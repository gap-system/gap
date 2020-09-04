#@local o,dir,fname,rawfname,checkGzippedFile,stream,str
gap> START_TEST("compressed.tst");
gap> dir := DirectoryTemporary();;
gap> fname := Filename(dir, "test.g.gz");;
gap> rawfname := Filename(dir, "rawtest.g.gz");;

# Let us check when we have written a compressed file by checking the gzip header
# We need raw file access to do this, so we use 'IO'. We stub out this part of the
# test if IO is not loaded
gap> checkGzippedFile := function(fname, expected)
>    local ins, str;
>    if not IsPackageLoaded("IO") then return true; fi;
>    # Use 'ValueGlobal' to avoid warnings about undefined functions
>    ins := ValueGlobal("IO_File")(fname, "r");
>    str := ValueGlobal("IO_Read")(ins, 2);;
>    # All gzipped files should start with these two characters
>    return (str = [CharInt(31),CharInt(139)]) = expected;
>  end;;
gap> str := "hello\ngoodbye\n";;

# Write an uncompressed file
gap> FileString( rawfname, str ) = Length(str);
true

# Write a compressed file, using OutputGzipFile
gap> o := OutputGzipFile(fname, false);;
gap> WriteAll(o, str);
true
gap> CloseStream(o);

# Check file really is compressed
gap> checkGzippedFile(fname, true);
true

# Check file really is NOT compressed
gap> checkGzippedFile(rawfname, false);
true

# Check reading compressed file
gap> StringFile( fname ) = str;
true

# Check reading uncompressed file
gap> StringFile( rawfname ) = str;
true

# Check gz is added transparently
gap> StringFile( Filename(dir, "test.g") ) = str;
true

# Test reading/seeking in a gzip compressed file
gap> stream := InputTextFile(fname);;
gap> ReadLine(stream);
"hello\n"
gap> ReadLine(stream);
"goodbye\n"
gap> ReadLine(stream);
fail
gap> SeekPositionStream(stream, -1);
fail
gap> SeekPositionStream(stream, 0);
true
gap> ReadLine(stream);
"hello\n"
gap> ReadLine(stream);
"goodbye\n"
gap> ReadLine(stream);
fail
gap> SeekPositionStream(stream, 2);
true
gap> PositionStream(stream);
2
gap> ReadLine(stream);
"llo\n"
gap> ReadLine(stream);
"goodbye\n"
gap> SeekPositionStream(stream, 0);
true
gap> ReadAll(stream) = str;
true
gap> SeekPositionStream(stream, 0);
true
gap> PositionStream(stream);
0
gap> ReadAll(stream) = str;
true
gap> CloseStream(stream);

# Test multiple writes
gap> stream := OutputGzipFile( fname, false );;
gap> PrintTo( stream, "1");
gap> AppendTo( stream, "2");
gap> PrintTo( stream, "3");
gap> WriteLine(stream, "abc");
true
gap> CloseStream(stream);
gap> stream;
closed-stream
gap> checkGzippedFile(fname, true);
true

# verify it
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream);
"123abc\n"
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
gap> ReadAll(stream, 10);
"123abc\n"
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
gap> stream := OutputGzipFile( fname, true );;
gap> PrintTo( stream, "4");
gap> CloseStream(stream);

# verify it
gap> stream := InputTextFile( fname );;
gap> ReadAll(stream);
"123abc\n4"
gap> CloseStream(stream);
gap> stream;
closed-stream

# overwrite initial data
gap> stream := OutputGzipFile( fname, false );;
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
gap> stream := OutputGzipFile( fname, false );;
gap> PrintFormattingStatus(stream);
true
gap> PrintTo( stream, "a very long line that GAP is going to wrap at 80 chars by default if we don't do anything about it\n");
gap> CloseStream(stream);
gap> StringFile(fname);
"a very long line that GAP is going to wrap at 80 chars by default if we don't\
 \\\ndo anything about it\n"
gap> stream := OutputGzipFile( fname, false );;
gap> SetPrintFormattingStatus(stream, false);
gap> PrintFormattingStatus(stream);
false
gap> PrintTo( stream, "a very long line that GAP is going to wrap at 80 chars by default if we don't do anything about it\n");
gap> CloseStream(stream);
gap> StringFile(fname);
"a very long line that GAP is going to wrap at 80 chars by default if we don't\
 do anything about it\n"

# Test even if a file ends in .gz, if it is not compressed it can still be read
gap> stream := InputTextFile(Filename(DirectoriesLibrary("tst"), "example-dir/compress/not-compressed.txt.gz"));;
gap> ReadAll(stream) = "not compressed\n";
true
gap> CloseStream(stream);
gap> STOP_TEST("compressed.tst");
