############################################################################
##
#W  streams.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for streams.
##
Revision.streams_gd :=
    "@(#)$Id$";

#1
##  *Streams* provide flexible access to {\GAP}'s input and output
##  processing. An *input stream* takes characters from some source and
##  delivers them to {\GAP} which *reads* them from the stream.  When an
##  input stream has delivered all characters it is at `end-of-stream'.  An
##  *output stream* receives characters from {\GAP} which *writes* them to
##  the stream, and delivers them to some destination.
## 
##  A major use of streams is to provide efficient and flexible access to
##  files.  Files can be read and written using `Read' and `AppendTo',
##  however the former only allows a complete file to be read as {\GAP}
##  input and the latter imposes a high time penalty if many small pieces of
##  output are written to a large file. Streams allow input files in other
##  formats to be read and processed, and files to be built up efficiently
##  from small pieces of output. Streams may also be used for other purposes, 
##  for example to read from and print to {\GAP} strings, or to read input
##  directly from the user.
## 
##  Any stream is either a *text stream*, which translates the `end-of-line'
##  character (`{'\\n'}') to or from the system's representation of
##  `end-of-line' (e.g., <new-line> under UNIX, <carriage-return> under
##  MacOS, <carriage-return>-<new-line> under DOS), or a *binary stream*,
##  which does not translate the `end-of-line' character. The processing of
##  other unprintable characters by text streams is undefined. Binary streams
##  pass them unchanged.
## 
##  Note that binary streams are *@not yet implemented@*.
## 
##  Whereas it is  cheap  to append  to a  stream, streams do  consume system
##  resources, and only a  limited number can  be open at any time, therefore
##  it is   necessary   to close   a  stream  as   soon as   possible  using
##  `CloseStream' described in Section~"CloseStream".   If creating  a stream
##  failed then `LastSystemError' (see "LastSystemError")  can be used to get
##  information about the failure. 
## 
## 

