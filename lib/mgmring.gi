#############################################################################
##
#W  mgmring.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for magma rings and their elements.
##
##  1. methods for elements of magma rings in default representation
##  2. methods for free magma rings
##  3. methods for free left modules of free magma ring elements
##
Revision.mgmring_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. methods for elements of magma rings in default representation
##

#############################################################################
##
#R  IsMagmaRingObjDefaultRep( <obj> )
##
##  The default representation of an element object is a list of length 2,
##  at first position the zero coefficient, at second position a list with
##  the coefficients at the even positions, and the magma elements at the
##  odd positions, with the ordering as defined for the magma elements.
##
##  It is assumed that the arithmetic operations of $M$ produce only
##  normalized elements.
##
DeclareRepresentation( "IsMagmaRingObjDefaultRep", IsPositionalObjectRep,
    [ 1, 2 ] );


#############################################################################
##
#M  NormalizedElementOfMagmaRingModuloRelations( <Fam>, <descr> )
##
##  A free magma ring element is normalized if <descr> is sorted according to
##  the involved magma elements.
##  Thus normalization is trivial.
##
InstallMethod( NormalizedElementOfMagmaRingModuloRelations,
    "for a family of elements in a *free* magma ring, and a list",
    true,
    [ IsElementOfFreeMagmaRingFamily, IsList ], 0,
    function( Fam, descr )
    return descr;
    end );


#############################################################################
##
#F  FMRRemoveZero( <coeffs_and_words>, <zero> )
##
##  removes all pairs from <coeffs_and_words> where the coefficient
##  is <zero>.
##  Note that <coeffs_and_words> is assumed to be sorted.
##
FMRRemoveZero := function( coeffs_and_words, zero )

    local i,    # offset of old and new position
          lenw, # length of `words' and `coeff'
          pos;  # loop over the lists

    i:= 0;
    lenw:= Length( coeffs_and_words );
    for pos in [ 2, 4 .. lenw ] do
      if   coeffs_and_words[ pos ] = zero then
        i:= i + 2;
      elif i < pos then
        coeffs_and_words[ pos-i-1 ]:= coeffs_and_words[ pos-1 ];
        coeffs_and_words[ pos-i   ]:= coeffs_and_words[ pos   ];
      fi;
    od;
    for pos in [ lenw-i+1 .. lenw ] do
      Unbind( coeffs_and_words[ pos ] );
    od;
    return coeffs_and_words;
end;


#############################################################################
##
#M  ElementOfMagmaRing( <Fam>, <zerocoeff>, <coeff>, <words> )
##
##  check whether <coeff> and <words> lie in the correct domains,
##  and remove zeroes.
##
InstallMethod( ElementOfMagmaRing,
    "for family, ring element, and two homogeneous lists",
    true,
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ], 0,
    function( Fam, zerocoeff, coeff, words )
    local rep, i, j;

    # Check that the data is admissible.
    if not IsBound( Fam!.defaultType ) then
      TryNextMethod();
    elif not IsIdenticalObj( FamilyObj( coeff ), Fam!.familyRing ) then
      Error( "<coeff> are not all in the correct domain" );
    elif not IsIdenticalObj( FamilyObj( words ), Fam!.familyMagma ) then
      Error( "<words> are not all in the correct domain" );
    elif Length( coeff ) <> Length( words ) then
      Error( "<coeff> and <words> must have same length" );
    fi;

    # Make sure that the list of words is strictly sorted.
    if not IsSSortedList( words ) then
      words:= ShallowCopy( words );
      coeff:= ShallowCopy( coeff );
      SortParallel( words, coeff );
      if not IsSSortedList( words ) then
        j:= 1;
        for i in [ 2 .. Length( coeff ) ] do
          if words[i] = words[j] then
            coeff[j]:= coeff[j] + coeff[i];
          else
            j:= j+1;
            words[j]:= words[i];
            coeff[j]:= coeff[i];
          fi;
        od;
        for i in [ j+1 .. Length( coeff ) ] do
          Unbind( words[i] );
          Unbind( coeff[i] );
        od;
      fi;
    fi;

    # Create the default representation, and remove zeros.
    rep:= [];
    j:= 1;
    for i in [ 1 .. Length( coeff ) ] do
      if coeff[i] <> zerocoeff then
        rep[  j  ]:= words[i];
        rep[ j+1 ]:= coeff[i];
        j:= j+2;
      fi;
    od;

    # Normalize the result.
    rep:= NormalizedElementOfMagmaRingModuloRelations( Fam,
              [ zerocoeff, rep ] );

    # Return the result.
    return Objectify( Fam!.defaultType, rep );
    end );


#############################################################################
##
#M  CoefficientsAndMagmaElements( <elm> )
##
InstallMethod( CoefficientsAndMagmaElements,
    "for magma ring element in default repr.",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 0,
    elm -> elm![2] );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . . for magma ring element in default repr.
##
InstallMethod( PrintObj,
    "for magma ring element",
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( elm )

    local coeffs_and_words,
          i;

    coeffs_and_words:= CoefficientsAndMagmaElements( elm );
    for i in [ 1, 3 .. Length( coeffs_and_words ) - 3 ] do
      Print( coeffs_and_words[i+1], "*", coeffs_and_words[i], "+" );
    od;
    i:= Length( coeffs_and_words );
    if i = 0 then
      Print( "<zero> of ..." );
    else
      Print( coeffs_and_words[i], "*", coeffs_and_words[i-1] );
    fi;
    end );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . for two free magma ring elements in default repr.
##
InstallMethod( \=,
    "for two free magma ring elements",
    IsIdenticalObj,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ], 0,
    function( x, y )
    return   CoefficientsAndMagmaElements( x )
           = CoefficientsAndMagmaElements( y );
    end );


#############################################################################
##
#M  \<( <x>, <y> )  . . . . for two free magma ring elements in default repr.
##
InstallMethod( \<,
    "for two free magma ring elements",
    IsIdenticalObj,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ], 0,
    function( x, y )
    local i;
    x:= CoefficientsAndMagmaElements( x );
    y:= CoefficientsAndMagmaElements( y );
    for i in [ 1 .. Minimum( Length( x ), Length( y ) ) ] do
      if   x[i] < y[i] then
        return true;
      elif y[i] < x[i] then
        return false;
      fi;
    od;
    return Length( x ) <= Length( y );
    end );


