#############################################################################
##
#W  mgmring.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
IsMagmaRingObjDefaultRep := NewRepresentation(
    "IsMagmaRingObjDefaultRep", 
    IsPositionalObjectRep,
    [ 1, 2 ] );


#############################################################################
##
#F  FMRRemoveZero( <coeffs_and_words>, <zero> )
##
##  removes all pairs from <coeffs_and_words> where the coefficient
##  is <zero>.
##
FMRRemoveZero := function( coeffs_and_words, zero )

    local i,    # offset of old and new position
          lenw, # length of 'words' and 'coeff'
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
#T better use PositionNot( v, from ) !!
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
    "method for family, ring element, and two homogeneous lists",
    true,
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ], 0,
    function( Fam, zerocoeff, coeff, words )
    local rep, i;

    # Check that the data is admissible.
    if not IsBound( Fam!.defaultType ) then
      TryNextMethod();
    elif not IsIdentical( FamilyObj( coeff ), Fam!.familyRing ) then
      Error( "<coeff> are not all in the correct domain" );
    elif not IsIdentical( FamilyObj( words ), Fam!.familyMagma ) then
      Error( "<words> are not all in the correct domain" );
    elif Length( coeff ) <> Length( words ) then
      Error( "<coeff> and <words> must have same length" );
    fi;

    # Create the default representation.
    rep:= [];
    for i in [ 1 .. Length( coeff ) ] do
#T better look for zeros already here ...
#T what about the ordering of monomials ?? (SortParallel by default?)
      rep[ 2*i-1 ]:= words[i];
      rep[ 2*i   ]:= coeff[i];
    od;

    # Remove all words with zero coefficients.
    return Objectify( Fam!.defaultType,
               [ zerocoeff, FMRRemoveZero( rep, Fam!.zeroRing ) ] );
    end );


#############################################################################
##
#M  CoefficientsAndMagmaElements( <elm> )
##
InstallMethod( CoefficientsAndMagmaElements,
    "method for magma ring element in default repr.",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 0,
    elm -> elm![2] );
    

#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . . for magma ring element in default repr.
##
InstallMethod( PrintObj,
    "method for magma ring element",
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
    IsIdentical,
    [ IsElementOfFreeMagmaRing, IsElementOfFreeMagmaRing ], 0,
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
    IsIdentical,
    [ IsElementOfFreeMagmaRing, IsElementOfFreeMagmaRing ], 0,
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
    IsIdentical,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ], 0,
    function( x, y )

    local F,           # family of 'x'
          zero,        # the zero of the ring
          coeff,       # the data of the result
          lenx,        # length of the data of 'x'
          leny,        # length of the data of 'y'
          posx,        # position in 'x'
          posy,        # position in 'y'
          coe;         # one coefficient in the sum

    F    := FamilyObj( x );
    zero := F!.zeroRing;
    x    := CoefficientsAndMagmaElements( x );
    y    := CoefficientsAndMagmaElements( y );

    coeff := [];
    lenx  := Length( x );
    leny  := Length( y );
    posx  := 1;
    posy  := 1;

    while posy <= leny do
      while     posx <= lenx
            and x[ posx ] < y[ posy ] do
        Add( coeff, x[ posx ]   );
        Add( coeff, x[ posx+1 ] );
        posx:= posx + 2;
      od;
      if lenx < posx then
        Append( coeff, y{ [ posy .. leny ] } );
        posy:= leny + 2;
      elif x[ posx ] = y[ posy ] then
        coe:= x[ posx+1 ] + y[ posy+1 ];
        if coe <> zero then
          Add( coeff, x[ posx ] );
          Add( coeff, coe );
        fi;
        posx:= posx + 2;
        posy:= posy + 2;
      else
        Add( coeff, y[ posy ] );
        Add( coeff, y[ posy+1 ] );
        posy:= posy + 2;
      fi;
    od;

    Append( coeff, x{ [ posx .. lenx ] } );

    return Objectify( F!.defaultType, [ zero, coeff ] );
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
    local ext, i, Fam;
    ext:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length( ext ) ] do
      ext[i]:= AdditiveInverse( ext[i] );
    od;
    Fam:= FamilyObj( x );
    return Objectify( Fam!.defaultType, [ Fam!.zeroRing, ext ] );
    end );


