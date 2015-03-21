This page describes the basic usage of [DiskPacker](DiskPacker.md)

# Introduction #

[DiskPacker](DiskPacker.md) is a Ruby script. At present there are no pre-compiled binaries (exe file for windows etc). One can run it from the source.

You just give the list of directories which has your files or other directories you intend to backup. This is what you get back from [DiskPacker](DiskPacker.md) in return:

  * It will give you optimized list of files and directories for the given type of disk (e.g. CD or DVD).
  * It will also generate the project files for some of the well known disk burning softwares in windows and linux. You can readily use open these projects in the burning softwares to burn the disks. (Currently Infrarecorder, K3B, and Brasero are supported.)
  * [DiskPacker](DiskPacker.md) also generates shell scripts (and batch files for windows) which you can run if you want to delete the files you have just backed up if you want.

# Details #

  * Get the source with this command, of course, you must have installed subversion:  `svn checkout http://diskpacker.googlecode.com/svn/trunk/ diskpacker`
  * `input_paths.txt` is the place where you can fill in the paths to your source directories. (This file is located under folder `lib` inside `diskpacker`)


For instance, on a windows system `input_paths.txt` can be like this:

```
    C:\MY DOCUMENTS\MY DOWNLOADS
    d:/movies
    c:\my documents/my pictures
```

Alternatively, on a linux system

```
    /home/username/Documents
    /home/username/Downloads
```

  * Run `main.rb` with the following command `ruby main.rb`
  * Output files are generated in your temporary directory (`/tmp/disk_packer_output` in case of linux. `%TEMP%\disk_packer_output` in case of windows).

Here is the output tree strucuture. The details are self explanatory.

> ![http://i78.photobucket.com/albums/j101/raguanu/disk_packer_output_tree.png](http://i78.photobucket.com/albums/j101/raguanu/disk_packer_output_tree.png)

  * **Report**
    * A report is generated with information about how many disks you need to backup all your stuff and which files go in which disks, free space in each disks, etc. You can use this info to backup your files manually.
    * You can find the reports under `disk_packer_output` folder. diskpacker\_report\_windows.txt` and `diskpacker\_report\_linux.txt` are generated now in order to accommodate file path differences

  * **Disk Burning Projects**
    * You can find the disk burning projects generated under `disk_packer_output` under corresponding folder for the disk burning application brasero or k3b or infrarecorder.
    * **Windows only** Infrarecorder projects are generated viz., `BACKUP_0.irp`, `BACKUP_1.irp`, etc. You can open these files in Infrarecorder, a open source cd/dvd burner for windows, to burn your CD/DVDs.
    * **Linux only** Brasero projects are generated viz., `brasero_BACKUP_0.xml`, `brasero_BACKUP_1.xml`, etc. You can open these files in Brasero, a open source cd/dvd burner for linux GNOME desktop. It is also now the default burner in Ubuntu.
    * **Linux only** Similarly K3B projects are also generated.

  * **Eraser scripts**
    * You can find the eraser scripts under `disk_packer_output/delete_scripts`.
    * **Windows only** Batch files are generated to erase the files after backup if desired viz., `delete_backup_set_0.bat`, `delete_backup_set_1.bat`, etc. `delete_backup_set_0.bat` has code to erase files that are included in `BACKUP_0.irp` or `id=0` section in `diskpacker_report_windows.txt`
    * **Linux only** Shell scripts are generated to erase the files after backup if desired viz., `delete_backup_set_0.sh`, `delete_backup_set_1.sh`, etc. `delete_backup_set_0.sh` has code to erase files that are included in `brasero_BACKUP_0.xml` or `id=0` section in `diskpacker_report_linux.txt`