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

LEVELDB_BENCH="/home/solid/leveldb/build/db_bench"
TXT_FORMAT=".txt"

array=("1" "2" "3" "4" "5" "6") 

for cnt in {1..5}
do  
    for team in "${array[@]}"
    do
      ((count++))
      result_file="No5_Team${team}_${cnt}${TXT_FORMAT}"
      
      rm -rf /tmp/ycsb-leveldb
      mkdir /tmp/ycsb-leveldb

      $LEVELDB_BENCH
      $LEVELDB_BENCH

      CMD="./YCSB-cpp/ycsb -load -db leveldb -P ./YCSB-cpp/workloads/workloada -P ./YCSB-cpp/leveldb/leveldb${team}.properties -s"
      echo "$CMD" | tee -a  "$result_file"
      RESULT=$($CMD)
      echo "$RESULT" | tee -a  "$result_file"

      CMD="./YCSB-cpp/ycsb -run -db leveldb -P ./YCSB-cpp/workloads/workloada -P ./YCSB-cpp/leveldb/leveldb${team}.properties -s"
      echo "$CMD" | tee -a  "$result_file"
      RESULT=$($CMD)
      echo "$RESULT" | tee -a  "$result_file"

      CMD="./YCSB-cpp/ycsb -run -db leveldb -P ./YCSB-cpp/workloads/workloadb -P ./YCSB-cpp/leveldb/leveldb${team}.properties -s"
      echo "$CMD" | tee -a  "$result_file"
      RESULT=$($CMD)
      echo "$RESULT" | tee -a  "$result_file"

      CMD="./YCSB-cpp/ycsb -run -db leveldb -P ./YCSB-cpp/workloads/workloadd -P ./YCSB-cpp/leveldb/leveldb${team}.properties -s"
      echo "$CMD" | tee -a  "$result_file"
      RESULT=$($CMD)
      echo "$RESULT" | tee -a  "$result_file"

      rm -rf /tmp/ycsb-leveldb
    done
done