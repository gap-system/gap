#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for streams.
##


##  <#GAPDoc Label="[1]{streams}">
##  <E>Streams</E> provide flexible access to &GAP;'s input and output
##  processing. An <E>input stream</E> takes characters from some source and
##  delivers them to &GAP; which <E>reads</E> them from the stream.  When an
##  input stream has delivered all characters it is at <C>end-of-stream</C>.  An
##  <E>output stream</E> receives characters from &GAP; which <E>writes</E> them to
##  the stream, and delivers them to some destination.
##  <P/>
##  A major use of streams is to provide efficient and flexible access to
##  files.  Files can be read and written using
##  <Ref Oper="Read"/> and <Ref Func="AppendTo"/>,
##  however the former only allows a complete file to be read as &GAP;
##  input and the latter imposes a high time penalty if many small pieces of
##  output are written to a large file. Streams allow input files in other
##  formats to be read and processed, and files to be built up efficiently
##  from small pieces of output. Streams may also be used for other purposes,
##  for example to read from and print to &GAP; strings, or to read input
##  directly from the user.
##  <P/>
##  Any stream is either a <E>text stream</E>, which translates the <C>end-of-line</C>
##  character (<C>\n</C>) to or from the system's representation of
##  <C>end-of-line</C> (e.g., <E>new-line</E> under UNIX and
##  <E>carriage-return</E>-<E>new-line</E> under DOS), or a <E>binary stream</E>,
##  which does not translate the <C>end-of-line</C> character. The processing of
##  other unprintable characters by text streams is undefined. Binary streams
##  pass them unchanged.
##  <P/>
##  Whereas it is  cheap  to append  to a  stream, streams do  consume system
##  resources, and only a  limited number can  be open at any time, therefore
##  it is   necessary   to close   a  stream  as   soon as   possible  using
##  <Ref Oper="CloseStream"/>.   If creating  a stream
##  failed then <Ref Func="LastSystemError"/> can be used to get
##  information about the failure.
##  <#/GAPDoc>
##


#############################################################################
##
#R  IsInputTextStringRep   (used in kernel)
##
##  <ManSection>
##  <Filt Name="IsInputTextStringRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation(
    "IsInputTextStringRep",
    IsPositionalObjectRep );


#############################################################################
##
#R  IsOutputTextStringRep   (used in kernel)
##
##  <ManSection>
##  <Filt Name="IsOutputTextStringRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation(
    "IsOutputTextStringRep",
    IsPositionalObjectRep );


#############################################################################
##
#C  IsClosedStream( <obj> ) . . . . . . . . . . .  category of closed streams
##
##  <#GAPDoc Label="IsClosedStream">
##  <ManSection>
##  <Filt Name="IsClosedStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  When a stream is closed, its type changes to lie in
##  <Ref Filt="IsClosedStream"/>. This category is used to install methods that trap
##  accesses to closed streams.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsClosedStream", IsObject );


#############################################################################
##
#C  IsStream( <obj> ) . . . . . . . . . . . . . . . . . . category of streams
##
##  <#GAPDoc Label="IsStream">
##  <ManSection>
##  <Filt Name="IsStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  Streams are &GAP; objects and all open streams, input, output, text
##  and binary, lie in this category.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsStream", IsObject );


#############################################################################
##
#C  IsInputStream( <obj> )  . . . . . . . . . . . . category of input streams
##
##  <#GAPDoc Label="IsInputStream">
##  <ManSection>
##  <Filt Name="IsInputStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  All input streams lie in this category, and support input
##  operations such as <Ref Oper="ReadByte"/> (see <Ref Sect="Operations for Input Streams"/>)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsInputStream", IsStream );


#############################################################################
##
#C  IsInputTextStream( <obj> )  . . . . . . .  category of input text streams
##
##  <#GAPDoc Label="IsInputTextStream">
##  <ManSection>
##  <Filt Name="IsInputTextStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  All <E>text</E> input streams lie in this category. They translate new-line
##  characters read.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsInputTextStream", IsInputStream );


#############################################################################
##
#C  IsInputTextNone( <obj> )  . . . . . . category of input text none streams
##
##  <#GAPDoc Label="IsInputTextNone">
##  <ManSection>
##  <Filt Name="IsInputTextNone" Arg='obj' Type='Category'/>
##
##  <Description>
##  It is convenient to use a category to distinguish dummy streams
##  (see <Ref Sect="Dummy Streams"/>) from others. Other distinctions are usually
##  made using representations
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsInputTextNone", IsInputTextStream );


#############################################################################
##
#C  IsOutputStream( <obj> ) . . . . . . . . . . .  category of output streams
##
##  <#GAPDoc Label="IsOutputStream">
##  <ManSection>
##  <Filt Name="IsOutputStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  All output streams lie in this category and support basic
##  operations such as <Ref Oper="WriteByte"/>
##  (see Section <Ref Sect="Operations for Output Streams"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsOutputStream", IsStream );


