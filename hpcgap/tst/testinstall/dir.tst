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
gap> ForAll([DirectoryHome, DirectoryDesktop,DirectoryCurrent],
>           x -> (IsDirectoryPath(x()) and IsDirectory(x())) );
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
gap> STOP_TEST("dir.tst", 1);
