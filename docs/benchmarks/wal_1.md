# WAL

## Option - Disable_WAL
In the case of LevelDB, there is no option to decide whether to use WAL when running `db_bench`. On the other hand, RocksDB, which is based on LevelDB, provides a `disable-wal` option that allows you to choose whether to use WAL.

Please note that the performance (Throughput, Latency) comparisons used in this post are measured using RocksDB, not LevelDB.

### Hypothesis
- Enabling WAL will negatively impact latency and throughput.

### Design
- Execute the following benchmarks using RocksDB's `db_bench`:
1. `fillseq`
2. `fillrandom`
3. `readrandom`

### Experiment Environment
#### CPU
Model: Intel(R) Core(TM) i9-7940X CPU @ 3.10GHz
Spec:
```
Caches (sum of all):
  L1d:                   448 KiB (14 instances)
  L1i:                   448 KiB (14 instances)
  L2:                    14 MiB (14 instances)
  L3:                    19.3 MiB (1 instance)
```
#### OS & HW
- OS: Ubuntu 22.04 LTS (Not VM)
- Storage: Samsung SSD 860 2TB

### Result
The `disable-wal` option used in RocksDB determines whether WAL is enabled. Through this, the performance of Throughput, SAF, WAF, and Latency (Average) was measured. The following data is the average of all results after running RocksDB's `db_bench` 10 times.

![wal_performance](https://user-images.githubusercontent.com/49092508/184468454-28357711-46af-400d-bb15-c9ad97bf9fd8.png)

The above graph is represented in the table below.

|WAL|Throughput (MB/s)|SAF|WAF|Latency (Average)|Benchmark Type|
|--|--|--|--|--|--|
|Disabled|180.22|2.667|2|0.61416|`fillseq`|
|Disabled|77.33|1.625|1.7|1.43117|`fillrandom`|
|Enabled|51.73|2.06667|2|2.13972|`fillseq`|
|Enabled|36.17|1.625|1.7|3.06011|`fillrandom`|

### Discussion
In the case of RocksDB, when writing WAL, it calls `rocksdb::DBImpl::WriteToWAL`. When this member function is called, the following procedure occurs.
![writetowal](https://user-images.githubusercontent.com/49092508/184468676-8c0ebc8f-2ab5-4350-87dc-94808d4d3d71.png)
> The above diagram is not a complete UML class diagram but a diagram to show the overall flow.

Through this diagram, we can see that when `rocksdb::DBImpl::WriteToWAL` is called, it uses `std::write` or `pwrite`. Therefore, allowing WAL requires more IO operations, and since these IO operations are heavily used, it significantly impacts the performance of Latency and Throughput.

The following graph measures the time taken to write WAL.

![wal3](https://user-images.githubusercontent.com/49092508/184468818-e39c1f08-ad7c-4239-8fdb-7df621b19744.png)

As shown in the graph, WAL is a task with considerable overhead due to the use of IO.

#### Summary
1. Advantages of WAL
- Increases the likelihood of not losing data in case of abnormal termination.
2. Disadvantages of WAL
- It has significant overhead due to the use of IO, negatively affecting performance in terms of Latency and Throughput.
