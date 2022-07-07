# LevelDB Study
2022 [DKU System Software Lab](https://sslab.dankook.ac.kr/) LevelDB Study

## Goals
* [Analyze LevelDB.](./analysis/README.md)
* [Write your LevelDB analysis into a git-book.](https://dku-starlab.gitbook.io/leveldb-analysis/)
* [Optimize LevelDB for real-world workload.](./optimization/README.md)
* [Implement new ideas in LevelDB.](./new_implementation/README.md)
* Write a research (undergraduate) paper on what you learned.

## Members
* Student: [Hansu Kim](https://github.com/gillyongs), [Isu Kim](https://github.com/gooday2die), [Ja-young Cho](https://github.com/cho-ja-young), [Jongki Park](https://github.com/JongKI-PARK), [Sanghyun Cho](https://github.com/Cho-SangHyun), [Sangwoo Kang](https://github.com/aarom416), [Seoyoung Cho](https://github.com/ChoSeoyoung), [Seyeon Park ](https://github.com/SayOny), [Subin Hong](https://github.com/sss654654), [Suhwan Shin](https://github.com/Student5421), [Taegyu Cho ](https://github.com/HASHTAG-YOU), [Wongil Kim](https://github.com/Wongilk), [Wonjun Jung](https://github.com/Seoulice), [Zhao Guangxun](https://github.com/ErosBryant), [Zhu Yongjie](https://github.com/arashio1111)
1. Memtable:
2. WAL:
3. Compaction:
4. SSTable:
5. Bloom Filter:
6. Cache:
* Assistant: [Min-guk Choi](https://github.com/korea-choi)
* Senior Assistant: [Sounghyoun Lee](https://github.com/shl812), [Hojin Shin](https://github.com/shinhojin)
* Professor: [Jongmoo Choi](http://embedded.dankook.ac.kr/~choijm/), [Seehwan Yoo](https://sites.google.com/site/dkumobileos/members/seehwanyoo)

## Schedule
* Date: Every Tuesday in July, August
* Time: 14:00 ~ 16:00
* Place: Dankook University Software ICT Hall Room 307

|No|Date|Contents||
|--|--|--|--|
|Week 1|22-07-05|LevelDB Introduction 1 ([PPT](https://github.com/DKU-StarLab/leveldb-study/blob/f1e17898ca0cc318f2d3301a68d165f6464aed8e/lntroduction/leveldb%20Introduction%201%20upload.pdf))|What is key-value store? </br> Why open-source?|
|Week 2|22-07-12|LevelDB Introduction 2|LevelDB basics </br>Analysis tools|
|Week 3|22-07-19|LevelDB Analysis 1||
|Week 4|22-07-26|LevelDB Analysis 2||
|Week 5|22-08-02|LevelDB Analysis 3||
|Week 6|22-08-09|LevelDB Analysis 4||
|Week 7|22-08-16|Real-World Workload Optimization|YCSB</br>Twitter Trace|
|Week 8|22-08-23|New Idea Implementation 1||
|Week 9|22-08-30|New Idea Implementation 2|Write (undergraduate) research paper|

## Photo
<img src="./photo/photo.png">

## Poster (KOR)
<img src="./photo/poster_kor.png" width="50%">

## References
* Lecture
  - [Jongmoo Choi, 『Key-Value DB for Unstructured data』, 2021](https://mooc.dankook.ac.kr/courses/61d537a3b6b71841651153b3)
  - [GL Tech Tutorials, 『LSM trees』, 2021](https://youtube.com/playlist?list=PLRNjlOFk-f0lJJZVoSAmcwZgVtp64tXaX)
  - [Wei Zhou, LevelDB YouTube playlist](https://youtube.com/playlist?list=PLaCN8MYUet0tR1xn5d8ZtCumHKtP6Wkeq)
* Documents
  - [LevelDB library documentation](https://github.com/google/leveldb/blob/main/doc/index.md)
  - [RocksDB WiKi](https://github.com/facebook/rocksdb/wiki)
  - [Fenggang Wu, 『LevelDB Introduction』, Universuty of Minnesota CSci5980, 2016](https://www-users.cselabs.umn.edu/classes/Spring-2020/csci5980/index.php?page=presentation)
  - [rjl493456442, 『leveldb-handbook』, 2022](https://github.com/rjl493456442/leveldb-handbook)
  - [rsy56640, 『read_and_analyse_levelDB](https://github.com/rsy56640/read_and_analyse_levelDB)
* Real-World Workload
  - [Twitter cache trace](https://github.com/twitter/cache-trace)
  - [Facebook ZippyDB](https://github.com/facebook/rocksdb/wiki/RocksDB-Trace%2C-Replay%2C-Analyzer%2C-and-Workload-Generation)
* Analysis Tools
  - [understand](https://licensing.scitools.com/download)
  - [uftrace](https://github.com/namhyung/uftrace)
* Previous Study
  - [DKU RocksDB Festival, 2021](https://github.com/DKU-StarLab/RocksDB_Festival)
