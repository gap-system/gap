#############################################################################
##
#W  arith.gi                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains  the generic  methods  for elements in families  that
##  allow certain arithmetical operations.
##
Revision.arith_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  Zero(<elm>)
##
InstallMethod( Zero,
    true, [ IsAdditiveElementWithZero ], 0,
    function ( elm )
    local   F;
    F := FamilyObj( elm );
    if not HasZero( F ) then
        TryNextMethod();
    fi;
    return Zero( F );
    end );


#############################################################################
##
#M  IsZero(<elm>)
##
InstallMethod( IsZero,
    true, [ IsAdditiveElementWithZero ], 0,
    function ( elm )
    return (elm = 0*elm);
    end );


#############################################################################
##
#M  <elm1>-<elm2>
##
InstallMethod( \-,
    true, [ IsExtAElement, IsAdditiveElementWithInverse ], 0,
    DIFF_DEFAULT );

#############################################################################
##
#M  One(<elm>)
##
InstallMethod( One,
    true, [ IsMultiplicativeElementWithOne ], 0,
    function ( elm )
    local   F;
    F := FamilyObj( elm );
    if not HasOne( F ) then
        TryNextMethod();
    fi;
    return One( F );
    end );


#############################################################################
##
#M  IsOne(<elm>)
##
InstallMethod( IsOne,
    true, [ IsMultiplicativeElementWithOne ], 0,
    function ( elm )
    return (elm = elm^0);
    end );


#############################################################################
##
#M  '<elm1>/<elm2>'
##
InstallMethod( \/,
    true, [ IsExtRElement, IsMultiplicativeElementWithInverse ], 0,
    QUO_DEFAULT );


#############################################################################
##
#M  LeftQuotient(<elm1>,<elm2>)
##
InstallMethod( LeftQuotient,
    true, [ IsMultiplicativeElementWithInverse, IsExtLElement ], 0,
    LQUO_DEFAULT );


#############################################################################
##
#M  '<elm1>^<elm2>'
##
InstallMethod( \^,
    IsIdentical,
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,
    POW_DEFAULT );


#############################################################################
##
#M  'Comm(<elm1>,<elm2>)'
##
InstallMethod( Comm,
    IsIdentical,
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,
    COMM_DEFAULT );


#############################################################################
##
#M  LieBracket(<elm1>,<elm2>)
##
InstallMethod( LieBracket,
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function ( elm1, elm2 )
    return ( elm1 * elm2 ) - ( elm2 * elm1 );
    end );


#############################################################################
##
#M  '<int>*<elm>'
##
InstallOtherMethod( \*,
    "positive integer * additive element",
    true, [ IsInt and IsPosRat, IsAdditiveElement ], 0,
    PROD_INT_OBJ );

InstallOtherMethod( \*,
    "zero integer * additive element with zero",
    true, [ IsInt and IsZeroCyc, IsAdditiveElementWithZero ], 0,
    PROD_INT_OBJ );

InstallOtherMethod( \*,
    "negative integer * additive element with inverse",
    true, [ IsInt and IsNegRat, IsAdditiveElementWithInverse ], 0,
    PROD_INT_OBJ );


#############################################################################
##
#M  '<elm>^<int>'
##
InstallMethod( \^,
    true, [ IsMultiplicativeElement, IsInt and IsPosRat ], 0,
    POW_OBJ_INT );

InstallMethod( \^,
    true, [ IsMultiplicativeElementWithOne, IsZeroCyc ], 0,
    POW_OBJ_INT );

InstallMethod( \^,
    true, [ IsMultiplicativeElementWithInverse, IsInt and IsNegRat ], 0,
    POW_OBJ_INT );


#############################################################################
##
#M  SetElementsFamily( <Fam>, <ElmsFam> )
##
InstallMethod( SetElementsFamily,
    "method to inherit 'Characteristic' to collections families",
    true,
    [ IsFamily and IsAttributeStoringRep, IsFamily ], SUM_FLAGS + 1,
    function( Fam, ElmsFam )
    if HasCharacteristic( ElmsFam ) then
      SetCharacteristic( Fam, Characteristic( ElmsFam ) );
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  Characteristic(<obj>)
##
InstallMethod( Characteristic,
    true, [ IsObject ], 0,
    function ( obj )
    local   F;
    F := FamilyObj( obj );
    if not HasCharacteristic( F ) then
        TryNextMethod();
    fi;
    return Characteristic( F );
end );


#############################################################################
##
#M  Order( <obj> )
##
InstallMethod( Order, true, [ IsMultiplicativeElementWithOne ], 0,
    function( obj )
    local one, pow, ord;
    one:= One( obj );
    pow:= obj;
    ord:= 1;
    while pow <> one do
    ord:= ord + 1;
      pow:= pow * obj;
    od;
    return ord;
    end );
#T warnings ??


#############################################################################
##
#M  NormedRowVector( <v> )
##
InstallMethod( NormedRowVector,
    true,
    [ IsRowVector and IsScalarCollection ],
    0,

function( v )
    local   depth;

    if 0 < Length(v)  then
        depth := PositionNot( v, Zero(v[1]) );
        if depth <= Length(v) then
            return Inverse(v[depth]) * v;
        else
            return ShallowCopy(v);
        fi;
    else
        return ShallowCopy(v);
    fi;
end );


#############################################################################
##
#E  arith.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



