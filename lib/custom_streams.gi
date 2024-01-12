#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Custom streams for HPC-GAP
##

#############################################################################
##
#F  # # # # # # # # # # # # # input text custom # # # # # # # # # # # # # # #
##


#############################################################################
##
#V  InputTextCustomType
##
InputTextCustomType := NewType(
    StreamsFamily,
    IsInputTextStream and IsInputTextCustomRep );


#############################################################################
##
#M  InputTextCustom( <state>, <read>, <close> )
##
InstallGlobalFunction( InputTextCustom,
    function(state, read, close)
      return Objectify( InputTextCustomType,
        rec(
          state := state,
          read := read,
          close := close,
          pos := 0,
          endofinput := false,
          buffer := ""
        ) );
    end);

#############################################################################
##
#M  CloseStream( <input-text-custom> )
##

InstallMethod( CloseStream,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
function( stream )
    if not stream!.close(stream!.state) then
      TryNextMethod();
    fi;
end );

#############################################################################
##
#M  IsEndOfStream( <input-text-custom> )
##
InstallMethod( IsEndOfStream,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
function( stream )
    return stream!.endofinput and Length(stream!.buffer) = 0;
end );


#############################################################################
##
#M  PositionStream( <input-text-custom> )
##
InstallMethod( PositionStream,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
    function(stream)
      return stream!.pos;
    end);


#############################################################################
##
#M  PrintObj( <input-text-custom> )
##
InstallMethod( PrintObj,
    "input text custom",
    [ IsInputTextCustomRep ],
function( obj )
    Print( "InputTextCustom( ... )" );
end );


#############################################################################
##
#M  ReadAll( <input-text-custom> )
##
InstallMethod( ReadAll,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
function( stream )
    local chunk;
    stream!.endofinput := false;
    while not stream!.endofinput do
      chunk := stream!.read(stream!.state);
      if chunk = "" then
        stream!.endofinput := true;
      else
        Append(stream!.buffer, chunk);
      fi;
    od;
    chunk := stream!.buffer;
    stream!.pos := stream!.pos + Length(chunk);
    stream!.buffer := "";
    return Immutable(chunk);
end );

InstallMethod( ReadAll,
    "input text custom and limit",
    [ IsInputTextStream and IsInputTextCustomRep, IsInt ],
function( stream, limit )
    local chunk;;

    if limit < 0 then
        Error("ReadAll: negative limit is not allowed");
    fi;

    stream!.endofinput := false;
    while not stream!.endofinput and Length(stream!.buffer) < limit do
      chunk := stream!.read(stream!.state);
      Append(stream!.buffer, chunk);
      if chunk = "" then
        stream!.endofinput := true;
      fi;
    od;
    chunk := stream!.buffer{[1..Minimum(limit, Length(stream!.buffer))]};
    stream!.pos := stream!.pos + Length(chunk);
    stream!.buffer := stream!.buffer{[Length(chunk)+1..Length(stream!.buffer)]};
    return Immutable(chunk);
end );


#############################################################################
##
#M  ReadByte( <input-text-custom> )
##
InstallMethod( ReadByte,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
function( stream )
    if stream!.buffer = "" then
      stream!.buffer := stream!.read(stream!.state);
      if stream!.buffer = "" then
        stream!.endofinput := true;
        return fail;
      fi;
    fi;
    stream!.pos := stream!.pos + 1;
    return INT_CHAR(Remove(stream!.buffer, 1));
end );


#############################################################################
##
#M  ReadLine( <input-text-custom> )
##
InstallMethod( ReadLine,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
function ( stream )
    local pos, chunk;
    pos := Position(stream!.buffer, '\n');
    stream!.endofinput := false;
    while pos = fail and not stream!.endofinput do
      chunk := stream!.read(stream!.state);
      if chunk = "" then
        stream!.endofinput := true;
      else
        Append(stream!.buffer, chunk);
        pos := Position(stream!.buffer, '\n');
      fi;
    od;
    if stream!.buffer = "" then
      return fail;
    fi;
    if pos = fail then
      pos := Length(stream!.buffer);
    fi;
    chunk := stream!.buffer{[1..pos]};
    stream!.buffer := stream!.buffer{[pos+1..Length(stream!.buffer)]};
    stream!.pos := stream!.pos+pos+1;
    return chunk;
end );

