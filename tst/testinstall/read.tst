#############################################################################
##
#W  read.tst                  GAP library                 Chris Jefferson
##
##
#Y  Copyright (C)  2014,  GAP Group
##
##  To be listed in testinstall.g
##
gap> START_TEST("read.tst");
gap> name := Filename( DirectoriesLibrary("tst"), "example.txt" );;
gap> x := InputTextFile(name);;
gap> ReadLine(x);
"hello\n"
gap> ReadLine(x);
"goodbye\n"
gap> ReadLine(x);
"i like pies\n"
gap> ReadLine(x);
fail
gap> ReadLine(x);
fail
gap> SeekPositionStream(x, 0);
true
gap> ReadLine(x);
"hello\n"
gap> ReadLine(x);
"goodbye\n"
gap> ReadLine(x);
"i like pies\n"
gap> ReadLine(x);
fail
gap> SeekPositionStream(x, 2);
true
gap> ReadLine(x);
"llo\n"
gap> ReadLine(x);
"goodbye\n"
gap> SeekPositionStream(x, 3);
true
gap> ReadAll(x);
"lo\ngoodbye\ni like pies\n"
gap> x := InputTextString("hello\ngoodbye\ni like pies\n");;
gap> ReadLine(x);
"hello\n"
gap> ReadLine(x);
"goodbye\n"
gap> ReadLine(x);
"i like pies\n"
gap> ReadLine(x);
fail
gap> ReadLine(x);
fail
gap> SeekPositionStream(x, 0);
true
gap> ReadLine(x);
"hello\n"
gap> ReadLine(x);
"goodbye\n"
gap> ReadLine(x);
"i like pies\n"
gap> ReadLine(x);
fail
gap> SeekPositionStream(x, 2);
true
gap> ReadLine(x);
"llo\n"
gap> ReadLine(x);
"goodbye\n"
gap> SeekPositionStream(x, 3);
true
gap> ReadAll(x);
"lo\ngoodbye\ni like pies\n"
gap> x := StringFile(Filename( DirectoriesLibrary("tst"), "example.txt" ));;
gap> ReplacedString(x, "\r\n", "\n");
"hello\ngoodbye\ni like pies\n"
gap> dir := DirectoryTemporary();;
gap> FileString( Filename(dir, "tmp1"), "Hello, world!");
13
gap> StringFile( Filename(dir, "tmp2"));
fail
gap> StringFile( Filename(dir, "tmp1"));
"Hello, world!"
gap> FileString( Filename(dir, "test.g.gz"), "\037\213\b\b0,\362W\000\ctest.g\0003\3246\264\346\<\000\225\307\236\324\005\000\000\000" );
32
gap> StringFile( Filename(dir, "test.g") ) = "1+1;\n" or ARCH_IS_WINDOWS(); # works only when Cygwin installed with gzip
true
gap> STOP_TEST( "read.tst", 220000);
