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

#1
## *Streams* provide flexible access to {\GAP}'s input and output
## processing. An *input stream* takes characters from some source and
## delivers them to {\GAP} which *reads* them from the stream.  When an
## input stream has delivered all characters it is at `end-of-stream'.  An
## *output stream* receives characters from {\GAP} which *writes* them to
## the stream, and delivers them to some destination.
## 
## A major use of streams is to provide efficient and flexible access to
## files.  Files can be read and written using `Read' and `AppendTo',
## however the former only allows a complete file to be read as {\GAP}
## input and the latter imposes a high time penalty if many small pieces of
## output are written to a large file. Streams allow input files in other
## formats to be read and processed, and files to be built up efficiently
## from small pieces of output. Streams may also be used for other purposes, 
## for example to read from and print to {\GAP} strings, or to read input
## directly from the user.
## 
## Any stream is either a *text stream*, which translates the `end-of-line'
## character (`{'\\n'}') to or from the system's representation of
## `end-of-line' (e.g., <new-line> under UNIX, <carriage-return> under
## MacOS, <carriage-return>-<new-line> under DOS), or a *binary stream*,
## which does not translate the `end-of-line' character. The processing of
## other unprintable characters by text streams is undefined. Binary streams
## pass them unchanged.
## 
## Note that binary streams are *@not yet implemented@*.
## 
## Whereas it is  cheap  to append  to a  stream, streams do  consume system
## resources, and only a  limited number can  be open at any time, therefore
## it is   necessary   to close   a  stream  as   soon as   possible  using
## `CloseStream' described in Section~"CloseStream".   If creating  a stream
## failed then `LastSystemError' (see "LastSystemError")  can be used to get
## information about the failure. 
## 
## 

#############################################################################
##
#C  IsClosedStream  . . . . . . . . . . . . . . .  category of closed streams
##
##  When a stream is closed, its type changes to lie in
##  'IsClosedStream'. This category is used to install methods that trap
##  accesses to closed streams.
##
DeclareCategory( "IsClosedStream", IsObject );


#############################################################################
##
#C  IsStream  . . . . . . . . . . . . . . . . . . . . . . category of streams
##
##  Streams are GAP objects and all open streams, input, output, text
##  and binary, lie in this category.
##
DeclareCategory( "IsStream", IsObject );


#############################################################################
##
#C  IsInputStream . . . . . . . . . . . . . . . . . category of input streams
##
##  All input streams lie in this category, and support input
##  operations such as `ReadByte' (see "Operations for Input Streams")
##
DeclareCategory( "IsInputStream", IsStream );


#############################################################################
##
#C  IsInputTextStream . . . . . . . . . . . .  category of input text streams
##
##  All *text* input streams lie in this category. They translate new-line
##  characters read.
##
DeclareCategory( "IsInputTextStream", IsInputStream );


#############################################################################
##
#C  IsInputTextNone . . . . . . . . . . . category of input text none streams
##
##  It is convenient to use a category to distinguish dummy streams
##  (see "Dummy Streams") from others. Other distinctions are usually
##  made using representations
##
DeclareCategory( "IsInputTextNone", IsInputTextStream );


#############################################################################
##
#C  IsOutputStream  . . . . . . . . . . . . . . .  category of output streams
##
##  All output streams lie in this category and support basic
##  operations such as `WriteByte' (see "Operations for Output Streams")
##
DeclareCategory( "IsOutputStream", IsStream );


#############################################################################
##
#C  IsOutputTextStream	. . . . . . . . . . . category of output text streams
##
## All *text* output streams lie in this category and translate
## new-line characters on output.
##
DeclareCategory( "IsOutputTextStream", IsOutputStream );


#############################################################################
##
#C  IsOutputTextNone  . . . . . . . . .  category of output text none streams
##
##  It is convenient to use a category to distinguish dummy streams
##  (see "Dummy Streams") from others. Other distinctions are usually
##  made using representations
##

DeclareCategory( "IsOutputTextNone", IsOutputTextStream );

#############################################################################
##
#C  IsInputOutputStream . . . . . . . . . . . . . category of two-way streams 
##
##  Streams which lie in `IsInputOutputStream' capture bidirectional 
##  communications between {\GAP} and another process, either locally
##  or (@as yet unimplemented@) remotely accessed through a socket
##
##  Such streams support the basic operations of both input and output 
##  streams. They should provide some buffering, allowing output date to be 
##  written to the stream, even when input data is waiting to be read, 
##  but the amount of this buffering is operating system dependent,
##  and the user shoould take care not to get too far ahead in writing, or 
##  behind in reading, or deadlock may occur.
##