#############################################################################
##
#C  IsOutputTextStream( <obj> ) . . . . . . . category of output text streams
##
##  <#GAPDoc Label="IsOutputTextStream">
##  <ManSection>
##  <Filt Name="IsOutputTextStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  All <E>text</E> output streams lie in this category and translate
##  new-line characters on output.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsOutputTextStream", IsOutputStream );


#############################################################################
##
#C  IsOutputTextNone( <obj> ) . . . . .  category of output text none streams
##
##  <#GAPDoc Label="IsOutputTextNone">
##  <ManSection>
##  <Filt Name="IsOutputTextNone" Arg='obj' Type='Category'/>
##
##  <Description>
##  It is convenient to use a category to distinguish dummy streams
##  (see <Ref Sect="Dummy Streams"/>) from others. Other distinctions are usually
##  made using representations
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareCategory( "IsOutputTextNone", IsOutputTextStream );


#############################################################################
##
#V  StreamsFamily . . . . . . . . . . . . . . . . . . . family of all streams
##
##  <#GAPDoc Label="StreamsFamily">
##  <ManSection>
##  <Fam Name="StreamsFamily"/>
##
##  <Description>
##  All streams lie in the <Ref Fam="StreamsFamily"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
StreamsFamily := NewFamily( "StreamsFamily" );


#############################################################################
##
#O  IsEndOfStream( <input-stream> ) . . . . . . . . . check for end-of-stream
##
##  <#GAPDoc Label="IsEndOfStream">
##  <ManSection>
##  <Oper Name="IsEndOfStream" Arg='input-stream'/>
##
##  <Description>
##  <Ref Oper="IsEndOfStream"/> returns <K>true</K> if the input stream is at <E>end-of-stream</E>,
##  and <K>false</K> otherwise.  Note   that <Ref Oper="IsEndOfStream"/> might  return <K>false</K>
##  even if the next <Ref Oper="ReadByte"/> fails.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsEndOfStream", [ IsInputStream ] );


#############################################################################
##
#O  PositionStream( <input-stream> )  . . . . . . . . . . .  current position
##
##  <#GAPDoc Label="PositionStream">
##  <ManSection>
##  <Oper Name="PositionStream" Arg='input-stream'/>
##
##  <Description>
##  Some input streams, such as string streams and file streams attached to
##  disk files, support a form of random access by way of the operations
##  <Ref Oper="PositionStream"/>, <Ref Oper="SeekPositionStream"/> and
##  <Ref Oper="RewindStream"/>. <Ref Oper="PositionStream"/>
##  returns a non-negative integer denoting
##  the current position in the stream (usually the number of characters
##  <E>before</E> the next one to be read.
##  <P/>
##  If this is not possible, for example for an input stream attached to
##  standard input (normally the keyboard), then <K>fail</K> is returned
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareOperation( "PositionStream", [ IsInputStream ] );


#############################################################################
##
#O  ReadAll( <input-stream> )  . . . . . . .  read whole input as string
#O  ReadAll( <input-stream> , <limit> )  . .  read whole input as string
##
##  <#GAPDoc Label="ReadAll">
##  <ManSection>
##  <Oper Name="ReadAll" Arg='input-stream[, limit]'/>
##
##  <Description>
##  <Ref Oper="ReadAll"/> returns all characters as string from the input stream
##  <A>stream-in</A>.  It waits (blocks) until at least one
##  character is available from the stream, or until there is evidence
##  that no characters will ever be available again. This last indicates
##  that the stream is at end-of-stream.
##  Otherwise, it reads as much input as it can from the stream without
##  blocking further and returns it to the user. If the stream is
##  already at end of file, so that no bytes are available, <K>fail</K> is
##  returned. In the case of a file
##  stream connected to a normal file (not a pseudo-tty or named pipe
##  or similar), all the bytes should be immediately available and
##  this function will read the remainder of the file.
##  <P/>
##  With a second argument, at most <A>limit</A> bytes will be
##  returned. Depending on the stream a bounded number of additional bytes
##  may have been read into an internal buffer.
##  <P/>
##  A default method is supplied for <Ref Oper="ReadAll"/> which simply calls
##  <Ref Oper="ReadLine"/> repeatedly.
##  This is only really safe for streams which cannot block.
##  Other streams should install a method for <Ref Oper="ReadAll"/>
##  <P/>
##  <Example><![CDATA[
##  gap> i := InputTextString( "1Hallo\nYou\n1" );;
##  gap> ReadByte(i);
##  49
##  gap> CHAR_INT(last);
##  '1'
##  gap> ReadLine(i);
##  "Hallo\n"
##  gap> ReadLine(i);
##  "You\n"
##  gap> ReadLine(i);
##  "1"
##  gap> ReadLine(i);
##  fail
##  gap> ReadAll(i);
##  ""
##  gap> RewindStream(i);;
##  gap> ReadAll(i);
##  "1Hallo\nYou\n1"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ReadAll", [ IsInputStream ] );
DeclareOperation( "ReadAll", [ IsInputStream, IsInt ] );

