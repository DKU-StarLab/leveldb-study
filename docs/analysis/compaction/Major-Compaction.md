## Major Compaction
  What is `Major Compaction`?  
      - This is the actual process we commonly refer to as `Compaction`.  
      - Unlike `Minor Compaction`, which moves data from memory to disk, it merges data within the disk.  
      - It merges each data and moves it to a lower level.  
      
  Why use `Major Compaction`?  
      - The most obvious benefit of using `Major Compaction` is to clean up duplicate data.  
      - If the same key exists in sst files of different levels, you can delete the data (old data) at the lower level.  
      - Since previously written data might be needed, data to be deleted is recorded sequentially, and the latest data is updated to save disk space.  
      - Since Level 0 may not have ordered data files, merging them into Level 1 sorts the data, making it easier to find files and improving read efficiency.
      
  When does `Major Compaction` occur?  
      - It occurs when the files at each level accumulate to a threshold and there is no immutable present.
      
## Overall Major Compaction Code Flow
  > Let's take a look at the overall Major Compaction Code Flow.

![image](https://user-images.githubusercontent.com/106041072/188577384-fca24121-ef6d-40b7-aa82-020faf6cc965.png)  
When the files at each level accumulate to a threshold, `MaybeScheduleCompaction` determines whether a merge is needed. If a merge is necessary, it checks for the presence of `immutable` and, if absent, calls `PickCompaction` to gather information for the merge, and Major Compaction proceeds in `DoCompactionWork`.  

Let's delve into the process of Major compaction through the source code.    

##### Overall Process  
  1. The number of files at a certain level reaches a threshold. 
  2. `MaybeScheduleCompaction` determines if a merge is needed.  
  3. `BackgroundCompaction` checks for the presence of immutable and, if absent, calls functions for Major Compaction.  
  4. `PickCompaction` stores the information needed for the merge. 
  5. With the stored information, the actual merge is carried out in `DoCompactionWork`.  
  6. In `DoCompactionWork`, `OpenCompactionOutputFile`, `FinishCompactionOutputFile`, and `InstallCompactionResults` are executed to create sst files, insert merged records, check for errors, and place the files in the respective level.  
  7. Afterward, the version is updated, and finally, `CleanupCompaction` is called to delete unnecessary sst files, completing the Major Compaction.  

### MaybeScheduleCompaction
> Determines if a merge is needed.
```cpp
void DBImpl::MaybeScheduleCompaction() {
  mutex_.AssertHeld();
  //(TeamCompaction)If a merger is already in progress, DB is being deleted, or if there is an error, nothing will happen.
  if (background_compaction_scheduled_) {
  } else if (shutting_down_.load(std::memory_order_acquire)) {
  } else if (!bg_error_.ok()) {
  //(TeamCompaction)If immutable does not exist, manual compaction do not exist, and mergers at each level are not required, nothing will happen.
  } else if (imm_ == nullptr && manual_compaction_ == nullptr &&
             !versions_->NeedsCompaction()) {
  //(TeamCompaction)In other cases, since a merger occurs, call 'BGWork' to proceed with the merger.
  } else {
    background_compaction_scheduled_ = true;
    env_->Schedule(&DBImpl::BGWork, this);
  }
}
```  
1. If a merge is already in progress, the DB is being deleted, or there is an error, nothing happens.  
2. If immutable does not exist, manual compaction does not exist, and compaction is not needed at each level (`NeedCompaction`), nothing happens. (Manual compaction will be explained in the BackgroundCompaction section.)  
3. In other cases, since a merge is needed, `BGWork` is called to proceed with the merge.  

### BackgroundCompaction
> Determines Major Compaction or Minor Compaction based on the presence of immutable. Also, if the user wants manual compaction, it proceeds here.  

```cpp
void DBImpl::BackgroundCompaction() {
  mutex_.AssertHeld();

//(TeamCompaction)If imutable exists, proceed with Minor Compact through the CompactMemtable function.
  if (imm_ != nullptr) {
    CompactMemTable();
    return;
  }

  Compaction* c;
  //(TeamCompaction)If you want to merge manually, proceed with the manual merger with true (most of them are automatically merged, so they are not used well)
  bool is_manual = (manual_compaction_ != nullptr);
  InternalKey manual_end;
  if (is_manual) {
    ManualCompaction* m = manual_compaction_;
    c = versions_->CompactRange(m->level, m->begin, m->end);
    m->done = (c == nullptr);
    if (c != nullptr) {
      manual_end = c->input(0, c->num_input_files(0) - 1)->largest;
    }
    Log(options_.info_log,
        "Manual compaction at level-%d from %s .. %s; will stop at %s\n",
        m->level, (m->begin ? m->begin->DebugString().c_str() : "(begin)"),
        (m->end ? m->end->DebugString().c_str() : "(end)"),
        (m->done ? "(end)" : manual_end.DebugString().c_str()));
  } //(TeamCompaction)Store information that needs to be merged if immutable does not exist
  else {
    c = versions_->PickCompaction();
  }
  
//...skipped

Status status;
  //(TeamCompaction)Nothing happens if there is no information to merge
  if (c == nullptr) {
  } else if (!is_manual && c->IsTrivialMove()) {
  
    //...skipped (TeamCompaciton) Manual Compaction progression part
    
  } //(TeamCompaction)With information to merge, proceed with Major Compaction.
  else {
    CompactionState* compact = new CompactionState(c);
    status = DoCompactionWork(compact);
    if (!status.ok()) {
      RecordBackgroundError(status);
    }
    //(TeamCompaction)If there is no problem after completing the merger completely, remove the sst files (files collected after the merger) that are now unnecessary
    CleanupCompaction(compact);
    //(TeamCompaction)Remove the sst files that were saved for the merger
    c->ReleaseInputs();
    RemoveObsoleteFiles();
  }
  
//...skipped

```  

1. If immutable exists, Minor Compaction (Flush) is performed through `CompactMemtable`.  
2. If immutable does not exist and manual compaction is not desired, information for compaction is stored through `PickCompaction`.  
3. If there is no information to merge, nothing happens. If there is, Major Compaction is carried out in `DoCompactionWork` based on that information.  
4. After the merge is completed in `DoCompactionWork` and the state is intact, unnecessary sst files from before the merge are removed through `CleanupCompaction` to finish.  

##### (Additional Explanation)  
> Manual Compaction vs Automatic Compaction  

Manual Compaction  
  - Rarely used and mainly for debugging purposes.  
  - To use, set a key range in the benchmark and execute it, setting the manual compaction boolean to true to perform manual compaction.  
  
Automatic Compaction  
  - Most of the compactions we use are performed automatically.  

### DoCompactionWork
> The actual Major Compaction is carried out.  

```cpp
Status DBImpl::DoCompactionWork(CompactionState* compact) {

//...skipped

  //(TeamCompaction)Create an iter for the index block and data block of each sst file from level 0, 1 to N, and use it to find each key. 
  //(TeamCompaction)After that, arrange the created iters so that they can be listed in the order of level 0, 1 to N, and store them in input (see Compaction-Iter.md for details)
  Iterator* input = versions_->MakeInputIterator(compact->compaction);
  
// Release mutex while we're actually doing the compaction work
  mutex_.Unlock();
  //(TeamCompaction)Position the pointer position of the created iter first
  input->SeekToFirst();
  Status status;
  //(TeamCompaction)Parse the internal key and divide it into user key, sequence number, and type
  ParsedInternalKey ikey;
  std::string current_user_key;
  bool has_current_user_key = false;
  //(TeamCompaction)Set the latest key to the highest value
  SequenceNumber last_sequence_for_key = kMaxSequenceNumber;
  //(TeamCompaction)The process of repeatedly finding and processing the key/value that needs to be merged through iter stored in the input
  while (input->Valid() && !shutting_down_.load(std::memory_order_acquire)) {
  
   //...skipped
   
    //(TeamCompaction)Obtain the key of the current corresponding sst file
    Slice key = input->key();
    //(TeamCompaction)Check if you need an sst file to put the key in, and if there is an sst file to put in, the merger is completed
    if (compact->compaction->ShouldStopBefore(key) && 
        compact->builder != NULL) {
      status = FinishCompactionOutputFile(compact, input);
    }
   
    //(TeamCompaction)Compare different sequences for the same key to obtain the latest user key and delete records from different user keys that were the same
    bool drop = false;
    if (!ParseInternalKey(key, &ikey)) {
      // Do not hide error keys
      current_user_key.clear();
      has_current_user_key = false;
      last_sequence_for_key = kMaxSequenceNumber;
    } else {
      if (!has_current_user_key ||
          user_comparator()->Compare(ikey.user_key, Slice(current_user_key)) !=
              0) {
        // First occurrence of this user key
        current_user_key.assign(ikey.user_key.data(), ikey.user_key.size());
        has_current_user_key = true;
        last_sequence_for_key = kMaxSequenceNumber;
      }

      if (last_sequence_for_key <= compact->smallest_snapshot) {
        // Hidden by an newer entry for same user key
        drop = true;  // (A)
      } else if (ikey.type == kTypeDeletion &&
                 ikey.sequence <= compact->smallest_snapshot &&
                 compact->compaction->IsBaseLevelForKey(ikey.user_key)) {
        // For this user key:
        // (1) there is no data in higher levels
        // (2) data in lower levels will have larger sequence numbers
        // (3) data in layers that are being compacted here and have
        //     smaller sequence numbers will be dropped in the next
        //     few iterations of this loop (by rule (A) above).
        // Therefore this deletion marker is obsolete and can be dropped.
        drop = true;
      }

      last_sequence_for_key = ikey.sequence;
    }
    
  //...skipped

    if (!drop) {
      //(TeamCompaction)Create new sst file if necessary
      if (compact->builder == nullptr) {
        status = OpenCompactionOutputFile(compact);
        if (!status.ok()) {
          break;
        }
      }
      if (compact->builder->NumEntries() == 0) {
        compact->current_output()->smallest.DecodeFrom(key);
      }
      compact->current_output()->largest.DecodeFrom(key);
      //(TeamCompaction)Add records from the latest user key to the sst file
      compact->builder->Add(key, input->value());

      //(TeamCompaction)If data accumulates in the sst file and exceeds the maximum file size, the merger of the sst file is completed
      if (compact->builder->FileSize() >=
          compact->compaction->MaxOutputFileSize()) {
        status = FinishCompactionOutputFile(compact, input);
        if (!status.ok()) {
          break;
        }
      }
    }
    //(TeamCompaction)Among the sst files arranged in order of level 0, 1 to N in the input variable, the next sst file is moved on
    input->Next();
  }
  
  if (status.ok() && shutting_down_.load(std::memory_order_acquire)) {
    status = Status::IOError("Deleting DB during compaction");
  }
  //(TeamCompaction)If the sst file does not have an error and the sst file exists, the merger is completed
  if (status.ok() && compact->builder != nullptr) {
    status = FinishCompactionOutputFile(compact, input);
  }
  if (status.ok()) {
    status = input->status();
  }
  
  //...skipped
  
  //(TeamCompaction)Move the merged sst file to its level
  if (status.ok()) {
    status = InstallCompactionResults(compact);
  }
  if (!status.ok()) {
    RecordBackgroundError(status);
  }
  VersionSet::LevelSummaryStorage tmp;
  Log(options_.info_log, "compacted to: %s", versions_->LevelSummary(&tmp));
  return status;
}

```  
1. Create an iter for the `index block` and `data block` of each sst file from level 0, 1 to N, and use it to find each key. Then, arrange the created iters so that they can be listed in the order of level 0, 1 to N, and store them in `input`.  
2. Position the pointer of the iter to the first position and parse the `internalkey` into user key, sequence, and type.  
3. Obtain the key of the current corresponding sst file using `key()`.  
4. Compare different sequences for the same key to obtain the latest user key's record and delete records from different user keys that were the same.  
5. If an sst file is needed, create a new one and insert the latest user key's record.  
6. If data accumulates in the sst file and exceeds the maximum file size, complete the merge and move to the next sst file.  
7. Repeat steps 2-6 to complete the merge of all sst files, check the overall status, and if there are no errors, move the merged sst file to its level.  

### OpenCompactionOutputFile
> Creates a new sst file to insert the merged user key records.  

```cpp
Status DBImpl::OpenCompactionOutputFile(CompactionState* compact) {

 //...skipped
 
  //(TeamCompaction)Set the number of the newly created sst file
  std::string fname = TableFileName(dbname_, file_number);
  //(TeamCompaction)Numbered and temporarily merged records in writablefile
  Status s = env_->NewWritableFile(fname, &compact->outfile);
  //(TeamCompaction)If the record is in good condition, create a sst file and add it to the builder
  if (s.ok()) {
    compact->builder = new TableBuilder(options_, compact->outfile);
  }
  return s;
}
```  
1. Assign a number to the newly created sst file.  
2. Numbered and temporarily merged records in `WriteableFile`.  
3. If the record is in good condition, create an sst file and add it to the builder.  

### FinishCompactionOutputFile
> Checks for errors in the merged iter and sst file.  

```cpp
Status DBImpl::FinishCompactionOutputFile(CompactionState* compact,
                                          Iterator* input) {
  //...skipped

  //(TeamCompaction)Check for errors for iter
  Status s = input->status();
  const uint64_t current_entries = compact->builder->NumEntries();
  if (s.ok()) {
    s = compact->builder->Finish();
  } else {
    compact->builder->Abandon();
  }
  
  //...skipped

  //(TeamCompaction)Check and finalize errors for the sst file itself
  if (s.ok()) {
    s = compact->outfile->Sync();
  }
  if (s.ok()) {
    s = compact->outfile->Close();
  }
  delete compact->outfile;
  compact->outfile = nullptr;
  
  //...skipped
  
}
```  
1. Check for errors in the iter.  
2. Check and finalize errors for the sst file itself.  

### InstallCompactionResults
> Moves the merged sst file to its level and updates the version.  

```cpp
Status DBImpl::InstallCompactionResults(CompactionState* compact) {

  //...skipped
  
  //(TeamCompaction) Moved merged sst files to that level
  compact->compaction->AddInputDeletions(compact->compaction->edit());
  const int level = compact->compaction->level();
  for (size_t i = 0; i < compact->outputs.size(); i++) {
    const CompactionState::Output& out = compact->outputs[i];
    compact->compaction->edit()->AddFile(level + 1, out.number, out.file_size,
                                         out.smallest, out.largest);
  }
  //(TeamCompaction)Update version
  return versions_->LogAndApply(compact->compaction->edit(), &mutex_);
}
```  

1. Move the merged sst file to its level.
2. Update the version to complete.  

### CleanupCompaction
> Removes unnecessary sst files (sst files before the merge) after the merge is completed.

```cpp
void DBImpl::CleanupCompaction(CompactionState* compact) {
  mutex_.AssertHeld();
  //(TeamCompaction)Remove files if they exist in the builder that contains the sst files that need to be merged
  if (compact->builder != nullptr) {
    // May happen if we get a shutdown call in the middle of compaction
    compact->builder->Abandon();
    delete compact->builder;
  } else {
    assert(compact->outfile == nullptr);
  }
  delete compact->outfile;
  for (size_t i = 0; i < compact->outputs.size(); i++) {
    const CompactionState::Output& out = compact->outputs[i];
    pending_outputs_.erase(out.number);
  }
  delete compact;
}
```  
1. Since the latest sst file has been updated, if there are files in the `builder` that contains the sst files to be merged, they are removed as they are no longer needed.  
2. Finalize the Major Compaction.





