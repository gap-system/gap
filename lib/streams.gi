#############################################################################
##
#W  streams.gi                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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

#V  ClosedStreamType
##
ClosedStreamType := NewType(
    StreamsFamily,
    IsClosedStream );


#############################################################################
##

#M  CloseStream( <stream> )
##
InstallMethod( CloseStream,
    "input stream",
    true,
    [ IsInputStream ],
    0,

function( stream )
    SET_TYPE_COMOBJ( stream, ClosedStreamType );
end );
        

#############################################################################
##
#M  PrintObj( <closed-stream> )
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

#M  ReadAll( <input-text-stream> )
##
InstallMethod( ReadAll,
    "input text stream",
    true,
    [ IsInputTextStream  ],
    0,
        
function( stream )
    local   str,  new;

    str := "";
    while not IsEndOfStream(stream)  do
        new := ReadLine(stream);
        if new <> fail  then
            Append( str, new );
        fi;
    od;
    return str;
    
end );


#############################################################################
##
#M  Read( <input-text-stream> )
##
InstallOtherMethod( Read,
    "input text stream",
    true,
    [ IsInputTextStream ],
    0,

function( stream )
    READ_STREAM(stream);
    CloseStream(stream);
end );


#############################################################################
##
#M  ReadTest( <input-text-stream> )
##
InstallOtherMethod( ReadTest,
    "input text stream",
    true,
    [ IsInputTextStream ],
    0,
    READ_TEST_STREAM );


#############################################################################
##
#M  RewindStream( <input-stream> )
##
InstallMethod( RewindStream,
    "input text stream",
    true,
    [ IsInputTextStream ],
    0,

function( stream )
    SeekPositionStream( stream, 0 );
end );


#############################################################################
##

#F  # # # # # # # # # # # # # # output stream # # # # # # # # # # # # # # # #
##


#############################################################################
##

#M  LogTo( <stream> )
##
InstallMethod( LogTo,
    "for output stream",
    true,
    [ IsOutputTextStream ],
    0,
    function(stream) LOG_TO_STREAM(stream); end );


#############################################################################
##
#M  LogTo( <filename> )
##
InstallOtherMethod( LogTo,
    "for output file",
    true,
    [ IsString ],
    0,
    function(name) LOG_TO(name); end );


#############################################################################
##
#M  LogTo()
##
InstallOtherMethod( LogTo,
    "close log",
    true,
    [],
    0,
    function() CLOSE_LOG_TO(); end );


#############################################################################
##
#M  InputLogTo( <stream> )
##
InstallMethod( InputLogTo,
    "for output stream",
    true,
    [ IsOutputTextStream ],
    0,
    function(stream) INPUT_LOG_TO_STREAM(stream); end );


#############################################################################
##
#M  InputLogTo( <filename> )
##
InstallOtherMethod( InputLogTo,
    "for output file",
    true,
    [ IsString ],
    0,
    function(name) INPUT_LOG_TO(name); end );


#############################################################################
##
#M  InputLogTo()
##
InstallOtherMethod( InputLogTo,
    "close log",
    true,
    [],
    0,
    function() CLOSE_INPUT_LOG_TO(); end );


#############################################################################
##
#M  OutputLogTo( <stream> )
##
InstallMethod( OutputLogTo,
    "for output stream",
    true,
    [ IsOutputTextStream ],
    0,
    function(stream) OUTPUT_LOG_TO_STREAM(stream); end );


#############################################################################
##
#M  OutputLogTo( <filename> )
##
InstallOtherMethod( OutputLogTo,
    "for output file",
    true,
    [ IsString ],
    0,
    function(name) OUTPUT_LOG_TO(name); end );


#############################################################################
##
#M  OutputLogTo()
##
InstallOtherMethod( OutputLogTo,
    "close log",
    true,
    [],
    0,
    function() CLOSE_OUTPUT_LOG_TO(); end );


#############################################################################
##

#F  # # # # # # # # # # # # # input text string # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsInputTextStringRep
##
IsInputTextStringRep := NewRepresentation(
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
        return fail;
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
        Error( "illegal position <pos>" );
    fi;
    if Length(stream![2]) < pos  then
        Error( "illegal position <pos>" );
    fi;
    stream![1] := pos;
end );


#############################################################################
##

#F  # # # # # # # # # # # # # input text file # # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsInputTextFileRep
##
IsInputTextFileRep := NewRepresentation(
    "IsInputTextFileRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  InputTextFileType
##
InputTextFileType := NewType(
    StreamsFamily,
    IsInputTextStream and IsInputTextFileRep );


#############################################################################
##
#V  InputTextFileStillOpen
##
InputTextFileStillOpen := [];


#############################################################################
##
#M  InputTextFile( <str> )
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

#M  CloseStream( <input-text-file> )
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
#M  IsEndOfStream( <input-text-file> )
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
#M  PositionStream( <input-text-file> )
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
#M  PrintObj( <input-text-file> )
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
#M  ReadByte( <input-text-file> )
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
#M  ReadLine( <input-text-file>> )
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
#M  SeekPositionStream( <input-text-string> )
##
InstallMethod( SeekPositionStream,
    "input text file",
    true,
    [ IsInputTextStream and IsInputTextFileRep,
      IsInt ],
    0,

function( stream, pos )
    if SEEK_POSITION_FILE( stream![1], pos ) = fail  then
        Error( "illegal position <pos>" );
    fi;
end );


#############################################################################
##

#F  # # # # # # # # # # # # # # input text none # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsInputTextNoneRep	. . . . . . representation of dummy input text stream
##
IsInputTextNoneRep := NewRepresentation(
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
InputTextNone := function()
    return Objectify( InputTextNoneType, [] );
end;



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
    ReturnFail );


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
    Ignore );


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
    Ignore );


#############################################################################
##

#F  # # # # # # # # # # # #  output text string # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsOutputTextStringRep
##
IsOutputTextStringRep := NewRepresentation(
    "IsOutputTextStringRep",
    IsPositionalObjectRep,
    [] );


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
    return Objectify( OutputTextStringType, [ str ] );
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
end );


#############################################################################
##

#F  # # # # # # # # # # # #  output text file # # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsOutputTextFileRep
##
IsOutputTextFileRep := NewRepresentation(
    "IsOutputTextFileRep",
    IsPositionalObjectRep,
    [] );


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
        return Objectify( OutputTextFileType, [fid,Immutable(str)] );
    fi;
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
#M  WriteAll( <output-text-file>, <string> )
##
InstallMethod( WriteAll,
    "output text file",
    true,
    [ IsOutputTextStream and IsOutputTextFileRep,
      IsList ],
    0,
                    
function( stream, string )
    if not IsString(string)  then
        Error( "<string> must be a string" );
    fi;
    Append( stream![1], string );
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
    WRITE_BYTE_FILE( stream![1], byte );
end );


#############################################################################
##

#F  # # # # # # # # # # # # # output text none  # # # # # # # # # # # # # # #
##


#############################################################################
##

#R  IsOutputTextNoneRep	. . . . .  representation of dummy output text stream
##
IsOutputTextNoneRep := NewRepresentation(
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
OutputTextNone := function()
    return Objectify( OutputTextNoneType, [] );
end;


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
    Add( stream![1], CHAR_INT(byte) );
end );


#############################################################################
##

#E  streams.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