#############################################################################
##
#O  ReadByte( <input-stream> )  . . . . . . . . . . . . . .  read single byte
##
##  <#GAPDoc Label="ReadByte">
##  <ManSection>
##  <Oper Name="ReadByte" Arg='input-stream'/>
##
##  <Description>
##  <Ref Oper="ReadByte"/> returns  one character (returned  as  integer) from  the input
##  stream <A>input-stream</A>.  <Ref Oper="ReadByte"/> returns <K>fail</K> if there is no character
##  available, in particular if it is at the end of a file.
##  <P/>
##  If <A>input-stream</A> is the input stream of  a input/output process, <Ref Oper="ReadByte"/>
##  may also return <K>fail</K> if no byte is currently available.
##  <P/>
##  <Ref Oper="ReadByte"/> is the basic operation for input streams. If a <Ref Oper="ReadByte"/>
##  method is installed for a user-defined type of stream which does
##  not block, then all the other
##  input stream operations will work (although possibly not at peak
##  efficiency).
##  <P/>
##  <Ref Oper="ReadByte"/> will wait (block) until a byte is available. For
##  instance if the stream is a connection to another process, it will
##  wait for the process to output a byte.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ReadByte", [ IsInputStream ] );


#############################################################################
##
#O  ReadLine( <input-stream> ) . read whole line (or what's there) as string
##
##  <#GAPDoc Label="ReadLine">
##  <ManSection>
##  <Oper Name="ReadLine" Arg='input-stream'/>
##
##  <Description>
##  <Ref Oper="ReadLine"/> returns one line (returned as string <E>with</E> the newline) from
##  the input stream <A>input-stream</A>.  <Ref Oper="ReadLine"/> reads in the input until  a
##  newline is read or the end-of-stream is encountered.
##  <P/>
##  If <A>input-stream</A> is the input stream of a input/output process, <Ref Oper="ReadLine"/>
##  may also return <K>fail</K> or return an incomplete line if the other
##  process has not yet written any more. It will always wait (block) for at
##  least one byte to be available, but will then return as much input
##  as is available, up to a limit of one  line
##  <P/>
##  A default method is supplied for <Ref Oper="ReadLine"/> which simply calls <Ref Oper="ReadByte"/>
##  repeatedly. This is only safe for streams that cannot block. The kernel
##  uses calls to <Ref Oper="ReadLine"/> to supply input to the
##  parser when reading from a stream.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ReadLine", [ IsInputStream ] );


#############################################################################
##
#O  ReadAllLine( <iostream>[, <nofail>][, <IsAllLine>] ) . .  read whole line
##
##  <#GAPDoc Label="ReadAllLine">
##  <ManSection>
##  <Oper Name="ReadAllLine" Arg='iostream[, nofail][, IsAllLine]'/>
##
##  <Description>
##  For an input/output stream <A>iostream</A> <Ref Oper="ReadAllLine"/> reads until a newline
##  character if any input is found or returns <K>fail</K> if no input  is  found,
##  i.e.&nbsp;if any input is found <Ref Oper="ReadAllLine"/> is non-blocking.
##  <P/>
##  If the argument <A>nofail</A> (which must be <K>false</K> or  <K>true</K>)  is  provided
##  and it is set to <K>true</K> then <Ref Oper="ReadAllLine"/> will wait, if  necessary,  for
##  input and never return <K>fail</K>.
##  <P/>
##  If the argument <A>IsAllLine</A> (which must be a function that takes a string
##  argument and returns either  <K>true</K>  or  <K>false</K>)  then  it  is  used  to
##  determine what  constitutes  a  whole  line.  The  default  behaviour  is
##  equivalent to passing the function
##  <P/>
##  <Log><![CDATA[
##  line -> 0 < Length(line) and line[Length(line)] = '\n'
##  ]]></Log>
##  <P/>
##  for the <A>IsAllLine</A> argument. The purpose of the <A>IsAllLine</A> argument  is
##  to cater for the case where the input being  read  is  from  an  external
##  process that writes a <Q>prompt</Q> for data that does not terminate with  a
##  newline.
##  <P/>
##  If the first argument is an input stream but not an  input/output  stream
##  then <Ref Oper="ReadAllLine"/> behaves as if <Ref Oper="ReadLine"/>  was  called  with  just  the
##  first argument and any additional arguments are ignored.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ReadAllLine", [ IsInputStream, IsBool, IsFunction ] );


#############################################################################
##
#O  RewindStream( <input-stream> )  . . . . . . . . . return to the beginning
##
##  <#GAPDoc Label="RewindStream">
##  <ManSection>
##  <Oper Name="RewindStream" Arg='input-stream'/>
##
##  <Description>
##  <Ref Oper="RewindStream"/> attempts to return an input stream to its starting
##  condition, so that all the same characters can be read again. It returns
##  <K>true</K> if the rewind succeeds and <K>fail</K> otherwise
##  <P/>
##  A default method implements RewindStream using <Ref Oper="SeekPositionStream"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RewindStream", [ IsInputStream ] );


