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

#
# string streams
#

# output
gap> res:="";;
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

#
gap> STOP_TEST( "streams.tst", 1);
