#############################################################################
##
#W  streams.gi                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for streams.
##
Revision.streams_gi :=
    "@(#)$Id$";


#############################################################################
##

#F  # # # # # # # # # # # # # # closed stream # # # # # # # # # # # # # # # #
##


#############################################################################
##

#V  ClosedStreamType  . . . . . . . . . . . . . . . . type of a closed stream
##
ClosedStreamType := NewType(
    StreamsFamily,
    IsClosedStream );


#############################################################################
##

#M  CloseStream( <stream> ) . . . . . . . . .  set type to <ClosedStreamType>
##
InstallMethod( CloseStream,
    "non-process streams",
    true,
    [ IsStream and IsComponentObjectRep],
    0,

function( stream )
    SET_TYPE_COMOBJ( stream, ClosedStreamType );
end );

InstallMethod( CloseStream,
    "non-process streams",
    true,
    [ IsStream and IsPositionalObjectRep],
    0,

function( stream )
    SET_TYPE_POSOBJ( stream, ClosedStreamType );
end );
        

#############################################################################
##
#M  PrintObj( <closed-stream> ) . . . . . . . . . . . . . . . .  pretty print
##
InstallMethod( PrintObj,
    "closed stream",
    true,
    [ IsClosedStream ],
    0,
        
function( obj )
    Print( "closed-stream" );
end );


#############################################################################
##

#F  # # # # # # # # # # # # # #  input stream # # # # # # # # # # # # # # # #
##


#############################################################################
##
#M  ReadAll( <input-text-stream> )  . . . . . . . . . . . . .  read all input
##
InstallMethod( ReadAll,
    "input stream",
    true,
    [ IsInputStream  ],
    0,
        
function( stream )
    local   str,  str1,  new;
    
    str := "";
    str1 := [];
    while not IsEndOfStream(stream)  do
        new := ReadLine(stream);
        if new <> fail  then
            Append( str1, new );
            if Length(str1)>500000 then
              ConvertToStringRep(str1);
              Append(str, str1);
              str1 := [];
            fi;
        fi;
    od;
#T this is just a hack for the moment (24.02.2000)
    ConvertToStringRep(str1);
    Append(str, str1);
    return Immutable(str);
#T why immutable???
    
end );

#############################################################################
##
#M  ReadLine( <input-stream> ) . . . . . . . . . . . generic read-line method
##
InstallMethod( ReadLine, "generic, call ReadByte", [ IsInputStream ],
        function(stream)
    local x,c,line;
    line := [];
    repeat 
        x := ReadByte(stream);
        if x = fail then 
            if line <> "" then
                return line;
            else
                return fail;
            fi;
        fi;
        c := CHAR_INT(x);
        Add(line,c);
    until c = '\n';
    ConvertToStringRep(line);
    return line;
end);
        
        


#############################################################################
##
#M  Read( <input-stream> )	. . . . . . . . . .  read stream as GAP input
##
InstallOtherMethod( Read,
    "input stream",
    true,
    [ IsInputStream ],
    0,

function( stream )
    READ_STREAM(stream);
    CloseStream(stream);
end );


#############################################################################
##
#M  ReadTest( <input-stream> ) . . . . . . . . read stream as TEST input
##
InstallOtherMethod( ReadTest,
    "input stream",
    true,
    [ IsInputStream ],
    0,
    READ_TEST_STREAM );


#############################################################################
##
#M  ReadAsFunction( <input-stream> ) . . . . . . read stream as function
##
InstallOtherMethod( ReadAsFunction,
    "input stream",
    true,
    [ IsInputStream ],
    0,
    READ_AS_FUNC_STREAM );


#############################################################################
##
#M  RewindStream( <input-stream> )  . . . . . . . . . . . . . . rewind stream
##
InstallMethod( RewindStream,
    "input text stream",
    true,
    [ IsInputTextStream ],
    0,

function( stream )
    return SeekPositionStream( stream, 0 );
end );


#############################################################################
##

#F  # # # # # # # # # # # # # # output stream # # # # # # # # # # # # # # # #
##


#############################################################################
##

