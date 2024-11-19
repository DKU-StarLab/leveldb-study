## Cache

### Contents 
- [1. What is Cache](#1-what-is-cache)
- [2. What is LRU](#2-what-is-lru)
- [3. LRU Cache Structure in LevelDB](#3-lru-cache-structure-in-leveldb)
- [4. Overall Cache Flow](#4-overall-cache-flow)

---

### 1. What is Cache

Cache is hardware or software that temporarily stores data in computing environments. It is a smaller, faster, and more expensive memory used to improve the performance of recently or frequently accessed data.

There are several types of caches:

1. **CPU Cache**: Memory mounted next to the CPU
2. **Disk Cache**: Memory built into hard disks for disk control and external interface
3. **Other Caches**: These are the caches we need to understand in LevelDB. Caches other than the two mentioned above are mainly managed through software, such as page cache where the operating system's main memory is copied to the hard disk.

---

### 2. What is LRU

LRU(Least Recently Used) policy is a page replacement algorithm, which means that the least recently used data will be removed. The basic assumption of this algorithm is that the data that has not been used for the longest time is unlikely to be used in the future.

LRU Cache works by removing the least recently used item when the cache is full and placing a new node. LRU Cache can be implemented using **double linked list**.

Below is a diagram explaining LRU Cache.

<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/84978165/189130049-634c1d81-5b49-49b5-bfea-3621a82c6687.png">
</p>

The basic assumption is that the data closer to Head (rightmost node) is recently used and the data closer to Tail (leftmost node) is old. When accessing cached data, move the data to Head to indicate that it is recently used and remove it from the priority queue.

The order of reading data is A, B, C, D, E, D, F.

1. The numbers in parentheses indicate sorting. The smaller the number, the closer the data is to Tail.
2. When E is read, the cache is full, so the oldest data A is removed.
3. Continue reading D and F, and you can see that the node with the least access count is removed and replaced.

LevelDB uses two different data structures for LRU Cache:

1. **HashTable (HandleTable)**: Used for lookup
2. **Double Linked List**: Used for removing old data

---

### 3. LRU Cache Structure in LevelDB

To understand the LRU Cache structure in LevelDB accurately, we analyzed the source code of LevelDB through Git clone.

(source code download)

```
git clone --recurse-submodules https://github.com/google/leveldb.git leveldb_release
```

Below is a rough diagram of the overall LRU Cache structure. (For accurate code analysis, please refer to `leveldb_release/build/util/cache.cc`.)

<p align="center">
<img width="800" alt="image" src="https://user-images.githubusercontent.com/84978165/189133099-0140c4df-884a-4591-870d-a5e92be39df5.png">
</p>

#### (1) ShardedLRUCache
ShardedLRUCache in LevelDB consists of 16 LRU Caches internally and is defined as the external LRUCache.

#### Sharding
Sharding means dividing data into pieces and managing them. It is a kind of load balancing technique that distributes workload requests to multiple servers or processing devices. It means dividing a large database or network system into multiple small pieces and distributing them for storage and management.

Below is a diagram showing how to divide a table into different tables.

<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/84978165/189147668-2f5907b4-7529-427a-8176-7d4d9a55223d.png">
</p>

LevelDB uses LRU Cache through Sharding technique. ShardedLRUCache maintains an array of LRU Caches internally.

*When calling LRU Caches in ShardedLRUCache, Lock is performed for each LRU Cache to prevent multiple threads from accessing the same LRU Cache object.*

#### (2) LRUCache
Each Item in LRUCache is an LRUHandle, which will be described in (3) LRUHandle. LRUCache is managed by 1 HandleTable (HashTable) and 2 Double Linked Lists. LRUHandles are managed in both Double Linked List and HashTable HandleTable.

Below are the three elements that make up the Cache: Double Linked List and HashTable.

```
LRUHandle lru_; // will be described (5).
LRUHandle in_use_; // will be described (6).
HandleTable table_; // will be described (4).
```

#### (3) LRUHandle
LRUCache's object. HandleTable (HashTable) implements fast lookup by combining with Double Linked List and Double Linked List implements fast addition and deletion.

LRUHandle's components:

```cpp
struct LRUHandle {
    void* value;
    void (*deleter)(const Slice&, void* value); // to free the key and value space
    LRUHandle* next_hash; // handle hash collisions and keep objects (LRUHandle) belonging to the array
    LRUHandle* next; // used to maintain LRU order in doubly linked list
    LRUHandle* prev; // points to the previous node in a doubly linked list
    size_t charge;  
    size_t key_length; // length of key value
    bool in_cache; // whether the handle is in the cache table
    uint32_t refs; // the number of times the handle was referenced    
    uint32_t hash; // hash value of key used to determine sharding and fast comparison    
    char key_data[1]; // start of key
};
```

#### (4) HandleTable
It is a very simple hash table.

<p align="center">
<img width="300" alt="image" src="https://user-images.githubusercontent.com/84978165/189152590-843477ba-efbd-41e6-a00e-6e0ed2e28062.png">
</p>

Declare a double pointer `list_` in the code to manage LRUHandle objects.

```cpp
uint32_t length_; // length of LRUHandle* array
uint32_t elems_; // number of nodes in the table
LRUHandle** list_;
```

Below is a diagram showing `LRUHandle** list_` as `LRUHandle* list_`.

<p align="center">
<img width="300" alt="image" src="https://user-images.githubusercontent.com/84978165/189152971-8c8aabfd-4bea-4a50-a3f1-60e0e028aa96.png">
</p>

Below are the LRUHandle methods for the HandleTable class.

```cpp
LRUHandle** FindPointer(const Slice& key, uint32_t hash);
// use next_hash to traverse the double linked lists until find the item corresponding to the key.
// if no match is found, next_hash points to the end of list_ and the value of next_hash is nullptr.
// if a match is found, a double pointer (LRUHandle) pointed to by next_hash is returned.
// due to the above characteristics, it is used in the first line of Lookup, Insert, and Remove function.

LRUHandle* Lookup(const Slice& key, uint32_t hash);
// directly read the value pointed to by the pointer (LRUHandle) by calling FindPointer

LRUHandle* Insert(LRUHandle* h);
// call FindPointer to put LRUHandle at the location pointed to by the pointer (next_hash).

LRUHandle* Remove(const Slice& key, uint32_t hash);
// directly deletes the item pointed to by the pointer (next_hash) by calling FindPointer

void Resize();
// dynamically expand array as LRUHandle grows
```

#### (5) in_use_ and (6) lru_
Each of them is a data structure that makes up the LRU Cache: Double Linked List. They separate hot and cold data and maintain an internal HashTable. Hot data is frequently accessed, while cold data is rarely accessed.

<p align="center">
<img width="400" alt="image" src="https://user-images.githubusercontent.com/84978165/189153724-0f2ab665-8ffb-4cc1-a986-e0425560178e.png">
</p>

#### (5) in_use_
Hot linked list, which maintains the cached object for use by the caller.

#### (6) lru_
Cold linked list, which maintains the popularity of cached objects.

Both of these double linked lists are managed by the `refs` variable. `in_use_` has `refs` of 2 because it is referenced by external users, and `lru_` has `refs` of 1 because it is not referenced.

*Here, `lru_` and `in_use_` are not actual nodes; they do not store data themselves.* Data is always inserted into the `lru_` list first. (Important, data is always inserted into the `lru_` list first.)

`lru_->next` (next pointer) points to the oldest data, and `lru_->prev` (previous pointer) points to the newest data. When a new Handle is inserted, it is inserted at the end of the double linked list, and `lru_->prev` (previous pointer) points to the newly inserted Handle. When a cache is accessed by external users, it goes from `lru_` to `next_hash` to `in_use_`, and `refs` increases from 1 to 2.

---

### 4. Overall Cache Flow

**LevelDB Cache Mechanism**

In LevelDB, Cache is checked when reading data, and the mechanism is shown in the diagram below.

<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/84978165/189153950-24b00d7d-a39b-44ac-b2f6-4defe5a08299.png">
</p>

* The function `Get` is called when reading data.

```cpp
leveldb::Status s = db->Get(leveldb::ReadOptions(), key, &value);
```

* Part of the source code of `DBImpl::Get`:

```cpp
<1> MemTable* mem = mem_;
<2> MemTable* imm = imm_;
<3> Version* current = versions_->current();

if (mem->Get(lkey, value, &s)) { <4>
} else if (imm != nullptr && imm->Get(lkey, value, &s)) { 
    <5>
} else { 
    <6>
    s = current->Get(options, lkey, value, &stats);
    have_stat_update = true;
}
```

1. Declare `memtable mem_` to find the table in memtable
2. If not found in memtable, declare `memtable imm_` to find the table in immutable memtable
3. If not found in both, declare `version current` to get the current version to find the table in sstable
4. Call `Memtable::Get` to read the table from disk
5. Similarly, call `Memtable::Get` to read the table from immutable memtable
6. Call `Version::Get` to read the table from sstable

Version::Get calls `TableCache::Get` to read the table.

---

**LevelDB Cache Usage**

`TableCache::Get` is the part where LevelDB uses Cache.

TableCache::Get source code:

```cpp
Cache::Handle* handle = nullptr;

<1> Status s = FindTable(file_number, file_size, &handle);
    
if (s.ok()) {
    <2> 
    Table* t = reinterpret_cast<TableAndFile*>(cache_->Value(handle))->table;

    s = t->InternalGet(options, k, arg, handle_result);

    cache_->Release(handle);
}

return s;
```

+LevelDB has two different caches: **TableCache** and **BlockCache**.

#### <1> TableCache Usage (FindTable)
Find the table corresponding to the file in the cache. If not found, open the file first and then create the table corresponding to the file and add it to the cache.

Below is the structure of TableCache.

<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/84978165/189172319-30682e1a-6f1b-4b1d-8b15-5e6dce460180.png">
</p>

*key* is the file number of the SSTable.
*value* is divided into two sections:

- **RandomAccessFile**: Pointer to the opened SSTable on disk
- **Table**: Pointer to the Table structure corresponding to the SSTable in memory, which stores the `cache_id` of the SSTable and the block cache

#### <2> BlockCache Usage (InternalGet -> BlockReader)
The InternalGet function that implements the logic of finding Key in the SSTable calls BlockReader. BlockCache is used when the block is found in the BlockCache; if not found, the file is opened and read, and then the block is added to the BlockCache.

* BlockReader Cache Usage Algorithm:
  1. Try to get the block directly from the BlockCache.
  2. If not found in the BlockCache, call `ReadBlock` to read from the file.
  3. If reading is successful, add the block to the BlockCache.

Below is the structure of BlockCache.

<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/84978165/189172561-b52b24a4-dfb5-4bb4-b0d4-69ca0963380e.png">
</p>

*key* is composed of the offset of each SSTable file and a unique `cache_id` to distinguish it from other SSTable files.

*value* is composed of Data blocks of the opened SSTable file.

After BlockReader finishes looking up in the BlockCache and inserting into the BlockCache, the read operation finishes using the Cache.

Below is a rough diagram of how to use Cache in LevelDB.

<p align="center">
<img width="700" alt="image" src="https://user-images.githubusercontent.com/84978165/189153950-24b00d7d-a39b-44ac-b2f6-4defe5a08299.png">
</p>

---

**LevelDB Cache Creation**

TableCache is created using the `cache_size` option in `./db_bench` and set using the `TableCache::TableCacheSize` function.

TableCache::TableCache BackTrace:

```
leveldb::Benchmark::Run
leveldb::Benchmark::Open 
leveldb::DB::Open
leveldb::DBImpl::DBImpl
leveldb::TableCache::TableCache
```
