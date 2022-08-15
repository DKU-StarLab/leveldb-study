# Team cache YCSB tunning report

## Hyphothesis and Experiment Options
### default option
<pre><code># YCSB-cpp/leveldb/leveldb.properties
# ---------------------------Restriction----------------------------
#  max_memory size (= write_buffer_size + block_cache_size) <= 1024 * 1024 * 1024 (1GB)
#  max_file_size <= 1024 * 1024 * 1024 (1GB)
leveldb.max_open_files=10000

# -------------LevelDB Options, Tune them!------------------
leveldb.dbname=/tmp/ycsb-leveldb
leveldb.format=single
leveldb.destroy=false

leveldb.write_buffer_size=2097152
leveldb.max_file_size=4194304
leveldb.compression=snappy 
leveldb.cache_size=4194304
leveldb.filter_bits=10
leveldb.block_size=4096
leveldb.block_restart_interval=16</code></pre>


## experiment options
<pre><code>YCSB Workload
Record Count = 2,000,000
Operation Count = 2,000,000
Workload file
Workload A
Workload B
Workload D
Load A -> Run A -> Run B -> Run D
</code></pre>

* Workload A :  Read/update ratio: 50/50
* Workload A :  Read/update ratio: 95/5
* Workload A :  Read/update/insert ratio: 95/0/5

>각 workload 의 조건에 따라서 DB를 read, wirte 하는 조건이 다른다고 판단하여 shell script를 workload 마다 작성하여 실험을 진행하였다.

<pre><code>
echo "ex 1"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties1 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties2 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties3 -s"
RESULT=$($CMD)
echo "$RESULT"


echo "ex 2"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties1 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties2 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties3 -s"
RESULT=$($CMD)
echo "$RESULT"

echo "ex 3"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties1 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties2 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties3 -s"
RESULT=$($CMD)
echo "$RESULT"


echo "ex 4"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties1 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties2 -s"
RESULT=$($CMD)
echo "$RESULT"
CMD="./ycsb -run -db leveldb -P workloads/workloada -P leveldb/leveldb.properties3 -s"
RESULT=$($CMD)
echo "$RESULT"
</code></pre>

> 결과값은 각 실험마다 나온 결과의 평균으로 성능을 측정하였다.


### write_buffer_size
>값을 2배씩 늘려가면서 성능이 더이상 좋아지지 않는 시점을 찾았다.
### max_file_size
>write_buffer_size와 같이 값을 증가시키면서 최적의 옵션을 선택했다
### cache_size
>실험을 돌리면서 옵션들의 변화에도 큰 성능의 차이는 발견하지 못했다. 하지만 이전에 실험했던 것 처럼 여러번 실험을 반복하여
평균치가 가장 좋은 옵션을 선택하였다. 
### block_size
>write, read 모두 성능을 비교하여 측정
### block_restart_interval
>키의 델타 인코딩을 위한 다시 시작 지점 사이의 키 수.

## Result

|Result||
|---|---|
|leveldb.write_buffer_size|47.68MB|
|leveldb.max_file_size|4MB|
|leveldb.compression|snappy|
|leveldb.cache_size|40MB|
|leveldb.filter_bits|10|
|leveldb.block_size|8KB|
|leveldb.block_restart_interval|32|  













