#@local dir,fname,file,line,stream,tmpdir,res
gap> START_TEST("streams.tst");

#
gap> tmpdir := DirectoryTemporary();;
gap> fname := Filename(tmpdir, "data");;

#
# Test input/out text stream
#

# write initial data
gap> stream := OutputTextFile( fname, false );;
gap> PrintTo( stream, "1");
gap> AppendTo( stream, "2");
gap> PrintTo( stream, "3");
gap> CloseStream(stream);
gap> stream;
closed-stream

# verify it
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream);
"123"
gap> CloseStream(stream);
gap> stream;
closed-stream

# partial reads
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream, 2);
"12"
gap> CloseStream(stream);
gap> stream;
closed-stream

# too long partial read
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream, 5);
"123"
gap> CloseStream(stream);
gap> stream;
closed-stream

# error partial read
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream, -1);
Error, ReadAll: negative limit is not allowed
gap> CloseStream(stream);
gap> stream;
closed-stream

# append to initial data
gap> stream := OutputTextFile( fname, true );;
gap> PrintTo( stream, "4");
gap> CloseStream(stream);

# verify it
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream);
"1234"
gap> CloseStream(stream);
gap> stream;
closed-stream

# overwrite initial data
gap> stream := OutputTextFile( fname, false );;
gap> PrintTo( stream, "new content");
gap> CloseStream(stream);

# verify it
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream);
"new content"
gap> CloseStream(stream);
gap> stream;
closed-stream

# ReadAll with length limit
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream, 3);
"new"
gap> CloseStream(stream);

# test PrintFormattingStatus
gap> stream := OutputTextFile( fname, false );;
gap> PrintFormattingStatus(stream);
true
gap> PrintTo( stream, "a very long line that GAP is going to wrap at 80 chars by default if we don't do anything about it\n");
gap> CloseStream(stream);
gap> StringFile(fname);
"a very long line that GAP is going to wrap at 80 chars by default if we don't\
 \\\ndo anything about it\n"
gap> stream := OutputTextFile( fname, false );;
gap> SetPrintFormattingStatus(stream, false);
gap> PrintFormattingStatus(stream);
false
gap> PrintTo( stream, "a very long line that GAP is going to wrap at 80 chars by default if we don't do anything about it\n");
gap> CloseStream(stream);
gap> StringFile(fname);
"a very long line that GAP is going to wrap at 80 chars by default if we don't\
 do anything about it\n"

#
# string streams
#

# output
gap> res:="abc";;
gap> stream := OutputTextString(res, true);
OutputTextString(3)
gap> res;
"abc"
gap> PrintTo( stream, "1" );
gap> res;
"abc1"
gap> stream := OutputTextString(res, false);
OutputTextString(0)
gap> res;
""
gap> stream := OutputTextString(res, true);
OutputTextString(0)
gap> PrintTo( stream, "1");
gap> AppendTo( stream, "2");
gap> PrintTo( stream, "3\n567\n");
gap> PrintTo( stream, "some line\n");
gap> PrintTo( stream, "another line\n", "last line without newline");
gap> CloseStream(stream);
gap> res;
"123\n567\nsome line\nanother line\nlast line without newline"
gap> OutputTextString("abc");
Error, Usage OutputTextString( <string>, <append> )
gap> OutputTextString(Immutable("abc"), true);
Error, <str> must be mutable

# input
gap> stream := InputTextString( res );
InputTextString(0,56)
gap> ReadLine(stream);
"123\n"
gap> ReadAllLine(stream);
"567\n"
gap> stream;
InputTextString(8,56)
gap> ReadAllLine(stream, true);
"some line\n"
gap> ReadAllLine(stream, line -> 0 < Length(line) and line[Length(line)] = '\n');
"another line\n"
gap> ReadAllLine(stream, false, line -> 0 < Length(line) and line[Length(line)] = '\n');
"last line without newline"
gap> ReadAllLine(stream);
fail
gap> stream := InputTextString( res );
InputTextString(0,56)
gap> ReadAll(stream, 3);
"123"
gap> ReadAll(stream, -1);
Error, ReadAll: negative limit is not allowed
gap> ReadAll(stream, 0);
""
gap> ReadAll(stream, 1000);
"\n567\nsome line\nanother line\nlast line without newline"
gap> SeekPositionStream(stream, -1);
fail
gap> SeekPositionStream(stream, 1000);
fail
gap> SeekPositionStream(stream, 1);
true
gap> ReadLine(stream);
"23\n"

# Test reading longer file
gap> dir := DirectoriesLibrary("tst/testinstall/files");;
gap> fname := Filename(dir, "testdata");;
gap> file := InputTextFile( fname );;
gap> repeat
>  line := ReadLine( file );
> until line = fail;

# Invalid files
gap> PrintTo("/", "out");
Error, PrintTo: cannot open '/' for output
gap> OutputTextFile("/", true);
fail

# Assume this file does not exist
gap> InputTextFile("/filewhichdoesnotexist/lspdsiodfsjfdsjofdsjkfd/fdsjkfds");
fail

# some input validation
gap> PrintTo(fail);
Error, first argument must be a filename or output stream
gap> AppendTo(fail);
Error, first argument must be a filename or output stream

# None stream
gap> stream := OutputTextNone();
OutputTextNone()
gap> PrintObj(stream); Print("\n");
OutputTextNone()
gap> WriteAll(stream, "abc");
true
gap> WriteByte(stream, 3);
true
gap> WriteByte(stream, 300);
Error, <byte> must an integer between 0 and 255
gap> SetPrintFormattingStatus(stream, fail);
Error, Print formatting status must be true or false

#
gap> STOP_TEST( "streams.tst", 1);
