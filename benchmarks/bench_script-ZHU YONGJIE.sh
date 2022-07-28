#!/bin/bash

# ----------------1. db_bench enviorment setting-----------------
# (0) root user
# sudo su

# (1) disable swap entirely to avoid performance problems and incosistencies
# swapoff --all

# (2) disable zone_reclaim_mode
# echo 0 > /proc/sys/vm/zone_reclaim_mode

# (3) maximum open file
# sysctl fs.file-max
# sysctl -w fs.file-max=5000000
# ---------------------------------------------------------------

# ----------------------2. db_bench benchmarks----------------------
# All options are written in leveldb/benchmarks/db_bench.cc

# Comma-separated list of operations to run in the specified order
#   Actual benchmarks:
#      fillseq       -- write N values in sequential key order in async mode
#      fillrandom    -- write N values in random key order in async mode
#      overwrite     -- overwrite N values in random key order in async mode
#      fillsync      -- write N/100 values in random key order in sync mode
#      fill100K      -- write N/1000 100K values in random order in async mode
#      deleteseq     -- delete N keys in sequential order
#      deleterandom  -- delete N keys in random order
#      readseq       -- read N times sequentially
#      readreverse   -- read N times in reverse order
#      readrandom    -- read N times in random order
#      readmissing   -- read N missing keys in random order
#      readhot       -- read N times in random order from 1% section of DB
#      seekrandom    -- N random seeks
#      seekordered   -- N ordered seeks
#      open          -- cost of opening a DB
#      crc32c        -- repeated crc32c of 4K of data
#   Meta operations:
#      compact     -- Compact the entire DB
#      stats       -- Print DB stats
#      sstables    -- Print sstable info
#      heapprofile -- Dump a heap profile (if supported by this port)
# ---------------------------------------------------------------

# ----------------------3. db_bench options----------------------
# --db=
# --reuse_logs=
# --use_existing_db=

# --benchmarks=""
# --histogram=
# --comparisons=

# --num=
# --reads=
# --threads=

# --value_size=
# --compression_ratio=

# --write_buffer_size=
# --max_file_size=
# --block_size=
# --cache_size=
# --open_files=
# --bloom_bits=
# --key_prefix=
# ----------------------------------------------------------------

# ------------------------3. Run db_bench------------------------
# clearing kernel buffers before running each workload.
sync; echo 3 > /proc/sys/vm/drop_caches

# sample db_bench command
#CMD="./db_bench \
#--use_existing_db=0 \
#--compression_ratio=1 \
#--comparisons=1 \
#--benchmarks="fillrandom,stats,readrandom,stats" \
#--histogram=1 \
#--num=1000 \
#--reads=5000 \
#--bloom_bits=0 \
#"

# ----------------------------------------------------------------

# ------------------------4. Debug db_bench-----------------------
# gdb --args db_bench (args ...)
# b db_bench.cc:1022 [line of db_bench main func]
# -----------~-----------------------------------------------------
#用for循环测试fillseq，fillrandom，每次测试后将write_buffer_size乘以2
for i in {2097152,4194304,8388608,16777216,33554432}
do
        for j in {2097152,4194304,8388608,16777216,33554432}
        do
            echo "write_buffer_size is $i" | tee -a result.txt
            echo "max_file_size is $j" | tee -a result.txt

            CMD="./db_bench --benchmarks="fillseq" --use_existing_db=0 --compression_ratio=1 --comparisons=1 --num=5000000 --reads=1000000 --bloom_bits=0 --value_size=100 --write_buffer_size=$i --max_file_size=$j --open_files=1024"
            echo "$CMD" | tee -a result.txt
            echo | tee -a result.txt
            RESULT=$($CMD)
            echo "$RESULT" | tee -a result.txt
            echo | tee -a result.txt

            CMD="./db_bench --benchmarks="readrandom" --use_existing_db=1 --reads=1000000 --open_files=1024"
            echo "$CMD" | tee -a result.txt
            echo | tee -a result
            RESULT=$($CMD)
            echo "$RESULT" | tee -a result.txt
            echo | tee -a result.txt

            CMD="./db_bench --benchmarks="fillrandom" --use_existing_db=0 --compression_ratio=1 --comparisons=1 --num=5000000 --reads=1000000 --bloom_bits=0 --value_size=100 --write_buffer_size=$i --max_file_size=$j --open_files=1024"
            echo "$CMD" | tee -a result.txt
            echo | tee -a result.txt
            RESULT=$($CMD)
            echo "$RESULT" | tee -a result.txt
            echo | tee -a result.txt

            CMD="./db_bench --benchmarks="readrandom" --use_existing_db=1 --reads=1000000 --open_files=1024"
            echo "$CMD" | tee -a result.txt
            echo | tee -a result.txt
            RESULT=$($CMD)
            echo "$RESULT" | tee -a result.txt
            echo | tee -a result.txt
        done

done