#############################################################################
##
#M  \*( <x>, <y> )  . . . . . .  for two magma ring elements in default repr.
##
InstallMethod( \*,
    "for two magma ring elements",
    IsIdentical,
    [ IsElementOfMagmaRingModuloRelations,
      IsElementOfMagmaRingModuloRelations ], 0,
    function( x, y )

    local F,           # family of 'x' and 'y'
          coeff,       # the data of the result
          words,       # list of words in the result
          coef,        # one coefficient of the result
          word,        # one word of the result
          lenx,        # length of the data of 'x'
          leny,        # length of the data of 'y'
          posx,        # position in 'x'
          posy,        # position in 'y'
          pos,         # position of a single word
          coe,         # one coefficient in the sum
          i;

    F := FamilyObj( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );

    coeff := [];
    words := [];
    lenx  := Length( x );
    leny  := Length( y );
    posx  := 2;
    posy  := 2;

    for posx in [ 2, 4 .. lenx ] do
      for posy in [ 2, 4 .. leny ] do

        coef:= x[ posx ] * y[ posy ];
        word:= x[ posx-1 ] * y[ posy-1 ];
        pos := PositionSorted( words, word );
        if   IsBound( words[ pos ] ) and words[ pos ] = word then
          pos:= 2*pos;
          coeff[ pos ]:= coeff[ pos ] + coef;
        else
          if   pos <= Length( words ) then
            for i in [ Length( words ), Length( words )-1 .. pos ] do
              words[ i+1 ]:= words[i];
            od;
            for i in [ Length( coeff ), Length( coeff )-1 .. 2*pos-1 ] do
              coeff[ i+2 ]:= coeff[i];
            od;
          fi;
          words[ pos ]:= word;
          pos:= 2*pos;
          coeff[ pos ]:= coef;
          coeff[ pos-1 ]:= word;
        fi;

      od;
    od;

    # Remove all words with zero coefficients.
    return Objectify( F!.defaultType,
                      [ F!.zeroRing, FMRRemoveZero( coeff, F!.zeroRing ) ] );
    end );


#T install multiplication with magma elements from left and right !


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
    local F, i;
    F:= FamilyObj( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] * y;
    od;
    return Objectify( F!.defaultType,
                      [ F!.zeroRing, FMRRemoveZero( x, F!.zeroRing ) ] );
end;

InstallMethod( \*,
    "method for magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsElementOfMagmaRingModuloRelations, IsRingElement ], 0,
    ElmTimesRingElm );

InstallMethod( \*,
    "method for magma ring element, and integer",
    true,
    [ IsElementOfMagmaRingModuloRelations, IsInt ], 0,
    ElmTimesRingElm );


#############################################################################
##
#M  \*( r, x )  . . . . . . . . . . .  for coefficient and magma ring element
##
RingElmTimesElm := function( x, y )
    local F, i;
    F:= FamilyObj( y );
    y:= ShallowCopy( CoefficientsAndMagmaElements( y ) );
    for i in [ 2, 4 .. Length(y) ] do
      y[i]:= x * y[i];
    od;
    return Objectify( F!.defaultType,
                      [ F!.zeroRing, FMRRemoveZero( y, F!.zeroRing ) ] );
end;

InstallMethod( \*,
    "method for ring element, and magma ring element",
    IsRingsMagmaRings,
    [ IsRingElement, IsElementOfMagmaRingModuloRelations ],0,
    RingElmTimesElm );

InstallMethod( \*,
    "method for integer, and magma ring element",
    true,
    [ IsInt, IsElementOfMagmaRingModuloRelations ],0,
    RingElmTimesElm );


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
    "method for magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsElementOfMagmaRingModuloRelations, IsRingElement ], 0,
    ElmDivRingElm );

InstallMethod( \/,
    "method for magma ring element, and integer",
    true,
    [ IsElementOfMagmaRingModuloRelations, IsInt ], 0,
    ElmDivRingElm );


#############################################################################
##
#M  Inverse( <elm> ) . . . . . . . . . . . .  inverse of a magma ring element
##
InstallOtherMethod( Inverse,
    "method for free magma ring element",
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
    "method for magma ring element",
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( elm )
    local F, zerocoeff;
    F:= FamilyObj( elm );
    zerocoeff:= F!.zeroRing;
    return Objectify( F!.defaultType,
               [ zerocoeff, [ One( ElementsFamily( F!.familyMagma ) ),
                              One( zerocoeff ) ] ] );
#T problem!!
    end );


