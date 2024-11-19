## Bloom Filter

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183424363-05494e10-e230-45b1-9a2a-18f413748970.png)
(Source: https://en.wikipedia.org/wiki/Bloom_filter)

A Bloom filter is a probabilistic data structure that quickly checks for the presence of a specific key in a data block.

In `db_bench`, you can adjust the value of `bloom_bits` to create a Bloom filter of your desired size. This experiment aims to explore the performance differences based on the value of `bloom_bits` and the reasons behind them.

### Hypothesis 1

As the size of the Bloom filter increases, false positives decrease, improving performance. However, the overhead required to read and write the Bloom filter also increases, creating a trade-off. Considering this trade-off, the optimal `bloom_bits` value would be the default value used by LevelDB, which is 10 bits.

#### Fillrandom Performance Measurement

| Bits per key | Throughput | Latency |
|--------------|------------|---------|
| -1           | 28.21      | 4.327   |
| 0            | 28.13      | 4.389   |
| 1            | 28.01      | 4.472   |
| 5            | 27.92      | 4.475   |
| 10           | 27.56      | 4.486   |
| 30           | 26.72      | 4.729   |
| 50           | 25.49      | 5.292   |
| 100          | 25.46      | 5.382   |
| 1000         | 19.11      | 7.781   |

![image](https://user-images.githubusercontent.com/101636590/188536205-ebae47e8-9f0e-46be-8c13-d98c026a67e2.png)

![image](https://user-images.githubusercontent.com/101636590/188535916-10cb4bd4-d76c-42d5-90bf-62369d71cbb3.png)

As the number of bits per key increases, latency increases and throughput decreases.

#### Readrandom Performance Measurement

| Bits per key | Latency |
|--------------|---------|
| -1           | 3.20    |
| 0            | 2.84    |
| 1            | 2.81    |
| 5            | 2.78    |
| 10           | 2.41    |
| 30           | 2.97    |
| 50           | 3.40    |
| 100          | 3.56    |
| 1000         | 5.69    |

![image](https://user-images.githubusercontent.com/101636590/188536768-d836e937-2788-44c4-b292-e89d8c09f535.png)

As the number of bits per key increases, latency initially decreases but then increases again. This suggests that initially, the performance improvement from the Bloom filter outweighs the overhead, but eventually, the overhead becomes too large, reducing throughput.

![image](https://user-images.githubusercontent.com/101636590/183422850-3879d47a-209e-4c00-9462-96f1cd8cd5b1.png)

Additionally, the number 10 is identified as the threshold that enhances read performance without significantly degrading write performance, which is why LevelDB uses 10 bits per key as the default value.

### Hypothesis 2

The size of the Bloom filter is determined by the number of bits per key and the number of data items. If these values are fixed and only the data size is changed, the overhead from the Bloom filter should remain unchanged.

#### Result

![image](https://user-images.githubusercontent.com/101636590/188540907-795ac9bf-348f-463a-a79d-c82a4fcb68dd.png)

![image](https://user-images.githubusercontent.com/101636590/188540987-7aa69da2-f7ec-4e7e-81cb-93f7f23eeda3.png)

When the `value_size` is 128 Bytes, using a Bloom filter results in a 7% decrease in write performance and a 7% increase in read performance. When the `value_size` is increased tenfold to 1280 Bytes, the write performance decreases by 8% and the read performance increases by 9.5%.

Contrary to the hypothesis, it appears that `value_size` also affects the performance difference caused by the Bloom filter. This is likely because, although the overall size of the Bloom filter remains the same, each Bloom filter is divided into smaller parts, requiring additional overhead for reading and writing.

### Hypothesis 3

When the number of bits per key in a Bloom filter is fixed, the mathematically proven optimal number of hashes is ln2 * bloom_bits ≈ 0.69 * bloom_bits. However, since the number of hashes cannot be a fraction, if we use the default value of 10 bits in LevelDB, the number of hashes becomes 6 instead of 6.9. Therefore, using 7 hash functions, which is closer to the theoretically optimal value, should improve performance.

#### Result

![image](https://user-images.githubusercontent.com/101636590/188542665-f40355bf-2e3e-4926-913f-8deaabadcf42.png)

The results were almost identical, but using 7 hash functions slightly decreased write performance and slightly improved read performance, though the difference was minimal.

![image](https://user-images.githubusercontent.com/101636590/188542986-bc017ba8-4e05-4f2e-8e06-7f5757fe77f1.png)

Mathematically, the difference in the probability of false positives between using 6 and 7 hash functions is 0.00024, which is negligible and likely equivalent to the additional overhead from processing one more hash during reading.

### Hypothesis 4

If we use 9 bits (6.21 <-> 6) or 12 bits (8.28 <-> 8), which are closer to the theoretically optimal number of hash functions, performance should improve.

#### Result

![image](https://user-images.githubusercontent.com/101636590/188543384-32643815-612a-4f40-b5b1-4bd67103aacc.png)

Contrary to expectations, the best results were obtained when using 10 bits.

![image](https://user-images.githubusercontent.com/101636590/188543466-a3e12c1c-77f9-42ce-a674-dc3214db5c11.png)

Using 12 bits and 8 hashes significantly reduced the probability of false positives compared to the default 10 bits and 6 hashes, but considering the overhead required to process 2 additional bits and 2 hashes, the difference in read performance was not significant, and write performance decreased.

![image](https://user-images.githubusercontent.com/101636590/188544697-3e50231b-4709-41c5-a111-2c119a036bdf.png)

When using 6 hashes and 9 bits, the write performance was similar to the default case, but read performance decreased.

![image](https://user-images.githubusercontent.com/101636590/188544749-24cfabb8-f4ee-48ae-a9aa-379ee1b963d3.png)

This is because, contrary to my expectations, the optimal number of hashes is the value that minimizes false positives when the bloom_bits value is fixed. Conversely, if the number of hashes is fixed, false positives decrease as the bloom_bits value increases.

### Hypothesis 5

![image](https://user-images.githubusercontent.com/101636590/188545415-3b94a1a0-2577-4a61-83a1-66e939c6d8de.png)

From the experimental results above, it was found that with the same number of hashes, a larger bloom_bits value results in better read performance. Considering that the bloom_bits value has a greater impact on false positives than the number of hashes, and that the overhead of the Bloom filter is largely due to the number of hashes, it is hypothesized that fixing the number of hashes and increasing the bloom_bits value will yield better performance results.

#### Result

![image](https://user-images.githubusercontent.com/101636590/188545779-24ac7ed8-dba5-41b7-b17a-33799ad49b42.png)

Using 6 hash functions with 10 bits and 30 bits each resulted in a slight increase in read performance but a decrease in write performance. Despite adjusting various variables and conducting numerous measurements, it seems difficult to achieve better results than using the default 10 bits with 6 hash functions through simple numerical adjustments.

### Hypothesis 6

False positives can only occur if the data to be read does not exist. Therefore, in the ReadMissing benchmark, where only non-existent keys are searched, the impact of false positives will be greater than in ReadRandom.

#### Result

![image](https://user-images.githubusercontent.com/101636590/188546151-a06edf9a-93a0-4ed3-b277-f24f39251422.png)

Unlike FillRandom, which consistently decreases in performance, and ReadRandom, which increases and then decreases around 10 bits, ReadMissing shows a significant performance increase as soon as a Bloom filter is used, and performance continues to improve as the number of bits increases. This is likely because, as hypothesized, in ReadMissing, the performance improvement from reducing false positives outweighs the overhead from increasing the Bloom filter size.
