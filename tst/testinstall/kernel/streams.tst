#
# Tests for functions defined in src/streams.c
#
gap> START_TEST("kernel/streams.tst");

#
gap> LastSystemError();
rec( message := "no error", number := 0 )

#
gap> str := "";;
gap> out := OutputTextString(str, false);;
gap> SetPrintFormattingStatus(out, false);
gap> CALL_WITH_STREAM(fail, fail, fail);
Error, CALL_WITH_STREAM: <stream> must be an output stream (not the value 'fai\
l')
gap> CALL_WITH_STREAM(out, fail, fail);
Error, CALL_WITH_STREAM: <args> must be a small list (not the value 'fail')
gap> CALL_WITH_STREAM(out, Display, [ [[1,2],[3,4]] ]);
gap> CloseStream(out);
gap> str;
"[ [  1,  2 ],\n  [  3,  4 ] ]\n"

#
gap> CLOSE_LOG_TO();
Error, LogTo: cannot close the logfile
gap> LOG_TO(fail);
Error, LOG_TO: <filename> must be a string (not the value 'fail')
gap> LOG_TO(TmpName());
true
gap> CLOSE_LOG_TO();
true
gap> LOG_TO_STREAM(fail);
Error, LOG_TO_STREAM: <stream> must be an output stream (not the value 'fail')
gap> str := "";; s:=OutputTextString(str, false);;
gap> LOG_TO_STREAM(s);
true
gap> CLOSE_LOG_TO();
true

#
gap> CLOSE_INPUT_LOG_TO();
Error, InputLogTo: cannot close the logfile
gap> INPUT_LOG_TO(fail);
Error, INPUT_LOG_TO: <filename> must be a string (not the value 'fail')
gap> INPUT_LOG_TO(TmpName());
true
gap> CLOSE_INPUT_LOG_TO();
true
gap> INPUT_LOG_TO_STREAM(fail);
Error, INPUT_LOG_TO_STREAM: <stream> must be an output stream (not the value '\
fail')
gap> str := "";; s:=OutputTextString(str, false);;
gap> INPUT_LOG_TO_STREAM(s);
true
gap> CLOSE_INPUT_LOG_TO();
true

#
gap> CLOSE_OUTPUT_LOG_TO();
Error, OutputLogTo: cannot close the logfile
gap> OUTPUT_LOG_TO(fail);
Error, OUTPUT_LOG_TO: <filename> must be a string (not the value 'fail')
gap> OUTPUT_LOG_TO(TmpName());
true
gap> CLOSE_OUTPUT_LOG_TO();
true
gap> OUTPUT_LOG_TO_STREAM(fail);
Error, OUTPUT_LOG_TO_STREAM: <stream> must be an output stream (not the value \
'fail')
gap> str := "";; s:=OutputTextString(str, false);;
gap> OUTPUT_LOG_TO_STREAM(s);
true
gap> CLOSE_OUTPUT_LOG_TO();
true

#
# READ_COMMAND_REAL
#
gap> READ_COMMAND_REAL(true, fail);
Error, READ_COMMAND_REAL: <stream> must be an input stream (not the value 'tru\
e')

#
gap> stream:=InputTextString("1+1;");
InputTextString(0,4)
gap> READ_COMMAND_REAL(stream, false); stream;
[ true, 2 ]
InputTextString(4,4)
gap> READ_COMMAND_REAL(stream, false); stream;
[ false ]
InputTextString(4,4)

#
gap> stream := InputTextString("1+1;2+2;");
InputTextString(0,8)
gap> READ_COMMAND_REAL(stream, false); stream;
[ true, 2 ]
InputTextString(4,8)
gap> READ_COMMAND_REAL(stream, false); stream;
[ true, 4 ]
InputTextString(8,8)
gap> READ_COMMAND_REAL(stream, false); stream;
[ false ]
InputTextString(8,8)

#
gap> READ_COMMAND_REAL(InputTextString("/1;"), false); # intentional syntax error
Syntax error: expression expected in stream:1
/1;
^
[ true ]
gap> READ_COMMAND_REAL(InputTextString("quit;"), false);
[ true ]
gap> READ_COMMAND_REAL(InputTextString("QUIT;"), false);
[ false ]

#
gap> READ(fail);
Error, READ: <input> must be a string or an input stream (not the value 'fail'\
)
gap> READ("/this/path/does/not/exist!");
false
gap> READ(InputTextString(""));
true
gap> stream := InputTextString("function() end;");
InputTextString(0,15)
gap> READ(stream);
true
gap> LastReadValue;
function(  ) ... end
gap> NameFunction(LastReadValue);
"unknown"
gap> stream := InputTextString("function() end;");
InputTextString(0,15)
gap> READ(stream);
true
gap> func := LastReadValue;;
gap> NameFunction(func);
"func"

#
gap> READ_NORECOVERY(fail);
Error, READ_NORECOVERY: <input> must be a string or an input stream (not the v\
alue 'fail')
gap> READ_NORECOVERY("/this/path/does/not/exist!");
false
gap> READ_NORECOVERY(InputTextString(""));
true

#
gap> READ_STREAM_LOOP(fail, fail, fail);
Error, READ_STREAM_LOOP: <instream> must be an input stream (not the value 'fa\
il')
gap> READ_STREAM_LOOP(InputTextString(""), fail, fail);
Error, READ_STREAM_LOOP: <outstream> must be an output stream (not the value '\
fail')

