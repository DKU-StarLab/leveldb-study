## [Team BloomFilter] YCSB Tuning Report 

### 1) Write Buffer Size
**Hypothesis:** Increasing the write buffer size is expected to improve write performance. However, if increased excessively, it may lead to significant overhead, resulting in performance degradation. The goal is to maximize the size while minimizing performance loss to find the optimal value.

**Measurement:** Using the original value of 64MB, the time taken for LOAD was mostly similar, and the LOAD and RUN times were proportional. Increasing it to 128MB significantly reduced the LOAD time, and the LOAD and RUN times were no longer proportional. Runtime either increased or decreased compared to the original, with decreases being more significant. This option had the most impact on performance changes, and efforts were made to minimize cases where time increased using other options. Increasing beyond 128MB showed no significant difference or even reduced performance.

### 2) Max File Size
**Hypothesis:** Limiting the maximum file size is expected to improve performance, but it may impose restrictions on database usage.

**Measurement:** Changing the value multiple times did not yield significant differences in measurements.

### 3) Cache Size
**Hypothesis:** Since cache memory is high-speed, increasing the cache size is expected to enhance performance.

**Measurement:** Contrary to expectations, doubling the original value of 128MB decreased performance, while reducing it to 64MB increased performance. A cache size of 64MB is sufficient, and increasing beyond this seems to increase overhead.

### 4) Filter Bits
**Hypothesis:** The default Bloom filter bit value is 10 bits, with the optimal number of hashes being 10 * 0.69 = 6.9. However, since the actual value used is 6, using 9 filter bits with 6 hashes is hypothesized to reduce false positives and improve performance.

**Measurement:** Reducing the bits from 10 to 9 resulted in slightly more consistent values, though not significantly different. Increasing the max file size made the results irregular, and significantly increasing filter bits did not have a major effect.

### 5) Block Size
**Hypothesis:** The block size is considered to have a clear tradeoff, and the default value is assumed to be the most appropriate.

**Measurement:** No significant differences were observed, but the default value generally showed the best performance.

### 6) Block Restart Interval
**Hypothesis:** Reducing the interval between blocks is expected to improve performance.

**Measurement:** Reducing the value showed a slight tendency to improve performance.

### Final Results
| Options               | Result |
|-----------------------|--------|
| Write Buffer Size     | 128MB  |
| Max File Size         | 64MB   |
| Cache Size            | 64MB   |
| Filter Bits           | 9      |
| Block Size            | 8KB    |
| Block Restart Interval| 4      |
