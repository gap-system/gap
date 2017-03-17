#############################################################################
##
#W  read.tst                  GAP library                 Chris Jefferson
##
##
#Y  Copyright (C)  2014,  GAP Group
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
gap> STOP_TEST( "read.tst", 1);
