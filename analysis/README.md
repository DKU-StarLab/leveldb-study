# LevelDB analysis

## Topics
|              | User API         | Internal Operation    | Contents                                                | Source Code                                                    |
|--------------|------------------|-----------------------|---------------------------------------------------------|----------------------------------------------------------------|
| WAL/Manifest | Put              | Open Flush Compaction | Version Control  Log Format Manifest Format             | log_*.h version_*.h db_impl.h repair.cc                        |
| Memtable     | Put Get Iterator | Flush                 | Skiplist Arena Batch Write                              | wirte_batch_internal.h skiplist.h memtable.h db_impl.h arena.h |
| Compaction   | Put              | Compaction            | Compaction Policy Merge Iterator                        | db_impl.h merger.h version_set.h                               |
| SSTable      | Get Iterator     | Flush Compaction      | SST Format Block Format                                 | table/ builder.h                                               |
| Bloom filter | Put Get          | Flush Compaction      | Meta Index Block Filter Block Bloom Filter              | bloom.cc filter_block.cc filter_policy.h                       |
| Cache        | Get, Iterator    |                       | Replacement Policy Sharding, Lock Hash Index/Data Block | cache.h table.cc table_cache.h hash.h db_impl.h                |
