#############################################################################
##
#W  streams.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for streams.
##
Revision.streams_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsClosedStream  . . . . . . . . . . . . . . .  category of closed streams
##
IsClosedStream := NewCategory(
    "IsClosedStream",
    IsObject );


#############################################################################
##
#C  IsStream  . . . . . . . . . . . . . . . . . . . . . . category of streams
##
IsStream := NewCategory(
    "IsStream",
    IsObject );


#############################################################################
##
#C  IsInputStream . . . . . . . . . . . . . . . . . category of input streams
##
IsInputStream := NewCategory(
    "IsInputStream",
    IsStream );


#############################################################################
##
#C  IsInputTextStream . . . . . . . . . . . .  category of input text streams
##
IsInputTextStream := NewCategory(
    "IsInputTextStream",
    IsInputStream );


#############################################################################
##
#C  IsInputTextNone . . . . . . . . . . . category of input text none streams
##
IsInputTextNone := NewCategory(
    "IsInputStream",
    IsInputTextStream );


#############################################################################
##
#C  IsOutputStream  . . . . . . . . . . . . . . .  category of output streams
##
IsOutputStream := NewCategory(
    "IsOutputStream",
    IsStream );


#############################################################################
##
#C  IsOutputTextStream	. . . . . . . . . . . category of output text streams
##
IsOutputTextStream := NewCategory(
    "IsOutputTextStream",
    IsOutputStream );


#############################################################################
##
#C  IsOutputTextNone  . . . . . . . . .  category of output text none streams
##
IsOutputTextNone := NewCategory(
    "IsOutputStream",
    IsOutputTextStream );


#############################################################################
##

#V  StreamsFamily . . . . . . . . . . . . . . . . . . . family of all streams
##
StreamsFamily := NewFamily( "StreamsFamily" );


#############################################################################
##

#O  IsEndOfStream( <input-stream> ) . . . . . . . . . check for end-of-stream
##
##  'IsEndOfStream' returns 'true' if the input stream is at <end-of-stream>,
##  and 'false' otherwise.  Note   that 'IsEndOfStream' might  return 'false'
##  even if the next 'ReadByte' fails.
##
IsEndOfStream := NewOperation(
    "IsEndOfStream",
    [ IsInputStream ] );


#############################################################################
##
#O  PositionStream( <input-stream> )  . . . . . . . . . . .  current position
##
PositionStream := NewOperation(
    "PositionStream",
    [ IsInputStream ] );


#############################################################################
##
#O  ReadAll( <input-text-stream> )  . . . . . . .  read whole input as string
##
##  'ReadAll' returns all  characters  as   string  from the input     stream
##  <stream-in>.  It reads in the input until the stream is at end-of-stream,
##  it    returns  'fail' if   the   <input-text-stream>  is  already at  the
##  end-of-stream.
##
##  If <stream-in> is  the input stream  of a input/output process, 'ReadAll'
##  may also return 'fail' if the process is also trying to read.
##
ReadAll := NewOperation(
    "ReadAll",
    [ IsInputTextStream ] );


#############################################################################
##
#O  ReadByte( <input-stream> )	. . . . . . . . . . . . . .  read single byte
##
##  'ReadByte' returns  one character (returned  as  integer) from  the input
##  stream <stream-in>.  'ReadByte' waits until a  character is available, it
##  returns 'fail' is the <input-text-stream> is at the end-of-stream.
##
##  If <stream-in> is the input stream of  a input/output process, 'ReadByte'
##  may also return 'fail' if the process is also trying to read.
##
ReadByte := NewOperation(
    "ReadByte",
    [ IsInputStream ] );
                    

#############################################################################
##
#O  ReadLine( <input-text-stream> ) . . . . . . . . read whole line as string
##
##  'ReadLine' one   line (returned as  string  *with* the newline)  from the
##  input stream <stream-in>.  'ReadLine' reads  in the input until a newline
##  is read or the end-of-stream. is encountered.
##
##  If <stream-in> is the input stream of  a input/output process, 'ReadLine'
##  may also return 'fail' if the process is also trying to read.
##
ReadLine := NewOperation(
    "ReadLine",
    [ IsInputTextStream ] );


#############################################################################
##
#O  RewindStream( <input-stream> )  . . . . . . . . . return to the beginning
##
RewindStream := NewOperation(
    "RewindStream",
    [ IsInputStream ] );