DeclareCategory( "IsInputOutputStream", IsInputStream and
        IsOutputStream );


#############################################################################
##
#V  StreamsFamily . . . . . . . . . . . . . . . . . . . family of all streams
##
##  All streams lie in the `StreamsFamily'
##
StreamsFamily := NewFamily( "StreamsFamily" );


#############################################################################
##
#O  IsEndOfStream( <input-stream> ) . . . . . . . . . check for end-of-stream
##
##  `IsEndOfStream' returns `true' if the input stream is at <end-of-stream>,
##  and `false' otherwise.  Note   that `IsEndOfStream' might  return `false'
##  even if the next `ReadByte' fails.
##
DeclareOperation( "IsEndOfStream", [ IsInputStream ] );


#############################################################################
##
#O  PositionStream( <input-stream> )  . . . . . . . . . . .  current position
##
##  Some input streams, such as string streams and file streams attached to
##  disk files, support a form of random access by way of the operations
##  `PositionStream', `SeekPositionStream' and
##  `RewindStream'. `PositionStream' returns a non-negative integer denoting
##  the current position in the stream (usually the number of characters
##  *before* the next one to be read.
##
##  If this is not possible, for example for an input stream attached to
##  standard input (normally the keyboard), then `fail' is returned
##

DeclareOperation( "PositionStream", [ IsInputStream ] );


#############################################################################
##
#O  ReadAll( <input-stream> )  . . . . . . .  read whole input as string
##
##  `ReadAll' returns all  characters  as   string  from the input     stream
##  <stream-in>.  It reads in the input until the stream is at end-of-stream,
##  it    returns  `fail' if   the   <input-text-stream>  is  already at  the
##  end-of-stream.
##
##  If <stream-in> is the input stream of a input/output process, `ReadAll'
##  reads all the input currently available.
##
##  A default method is supplied for `ReadAll' which simply calls `ReadByte'
##  repeatedly.
##
DeclareOperation( "ReadAll", [ IsInputStream ] );


#############################################################################
##
#O  ReadByte( <input-stream> )	. . . . . . . . . . . . . .  read single byte
##
##  `ReadByte' returns  one character (returned  as  integer) from  the input
##  stream <stream-in>.  `ReadByte' returns `fail' if there is no character
##  available, in particular if it is at the end of a file.
##
##  If <stream-in> is the input stream of  a input/output process, `ReadByte'
##  may also return `fail' if no byte is currently available.
##
##  `ReadByte' is the basic operation for input streams. If a `ReadByte'
##  method is installed for a user-defined type of stream, then all the other
##  input stream operations will work (although possibly not at peak
##  efficiency).
##
DeclareOperation( "ReadByte", [ IsInputStream ] );
                    

#############################################################################
##
#O  ReadLine( <input-stream> ) . . . . . . . . read whole line as string
##
##  `ReadLine' returns one line (returned as string *with* the newline) from
##  the input stream <stream-in>.  `ReadLine' reads in the input until a
##  newline is read or the end-of-stream. is encountered.
##
##  If <stream-in> is the input stream of a input/output process, `ReadLine'
##  may also return `fail' or return an incomplete line if the other
##  process has not yet written any more.
##
##  A default method is supplied for `ReadLine' which simply calls `ReadByte'
##  repeatedly. The kernel uses calls to `ReadLine' to supply input to the
##  parser when reading from a stream.
##
DeclareOperation( "ReadLine", [ IsInputStream ] );


#############################################################################
##
#O  RewindStream( <input-stream> )  . . . . . . . . . return to the beginning
##
##  `RewindStream' attempts to return an input stream to its starting
##  condition, so that all the same characters can be read again. It returns
##  `true' if the rewind succeeds and `fail' otherwise
##
##  A default method implements RewindStream using `SeekPositionStream'.
##
DeclareOperation( "RewindStream", [ IsInputStream ] );


#############################################################################
##
#O  SeekPositionStream( <input-stream>, <pos> )	. . . .  return to a position
##
##  `SeekPositionStream' attempts to rewind or wind forward an input stream
##  to the specified position. This is not possible for all streams. It
##  returns `true' if the seek is successful and `fail' otherwise.
##
DeclareOperation( "SeekPositionStream", [ IsInputStream, IsInt ] );