#M  LogTo( <output-text-stream> ) . . . . . . . .  log input/output to stream
##
InstallMethod( LogTo,
    "for output stream",
    true,
    [ IsOutputTextStream ],
    0,
    function(stream) LOG_TO_STREAM(stream); end ); # ignore return value


#############################################################################
##
#M  LogTo( <filename> ) . . . . . . . . . . . . . .  log input/output to file
##
InstallOtherMethod( LogTo,
    "for output file",
    true,
    [ IsString ],
    0,
    function(name) LOG_TO(name); end ); # ignore return value


#############################################################################
##
#M  LogTo() . . . . . . . . . . . . . . . . . . . . . . . . . . . . close log
##
InstallOtherMethod( LogTo,
    "close log",
    true,
    [],
    0,
    function() CLOSE_LOG_TO(); end );


#############################################################################
##
#M  InputLogTo( <output-text-stream> )  . . . . . . . . . log input to stream
##
InstallMethod( InputLogTo,
    "for output stream",
    true,
    [ IsOutputTextStream ],
    0,
    function(stream) INPUT_LOG_TO_STREAM(stream); end ); # ignore ret value


#############################################################################
##
#M  InputLogTo( <filename> )  . . . . . . . . . . . . . . . log input to file
##
InstallOtherMethod( InputLogTo,
    "for output file",
    true,
    [ IsString ],
    0,
    function(name) INPUT_LOG_TO(name); end ); # ignore return value


#############################################################################
##
#M  InputLogTo()  . . . . . . . . . . . . . . . . . . . . . . close input log
##
InstallOtherMethod( InputLogTo,
    "close log",
    true,
    [],
    0,
    function() CLOSE_INPUT_LOG_TO(); end );


#############################################################################
##
#M  OutputLogTo( <output-text-stream> ) . . . . . . . .  log output to stream
##
InstallMethod( OutputLogTo,
    "for output stream",
    true,
    [ IsOutputTextStream ],
    0,
    function(stream) OUTPUT_LOG_TO_STREAM(stream); end ); # ignore ret value


#############################################################################
##
#M  OutputLogTo( <filename> ) . . . . . . . . . . . . . .  log output to file
##
InstallOtherMethod( OutputLogTo,
    "for output file",
    true,
    [ IsString ],
    0,
    function(name) OUTPUT_LOG_TO(name); end ); # ignore return value


#############################################################################
##
#M  OutputLogTo() . . . . . . . . . . . . . . . . . . . . .  close output log
##
InstallOtherMethod( OutputLogTo,
    "close log",
    true,
    [],
    0,
    function() CLOSE_OUTPUT_LOG_TO(); end );


#############################################################################
##
#M  WriteAll( <output-text-stream>, <string> )  . . . . . . . write all bytes
##
InstallMethod( WriteAll,
    "output stream",
    true,
    [ IsOutputStream,
      IsList ],
    0,
                    
function( stream, string )
    local   byte;

    if not IsString(string)  then
        Error( "<string> must be a string" );
    fi;
    for byte  in string  do
        if WriteByte( stream, INT_CHAR(byte) ) <> true  then
            return fail;
        fi;
    od;
    return true;
end );


#############################################################################
##
#M  WriteLine( <output-stream>, <string> ) . . . . .  write plus newline
##
InstallMethod( WriteLine,
    "output stream",
    true,
    [ IsOutputStream,
      IsList ],
    0,
                    
function( stream, string )
    local   res;

    res := WriteAll( stream, string );
    if res <> true  then return res;  fi;
    return WriteByte( stream, INT_CHAR('\n') );
end );


#############################################################################
##

