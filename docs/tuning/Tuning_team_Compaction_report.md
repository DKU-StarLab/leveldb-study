## [Team Compaction] YCSB Tuning Report 

### DB options for tunning
-------
|options|default|Explanation|
|---|---|---|
|leveldb.write_buffer_size|2MB|single memtable size|
|leveldb.max_file_size|4MB|sstable size|
|leveldb.compression|snappy|compression method|
|leveldb.cache_size|4M|cache size|
|leveldb.filter_bits|10|number of filter block bits|
|leveldb.block_size|4KB|size of data block in one file|
|leveldb.block_restart_interval|16|number of keys between restart points(delta encoding)|

### Analyze workloads
----
![img](https://user-images.githubusercontent.com/87025898/183247993-0133d8c1-3b40-455e-987d-f54892488e84.png)  
A: Read/update ratio: 50/50  
B: Read/update ratio: 95/5  
D: Read/update/insert ratio: 95/0/5    
Because of the high read proportion, consideration is given to ways to maximize read performance.  
Of course, consider write performance and choose the best option.  
  
### Hypothesis and experiment
------
Considering that it is run at random, it is measured with an average of 3 times.  
#### Hypothesis  
Based on what was studied in the study, it is expected that writing performance will increase as the size of the buffer increases the amount of writing at once.  
In addition, it is expected that read performance will improve if the size of the file is 1/4 of the size of the buffer, allowing four files, which are the thresholds of level0, to be read at once, and increasing the cache size.  
Finally, by reducing the size of the block, increasing the number of bits in the index of the file, and increasing the number of bits in the filter block, the read performance is expected to be improved  

#### Default
|workload|runtime(sec)|throughput(ops/sec)|
|---|---|---|
|load|6.22135|16073.7|
|A|2.88199|34698.2|
|B|0.753103|132784|
|D|0.545697|183252|

#### write_buffer_size 8MB
|workload|runtime(sec)|throughput(ops/sec)| -> |runtime(sec)|throughput(ops/sec)|
|---|---|---|---|---|---|
|load|6.22135|16073.7| -> |4.58351|21817.4|
|A|2.88199|34698.2| -> |2.30625|43360.4|
|B|0.753103|132784| -> |0.738974|135323|
|D|0.545697|183252| -> |0.50175|199302|  

As the write performance improved, the performance of load and A improved.  

#### write_buffer_size 32MB, max_file_size 8MB
|workload|runtime(sec)|throughput(ops/sec)| -> |runtime(sec)|throughput(ops/sec)|
|---|---|---|---|---|---|
|load|6.22135|16073.7| -> |1.33948|74655.9|
|A|2.88199|34698.2| -> |1.44349|69276.5|
|B|0.753103|132784| -> |0.708532|141137|
|D|0.545697|183252| -> |0.502773|198897|  

The buffer size was further increased to 32MB(no performance changes after increasing more than 32MB), and the file size was 8MB, so that only Level 0 could be filled first, and it could be seen that the write performance was improved.    

#### cacahe_size 8MB, block_size 2KB
|workload|runtime(sec)|throughput(ops/sec)| -> |runtime(sec)|throughput(ops/sec)|
|---|---|---|---|---|---|
|load|6.22135|16073.7| -> |1.33054|75157.5|
|A|2.88199|34698.2| -> |1.38317|72297.5|
|B|0.753103|132784| -> |0.690946|144729|
|D|0.545697|183252| -> |0.484127|206557|  

For read performance, the cache size was increased and the block size was reduced. (More cache than 8MB or less block size makes little difference in performance)  
It was found that the performance of workload B and C, which had a high reading proportion, improved slightly.    
Here, increasing the filter block and changing block_restart_interval does not cause any worse performance or make any difference.  

### Therefore, the best options
|the best options||
|---|---|
|leveldb.write_buffer_size|32MB|
|leveldb.max_file_size|8MB|
|leveldb.compression|snappy|
|leveldb.cache_size|8MB|
|leveldb.filter_bits|10|
|leveldb.block_size|2KB|
|leveldb.block_restart_interval|16|  

### Conclusion and discussion
------
We selected the best option by properly increasing the buffer size, file size, and cache size to 32MB, 8MB, and 8MB, respectively, and the block size to half 2KB.  
It was clear that writing performance improved. However, it was predicted that read performance would improve if the cache size was increased to increase the hit rate and the block size was reduced to increase the items included in the index, but read performance did not improve significantly. There may be several factors for this reason, but the unpredictable factor is believed to be the main cause because data is accessed randomly.  

Using one-third of the memory as a cache is good in terms of tradeoff, which can leave a large amount of OS page cache, so it is expensive to avoid memory budgeting, but in terms of performance, it is expected that the performance will be better if the size is increased by utilizing the remaining cache well.