#############################################################################
##
#M  \+( <x>, <y> )  . . . . . .  for two magma ring elements in default repr.
##
InstallMethod( \+,
    "for two magma ring elements",
    IsIdenticalObj,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ], 0,
    function( x, y )
    local F, sum;
    F := FamilyObj( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );
    sum:= ZippedSum( x, y, F!.zeroRing, [ \<, \+ ] );
    sum:= NormalizedElementOfMagmaRingModuloRelations( F,
              [ F!.zeroRing, sum ] );
    return Objectify( F!.defaultType, sum );
    end );


#############################################################################
##
#M  AdditiveInverse( <x> )  . . . . . for magma ring element in default repr.
##
InstallMethod( AdditiveInverse,
    "for free magma ring element",
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( x )
    local ext, i, Fam, inv;
    ext:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length( ext ) ] do
      ext[i]:= AdditiveInverse( ext[i] );
    od;
    Fam:= FamilyObj( x );
    inv:= NormalizedElementOfMagmaRingModuloRelations( Fam,
              [ Fam!.zeroRing, ext ] );
    return Objectify( Fam!.defaultType, inv );
    end );


#############################################################################
##
#M  \*( <x>, <y> )  . . . . . .  for two magma ring elements in default repr.
##
InstallMethod( \*,
    "for two magma ring elements",
    IsIdenticalObj,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ], 0,
    function( x, y )
    local F, prod;
    F := FamilyObj( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );
    prod:= ZippedProduct( x, y, F!.zeroRing, [ \*, \<, \+, \* ] );
    prod:= NormalizedElementOfMagmaRingModuloRelations( F,
               [ F!.zeroRing, prod ] );
    return Objectify( F!.defaultType, prod );
    end );


#############################################################################
##
#M  \*( x, r )  . . . . . . . . . . .  for magma ring element and coefficient
##
##  Note that multiplication with zero or zero divisors
##  may cause zero coefficients in the result.
##  So we must normalize the elements.
#T  (But we can avoid the argument check)
#T  Should these two aspects be treated separately in general?
#T  Should multiplication with zero be avoided (store the zero)?
#T  Should the nonexistence of zero divisors be known/used?
##
ElmTimesRingElm := function( x, y )
    local F, i, prod;
    F:= FamilyObj( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] * y;
    od;
    prod:= NormalizedElementOfMagmaRingModuloRelations( F,
               [ F!.zeroRing, FMRRemoveZero( x, F!.zeroRing ) ] );
    return Objectify( F!.defaultType, prod );
end;

InstallMethod( \*,
    "for magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsElementOfMagmaRingModuloRelations, IsRingElement ], 0,
    ElmTimesRingElm );

InstallMethod( \*,
    "for magma ring element, and integer",
    true,
    [ IsElementOfMagmaRingModuloRelations, IsInt ], 0,
    ElmTimesRingElm );


#############################################################################
##
#M  \*( <r>, <x> )  . . . . . . . . .  for coefficient and magma ring element
#M  \*( <r>, <x> )  . . . . . . . . . . .  for integer and magma ring element
##
RingElmTimesElm := function( x, y )
    local F, i, prod;
    F:= FamilyObj( y );
    y:= ShallowCopy( CoefficientsAndMagmaElements( y ) );
    for i in [ 2, 4 .. Length(y) ] do
      y[i]:= x * y[i];
    od;
    prod:= NormalizedElementOfMagmaRingModuloRelations( F,
               [ F!.zeroRing, FMRRemoveZero( y, F!.zeroRing ) ] );
    return Objectify( F!.defaultType, prod );
end;

InstallMethod( \*,
    "for ring element, and magma ring element",
    IsRingsMagmaRings,
    [ IsRingElement, IsElementOfMagmaRingModuloRelations ],0,
    RingElmTimesElm );

InstallMethod( \*,
    "for integer, and magma ring element",
    true,
    [ IsInt, IsElementOfMagmaRingModuloRelations ],0,
    RingElmTimesElm );


