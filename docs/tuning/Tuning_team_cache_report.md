## [Team Cache] YCSB Tuning Report

### Hypothesis and Experiment Options

#### Default Options

- **Restrictions:**
  - Maximum memory size (write_buffer_size + block_cache_size) must be ≤ 1GB
  - Maximum file size must be ≤ 1GB
  - `leveldb.max_open_files=10000`

- **LevelDB Options:**
  - `leveldb.dbname=/tmp/ycsb-leveldb`
  - `leveldb.format=single`
  - `leveldb.destroy=false`
  - `leveldb.write_buffer_size=2097152`
  - `leveldb.max_file_size=4194304`
  - `leveldb.compression=snappy`
  - `leveldb.cache_size=4194304`
  - `leveldb.filter_bits=10`
  - `leveldb.block_size=4096`
  - `leveldb.block_restart_interval=16`

#### Experiment Options
Different shell scripts were created for each workload to handle varying read and write conditions, and experiments were conducted accordingly.

- **YCSB Workload:**
  - Record Count: 2,000,000
  - Operation Count: 2,000,000
  - Workload Files: Workload A, Workload B, Workload D
  - Sequence: Load A -> Run A -> Run B -> Run D

- **Workload Details:**
  - Workload A: Read/update ratio: 50/50
  - Workload B: Read/update ratio: 95/5
  - Workload D: Read/update/insert ratio: 95/0/5

```bash
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
```

```bash
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
```

```bash
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
```
```bash
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
```

The results are the averages of the results from each experiment.

#### write_buffer_size
The value was increased by a factor of 2, and the point at which performance no longer improved was found.

#### max_file_size
The value was increased along with write_buffer_size, and the optimal option was selected.

#### cache_size
While no significant performance differences were found with changes in other options, the optimal option was selected by repeating experiments multiple times and averaging the results.

#### block_size
Both write and read performance were compared and measured.

#### block_restart_interval
The number of keys between restart points for delta encoding.

### Result

|Result||
|---|---|
|leveldb.write_buffer_size|47.68MB|
|leveldb.max_file_size|4MB|
|leveldb.compression|snappy|
|leveldb.cache_size|40MB|
|leveldb.filter_bits|10|
|leveldb.block_size|8KB|
|leveldb.block_restart_interval|32|













