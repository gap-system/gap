#############################################################################
##
#W  addcoset.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for additive cosets.
##
Revision.addcoset_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsAdditiveCosetDefaultRep
##
##  The default additive coset is represented as a list object that stores
##  at first position the additively acting domain, and at second position
##  a representative.
##  (Of course this representative need not be normalized.)
##
IsAdditiveCosetDefaultRep := NewRepresentation( "IsAdditiveCosetDefaultRep",
    IsPositionalObjectRep,
    [ 1, 2 ] );


#############################################################################
##
#M  AdditiveCoset( <A>, <a> ) . . . . . . . . for add. group and add. element
##
##  The default method constructs an additive coset
##  in 'IsAdditiveCosetDefaultRep'.
##
InstallMethod( AdditiveCoset,
    "method for additive group and additive element",
    IsCollsElms,
    [ IsAdditiveGroup, IsAdditiveElement ], 0,
    function( A, a )
    return Objectify( NewType( FamilyObj( A ),
                                   IsAdditiveCoset
                               and IsAdditiveCosetDefaultRep ),
                      [ A, a ] );
    end );


#############################################################################
##
#M  AdditivelyActingDomain( <A> ) . . . . . for add. coset in default repres.
##
InstallMethod( AdditivelyActingDomain,
    "method for additive coset in default repres.",
    true,
    [ IsAdditiveCoset and IsAdditiveCosetDefaultRep ], SUM_FLAGS,
    A -> A![1] );


#############################################################################
##
#M  Representative( <A> ) . . . . . . . . . for add. coset in default repres.
##
InstallMethod( Representative,
    "method for additive coset in default repres.",
    true,
    [ IsAdditiveCoset and IsAdditiveCosetDefaultRep ], SUM_FLAGS,
    A -> A![2] );


#############################################################################
##
#M  \+( <A>, <a> )  . . . . . . . . . for additive group and additive element
#M  \+( <a>, <A> )  . . . . . . . . . for additive element and additive group
##
InstallOtherMethod( \+,
    "method for additive group and additive element",
    IsCollsElms,
    [ IsAdditiveGroup, IsAdditiveElement ], 0,
    function( A, a )
    return AdditiveCoset( A, a );
    end );

InstallOtherMethod( \+,
    "method for additive element and additive group",
    IsElmsColls,
    [ IsAdditiveElement, IsAdditiveGroup ], 0,
    function( a, A )
    return AdditiveCoset( A, a );
    end );


#############################################################################
##
#M  \+( <C>, <a> )  . . . . . . . . . for additive coset and additive element
#M  \+( <a>, <C> )  . . . . . . . . . for additive element and additive coset
##
InstallMethod( \+,
    "method for additive coset and additive element",
    IsCollsElms,
    [ IsAdditiveCoset, IsAdditiveElement ], 0,
    function( C, a )
    return AdditiveCoset( AdditivelyActingDomain( C ),
                          a + Representative( C ) );
    end );

InstallMethod( \+,
    "method for additive element and additive coset",
    IsElmsColls,
    [ IsAdditiveElement, IsAdditiveCoset ], 0,
    function( a, C )
    return AdditiveCoset( AdditivelyActingDomain( C ),
                          a + Representative( C ) );
    end );


#############################################################################
##
#M  Enumerator( <A> ) . . . . . . . . . . . . . . . . . . for additive cosets
##
InstallMethod( Enumerator,
    "method for an additive coset",
    true,
    [ IsAdditiveCoset ], 0,
    function( A )
    local rep;
    rep:= Representative( A );
    return List( AsList( AdditivelyActingDomain( A ) ), a -> rep + a );
    end );


#############################################################################
##
#M  IsFinite( <A> ) . . . . . . . . . . . . . . . . . . . for additive cosets
##
InstallMethod( IsFinite,
    "method for an additive coset",
    true,
    [ IsAdditiveCoset ], 0,
    A -> IsFinite( AdditivelyActingDomain( A ) ) );


#############################################################################
##
#M  Random( <A> ) . . . . . . . . . . . . . . . . . . . . for additive cosets
##
InstallMethod( Random,
    "method for an additive coset",
    true,
    [ IsAdditiveCoset ], 0,
    A -> Representative( A ) + Random( AdditivelyActingDomain( A ) ) );