#############################################################################
##
#M  RewindStream( <input-text-custom> )
##
InstallMethod( RewindStream,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep ],
ReturnFail );


#############################################################################
##
#M  SeekPositionStream( <input-text-custom> )
##
InstallMethod( SeekPositionStream,
    "input text custom",
    [ IsInputTextStream and IsInputTextCustomRep,
      IsInt ],
ReturnFail );


#############################################################################
##
#F  # # # # # # # # # # # #  output text custom # # # # # # # # # # # # # # #
##


#############################################################################
##
#R  IsOutputTextCustomRep
##
DeclareRepresentation(
    "IsOutputTextCustomRep",
    IsComponentObjectRep,
    ["state", "write", "close", "buffer", "formatting"] );


#############################################################################
##
#V  OutputTextCustomType
##
OutputTextCustomType := NewType(
    StreamsFamily,
    IsOutputTextStream and IsOutputTextCustomRep );


#############################################################################
##
#M  OutputTextCustom( <state>, <write>, <close> )
##
InstallGlobalFunction( OutputTextCustom,
function( state, write, close )
    return Objectify( OutputTextCustomType, rec (
      state := state,
      write := write,
      close := close,
      buffer := "",
      formatting := false,
    ) );
end );

#############################################################################
##
#M  CloseStream( <output-text-custom> )
##

InstallMethod( CloseStream,
    "output text custom",
    [ IsOutputTextStream and IsOutputTextCustomRep ],
function( stream )
    if not stream!.close(stream!.state) then
      TryNextMethod();
    fi;
end );



#############################################################################
##
#M  PrintObj( <output-text-custom> )
##
InstallMethod( PrintObj,
    "output text custom",
    [ IsOutputTextCustomRep ],
function( obj )
    Print( "OutputTextCustom( ... )" );
end );


#############################################################################
##
#M  WriteAll( <output-text-custom>, <custom> )
##
InstallMethod( WriteAll,
    "output text custom",
    [ IsOutputTextStream and IsOutputTextCustomRep,
      IsString ],
function( stream, string )
    Append( stream!.buffer, string );
    stream!.write(stream!.state, stream!.buffer);
    stream!.buffer := "";
    return true;
end );


#############################################################################
##
#M  WriteByte( <output-text-custom>, <byte> )
##
InstallMethod( WriteByte,
    "output text custom",
    [ IsOutputTextStream and IsOutputTextCustomRep,
      IsInt ],
function( stream, byte )
    if byte < 0 or 255 < byte  then
        Error( "<byte> must an integer between 0 and 255" );
    fi;
    if byte = 3 then
      if stream!.buffer <> "" then
        stream!.write(stream!.state, stream!.buffer);
        stream!.buffer := "";
      fi;
    else
      Add( stream!.buffer, CHAR_INT(byte) );
      if byte = 10 then
        stream!.write(stream!.state, stream!.buffer);
        stream!.buffer := "";
      fi;
    fi;
    return true;
end );

#############################################################################
##
#M  PrintFormattingStatus( <output-text-custom> )
##
InstallMethod( PrintFormattingStatus, "output text custom",
        [IsOutputTextCustomRep and IsOutputTextStream],
        str -> str!.formatting);

#############################################################################
##
#M  SetPrintFormattingStatus( <output-text-custom>, <status> )
##
InstallMethod( SetPrintFormattingStatus, "output text custom",
        [IsOutputTextCustomRep and IsOutputTextStream,
         IsBool],
        function( str, stat)
    if stat = fail then
        Error("Print formatting status must be true or false");
    else
        str!.formatting := stat;
    fi;
end);