#F  # # # # # # # # # # # # # input text string # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsInputTextStringRep
##
DeclareRepresentation(
    "IsInputTextStringRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  InputTextStringType
##
InputTextStringType := NewType(
    StreamsFamily,
    IsInputTextStream and IsInputTextStringRep );


#############################################################################
##
#M  InputTextString( <str> )
##
InstallMethod( InputTextString,
    "input text stream from string",
    true,
    [ IsString ],
    0,
        
function( str )
    ConvertToStringRep(str);
    return Objectify( InputTextStringType, [ 0, Immutable(str) ] );
end );



#############################################################################
##

#M  IsEndOfStream( <input-text-string> )
##
InstallMethod( IsEndOfStream,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,
        
function( stream )
    return Length(stream![2]) <= stream![1];
end );


#############################################################################
##
#M  PositionStream( <input-text-string> )
##
InstallMethod( PositionStream,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,

function( stream )
    return stream![1];
end );


#############################################################################
##
#M  PrintObj( <input-text-string> )
##
InstallMethod( PrintObj,
    "input text string",
    true,
    [ IsInputTextStringRep ],
    0,
        
function( obj )
    Print( "InputTextString(", obj![1], ",", Length(obj![2]), ")" );
end );


#############################################################################
##
#M  ReadAll( <input-text-string> )
##
InstallMethod( ReadAll,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,
        
function( stream )
    local   start;

    if Length(stream![2]) <= stream![1]  then
        return Immutable("");
    fi;
    start := stream![1]+1;
    stream![1] := Length(stream![2]);
    return Immutable( stream![2]{[start..stream![1]]} );
    
end );


#############################################################################
##
#M  ReadByte( <input-text-string> )
##
InstallMethod( ReadByte,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,
                    
function( stream )
    if Length(stream![2]) <= stream![1]  then
        return fail;
    fi;
    stream![1] := stream![1] + 1;
    return INT_CHAR( stream![2][stream![1]] );
end );


#############################################################################
##
#M  ReadLine( <input-text-string> )
##
InstallMethod( ReadLine,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,

function( stream )
    local   str,  len,  start,  stop;

    str := stream![2];
    len := Length(str);
    if len <= stream![1]  then
        return fail;
    fi;
    start := stream![1] + 1;
    stop  := start;
    while stop <= len and str[stop] <> '\n'  do
        stop := stop + 1;
    od;
    stream![1] := stop;
    return Immutable( str{[start..stop]} );

end );


#############################################################################
##
#M  RewindStream( <input-text-string> )
##
InstallMethod( RewindStream,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,

function( stream )
    stream![1] := 0;
    return true;
end );


#############################################################################
##
#M  SeekPositionStream( <input-text-string> )
##
InstallMethod( SeekPositionStream,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep,
      IsInt ],
    0,

function( stream, pos )
    if pos < 0  then
        return fail;
    fi;
    if Length(stream![2]) < pos  then
        return fail;
    fi;
    stream![1] := pos;
    return true;
end );


#############################################################################
##

