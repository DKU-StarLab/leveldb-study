# Tune LevelDB Options for YCSB

## LevelDB options tuning contest for YCSB
1. Study the db options and their relationships.
2. Analyze workloads such as key/value size and key/operations distribution.
3. Hypothesize the best option set and verify it by experiment.
4. Submit your best option set to the assistant.
5. Write a document about your hypothesis, experiment, and final decision.
6. Prepare a 15-minute presentation and upload your PPT in pdf format.
* Please refer to LevelDB options.h and RocksDB tuning guide before you start!
  - [leveldb/include/leveldb/options.h](https://github.com/google/leveldb/blob/main/include/leveldb/options.h)
  - [leveldb/doc/index.md](https://github.com/google/leveldb/blob/main/doc/index.md)
  - [RocksDB Tuning Guide](https://github.com/facebook/rocksdb/wiki/RocksDB-Tuning-Guide)
  - [RocksDB Setup Options and Basice Tuning](https://github.com/facebook/rocksdb/wiki/Setup-Options-and-Basic-Tuning)

## Result
|   | Load (MB/s)  | Run A | Run B | Run D | Total | PPT  |
|---|--------------|-------|-------|-------|-----------|------|
| 1 | Team A (8.8) |       |       |       |           | File |
| 2 |              |       |       |       |           | File |
| 3 |              |       |       |       |           | File |
| 4 |              |       |       |       |           | File |
| 5 |              |       |       |       |           | File |
| 6 |              |       |       |       |           | File |

## Benchmark: YCSB-cpp
 The goal of the Yahoo Cloud Serving Benchmark (YCSB) project is to develop a framework and common set of workloads for evaluating the performance of different "key-value" and "cloud" serving stores. 
* [YCSB github](https://github.com/brianfrankcooper/YCSB)
* [YCSB-cpp github](https://github.com/ls4154/YCSB-cpp)
* [Cooper, Brian F., et al. "Benchmarking cloud serving systems with YCSB." Proceedings of the 1st ACM symposium on Cloud computing. 2010.](https://dl.acm.org/doi/abs/10.1145/1807128.1807152)

### Measurement For Evaluation
* Average of throughput ranks for each workload

### LevelDB options and restrictions
Modify _YCSB-cpp/leveldb/leveldb.cc:LeveldbDB::GetOptions_ like below.
``` c++
void LeveldbDB::GetOptions(const utils::Properties &props, leveldb::Options *opt) {
// ---------------------------Restriction----------------------------
  // max_memory size (= write_buffer_size + block_cache_size) <= 1024 * 1024
  // max_file_size <= 1024 * 1024
  // Do not change other options except the ones below
  opt->max_open_files = 1000;


// -------------LevelDB Default Options, Tune them!------------------
  // Memtable Size
  opt->write_buffer_size = 4 * 1024 * 1024;
  
  // SST
  opt->max_file_size = 2 * 1024 * 1024;
  opt->block_size = 4 * 1024 ;
  opt->block_restart_interval = 16;

  // Cache
  opt->block_cache = nullptr;

  // Compression
  opt->compression = leveldb::kSnappyCompression;

  // BloomFilter
  opt->filter_policy = nullptr;
}
```
- Example source code: [leveldb_db.cc](./leveldb_db.cc)

### Contest Workload
* Load A -> Run A -> Run B -> Run D
  ```
  # Command
  ./ycsb -load -db leveldb -P workloads/workloada -P leveldb/leveldb.properties -s
  ./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties -s
  ./ycsb -run -db leveldb -P workloads/workloadb -P leveldb/leveldb.properties -s
  ./ycsb -run -db leveldb -P workloads/workloadd -P leveldb/leveldb.properties -s
  ```
- Workload
  - Record Count = 2,000,000 
  - Operation Count = 2,000,000
  - Workload file 
    - [Workload A](./workloada)
    - [Workload B](./workloadb)
    - [Workload D](./workloadd)
  

### Install YCSB-cpp
  - Install and build leveldb in release mode
  - ```git clone https://github.com/ls4154/YCSB-cpp.git```
  - modify config section in Makefile
    ```
    #---------------------build config-------------------------
    DEBUG_BUILD ?= 0
    # put your leveldb directory
    EXTRA_CXXFLAGS ?= -I/example/leveldb/include
    EXTRA_LDFLAGS ?= -L/example/leveldb/build -lsnappy

    BIND_LEVELDB ?= 1
    BIND_ROCKSDB ?= 0 
    BIND_LMDB ?= 0
    ```
  - ```make```