#############################################################################
##
#R  IsInputTextStringRep   (used in kernel)
##
DeclareRepresentation(
    "IsInputTextStringRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#C  IsClosedStream( <obj> ) . . . . . . . . . . .  category of closed streams
##
##  When a stream is closed, its type changes to lie in
##  'IsClosedStream'. This category is used to install methods that trap
##  accesses to closed streams.
##
DeclareCategory( "IsClosedStream", IsObject );


#############################################################################
##
#C  IsStream( <obj> ) . . . . . . . . . . . . . . . . . . category of streams
##
##  Streams are {\GAP} objects and all open streams, input, output, text
##  and binary, lie in this category.
##
DeclareCategory( "IsStream", IsObject );


#############################################################################
##
#C  IsInputStream( <obj> )  . . . . . . . . . . . . category of input streams
##
##  All input streams lie in this category, and support input
##  operations such as `ReadByte' (see "Operations for Input Streams")
##
DeclareCategory( "IsInputStream", IsStream );


#############################################################################
##
#C  IsInputTextStream( <obj> )  . . . . . . .  category of input text streams
##
##  All *text* input streams lie in this category. They translate new-line
##  characters read.
##
DeclareCategory( "IsInputTextStream", IsInputStream );


#############################################################################
##
#C  IsInputTextNone( <obj> )  . . . . . . category of input text none streams
##
##  It is convenient to use a category to distinguish dummy streams
##  (see "Dummy Streams") from others. Other distinctions are usually
##  made using representations
##
DeclareCategory( "IsInputTextNone", IsInputTextStream );


#############################################################################
##
#C  IsOutputStream( <obj> ) . . . . . . . . . . .  category of output streams
##
##  All output streams lie in this category and support basic
##  operations such as `WriteByte' (see "Operations for Output Streams")
##
DeclareCategory( "IsOutputStream", IsStream );


#############################################################################
##
#C  IsOutputTextStream( <obj> ) . . . . . . . category of output text streams
##
##  All *text* output streams lie in this category and translate
##  new-line characters on output.
##
DeclareCategory( "IsOutputTextStream", IsOutputStream );


#############################################################################
##
#C  IsOutputTextNone( <obj> ) . . . . .  category of output text none streams
##
##  It is convenient to use a category to distinguish dummy streams
##  (see "Dummy Streams") from others. Other distinctions are usually
##  made using representations
##

DeclareCategory( "IsOutputTextNone", IsOutputTextStream );


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
#O  ReadAll( <input-stream> , <limit> )  . .  read whole input as string
##
##  `ReadAll' returns all characters as string from the input stream
##  <stream-in>.  It waits (blocks) until at least one
##  character is available from the stream, or until there is evidence
##  that no characters will ever be available again. This last indicates
##  that the stream is at end-of-stream.
##  Otherwise, it reads as much input as it can from the stream without
##  blocking further and returns it to the user. If the stream is
##  already at end of file, so that no bytes are available, `fail' is
##   returned. In the case of a file
##  stream connected to a normal file (not a pseudo-tty or named pipe
##  or similar), all the bytes should be immediately available and
##  this function will read the remainder of the file.
##
##  With a second argument, at most <limit> bytes will be
##  returned. Depending on the stream a bounded number of additional bytes
##  may have been read into an internal buffer.  
##
##  A default method is supplied for `ReadAll' which simply calls `ReadLine'
##  repeatedly. This is only really safe for streams which cannot
##  block. Other streams should install a method for ReadAll
##
DeclareOperation( "ReadAll", [ IsInputStream ] );
DeclareOperation( "ReadAll", [ IsInputStream, IsInt ] );

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
##  method is installed for a user-defined type of stream which does
##  not block, then all the other
##  input stream operations will work (although possibly not at peak
##  efficiency).
##
##  `ReadByte' will wait (block) until a byte is available. For
##  instance if the stream is a connection to another process, it will
##  wait for the process to output a byte.
##
DeclareOperation( "ReadByte", [ IsInputStream ] );
                    

#############################################################################
##
#O  ReadLine( <input-stream> ) . read whole line (or what's there) as string
##
##  `ReadLine' returns one line (returned as string *with* the newline) from
##  the input stream <input-stream>.  `ReadLine' reads in the input until  a
##  newline is read or the end-of-stream is encountered.
##
##  If <input-stream> is the input stream of a input/output process, `ReadLine'
##  may also return `fail' or return an incomplete line if the other
##  process has not yet written any more. It will always wait (block) for at
##  least one byte to be available, but will then return as much input
##  as is available, up to a limit of one  line
##
##  A default method is supplied for `ReadLine' which simply calls `ReadByte'
##  repeatedly. This is only safe for streams that cannot block. The kernel 
##  uses calls to `ReadLine' to supply input to the
##  parser when reading from a stream.
##
DeclareOperation( "ReadLine", [ IsInputStream ] );


#############################################################################
##
#O  ReadAllLine( <iostream>[, <nofail>][, <IsAllLine>] ) . .  read whole line
##
##  For an input/output stream <iostream> `ReadAllLine' reads until a newline
##  character if any input is found or returns `fail' if no input  is  found,
##  i.e.~if any input is found `ReadAllLine' is non-blocking.
##
##  If the argument <nofail> (which must be `false' or  `true')  is  provided
##  and it is set to `true' then `ReadAllLine' will wait, if  necessary,  for
##  input and never return `fail'.
##
##  If the argument <IsAllLine> (which must be a function that takes a string
##  argument and returns either  `true'  or  `false')  then  it  is  used  to
##  determine what  constitutes  a  whole  line.  The  default  behaviour  is
##  equivalent to passing the function
##
##  \begintt
##  line -> 0 < Length(line) and line[Length(line)] = '\n'
##  \endtt
##
##  for the <IsAllLine> argument. The purpose of the <IsAllLine> argument  is
##  to cater for the case where the input being  read  is  from  an  external
##  process that writes a ``prompt'' for data that does not terminate with  a
##  newline.
##
##  If the first argument is an input stream but not an  input/output  stream
##  then `ReadAllLine' behaves as if `ReadLine'  was  called  with  just  the
##  first argument and any additional arguments are ignored.
##
DeclareOperation( "ReadAllLine", [ IsInputStream, IsBool, IsFunction ] );


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
##  appends  <string> to <output-stream>.   No final  newline is written.
##  The function returns `true' if the write succeeds and `fail' otherwise.
##  It will block as long as necessary for the write operation to
##  complete (for example for a child process to clear its input buffer )
##
##  A default method is installed which implements `WriteAll' by repeated
##  calls to `WriteByte'.
##
##  When printing or appending to a stream (using `PrintTo', or `AppendTo' or
##  when logging to a stream), the kernel generates a call to `WriteAll' for
##  each line output.
##

DeclareOperation( "WriteAll", [ IsOutputStream, IsList ] );
                    

#############################################################################
##
#O  WriteByte( <output-stream>, <byte> )  . . . . . . . . . write single byte
##
##  writes the  next  character  (given  as *integer*)  to the  output stream
##  <output-stream>.  The function  returns `true' if  the write succeeds and
##  `fail' otherwise.
## 
##  `WriteByte' is the basic operation for output streams. If a `WriteByte'
##  method is installed for a user-defined type of stream, then all the other
##  output stream operations will work (although possibly not at peak
##  efficiency).
##
DeclareOperation( "WriteByte", [ IsOutputStream, IsInt ] );
                    

#############################################################################
##
#O  WriteLine( <output-stream>, <string> ) .   write string plus newline
##
##  appends  <string> to <output-stream>.   A  final newline is written.
##  The function returns `true' if the write succeeds and `fail' otherwise.
##
##  A default method is installed which implements `WriteLine' by repeated
##  calls to `WriteByte'.
##
DeclareOperation( "WriteLine", [ IsOutputStream, IsList ] );
                    

#############################################################################
##
#O  CloseStream( <stream> ) . . . . . . . . . . . . . . . . .  close a stream
##
##  In order  to preserve system resources  and to flush output streams every
##  stream should  be  closed  as soon   as  it is   no longer   used using
##  `CloseStream'.
## 
##  It is an error to  try to read  characters from or  write characters to a
##  closed  stream.   Closing a  stream tells  the {\GAP}   kernel and/or the
##  operating system kernel  that the file is  no longer needed.  This may be
##  necessary  because  the {\GAP} kernel  and/or  the  operating  system may
##  impose a limit on how many streams may be open simultaneously.
##
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
##  returns a dummy output stream, which discards all received characters. 
##  Its main use is for calls to `Process' (see~"Process") when the started
##  program does not write anything.
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

#2
##  Input-output streams capture bidirectional 
##  communications between {\GAP} and another process, either locally
##  or (@as yet unimplemented@) remotely.
##
##  Such streams support the basic operations of both input and output 
##  streams. They should provide some buffering, allowing output data to be
##  written to the stream, even when input data is waiting to be read,
##  but the amount of this buffering is operating system dependent,
##  and the user should take care not to get too far ahead in writing, or 
##  behind in reading, or deadlock may occur.
##



#############################################################################
##
#C  IsInputOutputStream( <obj> )  . . . . . . . . category of two-way streams 
##
##  `IsInputOutputStream' is the Category of Input-Output Streams; it returns
##  `true' if the <obj> is an input-output stream and `false' otherwise.
##

DeclareCategory( "IsInputOutputStream", IsInputStream and
        IsOutputStream );


#3  
##  At present the only type of Input-Output streams that are
##  implemented provide communication with a local child process,
##  using a pseudo-tty.
##
##  Like other streams, write operations are blocking, read operations
##  will block to get the first character, but not thereafter. 
##
##  As far as possible, no translation is done on characters written
##  to, or read from the stream, and no control characters have special
##  effects, but the details of particular pseudo-tty implementations 
##  may effect this. 
##

#############################################################################
##
#F  InputOutputLocalProcess(<dir>, <executable>, <args>) %
##   . . .input/output stream to a process run as a "slave" on the local host
##
##  starts up a slave process, whose executable file is <executable>, with
##  ``command line'' arguments <args> in the directory <dir>. (Suitable 
##  choices for <dir> are `DirectoryCurrent()' or `DirectoryTemporary()'
##  (see Section~"Directories"); `DirectoryTemporary()' may be a good choice
##  when <executable> generates output files that it doesn't itself remove
##  afterwards.) 
##  `InputOutputLocalProcess' returns an InputOutputStream object. Bytes
##  written to this stream are received by the slave process as if typed
##  at a terminal on standard input. Bytes written to standard output
##  by the slave process can be read from the stream. 
##
##  When the stream is closed, the signal SIGTERM is delivered to the child
##  process, which is expected to exit.
##
DeclareGlobalFunction( "InputOutputLocalProcess" );

#############################################################################
##
#O  PrintFormattingStatus( <stream> ) . . . . . . . . is stream line-breaking
##
##  returns `true' if output sent to the output text stream <stream> via
##  `PrintTo', `AppendTo', etc.  (but not `WriteByte', `WriteLine' or
##  `WriteAll') will be formatted with line breaks and indentation, and
##  `false' otherwise (see~"SetPrintFormattingStatus"). For non-text
##  streams, it returns `false'.
##

DeclareOperation( "PrintFormattingStatus", [IsOutputStream] );

#############################################################################
##
#O  SetPrintFormattingStatus( <stream>, <newstatus> )
##
##  sets whether output sent to the output  stream  <stream>  via  `PrintTo',
##  `AppendTo', etc. (but not `WriteByte', `WriteLine' or `WriteAll') will be
##  formatted with line  breaks  and  indentation.  If  the  second  argument
##  <newstatus> is `true' then output will be so formatted,  and  if  `false'
##  then it will not. If the stream is not a text stream, only `false'
##  is allowed.
##

DeclareOperation( "SetPrintFormattingStatus", [IsOutputStream, IsBool] );

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
        arg := ShallowCopy(arg);
        arg[1] := USER_HOME_EXPAND(arg[1]);
        CallFuncList( APPEND_TO, arg );
    elif IsOutputStream(arg[1])  then
        # direct call to `WriteAll' if arg is one string and formatting
        # is switched off
        if Length(arg) = 2 and ( not IsOutputTextStream( arg[1] ) or
           PrintFormattingStatus(arg[1]) = false ) and IsStringRep(arg[2]) then
           WriteAll(arg[1], arg[2]);
        else
          CallFuncList( APPEND_TO_STREAM, arg );
        fi;
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
        arg := ShallowCopy(arg);
        arg[1] := USER_HOME_EXPAND(arg[1]);
        CallFuncList( PRINT_TO, arg );
    elif IsOutputStream(arg[1])  then
        # direct call to `WriteAll' if arg is one string and formatting
        # is switched off
        if Length(arg) = 2 and ( not IsOutputTextStream( arg[1] ) or
           PrintFormattingStatus(arg[1]) = false ) and IsStringRep(arg[2]) then
           WriteAll(arg[1], arg[2]);
        else
          CallFuncList( PRINT_TO_STREAM, arg );
        fi;
    else
        Error( "first argument must be a filename or output stream" );
    fi;
end );