#############################################################################
##
#O  WriteAll( <output-stream>, <string> )  .  write whole string to file
##
## appends  <string> to <output-stream>.   No final  newline is written.
## The function returns `true' if the write succeeds and `fail' otherwise.
##
## A default method is installed which implements `WriteAll' by repreated
## calls to `WriteByte'.
##
## When Printing or appending to a stream (using `PrintTo', or `AppendTo' or
## when logging to a stream), the kernel generates a call to `WriteAll' for
## each line output.
##

DeclareOperation( "WriteAll", [ IsOutputStream, IsList ] );
                    

#############################################################################
##
#O  WriteByte( <output-stream>, <byte> )  . . . . . . . . . write single byte
##
## writes the  next  character  (given  as *integer*)  to the  output stream
## <output-stream>.  The function  returns `true' if  the write succeeds and
## `fail' otherwise.
## 
##  `WriteByte' is the basic operation for input streams. If a `WriteByte'
##  method is installed for a user-defined type of stream, then all the other
##  output stream operations will work (although possibly not at peak
##  efficiency).
##


DeclareOperation( "WriteByte", [ IsOutputStream, IsInt ] );
                    

#############################################################################
##
#O  WriteLine( <output-stream>, <string> ) .   write string plus newline
##
## appends  <string> to <output-stream>.   A  final newline is written.
## The function returns `true' if the write succeeds and `fail' otherwise.
##
## A default method is installed which implements `WriteLine' by repreated
## calls to `WriteByte'.
##
DeclareOperation( "WriteLine", [ IsOutputStream, IsList ] );
                    

#############################################################################
##
#O  CloseStream( <stream> ) . . . . . . . . . . . . . . . . .  close a stream
##
##  In order  to preserve system resources  and to flush output streams every
## stream should  be  closed  as soon   as  it is   no longer   used using
## `CloseStream'.
## 
## It is an error to  try to read  characters from or  write characters to a
## closed  stream.   Closing a  stream tells  the {\GAP}   kernel and/or the
## operating system kernel  that the file is  no longer needed.  This may be
## necessary  because  the {\GAP} kernel  and/or  the  operating  system may
## impose a limit on how many streams may be open simultaneously.

DeclareOperation( "CloseStream", [ IsStream ] );


#############################################################################
##
#O  InputTextString( <string> )	. . . .  create input text stream from string
##
##  `InputTextString( <string> )'returns an input stream that delivers the
##  characters from the string <string>.  The <string> is not changed when
##  reading characters from it and changing the <string> after the call to
##  `InputTextString' has no influence on the input stream.
##

DeclareOperation( "InputTextString", [ IsString ] );


#############################################################################
##
#O  InputTextFile( <name-file> )  . . . .  create input text stream from file
##
##  `InputTextFile( <name-file> )' returns an input stream in the category
##  `IsInputTextStream' that delivers the characters from the file
##  <name-file>.
##
DeclareOperation( "InputTextFile", [ IsString ] );


#############################################################################
##
#F  InputTextNone() . . . . . . . . . . . . . . . . . dummy input text stream
##
##  returns a dummy input text stream, which delivers no characters, i.e., it
##  is always at end of stream.  Its main use is for calls to `Process' (see
##  "Process") when the started program does not read anything.
##

UNBIND_GLOBAL( "InputTextNone" );
DeclareGlobalFunction( "InputTextNone" );


#############################################################################
##
#F  InputTextUser() . . . . . . . . . . . . . input text stream from the user
##
##  returns an input text stream which delivers characters typed by the user
##  (or from the standard input device if it has been redirected). In normal
##  circumstances, characters are delivered one by one as they are typed,
##  without waiting until the end of a line. No prompts are printed.
##
                                                    
DeclareGlobalFunction( "InputTextUser" );


#############################################################################
##
#O  OutputTextString( <list>, <append> )  . . . . create output text stream
##
##  returns an output stream that puts all received characters into the list
##  <list>.  If <append> is `false', then the list is emptied first,
##  otherwise received characters are added at the end of the list. 
##