#############################################################################
##
#O  SeekPositionStream( <input-stream>, <pos> ) . . . .  return to a position
##
##  <#GAPDoc Label="SeekPositionStream">
##  <ManSection>
##  <Oper Name="SeekPositionStream" Arg='input-stream, pos'/>
##
##  <Description>
##  <Ref Oper="SeekPositionStream"/> attempts to rewind or wind forward an input stream
##  to the specified position. This is not possible for all streams. It
##  returns <K>true</K> if the seek is successful and <K>fail</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SeekPositionStream", [ IsInputStream, IsInt ] );


#############################################################################
##
#O  WriteAll( <output-stream>, <string> )  .  write whole string to file
##
##  <#GAPDoc Label="WriteAll">
##  <ManSection>
##  <Oper Name="WriteAll" Arg='output-stream, string'/>
##
##  <Description>
##  appends <A>string</A> to <A>output-stream</A>.
##  No final  newline is written.
##  The function returns <K>true</K> if the write succeeds
##  and <K>fail</K> otherwise.
##  It will block as long as necessary for the write operation to
##  complete (for example for a child process to clear its input buffer )
##  <P/>
##  A default method is installed which implements <Ref Oper="WriteAll"/>
##  by repeated calls to <Ref Oper="WriteByte"/>.
##  <P/>
##  When printing or appending to a stream (using <Ref Func="PrintTo"/>,
##  or <Ref Func="AppendTo"/> or when logging to a stream),
##  the kernel generates a call to <Ref Oper="WriteAll"/> for each line
##  output.
##  <P/>
##  <Example><![CDATA[
##  gap> str := "";; a := OutputTextString(str,true);;
##  gap> WriteByte(a,INT_CHAR('H'));
##  true
##  gap> WriteLine(a,"allo");
##  true
##  gap> WriteAll(a,"You\n");
##  true
##  gap> CloseStream(a);
##  gap> Print(str);
##  Hallo
##  You
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "WriteAll", [ IsOutputStream, IsString ] );


#############################################################################
##
#O  WriteByte( <output-stream>, <byte> )  . . . . . . . . . write single byte
##
##  <#GAPDoc Label="WriteByte">
##  <ManSection>
##  <Oper Name="WriteByte" Arg='output-stream, byte'/>
##
##  <Description>
##  writes the  next  character  (given  as <E>integer</E>)  to the  output stream
##  <A>output-stream</A>.  The function  returns <K>true</K> if  the write succeeds and
##  <K>fail</K> otherwise.
##  <P/>
##  <Ref Oper="WriteByte"/> is the basic operation for output streams. If a <Ref Oper="WriteByte"/>
##  method is installed for a user-defined type of stream, then all the other
##  output stream operations will work (although possibly not at peak
##  efficiency).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "WriteByte", [ IsOutputStream, IsInt ] );


#############################################################################
##
#O  WriteLine( <output-stream>, <string> ) .   write string plus newline
##
##  <#GAPDoc Label="WriteLine">
##  <ManSection>
##  <Oper Name="WriteLine" Arg='output-stream, string'/>
##
##  <Description>
##  appends  <A>string</A> to <A>output-stream</A>.   A  final newline is written.
##  The function returns <K>true</K> if the write succeeds and <K>fail</K> otherwise.
##  <P/>
##  A default method is installed which implements <Ref Oper="WriteLine"/> by repeated
##  calls to <Ref Oper="WriteByte"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "WriteLine", [ IsOutputStream, IsString ] );


#############################################################################
##
#O  CloseStream( <stream> ) . . . . . . . . . . . . . . . . .  close a stream
##
##  <#GAPDoc Label="CloseStream">
##  <ManSection>
##  <Oper Name="CloseStream" Arg='stream'/>
##
##  <Description>
##  In order  to preserve system resources  and to flush output streams every
##  stream should  be  closed  as soon   as  it is   no longer   used using
##  <Ref Oper="CloseStream"/>.
##  <P/>
##  It is an error to  try to read  characters from or  write characters to a
##  closed  stream.   Closing a  stream tells  the &GAP;   kernel and/or the
##  operating system kernel  that the file is  no longer needed.  This may be
##  necessary  because  the &GAP; kernel  and/or  the  operating  system may
##  impose a limit on how many streams may be open simultaneously.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CloseStream", [ IsStream ] );


#############################################################################
##
#O  InputTextString( <string> ) . . . .  create input text stream from string
##
##  <#GAPDoc Label="InputTextString">
##  <ManSection>
##  <Oper Name="InputTextString" Arg='string'/>
##
##  <Description>
##  <C>InputTextString(  <A>string</A>  )</C>  returns an  input  stream
##  that  delivers the  characters  from the  string <A>string</A>.  The
##  <A>string</A> is  not changed  when reading  characters from  it and
##  changing the <A>string</A> after the call to
##  <Ref Oper="InputTextString"/> has no influence on the input stream.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareOperation( "InputTextString", [ IsString ] );


