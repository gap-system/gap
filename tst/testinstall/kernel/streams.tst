#
# Tests for functions defined in src/streams.c
#
gap> START_TEST("kernel/streams.tst");

#
gap> CLOSE_LOG_TO();
Error, LogTo: can not close the logfile
gap> LOG_TO(fail);
Error, LogTo: <filename> must be a string (not a boolean or fail)

#
gap> CLOSE_INPUT_LOG_TO();
Error, InputLogTo: can not close the logfile
gap> INPUT_LOG_TO(fail);
Error, InputLogTo: <filename> must be a string (not a boolean or fail)

#
gap> CLOSE_OUTPUT_LOG_TO();
Error, OutputLogTo: can not close the logfile
gap> OUTPUT_LOG_TO(fail);
Error, OutputLogTo: <filename> must be a string (not a boolean or fail)

#
gap> READ(fail);
Error, READ: <filename> must be a string (not a boolean or fail)
gap> READ_NORECOVERY(fail);
Error, READ: <filename> must be a string (not a boolean or fail)
gap> READ_AS_FUNC(fail);
Error, READ_AS_FUNC: <filename> must be a string (not a boolean or fail)
gap> READ_GAP_ROOT(fail);
Error, READ: <filename> must be a string (not a boolean or fail)

#
gap> RemoveFile(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> CreateDir(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> RemoveDir(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> IsDir(fail);
Error, <filename> must be a string (not a boolean or fail)

#
gap> LastSystemError();; LastSystemError();
rec( message := "no error", number := 0 )

#
gap> IsExistingFile(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> IsReadableFile(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> IsWritableFile(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> IsExecutableFile(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> IsDirectoryPathString(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> STRING_LIST_DIR(fail);
Error, <dirname> must be a string (not a boolean or fail)

#
gap> CLOSE_FILE(fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> INPUT_TEXT_FILE(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> IS_END_OF_FILE(fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> IS_END_OF_FILE(-1);
fail
gap> IS_END_OF_FILE(0);
false
gap> IS_END_OF_FILE(254);
fail
gap> OUTPUT_TEXT_FILE(fail, fail);
Error, <filename> must be a string (not a boolean or fail)
gap> OUTPUT_TEXT_FILE("test", fail);
Error, <append> must be a boolean (not a boolean or fail)

#
gap> POSITION_FILE(fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> POSITION_FILE(-1);
fail
gap> IsInt(POSITION_FILE(4));
true
gap> POSITION_FILE(254);
fail

#
gap> READ_BYTE_FILE(fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> READ_BYTE_FILE(-1);
fail

#
gap> READ_LINE_FILE(fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> READ_ALL_FILE(fail,fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> READ_ALL_FILE(1,fail);
Error, <limit> must be a small integer (not a boolean or fail)
gap> SEEK_POSITION_FILE(fail,fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> SEEK_POSITION_FILE(1,fail);
Error, <pos> must be an integer (not a boolean or fail)

#
gap> WRITE_BYTE_FILE(fail,fail);
Error, <fid> must be an integer (not a boolean or fail)
gap> WRITE_BYTE_FILE(1,fail);
Error, <ch> must be an integer (not a boolean or fail)
gap> WRITE_BYTE_FILE(-1,65);
fail
gap> WRITE_BYTE_FILE(0,65);
true
gap> WRITE_BYTE_FILE(254,65);
fail

#
gap> READ_STRING_FILE(fail);
Error, <fid> must be an integer (not a boolean or fail)

#
gap> FD_OF_FILE(fail);
Error, <fid> must be a small integer (not a boolean or fail)

#
gap> ExecuteProcess(fail,fail,fail,fail,fail);
Error, <dir> must be a string (not a boolean or fail)
gap> ExecuteProcess("",fail,fail,fail,fail);
Error, <prg> must be a string (not a boolean or fail)
gap> ExecuteProcess("","",fail,fail,fail);
Error, <in> must be an integer (not a boolean or fail)
gap> ExecuteProcess("","",0,fail,fail);
Error, <out> must be an integer (not a boolean or fail)
gap> ExecuteProcess("","",0,0,fail);
Error, <args> must be a small list (not a boolean or fail)
gap> ExecuteProcess("","",0,0,[1]);
Error, <tmp> must be a string (not a integer)

#
gap> STOP_TEST("kernel/streams.tst", 1);