DeclareOperation( "OutputTextString", [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextFile( <name-file>, <append> )  . . . create output text stream
##
## `OutputTextFile( <name-file>, <append> )' returns an output stream in the
## category `IsOutputTextFile' that writes received characters to the file
## <name-file>.  If <append> is `false', then the file is emptied first,
## otherwise received characters are added at the end of the list.
##

DeclareOperation( "OutputTextFile", [ IsList, IsBool ] );


#############################################################################
##
#F  OutputTextNone()  . . . . . . . . . . . . . . .  dummy output text stream
##
##  returns a dummy output stream, which discards all received characters. ts
##  main use is for calls to `Process' when the started program does not
##  write anything.
##
  
UNBIND_GLOBAL( "OutputTextNone" );
DeclareGlobalFunction( "OutputTextNone" );


#############################################################################
##
#F  OutputTextUser()  . . . . . . . . . . . .  output text stream to the user
##
##  returns an output stream which delivers characters to the user's display
##  (or the standard output device if it has been redirected). Each character
##  is delivered immediately it is written, without waiting for a full line
##  of output. Text written in this way is *not* written to the session log
##  (see "LogTo").
##

DeclareGlobalFunction( "OutputTextUser" );

#############################################################################
##
#F  InputOutputLocalProcess(<current-dir>, <executable>, <args>)
#F   . . .input/output stream to a process run as a "slave" on the local host
##
##
##  Calling `InputOutputLocalProcess( <current-dir>, <executable>, <args> )
##  starts up a slave process, whose executable file is <executable>, with
##  `command line' arguments <args> and current directory
##  <current-dir>. It returns an InputOutputStream object. Bytes
##  written to this stream are received by the slave process as if typed
##  at a terminal on standard input. Bytes written to standard output
##  by the slave process can be read from the stream (some buffering
##  of reads, but not writes may be done by the stream).
## 
DeclareGlobalFunction( "InputOutputLocalProcess" );

#############################################################################
##
#F  AppendTo( <stream>, <arg1>, ... ) . . . . . . . . . .  append to a stream
##
##  This is   the same as   `PrintTo'  for streams.   If   <stream> is just a
##  filename than there  is a difference:  `PrintTo'  will clear the    file,
##  `AppendTo' will not.
##
##  If <stream> is really a stream, then the kernel will generate a call to
##  `WriteAll' for each line of output.
##
BIND_GLOBAL( "AppendTo", function( arg )
    if IsString(arg[1])  then
        CallFuncList( APPEND_TO, arg );
    elif IsOutputStream(arg[1])  then
        CallFuncList( APPEND_TO_STREAM, arg );
    else
        Error( "first argument must be a filename or output stream" );
    fi;
end );


#############################################################################
##
#F  PrintTo( <stream>, <arg1>, ... )  . . . . . . . . . .  append to a stream
##
##  `PrintTo' appends <arg1>, ... to the output stream.
##
##  If <stream> is really a stream, then the kernel will generate a call to
##  `WriteAll' for each line of output.
##
BIND_GLOBAL( "PrintTo", function( arg )    
    if IsString(arg[1])  then
        CallFuncList( PRINT_TO, arg );
    elif IsOutputStream(arg[1])  then
        CallFuncList( PRINT_TO_STREAM, arg );
    else
        Error( "first argument must be a filename or output stream" );
    fi;
end );


#############################################################################
##
#F  LogTo( <stream> ) . . . . . . . . . . . . . . . . . . . . log to a stream
##
##  `LogTo' may be used with a stream, just as with a file. See "File
##   Operations" for details
##  
DeclareOperation( "LogTo", [ IsOutputStream ] );


#############################################################################
##
#O  InputLogTo( <stream> )  . . . . . . . . . . . . . . log input to a stream
##
##  `InputLogTo' may be used with a stream, just as with a file. See "File
##   Operations" for details
##
DeclareOperation( "InputLogTo", [ IsOutputStream ] );


#############################################################################
##
#O  OutputLogTo( <stream> ) . . . . . . . . . . . . .  log output to a stream
##
##  `OutputLogTo' may be used with a stream, just as with a file. See "File
##   Operations" for details
##
DeclareOperation( "OutputLogTo", [ IsOutputStream ] );

#############################################################################
##
#O  PrintFormattingStatus( <stream> ) . . . . . . . . is stream line-breaking
##
##  `PrintFormattingStatus( <stream> )' returns 'true' if output sent to 
##   the stream via `PrintTo', `AppendTo', etc. (but not `WriteByte',
##   `WriteLine' or `WriteAll') will be formatted with 
##   line breaks and indentation, and `false' otherwise.
##

DeclareOperation( "PrintFormattingStatus", [IsOutputTextStream] );

#############################################################################
##
#O  SetPrintFormattingStatus( <stream>, <newstatus> )
##
##  `SetPrintFormattingStatus( <stream>, <newstatus> )' sets whether 
##   output sent to 
##   the stream via `PrintTo', `AppendTo', etc. (but not `WriteByte',
##   `WriteLine' or `WriteAll') will be formatted with 
##   line breaks and indentation. If the second argument is `true'
##  then output will be so formatted, if `false' then it will not.
##

DeclareOperation( "SetPrintFormattingStatus", [IsOutputTextStream, IsBool] );


#############################################################################
##
#E  streams.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
