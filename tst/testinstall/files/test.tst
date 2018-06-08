gap> START_TEST("test.tst");
gap> dir := DirectoriesLibrary("tst/testinstall/files");;
gap> Test(Filename(dir,"empty.txt"));
#I  Test: File does not contain any tests!
true
gap> Test(Filename(dir,"invalidtestfile.txt"));
Error, Invalid data at line 7 of test file
gap> Test(Filename(dir, "tinytest.txt"));
true
gap> STOP_TEST("test.tst");
