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
| WAL/Manifest | Put              | Open </br>Flush </br>Compaction | Version Control </br>Log Format </br>Manifest Format             | log_*.h </br>version_*.h </br>db_impl.h </br>repair.cc                        |
| Memtable     | Put </br>Get </br>Iterator | Flush                 | Skiplist </br>Arena </br>Batch Write                              | wirte_batch_internal.h </br>skiplist.h </br>memtable.h </br>db_impl.h </br>arena.h |
| Compaction   | Put              | Compaction            | Compaction Policy </br>Merge Iterator                        | db_impl.h </br>merger.h </br>version_set.h                               |
| SSTable      | Get </br>Iterator     | Flush </br>Compaction      | SST Format </br>Block Format                                 | table/ </br>builder.h                                               |
| Bloom filter | Put </br>Get          | Flush </br>Compaction      | Meta Index Block </br>Filter Block </br>Bloom Filter              | bloom.cc </br>filter_block.cc </br>filter_policy.h                       |
| Cache        | Get </br>Iterator    |                       | Replacement Policy </br>Sharding, Lock </br>Hash </br>Index/Data Block | cache.h </br>table.cc </br>table_cache.h </br>hash.h </br>db_impl.h                |
