# LevelDB analysis
## Notice
* Upload your presentation file through pull reqeust.
    - Pull request until **every Tuesday, 11AM**.
    - Title: [analysis]topic_week0.pdf
    - [presentation.ppt](../file/%5Bformat%5Dleveldb_study_ppt.pptx)   
    
* Upload your analysis document at [DKU-StarLab/leveldb-wiki](https://github.com/DKU-StarLab/leveldb-wiki) repository through pull reqeust.
    - Pull request until **every Tuesday, 11AM**.
* Check previous study presentation files.
    - https://github.com/DKU-StarLab/RocksDB_Festival

## Topics
| Topic        | User API         | Internal Operation    | Contents                                                | Source Code                                                    |
|--------------|------------------|-----------------------|---------------------------------------------------------|----------------------------------------------------------------|
| WAL/Manifest | Put              | Open Flush Compaction | Version Control  Log Format Manifest Format             | log_*.h version_*.h db_impl.h repair.cc                        |
| Memtable     | Put Get Iterator | Flush                 | Skiplist Arena Batch Write                              | wirte_batch_internal.h skiplist.h memtable.h db_impl.h arena.h |
| Compaction   | Put              | Compaction            | Compaction Policy Merge Iterator                        | db_impl.h merger.h version_set.h                               |
| SSTable      | Get Iterator     | Flush Compaction      | SST Format Block Format                                 | table/ builder.h                                               |
| Bloom filter | Put Get          | Flush Compaction      | Meta Index Block Filter Block Bloom Filter              | bloom.cc filter_block.cc filter_policy.h                       |
| Cache        | Get, Iterator    |                       | Replacement Policy Sharding, Lock Hash Index/Data Block | cache.h table.cc table_cache.h hash.h db_impl.h                |
