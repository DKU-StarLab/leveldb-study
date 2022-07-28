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

# ------------------------2. Run db_bench------------------------
# 1. Set your benchmark options
# 1) Set result file
result_file="example.txt"
# 2) Set db_bench option-num array
NUM=(1 2)
# 3) Set db_bench option-value_size array
VAl_SIZE=(128 256 512)
# 4) Set db_bench benchmarks array
BENCH=("fillrandom,stats,readrandom,stats" "fillrandom,stats,seekrandom,stats")
# you can add more options with for statement.

# 2. Run db_bench
# num loop
for num in "${NUM[@]}" 
do 
    # valuesize loop
    for value in "${VAl_SIZE[@]}" # 4) num array loop
    do
        # benchmark loop
        for bench in "${BENCH[@]}"
        do
            ((count++))

            # Make Command String
            CMD="./db_bench \
            --use_existing_db=0 \
            --histogram=1 \
            --compression_ratio=1 \
            --benchmarks="$bench"
            --num="$num" \
            --value_size="$value" \
            "
            # Write Experiment Count to file and terminal
            echo "Count $count" | tee -a "$result_file"
            
            # Write Command to file and terminal
            echo "$CMD" | tee -a "$result_file"
            # Write '\n' to file and terminal
            echo | tee -a "$result_file"
            
            # 3. clearing kernel buffers before running each workload.
            # if you want to drop caches, run shell script with sudo su
            # sync; echo 3 > /proc/sys/vm/drop_caches
            
            # Run Command and Save bench result
            RESULT=$($CMD)

            # Write bench result to file and terminal 
            echo "$RESULT" | tee -a "$result_file"
            # Write '\n' to file and terminal
            echo | tee -a "$result_file"
        done
    done
done
