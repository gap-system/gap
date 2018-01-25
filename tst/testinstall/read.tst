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
gap> READ_ALL_COMMANDS(InputTextString(""), false);
[  ]
gap> READ_ALL_COMMANDS(InputTextString("a := (3,7,1); y := a^(-1);"), false);
[ [ true, (1,3,7), false ], [ true, (1,7,3), false ] ]
gap> READ_ALL_COMMANDS(InputTextString("Unbind(x); z := x;"), false);
Error, Variable: 'x' must have a value
[ [ true,, false ], [ false ] ]
gap> p := READ_ALL_COMMANDS(InputTextString("1;;2;3;;4;5;6;7;8;9;10;11;12;13;14;;15;16;17;18;"), false);;
gap> p;
[ [ true, 1, true ], [ true, 2, false ], [ true, 3, true ], 
  [ true, 4, false ], [ true, 5, false ], [ true, 6, false ], 
  [ true, 7, false ], [ true, 8, false ], [ true, 9, false ], 
  [ true, 10, false ], [ true, 11, false ], [ true, 12, false ], 
  [ true, 13, false ], [ true, 14, true ], [ true, 15, false ], 
  [ true, 16, false ], [ true, 17, false ], [ true, 18, false ] ]
gap> STOP_TEST( "read.tst", 1);