#############################################################################
##
#O  LogTo( <stream> ) . . . . . . . . . . . . . . . . . . . . log to a stream
##
##  causes the subsequent interaction to  be  logged  to  the  output  stream
##  <stream>. It works in precisely  the  same  way  as  it  does  for  files
##  (see~"LogTo").
##
DeclareOperation( "LogTo", [ IsOutputStream ] );


#############################################################################
##
#O  InputLogTo( <stream> )  . . . . . . . . . . . . . . log input to a stream
##
##  causes the subsequent input to be logged to the output  stream  <stream>.
##  It works just like it does for files (see~"InputLogTo").
##
DeclareOperation( "InputLogTo", [ IsOutputStream ] );
DeclareSynonym( "LogInputTo",InputLogTo);


#############################################################################
##
#O  OutputLogTo( <stream> ) . . . . . . . . . . . . .  log output to a stream
##
##  causes the subsequent output to be logged to the output stream  <stream>.
##  It works just like it does for files (see~"OutputLogTo").
##
DeclareOperation( "OutputLogTo", [ IsOutputStream ] );
DeclareSynonym( "LogOutputTo",OutputLogTo);

#############################################################################
##
#O  FileDescriptorOfStream( <stream> )
##
##  returns the UNIX file descriptor of the underlying file. This is mainly
##  useful for the `UNIXSelect' function call (see~"UNIXSelect"). This is
##  as of now only available on UNIX-like operating systems and only for
##  streams to local processes and local files.
##

