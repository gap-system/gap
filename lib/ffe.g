#############################################################################
##
#W  ffe.g                        GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with internal finite field elements.
##
Revision.ffe_g :=
    "@(#)$Id$";


#############################################################################
##

#V  MAXSIZE_GF_INTERNAL . . . . . . . . . . . . maximal size of internal ffes
##
MAXSIZE_GF_INTERNAL := 2^16;


#############################################################################
##
#V  FAMS_FFE  . . . . . . . . . . . . list of known families of internal ffes
##
FAMS_FFE  := [];


#############################################################################
##
#V  TYPES_FFE . . . . . . . . . . . . .  list of known types of internal ffes
##
TYPES_FFE := [];


#############################################################################
##
#F  TYPE_FFE( <p> ) . . . . . . . . . . . type of a ffe in characteristic <p>
##
##  see also "ffe.gi"
##
TYPE_FFE  := function ( p )
    if not IsBound( TYPES_FFE[p] )  then
        FAMS_FFE[p] := NewFamily( "FFEFamily", IS_FFE );
        SetIsUFDFamily( FAMS_FFE[p], true );
        SetCharacteristic( FAMS_FFE[p], p );
        TYPES_FFE[p] := NewType( FAMS_FFE[p], IS_FFE and IsInternalRep );
    fi;
    return TYPES_FFE[p];
end;


#############################################################################
##

#M  DegreeFEE( <ffe> )  . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( DegreeFFE,
    "method for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    DEGREE_FFE_DEFAULT );


#############################################################################
##
#M  LogFFE( <ffe>, <ffe> )  . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( LogFFE,
    "method for two internal FFEs",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsFFE and IsInternalRep ], 0,
    LOG_FFE_DEFAULT );


#############################################################################
##
#M  IntFFE( <ffe> ) . . . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( IntFFE,
    "method for internal FFE",
    true, [ IsFFE and IsInternalRep ], 0,
    INT_FFE_DEFAULT );

#############################################################################
##

#F  SUM_FFE_LARGE
#F  DIFF_FFE_LARGE
#F  PROD_FFE_LARGE
#F  QUO_FFE_LARGE
#F  LOG_FFE_LARGE
##
SUM_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
DIFF_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
PROD_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
QUO_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
LOG_FFE_LARGE := function(arg) Error( "not supported yet" ); end;


#############################################################################
##

#E  ffe.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
