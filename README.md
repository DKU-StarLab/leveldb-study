# LevelDB Study
2022 [DKU System Software Lab](https://sslab.dankook.ac.kr/) LevelDB Study

## Goals
* [Study LevelDB.](./introduction/README.md)
* [Analyze LevelDB](./analysis/README.md)
* Write LevelDB analysis document.
  * [leveldb-wiki](https://github.com/DKU-StarLab/leveldb-wiki)
  * [leveldb-wiki-kor](https://github.com/DKU-StarLab/leveldb-wiki-kor)
* [Tuning Contest: YCSB](./tuning/README.md)
* Write a research paper on what you learned.

## Members
* Student:
  - 1.WAL/Manifest: [Isu Kim](https://github.com/gooday2die), [Seyeon Park ](https://github.com/SayOny), [Suhwan Shin](https://github.com/Student5421)
  - 2.Memtable: [Taegyu Cho ](https://github.com/HASHTAG-YOU), [Zhu Yongjie](https://github.com/arashio1111)
  - 3.Compaction: [Sangwoo Kang](https://github.com/aarom416), [Seoyoung Park](https://github.com/seo-0), [Zhao Guangxun](https://github.com/ErosBryant)
  - 4.SSTable: [Jongki Park](https://github.com/JongKI-PARK), [Sanghyun Cho](https://github.com/Cho-SangHyun)
  - 5.Bloom Filter: [Hansu Kim](https://github.com/gillyongs)
  - 6.Cache: [Seungwon Ha](https://github.com/ha-seungwon), [Subin Hong](https://github.com/sss654654)
* Assistant: [Min-guk Choi](https://github.com/korea-choi)
* Senior Assistant: [Sounghyoun Lee](https://github.com/shl812), [Hojin Shin](https://github.com/shinhojin)
* Professor: [Jongmoo Choi](http://embedded.dankook.ac.kr/~choijm/), [Seehwan Yoo](https://sites.google.com/site/dkumobileos/members/seehwanyoo)

## Schedule
* Date: Every Tuesday in July, August
* Time: 14:00 ~ 16:00
* Place: Dankook University Software ICT Hall Room 307

|No|Date|Contents|Details|
|--|--|--|--|
Week 1|22-07-05|[Introduction 1](./introduction/README.md)| What is key-value store? </br> Why open-source?|
Week 2|22-07-12|[Introduction 2](./introduction/README.md)|LevelDB Basics </br>LevelDB Install</br>[Homework](https://github.com/DKU-StarLab/leveldb-study/issues/6#issue-1302876982)|
Week 3|22-07-19|[Introduction 3](./introduction/README.md)|Analysis Tools</br>[Homework Solutions](./homework/README.md)|
|Week 4|22-07-26|[Benchmark Experiment](./benchmarks/README.md)|LevelDB db_bench|
|Week 5</br>(zoom)|22-08-02|[Analysis 1](./analysis/README.md)|
|Week 6|22-08-09|[Analysis 2](./analysis/README.md)|
|Week 7|22-08-16|[Tuning Contest](./tuning/README.md)|YCSB|
|Week 8|22-08-23|[Analysis 3](./analysis/README.md)|
|Week 9|22-08-30|[Analysis 4](./analysis/README.md)|
|Week 10|22-09-11|Wrap up|Photo, Dinner (삼겹살)|

## Photo
<img src="./photo/photo.png">

## Poster (KOR)
<img src="./photo/poster_kor.png" width="50%">

## References
* Documents
  - [LevelDB Document](https://github.com/google/leveldb/blob/main/doc)
  - [RocksDB Wiki](https://github.com/facebook/rocksdb/wiki)
  - [Jongmoo Choi,『Key-Value Store: Database for Unstructured Bigdata』, 2021](https://github.com/DKU-StarLab/leveldb-study/blob/761b550973ab6d1e88189190e66c0ee19a52aa12/introduction/Jongmoo%20Choi,%20Key-Value%20Store%20-%20Database%20for%20Unstructured%20Bigdata,%202021.pdf)
  - [Fenggang Wu, 『LevelDB Introduction』, 2016](https://www-users.cselabs.umn.edu/classes/Spring-2020/csci5980/index.php?page=presentation)
  - [rjl493456442, 『leveldb-handbook (CHS)』, 2022](https://leveldb-handbook.readthedocs.io/zh/latest/)
  - [rsy56640, 『read_and_analyse_levelDB (CHS)』](https://github.com/rsy56640/read_and_analyse_levelDB/tree/master/reference)
  - [FOCUS,『LevelDB fully parsed (CHS)』](https://www.zhihu.com/column/c_1258068131073183744)
  - [bloomingTony, 『Research on Network and Storage Technology(CHS)』](https://www.zhihu.com/column/c_180212366)
  - [木鸟杂记,『Talking about LevelDB data structure (CHS)』, 2021 ](https://www.qtmuniao.com/categories/%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB/)
* Lecture
  - [Jongmoo Choi, 『Key-Value Store: Database for Unstructured Bigdata (KOR)』,  2021](https://mooc.dankook.ac.kr/courses/61d537a3b6b71841651153b3)
  - [GL Tech Tutorials, 『LSM trees』, 2021](https://youtube.com/playlist?list=PLRNjlOFk-f0lJJZVoSAmcwZgVtp64tXaX)
  - [Wei Zhou, LevelDB YouTube playlist](https://youtube.com/playlist?list=PLaCN8MYUet0tR1xn5d8ZtCumHKtP6Wkeq)
* Analysis Tools
  - [GDB](https://www.sourceware.org/gdb/)
  - [Understand](https://licensing.scitools.com/download)
  - [Uftrace](https://github.com/namhyung/uftrace)
* Previous Study
  - [DKU RocksDB Festival, 2021](https://github.com/DKU-StarLab/RocksDB_Festival)
  

## File
- [presentation format](./file/%5Bformat%5Dleveldb_study_ppt.pptx)
- [kcc research paper format](./file/%5Bformat%5Dresearch_paper(KCC).hwp)
- [leveldb db_bench script](./file/bench_script.sh)
- [leveldb uftrace script](./file/uftrace_script.sh)
