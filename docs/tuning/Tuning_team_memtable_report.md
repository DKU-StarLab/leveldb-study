## [Team Memtable] YCSB Tuning Report

### Configuration Options Overview

#### leveldb.write_buffer_size
- Controls the size of memtable & immutable memtable
- Default: 33554432 (32MB)
- Impact:
  - Larger size improves write performance
  - However, increases recovery time during DB restart due to WAL replay
  - Recommended to adjust based on your write patterns

#### leveldb.max_file_size
- Determines maximum size of a single SSTable file
- Default: 16777216 (16MB)
- Considerations:
  - Should be proportional to key/value sizes
  - Larger values may increase read/write amplification
  - Need to balance between performance and resource usage

#### leveldb.compression
- Uses Snappy compression algorithm
- Characteristics:
  - Good performance-to-compression ratio
  - Popular choice for databases
  - Trade-off between CPU usage and storage space
- Recommendations:
  - Enable for large datasets
  - Disable for small datasets where CPU is more critical

#### leveldb.cache_size
- Controls block cache size
- Default: 33554432 (32MB)
- Effects:
  - Larger cache improves read performance
  - Increases memory usage
  - Caches blocks to reduce disk I/O

#### leveldb.block_size
- Basic unit for read/write operations
- Default: 8192 (8KB)
- Should be configured according to key/value sizes

#### leveldb.block_restart_interval
- Default: 16
- Controls prefix compression interval for keys
- Determines how many keys share prefix compression

### Performance Test Results

#### Test Timeline
- Start: 2022-08-15 20:13:09 (0 operations)
- End: 2022-08-15 20:13:10 (100,000 operations)

#### Performance Metrics
- Total Runtime: 0.831485 seconds
- Total Operations: 100,000
- Throughput: 120,267 ops/sec

### Operation Breakdown
#### READ Operations
- Count: 49,912
- Maximum Latency: 4,231.61ms
- Minimum Latency: 1.14ms  
- Average Latency: 4.24ms

#### UPDATE Operations
- Count: 50,088
- Maximum Latency: 3,125.45ms
- Minimum Latency: 3.94ms
- Average Latency: 8.25ms

### Configuration Settings
Note: Options are configured for a small database due to the limited number of operations.
  
### Database Parameters
```
leveldb.write_buffer_size=33554432
leveldb.max_file_size=16777216
leveldb.compression=snappy
leveldb.cache_size=33554432
leveldb.filter_bits=10
leveldb.block_size=8192
leveldb.block_restart_interval=16
```