#############################################################################
##
#O  InputTextFile( <filename> )  . . . .  create input text stream from file
##
##  <#GAPDoc Label="InputTextFile">
##  <ManSection>
##  <Oper Name="InputTextFile" Arg='filename'/>
##
##  <Description>
##  <C>InputTextFile( <A>filename</A> )</C> returns an input stream in the category
##  <Ref Filt="IsInputTextStream"/> that delivers the characters from the file
##  <A>filename</A>. If <A>filename</A> ends in <C>.gz</C> and the file is
##  a valid gzipped file, then the file will be transparently uncompressed.
##  <P/>
##  <C>InputTextFile</C> is designed for use with text files and automatically
##  handles windows-style line endings. This means it should <E>not</E> be used for
##  binary data. The <Ref BookName="IO" Oper="IO_File" /> function from the <Package>IO</Package>
##  package should be used to access binary data.
##  <P/>
##  Note: At most 256 files may be open for reading or writing at the same time.
##  Use <Ref Oper="CloseStream"/> to close the input stream once you have finished
##  reading from it.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "InputTextFile", [ IsString ] );


#############################################################################
##
#F  InputTextNone() . . . . . . . . . . . . . . . . . dummy input text stream
##
##  <#GAPDoc Label="InputTextNone">
##  <ManSection>
##  <Func Name="InputTextNone" Arg=''/>
##
##  <Description>
##  returns a dummy input text stream, which delivers no characters, i.e., it
##  is always at end of stream.  Its main use is for calls to
##  <Ref Oper="Process"/> when the started program does not read anything.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

UNBIND_GLOBAL( "InputTextNone" );
DeclareGlobalFunction( "InputTextNone" );


#############################################################################
##
#F  InputTextUser() . . . . . . . . . . . . . input text stream from the user
##
##  <#GAPDoc Label="InputTextUser">
##  <ManSection>
##  <Func Name="InputTextUser" Arg=''/>
##
##  <Description>
##  returns an input text stream which delivers characters typed by the user
##  (or from the standard input device if it has been redirected). In normal
##  circumstances, characters are delivered one by one as they are typed,
##  without waiting until the end of a line. No prompts are printed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InputTextUser" );


#############################################################################
##
#O  OutputTextString( <list>, <append> )  . . . . create output text stream
##
##  <#GAPDoc Label="OutputTextString">
##  <ManSection>
##  <Oper Name="OutputTextString" Arg='list, append'/>
##
##  <Description>
##  returns an output stream that puts all received characters into the list
##  <A>list</A>.
##  If <A>append</A> is <K>false</K>, then the list is emptied first,
##  otherwise received characters are added at the end of the list.
##  <P/>
##  <Example><![CDATA[
##  gap> # read input from a string
##  gap> input := InputTextString( "Hallo\nYou\n" );;
##  gap> ReadLine(input);
##  "Hallo\n"
##  gap> ReadLine(input);
##  "You\n"
##  gap> # print to a string
##  gap> str := "";;
##  gap> out := OutputTextString( str, true );;
##  gap> PrintTo( out, 1, "\n", (1,2,3,4)(5,6), "\n" );
##  gap> CloseStream(out);
##  gap> Print( str );
##  1
##  (1,2,3,4)(5,6)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OutputTextString", [ IsList, IsBool ] );


#############################################################################
##
#O  OutputTextFile( <filename>, <append> )  . . . create output text stream
##
##  <#GAPDoc Label="OutputTextFile">
##  <ManSection>
##  <Oper Name="OutputTextFile" Arg='filename, append'/>
##  <Oper Name="OutputGzipFile" Arg='filename, append'/>
##
##  <Description>
##  <C>OutputTextFile( <A>filename</A>, <A>append</A> )</C> returns an output stream in the
##  category <C>IsOutputTextFile</C> that writes received characters to the file
##  <A>filename</A>.  If <A>append</A> is <K>false</K>, then the file is emptied first,
##  otherwise received characters are added at the end of the file.
##  <C>OutputGzipFile</C> acts identically to <C>OutputTextFile</C>, except it compresses
##  the output with gzip.
##  <P/>
##  Note: At most 256 files may be open for reading or writing at the same time.
##  Use <Ref Oper="CloseStream"/> to close the output stream once you have finished
##  writing to it.
##  <P/>
##  <Example><![CDATA[
##  gap> # use a temporary directory
##  gap> name := Filename( DirectoryTemporary(), "test" );;
##  gap> # create an output stream, append output, and close again
##  gap> output := OutputTextFile( name, true );;
##  gap> AppendTo( output, "Hallo\n", "You\n" );
##  gap> CloseStream(output);
##  gap> # create an input, print complete contents of file, and close
##  gap> input := InputTextFile(name);;
##  gap> Print( ReadAll(input) );
##  Hallo
##  You
##  gap> CloseStream(input);
##  gap> # append a single line
##  gap> output := OutputTextFile( name, true );;
##  gap> AppendTo( output, "AppendLine\n" );
##  gap> # close output stream to flush the output
##  gap> CloseStream(output);
##  gap> # create an input, print complete contents of file, and close
##  gap> input := InputTextFile(name);;
##  gap> Print( ReadAll(input) );
##  Hallo
##  You
##  AppendLine
##  gap> CloseStream(input);
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OutputTextFile", [ IsString, IsBool ] );
DeclareOperation( "OutputGzipFile", [ IsString, IsBool ] );


