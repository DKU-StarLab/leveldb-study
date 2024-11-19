## SSTable 
LevelDB is based on the LSM tree (Log Structured Merge Tree), which means that when writing, data is not written directly to the disk but is first written to the Log and then to the MemTable. When the MemTable is full, it sends the data to the Immutable MemTable, and from the Immutable MemTable, it flushes the data to storage (i.e., disk).

When the data in memory is flushed to storage in this way, LevelDB stores the data in a data structure called SSTable (Sorted String Table). This article deals with this SSTable.  
<br/>  

### SSTable format  
Physically, an SSTable is divided into 4KB blocks, each containing fields for storing data, compression type (indicating whether the data stored in the block is compressed and, if so, which algorithm was used), and CRC checks for error detection.

From a logical perspective, an SSTable can be viewed as having the following structure:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/182532427-47d356d8-c3a7-4d72-b8df-f3adcb75bcbe.png"></p>  

<br/>  

### Data Block  
This block stores key-value pairs. The structure is as follows:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187910209-7d931fb7-6870-45e2-ade4-f0316cb25c72.png"></p>  

Since SSTables hold keys in a sorted manner, each key can have many overlapping parts with others. To address this issue and improve space efficiency, LevelDB is designed to store only the non-overlapping part of the key (excluding the prefix shared with the previous record) rather than the entire key value.

This method reduces the memory used for storing keys, but it also has the downside of degrading read performance. Although SSTables are internally sorted, allowing for binary search, the partial key storage means binary search cannot be effectively used.

To solve this problem, LevelDB introduces the concept of a `Restart Point`. Instead of storing only partial keys for all entries in a Data Block, it stores the full key value every k entries (default is 16). These entries with full key values are called `Restart Points`. As shown in the diagram, the Data Block internally stores the positions of each `Restart Point`.

By introducing `Restart Points` and rewriting the full key value every k records, the entries within a Data Block form sections based on these `Restart Points`.

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187920060-32e4a102-a0e7-4929-8d59-6494f9f09ee8.png"></p> 

Since SSTables internally maintain keys in a sorted order, the entries corresponding to each `Restart Point` are also sorted. Therefore, you can use binary search to find the section where the key you are looking for might be, thus improving read performance.  
<br/>  

### Filter Block  
This block contains Bloom Filters. The structure is as follows:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187955758-acd5f9e8-8d00-4ea4-898b-9773e5071b9b.png"></p> 

Filters refer to Bloom Filters, and the Filter offset contains the starting offset information for each Filter. The Filter offset's offset contains the offset information for Filter 1. To read a Bloom Filter, you first read the Filter offset's offset, then use it to read the desired Filter's offset, and finally navigate to and read the corresponding Filter.  
<br/>  

### Meta Index Block  
This block contains the index information for the Filter Block and stores only one related record.  
<br/>  

### Index Block  
This block contains the index information for each Data Block. The structure is as follows:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187952948-860a8f3d-1b91-4ce0-b127-3b7a56b64008.png"></p>  

Each entry contains not only the index information for the corresponding Data Block but also the size of the Data Block and the largest key value in that Data Block.  
<br/>  

### Footer  
This block has a fixed size of 48 bytes and contains the index information for the Meta Index Block and the Index Block. The structure is as follows:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187959918-6f36b165-b598-4aed-8c88-72716c7d0179.png"></p>  
<br/>  

### Note - Block Entry Structure
Data Block, Index Block, and Meta Index Block are all created through the same object called BlockBuilder, so their structures are essentially the same. This means that not only Data Blocks but also Index Blocks and Meta Index Blocks have `Restart Points`. Just as Data Blocks store Key-Value Pairs, Index Blocks and Meta Index Blocks also store a kind of Key-Value Pair. For example, in an Index Block, the Max key field of each entry acts as the key, while the offset and length fields act as the value.

The structure of the entries that make up these blocks is as follows:

<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187917146-dcf4bd36-30b6-4406-ab15-ac461bb48f64.png"></p>  

- Shared key length: Length of the part of the key that overlaps with the previous record
- Unshared key length: Length of the part of the key that does not overlap with the previous record
- Value length: Length of the value
- Unshared key content: Part of the key that does not overlap with the previous record
- Value: The value itself  

#### Example
```
- restart_interval = 3
- entry 1: key = abc, value = v1
- entry 2: key = abe, value = v2
- entry 3: key = abg, value = v3
- entry 4: key = chesh, value = v4
- entry 5: key = chosh, value = v5
- entry 6: key = chush, value = v6
```  
<p align="center"><img src="https://user-images.githubusercontent.com/65762283/187968907-06fdea2b-b44c-4240-b529-c77a9f6112b8.png"></p>  

By setting the `restart_interval` to 3, you can see that a `Restart Point` is marked every 3 records, and the entries corresponding to these `Restart Points` store the full key value, unlike other records.  

### SSTable - Write & Read 
[Write - Process of Creating an SSTable](./sstable-write.md)  
[Read - Process of Finding a Key in an SSTable](./sstable-read.md)  
