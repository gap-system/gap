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

#V  StreamsFamily
##
StreamsFamily := NewFamily( "StreamsFamily" );


#############################################################################
##

#O  IsEndOfStream( <input-text-stream> )
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
ReadAll := NewOperation(
    "ReadAll",
    [ IsInputTextStream ] );


#############################################################################
##
#O  ReadByte( <input-text-stream> )
##
ReadByte := NewOperation(
    "ReadByte",
    [ IsInputTextStream ] );
                    

#############################################################################
##
#O  ReadLine( <input-text-stream> )
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

#O  CloseInput( <input-stream> )
##
CloseInput := NewOperation(
    "CloseInput",
    [ IsInputStream ] );


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

#E  streams.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