#############################################################################
##
#F  OutputTextNone()  . . . . . . . . . . . . . . .  dummy output text stream
##
##  <#GAPDoc Label="OutputTextNone">
##  <ManSection>
##  <Func Name="OutputTextNone" Arg=''/>
##
##  <Description>
##  returns a dummy output stream, which discards all received characters.
##  Its main use is for calls to <Ref Oper="Process"/> when the started
##  program does not write anything.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

UNBIND_GLOBAL( "OutputTextNone" );
DeclareGlobalFunction( "OutputTextNone" );


#############################################################################
##
#F  OutputTextUser()  . . . . . . . . . . . .  output text stream to the user
##
##  <#GAPDoc Label="OutputTextUser">
##  <ManSection>
##  <Func Name="OutputTextUser" Arg=''/>
##
##  <Description>
##  returns an output stream which delivers characters to the user's display
##  (or the standard output device if it has been redirected). Each character
##  is delivered immediately it is written, without waiting for a full line
##  of output. Text written in this way is <E>not</E> written to the session log
##  (see <Ref Oper="LogTo" Label="for a filename"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OutputTextUser" );


##  <#GAPDoc Label="[2]{streams}">
##  Input-output streams capture bidirectional
##  communications between &GAP; and another process, either locally
##  or (@as yet unimplemented@) remotely.
##  <P/>
##  Such streams support the basic operations of both input and output
##  streams. They should provide some buffering, allowing output data to be
##  written to the stream, even when input data is waiting to be read,
##  but the amount of this buffering is operating system dependent,
##  and the user should take care not to get too far ahead in writing, or
##  behind in reading, or deadlock may occur.
##  <P/>
##  At present the only type of Input-Output streams that are
##  implemented provide communication with a local child process,
##  using a pseudo-tty.
##  <P/>
##  Like other streams, write operations are blocking, read operations
##  will block to get the first character, but not thereafter.
##  <P/>
##  As far as possible, no translation is done on characters written
##  to, or read from the stream, and no control characters have special
##  effects, but the details of particular pseudo-tty implementations
##  may effect this.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsInputOutputStream( <obj> )  . . . . . . . . category of two-way streams
##
##  <#GAPDoc Label="IsInputOutputStream">
##  <ManSection>
##  <Filt Name="IsInputOutputStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsInputOutputStream"/> is the Category of Input-Output Streams; it returns
##  <K>true</K> if the <A>obj</A> is an input-output stream and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareCategory( "IsInputOutputStream", IsInputStream and
        IsOutputStream );


#############################################################################
##
#F  InputOutputLocalProcess(<dir>, <executable>, <args>) %
##   . . .input/output stream to a child process on the local host
##
##  <#GAPDoc Label="InputOutputLocalProcess">
##  <ManSection>
##  <Func Name="InputOutputLocalProcess" Arg='dir, executable, args'/>
##
##  <Description>
##  starts up a child process, whose executable file is <A>executable</A>, with
##  <Q>command line</Q> arguments <A>args</A> in the directory <A>dir</A>. (Suitable
##  choices for <A>dir</A> are <C>DirectoryCurrent()</C> or <C>DirectoryTemporary()</C>
##  (see Section&nbsp;<Ref Sect="Directories"/>); <C>DirectoryTemporary()</C> may be a good choice
##  when <A>executable</A> generates output files that it doesn't itself remove
##  afterwards.)
##  <Ref Func="InputOutputLocalProcess"/> returns an InputOutputStream object. Bytes
##  written to this stream are received by the child process as if typed
##  at a terminal on standard input. Bytes written to standard output
##  by the child process can be read from the stream.
##  <P/>
##  When the stream is closed, the signal SIGTERM is delivered to the child
##  process, which is expected to exit.
##  <Log><![CDATA[
##  gap> d := DirectoryCurrent();
##  dir("./")
##  gap> f := Filename(DirectoriesSystemPrograms(), "rev");
##  "/usr/bin/rev"
##  gap> s := InputOutputLocalProcess(d,f,[]);
##  < input/output stream to rev >
##  gap> WriteLine(s,"The cat sat on the mat");
##  true
##  gap> Print(ReadLine(s));
##  tam eht no tas tac ehT
##  gap> x := ListWithIdenticalEntries(10000,'x');;
##  gap> ConvertToStringRep(x);
##  gap> WriteLine(s,x);
##  true
##  gap> WriteByte(s,INT_CHAR('\n'));
##  true
##  gap> y := ReadAll(s);;
##  gap> Length(y);
##  10002
##  gap> CloseStream(s);
##  gap> s;
##  < closed input/output stream to rev >
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InputOutputLocalProcess" );


