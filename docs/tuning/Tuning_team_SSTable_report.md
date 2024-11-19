## [Team SSTable] Tuning Report

### write_buffer_size
Increasing this option improves write performance, thus speeding up bulk loads. However, this comes with a trade-off as the time to search for a desired key in the MemTable may increase. Nevertheless, since the search time in a Skiplist is O(log n), the time taken for searching is not significantly large compared to the increase in write_buffer size. Moreover, searching in memory is faster than searching on disk, so we decided to increase the `write_buffer_size`.

### max_file_size
This option concerns the size of the SSTable. If this is smaller than the write_buffer_size, more SSTables will be created through minor compaction, which is disadvantageous for write performance. Additionally, if `max_file_size` is less than a quarter of `write_buffer_size`, level 0 compaction may occur every time a minor compaction happens, leading to performance degradation. Therefore, we decided to set `max_file_size` to be larger than a quarter of `write_buffer_size`, and thought it appropriate to set it to about half of `write_buffer_size`.

### compression
According to the content in `options.h`, it is generally better to use snappy, so we left it as is.

### cache_size
A larger cache size results in more hits, improving read performance. Especially for workload D, which involves reading recent data frequently, increasing the cache size can lead to significant performance improvements. However, we cannot increase the cache size indefinitely, so we considered how large it should be. The cache size of the environment (school server) where the experiment is run is 14080KB, so we decided to set the cache size accordingly.

### filter_bits
- Whether to use a Bloom Filter  
  Not using a Bloom Filter improves write performance, while using it enhances read performance. However, based on our team's experimental results, the improvement in write performance without a Bloom Filter was negligible. Since LSM-Tree is inherently optimized for writing, we decided that enhancing read performance is more beneficial and chose to use a Bloom Filter.
- How many bits to use per key  
  Referring to the previous presentation by the Bloom Filter team, we found that using 10 bits yielded the most optimal speed. Therefore, we decided to keep it at 10 bits.

### block_size
According to our team's analysis, when creating an SSTable, Data Blocks are written directly to disk, while other blocks, including Filter Blocks, are gathered in a buffer and written at once. Thus, if the number of Data Blocks within an SSTable is small, the disk I/O required to create that SSTable can be reduced, potentially improving write performance. However, this comes with a trade-off of potentially degrading read performance. Since the process of finding a key within an SSTable uses binary search, and the time complexity of binary search is O(log n), we thought the increase in block size would not significantly increase search time. Therefore, we decided to increase the block_size.

### block_restart_interval
Through `block_restart_interval`, key-value pairs within a Data Block form a kind of section. Analyzing the code, we observed that the target key is found using binary search for the section, and linear search within the section. Therefore, we judged that setting this option smaller is advantageous for reading and decided to make it smaller. Although this may use more space, we decided not to consider this as long as runtime and throughput are the only concerns.

## Result
The average values obtained by entering each command three times are as follows.

### Default set
```
leveldb.write_buffer_size=2097152
leveldb.max_file_size=4194304
leveldb.compression=snappy 
leveldb.cache_size=4194304
leveldb.filter_bits=10
leveldb.block_size=4096
leveldb.block_restart_interval=16
```

- Load A
  - Average Load Runtime(sec): 4.4636
  - Average Load Throughput(ops/sec): 22598.2
- Run A
  - Average Run Runtime(sec): 1.98984
  - Average Run Throughput(ops/sec): 51221.6
- Run B
  - Average Run Runtime(sec): 0.60909
  - Average Run Throughput(ops/sec): 164452.7
- Run D
  - Average Run Runtime(sec): 0.43340
  - Average Run Throughput(ops/sec): 230799.3

### Our Best set
```
leveldb.write_buffer_size=67108864
leveldb.max_file_size=33554432
leveldb.compression=snappy 
leveldb.cache_size=14417920
leveldb.filter_bits=10
leveldb.block_size=2097152
leveldb.block_restart_interval=4
```

- Load A
  - Average Load Runtime(sec): 1.32495
  - Average Load Throughput(ops/sec): 77013.1
- Run A
  - Average Run Runtime(sec): 1.16803
  - Average Run Throughput(ops/sec): 85921.1
- Run B
  - Average Run Runtime(sec): 0.55706
  - Average Run Throughput(ops/sec): 184068
- Run D
  - Average Run Runtime(sec): 0.42554
  - Average Run Throughput(ops/sec): 240711.3