#############################################################################
##
#W  boolean.g                    GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with booleans.
##
Revision.boolean_g :=
    "@(#)$Id$";


#############################################################################
##
#C  IsBool  . . . . . . . . . . . . . . . . . . . . . .  category of booleans
##
IsBool := NewCategoryKernel( "IsBool", IsObject, IS_BOOL );


#############################################################################
##
#V  BooleanFamily . . . . . . . . . . . . . . . . . . . .  family of booleans
##
BooleanFamily := NewFamily(  "BooleanFamily", IS_BOOL );


#############################################################################
##
#F  TYPE_BOOL . . . . . . . . . . . . . . . . . . . type of internal booleans
##
TYPE_BOOL := NewType( BooleanFamily, IS_BOOL and IsInternalRep );


#############################################################################
##
#M  String( <bool> )  . . . . . . . . . . . . . . . . . . . . . for a boolean
##
InstallMethod( String,
    "method for a boolean",
    true,
    [ IsBool ], 0,
    function( bool )
    if bool = true then
      return "true";
    elif bool = false  then
      return "false";
    elif bool = fail  then
      return "fail";
    else
      Error( "unknown boolean" );
    fi;
    end );


#############################################################################
##

#E  boolean.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
