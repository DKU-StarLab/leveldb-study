# How to analyze LevelDB
1. Choose your topic.
2. Do a research of your chosen topic by reading documents and/or watching lectures.
3. Study remarks and codes related to your topic.
4. Try static analysis tools like Understand by [SciTools](https://www.scitools.com/).
5. Run db_bench with gdb debugger or dynamic analysis tool like uftrace.
6. Draw figures to organize the structure, class diagram, code flow and etc. 
7. Write a markdown document with figure and description.
8. Create a 15-minute powerpoint presentation.  
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
