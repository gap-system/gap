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

#C  IsClosedStream
##
IsClosedStream := NewCategory(
    "IsClosedStream",
    IsObject );


#############################################################################
##
#C  IsStream
##
IsStream := NewCategory(
    "IsStream",
    IsObject );


#############################################################################
##
#C  IsInputStream
##
IsInputStream := NewCategory(
    "IsInputStream",
    IsStream );


#############################################################################
##
#C  IsInputTextStream
##
IsInputTextStream := NewCategory(
    "IsInputTextStream",
    IsInputStream );


#############################################################################
##
#C  IsOutputStream
##
IsOutputStream := NewCategory(
    "IsOutputStream",
    IsStream );


#############################################################################
##
#C  IsOutputTextStream
##
IsOutputTextStream := NewCategory(
    "IsOutputTextStream",
    IsOutputStream );


#############################################################################
##

#V  StreamsFamily
##
StreamsFamily := NewFamily( "StreamsFamily" );


#############################################################################
##

#O  IsEndOfStream( <input-text-stream> )
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
#O  PositionStream( <input-text-stream> )
##
PositionStream := NewOperation(
    "PositionStream",
    [ IsInputStream ] );


#############################################################################
##
#O  ReadAll( <input-text-stream> )
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
#O  ReadByte( <input-stream> )
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
#O  ReadLine( <input-text-stream> )
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
#O  RewindStream( <input-text-stream> )
##
RewindStream := NewOperation(
    "RewindStream",
    [ IsInputStream ] );


#############################################################################
##
#O  SeekPositionStream( <input-text-stream> )
##
SeekPositionStream := NewOperation(
    "SeekPositionStream",
    [ IsInputStream, IsInt ] );


#############################################################################
##
#O  WriteAll( <output-stream>, <string> )
##
WriteAll := NewOperation(
    "WriteAll",
    [ IsOutputStream, IsList ] );
                    

#############################################################################
##
#O  WriteByte( <output-stream>, <byte> )
##
WriteByte := NewOperation(
    "WriteByte",
    [ IsOutputStream, IsInt ] );
                    

#############################################################################
##

#O  CloseStream( <stream> )
##
CloseStream := NewOperation(
    "CloseStream",
    [ IsStream ] );


#############################################################################
##

#O  InputTextString( <string> )
##
InputTextString := NewOperation(
    "InputTextString",
    [ IsString ] );


#############################################################################
##
#O  InputTextFile( <string> )
##
InputTextFile := NewOperation(
    "InputTextFile",
    [ IsString ] );


#############################################################################
##
#O  OutputTextString( <string>, <append> )
##
OutputTextString := NewOperation(
    "OutputTextString",
    [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextFile( <string>, <append> )
##
OutputTextFile := NewOperation(
    "OutputTextFile",
    [ IsList, IsBool ] );


#############################################################################
##

#F  AppendTo( <stream>, <arg1>, ... )
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
#F  PrintTo( <stream>, <arg1>, ... )
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
#O  LogTo( <stream> )
##
LogTo := NewOperation(
    "LogTo",
    [ IsOutputStream ] );


#############################################################################
##
#O  InputLogTo( <stream> )
##
InputLogTo := NewOperation(
    "InputLogTo",
    [ IsOutputStream ] );


#############################################################################
##
#O  OutputLogTo( <stream> )
##
OutputLogTo := NewOperation(
    "OutputLogTo",
    [ IsOutputStream ] );


#############################################################################
##

#E  streams.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
