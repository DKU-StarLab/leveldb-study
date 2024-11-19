## Bloom Filter Write

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183425832-0ca0a6f6-a8d4-471b-8765-44a3ccad1904.png)

The entire LevelDB code contains about 100 main functions. By checking the `makefile` of `db_bench`, we can see that the main function of `db_bench` is located in the `db_bench.cc` file.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183425880-7bcff039-5faa-4e42-9ad9-763c12f6c614.png)

This main function is largely divided into two parts. The first part is the `sscanf` section that reads parameters like `bloom_bits` and `num` when executing `db_bench`, and the second part is the `benchmark.Run()` class function.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183425930-e7017bb8-d77e-428a-a4c1-fa9e1b5288ca.png)

The `benchmark.Run()` is also divided into three main parts.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183425988-2d5638f4-ba97-4a54-9f5e-ddc3529dbe7a.png)

In the `Benchmark` class, several class variables, including `filter_policy`, are declared.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183425998-87fd0957-3bc3-4c7f-9239-ebf597053cf7.png)

Subsequently, the values of the class variables are assigned in the class constructor. At this time, if the `bloom_bits` value read by `sscanf` in the main function is 0 or more, it means that a bloom filter is used, so the `NewBloomFilterPolicy()` function is called. If it is less than 0, it means that the bloom filter is not used, and `Null` is returned. The default value of `bloom_bits` is -1, meaning that if the value is not changed, the bloom filter is not used, and if set to 0, a minimum size bloom filter is used.

![image](https://user-images.githubusercontent.com/101636590/189701906-715a3bca-2840-444f-a2a6-65d9e488a611.png)

Then, the `Run()` class function is divided into three main parts.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183426642-fe0298bb-797c-4453-8baf-877f042e7468.png)

`PrintHeader()` is a function that outputs information about the environment or data when running `db_bench` to the terminal, `Open()` handles the write process, and `RunBenchmark()` handles the read process.

![image](https://user-images.githubusercontent.com/101636590/189703746-c4dbafce-b352-46d5-8404-ac614a7536ff.png)

In the `Open()` function, the values of class variables, including `filter_policy`, are stored in a new `Struct` called `options` and passed to the `DB::Open()` function. The `DB::Open()` function also puts the values of `options` received as arguments into a class called `impl` and continues the process of passing variable values, including `filter_policy`, to the next function by performing functions like `MaybeScheduleCompaction()`.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183426744-152b6145-f791-45f1-b45e-3e8c5139930f.png)

The code flow is as shown above, which involves performing compaction and creating SSTables, including FilterBlock. In this process, `filter_policy` only receives values from the previous function to the next function, so detailed explanation is omitted.

