#@local dir,fname,isGzippedFile,stream,str
gap> START_TEST("compressed.tst");
gap> dir := DirectoryTemporary();;
gap> fname := Filename(dir, "test.g.gz");;

# Let us check when we have written a compressed file by checking the gzip header
gap> isGzippedFile := function(dir, name)
>    local out, str,prog;
>    str := "";
>    out := OutputTextString(str, true);
>    Process(dir, Filename(DirectoriesSystemPrograms(),"cat"), InputTextNone(), out, [name]);
>    return str{[1..2]} = "\037\213";
>  end;;
gap> str := "hello\ngoodbye\n";;

# Write a compressed file
gap> FileString( fname, str ) = Length(str);
true

# Check file really is compressed (FIXME: disabled in stable-4.11)
gap> isGzippedFile(dir, "test.g.gz");
false

# Check reading compressed file
gap> StringFile( fname ) = str;
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
gap> stream := OutputTextFile( fname, false );;
gap> PrintTo( stream, "1");
gap> AppendTo( stream, "2");
gap> PrintTo( stream, "3");
gap> CloseStream(stream);
gap> stream;
closed-stream
gap> isGzippedFile(dir, "test.g.gz");
false

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

# Test even if a file ends in .gz, if it is not compressed it can still be read
gap> stream := InputTextFile(Filename(DirectoriesLibrary("tst"), "example-dir/compress/not-compressed.txt.gz"));;
gap> ReadAll(stream) = "not compressed\n";
true
gap> CloseStream(stream);
gap> STOP_TEST("compressed.tst");
