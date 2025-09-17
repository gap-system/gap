#@local dir,fname,file,line,stream,tmpdir,res,streams,i,func,linewrap,indent
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
gap> WriteLine(stream, "abc");
true
gap> CloseStream(stream);
gap> stream;
closed-stream

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
gap> stream := OutputTextFile( fname, true );;
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
gap> func := function(x) if x then return "a very long line that GAP is going to wrap at 80 chars by default if we don't do anything about it"; fi; end;;
gap> for linewrap in [false,true] do
> for indent in [false,true] do
> stream := OutputTextFile(fname, false);
> SetPrintFormattingStatus(stream, rec(linewrap := linewrap, indent := indent));
> PrintTo(stream, func);
> CloseStream(stream);
> Print([linewrap, indent, StringFile(fname)],"\n");
> od;
> od;
[ false, false, 
  "function ( x )\nif x then\nreturn \"a very long line that GAP is going to w\
rap at 80 chars by default if we don't do anything about it\";\nfi;\nreturn;\n\
end" ]
[ false, true, 
  "function ( x )\n    if x then\n        return \"a very long line that GAP i\
s going to wrap at 80 chars by default if we don't do anything about it\";\n  \
  fi;\n    return;\nend" ]
[ true, false, 
  "function ( x )\nif x then\nreturn \"a very long line that GAP is going to w\
rap at 80 chars by default if w\\\ne don't do anything about it\";\nfi;\nretur\
n;\nend" ]
[ true, true, 
  "function ( x )\n    if x then\n        return \n         \"a very long line\
 that GAP is going to wrap at 80 chars by default if\\\n we don't do anything \
about it\";\n    fi;\n    return;\nend" ]
gap> for linewrap in [false,true] do
> for indent in [false,true] do
> res := "";
> stream := OutputTextString(res, true);
> SetPrintFormattingStatus(stream, rec(linewrap := linewrap, indent := indent));
> PrintTo(stream, func);
> CloseStream(stream);
> Print([linewrap, indent, res],"\n");
> od;
> od;
[ false, false, 
  "function ( x )\nif x then\nreturn \"a very long line that GAP is going to w\
rap at 80 chars by default if we don't do anything about it\";\nfi;\nreturn;\n\
end" ]
[ false, true, 
  "function ( x )\n    if x then\n        return \"a very long line that GAP i\
s going to wrap at 80 chars by default if we don't do anything about it\";\n  \
  fi;\n    return;\nend" ]
[ true, false, 
  "function ( x )\nif x then\nreturn \"a very long line that GAP is going to w\
rap at 80 chars by default if w\\\ne don't do anything about it\";\nfi;\nretur\
n;\nend" ]
[ true, true, 
  "function ( x )\n    if x then\n        return \n         \"a very long line\
 that GAP is going to wrap at 80 chars by default if\\\n we don't do anything \
about it\";\n    fi;\n    return;\nend" ]
gap> stream := OutputTextString(res, true);
OutputTextString(181)
gap> SetPrintFormattingStatus(stream, true);
gap> PrintFormattingStatus(stream);
rec( indent := true, linewrap := true )
gap> SetPrintFormattingStatus(stream, false);
gap> PrintFormattingStatus(stream);
rec( indent := false, linewrap := false )
gap> SetPrintFormattingStatus(stream, rec(indent := false, linewrap := true));
gap> PrintFormattingStatus(stream);
rec( indent := false, linewrap := true )
gap> SetPrintFormattingStatus(stream, fail);
Error, Formatting status cannot be 'fail'
gap> SetPrintFormattingStatus(stream, 6);
Error, Formatting status must be a boolean or a record
gap> SetPrintFormattingStatus(stream, rec(indent := false));
Error, Formatting status records must contain exactly two components, named 'i\
ndent' and 'linewrap'
gap> SetPrintFormattingStatus(stream, rec(indent := false, linewrap := 12));
Error, linewrap must be 'true' or 'false' in formatting status record
gap> SetPrintFormattingStatus(stream, rec(indent := false, linewrap := false, extra := true));
Error, Formatting status records must contain exactly two components, named 'i\
ndent' and 'linewrap'
gap> PrintFormattingStatus(stream);
rec( indent := false, linewrap := true )

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
gap> ReadAllLine(stream, line -> 0 < Length(line) and Last(line) = '\n');
"another line\n"
gap> ReadAllLine(stream, false, line -> 0 < Length(line) and Last(line) = '\n');
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
gap> CloseStream(file);

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
Error, Formatting status cannot be 'fail'

# too many open files
gap> streams := [ ];;
gap> for i in [ 1 .. 300 ] do
>    stream := OutputTextFile( fname, false );
>    Assert(0, stream <> fail);
>    Add( streams, stream );
> od;;
Error, Assertion failure
gap> Perform( streams, CloseStream );
gap> RemoveFile(fname);
true

#
gap> STOP_TEST("streams.tst");