DeclareOperation("FileDescriptorOfStream", [IsStream] );


#############################################################################
##
#V  OnCharReadHookInFuncs . . . . . . . installed handler functions for input
##
##  contains a list of functions that are installed as reading handlers for
##  streams.
##
DeclareGlobalVariable( "OnCharReadHookInFuncs",
                       "installed input handlers for streams" );
#############################################################################
##
#V  OnCharReadHookInFds . . . . . . . . file descriptors for reading handlers
##
##  contains a list of file descriptors of streams for which reading handlers
##  are installed.
##
DeclareGlobalVariable( "OnCharReadHookInFds",
                       "UNIX file descriptors of input streams" );
#############################################################################
##
#V  OnCharReadHookInStreams . . . . . . . . . . streams with reading handlers
##
##  contains a list of streams for which reading handlers are installed.
##
DeclareGlobalVariable( "OnCharReadHookInStreams",
                       "input streams for which handlers are installed" );
#############################################################################
##
#V  OnCharReadHookOutFuncs . . . . . . installed handler functions for output
##
##  contains a list of functions that are installed as reading handlers for
##  streams.
##
DeclareGlobalVariable( "OnCharReadHookOutFuncs",
                       "installed output handlers for streams" );
#############################################################################
##
#V  OnCharReadHookOutFds . . . . . . .  file descriptors for writing handlers
##
##  contains a list of file descriptors of streams for which writing handlers
##  are installed.
##
DeclareGlobalVariable( "OnCharReadHookOutFds",
                       "UNIX file descriptors of output streams" );
