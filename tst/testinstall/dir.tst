#@local badbase,baddirbase,base,dirTest,dirbase,dirs,subdir,tmpdir
gap> START_TEST("dir.tst");
gap> base := Filename( DirectoriesLibrary( "tst" ), "example-dir");;
gap> dirbase := Directory(base);;
gap> badbase := Concatenation(base,"cheeseababababab");;
gap> baddirbase := Directory(badbase);;
gap> dirs := [base, dirbase, badbase, baddirbase];;
gap> List(dirs, IsDirectoryPath);
[ true, true, false, false ]
gap> List(dirs, IsDirectory);
[ false, true, false, true ]
gap> DirectoryHome() = Directory("~") or ARCH_IS_WINDOWS();
true
gap> IsDirectoryPath(DirectoryCurrent());
true
gap> IsDirectory(DirectoryCurrent());
true
gap> dirTest := Concatenation(base,"/dir-test");;
gap> SortedList(DirectoryContents(dirTest));
[ ".", "..", "A", "B", "C", "D" ]
gap> SortedList(DirectoryContents(Directory(dirTest)));
[ ".", "..", "A", "B", "C", "D" ]
gap> if ARCH_IS_WINDOWS() then
> Print(ExternalFilename(Directory("/illegal"), "filename") = "\\illegal\\filename",
>       ExternalFilename([Directory("/illegal")], "filename") = fail,
>       ExternalFilename(Directory("/proc/cygdrive/C/"), "filename") = "C:\\filename",
>       ExternalFilename(Directory("/cygdrive/Q/"), "filename") = "Q:\\filename","\n");
> else
> Print(ExternalFilename(Directory("/illegal"), "filename") = "/illegal/filename",
>       ExternalFilename([Directory("/illegal")], "filename") = fail,
>       ExternalFilename(Directory("/proc/cygdrive/C/"), "filename") = "/proc/cygdrive/C/filename",
>       ExternalFilename(Directory("/cygdrive/Q/"), "filename") = "/cygdrive/Q/filename","\n");
> fi;
truetruetruetrue

# CreateDir and RemoveDir accept strings and directory objects
gap> tmpdir := TmpDirectory();;
gap> subdir := Concatenation(tmpdir, "/subdir");;
gap> CreateDir(Directory(subdir));
true
gap> IsDirectoryPath(subdir);
true
gap> CreateDir(Directory(subdir));
fail
gap> RemoveDir(Directory(subdir));
true
gap> IsDirectoryPath(subdir);
false
gap> RemoveDir(Directory(subdir));
fail
gap> CreateDir(subdir);
true
gap> RemoveDir(subdir);
true
gap> RemoveDir(Directory(tmpdir));
true
gap> IsDirectoryPath(tmpdir);
false
gap> CreateDir(fail);
Error, CREATE_DIR: <filename> must be a string (not the value 'fail')
gap> RemoveDir(fail);
Error, REMOVE_DIR: <filename> must be a string (not the value 'fail')
gap> STOP_TEST("dir.tst");