#F  # # # # # # # # # # # # # input text file # # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsInputTextFileRep	. . . . .  representation of a input text file stream
##
DeclareRepresentation(
    "IsInputTextFileRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  InputTextFileType . . . . . . . . . . .  type of a input text file stream
##
InputTextFileType := NewType(
    StreamsFamily,
    IsInputTextStream and IsInputTextFileRep );


#############################################################################
##
#V  InputTextFileStillOpen  . . . . . . . . . . . . . . .  list of open files
##
InputTextFileStillOpen := [];


#############################################################################
##
#M  InputTextFile( <str> )  . . . . . . . . . create a input text file stream
##
InstallMethod( InputTextFile,
    "input text stream from file",
    true,
    [ IsString ],
    0,
        
function( str )
    local   fid;

    fid := INPUT_TEXT_FILE(str);
    if fid = fail  then
        return fail;
    else
        AddSet( InputTextFileStillOpen, fid );
        return Objectify( InputTextFileType, [fid,Immutable(str)] );
    fi;
end );


#############################################################################
##

#M  CloseStream( <input-text-file> )  . . . . . . . . . . . . . .  close file
##
InstallMethod( CloseStream,
    "input text file",
    true,
    [ IsInputStream and IsInputTextFileRep ],
    0,

function( stream )
    CLOSE_FILE(stream![1]);
    RemoveSet( InputTextFileStillOpen, stream![1] );
    SET_TYPE_COMOBJ( stream, ClosedStreamType );
end );


InstallAtExit( function()
    local   i;

    for i  in InputTextFileStillOpen  do
        CLOSE_FILE(i);
    od;

end );
  

#############################################################################
##
#M  IsEndOfStream( <input-text-file> )  . . . . . . . . . . . . check for eof
##
InstallMethod( IsEndOfStream,
    "input text file",
    true,
    [ IsInputStream and IsInputTextFileRep ],
    0,
        
function( stream )
    return IS_END_OF_FILE(stream![1]);
end );


#############################################################################
##
#M  PositionStream( <input-text-file> ) . . . . . . . . . . . .  get position
##
InstallMethod( PositionStream,
    "input text file",
    true,
    [ IsInputTextStream and IsInputTextFileRep ],
    0,

function( stream )
    return POSITION_FILE(stream![1]);
end );


#############################################################################
##
#M  PrintObj( <input-text-file> ) . . . . . . . . . . . . . . .  pretty print
##
InstallMethod( PrintObj,
    "input text file",
    true,
    [ IsInputTextFileRep ],
    0,
        
function( obj )
    Print( "InputTextFile(", obj![2], ")" );
end );


#############################################################################
##
#M  ReadByte( <input-text-file> ) . . . . . . . . . . . . . . . get next byte
##
InstallMethod( ReadByte,
    "input text file",
    true,
    [ IsInputTextStream and IsInputTextFileRep ],
    0,
                    
function( stream )
    return READ_BYTE_FILE(stream![1]);
end );


#############################################################################
##
#M  ReadLine( <input-text-file>> )  . . . . . . . . . . . . . . get next line
##
InstallMethod( ReadLine,
    "input text file",
    true,
    [ IsInputTextStream and IsInputTextFileRep ],
    0,

function( stream )
    return READ_LINE_FILE(stream![1]);
end );


#############################################################################
##
#M  SeekPositionStream( <input-text-file> ) . . . . . . . . .  set position
##
InstallMethod( SeekPositionStream,
    "input text file",
    true,
    [ IsInputTextStream and IsInputTextFileRep,
      IsInt ],
    0,

function( stream, pos )
    return SEEK_POSITION_FILE( stream![1], pos );
end );


#############################################################################
##

#F  # # # # # # # # # # # # # # input text none # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsInputTextNoneRep	. . . . . . representation of dummy input text stream
##
DeclareRepresentation(
    "IsInputTextNoneRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  InputTextNoneType	. . . . . . . . . . . type of dummy input text stream
##
InputTextNoneType := NewType(
    StreamsFamily,
    IsInputTextNone and IsInputTextNoneRep );


#############################################################################
##
#M  InputTextNone() . . . . . . . . . .  create a new dummy input text stream
##
InstallGlobalFunction( InputTextNone, function()
    return Objectify( InputTextNoneType, [] );
end );



#############################################################################
##

#M  IsEndOfStream( <input-text-none> )	. . . . . . . always at end-of-stream
##
InstallMethod( IsEndOfStream,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep ],
    0,
        
function( stream )
    return true;
end );


#############################################################################
##
#M  PositionStream( <input-text-none> )	. . . . . . . always at end-of-stream
##
InstallMethod( PositionStream,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep ],
    0,

function( stream )
    return 0;
end );


#############################################################################
##
#M  PrintObj( <input-text-none> ) . . . . . . . . . . . . . . . .  nice print
##
InstallMethod( PrintObj,
    "input text none",
    true,
    [ IsInputTextNoneRep ],
    0,
        
function( obj )
    Print( "InputTextNone()" );
end );


#############################################################################
##
#M  ReadAll( <input-text-none> )  . . . . . . . . . . always at end-of-stream
##
InstallMethod( ReadAll,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep ],
    0,
    function(stream) return Immutable(""); end );


#############################################################################
##
#M  ReadByte( <input-text-none> ) . . . . . . . . . . always at end-of-stream
##
InstallMethod( ReadByte,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep ],
    0,
    ReturnFail );


#############################################################################
##
#M  ReadLine( <input-text-none> ) . . . . . . . . . . always at end-of-stream
##
InstallMethod( ReadLine,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep ],
    0,
    ReturnFail );


