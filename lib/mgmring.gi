#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for magma rings and their elements.
##
##  1. methods for elements of magma rings in default representation
##  2. methods for free magma rings
##  3. methods for free left modules in magma ring modulo relations
##  4. methods for free magma rings modulo the span of a ``zero'' element
##  5. methods for groups of free magma ring elements
##


#T > Dear Craig,
#T >
#T > you asked for the implementation of magma rings modulo the identification
#T > of a ``zero element'' in the magma with zero.
#T >
#T > Here is my proposal for the basic stuff.
#T > (I have mainly taken the implementation of free magma rings plus the
#T > ideas used for `FreeLieAlgebra'.)
#T > It does not cover the vector space functionality (computing bases etc.),
#T > but I will rearrange the code in `mgmring.gd' and `mgmring.gi' in such a way
#T > that your generalized magma rings can use the mechanisms provided there.


#T get rid of `!.zeroRing'
#T (provide uniform access to the zero coeff. stored in the element;
#T this is also possible for polynomials etc.)


#T get rid of !.defaultType
#T get rid of !.oneMagma

#T best get rid of the families distinction for magma rings ?
#T (would solve problems such as relation between GroupRing( Integers, G )
#T and GroupRing( Rationals, G ))


#############################################################################
##
##  1. methods for elements of magma rings in default representation
##

#############################################################################
##
#R  IsMagmaRingObjDefaultRep( <obj> )
##
##  <#GAPDoc Label="IsMagmaRingObjDefaultRep">
##  <ManSection>
##  <Filt Name="IsMagmaRingObjDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  The default representation of a magma ring element is a list of length 2,
##  at first position the zero coefficient, at second position a list with
##  the coefficients at the even positions, and the magma elements at the
##  odd positions, with the ordering as defined for the magma elements.
##  <P/>
##  It is assumed that arithmetic operations on magma rings produce only
##  normalized elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
if IsHPCGAP then
DeclareRepresentation( "IsMagmaRingObjDefaultRep", IsAtomicPositionalObjectRep,
    [ 1, 2 ] );
else
DeclareRepresentation( "IsMagmaRingObjDefaultRep", IsPositionalObjectRep,
    [ 1, 2 ] );
fi;

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
    [ IsElementOfFreeMagmaRingFamily, IsList ],
    function( Fam, descr )
    return Immutable(descr);
    end );


#############################################################################
##
#F  FMRRemoveZero( <coeffs_and_words>, <zero> )
##
##  removes all pairs from <coeffs_and_words> where the coefficient
##  is <zero>.
##  Note that <coeffs_and_words> is assumed to be sorted.
##
BindGlobal( "FMRRemoveZero", function( coeffs_and_words, zero )

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
end );


#############################################################################
##
#M  ElementOfMagmaRing( <Fam>, <zerocoeff>, <coeff>, <words> )
##
##  check whether <coeff> and <words> lie in the correct domains,
##  and remove zeroes.
##
InstallMethod( ElementOfMagmaRing,
    "for family, ring element, and two homogeneous lists",
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ],
    function( Fam, zerocoeff, coeff, words )
    local rep, i, j;

    # Check that the data is admissible.
    if not IsBound( Fam!.defaultType ) then
      TryNextMethod();
    elif IsEmpty( coeff ) and IsEmpty( words ) then
      return Objectify( Fam!.defaultType, [ zerocoeff, [] ] );
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
#M  ZeroCoefficient( <elm> )
##
InstallMethod( ZeroCoefficient,
    "for magma ring element in default repr.",
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ],
    elm -> FamilyObj( elm )!.zeroRing );


#############################################################################
##
#M  CoefficientsAndMagmaElements( <elm> )
##
InstallMethod( CoefficientsAndMagmaElements,
    "for magma ring element in default repr.",
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ],
    elm -> elm![2] );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . . for magma ring element in default repr.
