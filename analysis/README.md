# LevelDB analysis
## 1. WAL/Manifest
- Log structure
- Flush, Recovery
- Operations: Put

## 2. Memtable
- Data Structure: Skiplist
- Memory Management: Arena
- Immutable Memtable, Flush
- Operations: Put, Get, Seek

## 3. Compaction
- Policy: Leveled, Tiered
- Compaction Trigger
- Merge Iterator
- Operations: Put

## 4. SST file
- SST file format
- Index/Data Block format
- Two Level Iterator
- Operations: Put, Get, Seek

## 5. Bloom Filiter
- Bloom Filiter Structure
- Flush, Compaction
- Operations: Put, Get, Seek

## 6. Cache
- Cache Structure
- Index Block, Data Block
- Replacement Policy: LRU
- Operations: Get, Seek