![image](https://user-images.githubusercontent.com/101636590/189719785-9600699f-32c8-4833-891b-253fadd6d770.png)

Finally, in the `GenerateFilter()` function, the `createFilter` class function of the `filter_policy` that has been passed so far is called.

![image](https://user-images.githubusercontent.com/101636590/189720666-9f93d9fb-f38a-46c6-a492-5b90f7e296ce.png)

The content of this function is determined by the `NewBloomFilterPolicy()` function called in the `Benchmark` class constructor.

## Bloom Filter Policy

![image](https://user-images.githubusercontent.com/101636590/189722524-431b95ed-948e-4b27-b65a-c8c3c2a699c1.png)

`NewBloomFilterPolicy()` is a function that creates and returns a "BloomFilterPolicy" class that overrides the "FilterPolicy" class.

![image](https://user-images.githubusercontent.com/101636590/189721381-008fcdf8-9133-4c0d-9f00-ad612fc659fc.png)

The `FilterPolicy` class consists of a `Name()` function that returns the name of the filter, a `CreateFilter()` function that creates a bloom filter array during write, and a `KeyMayMatch()` function that checks if a specific key value exists in the array during read.

The `BloomFilterPolicy` class that overrides this is implemented as follows:

```cpp
class BloomFilterPolicy : public FilterPolicy {
 public:
  explicit BloomFilterPolicy(int bits_per_key) : bits_per_key_(bits_per_key) {
    // We intentionally round down to reduce probing cost a little bit
    k_ = static_cast<size_t>(bits_per_key * 0.69);  // 0.69 =~ ln(2)
    if (k_ < 1) k_ = 1;
    if (k_ > 30) k_ = 30;
  }

  const char* Name() const override { return "leveldb.BuiltinBloomFilter2"; }
```

The part of the code that determines the number of hash functions and limits the maximum number, and

The `Name()` function that returns a specific name.

<br/>
<br/>

```cpp
void CreateFilter(const Slice* keys, int n, std::string* dst) const override {
    // Compute bloom filter size (in both bits and bytes)
    size_t bits = n * bits_per_key_;

    // For small n, we can see a very high false positive rate.  Fix it
    // by enforcing a minimum bloom filter length.
    if (bits < 64) bits = 64;

    size_t bytes = (bits + 7) / 8;
    bits = bytes * 8;
```

And the `CreateFilter()` function determines the size of the bloom filter array (=bits) by multiplying the bloom_bits (=bits_per_key) value and the num (=n) value.

<br/>
<br/>

```cpp
const size_t init_size = dst->size();
    dst->resize(init_size + bytes, 0);
    dst->push_back(static_cast<char>(k_));  // Remember # of probes in filter
    char* array = &(*dst)[init_size];
    for (int i = 0; i < n; i++) {
      // Use double-hashing to generate a sequence of hash values.
      // See analysis in [Kirsch,Mitzenmacher 2006].
      uint32_t h = BloomHash(keys[i]);
      const uint32_t delta = (h >> 17) | (h << 15);  // Rotate right 17 bits
      for (size_t j = 0; j < k_; j++) {
        const uint32_t bitpos = h % bits;
        array[bitpos / 8] |= (1 << (bitpos % 8));
        h += delta;
      }
    }
 ```

It is divided into a part that handles "double hashing".

# Double Hashing

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183426381-db205ffc-c946-49af-a75d-2b0869145737.png)
![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183426385-eb7ead05-1359-4802-9bc6-0f2d892756bb.png)

(Source: https://www.eecs.harvard.edu/~michaelm/postscripts/rsa2008.pdf)

Referring to the paper mentioned in the comments of the function, it is mathematically proven that by using two hash functions and reusing one of them, instead of using k different hash functions, the load and computation caused by hash functions can be significantly reduced while maintaining the original performance.

<br/>
<br/>

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183426427-2a7c8496-b118-42aa-b6da-112205d9b581.png)

In LevelDB, the first hash function is implemented as a function called `BloomHash()`, and the second hash function is implemented as a bit operation `( h>>17 ) | ( h<<15 )`.

```cpp
namespace {
static uint32_t BloomHash(const Slice& key) {
  return Hash(key.data(), key.size(), 0xbc9f1d34);
}
```

```cpp
uint32_t Hash(const char* data, size_t n, uint32_t seed) {
  // Similar to murmur hash
  const uint32_t m = 0xc6a4a793;
  const uint32_t r = 24;
  const char* limit = data + n;
  uint32_t h = seed ^ (n * m);
```

`BloomHash` takes a key value as an argument and returns a specific value, taking the form of a typical hash function.

![img1 daumcdn](https://user-images.githubusercontent.com/101636590/183426489-099b0b6f-8a1c-4263-a575-60407a8b8c65.png)

The shift operation is structured to swap the first 15 bits and the last 17 bits. (Note that the hash value uses a 32-bit data type called `uint32_t`.) This shift operation is presumed to be used because it satisfies the properties of a hash function while having low overhead required for computation.

```cpp
uint32_t h = BloomHash(key);
    const uint32_t delta = (h >> 17) | (h << 15);  // Rotate right 17 bits
    for (size_t j = 0; j < k; j++) {
      const uint32_t bitpos = h % bits;
      if ((array[bitpos / 8] & (1 << (bitpos % 8))) == 0) return false;
      h += delta;
    }
```

And notably, since one bit must be set to 1 per hash, the bloom filter array is used by dividing one byte (1 byte = 8 bits) into 8 parts.

```cpp
 bool KeyMayMatch(const Slice& key, const Slice& bloom_filter) const override {
    // ... omitted
    uint32_t h = BloomHash(key);
    const uint32_t delta = (h >> 17) | (h << 15);  // Rotate right 17 bits
    for (size_t j = 0; j < k; j++) {
      const uint32_t bitpos = h % bits;
      if ((array[bitpos / 8] & (1 << (bitpos % 8))) == 0) return false;
      h += delta;
    }
    return true;
  }
```

Finally, the `KeyMayMatch` function used when reading data uses almost the same computation as `CreateFilter`, but it uses an if statement and an and operation instead of an or operation to check if a specific key value exists within the filter.