#############################################################################
##
#W  padics.gd                   GAP Library                     Jens Hollmann
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration part of the padic numbers.
##
Revision.padics_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsPadicNumber
##
IsPadicNumber :=  NewCategory( "IsPadicNumber", IsScalar 
    and IsAssociativeElement and IsCommutativeElement );

IsPadicNumberCollection := CategoryCollections( IsPadicNumber );

IsPadicNumberCollColl := CategoryCollections( IsPadicNumberCollection );

IsPadicNumberList  := IsPadicNumberCollection and IsList;
IsPadicNumberTable := IsPadicNumberCollColl   and IsTable;
    

#############################################################################
##
#C  IsPadicNumbersFamily
##
IsPadicNumbersFamily := CategoryFamily( IsPadicNumber );


#############################################################################
##
#C  IsPurePadicNumber
##
IsPurePadicNumber := NewCategory( "IsPurePadicNumber", IsPadicNumber );


#############################################################################
##
#C  IsPurePadicNumbersFamily
##
IsPurePadicNumbersFamily := CategoryFamily( IsPurePadicNumber );


#############################################################################
##
#C  IsPadicExtensionNumber
##
IsPadicExtensionNumber := NewCategory( "IsPadicExtensionNumber",
    IsPadicNumber );


#############################################################################
##
#C  IsPadicExtensionNumbersFamily
##
IsPadicExtensionNumbersFamily := CategoryFamily( IsPadicExtensionNumber );


#############################################################################
##

#O  Valuation( <obj> )
##
Valuation := NewOperation( "Valuation",  [ IsObject ] );


#############################################################################
##

#O  PadicNumber( <fam>, <obj> )
##
PadicNumber := NewOperation( "PadicNumber",
    [ IsPadicNumbersFamily, IsObject ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  ShiftedPadicNumber( <padic>, <int> )
##
ShiftedPadicNumber := NewOperation( "ShiftedPadicNumber",
    [ IsPadicNumber, IsInt ] );


#############################################################################
##
#O  PurePadicNumbersFamily( <p>, <precision> )
##
PurePadicNumbersFamily := NewOperationArgs( "PurePadicNumbersFamily" );


#############################################################################
##
#O  PadicExtensionNumbersFamily( <p>, <precision>, <unram>, <ram> )
##
PadicExtensionNumbersFamily := NewOperationArgs(
    "PadicExtensionNumbersFamily" );


#############################################################################
##

#E  padics.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
