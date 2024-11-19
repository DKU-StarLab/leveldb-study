# Write-Ahead Logging (WAL) Analysis

## Overview of `max_total_wal_size` Option

### Hypothesis

- Each column family has its own ssTable, but they share a single WAL.
- A new WAL is created whenever a column family is flushed, redirecting all writes to the new WAL.
- WALs can only be deleted once all their data is moved to ssTables, necessitating regular flushes.
- Without constraints on WAL size, deletion slows, and flushes become infrequent.
- The `max_total_wal_size` option triggers the deletion of the oldest live WAL file when the size exceeds a specified value, forcing a flush if live data exists.
- A smaller WAL size might lead to frequent flushes, potentially degrading performance.

### Experimental Design

- **Independent Variable**: `--max_total_wal_size=[int value]`
- **Dependent Variables**: SAF, WAF, Latency, Throughput

#### Command
```bash
./db_bench --benchmarks="fillseq" --max_total_wal_size=[0,1,10,100,1000,10000,100000,1000000,10000000,100000000] --num=10000000
```

### Experiment Environment

- **Operating System**: macOS Monterey
- **Processor**: 2.3GHz 8-Core Intel Core i9
- **SSD**: APPLE SSD AP1024N 1TB

### Results

- Initial experiments showed no significant results in the given environment.
- The default value of `max_total_wal_size` is not zero but calculated as:
  ```plaintext
  [sum of all write_buffer_size * max_write_buffer_number] * 4
  ```
- This option is effective only with two or more column families.

#### Calculations for Column Families

- **10 Column Families**:
  - `write_buffer_size = 64 MB (Default)`
  - `max_write_buffer_number = 2 (Default)`
  - `max_total_wal_size = [10*64MB*2]*4 = 5.12GB`

- **15 Column Families**:
  - `write_buffer_size = 64 MB (Default)`
  - `max_write_buffer_number = 2 (Default)`
  - `max_total_wal_size = [15*64MB*2]*4 = 7.68GB`

#### Experiment Results

- The results seem to reflect only the default column family analysis.
- Different results were observed when the `--num_column_families=` option was not specified, indicating usage of all 10 and 15 families.

### Discussion

- Performance appears to degrade as `max_total_wal_size` decreases from its default value.
- Testing with a fixed `max_total_wal_size` of 500MB and varying column family counts (10, 15, 20, 25, 30) suggests performance degradation with more column families sharing the WAL.
- The threshold for performance degradation in `max_total_wal_size` increases with more column families.

### Future Work

- Further benchmarking with multiple column families, altering their characteristics, and monitoring flush counts could provide deeper insights.



