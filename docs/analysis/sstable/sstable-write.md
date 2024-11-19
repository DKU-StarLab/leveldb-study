## SSTable - Write
SSTables are created in the following situations:

1. When a `Flush (Minor Compaction)` occurs from the MemTable
2. When `Compaction` occurs in storage

This document focuses on how SSTables are created when a `Flush` occurs from the MemTable.
<br>

### When a Flush Occurs from the MemTable
The process of a `Flush` occurring from the MemTable is as follows:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187967954-c9b740dc-18c6-4def-8170-bb29d3bb8809.png"></p>

`CompactMemTable` is called, which in turn calls `WriteLevel0Table`, resulting in the creation of an SSTable. At this point, `BuildTable` is the function that actually creates the SSTable.

The flow of `BuildTable` is as follows:

### Overall Process
![Sequence 01](https://user-images.githubusercontent.com/65762283/183480267-03e4a024-06b0-4798-83d0-74c50a5d0f1a.gif)

#### Steps
1. Create an instance of `TableBuilder`
2. Add key-value pairs from the MemTable one by one using the `Add` method of `TableBuilder`
3. Complete the process of creating the SSTable using the `Finish` method of `TableBuilder`
4. Write the contents in the `WritableFile` to storage
5. Load the SSTable stored in storage into the cache and check if it is available

```cpp
Status BuildTable(const std::string& dbname, Env* env, const Options& options,
                  TableCache* table_cache, Iterator* iter, FileMetaData* meta) {
  Status s;
  meta->file_size = 0;
  // Make sure the Iterator points to the first element
  iter->SeekToFirst();

  std::string fname = TableFileName(dbname, meta->number);
  if (iter->Valid()) {
    WritableFile* file;
    s = env->NewWritableFile(fname, &file);
    if (!s.ok()) {
      return s;
    }

    // 1. Create an instance of TableBuilder
    TableBuilder* builder = new TableBuilder(options, file);
    meta->smallest.DecodeFrom(iter->key());
    Slice key;

    // 2. Add key-value pairs of MemTable one by one via TableBuilder's "Add" method
    for (; iter->Valid(); iter->Next()) {
      key = iter->key();
      builder->Add(key, iter->value());
    }
    if (!key.empty()) {
      meta->largest.DecodeFrom(key);
    }

    // 3. Complete the process of creating SSTable via TableBuilder's "Finish" method
    s = builder->Finish();
    if (s.ok()) {
      meta->file_size = builder->FileSize();
      assert(meta->file_size > 0);
    }
    delete builder;

    // 4. Write the contents in the WritableFile to storage
    if (s.ok()) {
      s = file->Sync();
    }
    if (s.ok()) {
      s = file->Close();
    }
    delete file;
    file = nullptr;

    if (s.ok()) {
      // 5. Put the SSTable stored in storage into cache and check if it is available
      Iterator* it = table_cache->NewIterator(ReadOptions(), meta->number,
                                              meta->file_size);
      s = it->status();
      delete it;
    }
  }

  // Check for Iterator related errors
  if (!iter->status().ok()) {
    s = iter->status();
  }

  if (s.ok() && meta->file_size > 0) {
    // Keep it
  } else {
    env->RemoveFile(fname);
  }
  return s;
}
```

#### TableBuilder::Add
> *The role of passing the key-value pair currently referenced by the Iterator to each BlockBuilder within the TableBuilder.*

1. If the Data Block being created by the `BlockBuilder` is empty, meaning a new Data Block is being started, add a new entry to the Index Block. The entry added at this time is not for the newly started Data Block but for the Data Block that was being created just before.
2. If using a Bloom Filter, update the Filter Block as well.
3. Add data to the Data Block.
4. If the Data Block being created is full (i.e., exceeds the block size specified by the option), call `Flush`.

```cpp
void TableBuilder::Add(const Slice& key, const Slice& value) {
  Rep* r = rep_;
  
  // ...

  // 1. If the Data Block that BlockBuilder is creating is empty,
  //    add a new entry to the Index Block
  if (r->pending_index_entry) {
    assert(r->data_block.empty());
    r->options.comparator->FindShortestSeparator(&r->last_key, key);
    std::string handle_encoding;
    r->pending_handle.EncodeTo(&handle_encoding);
    r->index_block.Add(r->last_key, Slice(handle_encoding));
    r->pending_index_entry = false;
  }

  // 2. If using Bloom Filter, update the Filter Block as well
  if (r->filter_block != nullptr) {
    r->filter_block->AddKey(key);
  }

  r->last_key.assign(key.data(), key.size());
  r->num_entries++;
  // 3. Add data to the Data Block
  r->data_block.Add(key, value);

  const size_t estimated_block_size = r->data_block.CurrentSizeEstimate();
  // 4. If the Data Block being created is full, call "Flush"
  if (estimated_block_size >= r->options.block_size) {
    Flush();
  }
}
```
#### TableBuilder::Finish
> *Called when `Add` is finished for all key-value pairs in the MemTable, and it finalizes the SSTable being written.*

1. Call `Flush`.
2. If using a Bloom Filter, add the Filter Block to the `WritableFile` using `FilterBlockBuilder`.
3. Add the Meta Index Block to the `WritableFile`.
4. Add the Index Block being created by `BlockBuilder` to the `WritableFile`.
5. Add the Footer to the `WritableFile`.

```cpp
Status TableBuilder::Finish() {
  Rep* r = rep_;
  // 1. Call "Flush"
  Flush();
  assert(!r->closed);
  r->closed = true;

  BlockHandle filter_block_handle, metaindex_block_handle, index_block_handle;

  // 2. If using Bloom Filter, add the Filter Block to the WritableFile.
  if (ok() && r->filter_block != nullptr) {
    WriteRawBlock(r->filter_block->Finish(), kNoCompression,
                  &filter_block_handle);
  }

  // 3. Add the Meta Index Block to the WritableFile
  if (ok()) {
    BlockBuilder meta_index_block(&r->options);
    if (r->filter_block != nullptr) {
      std::string key = "filter.";
      key.append(r->options.filter_policy->Name());
      std::string handle_encoding;
      filter_block_handle.EncodeTo(&handle_encoding);
      meta_index_block.Add(key, handle_encoding);
    }

    WriteBlock(&meta_index_block, &metaindex_block_handle);
  }

  // 4. Add the Index Block to the WritableFile.
  if (ok()) {
    if (r->pending_index_entry) {
      r->options.comparator->FindShortSuccessor(&r->last_key);
      std::string handle_encoding;
      r->pending_handle.EncodeTo(&handle_encoding);
      r->index_block.Add(r->last_key, Slice(handle_encoding));
      r->pending_index_entry = false;
    }
    WriteBlock(&r->index_block, &index_block_handle);
  }

  // 5. Add the Footer to the WritableFile.
  if (ok()) {
    Footer footer;
    footer.set_metaindex_handle(metaindex_block_handle);
    footer.set_index_handle(index_block_handle);
    std::string footer_encoding;
    footer.EncodeTo(&footer_encoding);
    r->status = r->file->Append(footer_encoding);
    if (r->status.ok()) {
      r->offset += footer_encoding.size();
    }
  }
  return r->status;
}
```

#### TableBuilder::Flush
> *The role of writing the Data Block being created to storage.*

1. Add the contents of the Data Block being created to the `WritableFile`.
2. Write the contents of the `WritableFile` to storage.
3. If using a Bloom Filter, create a new Bloom Filter.

```cpp
void TableBuilder::Flush() {
  Rep* r = rep_;
  
  // ...

  // 1. Add the contents of the Data Block being created to the WritableFile
  WriteBlock(&r->data_block, &r->pending_handle);
  if (ok()) {
    r->pending_index_entry = true;
    // 2. Write the contents of WritableFile to storage
    r->status = r->file->Flush();
  }
  // 3. If using Bloom Filter, create a new Bloom Filter
  if (r->filter_block != nullptr) {
    r->filter_block->StartBlock(r->offset);
  }
}
```