#############################################################################
##
#M  Zero( <elm> )
##
InstallMethod( Zero,
    "method for magma ring element",
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
    "method for free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM -> IsGroup( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  PrintObj( <MR> )  . . . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( PrintObj,
    "method for a free magma ring",
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
FreeMagmaRing := function( R, M )

    local F,     # family of magma ring elements
          one,   # identity of 'R'
          zero,  # zero of 'R'
          RM,    # free magma ring, result
          gens;  # generators of the magma ring

    # Check the arguments.
    if not IsRing( R ) or One( R ) = fail then
#T change?
      Error( "<R> must be a ring-with-one" );
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
#T how to improve?

    one:= One( R );
    zero:= Zero( R );

    F!.defaultType := NewType( F, IsMagmaRingObjDefaultRep );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( M );
    F!.zeroRing    := zero;
#T no !!

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
    if IsMagmaWithInverses( M ) and HasIsAssociative( M )
                                and IsAssociative( M ) then
      SetIsGroupRing( RM, IsGroup( M ) );
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
end;


#############################################################################
##
#R  IsCanonicalBasisFreeMagmaRingRep( <B> )
##
IsCanonicalBasisFreeMagmaRingRep := NewRepresentation(
    "IsCanonicalBasisFreeMagmaRingRep",
    IsCanonicalBasis and IsAttributeStoringRep,
    [ "zerovector" ] );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . for canon. basis of free magma ring
##
InstallMethod( Coefficients,
    "method for canon. basis of a free magma ring, and a vector",
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
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing ],
    10,  # must be higher than default method for (asssoc.) FLMLOR(WithOne)
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <RM> )  . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( CanonicalBasis,
    "method for a free magma ring",
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
#M  IsFinite( <RM> )
##
InstallMethod( IsFinite,
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsFinite( LeftActingDomain( RM ) )
          and IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <RM> ) . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsFiniteDimensional,
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM -> IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  Dimension( <RM> )
##
InstallMethod( Dimension,
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM -> Size( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <RM> )
##
InstallMethod( GeneratorsOfLeftModule,
    "method for a free magma ring",
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
#M  Centre( <RM> )
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
    "method for a group ring",
    true,
    [ IsGroupRing ], 0,
    function( RG )

    local F,      # family of elements of 'RG'
          one,    # identity of the coefficients ring
          zero,   # zero of the coefficients ring
          gens,   # list of (module) generators of the result
          c,      # loop over 'ccl'
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
    "method for ring element, and magma ring",
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
IsFreeMagmaRingEnumerator := NewRepresentation(
    "IsFreeMagmaRingEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "family", "zerocoeff", "ringenum", "magmaenum", "zero" ] );

InstallMethod( \[\],
    "method for enumerator of a free magma ring",
    true,
    [ IsFreeMagmaRingEnumerator, IsPosRat and IsInt ], 0,
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
    "method for enumerator of a free magma ring",
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
    "method for enumerator of a free magma ring with finite ring",
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
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsAssociative( LeftActingDomain( RM ) )
          and IsAssociative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsCommutative( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsCommutative,
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing ], 0,
    RM ->     IsCommutative( LeftActingDomain( RM ) )
          and IsCommutative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsWholeFamily( <RM> ) . . . . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsWholeFamily,
    "method for a free magma ring",
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
    "method for a free magma ring",
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
    "method for a free magma ring-with-one",
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
IsEmbeddingRingMagmaRing := NewRepresentation( "IsEmbeddingRingMagmaRing",
        IsNonSPGeneralMapping
    and IsMapping
    and IsInjective
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#R  IsEmbeddingMagmaMagmaRing( <M>, <RM> )
##
IsEmbeddingMagmaMagmaRing := NewRepresentation( "IsEmbeddingMagmaMagmaRing",
        IsNonSPGeneralMapping
    and IsMapping
    and IsInjective
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#M  Embedding( <R>, <RM> )
##
InstallMethod( Embedding,
    IsRingsMagmaRings,
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
    FamSourceEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsRingElement ], 0,
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return [ ElementOfMagmaRing( F, Zero( elm ), [ elm ],
                 [ One( UnderlyingMagma( Range( emb ) ) ) ] ) ];
    end );


InstallMethod( PreImagesElm, FamRangeEqFamElm,
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
#F  Embedding( <M>, <RM> )
##
InstallMethod( Embedding,
    IsMagmasMagmaRings,
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
    "method for magma ring element",
#T eventually more specific!
#T allow this only if the magma elements have an external representation!
    true,
    [ IsElementOfMagmaRingModuloRelations ], 0,
    function( elm )
    local zero, i;
    zero:= FamilyObj( elm )!.zeroRing;
    elm:= ShallowCopy( CoefficientsAndMagmaElements( elm ) );
    for i in [ 1, 3 .. Length( elm ) - 1 ] do
      elm[i]:= ExtRepOfObj( elm[i] );
    od;
#T sort this !!
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
InstallMethod( ObjByExtRep,
    "method for magma ring elements family, and list",
    true,
    [ IsFamilyElementOfMagmaRingModuloRelations, IsList ], 0,
    function( Fam, descr )
    local FM, elm, i;
    FM:= ElementsFamily( Fam!.familyMagma );
#T why not store the elements family itself?
    elm:= ShallowCopy( descr[2] );
    for i in [ 1, 3 .. Length( elm ) - 1 ] do
      elm[i]:= ObjByExtRep( FM, elm[i] );
    od;
#T sort this !!
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
##  The computation of $S$ is done by 'PrepareNiceFreeLeftModule'.
##

#############################################################################
##
#R  IsSpaceOfElementsOfFreeMagmaRingRep( <V> )
##
##  is the representation of free left modules of free magma ring elements
##  that are handled via nice bases.
##
##  'family' : \\
##     elements family of <V>
##
##  'monomials' : \\
##     the list of magma elements that occur in elements of <V>.
##
##  'zerocoeff' : \\
##     zero coefficient of elements in <V>
##
##  'zerovector' : \\
##     zero row vector in the nice left module
##
IsSpaceOfElementsOfFreeMagmaRingRep := NewRepresentation(
    "IsSpaceOfElementsOfFreeMagmaRingRep",
    IsHandledByNiceBasis and IsAttributeStoringRep,
    [ "family", "monomials", "zerocoeff", "zerovector" ] );


#############################################################################
##
#M  PrepareNiceFreeLeftModule( <V> )
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for free left module of free magma ring elements",
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
#T may we assume here that the generators are in default rep.?
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
##  is the row vector in 'NiceFreeLeftModule( <V> )' that corresponds
##  to the vector <v> of <V>.
##
InstallMethod( NiceVector,
    "method for free left module of free magma ring elements, and element",
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
##  'NiceFreeLeftModule( <V> )'.
##
InstallMethod( UglyVector,
    "method for left module of free magma ring elements, and row vector",
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
#M  MutableBasisByGenerators( <R>, <gens> )
#M  MutableBasisByGenerators( <R>, <gens>, <zero> )
##
##  We choose a mutable basis that stores a mutable basis for a nice module.
##
InstallMethod( MutableBasisByGenerators,
    "method for ring and collection of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection ], 0,
    MutableBasisViaNiceMutableBasisMethod2 );

InstallOtherMethod( MutableBasisByGenerators,
    "method for ring, (possibly empty) list, and zero in free magma ring",
    true,
    [ IsRing, IsList, IsElementOfFreeMagmaRing ], 0,
    MutableBasisViaNiceMutableBasisMethod3 );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <gens> ) . create vector space of field elms
##
InstallMethod( LeftModuleByGenerators,
    "method for ring and collection of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection ] , 0,
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
    "method for ring and collection of free magma ring elements",
    true,
    [ IsRing, IsElementOfFreeMagmaRingCollection, IsElementOfFreeMagmaRing ],
    0,
    function( F, gens, zero )
    local V;
    V:= Objectify( NewType( FamilyObj( F ),
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
    "method for ring, empty list, and free magma ring element",
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
    "method for ring and list of free magma ring elements",
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
    "method for ring, empty list, and free magma ring element",
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
    "method for ring, list of free magma ring elements, and zero",
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
    "method for ring and list of free magma ring elements",
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
    "method for ring, empty list, and free magma ring element",
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
    "method for ring, list of free magma ring elements, and zero",
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
#E  mgmring.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