#############################################################################
##
#M  Size( <A> ) . . . . . . . . . . . . . . . . . . . . . for additive cosets
##
InstallMethod( Size,
    "method for an additive coset",
    true,
    [ IsAdditiveCoset ], 0,
    A -> Size( AdditivelyActingDomain( A ) ) );


#############################################################################
##
#M  \=( <A1>, <A2> )  . . . . . . . . . . . . . . . . for two additive cosets
##
InstallMethod( \=,
    "method for two additive cosets",
    IsIdentical,
    [ IsAdditiveCoset, IsAdditiveCoset ], 0,
    function( A1, A2 )
    local D;
    D:= AdditivelyActingDomain( A1 );
    return     D = AdditivelyActingDomain( A2 )
           and Representative( A1 ) - Representative( A2 ) in D;
    end );


#T  #############################################################################
#T  ##
#T  #M  \=( <A1>, <A2> )  . . . . . . for two additive cosets with canon. repres.
#T  ##
#T  InstallMethod( \=,
#T      "method for two additive cosets with canon. repres.",
#T      IsIdentical,
#T      [ IsAdditiveCoset and HasCanonicalRepresentative,
#T        IsAdditiveCoset and HasCanonicalRepresentative ], 0,
#T      function( A1, A2 )
#T      return     AdditivelyActingDomain( A1 ) = AdditivelyActingDomain( A2 )
#T             and CanonicalRepresentative( A1 ) = CanonicalRepresentative( A2 );
#T      end );


#############################################################################
##
#M  \=( <C>, <A> )  . . . . . . . . . . for additive coset and additive group
##
InstallMethod( \=,
    "method for additive coset and additive group",
    IsIdentical,
    [ IsAdditiveCoset, IsAdditiveGroup ], 0,
    function( C, A )
    return     AdditivelyActingDomain( C ) = A
           and Representative( C ) in A;
    end );


#############################################################################
##
#M  \=( <A>, <C> )  . . . . . . . . . . for additive group and additive coset
##
InstallMethod( \=,
    "method for additive group and additive coset",
    IsIdentical,
    [ IsAdditiveGroup, IsAdditiveCoset ], 0,
    function( A, C )
    return     AdditivelyActingDomain( C ) = A
           and Representative( C ) in A;
    end );


#############################################################################
##
#M  \in( <a>, <A> ) . . . . . . . . . for additive element and additive coset
##
InstallMethod( \in,
    "method for additive element and additive coset",
    IsElmsColls,
    [ IsAdditiveElement, IsAdditiveCoset ], 0,
    function( a, A )
    return a - Representative( A ) in AdditivelyActingDomain( A );
    end );


#############################################################################
##
#M  Intersection2( <C1>, <C2> ) . . . . . . . . . . . for two additive cosets
## 
InstallMethod( Intersection2,
    "method for two additive cosets",
    IsIdentical,
    [ IsAdditiveCoset, IsAdditiveCoset ], 0,
    function( C1, C2 )
    if AdditivelyActingDomain( C1 ) = AdditivelyActingDomain( C2 ) then
      if Representative( C1 ) in C2 then
        return C1;
      else
        return [];
      fi;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  PrintObj( <A> ) . . . . . . . . . . . . . . . . . . for an additive coset
## 
InstallMethod( PrintObj,
    "method for an additive coset",
    true,
    [ IsAdditiveCoset ], 0,
    function( A )
    Print( "( ", Representative( A ), " + ",
           AdditivelyActingDomain( A ), " )" );
    end );


#T  #############################################################################
#T  ##
#T  #F  SpaceCosetOps.\*( <s>, <C> )
#T  ## 
#T  SpaceCosetOps.\* := function( scalar, C )
#T      if     not IsInt( scalar )
#T         and not scalar in C.factorDen.field then
#T        Error( "only scalar multiplication" );
#T      fi;
#T      return SpaceCoset( C.factorDen, scalar * C.representative );
#T      end;


#############################################################################
##
#E  addcoset.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



