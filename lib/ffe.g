#############################################################################
##
#W  ffe.g                        GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#V  TYPES_FFE . . . . . . . . . . . . .  list of known types of internal ffes
##
#T TYPES_FFE := WeakPointerObj( [] );
TYPES_FFE := [];


#############################################################################
##
#F  TYPE_FFE( <p> ) . . . . . . . . . . . type of a ffe in characteristic <p>
##
##  see also "ffe.gi"
##
TYPE_FFE := function ( p )
    local type, fam;
    if IsBound( TYPES_FFE[p] ) then
      return TYPES_FFE[p];
    fi;
#T     if IsBoundElmWPObj( TYPES_FFE, p ) then
#T       type:= ElmWPObj( TYPES_FFE, p );
#T       if type <> fail then
#T         return type;
#T       fi;
#T     fi;
    fam:= NewFamily( "FFEFamily", IS_FFE );
    SetIsUFDFamily( fam, true );
    SetCharacteristic( fam, p );
    type:= NewType( fam, IS_FFE and IsInternalRep );
    TYPES_FFE[p]:= type;
#T     SetElmWPObj( TYPES_FFE, p, type );
    return type;
end;


#############################################################################
##

#M  DegreeFEE( <ffe> )  . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( DegreeFFE,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    DEGREE_FFE_DEFAULT );


#############################################################################
##
#M  LogFFE( <ffe>, <ffe> )  . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( LogFFE,
    "for two internal FFEs",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsFFE and IsInternalRep ], 0,
    LOG_FFE_DEFAULT );


#############################################################################
##
#M  IntFFE( <ffe> ) . . . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( IntFFE,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    INT_FFE_DEFAULT );


#############################################################################
##
#M  \*( <ffe>, <int> )  . . . . . . . . . . . . . for ffe and (large) integer
##
##  Note that the multiplication with a small integer is handled by the
##  kernel.
##
InstallOtherMethod( \*,
    "ffe * (large) integer",
    true,
    [ IsFFE, IsInt ], 0,
    function( ffe, int )
    local char;
    char:= Characteristic( ffe );
    if IsSmallIntRep( char ) then
      return ffe * ( int mod char );
    else
      return PROD_INT_OBJ( int, ffe );
    fi;
    end );
        

#############################################################################
##

#F  SUM_FFE_LARGE
#F  DIFF_FFE_LARGE
#F  PROD_FFE_LARGE
#F  QUO_FFE_LARGE
#F  LOG_FFE_LARGE
##
##  If the {\GAP} kernel cannot handle the addition, multiplication etc.
##  of internally represented FFEs then it delegates to the library without
##  checking the characteristic; therefore this check must be done here.
##  (Note that `LogFFE' is an operation for which the kernel does not know
##  a table of methods, so the check for equal characteristic is done by
##  the method selection.
#T  Note that `LogFFEHandler' would not need to call `LOG_FFE_DEFAULT';
#T  if the two arguments <z>, <r> are represented w.r.t. incompatible fields
#T  then either <z> can be represented in the field of <r> or the logarithm
#T  does not exist.
##
SUM_FFE_LARGE := function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
    fi;
    Error( "not supported yet" );
end;

DIFF_FFE_LARGE := function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
    fi;
    Error( "not supported yet" );
end;

PROD_FFE_LARGE := function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
    fi;
    Error( "not supported yet" );
end;

QUO_FFE_LARGE := function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
    fi;
    Error( "not supported yet" );
end;

LOG_FFE_LARGE := function( x, y )
    Error( "not supported yet" );
end;


#############################################################################
##

#E  ffe.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
