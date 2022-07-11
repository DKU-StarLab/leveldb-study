# LevelDB Study
2022 [DKU System Software Lab](https://sslab.dankook.ac.kr/) LevelDB Study

## Goals
* [Analyze LevelDB.](./analysis/README.md)
* [Write your LevelDB analysis into a git-book.](https://dku-starlab.gitbook.io/leveldb-analysis/)
* [Optimize LevelDB for real-world workload.](./optimization/README.md)
* [Implement new ideas in LevelDB.](./new_implementation/README.md)
* Write a research (undergraduate) paper on what you learned.

## Members
* Student: [Hansu Kim](https://github.com/gillyongs), [Isu Kim](https://github.com/gooday2die), [Ja-young Cho](https://github.com/cho-ja-young), [Jongki Park](https://github.com/JongKI-PARK), [Sanghyun Cho](https://github.com/Cho-SangHyun), [Sangwoo Kang](https://github.com/aarom416), [Seoyoung Cho](https://github.com/ChoSeoyoung), [Seyeon Park ](https://github.com/SayOny), [Subin Hong](https://github.com/sss654654), [Suhwan Shin](https://github.com/Student5421), [Taegyu Cho ](https://github.com/HASHTAG-YOU), [Wongil Kim](https://github.com/Wongilk), [Zhao Guangxun](https://github.com/ErosBryant), [Zhu Yongjie](https://github.com/arashio1111)
1. Memtable:
2. WAL/Manifest:
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
|[Week 1](./lntroduction/)|22-07-05|LevelDB Introduction 1 ([PPT](https://github.com/DKU-StarLab/leveldb-study/blob/e225f52ffc254a3b49aaf86a20eadfeb027a0c9b/lntroduction/%5Bweek%201%5D%20leveldb%20study%20Introduction%201.pdf))|What is key-value store? </br> Why open-source?|
|[Week 2](./lntroduction/)|22-07-12|LevelDB Introduction 2 ([PPT](https://github.com/DKU-StarLab/leveldb-study/blob/e225f52ffc254a3b49aaf86a20eadfeb027a0c9b/lntroduction/%5Bweek%202%5D%20leveldb%20study%20Introduction%202.pdf))|LevelDB basics </br>LevelDB install & db_bench|
|Week 3|22-07-19|LevelDB Analysis 1|Analysis tool|
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
* Documents
  - [LevelDB library documentation](https://github.com/google/leveldb/blob/main/doc)
  - [RocksDB WiKi](https://github.com/facebook/rocksdb/wiki)
  - [Fenggang Wu, 『LevelDB Introduction』, University of Minnesota CSci5980, 2016](https://www-users.cselabs.umn.edu/classes/Spring-2020/csci5980/index.php?page=presentation)
  - [rjl493456442, 『leveldb-handbook (CHS)』, 2022](https://leveldb-handbook.readthedocs.io/zh/latest/)
  - [木鸟杂记, Talking about LevelDB data structure (CHS), 2021 ](https://www.qtmuniao.com/categories/%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB/)
  - [rsy56640, 『read_and_analyse_levelDB (CHS)』](https://github.com/rsy56640/read_and_analyse_levelDB/tree/master/reference)
  - [FOCUS,『LevelDB fully parsed (CHS)』](https://www.zhihu.com/column/c_1258068131073183744)
  - [bloomingTony, 『Research on Network and Storage Technology(CHS)』](https://www.zhihu.com/column/c_180212366)
* Lecture
  - [Jongmoo Choi, 『Key-Value DB for Unstructured data (KOR)』, 2021](https://mooc.dankook.ac.kr/courses/61d537a3b6b71841651153b3)
  - [GL Tech Tutorials, 『LSM trees』, 2021](https://youtube.com/playlist?list=PLRNjlOFk-f0lJJZVoSAmcwZgVtp64tXaX)
  - [Wei Zhou, LevelDB YouTube playlist](https://youtube.com/playlist?list=PLaCN8MYUet0tR1xn5d8ZtCumHKtP6Wkeq)
* Real-World Workload
  - [Twitter cache trace](https://github.com/twitter/cache-trace)
  - [Facebook ZippyDB](https://github.com/facebook/rocksdb/wiki/RocksDB-Trace%2C-Replay%2C-Analyzer%2C-and-Workload-Generation)
* Analysis Tools
  - [understand](https://licensing.scitools.com/download)
  - [uftrace](https://github.com/namhyung/uftrace)
* Previous Study
  - [DKU RocksDB Festival, 2021](https://github.com/DKU-StarLab/RocksDB_Festival)
