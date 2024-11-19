# SSTable

An SSTable consists of Data Blocks containing key-value pairs and a Filter Block that holds bloom filters for each Data Block. According to the [LevelDB Handbook](https://leveldb-handbook.readthedocs.io/zh/latest/sstable.html), it states the following regarding the Filter Block:

> *If the user does not specify LevelDB to use filters, LevelDB does not store content in this block.*


This means that if you do not specify to use bloom filters, data is not stored in the Filter Block. This led to the thought, *"If we don't use bloom filters, wouldn't the performance improve during writes since we don't write to the Filter Block?"* Thus, I decided to conduct an experiment on this.  

Before conducting the experiment, I used `uftrace` to confirm that the `leveldb::FilterBlockBuilder::Addkey` function is only called when bloom filters are applied, verifying that data is not written to the Filter Block if bloom filters are not used.

## Hypothesis
If bloom filters are not applied, data is not stored in the Filter Block, which will improve performance during write operations.  
`Latency` will decrease, and `Throughput` will increase.

## Design  
- Controlled Variables
  - `--value_size`: 2,000
  - `--use_existing_db`: 0
  - `--compression_ratio`: 1
  - `--benchmarks`: "fillseq"
- Independent Variables
  - `--bloom_bits`: Not specified when bloom filters are not applied, specified as 64 when applied
- Dependent Variables
  - `Throughput`
  - `Latency` 
  
## Experiment Environment
- CPU: 40*Intel® Xeon® Silver 4210R CPU @2.40GHz
- CPUCache: 14080KB

## Result
Measured 10 times each with and without applying bloom filters    
`Latency`: micros/op  
`Throughput`: MB/s

- When bloom filters are applied  

||1|2|3|4|5|6|7|8|9|10|
|-------|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|Latency|11.194|11.314|11.178|11.176|11.023|11.374|11.204|11.047|11.117|11.206|
|Throughput|171.8|169.9|172.0|172.0|174.4|169.0|171.6|174.0|172.9|171.6|  
> *Average Latency = 11.183 micros/op*  
> *Average Throughput = 172.92 MB/s*

- When bloom filters are not applied  

||1|2|3|4|5|6|7|8|9|10|
|-------|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|Latency|10.543|11.258|10.280|10.674|10.976|10.537|10.724|10.353|10.619|10.785|
|Throughput|182.4|170.8|187.0|180.1|175.2|182.5|179.3|185.7|181.1|178.3|  
> *Average Latency = 10.674 micros/op*  
> *Average Throughput = 180.24 MB/s* 


## Discussion  
Based on the results above, comparing the average `Latency` and `Throughput` when bloom filters are applied versus when they are not, we find the following:  

- Latency
<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187726811-56a5f707-7734-45b7-b638-e2645bc55f14.png"></p><br/>  

- Throughput  
<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187726961-c13fc1dc-8c00-4f1e-9644-6cec629107a6.png"></p><br/>

Before the experiment, I hypothesized that not using bloom filters would result in lower `Latency` and higher `Throughput` during writes. Indeed, the results show that `Latency` is lower and `Throughput` is higher when bloom filters are not applied compared to when they are.  
However, I expected a more significant difference between applying and not applying bloom filters during write operations, but the actual difference in `Latency` was only about 0.5 micros per key-value pair, which did not seem substantial. I pondered why the difference was not more pronounced.

1. db_bench Output  
The output from running db_bench does not strictly represent the time taken to create a single SSTable but rather the time taken to process a single key-value pair. Therefore, the output of db_bench should be viewed as an indicator of the overall write process rather than the time taken to create an SSTable. Since an SSTable is not created for every key-value pair, the time difference in writing an SSTable may not significantly impact the overall write process. Thus, while there may have been a noticeable time difference in processing a single SSTable, it might not have been significant in the overall write process.

2. fillseq  
The reason for using `fillseq` instead of `fillrandom` in this experiment was to ensure the same order of key insertion when applying and not applying bloom filters. `fillseq` has the characteristic of not triggering `compaction`, meaning that performance differences only appear for SSTables created by `flush`. In an environment where both `flush` and `compaction` occur, more SSTables are created, potentially leading to more significant performance differences. However, since this experiment was conducted in a `flush`-only scenario, the number of SSTables created was limited, resulting in smaller performance differences.