#############################################################################
##
#M  RewindStream( <input-text-none> ) . . . . . . . . always at end-of-stream
##
InstallMethod( RewindStream,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep ],
    0,
    RETURN_TRUE );


#############################################################################
##
#M  SeekPositionStream( <input-text-none> ) . . . . . always at end-of-stream
##
InstallMethod( SeekPositionStream,
    "input text none",
    true,
    [ IsInputTextNone and IsInputTextNoneRep,
      IsInt ],
    0,
    RETURN_TRUE );


#############################################################################
##

#F  # # # # # # # # # # # #  output text string # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsOutputTextStringRep
##
DeclareRepresentation(
    "IsOutputTextStringRep",
    IsPositionalObjectRep,
    ["string", "format"] );


#############################################################################
##
#V  OutputTextStringType
##
OutputTextStringType := NewType(
    StreamsFamily,
    IsOutputTextStream and IsOutputTextStringRep );


#############################################################################
##
#M  OutputTextString( <str>, <append> )
##
InstallMethod( OutputTextString,
    "output text stream from string",
    true,
    [ IsList,
      IsBool ],
    0,
        
function( str, append )
    local   i;

    if not append  then
        for i  in [ Length(str), Length(str)-1 .. 1 ]   do
            Unbind(str[i]);
        od;
    fi;
    if not IsMutable(str)  then
        Error( "<str> must be mutable" );
    fi;
    return Objectify( OutputTextStringType, [ str, true ] );
end );


#############################################################################
##
#M  PrintObj( <output-text-string> )
##
InstallMethod( PrintObj,
    "output text string",
    true,
    [ IsOutputTextStringRep ],
    0,
        
function( obj )
    Print( "OutputTextString(", Length(obj![1]), ")" );
end );


#############################################################################
##
#M  WriteAll( <output-text-string>, <string> )
##
InstallMethod( WriteAll,
    "output text string",
    true,
    [ IsOutputTextStream and IsOutputTextStringRep,
      IsList ],
    0,
                    
function( stream, string )
    if not IsString(string)  then
        Error( "<string> must be a string" );
    fi;
    Append( stream![1], string );
    return true;
end );


#############################################################################
##
#M  WriteByte( <output-text-string>, <byte> )
##
InstallMethod( WriteByte,
    "output text string",
    true,
    [ IsOutputTextStream and IsOutputTextStringRep,
      IsInt ],
    0,
                    
function( stream, byte )
    if byte < 1 or 255 < byte  then
        Error( "<byte> must an integer between 1 and 255" );
    fi;
    Add( stream![1], CHAR_INT(byte) );
    return true;
end );

#############################################################################
##
#M  PrintFormattingStatus( <output-text-string> )
##
InstallMethod( PrintFormattingStatus, "output tyext string", true,
        [IsOutputTextStringRep and IsOutputTextStream],
        0,
        str -> str![2]);

#############################################################################
##
#M  SetPrintFormattingStatus( <output-text-string>, <status> )
##
InstallMethod( SetPrintFormattingStatus, "output text string", true,
        [IsOutputTextStringRep and IsOutputTextStream,
         IsBool],
        0,
        function( str, stat)
    if stat = fail then
        Error("Print formatting status must be true or false");
    else
        str![2] := stat;
    fi;
end);
       


#############################################################################
##

#F  # # # # # # # # # # # #  output text file # # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsOutputTextFileRep
##
DeclareRepresentation(
    "IsOutputTextFileRep",
    IsPositionalObjectRep,
    ["fid", "fname", "format" ] );


#############################################################################
##
#V  OutputTextFileType
##
OutputTextFileType := NewType(
    StreamsFamily,
    IsOutputTextStream and IsOutputTextFileRep );


#############################################################################
##
#V  OutputTextFileStillOpen
##
OutputTextFileStillOpen := [];


