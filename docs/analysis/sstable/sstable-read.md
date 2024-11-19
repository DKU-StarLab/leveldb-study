## SSTable - Read
This document explores how LevelDB finds a value for a desired key through the Get Operation, specifically focusing on the process of searching within SSTables stored in storage, using a Top-Down approach.
<br/>

### LevelDB Get Operation
LevelDB searches for a desired key in the following order:

1. Search in MemTable
2. If not found, search in Immutable MemTable
3. If not found, search in storage (disk)
<br/>

We can see this search process in `DBImpl::Get` as follows:

```cpp
Status DBImpl::Get(const ReadOptions& options, const Slice& key,
                   std::string* value) {

  // ...

  MemTable* mem = mem_;
  MemTable* imm = imm_;
  Version* current = versions_->current();
  
  // ...
  {
    mutex_.Unlock();
    LookupKey lkey(key, snapshot);
    // 1. Searching in the MemTable
    if (mem->Get(lkey, value, &s)) {
    // 2. If not in MemTable, searching in the Immutable MemTable
    } else if (imm != nullptr && imm->Get(lkey, value, &s)) {
    // 3. If not in Immutable MemTable, searching in storage(disk)
    } else {
      s = current->Get(options, lkey, value, &stats);
      have_stat_update = true;
    }
    mutex_.Lock();
  }
  // ...
}
```
<br/>

### Process of Finding Target Key in Storage
The process of finding a target key in storage begins with `Version::Get` and follows these steps:

1. Select SSTables that might contain the target key from each Level
2. Search for the target key within the selected SSTables
<br/>

We can see this search process in `Version::Get` as follows:

```cpp
Status Version::Get(const ReadOptions& options, const LookupKey& k,
                    std::string* value, GetStats* stats) {
  // ...

  struct State {
    // ...

    static bool Match(void* arg, int level, FileMetaData* f) {
      // ...
      // 2. Find the target key from the selected SSTable
      state->s = state->vset->table_cache_->Get(*state->options, f->number,
                                                f->file_size, state->ikey,
                                                &state->saver, SaveValue);
      // ...
    }
  };

  // ...
  // 1. At each level, select SSTables that may have a target key
  ForEachOverlapping(state.saver.user_key, state.ikey, &state, &State::Match);

  return state.found ? state.s : Status::NotFound(Slice());
}
```

> *When calling `ForEachOverlapping`, `Match` is passed as an argument, and `ForEachOverlapping` performs the process of finding the target key from the selected SSTables by executing the received `Match` on the selected SSTables.*

- Level 0: SSTables in Level 0 can have overlapping key ranges. Therefore, each SSTable is evaluated one by one using Linear Search.
- Other Levels: In levels other than Level 0, SSTable key ranges are separated. Therefore, Binary Search is used to quickly find SSTables that might contain the target key.
<br/>

```cpp
void Version::ForEachOverlapping(Slice user_key, Slice internal_key, void* arg,
                                 bool (*func)(void*, int, FileMetaData*)) {

  const Comparator* ucmp = vset_->icmp_.user_comparator();
  std::vector<FileMetaData*> tmp;
  tmp.reserve(files_[0].size());
  // Level 0: Picks out SSTables via Linear Search
  for (uint32_t i = 0; i < files_[0].size(); i++) {
    FileMetaData* f = files_[0][i];
    if (ucmp->Compare(user_key, f->smallest.user_key()) >= 0 &&
        ucmp->Compare(user_key, f->largest.user_key()) <= 0) {
      tmp.push_back(f);
    }
  }
  if (!tmp.empty()) {
    std::sort(tmp.begin(), tmp.end(), NewestFirst);
    for (uint32_t i = 0; i < tmp.size(); i++) {
      // Perform functions received as parameter
      if (!(*func)(arg, 0, tmp[i])) return;
    }
  }

  // Ohter Levels: Picks out SSTables via Binary Search
  for (int level = 1; level < config::kNumLevels; level++) {
    size_t num_files = files_[level].size();
    if (num_files == 0) continue;

    // FindFile : Gets index of SSTable that may have a target key via Binary search
    uint32_t index = FindFile(vset_->icmp_, files_[level], internal_key);
    if (index < num_files) {
      FileMetaData* f = files_[level][index];
      if (ucmp->Compare(user_key, f->smallest.user_key()) < 0) {

      } else {
        // Perform functions received as parameter
        if (!(*func)(arg, level, f)) return;
      }
    }
  }
}
```  
<br/>

