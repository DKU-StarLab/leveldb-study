# Benchmarks Experiment
## Notice
* Upload your presentation file through pull reqeust.
    - Pull request until **Tuesday, 7/26 11AM**.
    - Title: [topic]benchmark_experiment.pdf
    - PPT format: [presentation.ppt](./introduction/[format]leveldb_study_ppt.pptx)
</br>

* Upload your experiment document at [DKU-StarLab/leveldb-wiki](https://github.com/DKU-StarLab/leveldb-wiki) repository through pull reqeust.
    - Pull request until **Tuesday, 8/2 11AM**.
* Check previous study presentation files.
    - https://github.com/DKU-StarLab/RocksDB_Festival

## Topics / Benchmarks / Options
|No|Topic|Benchmarks|Options|Result|
|--|--|--|--|--|
|1|WAL/Manifest|--disable_wal</br>--wal_bytes_per_sync|fillseq/random</br>readrandom|PPT
|2|Memtable|--write_buffer_size</br>--max_file_size|fillseq/random</br>readrandom|PPT
|3|Compaction|--base_background_compactions</br>--compaction_style|fillseq/random</br>readrandom|PPT
|4|SSTable|--write_buffer_size</br>--max_file_size</br>--block_size|fillseq/random</br>readseq/random</br>seekrandom|PPT
|5|Bloom Filter|--bloom_bits|readhot/random<br>seekrandom|PPT
|6|Cache|--cache_size</br>--block_size|readhot/random</br>seekrandom|PPT

## 5 Steps of Experiment
1. Hypothesis
* What changes will be happen internally, if option changes?
* How will internal changes affect the metrics?
* What result and graph do you expect?
</br>
2. Design
* Do the simplest and smallest experiment that can test your hypothesis.
* Do not experiment with multiple independent variables at once from the beginning.
* Do not let uncontrolled variables ruin your experiment.  
* Variables
    1. Independent: Options, Benchmarks, # of KV pairs
    2. Dependent: Metrics(Throughput, Latency, WAF/SAF/RAF)
    3. Controlled: Env, Page Cache, Compile option, existing db, compression ratio, bloomfilter bit
</br>
3. Run Experiment
* Please use shell/python script.
    - echo, redirection, pyplot, ...
* Do not change experiment enviornment.
</br>
4. Result and Discussion
* Draw graphs and figures that explain experiments.
* Verify your idea and hypothesis with result.
* Explain why your hypothesis is correct or not.
</br>
5. Presentation
* Present your experiments in 10 minutes.
* Write a document that explains your experiment.
    - git-book








 