#############################################################################
##
#O  SetPrintFormattingStatus( <stream>, <newstatus> )
#O  PrintFormattingStatus( <stream> ) . . . . . . . . is stream line-breaking
##
##  <#GAPDoc Label="SetPrintFormattingStatus">
##  <ManSection>
##  <Oper Name="SetPrintFormattingStatus" Arg='stream, newstatus'/>
##  <Oper Name="PrintFormattingStatus" Arg='stream'/>
##
##  <Description>
##  When text is being sent to an output text stream via
##  <Ref Func="PrintTo"/>, <Ref Func="AppendTo"/>,
##  <Ref Oper="LogTo" Label="for streams"/>, etc., it is
##  by default formatted just as it would be were it being printed to the
##  screen.
##  Thus, it is broken into lines of reasonable length at (where possible)
##  sensible places, lines containing elements of lists or records are
##  indented, and so forth.
##  This is appropriate if the output is eventually to be viewed by a human,
##  and harmless if it to passed as input to &GAP;,
##  but may be unhelpful if the output is to be passed as input to another
##  program.
##  It is possible to turn off this behaviour for a stream using the
##  <Ref Oper="SetPrintFormattingStatus"/> operation, and to test whether it
##  is on or off using <Ref Oper="PrintFormattingStatus"/>.
##  <P/>
##  <Ref Oper="SetPrintFormattingStatus"/> sets whether output sent to the
##  output stream <A>stream</A> via <Ref Func="PrintTo"/>,
##  <Ref Func="AppendTo"/>, etc.
##  will be formatted with line breaks and
##  indentation.  If  the  second  argument <A>newstatus</A> is <K>true</K>
##  then output will be so formatted, and if <K>false</K> then it will not.
##  If the stream is not a text stream, only <K>false</K> is allowed.
##  <P/>
##  <Ref Oper="PrintFormattingStatus"/> returns <K>true</K> if output sent to
##  the output text stream <A>stream</A>  via <Ref Func="PrintTo"/>,
##  <Ref Func="AppendTo"/>, etc.
##  will be formatted with line breaks and
##  indentation, and <K>false</K> otherwise.
##  For non-text streams, it returns <K>false</K>.
##  If as argument <A>stream</A> the string <C>"*stdout*"</C> is given, these
##  functions refer to the formatting status of the standard output (so usually
##  the user's terminal screen).<P/>
##  Similarly, the string <C>"*errout*"</C> refers to the formatting status
##  of the standard error output, which influences how error messages are
##  printed.<P/>
##  These functions do not influence the behaviour of the low level functions
##  <Ref Oper="WriteByte"/>,
##  <Ref Oper="WriteLine"/> or  <Ref Oper="WriteAll"/> which always write
##  without formatting.
##  <P/>
##  <Example><![CDATA[
##  gap> s := "";; str := OutputTextString(s,false);;
##  gap> PrintTo(str,Primes{[1..30]});
##  gap> s;
##  "[ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,\
##   \n  67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113 ]"
##  gap> Print(s,"\n");
##  [ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
##    67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113 ]
##  gap> SetPrintFormattingStatus(str, false);
##  gap> PrintTo(str,Primes{[1..30]});
##  gap> s;
##  "[ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,\
##   \n  67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113 ][ 2, 3, 5, 7\
##  , 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, \
##  79, 83, 89, 97, 101, 103, 107, 109, 113 ]"
##  gap> Print(s,"\n");
##  [ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
##    67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113 ][ 2, 3, 5, 7, 1\
##  1, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79,\
##   83, 89, 97, 101, 103, 107, 109, 113 ]
##  ]]></Example>
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SetPrintFormattingStatus", [IsOutputStream, IsBool] );
DeclareOperation( "PrintFormattingStatus", [IsOutputStream] );


#############################################################################
##
#F  AppendTo( <stream>, <arg1>, ... ) . . . . . . . . . .  append to a stream
##
##  <ManSection>
##  <Func Name="AppendTo" Arg='stream, arg1, ...'/>
##
##  <Description>
##  This is   the same as   <C>PrintTo</C>  for streams.   If   <A>stream</A> is just a
##  filename than there  is a difference:  <C>PrintTo</C>  will clear the    file,
##  <C>AppendTo</C> will not.
##  <P/>
##  If <A>stream</A> is really a stream, then the kernel will generate a call to
##  <Ref Func="WriteAll"/> for each line of output.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "AppendTo", function( arg )
    if IsString(arg[1])  then
        arg := ShallowCopy(arg);
        arg[1] := UserHomeExpand(arg[1]);
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
##  <ManSection>
##  <Func Name="PrintTo" Arg='stream, arg1, ...'/>
##
##  <Description>
##  <C>PrintTo</C> appends <A>arg1</A>, ... to the output stream.
##  <P/>
##  If <A>stream</A> is really a stream, then the kernel will generate a call to
##  <Ref Func="WriteAll"/> for each line of output.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "PrintTo", function( arg )
    if IsString(arg[1])  then
        arg := ShallowCopy(arg);
        arg[1] := UserHomeExpand(arg[1]);
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
##  <#GAPDoc Label="LogTo">
##  <ManSection>
##  <Oper Name="LogTo" Arg='stream' Label="for streams"/>
##
##  <Description>
##  causes the subsequent interaction to  be  logged  to  the  output  stream
##  <A>stream</A>. It works in precisely  the  same  way  as  it  does  for  files
##  (see&nbsp;<Ref Oper="LogTo" Label="for a filename"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LogTo", [ IsOutputStream ] );