### Process of Finding Target Key from Selected SSTable
Starting from `TableCache::Get`, the process follows these steps to find the target key:

1. Check if the SSTable object has already been cached, and if not, cache it.
2. Search inside the SSTable to find the target key.
<br/>

We can see this search process in `TableCache::Get` as follows:

```cpp
Status TableCache::Get(const ReadOptions& options, uint64_t file_number,
                       uint64_t file_size, const Slice& k, void* arg,
                       void (*handle_result)(void*, const Slice&,
                                             const Slice&)) {
  Cache::Handle* handle = nullptr;
  // 1. Checks whether the corresponding SSTable has already been cached
  //    If not, caches the corresponding SSTable
  Status s = FindTable(file_number, file_size, &handle);
  if (s.ok()) {
    Table* t = reinterpret_cast<TableAndFile*>(cache_->Value(handle))->table;
    // 2. Find the target key via searching inside the corresponding SSTable
    s = t->InternalGet(options, k, arg, handle_result);
    cache_->Release(handle);
  }
  return s;
}
```

> *When `TableCache::FindTable` is executed, the `Table::Open` method is called, which loads the Index Block and Filter Block of the corresponding SSTable into memory.*
<br/>

### Process of Searching for Target Key Inside SSTable
Starting from `Table::InternalGet`, the process follows these steps to find the target key:

1. Search the Index Block to identify potential Data Blocks containing the target key
2. If using bloom filter, check if the target key exists in the identified Data Block using the bloom filter
3. If the target key is determined to exist, create an Iterator for the identified Data Block
4. Search the Data Block using the created Iterator
5. If the target key is found, save its value
<br/>

We can see this search process in `Table::InternalGet` as follows:

```cpp
Status Table::InternalGet(const ReadOptions& options, const Slice& k, void* arg,
                          void (*handle_result)(void*, const Slice&,
                                                const Slice&)) {
  Status s;
  // Create an Iterator for the Index Block
  Iterator* iiter = rep_->index_block->NewIterator(rep_->options.comparator);
  // 1. Search the Index Block and find the Data Block that may have a target key
  iiter->Seek(k);
  if (iiter->Valid()) {
    // ...

    // 2. If using a bloom filter, 
    //    investigate with a bloom filter if there is a target key in the found Data Block
    if (filter != nullptr && handle.DecodeFrom(&handle_value).ok() &&
        !filter->KeyMayMatch(handle.offset(), k)) {
      // Not found
    } else {
      // 3. If it is determined that there is a target key,
      //    reate an Iterator for the found Data Block
      Iterator* block_iter = BlockReader(this, options, iiter->value());
      // 4. Exploring the Data Block using the generated Iterator
      block_iter->Seek(k);
      // 5. If find the target key, save the value
      if (block_iter->Valid()) {
        (*handle_result)(arg, block_iter->key(), block_iter->value());
      }
      // ...
    }
  }
  // ...
}
```

#### Table::BlockReader
> *Creates and returns an Iterator for the Data Block referenced by the Index Block Iterator's entry*

1. Check if the corresponding Data Block has already been cached using the `Lookup` method
2. If not cached, cache the corresponding Data Block:
   1) Read the contents of the corresponding Data Block using `ReadBlock`
   2) Create a new Block object with the read contents (effectively loading the Data Block into memory)
   3) Insert the loaded Data Block into the cache
3. Create an Iterator for that Data Block

> *If not using cache, just read the contents of the corresponding Data Block using `ReadBlock` and load it into memory*
<br/>

`Table::BlockReader` performs the following operations:

