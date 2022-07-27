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
# 1. clearing kernel buffers before running each workload.
# if you want, run shell script with sudo su
# sync; echo 3 > /proc/sys/vm/drop_caches


# 2. Set your benchmark options
# you can add more options with for statement.
result_file="example.txt"
NUM=(1 2)
VAl_SIZE=(128 256 512)
BENCH=("fillrandom,stats,readrandom,stats" "fillrandom,stats,seekrandom,stats")

for num in "${NUM[@]}"
do
    for value in "${VAl_SIZE[@]}"
    do
        for bench in "${BENCH[@]}"
        do
            ((count++))

            CMD="./db_bench \
            --use_existing_db=0 \
            --histogram=1 \
            --compression_ratio=1 \
            --benchmarks="$bench"
            --num="$num" \
            --value_size="$value" \
            "
            echo "Count $count" | tee -a "$result_file"
            echo "$CMD" | tee -a "$result_file"
            echo | tee -a "$result_file"

            RESULT=$($CMD)

            echo "$RESULT" | tee -a "$result_file"
            echo | tee -a "$result_file"
        done
    done
done


# ----------------------------------------------------------------

# ------------------------4. Debug db_bench-----------------------
# gdb --args db_bench (args ...)
# b db_bench.cc:1022 [line of db_bench main func]
# -----------~-----------------------------------------------------