##
InstallMethod( PrintObj,
    "for magma ring element",
    [ IsElementOfMagmaRingModuloRelations ],
    function( elm )

    local coeffs_and_words,
          i;

    coeffs_and_words:= CoefficientsAndMagmaElements( elm );
    for i in [ 1, 3 .. Length( coeffs_and_words ) - 3 ] do
      Print( "(", coeffs_and_words[i+1], ")*", coeffs_and_words[i], "+" );
    od;
    i:= Length( coeffs_and_words );
    if i = 0 then
      Print( "<zero> of ..." );
    else
      Print( "(", coeffs_and_words[i], ")*", coeffs_and_words[i-1] );
    fi;
    end );

#############################################################################
##
#M  String( <elm> ) . . . . . . . . for magma ring element in default repr.
##
InstallMethod( String,
    "for magma ring element",
    [ IsElementOfMagmaRingModuloRelations ],
function( elm )
local coeffs_and_words,s,i;

  s:="";
  coeffs_and_words:= CoefficientsAndMagmaElements( elm );
  for i in [ 1, 3 .. Length( coeffs_and_words ) - 3 ] do
    Append(s,Concatenation("(",String(coeffs_and_words[i+1]), ")*", String(coeffs_and_words[i]),
    "+" ));
  od;
  i:= Length( coeffs_and_words );
  if i = 0 then
    Append(s, "<zero> of ..." );
  else
    Append(s, Concatenation("(", String(coeffs_and_words[i]), ")*",
    String(coeffs_and_words[i-1]) ));
  fi;
  return s;
end );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . for two free magma ring elements in default repr.
##
InstallMethod( \=,
    "for two free magma ring elements",
    IsIdenticalObj,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ],
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
      IsElementOfMagmaRingModuloRelations ],
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
    return Length( x ) < Length( y );
    end );


#############################################################################
##
#M  \+( <x>, <y> )  . . . . . .  for two magma ring elements in default repr.
##
InstallMethod( \+,
    "for two magma ring elements",
    IsIdenticalObj,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ],
    function( x, y )
    local F, sum, z;
    F := FamilyObj( x );
    z := ZeroCoefficient( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );
    sum:= ZippedSum( x, y, z, [ \<, \+ ] );
    sum:= NormalizedElementOfMagmaRingModuloRelations( F, [ z, sum ] );
    return Objectify( F!.defaultType, sum );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <x> )  . . . . for magma ring element in default repr.
##
InstallMethod( AdditiveInverseOp,
    "for magma ring element",
    [ IsElementOfMagmaRingModuloRelations ],
    function( x )
    local ext, i, Fam, inv;
    ext:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length( ext ) ] do
      ext[i]:= AdditiveInverse( ext[i] );
    od;
    Fam:= FamilyObj( x );
    inv:= NormalizedElementOfMagmaRingModuloRelations( Fam,
              [ ZeroCoefficient( x ), ext ] );
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
      IsElementOfMagmaRingModuloRelations ],
    function( x, y )
    local F, prod, z;
    F := FamilyObj( x );
    z := ZeroCoefficient( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );
    prod:= ZippedProduct( x, y, z, [ \*, \<, \+, \* ] );
    prod:= NormalizedElementOfMagmaRingModuloRelations( F, [ z, prod ] );
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
BindGlobal( "ElmTimesRingElm", function( x, y )
    local F, i, prod, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] * y;
    od;
    prod:= NormalizedElementOfMagmaRingModuloRelations( F,
               [ z, FMRRemoveZero( x, z ) ] );
    return Objectify( F!.defaultType, prod );
end );

InstallMethod( \*,
    "for magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsElementOfMagmaRingModuloRelations, IsRingElement ],
    ElmTimesRingElm );

InstallMethod( \*,
    "for magma ring element, and rational",
    [ IsElementOfMagmaRingModuloRelations, IsRat ],
    ElmTimesRingElm );


