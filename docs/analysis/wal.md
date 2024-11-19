## WAL

This document provides an explanation of WAL (Write Ahead Log).

### Index
- [WAL](#wal): Overview of WAL
- [Functions](#functions): Description of WAL/MANIFEST related functions  
  - Since MANIFEST and WAL share many common functions, they are documented together in the WAL section.
- [ETC](#etc): Additional research findings

### WAL

#### Introduction
LevelDB does not have an option to enable/disable WAL. To activate or deactivate WAL, you need to either use RocksDB or modify LevelDB's source code.

LevelDB uses WAL (Write Ahead Log) when writing data. WAL records logs of all transactions in LevelDB and is used to prevent transaction loss.

In LevelDB, data is temporarily stored in the Memtable first. However, since Memtable exists only in memory, data stored in Memtable can be lost if the system terminates abnormally or encounters an error. Analysis of this is detailed in the [ETC](#etc) section.

To prevent data loss, LevelDB stores transactions in a separate log file, which is the WAL.

#### Format
LevelDB's WAL is stored as a `.log` file in binary format. The WAL file stores two things:
- Transaction header
- Actual transaction data (payload)

##### Header
The WAL header is stored in the following format:

<img src="https://user-images.githubusercontent.com/49092508/190959632-08d86d79-d24c-4d50-bbf6-55fccb829556.png" width="700"/>

Header components:
1. CRC Checksum (4byte)
2. Data size (2byte)
3. Record Type (1byte)

##### Payload
After the WAL header, the payload is stored in the following format.

> Example: When PUT-ting 3 pairs of Key-Value data like {"A": "Hello world!", "B": "Good bye world!", "C": "I am hungry"}, the WAL file looks like this:

<img src="https://user-images.githubusercontent.com/49092508/190959530-2832a72d-8f65-4207-9ca1-2fa227d17acb.png" width="700"/>

### Functions
Here are the findings from analyzing WAL and MANIFEST related functions.

The `log::reader` file contains the `Reader` class and several functions.

<img src="https://github.com/user-attachments/assets/80cb5290-83ef-4ac2-817c-a4957a5c4d84" width="700"/>

Analysis focused on the `bool Reader::ReadRecord(Slice* record, std::string* scratch)` function.

<img src="https://github.com/user-attachments/assets/d0f7438f-2498-4f03-a629-846d74efbc38" width="700"/>

- The `ReadRecord()` function finds the initial block position (`SkipToInitialBlock()`), and runs a `while` loop to get return values from `ReadPhysicalRecord()` function to read data.
- This function reads the block's `record type` and handles any errors. The function terminates when it reaches the end of the block.
- If the data spans multiple blocks, it adds data to `scratch` and transfers everything to `record` at the last block.
- The `in_fragmented_record` variable is used to determine if data spans multiple blocks.

#### log::Writer::AddRecord
Receives `slice` type data and writes it to WAL. Calls `log::Writer::EmitPhysicalRecord` function for writing.

#### log::Writer::EmitPhysicalRecord
Receives `slice` type data, creates a header, and writes to file. Adds the header and writes to `.log` file through `PosixWritableFile::Append()`.

#### PosixWritableFile::Append()
Implementation of `WritableFile` in POSIX environment. WAL files are written through `PosixWritableFile`. Records `slice` data to buffer and writes to file when buffer is full.

### ETC
Includes experimental results of data loss with WAL enabled/disabled. Since WAL options are only supported in RocksDB, experiments were conducted using RocksDB.

#### Summary
Experiments were conducted in the following situation:
- After writing data with PUT command, forcefully terminate process (`SIGINT`)
- Check for data loss before termination

#### Design
The code used in experiments can be found [here](https://github.com/gooday2die/WAL-Testing).

#### Scenarios
Experiments were conducted with 4 scenarios:

|            | WAL Enabled | Manual Flush |
|------------|------------|--------------|
| Scenario 1 | X          | X            |
| Scenario 2 | X          | O            |
| Scenario 3 | O          | X            |
| Scenario 4 | O          | O            |

#### Results
Results are as follows:

| Scenario  | Data Integrity                              |
|-----------|---------------------------------------------|
| Scenario 1 | Lost all data in Memtable                  |
| Scenario 2 | Lost some data before Manual Flush         |
| Scenario 3 | Preserved all data                         |
| Scenario 4 | Preserved all data                         |

Additional experiments used these conditions:
- Total 1,000,000 PUT commands executed
- [0] Flush every 1,000, [1] Flush every 10,000

| Type                          | Speed   | Data Integrity                                 |
|-------------------------------|---------|------------------------------------------------|
| WAL Disabled                   | 1.843s  | Lost all data                                 |
| WAL Enabled                    | 3.604s  | Preserved all data                            |
| Manual Flush [0] & WAL Disabled| 39.128s | Lost some data                                |
| Manual Flush [1] & WAL Disabled| 5.611s  | Lost some data                                |

### Bottom line
- Enabling WAL ensures data preservation
- Disabling WAL risks significant data loss
- Using Manual Flush with WAL disabled can preserve some data
