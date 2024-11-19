## Bloom Filter Structure

![Bloom Filter Diagram](https://user-images.githubusercontent.com/101636590/183424363-05494e10-e230-45b1-9a2a-18f413748970.png)
(Source: https://en.wikipedia.org/wiki/Bloom_filter)

A Bloom filter is a probabilistic data structure that can determine whether a specific key exists in a data block.

When writing data to a Bloom filter, k hash functions are performed on each key to obtain k hash values. The values corresponding to these hash values in the Bloom filter array are changed from 0 to 1, indicating that the key exists in the data block.

When reading, instead of reading the entire data block, the same k hash functions are performed on the data to be read to obtain k hash values. Only the data blocks where all the corresponding array values are 1 are selected for reading, thereby improving read performance.

---

### Bloom Filter Location

![SSTable Logic Diagram](https://user-images.githubusercontent.com/101636590/188339431-c3f219ba-b2f0-4bc5-bbcf-a39a8be35d85.jpg)
(Source: https://leveldb-handbook.readthedocs.io/zh/latest/)

The Bloom filter exists within the SSTable, and the structure of the SSTable is as shown above. One SSTable contains n data blocks, 1 filter block, and 1 meta index block.

The filter block contains n Bloom filter arrays, and the meta index block indicates which data block each Bloom filter array corresponds to.

---

### True Negative & False Positive

![True Negative & False Positive](https://user-images.githubusercontent.com/101636590/188339451-c0638280-3882-4883-8396-d23c88008068.png)
(Source: https://www.linkedin.com/pulse/which-worse-false-positive-false-negative-miha-mozina-phd)

The biggest advantage of a Bloom filter is that a True Negative never occurs. A True Negative is when data that exists in the database is judged as non-existent, which is directly related to the reliability of the filter.

On the other hand, False Positives (judging non-existent data as existent) can occur frequently. This can be a cause of performance degradation, and reducing False Positives is one of the important challenges of Bloom filters.

---

### Hash Function

![Bloom Filter Hashing](https://user-images.githubusercontent.com/101636590/183424697-ef93e101-a865-47a3-9e14-2046590dd9d9.png)

Using the benchmarking tool `db_bench` provided by LevelDB, we can adjust the number of bits used per key (Bloom_bits) or the number of data (Num). The size of the generated Bloom filter array becomes `Bloom_bits * Num` bits. This value can be checked in the `CreateFilter` class function of `bloom.cc`.

The default setting of `db_bench` does not use a Bloom filter, and to use it, the `Bloom_bits` value must be specified. The ideal `Bloom_bits` value in LevelDB is 10, which can improve read performance without significantly degrading write performance.

Additionally, the number of hash functions K is determined using the formula `K = ln(2) * (M/N) = ln(2) * B`. This formula calculates the value that can minimize the False Positive rate.

---

### False Positive Probability

![False Positive Formula](https://user-images.githubusercontent.com/101636590/188341913-5b0f489f-294a-4d5c-8171-d0ae7fa895cc.png)

The probability of a False Positive can be mathematically organized, and through this, the optimal k value and number of bits to minimize False Positives can be calculated.

When the k value is `ln(2) * (m/n)`, the probability of a False Positive is expressed in the form of `1/2^k`, and as the k value increases, the probability of a False Positive decreases. This is proportional to bloom_bits.

---

### Code Flow of Bloom Filter

- [Write: Creation of Bloom Filter](https://github.com/DKU-StarLab/leveldb-wiki/blob/main/analysis/bloomfilter/bloomfilter-write.md)
- [Read: Quickly check the existence of a specific key with Bloom Filter](https://github.com/DKU-StarLab/leveldb-wiki/blob/main/analysis/bloomfilter/bloomfilter-read.md)

---

### Reference

- [Estimation using Probabilistic Data Structures](https://d2.naver.com/helloworld/749531)  
- [LevelDB Github](https://github.com/google/leveldb)  
- [Github - db_bench.cc](https://github.com/google/leveldb/blob/main/benchmarks/db_bench.cc)  
- [Github - bloom.cc](https://github.com/google/leveldb/blob/main/util/bloom.cc)  
- [Github - filter_block.cc](https://github.com/google/leveldb/blob/main/table/filter_block.cc)  
- [Github - filter_policy.h](https://github.com/google/leveldb/blob/main/include/leveldb/filter_policy.h)  
- [LevelDB Handbook](https://leveldb-handbook.readthedocs.io/zh/latest/bloomfilter.html)