#############################################################################
##
#M  OutputTextFile( <str>, <append> )
##
InstallMethod( OutputTextFile,
    "output text stream from file",
    true,
    [ IsList,
      IsBool ],
    0,
        
function( str, append )
    local   fid;

    fid := OUTPUT_TEXT_FILE( str, append );
    if fid = fail  then
        return fail;
    else
        AddSet( OutputTextFileStillOpen, fid );
        return Objectify( OutputTextFileType, [fid,Immutable(str), true] );
    fi;
end );

InstallOtherMethod( OutputTextFile,
        "error catching method, append not given",
        true,
        [ IsList ],
        -SUM_FLAGS, # as low as possible
        function( str )
    Error("Usage OutputTextFile( <fname>, <appending> )");
end );

#############################################################################
##
#M  CloseStream( <output-text-file> )
##
InstallMethod( CloseStream,
    "output text file",
    true,
    [ IsOutputStream and IsOutputTextFileRep ],
    0,

function( stream )
    CLOSE_FILE(stream![1]);
    RemoveSet( OutputTextFileStillOpen, stream![1] );
    SET_TYPE_COMOBJ( stream, ClosedStreamType );
end );
        
InstallAtExit( function()
    local   i;

    for i  in OutputTextFileStillOpen  do
        CLOSE_FILE(i);
    od;

end );


#############################################################################
##
#M  PrintObj( <output-text-file> )
##
InstallMethod( PrintObj,
    "output text file",
    true,
    [ IsOutputTextFileRep ],
    0,
        
function( obj )
    Print( "OutputTextFile(", obj![2], ")" );
end );


#############################################################################
##
#M  WriteByte( <output-text-file>, <byte> )
##
InstallMethod( WriteByte,
    "output text file",
    true,
    [ IsOutputTextStream and IsOutputTextFileRep,
      IsInt ],
    0,
                    
function( stream, byte )
    if byte < 1 or 255 < byte  then
        Error( "<byte> must an integer between 1 and 255" );
    fi;
    return WRITE_BYTE_FILE( stream![1], byte );
end );

#############################################################################
##
#M  WriteAll( <output-text-file>, <string> )
##

InstallMethod( WriteAll, 
        "output text file",
        true,
        [ IsOutputTextStream and IsOutputTextFileRep,
          IsString ],
        0,
        function (stream, str)
    ConvertToStringRep(str);
    return WRITE_STRING_FILE_NC( stream![1], str );
end );

#############################################################################
##
#M  PrintFormattingStatus( <output-text-file> )
##
InstallMethod( PrintFormattingStatus, "output tyext file", true,
        [IsOutputTextFileRep and IsOutputTextStream],
        0,
        str -> str![3]);

#############################################################################
##
#M  SetPrintFormattingStatus( <output-text-file>, <status> )
##
InstallMethod( SetPrintFormattingStatus, "output text file", true,
        [IsOutputTextFileRep and IsOutputTextStream,
         IsBool],
        0,
        function( str, stat)
    if stat = fail then
        Error("Print formatting status must be true or false");
    else
        str![3] := stat;
    fi;
end);
       


