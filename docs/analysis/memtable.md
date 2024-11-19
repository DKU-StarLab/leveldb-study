## Memtable

Memtable can be viewed as a memory copy of the log. Its main role is to store log data in a structured manner.

![leveldb_format](https://wiesen.github.io/assets/leveldb-architecture.png)

(source: https://www.jianshu.com/p/0e6116f23c3d)

In LevelDB, when writing data to the DB, Memtable is the space where kv data is stored. When the data written to Memtable exceeds the specified size (Options:write_buffer_size), it converts to an Immutable Memtable, and simultaneously creates a new Memtable for storing data. When compaction occurs in the background, the Immutable Memtable is dumped to disk, creating an SSTable.

---

### Structure & Operation

![memtable_key_entry](https://github.com/user-attachments/assets/9bc80af1-856c-46be-ac5f-4f07ce4b4072)

(source: https://blog.csdn.net/redfivehit/article/details/107509884)

- **Klength & Vlength**: Varint32, maximum 5 bytes
- **SequenceNumber + ValueType**: 8 bytes

The Memtable key consists of four parts:  
Memtable key = key length + user key + value type + sequence number

Memtable can store multiple versions of the same key. KeyComparator first compares user keys in ascending order, then sequence numbers in descending order to determine entries. The user key is placed first to manipulate the same user key with sequence numbers.

MemTable provides Add and Get interfaces for KV entries in memory, but there is no actual Delete operation. Deleting a key's value is inserted as an entry with a deletion tag in Memtable, with actual deletion occurring during compaction.

Memtable is an interface class built on arena and skiplist. Arena manages memory, while skiplist is used for actual KV storage.

---

### Component

#### Arena: Memory Management for Memtable

![arena](https://wiesen.github.io/assets/arena.png)

(source: http://mingxinglai.com/cn/2013/01/leveldb-arena/)

1. Memory management for usage statistics: Memtable has a size limit (write_buffer_size). Memory is allocated through a unified interface.
2. Memory alignment guarantee: Arena requests memory in kBlockSize units (static const int kBlockSize = 4096) and provides memory address alignment for efficiency. Uses Vector to store allocated memory.
3. Prevention of inefficiency from frequent small memory block allocations and waste from large block allocations: When memtable requests memory, if size is less than kBlockSize / 4, it allocates from the current memory block; otherwise, it makes a new request (new).
4. When Memtable reaches its limit, it dumps to disk and Arena immediately releases used memory.
5. Memtable uses reference counting (refs): Even after Immutable Memtable completes disk dumping, it's not deleted if the reference count isn't 0.

#### Skiplist: Actual Structure of Memtable

![skiplist](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Skip_list_add_element-en.gif/400px-Skip_list_add_element-en.gif)

(source: https://en.wikipedia.org/wiki/Skip_list)

1. Performance bottlenecks can occur here due to the high cost of insert (random write) operations in sorted structures. LevelDB uses a lightweight Skiplist instead of complex B-trees.
2. Skiplist is an alternative data structure to binary trees. It maintains probabilistic balance, has similar time complexity of O(logN), and enables space savings.
3. Skiplist offers better concurrency performance than binary trees. While binary trees may require rebalancing during updates, Skiplist does not.
4. LevelDB's Skiplist doesn't require locks or node references, implementing thread synchronization through Memory Barriers.

---

### Coding & Function Analysis

![codeflow](https://pic2.zhimg.com/v2-867d7b9bb8b7c9584bfeb7b13156b70d_r.jpg)

(source: https://zhuanlan.zhihu.com/p/25300086)

#### Construction and destruction:

Memtable's object structure requires explicit calls. Arena initialization and Skiplist structure are key elements. The Memtable class releases memory through `Unref()`, and LevelDB prohibits copy constructors and assignment operators.

#### Operation:

- **Write**: `void Add(SequenceNumber seq, ValueType type, const Slice& key, const Slice& value)`  
  Status `DBImpl::MakeRoomForWrite(bool force)`

![makeroomforwrite](https://github.com/arashio1111/arashio1111.GitHub.io/blob/main/2022-09-23%20141330.png?raw=true)

1. **Check level0 & mem_**: `MakeRoomForWrite()` checks if Memtable, Immutable Memtable, and Level 0 are full. If full, it performs flush/compaction and creates a new Memtable.
2. **Encode**: Encapsulates passed variables into InternalKey and encodes them with value as an entry.
3. **Insert into data structure**: Calls `SkipList::Insert()` to insert data.

- **Read**: `bool Get(const LookupKey& key, std::string* value, Status* s)`

1. Obtains memtable_key from LookupKey.
2. Calls `MemTableIterator::Seek()` to return MemTableIterator.
3. Restores MemTableIterator's key and decodes the last 8 bytes to check type.
4. **a)** If `kTypeValue`, returns value as valid data.
5. **b)** If `kTypeDeletion`, sets Status to NotFound.

- **Delete**: No delete function exists; instead adds an entry with `ValueType = kTypeDeletion`.
