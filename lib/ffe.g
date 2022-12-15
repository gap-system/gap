#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with internal finite field elements.
##


#############################################################################
##
#V  MAXSIZE_GF_INTERNAL . . . . . . . . . . . . maximal size of internal ffes
##
## Now set by the kernel.


#############################################################################
##
#F  TYPE_FFE( <p> ) . . . . . . . . . . . type of a ffe in characteristic <p>
##
##  <p> must be a small prime integer
##  (see also `ffe.gi').
##
##  Note that the `One' and `Zero' values of the family cannot be set
##  in `TYPE_FFE' since this would need access to `One( Z(<p>) )' and
##  `Zero( Z(<p>) )', respectively,
##  which in turn would call `TYPE_FFE' and thus would lead to an infinite
##  recursion.
##
BIND_GLOBAL( "TYPE_FFE", MemoizePosIntFunction(
    function( p )
        local fam;
        fam:= NewFamily( "FFEFamily",
        IS_FFE,CanEasilySortElements,CanEasilySortElements );
        SetIsUFDFamily( fam, true );
        SetCharacteristic( fam, p );
        return NewType( fam, IS_FFE and IsInternalRep and HasDegreeFFE);
    end, rec(flush := false) ));


#############################################################################
##
#F  TYPE_FFE0( <p> ) . . . . . . . . .type of zero ffe in characteristic <p>
##
##  see also "ffe.gi"
##
BIND_GLOBAL( "TYPE_FFE0", MemoizePosIntFunction(
    function ( p )
        local fam;

        fam:= FamilyType(TYPE_FFE(p));
        return NewType( fam, IS_FFE and IsInternalRep and IsZero and HasIsZero
                            and HasDegreeFFE );
    end, rec(flush := false) ));


#############################################################################
##
#m  DegreeFEE( <ffe> )  . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( DegreeFFE,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    DEGREE_FFE_DEFAULT );

#############################################################################
##
#m  Characteristic( <ffe> )   . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( Characteristic,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    CHAR_FFE_DEFAULT );


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
#m  \*( <ffe>, <int> )  . . . . . . . . . . . . . for ffe and (large) integer
##
##  Note that the multiplication of internally represented FFEs with small
##  integers is handled by the kernel.
##
InstallOtherMethod( \*,
    "internal ffe * (large) integer",
    true,
    [ IsFFE and IsInternalRep, IsInt ], 0,
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
#O  SUM_FFE_LARGE
#O  DIFF_FFE_LARGE
#O  PROD_FFE_LARGE
#O  QUO_FFE_LARGE
#O  LOG_FFE_LARGE
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

DeclareOperation("SUM_FFE_LARGE", [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep]);

InstallOtherMethod(SUM_FFE_LARGE,  [IsFFE,
        IsFFE],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);

DeclareOperation("DIFF_FFE_LARGE", [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep]);

InstallOtherMethod(DIFF_FFE_LARGE,  [IsFFE,
        IsFFE],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);

DeclareOperation("PROD_FFE_LARGE", [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep]);

InstallOtherMethod(PROD_FFE_LARGE,  [IsFFE,
        IsFFE ],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);

DeclareOperation("QUO_FFE_LARGE", [IsFFE,
        IsFFE]);

InstallOtherMethod(QUO_FFE_LARGE,  [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);


BIND_GLOBAL( "LOG_FFE_LARGE", function( x, y )
    Error( "not supported yet -- this should never happen" );
end );

#############################################################################
##
#O  ZOp -- operation to compute Z for large values of q
##

DeclareOperation("ZOp", [IsPosInt]);
