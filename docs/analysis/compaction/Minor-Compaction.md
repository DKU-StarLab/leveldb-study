## Minor Compaction
  `Minor Compaction` 
  
   - Also known as `flush`, this process moves data from memory (imm memtable) to disk (level 0).

### Overall Minor Compaction Code Flow
> This section only describes the Minor Compaction process.

> For Major Compaction, please refer to [here](./analysis/compaction/Major-Compaction.md).
                                              
          
![image](https://user-images.githubusercontent.com/106041072/188577384-fca24121-ef6d-40b7-aa82-020faf6cc965.png)  
#### Overall Process          
1. `MaybeScheduleCompaction` checks if a Minor Compaction is needed and calls `BackgroundCall` if necessary.
2. `BackgroundCall` invokes `BackgroundCompaction` and checks for the presence of an imm memtable.
3. `CompactMemTable` calls the `WriteLevel0Table` function to execute the `Minor Compaction`.

### MaybeScheduleCompaction & BackgroundCompaction 
> These functions are explained in the [Major Compaction](./analysis/compaction/Major-Compaction.md) section, so they are omitted here.

### CompactMemTable
> This is where the actual Minor Compaction takes place.

```cpp
void DBImpl::CompactMemTable() {
  mutex_.AssertHeld();
  assert(imm_ != nullptr);

  // Save the contents of the memtable as a new Table
  VersionEdit edit;
  Version* base = versions_->current();
  base->Ref();
   //(TeamCompaction)1.Main point: call the `WriteLevel0Table` function for minor compaction
  Status s = WriteLevel0Table(imm_, &edit, base); 
  base->Unref();

   //(TeamCompaction)2. Check if WriteLevel0Table was executed successfully
  if (s.ok() && shutting_down_.load(std::memory_order_acquire)) { 
    s = Status::IOError("Deleting DB during memtable compaction");
  }
  
  //(TeamCompaction)3.If minor compaction is successful
  // Replace immutable memtable with the generated Table
  if (s.ok()) {
    edit.SetPrevLogNumber(0);
    edit.SetLogNumber(logfile_number_);  // Earlier logs no longer needed
    s = versions_->LogAndApply(&edit, &mutex_);
  }

  if (s.ok()) {  
    // Commit to the new state
    imm_->Unref();
    imm_ = nullptr;  
    has_imm_.store(false, std::memory_order_release);
    RemoveObsoleteFiles();
  } else {
    RecordBackgroundError(s);
  }
}
```
1. To execute `Minor Compaction`, the `WriteLevel0Table` function is called with the current imm memtable and version as arguments.
2. If an error occurs during the execution of the `WriteLevel0Table` function, an error message is sent.
3. If `Minor Compaction` is successfully executed, the imm memtable is released.

### WriteLevel0Table
> This function moves the imm memtable to disk.

```cpp
Status DBImpl::WriteLevel0Table(MemTable* mem, VersionEdit* edit,
                                Version* base) {
  mutex_.AssertHeld();
  const uint64_t start_micros = env_->NowMicros();
  FileMetaData meta;
  //(TeamCompaction)1. Organizes imm memtable's meta information.
  meta.number = versions_->NewFileNumber();
  pending_outputs_.insert(meta.number);
  Iterator* iter = mem->NewIterator();
  Log(options_.info_log, "Level-0 table #%llu: started",
      (unsigned long long)meta.number);

  Status s;
  {
    mutex_.Unlock();
    //(TeamCompaction)2. Change imm memtable to SST.
    s = BuildTable(dbname_, env_, options_, table_cache_, iter, &meta);
    mutex_.Lock();
  }

  Log(options_.info_log, "Level-0 table #%llu: %lld bytes %s",
      (unsigned long long)meta.number, (unsigned long long)meta.file_size,
      s.ToString().c_str());
  delete iter;
  pending_outputs_.erase(meta.number);

  // Note that if file_size is zero, the file has been deleted and
  // should not be added to the manifest.
  //(TeamCompaction)3. update the version
  int level = 0;
  if (s.ok() && meta.file_size > 0) {
    const Slice min_user_key = meta.smallest.user_key();
    const Slice max_user_key = meta.largest.user_key();
    if (base != nullptr) {
      level = base->PickLevelForMemTableOutput(min_user_key, max_user_key);
    }
    edit->AddFile(level, meta.number, meta.file_size, meta.smallest,
                  meta.largest);
  }

  CompactionStats stats;
  stats.micros = env_->NowMicros() - start_micros;
  stats.bytes_written = meta.file_size;
  stats_[level].Add(stats);
  return s;
}
```
1. First, the imm memtable's information is organized.
2. The `BuildTable` function is used to create an SST from the imm memtable information.
3. If the SST is successfully created, this information is updated in the Version.

### Trivial Move  
> A Trivial Move is a type of Minor Compaction where, if the newly created SST does not overlap with the keys of SSTs in each level, it is directly moved to level 2.

```cpp
void DBImpl::BackgroundCompaction() {
  
 // ...omitted 
  Status status;
  if (c == nullptr) {
    // Nothing to do
  } else if (!is_manual && c->IsTrivialMove()) {
    // 1.  Move file to next level
    assert(c->num_input_files(0) == 1);
    FileMetaData* f = c->input(0, 0);
    c->edit()->RemoveFile(c->level(), f->number);
    c->edit()->AddFile(c->level() + 1, f->number, f->file_size, f->smallest,
                       f->largest);
    status = versions_->LogAndApply(c->edit(), &mutex_);
    if (!status.ok()) {
      RecordBackgroundError(status);
    }
    VersionSet::LevelSummaryStorage tmp;
    Log(options_.info_log, "Moved #%lld to level-%d %lld bytes %s: %s\n",
        static_cast<unsigned long long>(f->number), c->level() + 1,
        static_cast<unsigned long long>(f->file_size),
        status.ToString().c_str(), versions_->LevelSummary(&tmp));
  }
  // ...omitted 
}


bool Compaction::IsTrivialMove() const {
  const VersionSet* vset = input_version_->vset_;
  // Avoid a move if there is lots of overlapping grandparent data.
  // Otherwise, the move could create a parent file that will require
  // a very expensive merge later on.
  return (num_input_files(0) == 1 && num_input_files(1) == 0 &&
          TotalFileSize(grandparents_) <=
              MaxGrandParentOverlapBytes(vset->options_));
}

```
- If `is_manual && c->IsTrivialMove()` is true, a Trivial Move is executed.