#############################################################################
##
#V  OnCharReadHookOutStreams . . . . . . . . . . streams with writing handlers
##
##  contains a list of streams for which writing handlers are installed.
##
DeclareGlobalVariable( "OnCharReadHookOutStreams",
                       "output streams for which handlers are installed" );
#############################################################################
##
#V  OnCharReadHookExcFuncs . . . . installed handler functions for exceptions
##
##  contains a list of functions that are installed as exception handlers
##  for streams.
##
DeclareGlobalVariable( "OnCharReadHookExcFuncs",
                       "installed exception handlers for streams" );
#############################################################################
##
#V  OnCharReadHookExcFds  . . . . . . file descriptors for exception handlers
##
##  contains a list of file descriptors of streams for which exception 
##  handlers are installed.
##
DeclareGlobalVariable( "OnCharReadHookExcFds",
                       "UNIX file descriptors of streams" );
#############################################################################
##
#V  OnCharReadHookExcStreams . . . . . . . .  streams with exception handlers
##
##  contains a list of streams for which exception handlers are installed.
##
DeclareGlobalVariable( "OnCharReadHookExcStreams",
                       "streams for which handlers are installed" );


#############################################################################
##
#F  InstallCharReadHookFunc( <stream>, <mode>, <func> )
##
##  installs the function <func> as a handler function for the stream
##  <stream>. The argument <mode> decides, for what operations on the
##  stream this function is installed. <mode> must be a string, in which
##  a letter `r' means ``read'', `w' means ``write'' and `x' means
##  ``exception'', according to the `select' function call in the UNIX
##  C-library (see `man select' and "UNIXSelect"). More than one letter 
##  is allowed in <mode>. As described above the function is called
##  in a situation when {\GAP} is reading a character from the keyboard.
##  Handler functions should not use much time to complete.
##
##  This functionality does not work on the Macintosh architecture and
##  only works if the operating system has a `select' function.
##
DeclareGlobalFunction( "InstallCharReadHookFunc" );


#############################################################################
##
#F  UnInstallCharReadHookFunc( <stream>, <func> )
##
##  uninstalls the function <func> as a handler function for the stream
##  <stream>. All instances are deinstalled, regardless of the mode
##  of operation (read, write, exception).
##
##  This functionality does not work on the Macintosh architecture and
##  only works if the operating system has a `select' function.
##
DeclareGlobalFunction( "UnInstallCharReadHookFunc" );



#############################################################################
##
#E  streams.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