#############################################################################
##
#M  \*( <m>, <x> )  . . . . . . . .  for magma element and magma ring element
#M  \*( <x>, <m> )  . . . . . . . .  for magma ring element and magma element
##
InstallMethod( \*,
    "for magma element and magma ring element",
    IsMagmasMagmaRings,
    [ IsMultiplicativeElement, IsElementOfMagmaRingModuloRelations ], 0,
    function( m, x )
    local F;
    F:= FamilyObj( x );
    x:= ZippedProduct( [ m, One( F!.zeroRing ) ],
                       CoefficientsAndMagmaElements( x ),
                       F!.zeroRing,
                       [ \*, \<, \+, \* ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F,
            [ F!.zeroRing, x ] );
    return Objectify( F!.defaultType, x );
    end );

InstallMethod( \*,
    "for magma ring element and magma element",
    IsMagmaRingsMagmas,
    [ IsElementOfMagmaRingModuloRelations, IsMultiplicativeElement ], 0,
    function( x, m )
    local F;
    F:= FamilyObj( x );
    x:= ZippedProduct( CoefficientsAndMagmaElements( x ),
                       [ m, One( F!.zeroRing ) ],
                       F!.zeroRing,
                       [ \*, \<, \+, \* ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F,
            [ F!.zeroRing, x ] );
    return Objectify( F!.defaultType, x );
    end );


#############################################################################
##
#M  \+( <m>, <x> )  . . . . . . . .  for magma element and magma ring element
#M  \+( <x>, <m> )  . . . . . . . .  for magma ring element and magma element
##
InstallOtherMethod( \+,
    "for magma element and magma ring element",
    IsMagmasMagmaRings,
    [ IsMultiplicativeElement, IsElementOfMagmaRingModuloRelations ], 0,
    function( m, x )
    local F;
    F:= FamilyObj( x );
    x:= ZippedSum( [ m, One( F!.zeroRing ) ],
                   CoefficientsAndMagmaElements( x ),
                   F!.zeroRing, [ \<, \+ ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F,
            [ F!.zeroRing, x ] );
    return Objectify( F!.defaultType, x );
    end );

InstallOtherMethod( \+,
    "for magma ring element and magma element",
    IsMagmaRingsMagmas,
    [ IsElementOfMagmaRingModuloRelations, IsMultiplicativeElement ], 0,
    function( x, m )
    local F;
    F:= FamilyObj( x );
    x:= ZippedSum( CoefficientsAndMagmaElements( x ),
                   [ m, One( F!.zeroRing ) ],
                   F!.zeroRing, [ \<, \+ ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F,
            [ F!.zeroRing, x ] );
    return Objectify( F!.defaultType, x );
    end );


#############################################################################
##
#M  \-( <x>, <m> )  . . . . . . . .  for magma ring element and magma element
#M  \-( <m>, <x> )  . . . . . . . .  for magma ring element and magma element
##
InstallOtherMethod( \-,
    "for magma ring element and magma element",
    IsMagmaRingsMagmas,
    [ IsElementOfMagmaRingModuloRelations, IsMultiplicativeElement ], 0,
    function( x, m )
    local F;
    F:= FamilyObj( x );
    return x - ElementOfMagmaRing( F, F!.zeroRing,
                   [ One( F!.zeroRing ) ], [ m ] );
    end );

InstallOtherMethod( \-,
    "for magma ring element and magma element",
    IsMagmasMagmaRings,
    [ IsMultiplicativeElement, IsElementOfMagmaRingModuloRelations ], 0,
    function( m, x )
    local F;
    F:= FamilyObj( x );
    return ElementOfMagmaRing( F, F!.zeroRing,
               [ One( F!.zeroRing ) ], [ m ] ) - x;
    end );


#############################################################################
##
#M  \/( x, r )  . . . . . . . . . . .  for magma ring element and coefficient
##
ElmDivRingElm := function( x, y )
    local F, i;
    F:= FamilyObj( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] / y;
    od;
    return Objectify( F!.defaultType, [ F!.zeroRing, x ] );
end;

InstallOtherMethod( \/,
    "for magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsElementOfMagmaRingModuloRelations, IsRingElement ], 0,
    ElmDivRingElm );

InstallMethod( \/,
    "for magma ring element, and integer",
    true,
    [ IsElementOfMagmaRingModuloRelations, IsInt ], 0,
    ElmDivRingElm );


#############################################################################
##
#M  Inverse( <elm> ) . . . . . . . . . . . .  inverse of a magma ring element
##
InstallOtherMethod( Inverse,
    "for free magma ring element",
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( elm )
    local F;
    F:= FamilyObj( elm );
    elm:= CoefficientsAndMagmaElements( elm );
    if Length( elm ) = 2 then
      return Objectify( F!.defaultType,
                 [ F!.zeroRing, [ Inverse( elm[1] ), Inverse( elm[2] ) ] ] );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  One( <elm> )
##
InstallMethod( One,
    "for magma ring element",
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( elm )
    local F, zerocoeff;
    F:= FamilyObj( elm );
    if not IsBound( F!.oneMagma ) then
      return fail;
    fi;
    zerocoeff:= F!.zeroRing;
    return Objectify( F!.defaultType,
               [ zerocoeff, [ F!.oneMagma, One( zerocoeff ) ] ] );
    end );


#############################################################################
##
#M  Zero( <elm> )
##
InstallMethod( Zero,
    "for magma ring element",
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    x -> Objectify( FamilyObj(x)!.defaultType,
             [ FamilyObj(x)!.zeroRing, [] ] ) );


#############################################################################
##
##  2. methods for free magma rings
##


#############################################################################
##
#M  IsGroupRing( <RM> ) . . . . . . . . . . . . . . . . . for free magma ring
##
InstallMethod( IsGroupRing,
    "for free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM -> IsGroup( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  PrintObj( <MR> )  . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( PrintObj,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    function( MR )
    Print( "FreeMagmaRing( ", LeftActingDomain( MR ), ", ",
                              UnderlyingMagma( MR ), " )" );
    end );


#############################################################################
##
#F  FreeMagmaRing( <R>, <M> )
##
InstallGlobalFunction( FreeMagmaRing, function( R, M )

    local F,     # family of magma ring elements
          one,   # identity of `R'
          zero,  # zero of `R'
          m,     # one element of `M'
          RM,    # free magma ring, result
          gens;  # generators of the magma ring

    # Check the arguments.
    if not IsRing( R ) or One( R ) = fail then
      Error( "<R> must be a ring with identity" );
    fi;

    # Construct the family of elements of our ring.
    if   IsMultiplicativeElementWithInverseCollection( M ) then
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsElementOfFreeMagmaRing,
                     IsMultiplicativeElementWithInverse );
    elif IsMultiplicativeElementWithOneCollection( M ) then
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsElementOfFreeMagmaRing,
                     IsMultiplicativeElementWithOne );
    else
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsElementOfFreeMagmaRing,
                     IsMultiplicativeElement );
    fi;

    one:= One( R );
    zero:= Zero( R );

    F!.defaultType := NewType( F, IsMagmaRingObjDefaultRep );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( M );
    F!.zeroRing    := zero;
#T no !!

    # Set the characteristic.
    if HasCharacteristic( R ) or HasCharacteristic( FamilyObj( R ) ) then
      SetCharacteristic( F, Characteristic( R ) );
    fi;

    m:= Representative( M );
    if IsMultiplicativeElementWithOne( m ) then
      F!.oneMagma:= One( m );
    fi;

    # Make the magma ring object.
    if IsMagmaWithOne( M ) then
      RM:= Objectify( NewType( CollectionsFamily( F ),
                                   IsFreeMagmaRingWithOne
                               and IsAttributeStoringRep ),
                      rec() );
    else
      RM:= Objectify( NewType( CollectionsFamily( F ),
                                   IsFreeMagmaRing
                               and IsAttributeStoringRep ),
                      rec() );
    fi;

    # Set the necessary attributes.
    SetLeftActingDomain( RM, R );
    SetUnderlyingMagma(  RM, M );

    # Deduce useful information.
    if HasIsFinite( M ) then
      SetIsFiniteDimensional( RM, IsFinite( M ) );
    fi;
    if HasIsAssociative( M ) then
      if IsMagmaWithInverses( M ) then
        SetIsGroupRing( RM, IsGroup( M ) );
      fi;
      if HasIsAssociative( R ) then
        SetIsAssociative( RM, IsAssociative( R ) and IsAssociative( M ) );
      fi;
    fi;
    if HasIsCommutative( R ) and HasIsCommutative( M ) then
      SetIsCommutative( RM, IsCommutative( R ) and IsCommutative( M ) );
    fi;
    if HasIsWholeFamily( R ) and HasIsWholeFamily( M ) then
      SetIsWholeFamily( RM, IsWholeFamily( R ) and IsWholeFamily( M ) );
    fi;

    # Construct the generators.
    # To get meaningful generators,
    # we have to handle the case that the magma is trivial.
    if IsMagmaWithOne( M ) then

      gens:= GeneratorsOfMagmaWithOne( M );
      SetGeneratorsOfLeftOperatorRingWithOne( RM,
          List( gens,
                x -> ElementOfMagmaRing( F, zero, [ one ], [ x ] ) ) );
      if IsEmpty( gens ) then
        SetGeneratorsOfLeftOperatorRing( RM,
                [ ElementOfMagmaRing( F, zero, [ one ], [ One( M ) ] ) ] );
      fi;

    else

      SetGeneratorsOfLeftOperatorRing( RM,
          List( GeneratorsOfMagma( M ),
                x -> ElementOfMagmaRing( F, zero, [ one ], [ x ] ) ) );

    fi;

    # Return the ring.
    return RM;
end );


#############################################################################
##
#F  GroupRing( <R>, <G> )
##
InstallGlobalFunction( GroupRing, function( R, G )

    if not IsGroup( G ) then
      Error( "<G> must be a group" );
    fi;
    R:= FreeMagmaRing( R, G );
    SetIsGroupRing( R, true );
    return R;
end );


#############################################################################
##
#M  AugmentationIdeal( <RG> ) . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( AugmentationIdeal,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    function( RG )
    local one, G, gens, I;
    one:= One( RG );
    if one = fail then
      TryNextMethod();
    fi;
    G:= UnderlyingMagma( RG );
    gens:= List( GeneratorsOfMagma( G ), g -> g - one );
    I:= TwoSidedIdealByGenerators( RG, gens );
    SetGeneratorsOfAlgebra( I, gens );
    return I;
    end );


#############################################################################
##
#R  IsCanonicalBasisFreeMagmaRingRep( <B> )
##
DeclareRepresentation( "IsCanonicalBasisFreeMagmaRingRep",
    IsCanonicalBasis and IsAttributeStoringRep,
    [ "zerovector" ] );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . for canon. basis of free magma ring
##
InstallMethod( Coefficients,
    "for canon. basis of a free magma ring, and a vector",
    IsCollsElms,
    [ IsCanonicalBasisFreeMagmaRingRep, IsElementOfFreeMagmaRing ], 0,
    function( B, v )

    local coeffs,
          data,
          elms,
          i;

    data:= CoefficientsAndMagmaElements( v );
    coeffs:= ShallowCopy( B!.zerovector );
    elms:= EnumeratorSorted( UnderlyingMagma( UnderlyingLeftModule( B ) ) );
    for i in [ 1, 3 .. Length( data )-1 ] do
      coeffs[ Position( elms, data[i] ) ]:= data[i+1];
    od;
    return coeffs;
    end );


#############################################################################
##
#M  BasisOfDomain( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( BasisOfDomain,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ],
    10,  # must be higher than default method for (asssoc.) FLMLOR(WithOne)
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <RM> )  . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( CanonicalBasis,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    function( RM )

    local B, one, zero, F;

    F:= ElementsFamily( FamilyObj( RM ) );
    if not IsBound( F!.defaultType ) then
      TryNextMethod();
    fi;

    one  := One(  LeftActingDomain( RM ) );
    zero := Zero( LeftActingDomain( RM ) );

    B:= Objectify( NewType( FamilyObj( RM ),
                                IsBasis
                            and IsCanonicalBasisFreeMagmaRingRep ),
                   rec() );

    SetUnderlyingLeftModule( B, RM );
    if IsFiniteDimensional( RM ) then
      SetBasisVectors( B,
          List( EnumeratorSorted( UnderlyingMagma( RM ) ),
                x -> ElementOfMagmaRing( F, zero, [ one ], [ x ] ) ) );
      B!.zerovector:= List( BasisVectors( B ), x -> zero );
    fi;

    return B;
    end );