#############################################################################
##
#M  \*( <r>, <x> )  . . . . . . . . .  for coefficient and magma ring element
#M  \*( <r>, <x> )  . . . . . . . . . . .  for integer and magma ring element
##
BindGlobal( "RingElmTimesElm", function( x, y )
    local F, i, prod, z;
    F:= FamilyObj( y );
    z:= ZeroCoefficient( y );
    y:= ShallowCopy( CoefficientsAndMagmaElements( y ) );
    for i in [ 2, 4 .. Length(y) ] do
      y[i]:= x * y[i];
    od;
    prod:= NormalizedElementOfMagmaRingModuloRelations( F,
               [ z, FMRRemoveZero( y, z ) ] );
    return Objectify( F!.defaultType, prod );
end );

InstallMethod( \*,
    "for ring element, and magma ring element",
    IsRingsMagmaRings,
    [ IsRingElement, IsElementOfMagmaRingModuloRelations ],
    RingElmTimesElm );

InstallMethod( \*,
    "for rational, and magma ring element",
    [ IsRat, IsElementOfMagmaRingModuloRelations ],
    RingElmTimesElm );


#############################################################################
##
#M  InverseOp( <x> )  . . . . . . . . for magma ring element in default repr.
##
InstallOtherMethod( InverseOp,
    "for magma ring element",
    [ IsElementOfMagmaRingModuloRelations ],
    function( x )
    local coeffs, inv1, inv2, one, R, B, T;

    coeffs:= CoefficientsAndMagmaElements( x );

    if IsEmpty( coeffs ) then
      # The zero element is not invertible.
      return fail;
    elif Length( coeffs ) = 2 then
      # Inverting a scalar multiple of a magma element
      # means to invert the scalar and the magma element.
      inv1:= Inverse( coeffs[1] );
      if inv1 = fail then
        return fail;
      fi;
      inv2:= Inverse( coeffs[2] );
      if inv2 = fail then
        return fail;
      fi;
      return Objectify( FamilyObj( x )!.defaultType,
                        [ ZeroCoefficient( x ), [ inv1, inv2 ] ] );
    fi;

    # An invertible element has an identity.
    one:= One( x );
    if one = fail then
      return fail;
    fi;

    # Get the necessary coefficient ring,
    # and a basis for the algebra spanned by `x'.
    coeffs:= coeffs{ [ 2, 4 .. Length( coeffs ) ] };
    if IsCyclotomicCollection( coeffs ) then
      R:= DefaultField( coeffs );
    else
      R:= DefaultRing( coeffs );
    fi;
    B:= Basis( FLMLORByGenerators( R, [ x ] ) );
    T:= StructureConstantsTable( B );

    # If `one' is not in the algebra spanned by `x' then there is no inverse.
    coeffs:= Coefficients( B, one );
    if coeffs = fail then
      return fail;
    fi;

    # Solve the equation system.
    one:= QuotientFromSCTable( T, coeffs, Coefficients( B, x ) );

    # If there is a solution then form the inverse.
    if one <> fail then
      one:= LinearCombination( B, one );
    fi;
    return one;
    end );