#############################################################################
##
#F  # # # # # # # # # # # # # output text none  # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsOutputTextNoneRep	. . . . .  representation of dummy output text stream
##
DeclareRepresentation(
    "IsOutputTextNoneRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  OutputTextNoneType  . . . . . . . . . .  type of dummy output text stream
##
OutputTextNoneType := NewType(
    StreamsFamily,
    IsOutputTextNone and IsOutputTextNoneRep );


#############################################################################
##
#M  OutputTextNone()  . . . . . . . . . create a new dummy output text stream
##
InstallGlobalFunction( OutputTextNone, function()
    return Objectify( OutputTextNoneType, [] );
end );


#############################################################################
##
#M  PrintObj( <output-text-none> )  . . . . . . . . . . . . . . .  nice print
##
InstallMethod( PrintObj,
    "output text none",
    true,
    [ IsOutputTextNoneRep ],
    0,
        
function( obj )
    Print( "OutputTextNone()" );
end );


#############################################################################
##
#M  WriteAll( <output-text-none>, <string> )  . . . . . . . . . .  ingore all
##
InstallMethod( WriteAll,
    "output text none",
    true,
    [ IsOutputTextNone and IsOutputTextNoneRep,
      IsList ],
    0,
                    
function( stream, string )
    if not IsString(string)  then
        Error( "<string> must be a string" );
    fi;
    return true;
end );


#############################################################################
##
#M  WriteByte( <output-text-none>, <byte> ) . . . . . . . . . . .  ignore all
##
InstallMethod( WriteByte,
    "output text none",
    true,
    [ IsOutputTextNone and IsOutputTextNoneRep,
      IsInt ],
    0,
                    
function( stream, byte )
    if byte < 1 or 255 < byte  then
        Error( "<byte> must an integer between 1 and 255" );
    fi;
    return true;
end );


#############################################################################
##
#M  PrintFormattingStatus( <output-text-none> )
##
InstallMethod( PrintFormattingStatus, "output text none", true,
        [IsOutputTextNoneRep and IsOutputTextNone],
        0,
        ReturnFalse);

#############################################################################
##
#M  SetPrintFormattingStatus( <output-text-none>, <status> )
##
InstallMethod( SetPrintFormattingStatus, "output text none", true,
        [IsOutputTextNoneRep and IsOutputTextNone,
         IsBool],
        0,
        function( str, stat)
    if stat = fail then
        Error("Print formatting status must be true or false");
    fi;
end);


#############################################################################
##
#F  # # # # # # # # # # # # # # user streams  # # # # # # # # # # # # # # # #
##


#############################################################################
##
#M  InputTextUser() . . . . . . . . . . . . . input text stream from the user
##
InstallGlobalFunction( InputTextUser, function()
    return InputTextFile("*stdin*");
end );


#############################################################################
##
#M  OutputTextUser()  . . . . . . . . . . . .  output text stream to the user
##
InstallGlobalFunction( OutputTextUser, function()
    return OutputTextFile("*stdout*",false);
end );

#############################################################################
##
#R  IsInputOutputStreamByPtyRep 
##
##  Position 1 is the pty number from the kernel
##  Position 2 is the input buffer
##  Position 3 is the left end of the active region in the buffer
##  Position 4 is the right end of the region
##  Position 5 is the executable name (kept for viewing and printing)
##  Position 6 is the arguments (kept for printing)
##

DeclareRepresentation("IsInputOutputStreamByPtyRep", IsPositionalObjectRep,
        []);

InputOutputStreamByPtyDefaultType := 
  NewType(StreamsFamily, IsInputOutputStreamByPtyRep and IsInputOutputStream);

#############################################################################
##
#M  InputOutputLocalProcess(<current-dir>, <executable>, <args>)
#M   . . .input/output stream to a process run as a "slave" on the local host
##

InstallGlobalFunction( InputOutputLocalProcess, 
        function( cdir, exec, argts)
    local dirname, ptynum, basename, i,buf;
    if not IsDirectory(cdir) or 
       not IsExecutableFile(exec) or 
       not IsList(argts)
       or not ForAll(argts, IsString) then
        Error("Usage: InputOutputLocalProcess( <current-directory>, <executable>, <argts> )");
    fi;
    if not IsDirectoryRep(cdir) then
        Error("Can't handle new rep for directories");
    fi;
    dirname := cdir![1];
    ptynum := CREATE_PTY_IOSTREAM( dirname, exec, argts);
    if ptynum = fail then
        return fail;
    fi;
    i := Length(exec);
    while i > 0 and exec[i] <> '/' do
        i := i-1;
    od;
    basename := exec{[i+1..Length(exec)]};
    buf := ListWithIdenticalEntries(100,' ');
    ConvertToStringRep(buf);
    return Objectify(InputOutputStreamByPtyDefaultType, [ptynum, buf,
                   1,0,basename,argts]);
end);

#############################################################################
##
#M  ViewObj( <iostream-by-pty> )
#M  PrintObj( <iostream-by-pty> )
##

InstallMethod(ViewObj, [IsInputOutputStreamByPtyRep and IsInputOutputStream,],
        function(stream)
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("input/output stream to ",stream![5]," >");
end);

InstallMethod(PrintObj, [IsInputOutputStreamByPtyRep and IsInputOutputStream],
        function(stream)
    local i;
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("input/output stream to ",stream![5]);
    for i in [1..Length(stream![6])] do
        Print(" ",stream![6][i]);
    od;
    Print(" >");
end);

#############################################################################
##
#M  ReadByte( <iostream-by-pty> )
##

InstallMethod(ReadByte, [IsInputOutputStreamByPtyRep and IsInputOutputStream],
        function(stream)
    local l,ret;
    l := stream![3];
    if l <= stream![4] then
        stream![3] := l+1;
        return INT_CHAR(stream![2][l]);
    else
        ret := READ_IOSTREAM(stream![1],stream![2],-Length(stream![2]));
        if ret < 1 then
            stream![4] := 0;
            stream![3] := 1;
            return fail;
        else
            stream![4] := ret;
            stream![3] := 2;
            return INT_CHAR(stream![2][1]);
        fi;
    fi;
end);   

#############################################################################
##
#M  ReadLine( <iostream-by-pty> )
##

InstallMethod(ReadLine, [IsInputOutputStreamByPtyRep and IsInputOutputStream],
        function(stream)
    local line, buf, nl, ret;
    buf := stream![2];
    line := "";
    nl := Position(buf, '\n', stream![3]-1);
    while nl > stream![4] do
        Append(line,buf{[stream![3]..stream![4]]});
        ret := READ_IOSTREAM(stream![1],buf,-Length(buf));
        if ret < 1 then
            stream![4] := 0;
            stream![3] := 1;
            if line = "" then
                return fail;
            else
                return line;
            fi;
        fi;
        stream![4] := ret;
        stream![3] := 1;
        nl := Position(buf,'\n');
    od;
    Append(line,buf{[stream![3]..nl]});
    stream![3] := nl+1;
    ConvertToStringRep(line);
    return line;
end);
   
#############################################################################
##
#M  ReadAll( <iostream-by-pty> )
##

InstallMethod(ReadAll, [IsInputOutputStreamByPtyRep and IsInputOutputStream],
        function(stream)
    local read, buf, nl, ret;
    buf := stream![2];
    read := "";
    repeat
        Append(read,buf{[stream![3]..stream![4]]});
        stream![3] := 1;
        ret := READ_IOSTREAM(stream![1],buf,-Length(buf));
        if ret >= 0 then
            stream![4] := ret;
        else
            stream![4] := 0;
        fi;
    until ret <= 0;
    return read;
end);
    
   
        

#############################################################################
##
#M  WriteByte( <iostream-by-pty> )
##

InstallMethod(WriteByte, [IsInputOutputStreamByPtyRep and
        IsInputOutputStream, IsInt],
        function(stream, byte)
    local ret,s;
    s := [CHAR_INT(byte)];
    ConvertToStringRep(s);
    ret := WRITE_IOSTREAM( stream![1], s,-1);
    if ret <> 1 then
        return fail;
    else
        return true;
    fi;
end);    

#############################################################################
##
#M  WriteAll( <iostream-by-pty> )
##

InstallMethod(WriteAll, [IsInputOutputStreamByPtyRep and
       IsInputOutputStream, IsString],
        function(stream, text)
    local ret,s;
    ret := WRITE_IOSTREAM( stream![1], text,-Length(text));
    if ret < Length(text) then
        return fail;
    else
        return true;
    fi;
end);    


#############################################################################
##
#M IsEndOfStream( <iostream-by-pty> )
##

InstallMethod(IsEndOfStream, 
        [IsInputOutputStreamByPtyRep and IsInputOutputStream],
        stream -> IS_BLOCKED_IOSTREAM(stream![1]));


#############################################################################
##
#M  CloseStream( <iostream-by-pty> )
##

InstallMethod(CloseStream,
        [IsInputOutputStreamByPtyRep and IsInputOutputStream],
        function(stream)
    CLOSE_PTY_IOSTREAM(stream![1]);
    SetFilterObj(stream, IsClosedStream);
end);

#############################################################################
##
#E  streams.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