#############################################################################
##
#M  IsFinite( <RM> )  . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsFinite,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsFinite( LeftActingDomain( RM ) )
          and IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <RM> ) . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsFiniteDimensional,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM -> IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <R> )  . .  for left module of free magma ring elms.
##
InstallMethod( IsFiniteDimensional,
    "for a left module of free magma ring elements",
    true,
    [ IsFreeLeftModule and IsElementOfFreeMagmaRingCollection
                       and HasGeneratorsOfLeftOperatorRing ], 0,
    function( R )
    local gens;
    gens:= Concatenation( List( GeneratorsOfLeftOperatorRing( R ),
                                CoefficientsAndMagmaElements ) );
    gens:= gens{ [ 1, 3 .. Length( gens ) - 1 ] };
    if IsEmpty( gens ) or IsFinite( Magma( gens ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Dimension( <RM> ) . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( Dimension,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM -> Size( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <RM> )  . . . . . . . . . . for a free magma ring
##
InstallMethod( GeneratorsOfLeftModule,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    function( RM )
    local F, one, zero;
    if IsFiniteDimensional( RM ) then
      F:= ElementsFamily( FamilyObj( RM ) );
      one:= One( LeftActingDomain( RM ) );
      zero:= Zero( LeftActingDomain( RM ) );
      return List( Enumerator( UnderlyingMagma( RM ) ),
                   m -> ElementOfMagmaRing( F, zero, [ one ], [ m ] ) );
    else
      Error( "<RM> is not finite dimensional" );
    fi;
    end );


#############################################################################
##
#M  Centre( <RM> )  . . . . . . . . . . . . . . . . . . . .  for a group ring
##
##  The centre of a group ring $RG$ of a finite group $G$ is the FLMLOR
##  over the centre of $R$ generated by the conjugacy class sums in $G$.
##
##  Note that this ring is clearly contained in the centre of $RG$.
##  On the other hand, if an element $x = \sum_{g \in G} r_g g$ lies in the
##  centre of $RG$ then $( r h ) \cdot x = x \cdot ( r h )$ for each
##  $r \in R$ and $h \in G$.
##  This means that
##  $\sum_{g \in G} (r r_g ) ( h g ) = \sum_{g \in G} (r_g r ) ( g h )$,
##  which means that for $k = h g_1 = g_2 h$, the coefficients on both sides,
##  which are $r r_{g_1} = r r_{h^{-1} k}$ and $r_{g_2} r = r_{k h^{-1}} r$,
##  must be equal.
##  Setting $r = 1$ forces $r_g$ to be constant on conjugacy classes of $G$,
##  and leaving $r$ arbitrary forces the coefficients to lie in the centre
##  of $R$.
##
InstallMethod( Centre,
    "for a group ring",
    true,
    [ IsGroupRing ], 0,
    function( RG )

    local F,      # family of elements of `RG'
          one,    # identity of the coefficients ring
          zero,   # zero of the coefficients ring
          gens,   # list of (module) generators of the result
          c,      # loop over `ccl'
          elms,   # set of elements of a conjugacy class
          coeff;  # coefficients vector

    if not IsFiniteDimensional( RG ) then
      TryNextMethod();
    fi;
    F:= ElementsFamily( FamilyObj( RG ) );
    one:= One( LeftActingDomain( RG ) );
    zero:= Zero( LeftActingDomain( RG ) );
    gens:= [];
    for c in ConjugacyClasses( UnderlyingMagma( RG ) ) do
      elms:= EnumeratorSorted( c );
      coeff:= List( elms, x -> one );
      Add( gens, ElementOfMagmaRing( F, zero, coeff, elms ) );
    od;
    return FLMLOR( Centre( LeftActingDomain( RG ) ), gens, "basis" );
    end );


#############################################################################
##
#M  \in( <r>, <RM> )  . . . . . . . . .  for ring element and free magma ring
##
InstallMethod( \in,
    "for ring element, and magma ring",
    IsElmsColls,
    [ IsElementOfMagmaRingModuloRelations, IsMagmaRingModuloRelations ], 0,
    function( r, RM )
    r:= CoefficientsAndMagmaElements( r );
    if (    ForAll( [ 2, 4 .. Length( r ) ],
                    i -> r[i] in LeftActingDomain( RM ) )
        and ForAll( [ 1, 3 .. Length( r ) - 1 ],
                    i -> r[i] in UnderlyingMagma( RM ) ) ) then
      return true;
    elif IsFreeMagmaRing( RM ) then
      return false;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Enumerator( <RM> )  . . . . . . .  for a free magma ring with finite ring
##
##  Let <RM> be a free magma ring over a finite left acting domain $R$
##  of order $q$, say.
##
##  If $m_i$ is the $i$-th element in a fixed enumerator of the underlying
##  magma then the element $\sum_{i=1}^k r_i m_i$ is at position
##  $1 + \sum_{i=1}^k p_i q^{i-1}$, where $p_i+1$ is the position of the ring
##  element $r_i$ in a fixed enumerator of $R$.
##  Especially, the first element in the enumerator of <RM> is the zero
##  element of <RM>.
##
DeclareRepresentation( "IsFreeMagmaRingEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "family", "zerocoeff", "ringenum", "magmaenum", "zero" ] );

InstallMethod( \[\],
    "for enumerator of a free magma ring",
    true,
    [ IsFreeMagmaRingEnumerator, IsPosInt ], 0,
    function( enum, nr )

    local elm,  # element, result
          i;    # loop over q-adic expansion

    nr:= CoefficientsQadic( nr-1, Length( enum!.ringenum ) );
    if Length( enum!.magmaenum ) < Length( nr ) then
      Error( "too large number" );
    fi;
    elm:= enum!.zero;
    for i in [ 1 .. Length( nr ) ] do
      elm:= elm + ElementOfMagmaRing( enum!.family, enum!.zerocoeff,
                                          [ enum!.ringenum[ nr[i]+1 ] ],
                                          [ enum!.magmaenum[i] ] );
    od;
    return elm;
    end );

InstallMethod( Position,
    "for enumerator of a free magma ring",
    IsCollsElmsX,
    [ IsFreeMagmaRingEnumerator, IsElementOfFreeMagmaRing, IsZeroCyc ], 0,
    function( enum, elm, zero )

    local pos,    # position, result
          q,      # cardinality of the ring
          rpos,   # position in ring enumerator
          mpos,   # position in magma enumerator
          i;      # loop over the expression of `elm'

    elm:= CoefficientsAndMagmaElements( elm );
    pos:= 1;
    q:= Length( enum!.ringenum );
    for i in [ 2, 4 .. Length( elm ) ] do
      rpos:= Position( enum!.ringenum, elm[i], 0 );
      if rpos = fail then
        return fail;
      fi;
      mpos:= Position( enum!.magmaenum, elm[ i-1 ], 0 );
      if mpos = fail then
        return fail;
      fi;
      pos:= pos + ( rpos - 1 ) * q ^ ( mpos - 1 );
    od;
    return pos;
    end );


InstallMethod( Enumerator,
    "for enumerator of a free magma ring with finite ring",
    true,
    [ IsFreeMagmaRing ], 0,
    function( RM )
    local R, enum;

    R:= LeftActingDomain( RM );
    if not IsFinite( LeftActingDomain( RM ) ) then
      TryNextMethod();
    fi;

    enum:= Objectify( NewType( FamilyObj( RM ),
                               IsFreeMagmaRingEnumerator ),
                    rec( family    := ElementsFamily( FamilyObj( RM ) ),
                         zerocoeff := Zero( R ),
                         ringenum  := Enumerator( R ),
                         magmaenum := Enumerator( UnderlyingMagma( RM ) ),
                         zero      := Zero( RM ) )
                     );
    SetUnderlyingCollection( enum, RM );
    return enum;
    end );


#############################################################################
##
#M  IsAssociative( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsAssociative,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsAssociative( LeftActingDomain( RM ) )
          and IsAssociative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsCommutative( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsCommutative,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsCommutative( LeftActingDomain( RM ) )
          and IsCommutative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsWholeFamily( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsWholeFamily,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsWholeFamily( LeftActingDomain( RM ) )
          and IsWholeFamily( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  GeneratorsOfRing( <RM> )  . . . . . . . . . . . . . for a free magma ring
#M  GeneratorsOfRingWithOne( <RM> ) . . . . .  for a free magma ring-with-one
##
##  If the underlying magma has an identity and if we know ring generators
##  for the ring <R>, we take the left operator ring generators together
##  with the images of the ring generators under the natural embedding.
##
InstallMethod( GeneratorsOfRing,
    "for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    function( RM )
    local R, emb;
    R:= LeftActingDomain( RM );
    emb:= Embedding( R, RM );
    if emb = fail then
      TryNextMethod();
    else
      return Concatenation( GeneratorsOfLeftOperatorRing( RM ),
                            List( GeneratorsOfRing( R ),
                                  r -> ImageElm( emb, r ) ) );
    fi;
    end );

InstallMethod( GeneratorsOfRingWithOne,
    "for a free magma ring-with-one",
    true,
    [ IsFreeMagmaRingWithOne ], 0,
    function( RM )
    local R, emb;
    R:= LeftActingDomain( RM );
    emb:= Embedding( R, RM );
    if emb = fail then
      TryNextMethod();
    else
      return Concatenation( GeneratorsOfLeftOperatorRingWithOne( RM ),
                            List( GeneratorsOfRingWithOne( R ),
                                  r -> ImageElm( emb, r ) ) );
    fi;
    end );


#############################################################################
##
#R  IsEmbeddingRingMagmaRing( <R>, <RM> )
##
DeclareRepresentation( "IsEmbeddingRingMagmaRing",
        IsNonSPGeneralMapping
    and IsMapping
    and IsInjective
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#R  IsEmbeddingMagmaMagmaRing( <M>, <RM> )
##
DeclareRepresentation( "IsEmbeddingMagmaMagmaRing",
        IsNonSPGeneralMapping
    and IsMapping
    and IsInjective
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#M  Embedding( <R>, <RM> )  . . . . . . . . . . . . . for ring and magma ring
##
InstallMethod( Embedding,
    "for ring and magma ring",
    IsRingCollsMagmaRingColls,
    [ IsRing, IsFreeMagmaRing ], 0,
    function( R, RM )

    local   emb;

    # Check that this is the right method.
    if Parent( R ) <> LeftActingDomain( RM ) then
      TryNextMethod();
    elif One( UnderlyingMagma( RM ) ) = fail then
      return fail;
    fi;

    # Make the mapping object.
    emb := Objectify( TypeOfDefaultGeneralMapping( R, RM,
                               IsEmbeddingRingMagmaRing ),
                      rec() );

    # Return the embedding.
    return emb;
    end );

InstallMethod( ImagesElm,
    "for embedding of ring into magma ring, and ring element",
    FamSourceEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsRingElement ], 0,
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return [ ElementOfMagmaRing( F, Zero( elm ), [ elm ],
                 [ One( UnderlyingMagma( Range( emb ) ) ) ] ) ];
    end );


InstallMethod( PreImagesElm,
    "for embedding of ring into magma ring, and free magma ring element",
    FamRangeEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsElementOfFreeMagmaRing ], 0,
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= CoefficientsAndMagmaElements( elm );
    if     Length( extrep ) = 2
       and extrep[1] = One( UnderlyingMagma( R ) ) then
      return [ extrep[2] ];
    else
      return [];
    fi;
    end );


#############################################################################
##
#F  Embedding( <M>, <RM> )  . . . . . . . . . . . .  for magma and magma ring
##
InstallMethod( Embedding,
    "for magma and magma ring",
    IsMagmaCollsMagmaRingColls,
    [ IsMagma, IsFreeMagmaRing ], 0,
    function( M, RM )

    local   emb;

    # Check that this is the right method.
    if not IsSubset( UnderlyingMagma( RM ), M ) then
      TryNextMethod();
    fi;

    # Make the mapping object.
    emb := Objectify( TypeOfDefaultGeneralMapping( M, RM,
                               IsEmbeddingMagmaMagmaRing ),
                      rec() );

    # Return the embedding.
    return emb;
    end );

InstallMethod( ImagesElm,
    "for embedding of magma into magma ring, and mult. element",
    FamSourceEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsMultiplicativeElement ], 0,
    function ( emb, elm )
    local R, F;
    R:= Range( emb );
    F:= ElementsFamily( FamilyObj( R ) );
    return [ ElementOfMagmaRing( F, Zero( LeftActingDomain( R ) ),
                 [ One( LeftActingDomain( R ) ) ], [ elm ] ) ];
    end );


InstallMethod( PreImagesElm,
    "for embedding of magma into magma ring, and free magma ring element",
    FamRangeEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsElementOfFreeMagmaRing ], 0,
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= CoefficientsAndMagmaElements( elm );
    if     Length( extrep ) = 2
       and extrep[2] = One( LeftActingDomain( R ) ) then
      return [ extrep[1] ];
    else
      return [];
    fi;
    end );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . . .  for magma ring element
##
##  The external representation of elements in a free magma ring is defined
##  as a list of length 2, the first entry being the zero coefficient,
##  the second being a zipped list containing the external representations
##  of the monomials and their coefficients.
##
InstallMethod( ExtRepOfObj,
    "for magma ring element",
#T eventually more specific!
#T allow this only if the magma elements have an external representation!
#T (make this explicit!)
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( elm )
    local zero, i;
    zero:= FamilyObj( elm )!.zeroRing;
    elm:= ShallowCopy( CoefficientsAndMagmaElements( elm ) );
    for i in [ 1, 3 .. Length( elm ) - 1 ] do
      elm[i]:= ExtRepOfObj( elm[i] );
    od;
    return [ zero, elm ];
    end );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> ) . . . . for free magma ring elements family
##
##  This is well-defined only if the magma elements of the free magma ring
##  have an external representation.
##
##  We need this mainly for free and f.p. algebras.
##
##  Note that <descr> must describe a *normalized* element (sorted w.r.t. the
##  magma elements, normalized w.r.t. the relations if there are some).
##
InstallMethod( ObjByExtRep,
    "for magma ring elements family, and list",
    true,
    [ IsElementOfMagmaRingModuloRelationsFamily, IsList ], 0,
    function( Fam, descr )
    local FM, elm, i;
    FM:= ElementsFamily( Fam!.familyMagma );
    elm:= ShallowCopy( descr[2] );
    for i in [ 1, 3 .. Length( elm ) - 1 ] do
      elm[i]:= ObjByExtRep( FM, elm[i] );
    od;
    return Objectify( Fam!.defaultType, [ descr[1], elm ] );
    end );


#############################################################################
##
##  3. methods for free left modules of free magma ring elements
##
##  Free left modules of elements in a free magma ring are handled as
##  follows.
##  Let $V$ be an $R$-module of elements in a free magma ring $RM$,
##  and let $S$ be the set of magma elements that occur in the generators of
##  $V$.
##  Then the row vector of coefficients w.r.t. $S$ is the nice vector of an
##  element in $V$.
##
##  The computation of $S$ is done by `PrepareNiceFreeLeftModule'.
##

#############################################################################
##
#R  IsSpaceOfElementsOfFreeMagmaRingRep( <V> )
##
##  is the representation of free left modules of free magma ring elements
##  that are handled via nice bases.
##
##  `family' :
##     elements family of <V>
##
##  `monomials' :
##     the list of magma elements that occur in elements of <V>.
##
##  `zerocoeff' :
##     zero coefficient of elements in <V>
##
##  `zerovector' :
##     zero row vector in the nice left module
##
DeclareRepresentation( "IsSpaceOfElementsOfFreeMagmaRingRep",
    IsHandledByNiceBasis and IsAttributeStoringRep,
    [ "family", "monomials", "zerocoeff", "zerovector" ] );


#############################################################################
##
#M  PrepareNiceFreeLeftModule( <V> )
##
InstallMethod( PrepareNiceFreeLeftModule,
    "for free left module of free magma ring elements",
    true,
    [ IsFreeLeftModule and IsSpaceOfElementsOfFreeMagmaRingRep ], 0,
    function( V )

    local gens,
          monomials,
          gen,
          list,
          i,
          zero;

    gens:= GeneratorsOfLeftModule( V );
    monomials:= [];

    for gen in gens do
      list:= CoefficientsAndMagmaElements( gen );
      for i in [ 1, 3 .. Length( list ) - 1 ] do
        AddSet( monomials, list[i] );
      od;
    od;

    V!.monomials:= monomials;

    zero:= Zero( V )![1];
    V!.zerocoeff  := zero;
    V!.zerovector := List( monomials, x -> zero );
    V!.family     := ElementsFamily( FamilyObj( V ) );
    end );


#############################################################################
##
#M  NiceVector( <V>, <v> )
##
##  is the row vector in `NiceFreeLeftModule( <V> )' that corresponds
##  to the vector <v> of <V>.
##
InstallMethod( NiceVector,
    "for free left module of free magma ring elements, and element",
    IsCollsElms,
    [ IsFreeLeftModule and IsSpaceOfElementsOfFreeMagmaRingRep,
      IsElementOfFreeMagmaRing ],
    0,
    function( V, v )
    local c, monomials, i, pos;
    c:= ShallowCopy( V!.zerovector );
    v:= CoefficientsAndMagmaElements( v );
    monomials:= V!.monomials;
    for i in [ 2, 4 .. Length( v ) ] do
      pos:= Position( monomials, v[ i-1 ] );
      if pos = fail then return fail; fi;
      c[ pos ]:= v[i];
    od;
    return c;
    end );


#############################################################################
##
#M  UglyVector( <V>, <r> )
##
##  returns the vector in <V> that corresponds to the vector <r> in
##  `NiceFreeLeftModule( <V> )'.
##
InstallMethod( UglyVector,
    "for left module of free magma ring elements, and row vector",
    true,
    [ IsFreeLeftModule and IsSpaceOfElementsOfFreeMagmaRingRep,
      IsRowVector ], 0,
    function( V, r )
    if Length( r ) <> Length( V!.zerovector ) then
      return fail;
    fi;
    return ElementOfMagmaRing( V!.family, V!.zerocoeff,
               r, V!.monomials );
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <gens> )
##
InstallMethod( LeftModuleByGenerators,
    "for ring and collection of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection ], 0,
    function( F, gens )
    local V;
    V:= Objectify( NewType( FamilyObj( gens ),
                                IsFreeLeftModule
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( gens ) );
    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <gens>, <zero> )
##
InstallOtherMethod( LeftModuleByGenerators,
    "for ring and collection of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection, IsElementOfFreeMagmaRing ],
    0,
    function( F, gens, zero )
    local V;
    V:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsFreeLeftModule
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( gens ) );
    SetZero( V, zero );
    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <empty>, <zero> )
##
InstallOtherMethod( LeftModuleByGenerators,
    "for ring, empty list, and free magma ring element",
    true,
    [ IsRing, IsList and IsEmpty, IsElementOfFreeMagmaRing ], 0,
    function( F, empty, zero )
    local V;
    V:= Objectify( NewType( FamilyObj( F ),
                                IsFreeLeftModule
                            and IsTrivial
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( empty ) );
    SetZero( V, zero );
    return V;
    end );


#############################################################################
##
#M  FLMLORByGenerators( <R>, <elms> )
#M  FLMLORByGenerators( <R>, <empty>, <zero> )
#M  FLMLORByGenerators( <R>, <elms>, <zero> )
##
InstallMethod( FLMLORByGenerators,
    "for ring and list of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection and IsList ], 0,
    function( R, elms )
    local A;

    A:= Objectify( NewType( FamilyObj( elms ),
                                IsFLMLOR
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftOperatorRing( A, AsList( elms ) );

    # Return the result.
    return A;
    end );

InstallOtherMethod( FLMLORByGenerators,
    "for ring, empty list, and free magma ring element",
    true,
    [ IsRing, IsList and IsEmpty, IsElementOfFreeMagmaRing ], 0,
    function( R, empty, zero )
    local A;

    A:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsFLMLOR
                            and IsSpaceOfElementsOfFreeMagmaRingRep
                            and IsTrivial ),
                   rec() );
    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftModule( A, empty );
    SetZero( A, zero );

    # Return the result.
    return A;
    end );

InstallOtherMethod( FLMLORByGenerators,
    "for ring, list of free magma ring elements, and zero",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection and IsList,
      IsElementOfFreeMagmaRing ], 0,
    function( F, elms, zero )
    local A;

    A:= Objectify( NewType( FamilyObj( elms ),
                                IsFLMLOR
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( A, F );
    SetGeneratorsOfLeftOperatorRing( A, AsList( elms ) );
    SetZero( A, zero );

    # Return the result.
    return A;
    end );


#############################################################################
##
#M  FLMLORWithOneByGenerators( <R>, <elms> )
#M  FLMLORWithOneByGenerators( <R>, <empty>, <zero> )
#M  FLMLORWithOneByGenerators( <R>, <elms>, <zero> )
##
InstallMethod( FLMLORWithOneByGenerators,
    "for ring and list of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection and IsList ], 0,
    function( R, elms )
    local A;

    A:= Objectify( NewType( FamilyObj( elms ),
                                IsFLMLORWithOne
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                   rec() );

    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftOperatorRingWithOne( A, AsList( elms ) );

    # Return the result.
    return A;
    end );

InstallOtherMethod( FLMLORWithOneByGenerators,
    "for ring, empty list, and free magma ring element",
    true,
    [ IsRing, IsList and IsEmpty, IsElementOfFreeMagmaRing ], 0,
    function( R, empty, zero )
    local A;

    A:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsFLMLORWithOne
                            and IsSpaceOfElementsOfFreeMagmaRingRep
                            and IsAssociative ),
                   rec() );
    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftOperatorRingWithOne( A, empty );
    SetZero( A, zero );

    # Return the result.
    return A;
    end );

InstallOtherMethod( FLMLORWithOneByGenerators,
    "for ring, list of free magma ring elements, and zero",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection and IsList,
      IsElementOfFreeMagmaRing ], 0,
    function( R, elms, zero )
    local A;

    A:= Objectify( NewType( FamilyObj( elms ),
                                IsFLMLORWithOne
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                   rec() );

    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftOperatorRingWithOne( A, AsList( elms ) );
    SetZero( A, zero );

    # Return the result.
    return A;
    end );


#############################################################################
##
#M  TwoSidedIdealByGenerators( <A>, <elms> )
#M  LeftIdealByGenerators( <A>, <elms> )
#M  RightIdealByGenerators( <A>, <elms> )
##
InstallMethod( TwoSidedIdealByGenerators,
    "for free magma ring, and list of free magma ring elements",
    IsIdenticalObj,
    [ IsFreeMagmaRing, IsElementOfFreeMagmaRingCollection and IsList ], 0,
    function( A, elms )
    local I;

    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( I, LeftActingDomain( A ) );
    SetGeneratorsOfTwoSidedIdeal( I, elms );
    SetLeftActingRingOfIdeal( I, A );
    SetRightActingRingOfIdeal( I, A );

    # Return the result.
    return I;
    end );

InstallMethod( LeftIdealByGenerators,
    "for free magma ring, and list of free magma ring elements",
    IsIdenticalObj,
    [ IsFreeMagmaRing, IsElementOfFreeMagmaRingCollection and IsList ], 0,
    function( A, elms )
    local I;

    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( I, LeftActingDomain( A ) );
    SetGeneratorsOfLeftIdeal( I, elms );
    SetLeftActingRingOfIdeal( I, A );

    # Return the result.
    return I;
    end );

InstallMethod( RightIdealByGenerators,
    "for free magma ring, and list of free magma ring elements",
    IsIdenticalObj,
    [ IsFreeMagmaRing, IsElementOfFreeMagmaRingCollection and IsList ], 0,
    function( A, elms )
    local I;

    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( I, LeftActingDomain( A ) );
    SetGeneratorsOfRightIdeal( I, elms );
    SetRightActingRingOfIdeal( I, A );

    # Return the result.
    return I;
    end );

InstallMethod( TwoSidedIdealByGenerators,
    "for free magma ring, and empty list",
    true,
    [ IsFreeMagmaRing, IsList and IsEmpty ], 0,
    function( A, elms )
    local I;

    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsTrivial
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( I, LeftActingDomain( A ) );
    SetGeneratorsOfTwoSidedIdeal( I, elms );
    SetGeneratorsOfLeftOperatorRing( I, elms );
    SetGeneratorsOfLeftModule( I, elms );
    SetLeftActingRingOfIdeal( I, A );
    SetRightActingRingOfIdeal( I, A );

    # Return the result.
    return I;
    end );

InstallMethod( LeftIdealByGenerators,
    "for free magma ring, and empty list",
    true,
    [ IsFreeMagmaRing, IsList and IsEmpty ], 0,
    function( A, elms )
    local I;

    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsTrivial
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( I, LeftActingDomain( A ) );
    SetGeneratorsOfLeftIdeal( I, elms );
    SetGeneratorsOfLeftOperatorRing( I, elms );
    SetGeneratorsOfLeftModule( I, elms );
    SetLeftActingRingOfIdeal( I, A );

    # Return the result.
    return I;
    end );

InstallMethod( RightIdealByGenerators,
    "for free magma ring, and empty list",
    true,
    [ IsFreeMagmaRing, IsList and IsEmpty ], 0,
    function( A, elms )
    local I;

    I:= Objectify( NewType( FamilyObj( A ),
                                IsFLMLOR
                            and IsTrivial
                            and IsSpaceOfElementsOfFreeMagmaRingRep ),
                     rec() );

    SetLeftActingDomain( I, LeftActingDomain( A ) );
    SetGeneratorsOfRightIdeal( I, elms );
    SetGeneratorsOfLeftOperatorRing( I, elms );
    SetGeneratorsOfLeftModule( I, elms );
    SetRightActingRingOfIdeal( I, A );

    # Return the result.
    return I;
    end );


#############################################################################
##
#E  mgmring.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