#############################################################################
##
#O  InputLogTo( <stream> )  . . . . . . . . . . . . . . log input to a stream
##
##  <#GAPDoc Label="InputLogTo">
##  <ManSection>
##  <Oper Name="InputLogTo" Arg='stream' Label="for streams"/>
##
##  <Description>
##  causes the subsequent input to be logged to the output stream
##  <A>stream</A>.
##  It works just like it does for files
##  (see&nbsp;<Ref Oper="InputLogTo" Label="for a filename"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "InputLogTo", [ IsOutputStream ] );
DeclareSynonym( "LogInputTo",InputLogTo);


#############################################################################
##
#O  OutputLogTo( <stream> ) . . . . . . . . . . . . .  log output to a stream
##
##  <#GAPDoc Label="OutputLogTo">
##  <ManSection>
##  <Oper Name="OutputLogTo" Arg='stream' Label="for streams"/>
##
##  <Description>
##  causes the subsequent output to be logged to the output stream
##  <A>stream</A>.
##  It works just like it does for files
##  (see&nbsp;<Ref Oper="OutputLogTo" Label="for a filename"/>).
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OutputLogTo", [ IsOutputStream ] );
DeclareSynonym( "LogOutputTo",OutputLogTo);


#############################################################################
##
#O  FileDescriptorOfStream( <stream> )
##
##  <#GAPDoc Label="FileDescriptorOfStream">
##  <ManSection>
##  <Oper Name="FileDescriptorOfStream" Arg='stream'/>
##
##  <Description>
##  returns the UNIX file descriptor of the underlying file. This is mainly
##  useful for the <Ref Func="UNIXSelect"/> function call. This is
##  as of now only available on UNIX-like operating systems and only for
##  streams to local processes and local files.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("FileDescriptorOfStream", [IsStream] );


#############################################################################
##
#F  InstallCharReadHookFunc( <stream>, <mode>, <func> )
##
##  <#GAPDoc Label="InstallCharReadHookFunc">
##  <ManSection>
##  <Func Name="InstallCharReadHookFunc" Arg='stream, mode, func'/>
##
##  <Description>
##  installs the function <A>func</A> as a handler function for the stream
##  <A>stream</A>. The argument <A>mode</A> decides, for what operations on the
##  stream this function is installed. <A>mode</A> must be a string, in which
##  a letter <C>r</C> means <Q>read</Q>, <C>w</C> means <Q>write</Q> and <C>x</C> means
##  <Q>exception</Q>, according to the <C>select</C> function call in the UNIX
##  C-library (see <C>man select</C> and <Ref Func="UNIXSelect"/>). More than one letter
##  is allowed in <A>mode</A>. As described above the function is called
##  in a situation when &GAP; is reading a character from the keyboard.
##  Handler functions should not use much time to complete.
##  <P/>
##  This functionality
##  only works if the operating system has a <C>select</C> function.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InstallCharReadHookFunc" );


#############################################################################
##
#F  UnInstallCharReadHookFunc( <stream>, <func> )
##
##  <#GAPDoc Label="UnInstallCharReadHookFunc">
##  <ManSection>
##  <Func Name="UnInstallCharReadHookFunc" Arg='stream, func'/>
##
##  <Description>
##  uninstalls the function <A>func</A> as a handler function for the stream
##  <A>stream</A>. All instances are deinstalled, regardless of the mode
##  of operation (read, write, exception).
##  <P/>
##  This functionality
##  only works if the operating system has a <C>select</C> function.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "UnInstallCharReadHookFunc" );


#############################################################################
##
#F  InputFromUser( <arg> )
##
##  <#GAPDoc Label="InputFromUser">
##  <ManSection>
##  <Func Name="InputFromUser" Arg='arg'/>
##
##  <Description>
##  prints the <A>arg</A> as a prompt, then waits until a text is typed by the
##  user (or from the standard input device if it has been redirected).
##  This text must be a <E>single</E> expression, followed by one <E>enter</E>.
##  This is evaluated (see <Ref Func="EvalString"/>) and the result is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InputFromUser" );

#############################################################################
##
#F  OpenExternal( <filename> )
##
##  <#GAPDoc Label="OpenExternal">
##  <ManSection>
##  <Func Name="OpenExternal" Arg='filename'/>
##
##  <Description>
##  Open the file <A>filename</A> using the default application for this file
##  in the operating system. This can be used to open files like HTML and PDF
##  files in the GUI.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OpenExternal" );
