## [Team WAL/Manifest] Tuning Report

### Hypothesis
----------------

#### write_buffer_size
    Increasing the write_buffer_size improves performance during bulk loads.
    Since max_memory_size (= write_buffer_size + block_cache_size) <= 1GB,
    the performance of Load is expected to be maximized at 1GB.
    WorkloadA: Read(50) + Modify(50)
    WorkloadB: Read(95) + Modify(5)
    WorkloadD: Read(95) + Modify(5)
    Therefore, as all workloads involve modifications, increasing the write_buffer_size
    is expected to improve performance in LoadA, RunA, RunB, and RunD.

#### max_file_size
    Increasing the maximum file size may lengthen compaction time, potentially slowing latency.
    It is important to find a suitable value for the file system.
    If the file system is efficient with relatively large files, the file size can be increased.

#### block_size
    This option sets the approximate size of packed data per block.
    Since the block size here refers to uncompressed data, it was anticipated that smaller sizes
    would be advantageous for performance due to faster compression.

#### block_restart_interval
    The exact function of this option is not well understood, but
    // Most clients should leave this parameter alone.
    As recommended by leveldb, most clients do not change this parameter, so experiments were conducted accordingly.

#### block_cache_size
    Generally, a larger cache size is thought to increase the hit rate.
    However, due to the cost of cache and other factors, the performance may not scale linearly with size.

#### compression
    The compression options are kNoCompression and kSnappyCompression.
    // Note that these speeds are significantly faster than most
    // persistent storage speeds, and therefore it is typically never
    // worth switching to kNoCompression. Even if the input data is
    // incompressible, the kSnappyCompression implementation will
    // efficiently detect that and will switch to uncompressed mode.
    According to the description of leveldb's compression options, there is no need to switch to kNoCompression,
    and performance is expected to be better with kSnappyCompression.

#### filter_policy
    The default is set to NewBloomFilterPolicy, and based on the bloomfilter team's benchmark presentation,
    it was reported to be most efficient at 10 bits, so experiments were conducted without changing this setting.

### Experiments
----------------

#### write_buffer_size
    Experiments were conducted on three different servers with 64, 128, 256, and 512MB.
    It was found that there was no significant change beyond 64MB.

#### max_file_size
    Experiments were conducted by doubling the default max_file_size value of 2MB on three different server environments,
    testing from 64MB to 1GB.

#### block_size
    Experiments were conducted by setting multiple values, doubling or halving from the default value of 4kB.

#### block_restart_interval
    Experiments were conducted with the default value of 16.

#### block_cache_size
    The goal was to find the value at which performance no longer improved by increasing the size as much as possible.

#### compression
    Experiments were conducted with both kNoCompression and kSnappyCompression, but there was no significant difference,
    and performance did not improve with kNoCompression.

#### filter_policy
    Experiments were conducted with 10 bits while changing other options.

### Results
----------------

#### write_buffer_size
    It seems that beyond a certain value, it is fixed to a predetermined value.
    Although it needs to be confirmed whether different servers affect the results, the average value was taken as the result
    since the same results were not obtained on all three servers.

#### max_file_size
    There was no significant difference beyond 64MB, and since larger file sizes can generally be detrimental to performance,
    64MB was chosen as the result among similar values.

#### block_size
    In our experiments, consistent and good results were observed at 8kB, so 8kB was chosen as the result.

#### block_restart_interval
    16

#### block_cache_size
    Performance did not improve beyond 128MB, and repeated experiments confirmed high performance, so 128MB was chosen as the result.

#### compression
    kSnappyCompression

#### filter_policy
    10 bits
