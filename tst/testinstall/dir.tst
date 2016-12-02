gap> START_TEST("dir.tst");
gap> base := Filename( DirectoriesLibrary( "tst" ), "example-dir");;
gap> dirbase := Directory(base);;
gap> badbase := Concatenation(base,"cheeseababababab");;
gap> baddirbase := Directory(badbase);;
gap> file := Filename( DirectoriesLibrary( "tst" ), "example.txt");;
gap> dirs := [base, dirbase, badbase, baddirbase, file];;
gap> List(dirs, IsDirectoryPath);
[ true, true, fail, fail, false ]
gap> List(dirs, IsDirectory);
[ false, true, false, true, false ]
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
gap> STOP_TEST("dir.tst", 270000);
