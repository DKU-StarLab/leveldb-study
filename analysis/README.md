# How to analyze open source
1. Choose your topic.
2. Read documents, watch lecture and google your topic.
3. Study remarks and codes.
4. Try static analytics tools like scitools understand.
5. Run db_bench with gdb debugger or dynamic analyics tool like uftrace.
6. Draw figures to organize the structure, class diagram, code flow and etc. 
7. Write a english markdown document with figure and description.
8. Make a PPT for 15 min presentation.  
9. Upload your document and PPT(pdf format).

# Topic
## 1. Compaction
- Policy: Leveled, Tiered
- Compaction Trigger
- Merge Iterator
- Operations: Put

## 2. WAL
- Log structure
- Flush, Recovery
- Operations: Put

## 3. Memtable
- Data Structure: Skiplist
- Memory Management: Arena
- Immutable Memtable, Flush
- Operations: Put, Get, Seek

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
