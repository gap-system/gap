#############################################################################
##
#W  streams.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for streams.
##
Revision.streams_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsClosedStream  . . . . . . . . . . . . . . .  category of closed streams
##
DeclareCategory( "IsClosedStream", IsObject );


#############################################################################
##
#C  IsStream  . . . . . . . . . . . . . . . . . . . . . . category of streams
##
DeclareCategory( "IsStream", IsObject );


#############################################################################
##
#C  IsInputStream . . . . . . . . . . . . . . . . . category of input streams
##
DeclareCategory( "IsInputStream", IsStream );


#############################################################################
##
#C  IsInputTextStream . . . . . . . . . . . .  category of input text streams
##
DeclareCategory( "IsInputTextStream", IsInputStream );


#############################################################################
##
#C  IsInputTextNone . . . . . . . . . . . category of input text none streams
##
DeclareCategory( "IsInputTextNone", IsInputTextStream );


#############################################################################
##
#C  IsOutputStream  . . . . . . . . . . . . . . .  category of output streams
##
DeclareCategory( "IsOutputStream", IsStream );


#############################################################################
##
#C  IsOutputTextStream	. . . . . . . . . . . category of output text streams
##
DeclareCategory( "IsOutputTextStream", IsOutputStream );


#############################################################################
##
#C  IsOutputTextNone  . . . . . . . . .  category of output text none streams
##
DeclareCategory( "IsOutputTextNone", IsOutputTextStream );


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
DeclareOperation( "IsEndOfStream", [ IsInputStream ] );


#############################################################################
##
#O  PositionStream( <input-stream> )  . . . . . . . . . . .  current position
##
DeclareOperation( "PositionStream", [ IsInputStream ] );


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
DeclareOperation( "ReadAll", [ IsInputTextStream ] );


#############################################################################
##
#O  ReadByte( <input-stream> )	. . . . . . . . . . . . . .  read single byte
##
##  'ReadByte' returns  one character (returned  as  integer) from  the input
##  stream <stream-in>.  'ReadByte' returns 'fail' if there is no character
##  available, in particular if it is at the end of a file.
##
##  If <stream-in> is the input stream of  a input/output process, 'ReadByte'
##  may also return 'fail' if the process is also trying to read.
##
DeclareOperation( "ReadByte", [ IsInputStream ] );
                    

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
DeclareOperation( "ReadLine", [ IsInputTextStream ] );


#############################################################################
##
#O  RewindStream( <input-stream> )  . . . . . . . . . return to the beginning
##
DeclareOperation( "RewindStream", [ IsInputStream ] );


#############################################################################
##
#O  SeekPositionStream( <input-stream>, <pos> )	. . . .  return to a position
##
DeclareOperation( "SeekPositionStream", [ IsInputStream, IsInt ] );


#############################################################################
##
#O  WriteAll( <output-text-stream>, <string> )  .  write whole string to file
##
DeclareOperation( "WriteAll", [ IsOutputTextStream, IsList ] );
                    

#############################################################################
##
#O  WriteByte( <output-stream>, <byte> )  . . . . . . . . . write single byte
##
DeclareOperation( "WriteByte", [ IsOutputStream, IsInt ] );
                    

#############################################################################
##
#O  WriteLine( <output-text-stream>, <string> ) .   write string plus newline
##
DeclareOperation( "WriteLine", [ IsOutputTextStream, IsList ] );
                    

#############################################################################
##

#O  CloseStream( <stream> ) . . . . . . . . . . . . . . . . .  close a stream
##
DeclareOperation( "CloseStream", [ IsStream ] );


#############################################################################
##

#O  InputTextString( <string> )	. . . .  create input text stream from string
##
DeclareOperation( "InputTextString", [ IsString ] );


#############################################################################
##
#O  InputTextFile( <string> ) . . . . . .  create input text stream from file
##
DeclareOperation( "InputTextFile", [ IsString ] );


#############################################################################
##
#O  InputTextNone() . . . . . . . . . . . . . . . . . dummy input text stream
##
UNBIND_GLOBAL( "InputTextNone" );
DeclareGlobalFunction( "InputTextNone" );


#############################################################################
##
#O  InputTextUser() . . . . . . . . . . . . . input text stream from the user
##
DeclareGlobalFunction( "InputTextUser" );


#############################################################################
##
#O  OutputTextString( <string>, <append> )  . . . . create output text stream
##
DeclareOperation( "OutputTextString", [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextFile( <string>, <append> )  . . . . . create output text stream
##
DeclareOperation( "OutputTextFile", [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextNone()  . . . . . . . . . . . . . . .  dummy output text stream
##
UNBIND_GLOBAL( "OutputTextNone" );
DeclareGlobalFunction( "OutputTextNone" );


#############################################################################
##
#O  OutputTextUser()  . . . . . . . . . . . .  output text stream to the user
##
DeclareGlobalFunction( "OutputTextUser" );


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
DeclareOperation( "LogTo", [ IsOutputStream ] );


#############################################################################
##
#O  InputLogTo( <stream> )  . . . . . . . . . . . . . . log input to a stream
##
DeclareOperation( "InputLogTo", [ IsOutputStream ] );


#############################################################################
##
#O  OutputLogTo( <stream> ) . . . . . . . . . . . . .  log output to a stream
##
DeclareOperation( "OutputLogTo", [ IsOutputStream ] );


#############################################################################
##

#E  streams.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