```cpp
Iterator* Table::BlockReader(void* arg, const ReadOptions& options,
                             const Slice& index_value) {
  // ...

  if (s.ok()) {
    BlockContents contents;
    if (block_cache != nullptr) {
      // ...

      // 1. Checks whether the corresponding Data Block has already been cached via Lookup
      cache_handle = block_cache->Lookup(key);
      if (cache_handle != nullptr) {
        block = reinterpret_cast<Block*>(block_cache->Value(cache_handle));
      } else {
        // 2. If not, caches the corresponding Data Block
        // 2-1. Read the contents of the corresponding Data Block via ReadBlock
        s = ReadBlock(table->rep_->file, options, handle, &contents);
        if (s.ok()) {
          // 2-2. Create a new Block object with read contents
          //      (It means loading the corresponding Data Block into memory)
          block = new Block(contents);
          if (contents.cachable && options.fill_cache) {
            // 2-3. Insert Loaded data block into cache
            cache_handle = block_cache->Insert(key, block, block->size(),
                                               &DeleteCachedBlock);
          }
        }
      }
    } else {
      // If do not use cache, just load the corresponding Data Block into memory
      s = ReadBlock(table->rep_->file, options, handle, &contents);
      if (s.ok()) {
        block = new Block(contents);
      }
    }
  }

  // 3. Create an Iterator for that Data Block
  Iterator* iter;
  if (block != nullptr) {
    iter = block->NewIterator(table->rep_->options.comparator);

    // ...
  } else {
    iter = NewErrorIterator(s);
  }
  return iter;
}
```

#### Block::Iter::Seek
> *Finds the target argument within the Block*

1. Use Binary Search to find the area where the target might be located
2. Use Linear Search to find the target within the found area
<br/>

`Block::Iter::Seek` performs the search as follows:

```cpp
void Seek(const Slice& target) override {
    // ...

    // 1. Find the area where the target is located via Binary Search
    while (left < right) {
      uint32_t mid = (left + right + 1) / 2;
      uint32_t region_offset = GetRestartPoint(mid);
      
      // ...
      Slice mid_key(key_ptr, non_shared);
      if (Compare(mid_key, target) < 0) {
        // if "mid" < "target"
        left = mid;
      } else {
        // if "mid" >= "target"
        right = mid - 1;
      }
    }

    // ...

    // 2. Find the target in the correspond area via Linear Search
    while (true) {
      if (!ParseNextKey()) {
        return;
      }
      if (Compare(key_, target) >= 0) {
        return;
      }
    }
  }
```

Based on the described content, here's a more detailed explanation of the process of searching for a target key inside an SSTable:

<p align="center">
   <img src = "https://user-images.githubusercontent.com/65762283/187970494-255dbac9-d76f-46a0-8ff9-3061506ae5a9.png">
</p>  

1. `NewIterator`: Create an Iterator for the Index Block
2. `Seek`: Use the created Iterator to search the Index Block and identify potential Data Blocks containing the target key
3. `KeyMayMatch`: (If using bloom filter) Use the bloom filter to check if the target key exists in the identified Data Block
4. `BlockReader`: If it exists, create an Iterator for the corresponding Data Block
5. `Seek`: Use the created Iterator to search within the Data Block for the target key
6. `SaveValue`: If the target key is found, save its value
<br/>

### Summary - Process of Finding Target Key in Storage

<p align="center">
   <img src = "https://user-images.githubusercontent.com/65762283/187468693-a1819b3e-8c09-4cff-828d-3e9f6707b340.png">
</p>  

1. Select SSTables from each Level that might contain the target key
2. Check if each selected SSTable object has been cached, and if not, cache it
   - During this process, the Index Block and Filter Block of the corresponding SSTable are loaded into memory
3. Search the Index Block to identify potential Data Blocks containing the target key
4. Use the bloom filter in the Filter Block to check if the target key exists in the identified Data Block
5. If it exists, check if the corresponding Data Block has been cached, and if not, cache it
   - During this process, the Data Block is loaded into memory
6. Search within the Data Block to find the target key

