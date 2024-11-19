# WAL

## Option - Manual_wal_flush

When `DB::put` is called, data is written to the memtable and, if WAL is enabled, also to the WAL. Initially, it is recorded in the application memory buffer, which then calls the `fwrite` syscall to flush it to the OS buffer. (The OS buffer is later synchronized to permanent storage.) In the event of a crash, RocksDB can only recover data from the memtable. By default, RocksDB automatically flushes the WAL from memory to the OS buffer every time a put is called. However, by disabling the `manual_wal_flush` option, you can set it to flush only when `DB::FlushWAL` is called, or when the WAL buffer is full or the FlushWAL API is invoked. Not calling `fwrite` syscall every time a put is called generally involves a tradeoff between reliability and latency. If data preservation is crucial, set the `manual_wal_flush` option to True; if performance is prioritized over potential data loss, set it to False.

### Hypothesis

The fewer the flushes, the better the performance (latency). To determine the extent of this difference and consider the tradeoff, we conducted experiments. We measured throughput and latency by setting the `manual_wal_flush` option to true and false, respectively. Benchmarks were conducted with both fillseq and fillrandom, which are unrelated to WAL, so the results should be consistent with existing fillseq and fillrandom experiments. Additionally, comparisons were made in both sync/async modes.

### Design
- **Independent Variable**: `manual_wal_flush` (true / false)  
- **Dependent Variable**: Latency, Throughput  
- **Controlled Variable**: Benchmark (fillseq, fillrandom), Sync mode (Sync / Async)  

### Experiment Environment
<p align="center"> <img src = https://github.com/user-attachments/assets/c002ddb4-5c71-4306-a22d-23c8c5163ad4></p>

### Result
The results below are the average values from conducting each experiment five times.

<p align="center"> <img src = https://github.com/user-attachments/assets/383addbd-b332-49de-ae82-3775c4561d6a></p> 

- **Async**  
<p align="center"> <img src = https://github.com/user-attachments/assets/4295b9af-6edd-4adb-bc11-c01e3d822aad></p>  
Latency and Throughput in Asynchronous Mode  

- **Latency**  
<p align="center"> <img src = https://github.com/user-attachments/assets/05d84f46-ee69-47bf-80a3-d5229b5a855f></p>  
Latency in Synchronous and Asynchronous Modes  

### Discussion

- **Latency and Throughput with manual_wal_flush Option**  
  Performance is worse when true compared to false.

- **Benchmark (fillseq, fillrandom)**  
  As expected, fillseq performs better than fillrandom, and the difference in manual_wal_flush is around 1000, showing no impact on the benchmark.

- **Performance in Sync and Async**  
  Generally, performance should be lower when manual_wal_flush is true compared to false. However, in synchronous mode, latency is observed to be an overwhelmingly high 3000 micros/op, and performance can be better when true than false. This indicates that the manual_wal_flush option does not affect sync mode.