#
gap> READ_AS_FUNC(fail);
Error, READ_AS_FUNC: <input> must be a string or an input stream (not the valu\
e 'fail')
gap> READ_AS_FUNC("/this/path/does/not/exist!");
false
gap> func := READ_AS_FUNC(InputTextString(""));
function(  ) ... end
gap> NameFunction(func);
"func"

#
gap> READ_GAP_ROOT(fail);
Error, READ_GAP_ROOT: <filename> must be a string (not the value 'fail')

#
gap> RemoveFile(fail);
Error, RemoveFile: <filename> must be a string (not the value 'fail')
gap> CreateDir(fail);
Error, CreateDir: <filename> must be a string (not the value 'fail')
gap> RemoveDir(fail);
Error, RemoveDir: <filename> must be a string (not the value 'fail')
gap> IsDir(fail);
Error, IsDir: <filename> must be a string (not the value 'fail')

#
gap> IsExistingFile(fail);
Error, IsExistingFile: <filename> must be a string (not the value 'fail')
gap> IsReadableFile(fail);
Error, IsReadableFile: <filename> must be a string (not the value 'fail')
gap> IsWritableFile(fail);
Error, IsWritableFile: <filename> must be a string (not the value 'fail')
gap> IsExecutableFile(fail);
Error, IsExecutableFile: <filename> must be a string (not the value 'fail')
gap> IsDirectoryPathString(fail);
Error, IsDirectoryPathString: <filename> must be a string (not the value 'fail\
')
gap> LIST_DIR(fail);
Error, LIST_DIR: <dirname> must be a string (not the value 'fail')

#
gap> CLOSE_FILE(fail);
Error, CLOSE_FILE: <fid> must be a small integer (not the value 'fail')
gap> INPUT_TEXT_FILE(fail);
Error, INPUT_TEXT_FILE: <filename> must be a string (not the value 'fail')
gap> IS_END_OF_FILE(fail);
Error, IS_END_OF_FILE: <fid> must be a small integer (not the value 'fail')
gap> IS_END_OF_FILE(-1);
fail
gap> IS_END_OF_FILE(0);
false
gap> IS_END_OF_FILE(254);
fail
gap> OUTPUT_TEXT_FILE(fail, fail, fail);
Error, OUTPUT_TEXT_FILE: <filename> must be a string (not the value 'fail')
gap> OUTPUT_TEXT_FILE("test", fail, fail);
Error, OUTPUT_TEXT_FILE: <append> must be 'true' or 'false' (not the value 'fa\
il')
gap> OUTPUT_TEXT_FILE("test", true, fail);
Error, OUTPUT_TEXT_FILE: <comp> must be 'true' or 'false' (not the value 'fail\
')

#
gap> POSITION_FILE(fail);
Error, POSITION_FILE: <fid> must be a small integer (not the value 'fail')
gap> POSITION_FILE(-1);
fail
gap> IsInt(POSITION_FILE(4));
true
gap> POSITION_FILE(254);
fail

#
gap> READ_BYTE_FILE(fail);
Error, READ_BYTE_FILE: <fid> must be a small integer (not the value 'fail')
gap> READ_BYTE_FILE(-1);
fail

#
gap> READ_LINE_FILE(fail);
Error, READ_LINE_FILE: <fid> must be a small integer (not the value 'fail')
gap> READ_ALL_FILE(fail,fail);
Error, READ_ALL_FILE: <fid> must be a small integer (not the value 'fail')
gap> READ_ALL_FILE(1,fail);
Error, READ_ALL_FILE: <limit> must be a small integer (not the value 'fail')
gap> SEEK_POSITION_FILE(fail,fail);
Error, SEEK_POSITION_FILE: <fid> must be a small integer (not the value 'fail'\
)
gap> SEEK_POSITION_FILE(1,fail);
Error, SEEK_POSITION_FILE: <pos> must be a small integer (not the value 'fail'\
)

#
gap> WRITE_BYTE_FILE(fail,fail);
Error, WRITE_BYTE_FILE: <fid> must be a small integer (not the value 'fail')
gap> WRITE_BYTE_FILE(1,fail);
Error, WRITE_BYTE_FILE: <ch> must be a small integer (not the value 'fail')
gap> WRITE_BYTE_FILE(-1,65);
fail
gap> WRITE_BYTE_FILE(0,65);
true
gap> WRITE_BYTE_FILE(254,65);
fail

#
gap> READ_STRING_FILE(fail);
Error, READ_STRING_FILE: <fid> must be a small integer (not the value 'fail')

#
gap> FD_OF_FILE(fail);
Error, FD_OF_FILE: <fid> must be a small integer (not the value 'fail')

#
gap> ExecuteProcess(fail,fail,fail,fail,fail);
Error, ExecuteProcess: <dir> must be a string (not the value 'fail')
gap> ExecuteProcess("",fail,fail,fail,fail);
Error, ExecuteProcess: <prg> must be a string (not the value 'fail')
gap> ExecuteProcess("","",fail,fail,fail);
Error, ExecuteProcess: <in> must be a small integer (not the value 'fail')
gap> ExecuteProcess("","",0,fail,fail);
Error, ExecuteProcess: <out> must be a small integer (not the value 'fail')
gap> ExecuteProcess("","",0,0,fail);
Error, ExecuteProcess: <args> must be a small list (not the value 'fail')
gap> ExecuteProcess("","",0,0,[1]);
Error, ExecuteProcess: <tmp> must be a string (not the integer 1)

#
gap> STOP_TEST("kernel/streams.tst", 1);
