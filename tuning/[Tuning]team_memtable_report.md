#option설명
##leveldb.write_buffer_size
write_buffer_size는 memtable & imm_memtable의 크기를 정할수 있습니다.
db에 데이터를 입력할때 먼저 memtable에 write한는거라 write_buffer_size가 크면 write성능이 좋아지지만, db를 restart할때 wal에서 다시 write를 실행해햐해서 회복시간도 길어집니다.

##leveldb.max_file_size
max_file_size는 하나의 sstable의 최대크기를 정할수 있습니다.
key/value가 작으면 max_file_size도 같이 작아져야하고, 크면 커져야합니다. 하지만 크면 클수록 read/write amplification이 심해지니 크기를 수정할때 고려해야 합니다.

##leveldb.compression
leveldb에서 데이터들을 snappy압축을 지원합니다, snappy의 특성은 성응(효율)이 좋지만 앞축율은 제일 좋은것이 아닙니다, 그래서 보통 database에 많이 쓰이는 압축 알고리즘입니다.
압축은 data의 공간을 줄이지만 write할때 압축하거나 read할때 압축을 풀때는 cpu cost가 생기는 거라서 cpu cost로 공간을 바꾸는 겁니다.
data가 크면 앞축을 키고 작으면 끄는것을 권장합니다.

##leveldb.cache_size
leveldb에서 data를 저장할떄 block단위로 진행합니다. 그래서 data를 찾을때 block를  cache에 저장해서 다음의 시간을 줄일수 있습니다.
cache_size가 크면 database의 read성능이 좋아지지만 memory cost도 커집니다.

##leveldb.filter_bits


##leveldb.block_size
leveldb read/write의 기본단위입니다. 
key/value 크기에 대응하여 설정해야합니다.

##leveldb.block_restart_interval
몇개의 키를 간겹으로 prefix compression을 실행하는거를 정합니다.

- - -
- - -
2022-08-15 20:13:09 0 sec: 0 operations;
2022-08-15 20:13:10 0 sec: 100000 operations; [READ: Count=49912 Max=4231.61 Min=1.14 Avg=4.24] [UPDATE: Count=50088 Max=3125.45 Min=3.94 Avg=8.25]
Run runtime(sec): 0.831485
Run operations(ops): 100000
Run throughput(ops/sec): 120267

##100000 operations
op가 많은것이 않이어서 옵션을 작은db의 맞게 설정했습니다.

leveldb.write_buffer_size=33554432
leveldb.max_file_size=16777216
leveldb.compression=snappy
leveldb.cache_size=33554432
leveldb.filter_bits=10
leveldb.block_size=8192
leveldb.block_restart_interval=16