#############################################################################
##
#O  SeekPositionStream( <input-stream>, <pos> )	. . . .  return to a position
##
SeekPositionStream := NewOperation(
    "SeekPositionStream",
    [ IsInputStream, IsInt ] );


#############################################################################
##
#O  WriteAll( <output-text-stream>, <string> )  .  write whole string to file
##
WriteAll := NewOperation(
    "WriteAll",
    [ IsOutputTextStream, IsList ] );
                    

#############################################################################
##
#O  WriteByte( <output-stream>, <byte> )  . . . . . . . . . write single byte
##
WriteByte := NewOperation(
    "WriteByte",
    [ IsOutputStream, IsInt ] );
                    

#############################################################################
##
#O  WriteLine( <output-text-stream>, <string> ) .   write string plus newline
##
WriteLine := NewOperation(
    "WriteLine",
    [ IsOutputTextStream, IsList ] );
                    

#############################################################################
##

#O  CloseStream( <stream> ) . . . . . . . . . . . . . . . . .  close a stream
##
CloseStream := NewOperation(
    "CloseStream",
    [ IsStream ] );


#############################################################################
##

#O  InputTextString( <string> )	. . . .  create input text stream from string
##
InputTextString := NewOperation(
    "InputTextString",
    [ IsString ] );


#############################################################################
##
#O  InputTextFile( <string> ) . . . . . .  create input text stream from file
##
InputTextFile := NewOperation(
    "InputTextFile",
    [ IsString ] );


#############################################################################
##
#O  InputTextNone() . . . . . . . . . . . . . . . . . dummy input text stream
##
InputTextNone := NewOperationArgs(
    "InputTextNone" );


#############################################################################
##
#O  InputTextUser() . . . . . . . . . . . . . input text stream from the user
##
InputTextUser := NewOperationArgs(
    "InputTextUser" );


#############################################################################
##
#O  OutputTextString( <string>, <append> )  . . . . create output text stream
##
OutputTextString := NewOperation(
    "OutputTextString",
    [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextFile( <string>, <append> )  . . . . . create output text stream
##
OutputTextFile := NewOperation(
    "OutputTextFile",
    [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextNone()  . . . . . . . . . . . . . . .  dummy output text stream
##
OutputTextNone := NewOperationArgs(
    "OutputTextNone" );


#############################################################################
##
#O  OutputTextUser()  . . . . . . . . . . . .  output text stream to the user
##
OutputTextUser := NewOperationArgs(
    "OutputTextUser" );


#############################################################################
##

#F  AppendTo( <stream>, <arg1>, ... ) . . . . . . . . . .  append to a stream
##
##  This is   the same as   'PrintTo'  for streams.   If   <stream> is just a
##  filename than there  is a difference:  'PrintTo'  will clear the    file,
##  'AppendTo' will not.
##
AppendTo := function( arg )
    if IsString(arg[1])  then
        CallFuncList( APPEND_TO, arg );
    elif IsOutputStream(arg[1])  then
        CallFuncList( APPEND_TO_STREAM, arg );
    else
        Error( "first argument must be a filename or output stream" );
    fi;
end;


#############################################################################
##
#F  PrintTo( <stream>, <arg1>, ... )  . . . . . . . . . .  append to a stream
##
##  'PrintTo' appends <arg1>, ... to the output stream.
##
PrintTo := function( arg )
    if IsString(arg[1])  then
        CallFuncList( PRINT_TO, arg );
    elif IsOutputStream(arg[1])  then
        CallFuncList( PRINT_TO_STREAM, arg );
    else
        Error( "first argument must be a filename or output stream" );
    fi;
end;


#############################################################################
##
#O  LogTo( <stream> ) . . . . . . . . . . . . . . . . . . . . log to a stream
##
LogTo := NewOperation(
    "LogTo",
    [ IsOutputStream ] );


#############################################################################
##
#O  InputLogTo( <stream> )  . . . . . . . . . . . . . . log input to a stream
##
InputLogTo := NewOperation(
    "InputLogTo",
    [ IsOutputStream ] );


#############################################################################
##
#O  OutputLogTo( <stream> ) . . . . . . . . . . . . .  log output to a stream
##
OutputLogTo := NewOperation(
    "OutputLogTo",
    [ IsOutputStream ] );


#############################################################################
##

#E  streams.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