#############################################################################
##
#M  \* <m>, <x> )  . . . . . . . .  for magma element and magma ring element
#M  \*( <x>, <m> )  . . . . . . . .  for magma ring element and magma element
##
InstallMethod( \*,
    "for magma element and magma ring element",
    IsMagmasMagmaRings,
    [ IsMultiplicativeElement, IsElementOfMagmaRingModuloRelations ],
    function( m, x )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ZippedProduct( [ m, One( z ) ],
                       CoefficientsAndMagmaElements( x ),
                       z,
                       [ \*, \<, \+, \* ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F, [ z, x ] );
    return Objectify( F!.defaultType, x );
    end );

InstallMethod( \*,
    "for magma ring element and magma element",
    IsMagmaRingsMagmas,
    [ IsElementOfMagmaRingModuloRelations, IsMultiplicativeElement ],
    function( x, m )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ZippedProduct( CoefficientsAndMagmaElements( x ),
                       [ m, One( z ) ],
                       z,
                       [ \*, \<, \+, \* ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F,
            [ z, x ] );
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
    [ IsMultiplicativeElement, IsElementOfMagmaRingModuloRelations ],
    function( m, x )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ZippedSum( [ m, One( z ) ],
                   CoefficientsAndMagmaElements( x ),
                   z, [ \<, \+ ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F, [ z, x ] );
    return Objectify( F!.defaultType, x );
    end );

InstallOtherMethod( \+,
    "for magma ring element and magma element",
    IsMagmaRingsMagmas,
    [ IsElementOfMagmaRingModuloRelations, IsMultiplicativeElement ],
    function( x, m )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ZippedSum( CoefficientsAndMagmaElements( x ),
                   [ m, One( z ) ],
                   z, [ \<, \+ ] );
    x:= NormalizedElementOfMagmaRingModuloRelations( F, [ z, x ] );
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
    [ IsElementOfMagmaRingModuloRelations, IsMultiplicativeElement ],
    function( x, m )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    return x - ElementOfMagmaRing( F, z, [ One( z ) ], [ m ] );
    end );

InstallOtherMethod( \-,
    "for magma ring element and magma element",
    IsMagmasMagmaRings,
    [ IsMultiplicativeElement, IsElementOfMagmaRingModuloRelations ],
    function( m, x )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    return ElementOfMagmaRing( F, z, [ One( z ) ], [ m ] ) - x;
    end );


#############################################################################
##
#M  \/( x, r )  . . . . . . . . . . .  for magma ring element and coefficient
##
BindGlobal( "ElmDivRingElm", function( x, y )
    local F, i, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] / y;
    od;
    return Objectify( F!.defaultType, [ z, x ] );
end );

InstallOtherMethod( \/,
    "for magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsElementOfMagmaRingModuloRelations, IsRingElement ],
    ElmDivRingElm );

InstallMethod( \/,
    "for magma ring element, and integer",
    [ IsElementOfMagmaRingModuloRelations, IsInt ],
    ElmDivRingElm );


#############################################################################
##
#M  OneOp( <elm> )
##
InstallMethod( OneOp,
    "for magma ring element",
    [ IsElementOfMagmaRingModuloRelations ],
    function( elm )
    local F, z;
    F:= FamilyObj( elm );
    if not IsBound( F!.oneMagma ) then
      return fail;
    fi;
    z:= ZeroCoefficient( elm );
    return Objectify( F!.defaultType, [ z, MakeImmutable([ F!.oneMagma, One( z ) ]) ] );
    end );


#############################################################################
##
#M  ZeroOp( <elm> )
##
InstallMethod( ZeroOp,
    "for magma ring element",
    [ IsElementOfMagmaRingModuloRelations ],
    x -> Objectify( FamilyObj(x)!.defaultType,
             [ ZeroCoefficient( x ), [] ] ) );


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
    [ IsFreeMagmaRing ],
    RM -> IsGroup( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  PrintObj( <MR> )  . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( PrintObj,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
    function( MR )
    Print( "FreeMagmaRing( ", LeftActingDomain( MR ), ", ",
                              UnderlyingMagma( MR ), " )" );
    end );


#############################################################################
##
#F  FreeMagmaRing( <R>, <M> )
##
InstallGlobalFunction( FreeMagmaRing, function( R, M )
    local filter,  # implied filter of all elements in the new domain
          F,       # family of magma ring elements
          one,     # identity of `R'
          zero,    # zero of `R'
          m,       # one element of `M'
          RM,      # free magma ring, result
          gens;    # generators of the magma ring

    # Check the arguments.
    if not IsRing( R ) or One( R ) = fail then
      Error( "<R> must be a ring with identity" );
    fi;

    # Construct the family of elements of our ring.
    if   IsMultiplicativeElementWithInverseCollection( M ) then
      filter:= IsMultiplicativeElementWithInverse;
    elif IsMultiplicativeElementWithOneCollection( M ) then
      filter:= IsMultiplicativeElementWithOne;
    else
      filter:= IsMultiplicativeElement;
    fi;
    if IsAssociativeElementCollection( M ) and
       IsAssociativeElementCollection( R ) then
      filter:= filter and IsAssociativeElement;
    fi;

    F:= NewFamily( "FreeMagmaRingObjFamily",
                   IsElementOfFreeMagmaRing,
                   filter );

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

    # Just taking `Representative( M )' doesn't work if generators are not
    # yet computed (we need them anyway below).
    m := GeneratorsOfMagma( M );
    if Length(m) > 0 then
      m := m[1];
    else
      m:= Representative( M );
    fi;
    if IsMultiplicativeElementWithOne( m ) then
      F!.oneMagma:= One( m );
#T no !!
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
    [ IsFreeMagmaRing ],
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
    [ IsCanonicalBasisFreeMagmaRingRep, IsElementOfFreeMagmaRing ],
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
#M  Basis( <RM> ) . . . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( Basis,
    "for a free magma ring (delegate to `CanonicalBasis')",
    [ IsFreeMagmaRing ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <RM> )  . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( CanonicalBasis,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
    function( RM )

    local B, one, zero, F;

    F:= ElementsFamily( FamilyObj( RM ) );
    if not IsBound( F!.defaultType ) then
      TryNextMethod();
    fi;

    one  := One(  LeftActingDomain( RM ) );
    zero := Zero( LeftActingDomain( RM ) );

    B:= Objectify( NewType( FamilyObj( RM ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasisFreeMagmaRingRep ),
                   rec() );

    SetUnderlyingLeftModule( B, RM );
    if IsFiniteDimensional( RM ) then
      SetBasisVectors( B,
          List( EnumeratorSorted( UnderlyingMagma( RM ) ),
                x -> ElementOfMagmaRing( F, zero, [ one ], [ x ] ) ) );
      B!.zerovector:= List( BasisVectors( B ), x -> zero );
      MakeImmutable( B!.zerovector );
    fi;

    return B;
    end );


#############################################################################
##
#M  IsFinite( <RM> )  . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsFinite,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
    RM ->     IsFinite( LeftActingDomain( RM ) )
          and IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <RM> ) . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsFiniteDimensional,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
    RM -> IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <R> )  . .  for left module of free magma ring elms.
##
InstallMethod( IsFiniteDimensional,
    "for a left module of free magma ring elements",
    [ IsFreeLeftModule and IsElementOfFreeMagmaRingCollection
                       and HasGeneratorsOfLeftOperatorRing ],
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
    [ IsFreeMagmaRing ],
    RM -> Size( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <RM> )  . . . . . . . . . . for a free magma ring
##
InstallMethod( GeneratorsOfLeftModule,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
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
    [ IsGroupRing ],
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
    c:= FLMLORWithOne( Centre( LeftActingDomain( RG ) ), gens, "basis" );
    Assert( 1, IsAbelian( c ) );
    SetIsAbelian( c, true );
    return c;
    end );


#############################################################################
##
#M  \in( <r>, <RM> )  . . . . . . . . .  for ring element and free magma ring
##
InstallMethod( \in,
    "for ring element, and magma ring",
    IsElmsColls,
    [ IsElementOfMagmaRingModuloRelations, IsMagmaRingModuloRelations ],
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
#M  IsAssociative( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsAssociative,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
    RM ->     IsAssociative( LeftActingDomain( RM ) )
          and IsAssociative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsCommutative( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsCommutative,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
    RM ->     IsCommutative( LeftActingDomain( RM ) )
          and IsCommutative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsWholeFamily( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsWholeFamily,
    "for a free magma ring",
    [ IsFreeMagmaRing ],
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
    [ IsFreeMagmaRing ],
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
    [ IsFreeMagmaRingWithOne ],
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
        IsSPGeneralMapping
    and IsMapping
    and IsInjective
    and RespectsAddition
    and RespectsZero
    and RespectsMultiplication
    and RespectsOne
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#M  Embedding( <R>, <RM> )  . . . . . . . . . . . . . for ring and magma ring
##
InstallMethod( Embedding,
    "for ring and magma ring",
    IsRingCollsMagmaRingColls,
    [ IsRing, IsFreeMagmaRing ],
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
    [ IsEmbeddingRingMagmaRing, IsRingElement ],
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return [ ElementOfMagmaRing( F, Zero( elm ), [ elm ],
                 [ One( UnderlyingMagma( Range( emb ) ) ) ] ) ];
    end );

InstallMethod( ImagesRepresentative,
    "for embedding of ring into magma ring, and ring element",
    FamSourceEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsRingElement ],
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return ElementOfMagmaRing( F, Zero( elm ), [ elm ],
               [ One( UnderlyingMagma( Range( emb ) ) ) ] );
    end );


InstallMethod( PreImagesElm,
    "for embedding of ring into magma ring, and free magma ring element",
    FamRangeEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsElementOfFreeMagmaRing ],
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

InstallMethod( PreImagesRepresentative,
    "for embedding of ring into magma ring, and free magma ring element",
    FamRangeEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsElementOfFreeMagmaRing ],
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= CoefficientsAndMagmaElements( elm );
    if     Length( extrep ) = 2
       and extrep[1] = One( UnderlyingMagma( R ) ) then
      return extrep[2];
    else
      return fail;
    fi;
    end );


#############################################################################
##
#R  IsEmbeddingMagmaMagmaRing( <M>, <RM> )
##
DeclareRepresentation( "IsEmbeddingMagmaMagmaRing",
        IsSPGeneralMapping
    and IsMapping
    and IsInjective
    and RespectsMultiplication
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#F  Embedding( <M>, <RM> )  . . . . . . . . . . . .  for magma and magma ring
##
InstallMethod( Embedding,
    "for magma and magma ring",
    IsMagmaCollsMagmaRingColls,
    [ IsMagma, IsFreeMagmaRing ],
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

    if IsMagmaWithInverses( M ) then
      SetRespectsInverses( emb, true );
    elif IsMagmaWithOne( M ) then
      SetRespectsOne( emb, true );
    fi;

    # Return the embedding.
    return emb;
    end );


InstallMethod( ImagesElm,
    "for embedding of magma into magma ring, and mult. element",
    FamSourceEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsMultiplicativeElement ],
    function ( emb, elm )
    local R, F;
    R:= Range( emb );
    F:= ElementsFamily( FamilyObj( R ) );
    return [ ElementOfMagmaRing( F, Zero( LeftActingDomain( R ) ),
                 [ One( LeftActingDomain( R ) ) ], [ elm ] ) ];
    end );

InstallMethod( ImagesRepresentative,
    "for embedding of magma into magma ring, and mult. element",
    FamSourceEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsMultiplicativeElement ],
    function ( emb, elm )
    local R, F;
    R:= Range( emb );
    F:= ElementsFamily( FamilyObj( R ) );
    return ElementOfMagmaRing( F, Zero( LeftActingDomain( R ) ),
               [ One( LeftActingDomain( R ) ) ], [ elm ] );
    end );


InstallMethod( PreImagesElm,
    "for embedding of magma into magma ring, and free magma ring element",
    FamRangeEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsElementOfFreeMagmaRing ],
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

InstallMethod( PreImagesRepresentative,
    "for embedding of magma into magma ring, and free magma ring element",
    FamRangeEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsElementOfFreeMagmaRing ],
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= CoefficientsAndMagmaElements( elm );
    if     Length( extrep ) = 2
       and extrep[2] = One( LeftActingDomain( R ) ) then
      return extrep[1];
    else
      return fail;
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
    [ IsElementOfMagmaRingModuloRelations ],
    function( elm )
    local zero, i;
    zero:= ZeroCoefficient( elm );
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
    [ IsElementOfMagmaRingModuloRelationsFamily, IsList ],
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
##  3. Free left modules in magma rings modulo relations
##


#############################################################################
##
#M  NiceFreeLeftModuleInfo( <V> )
#M  NiceVector( <V>, <v> )
#M  UglyVector( <V>, <r> )
##
InstallHandlingByNiceBasis( "IsSpaceOfElementsOfMagmaRing", rec(
    detect := function( F, gens, V, zero )
      return IsElementOfMagmaRingModuloRelationsCollection( V );
      end,

    NiceFreeLeftModuleInfo := function( V )
      local gens,
            monomials,
            gen,
            list,
            i,
            zero,
            info;

      gens:= GeneratorsOfLeftModule( V );
      monomials:= [];

      for gen in gens do
        list:= CoefficientsAndMagmaElements( gen );
        for i in [ 1, 3 .. Length( list ) - 1 ] do
          AddSet( monomials, list[i] );
        od;
      od;

      zero:= Zero( V )![1];
      info:= rec( monomials := monomials,
                  zerocoeff := zero,
                  family    := ElementsFamily( FamilyObj( V ) ) );

      # For the zero row vector, catch the case of empty `monomials' list.
      if IsEmpty( monomials ) then
        info.zerovector := [ Zero( LeftActingDomain( V ) ) ];
      else
        info.zerovector := ListWithIdenticalEntries( Length( monomials ),
                                                     zero );
      fi;
      MakeImmutable( info.zerovector );

      return info;
      end,

    NiceVector := function( V, v )
      local info, c, monomials, i, pos;
      info:= NiceFreeLeftModuleInfo( V );
      c:= ShallowCopy( info.zerovector );
      v:= CoefficientsAndMagmaElements( v );
      monomials:= info.monomials;
      for i in [ 2, 4 .. Length( v ) ] do
        pos:= Position( monomials, v[ i-1 ] );
        if pos = fail then return fail; fi;
        c[ pos ]:= v[i];
      od;
      return c;
      end,

    UglyVector := function( V, r )
      local info;
      info:= NiceFreeLeftModuleInfo( V );
      if Length( r ) <> Length( info.zerovector ) then
        return fail;
      elif IsEmpty( info.monomials ) then
        if IsZero( r ) then
          return Zero( V );
        else
          return fail;
        fi;
      fi;
      return ElementOfMagmaRing( info.family, info.zerocoeff,
                 r, info.monomials );
      end ) );


#############################################################################
##
##  4. methods for free magma rings modulo the span of a ``zero'' element
##


#############################################################################
##
#F  MagmaRingModuloSpanOfZero( <R>, <M>, <z> )
##
InstallGlobalFunction( MagmaRingModuloSpanOfZero, function( R, M, z )

    local RM,         # result
          F,          # family of magma ring elements
          one,        # identity of `R'
          zero;       # zero of `R'

    # Construct the family of elements of our ring.
    F:= NewFamily( "MagmaRingModuloSpanOfZeroObjFamily",
                   IsElementOfMagmaRingModuloRelations );
    SetFilterObj( F, IsElementOfMagmaRingModuloSpanOfZeroFamily );

    one:= One( R );
    zero:= Zero( R );

    F!.defaultType := NewType( F, IsMagmaRingObjDefaultRep );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( M );
    F!.zeroRing    := zero;
#T no!
    F!.zeroOfMagma := z;

    # Do not set the characteristic since we do not know whether we are
    # 0-dimensional and the characteristic would then be 0.

    # Make the magma ring object.
    RM:= Objectify( NewType( CollectionsFamily( F ),
                                 IsMagmaRingModuloSpanOfZero
                             and IsAttributeStoringRep ),
                    rec() );

    # Store it in its elements family:
    F!.magmaring := RM;

    # Set the necessary attributes.
    SetLeftActingDomain( RM, R );
    SetUnderlyingMagma(  RM, M );

    # Deduce useful information.
    if HasIsFinite( M ) then
      SetIsFiniteDimensional( RM, IsFinite( M ) );
    fi;
    if HasIsWholeFamily( R ) and HasIsWholeFamily( M ) then
      SetIsWholeFamily( RM, IsWholeFamily( R ) and IsWholeFamily( M ) );
    fi;

    # Construct the generators.
    SetGeneratorsOfLeftOperatorRing( RM,
        List( GeneratorsOfMagma( M ),
              x -> ElementOfMagmaRing( F, zero, [ one ], [ x ] ) ) );

    # Return the ring.
    return RM;
end );


#############################################################################
##
#M  Characteristic( <A> )
#M  Characteristic( <algelm> )
#M  Characteristic( <algelmfam> )
##
##  (via delegations)
##
InstallMethod( Characteristic,
  "for an elements family of a magma ring quotient",
  [ IsElementOfMagmaRingModuloSpanOfZeroFamily ],
  function( fam )
    local A,one;
    A := fam!.magmaring;
    one := One(A);
    if Zero(A) = one then
        return 1;
    else
        return Characteristic(LeftActingDomain(A));
    fi;
  end );


#############################################################################
##
#M  NormalizedElementOfMagmaRingModuloRelations( <Fam>, <descr> )
#M                     . . . for a magma ring modulo the span of the ``zero''
##
##  <Fam> is a family of elements of a magma ring modulo the span of the
##  ``zero element'' of the magma.
##  <descr> is a list of the form `[ <z>, <list> ]', <z> being the zero
##  coefficient of the ring, and <list> being the list of monomials and
##  their coefficients.
##
##  The function returns the element described by <descr> in normal form,
##  that is, with zero coefficient of the ``zero element'' of the magma.
##
InstallMethod( NormalizedElementOfMagmaRingModuloRelations,
    "for family of magma rings modulo the span of ``zero'', and list",
    [ IsElementOfMagmaRingModuloSpanOfZeroFamily, IsList ],
    function( Fam, descr )

    local zeromagma, len, i;

    zeromagma:= Fam!.zeroOfMagma;
    len:= Length( descr[2] );
    for i in [ 1, 3 .. len - 1 ] do
      if descr[2][i] = zeromagma then
        descr:= [ descr[1], Concatenation( descr[2]{ [ 1 .. i-1 ] },
                                           descr[2]{ [ i+2 .. len ] } ) ];
        break;
      fi;
    od;

    MakeImmutable( descr );
    return descr;
    end );


#############################################################################
##
#M  IsFinite( <RM> )  . . . . . . . .  for magma ring modulo span of ``zero''
##
InstallMethod( IsFinite,
    "for a magma ring modulo the span of ``zero''",
    [ IsMagmaRingModuloSpanOfZero ],
    RM ->     IsFinite( LeftActingDomain( RM ) )
          and IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <RM> ) . . .  for magma ring modulo span of ``zero''
##
InstallMethod( IsFiniteDimensional,
    "for a magma ring modulo the span of ``zero''",
    [ IsMagmaRingModuloSpanOfZero ],
    RM -> IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  Dimension( <RM> ) . . . . . . . .  for magma ring modulo span of ``zero''
##
InstallMethod( Dimension,
    "for a magma ring modulo the span of ``zero''",
    [ IsMagmaRingModuloSpanOfZero ],
    RM -> Size( UnderlyingMagma( RM ) ) - 1 );


#############################################################################
##
#M  GeneratorsOfLeftModule( <RM> )  .  for magma ring modulo span of ``zero''
##
InstallMethod( GeneratorsOfLeftModule,
    "for a magma ring modulo the span of ``zero''",
    [ IsMagmaRingModuloSpanOfZero ],
    function( RM )
    local F, one, zero;
    if IsFiniteDimensional( RM ) then
      F:= ElementsFamily( FamilyObj( RM ) );
      one:= One( LeftActingDomain( RM ) );
      zero:= Zero( LeftActingDomain( RM ) );
      return List( Difference( AsSSortedList( UnderlyingMagma( RM ) ),
                               [ F!.zeroOfMagma ] ),
                   m -> ElementOfMagmaRing( F, zero, [ one ], [ m ] ) );
    else
      Error( "<RM> is not finite dimensional" );
    fi;
    end );


#############################################################################
##
##  5. methods for groups of free magma ring elements
##


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <mgmringelms> )
##
##  Check that all elements are in fact invertible.
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a collection of free magma ring elements",
    [ IsElementOfMagmaRingModuloRelationsCollection ],
    mgmringelms -> ForAll( mgmringelms, x -> Inverse( x ) <> fail ) );
