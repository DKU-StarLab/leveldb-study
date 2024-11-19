## Bloom Filter Read

![img](https://user-images.githubusercontent.com/101636590/187571334-4c1d3c8d-77e1-4824-8338-45dcf735d4c1.png)
The `db_bench` starts from the main function in the `db_bench.cc` file, reads parameters using `scanf`, and then executes the `benchmark.Run()` class function.

This function sequentially executes the `Open()` function, which handles the write process, and the `RunBenchmark()` function, which handles the read process.

![image](https://user-images.githubusercontent.com/101636590/189677379-32e48a2e-b087-47e3-9b8c-5771cc7a783c.png)

The `RunBenchmark()` function requires three parameters: `num_threads`, `name`, and `method`. Among them, `num_threads` indicates the number of threads and can be specified as a parameter value when starting `db_bench`.

![image](https://user-images.githubusercontent.com/101636590/189677993-8bdbcf82-3b03-43c1-8c76-2b55927d5d93.png)

Next, `Name` is a string variable that represents the type of benchmark. It stores the values entered in the parameters, separated by commas. `Method` is a pointer variable that stores the address of the benchmark function corresponding to `Name`.

![image](https://user-images.githubusercontent.com/101636590/189682019-4ded8020-839b-48f1-bcdb-7ad3a886a9b7.png)

After that, the address value of the `method` in the `RunBenchmark()` function is stored in the `arg[]` array. The `StartThread` function is executed with this value and the `ThreadBody()` function as arguments. The `ThreadBody()` function performs the given benchmark with the allocated thread.

![img](https://user-images.githubusercontent.com/101636590/187571539-e04da925-24a4-45ab-a18a-a3df6905e80c.png)

The code flow of the benchmark is as follows: Starting with benchmark functions like `ReadRandom()` or `ReadHot()`, it gradually narrows the search range through multiple `Get()` functions, from the database to the sstable, and then to each level, table, filter block, and bloom filter.

![image](https://user-images.githubusercontent.com/101636590/189691492-2cfdce0a-d5d8-4eeb-b5d5-80627986b82d.png)

In the benchmark function, after performing the functions assigned to each benchmark, the `db->Get()` function is used. Here, `db` is the address value of the database used in the `DB::open()` function when opening the database during the write process.

![image](https://user-images.githubusercontent.com/101636590/189692806-b438bfc1-8ea4-4aa5-a65d-a134b6223b82.png)

The `DBImpl::Get()` function sequentially searches the memtable, immemtable, and sstable. The function used to search the sstable is `Version::Get()`. (Note that the bloom filter is only used in the sstable.)

![image](https://user-images.githubusercontent.com/101636590/189693687-c932cc19-9c1b-456e-8201-b87d3525df0c.png)

The `Version::Get()` function executes the `ForEachOverlapping()` function with the `Match()` function as an argument. The `ForEachOverlapping()` function first searches level 0 of the sstable and then searches other levels. The `Match()` function used in this search process checks if a specific key exists in the table and returns a boolean value based on its existence.

![image](https://user-images.githubusercontent.com/101636590/189708396-b9111409-9051-4d3f-9a0c-a801793935f1.png)

The `TableCache::Get()` function called by the `Match()` function searches the table. Then, `FilterBlockReader::KeyMayMatch()` searches the filter block, and `BloomFilterPolicy::KeyMayMatch()` searches the bloom filter to finally check the existence of a specific key. The `InternalGet()` function in the middle proceeds with the read if the key being searched for exists.

