# [Team SSTable] Tuning report  
 
### write_buffer_size  
이 옵션은 클수록 쓰기 성능이 향상되기 때문에 대량 Load시의 속도도 빨라진다. 다만 이 경우 MemTable에서 원하는 key가 있는지 탐색하는 시간이 늘어날 수 있다는 점에서 일종의 trade-off가 있다. 근데 어차피 Skiplist의 탐색시간은 O(log n)으로 write_buffer가 커지는 것에 비해 탐색시간이 걸리는 시간은 그리 크지 않고 어차피 찾는 거라면 disk에서 찾는 것보단 memory에서 찾는 게 더 빠르므로 `write_buffer_size`는 크기를 키우는 방향으로 가기로 했다.  

### max_file_size  
SSTable의 size에 관한 옵션으로, write_buffer_size에 비해 이 녀석이 작으면 작을수록 minor compaction을 통해 SSTable을 만들 때 더 많은 SSTable이 만들어지므로 쓰기 성능에 있어서 `max_file_size`를 작게 하는 것은 불리하다고 생각했다. 또한 만약 `max_file_size`가 `write_buffer_size`의 4분의 1보다 작다면 minor compaction이 발생할 때마다 level 0 compaction이 일어날 수 있고 이는 성능 저하로 직결된다고 판단했다. 때문에 `max_file_size`를 `write_buffer_size`의 4분의 1보다는 크게 설정하는 방향으로 가기로 했으며, `write_buffer_size`의 2분의 1정도로 하는 것이 적당하다고 생각했다. 
### compression  
`options.h`에 쓰인 내용에 따르면 일반적으로 snappy를 쓰는 게 낫다고 하여 냅뒀다.
### cache_size  
캐시 사이즈가 클수록 hit가 많이 일어나므로 read성능이 향상되고, 특히 workload D의 경우 최근의 데이터를 read하는 부분이 많으므로 캐시 사이즈를 늘리면 큰 성능향상을 기대할 수 있으리라 생각했다. 단 캐시를 무작정 크게 할 순 없으므로 어느 정도로 크게 할 것인가를 고민했는데, 실험을 돌리는 환경(학교 서버)의 캐시 사이즈가 14080KB여서 거기에 맞춰서 캐시 사이즈를 정하기로 했다.
### filter_bits  
- 블룸필터를 사용할 것인지  
Bloom Filter를 쓰지 않으면 쓰기 성능이 향상되고, Bloom Filter를 쓰면 읽기 성능이 향상된다. 그러나 우리 팀에서 실험했던 결과에 따르면 Bloom Filter를 쓰지 않을 경우 쓰기 성능의 향상이 있긴 했지만 미비한 수준이었다. 어차피 LSM-Tree자체가 쓰기에 최적화된 자료구조이기도 하고, 읽기 성능을 꾀하는 것이 더 이익이라 판단하여 Bloom Filter를 사용하기로 했다.  
- 키당 몇 비트를 쓸 것인지  
Bloom Filter 팀에서 전에 발표했던 내용을 참고해보니 10비트로 둘 때가 가장 이상적인 속도가 나오는 걸 볼 수 있었다. 그래서 10비트 그대로 두기로 했다.  

### block_size  
우리 팀에서 분석한 결과에 따르면 SSTable을 만들 때 Data Block들은 바로바로 disk에 써주고, Filter Block들을 비롯한 나머지 블록들은 버퍼에 모았다가 한 번에 써준다. 즉 하나의 SSTable을 만들더라도 내부를 구성하고 있는 Data Block의 수가 적다면 그 SSTable을 만들기 위해 쓰이는 disk I/O를 줄일 수 있고 이는 쓰기 성능 향상에 도움이 될 수 있을 것이라고 생각했다. 단 이 경우 읽기 성능을 저하시킬 수 있는 점에서 trade-off가 있다. 근데 어차피 SSTable 내에서 key를 찾아가는 과정은 이분탐색을 사용한다고 알고 있고 이분탐색의 시간복잡도는 O(log n)으로 block size가 늘어난 것에 비해 그리 크게 탐색시간이 증가되지 않는다고 생각했다. 따라서 block_size는 키우는 방향으로 가기로 했다.  

### block_restart_interval  
`block_restart_interval`을 통해서 Data Block내에서 key-value pair들이 일종의 구역을 형성한다. 코드를 분석한 결과 target key가 있는 구역을 binary search로 찾고 그 구역내에서는 linear search를 하는 모습을 관찰했기 때문에 이 옵션을 작게 하는 것이 read에 유리한 것이라 판단하여 작게 하기로 했다. 단 이 경우 더 많은 공간을 사용할 수 있으나 runtime과 throughput만 고려하면 된다고 생각해 여기까진 생각하지 않기로 했다.

## Result
각 커맨드 당 3번씩 입력해 나온 평균값들이다.
### Default set
```
leveldb.write_buffer_size=2097152
leveldb.max_file_size=4194304
leveldb.compression=snappy 
leveldb.cache_size=4194304
leveldb.filter_bits=10
leveldb.block_size=4096
leveldb.block_restart_interval=16
```  

- Load A
  - Average Load Runtime(sec) : 4.4636
  - Average Load Throughput(ops/sec) : 22598.2
- Run A
  - Average Run Runtime(sec) : 1.98984
  - Average Run Throughput(ops/sec) : 51221.6
- Run B
  - Average Run Runtime(sec) : 0.60909
  - Average Run Throughput(ops/sec) : 164452.7
- Run D
  - Average Run Runtime(sec) : 0.43340
  - Average Run Throughput(ops/sec) : 230799.3

### Our Best set
```
leveldb.write_buffer_size=67108864
leveldb.max_file_size=33554432
leveldb.compression=snappy 
leveldb.cache_size=14417920
leveldb.filter_bits=10
leveldb.block_size=2097152
leveldb.block_restart_interval=4
```  

- Load A
  - Average Load Runtime(sec) : 1.32495
  - Average Load Throughput(ops/sec) : 77013.1
- Run A
  - Average Run Runtime(sec) : 1.16803
  - Average Run Throughput(ops/sec) : 85921.1
- Run B
  - Average Run Runtime(sec) : 0.55706
  - Average Run Throughput(ops/sec) : 184068
- Run D
  - Average Run Runtime(sec) : 0.42554
  - Average Run Throughput(ops/sec) : 240711.3