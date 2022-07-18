# Answers submitted by students
#####[homework_answered_by_students(kor).xlsx](./homework_answered_by_students(kor).xlsx)

# Homework Solutions

#### Question 1. (PPT - Jongki Park)
##### Why do LSM-tree and LevelDB use leveled structure? 
|# of Level|Write performance|Read Performance|WAF|RAF|
|--|--|--|--|--|
|Single|Bad|Good|High|Low|
|Multi|Good|Bad|Low|High|


#### Question 2. (PPT - Jongki Park) 
##### In leveldb, max size of level i is 10^iMB. But max size of level 0 is 8MB. Why? 
* We treat level-0 specially by bounding the number of files instead of number of bytes for two reasons:
    - (1) With larger write-buffer sizes, it is nice not to do too many level-0 compactions.
    - (2) The files in level-0 are merged on every read and therefore we wish to avoid too many files when the individual file size is small

#### Practice 1. (PPT - Suhwan Shin)
```
[A] $ ./db_bench --benchmarks="fillseq" 
[B] $ ./db_bench --benchmarks="fillrandom"
```

* Q1. Compare throughput, latency, and stats of two benchmarks and explain why.
* Q2. Calculate SAF (Space Amplification Factor) for each benchmark.

| Benchmark | duplicate key range  | Major Compaction | Throughput | Latency | SAF      |
|-----------|----------------------|------------------|------------|---------|----------|
| Fillseq   | No                   | No               | High       | High    | 1 (0.98) |
| Fillrandom| Yes                  | Yes              | Low        | Low     | 1.275    |
* Q3. In benchmark A, SSTs are not written in L0. Why?
    - Trivial Move


#### Practice 2. (PPT - Suhwan Shin)
```
[A] $ ./db_bench --benchmarks="fillrandom" --value_size=100 --num=1000000 --compression_ratio=1
[B] $ ./db_bench --benchmarks="fillrandom" --value_size=1000 --num=114173 --compression_ratio=1
```
> Note 1. key_size = 16B  
> Note 2. same total kv pairs size.  
> Note 3. # of B's entries = 114173 = (16+100)/(16+1000) * 1000000 

* Q. The size of input kv pairs is the same. But One is better in throughput, the other is better in latency. Explain why.

| Benchmark | DB size | # of entries     | Size of entry | Throughput | Latency |
|-----------|---------|------------------|---------------|------------|---------|
| A         | same    | 1,000,000 (many) | 116B (small)  | low        | high    |
| B         | same    | 114,173 (few)    | 1016B (big)   | high       | low     |

#### Practice 3. (PPT - Zhu Yongjie)
```
[Load] $ ./db_bench --benchmarks="fillrandom" --use_existing_db=0

[A] $ ./db_bench --benchmarks="readseq" --use_existing_db=1
[B] $ ./db_bench --benchmarks="readrandom" --use_existing_db=1
[C] $ ./db_bench --benchmarks="seekrandom" --use_existing_db=1
````
* Q1. Which user key-value interface does each benchmark use? (Put, Get, Iterator, ...)
* Q2. Compare throughput and latency of each benchmark and explain why.

| Benchmark  | Interface        | throughput | latency | I/O        | Access Level |
|------------|------------------|------------|---------|------------|--------------|
| readseq    | Get()            | high    | low  | sequential | all          |
| readrandom | Iterator->Next() |     low       |     high    | random     | access one by one </br> until find the key  |
| seekrandom | Iterator->Seek() | lowest     | highest  | random     | all          |








