# Homework & Solutions

### Question 1. (Solution - Jongki Park)
#### Why do LSM-tree and LevelDB use leveled structure? 
* Hint 1 - Stackoverflow
    - [Why does LevelDB needs more than two levels?](https://stackoverflow.com/questions/14305113/why-does-leveldb-needs-more-than-two-levels)
    - [Why rocksDB needs multiple levels?](https://stackoverflow.com/questions/68297612/why-rocksdb-needs-multiple-levels)
    - [Why does LevelDB make its lower level 10 times bigger than upper one?](https://stackoverflow.com/questions/52346275/why-does-leveldb-make-its-lower-level-10-times-bigger-than-upper-one)  

* Hint 2 – Memory hierarchy
* Hint 3 - [Patrick O'Neil, The Log-Structured Merge-Tree (LSM-Tree), 1996](https://www.cs.umb.edu/~poneil/lsmtree.pdf)

### Question 2. (Solution - Jongki Park) 
#### In leveldb, max size of level i is 10^iMB. But max size of level 0 is 8MB. Why? 
* Hint 1 - leveldb source code
    - leveldb/db/version_set.cc:VersionSet::Finalize
    - leveldb/db/dbformat.h:kL0_CompactionTrigger
* Hint 2 - [leveldb-handbook, Compaction (Use google chrome translator)](https://leveldb-handbook.readthedocs.io/zh/latest/compaction.html)

### Practice 1. (Solution - Suhwan Shin)
```
[A] $ ./db_bench --benchmarks="fillseq" 
[B] $ ./db_bench --benchmarks="fillrandom"
```
* Q1. Compare throughput, latency, and stats of two benchmarks and explain why.
    - Hint - Seek Time, Key Range, Compaction  
* Q2. In benchmark A, SSTs are not written in L0. Why?
    - Hint - Flush, Compaction Trigger
* Q3. Calculate SAF (Space Amplification Factor) for each benchmark.
    - Hint - db_bench meta operation

### Practice 2. (Solution - Suhwan Shin)
```
[A] $ ./db_bench --benchmarks="fillrandom" --value_size=100 --num=1000000 --compression_ratio=1
[B] $ ./db_bench --benchmarks="fillrandom" --value_size=1000 --num=114173 --compression_ratio=1
```
> Note 1. key_size = 16B  
> Note 2. same total kv pairs size.  
> Note 3. # of B's entries = 114173 = (16+100)/(16+1000) * 1000000 

* Q. The size of input kv pairs is the same. But One is better in throughput, the other is better in latency. Explain why.
    - Hint. Batch Processing

### Practice 3. (Solution - Zhu Yongjie)
```
[Load] $ ./db_bench --benchmarks="fillrandom" --use_existing_db=0

[A] $ ./db_bench --benchmarks="readseq" --use_existing_db=1
[B] $ ./db_bench --benchmarks="readrandom" --use_existing_db=1
[C] $ ./db_bench --benchmarks="seekrandom" --use_existing_db=1
````
> Note - Before running A, B, and C, run db_load benchmark.

* Q1. Which user key-value interface does each benchmark use? (Put, Get, Iterator, ...)
    - Hint 1 - _leveldb/doc/index.md_
    - Hint 2 - _leveldb/benchmarks/db_bench.cc_
* Q2. Compare throughput and latency of each benchmark and explain why.
    - Hint - Seek Time 









