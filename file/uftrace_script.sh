#!/bin/sh

# 1. If you define default function, you don't have to enter target function.
default_func=""

# 2. Before run shell script, record ./db_bench

# 3. Check if user entered command such as replay, report, graph, tui ...
if [ -z "$1" ]
then
    echo '[USAGE] : sh uft_cmd [COMMAND] [TARGET FUNC]'
    echo '[COMMAND] : replay, report, graph, tui'
    exit
fi

# 4. Set target function,
if [ -n "$2" ]
then
    func="-F ${2}"
else
    if [ -z "$default_func" ]
    then
        func=""
    else
        func="-F ${default_func}"
    fi
fi

# 5. Run uftrace with filters. You can modify filters if you want.
uftrace $1 \
$func \
--no-libcall \
-N leveldb::MutexLock \
-N leveldb::ExtractUserKey \
-N leveldb::Arena::MemoryUsage \
-N __gthread_mutex_unlock \
-N __gthread_mutex_lock \
-N ^leveldb::Slice:: \
-N ^leveldb::port::Mutex \
-N ^leveldb::crc32c:: \
-N ^__gnu_cxx:: \
-H ^std:: \
-H ^operator \
-H ^leveldb::Status \
-H ^leveldb::operator \
-H ^leveldb::GetVarint \
-H ^leveldb::EncodeFixed \
-H ^leveldb::Encode \
-H ^leveldb::DecodeFixed \
-H ^leveldb::Decode \
-H ^__gnu_cxx::
