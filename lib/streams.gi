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

#V  ClosedStreamKind
##
ClosedStreamKind := NewKind(
    StreamsFamily,
    IsClosedStream );


#############################################################################
##

#M  CloseInput( <input-stream> )
##
InstallMethod( CloseInput,
    "input stream",
    true,
    [ IsInputStream ],
    0,

function( stream )
    SET_KIND_COMOBJ( stream, ClosedStreamKind );
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
    Print( "closed stream" );
end );


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

#R  IsInputTextStringRep
##
IsInputTextStringRep := NewRepresentation(
    "IsInputTextStringRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  InputTextStringKind
##
InputTextStringKind := NewKind(
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
    return Objectify( InputTextStringKind, [ 0, Immutable(str) ] );
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
    Print( "stream(", obj![1], ",", Length(obj![2]), ")" );
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

#R  IsInputTextFileRep
##
IsInputTextFileRep := NewRepresentation(
    "IsInputTextFileRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  InputTextFileKind
##
InputTextFileKind := NewKind(
    StreamsFamily,
    IsInputTextStream and IsInputTextFileRep );


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
        return Objectify( InputTextFileKind, [fid,Immutable(str)] );
    fi;
end );


#############################################################################
##

#M  CloseInput( <input-text-file> )
##
InstallMethod( CloseInput,
    "input text file",
    true,
    [ IsInputStream and IsInputTextFileRep ],
    0,

function( stream )
    CLOSE_FILE(stream![1]);
    SET_KIND_COMOBJ( stream, ClosedStreamKind );
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
    Print( "stream(", obj![2], ")" );
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

#E  streams.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
