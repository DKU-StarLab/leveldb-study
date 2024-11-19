## MANIFEST

`MANIFEST` handles the organization of `VersionSet` and `VersionEdit` into files. It is stored with names like `MANIFEST-000000`.

The MANIFEST filename changes during LevelDB operations. The `CURRENT` file contains the name of the MANIFEST file that LevelDB will use in the current session.

### VersionSet and VersionEdit

Both `VersionSet` and `VersionEdit` manage version-related information.

`VersionSet` and `VersionEdit` are friend classes to each other.

Each class has one specific function for writing to and using the MANIFEST file:

- **`VersionSet::LogAndApply`**: Prepares version data for storage in MANIFEST and ultimately writes the data using `VersionEdit::EncodeTo` to save it to the MANIFEST file.

![image](https://user-images.githubusercontent.com/49092508/190644040-e60217d7-ca32-4419-8a32-b8034aa9909d.png)

- **`VersionEdit::EncodeTo`**: Writes the actual data in binary format.

![image](https://user-images.githubusercontent.com/49092508/190644269-23463bc4-27e8-4e4c-955c-abfa4df476cd.png)

### During DB Creation

![image](https://user-images.githubusercontent.com/49092508/190642300-5b4b12a4-7c4a-4ec0-af74-a339f5a87124.png)

When initially creating the DB, the MANIFEST file is generated through the above process. Initially, a `VersionEdit` is created with the following values and written to the `MANIFEST-000001` file:

- **`comparator`**: `"leveldb.BytewiseComparator"`
- **`log_number`**: `0`
- **`next_file_number`**: `2`
- **`last_sequence`**: `0`

These contents are then recorded through the `log::Writer` function.

### During DB Shutdown

![image](https://user-images.githubusercontent.com/49092508/190645030-4865a546-b26b-4702-8bd3-06d1d31f41a0.png)

When LevelDB shuts down, `~DBImpl` is called. This deletes the existing `VersionSet` and writes the data about the current version to the MANIFEST file. This written MANIFEST file allows LevelDB to recover the previous version when it starts up next time.
