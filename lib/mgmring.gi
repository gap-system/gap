#############################################################################
##
#W  mgmring.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for free magma rings and their elements.
##
##  1. methods for elements of free magma rings in default representation
##  2. methods for free magma rings
##
Revision.mgmring_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. methods for elements of free magma rings in default representation
##


#############################################################################
##
#R  IsFreeMagmaRingObjDefaultRep( <obj> )
##
##  The default representation of an element object is a list of length 2,
##  at first position the zero coefficient, at second position a list with
##  the coefficients at the even positions, and the magma elements at the
##  odd positions, with the ordering as defined for the magma elements.
##
##  It is assumed that the arithmetic operations of $M$ produce only
##  normalized elements.
##
IsFreeMagmaRingObjDefaultRep := NewRepresentation(
    "IsFreeMagmaRingObjDefaultRep", 
    IsPositionalObjectRep and IsRingElementWithOne,
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
      if coeffs_and_words[ pos ] = zero then
        i:= i + 2;
      fi;
      if i < pos then
        coeffs_and_words[ pos-i-1 ]:= coeffs_and_words[ pos-1 ];
        coeffs_and_words[ pos-i   ]:= coeffs_and_words[ pos   ];
      fi;
#T better use DepthVector( v, from ) !!
    od;
    for pos in [ lenw-i+1 .. lenw ] do
      Unbind( coeffs_and_words[ pos ] );
    od;
    return coeffs_and_words;
end;


#############################################################################
##
#M  FreeMagmaRingElement( <Fam>, <zerocoeff>, <coeff>, <words> )
##
##  check whether <coeff> and <words> lie in the correct domains,
##  and remove zeroes.
##
InstallMethod( FreeMagmaRingElement,
    "method for family, ring element, and two homogeneous lists",
    true,
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ], 0,
    function( Fam, zerocoeff, coeff, words )
    local rep, i;

    # Check that the data is admissible.
    if not IsBound( Fam!.defaultKind ) then
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
      rep[ 2*i-1 ]:= words[i];
      rep[ 2*i   ]:= coeff[i];
    od;

    # Remove all words with zero coefficients.
    return Objectify( Fam!.defaultKind,
               [ zerocoeff, FMRRemoveZero( rep, Fam!.zeroRing ) ] );
    end );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . .  for free magma ring element in default repr.
##
InstallMethod( PrintObj,
    "method for free magma ring element in default repr.",
    true,
    [ IsFreeMagmaRingObjDefaultRep ], 0,
    function( elm )

    local coeffs_and_words,
          i;

    coeffs_and_words:= elm![2];
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
    "for two free magma ring elements in default repr.",
    IsIdentical,
    [ IsFreeMagmaRingObjDefaultRep, IsFreeMagmaRingObjDefaultRep ],0,
    function( x, y )
    return x![2] = y![2];
    end );


#############################################################################
##
#M  \<( <x>, <y> )  . . . . for two free magma ring elements in default repr.
##
InstallMethod( \<,
    "for two free magma ring elements in default repr.",
    IsIdentical,
    [ IsFreeMagmaRingObjDefaultRep, IsFreeMagmaRingObjDefaultRep ],0,
    function( x, y )
    local i;
    x:= x![2];
    y:= y![2];
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
#M  \+( <x>, <y> )  . . . . for two free magma ring elements in default repr.
##
InstallMethod( \+,
    "for two free magma ring elements in default repr.",
    IsIdentical,
    [ IsFreeMagmaRingObjDefaultRep, IsFreeMagmaRingObjDefaultRep ],0,
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
    x    := x![2];
    y    := y![2];

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

    return Objectify( F!.defaultKind, [ zero, coeff ] );
    end );


#############################################################################
##
#M  AdditiveInverse( <x> )  . .  for free magma ring element in default repr.
##
InstallMethod( AdditiveInverse,
    "for free magma ring element in default repr.",
    true,
    [ IsFreeMagmaRingObjDefaultRep ], 0,
    function( x )
    local ext, i;
    ext:= ShallowCopy( x![2] );
    for i in [ 2, 4 .. Length( ext ) ] do
      ext[i]:= AdditiveInverse( ext[i] );
    od;
    return Objectify( FamilyObj( x )!.defaultKind, [ x![1], ext ] );
    end );


#############################################################################
##
#M  \*( <x>, <y> )  . . . . for two free magma ring elements in default repr.
##
InstallMethod( \*,
    "for two free magma ring elements in default repr.",
    IsIdentical,
    [ IsFreeMagmaRingObjDefaultRep, IsFreeMagmaRingObjDefaultRep ],0,
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
    x := x![2];
    y := y![2];

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
    return Objectify( F!.defaultKind,
                      [ F!.zeroRing, FMRRemoveZero( coeff, F!.zeroRing ) ] );
    end );


#############################################################################
##
#F  IsMagmaRingsRings( <FamRM>, <FamR> )  . . . . . . . . .  family predicate
#F  IsRingsMagmaRings( <FamR>, <FamRM> )  . . . . . . . . .  family predicate
#F  IsMagmasMagmaRings( <FamM>, <FamRM> ) . . . . . . . . .  family predicate
##
IsMagmaRingsRings := function( FamRM, FamR )
    return     IsBound( FamRM!.familyRing )
           and IsIdentical( ElementsFamily( FamRM!.familyRing ), FamR );
end;

IsRingsMagmaRings := function( FamR, FamRM )
    return     IsBound( FamRM!.familyRing )
           and IsIdentical( ElementsFamily( FamRM!.familyRing ), FamR );
end;

IsMagmasMagmaRings := function( FamM, FamRM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdentical( ElementsFamily( FamRM!.familyMagma ), FamM );
end;

#T install multiplication with magma elements from left and right !


#############################################################################
##
#M  \*( x, r )  . . . . . . . . . for free magma ring element and coefficient
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
    x:= ShallowCopy( x![2] );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] * y;
    od;
    return Objectify( F!.defaultKind,
                      [ F!.zeroRing, FMRRemoveZero( x, F!.zeroRing ) ] );
end;

InstallMethod( \*,
    "method for free magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsFreeMagmaRingObjDefaultRep, IsRingElement ], 0,
    ElmTimesRingElm );

InstallMethod( \*,
    "method for free magma ring element, and integer",
    true,
    [ IsFreeMagmaRingObjDefaultRep, IsInt ], 0,
    ElmTimesRingElm );


#############################################################################
##
#M  \*( r, x )  . . . . . . . . . for coefficient and free magma ring element
##
RingElmTimesElm := function( x, y )
    local F, i;
    F:= FamilyObj( y );
    y:= ShallowCopy( y![2] );
    for i in [ 2, 4 .. Length(y) ] do
      y[i]:= x * y[i];
    od;
    return Objectify( F!.defaultKind,
                      [ F!.zeroRing, FMRRemoveZero( y, F!.zeroRing ) ] );
end;

InstallMethod( \*,
    "method for ring element, and free magma ring element",
    IsRingsMagmaRings,
    [ IsRingElement, IsFreeMagmaRingObjDefaultRep ],0,
    RingElmTimesElm );

InstallMethod( \*,
    "method for integer, and free magma ring element",
    true,
    [ IsInt, IsFreeMagmaRingObjDefaultRep ],0,
    RingElmTimesElm );


#############################################################################
##
#M  \/( x, r )  . . . . . . . . . for free magma ring element and coefficient
##
ElmDivRingElm := function( x, y )
    local F, i;
    F:= FamilyObj( x );
    x:= ShallowCopy( x![2] );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] / y;
    od;
    return Objectify( F!.defaultKind, [ F!.zeroRing, x ] );
end;

InstallOtherMethod( \/,
    "method for free magma ring element, and ring element",
    IsMagmaRingsRings,
    [ IsFreeMagmaRingObjDefaultRep, IsRingElement ], 0,
    ElmDivRingElm );

InstallMethod( \/,
    "method for free magma ring element, and integer",
    true,
    [ IsFreeMagmaRingObjDefaultRep, IsInt ], 0,
    ElmDivRingElm );


#############################################################################
##
#M  Inverse( <elm> ) . . . . . . . . . . inverse of a free magma ring element
##
InstallOtherMethod( Inverse,
    "method for free magma ring element",
    true,
    [ IsFreeMagmaRingObjDefaultRep ], 0,
    function( elm )
    local F;
    F:= FamilyObj( elm );
    elm:= elm![2];
    if Length( elm ) = 2 then
      return Objectify( F!.defaultKind,
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
    "method for free magma ring element",
    true,
    [ IsFreeMagmaRingObjDefaultRep ], 0,
    function( elm )
    local F, zerocoeff;
    F:= FamilyObj( elm );
    zerocoeff:= F!.zeroRing;
    return Objectify( F!.defaultKind,
               [ zerocoeff, [ One( ElementsFamily( F!.familyMagma ) ),
                              One( zerocoeff ) ] ] );
#T problem!!
    end );


#############################################################################
##
#M  Zero( <elm> )
##
InstallMethod( Zero,
    "method for free magma ring element",
    true,
    [ IsFreeMagmaRingObjDefaultRep ], 0,
    x -> Objectify( FamilyObj(x)!.defaultKind,
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
          RM;    # free magma ring, result

    # Check the arguments.
    if not IsRing( R ) or One( R ) = fail then
#T change?
      Error( "<R> must be a ring-with-one" );
    fi;

    # Construct the family of elements of our ring.
    if   IsMultiplicativeElementWithInverseCollection( M ) then
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsFreeMagmaRingObjDefaultRep,
                     IsMultiplicativeElementWithInverse );
    elif IsMultiplicativeElementWithOneCollection( M ) then
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsFreeMagmaRingObjDefaultRep,
                     IsMultiplicativeElementWithOne );
    else
      F:= NewFamily( "FreeMagmaRingObjFamily",
                      IsFreeMagmaRingObjDefaultRep,
                      IsMultiplicativeElement );
    fi;
#T how to improve?

    one:= One( R );
    zero:= Zero( R );

    F!.defaultKind := NewKind( F, IsFreeMagmaRingObjDefaultRep );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( M );
    F!.zeroRing    := zero;
#T no !!

    # Make the magma ring object.
    if IsMagmaWithOne( M ) then
      RM:= Objectify( NewKind( CollectionsFamily( F ),
                                   IsFreeMagmaRingWithOne
                               and IsAttributeStoringRep ),
                      rec() );
    else
      RM:= Objectify( NewKind( CollectionsFamily( F ),
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
    if IsMagmaWithOne( M ) then
      SetGeneratorsOfLeftOperatorRingWithOne( RM,
          List( GeneratorsOfMagmaWithOne( M ),
                x -> FreeMagmaRingElement( F, zero, [ one ], [ x ] ) ) );
    else
      SetGeneratorsOfLeftOperatorRing( RM,
          List( GeneratorsOfMagma( M ),
                x -> FreeMagmaRingElement( F, zero, [ one ], [ x ] ) ) );
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
    [ IsCanonicalBasisFreeMagmaRingRep, IsFreeMagmaRingObjDefaultRep ], 0,
    function( B, v )

    local coeffs,
          data,
          elms,
          i;

    data:= v![2];
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
    [ IsFreeMagmaRing ], 0,
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
    if not IsBound( F!.defaultKind ) then
      TryNextMethod();
    fi;

    one  := One(  LeftActingDomain( RM ) );
    zero := Zero( LeftActingDomain( RM ) );

    B:= Objectify( NewKind( FamilyObj( RM ),
                            IsCanonicalBasisFreeMagmaRingRep ),
                   rec() );

    SetUnderlyingLeftModule( B, RM );
    if IsFiniteDimensional( RM ) then
      SetBasisVectors( B,
          List( EnumeratorSorted( UnderlyingMagma( RM ) ),
                x -> FreeMagmaRingElement( F, zero, one, x ) ) );
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
                   m -> FreeMagmaRingElement( F, zero, [ one ], [ m ] ) );
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
      Add( gens, FreeMagmaRingElement( F, zero, coeff, elms ) );
    od;
    return FLMLOR( Centre( LeftActingDomain( RG ) ), gens, "basis" );
    end );


#############################################################################
##
#M  \in( <r>, <RM> )  . . . . . . . . .  for ring element and free magma ring
##
InstallMethod( \in,
    "method for a ring element, and a free magma ring",
    IsElmsColls,
    [ IsFreeMagmaRingObjDefaultRep, IsFreeMagmaRing ], 0,
    function( r, RM )
    r:= r![2];
    return     ForAll( [ 2, 4 .. Length( r ) ],
                       i -> r[i] in LeftActingDomain( RM ) )
           and ForAll( [ 1, 3 .. Length( r ) - 1 ],
                       i -> r[i] in UnderlyingMagma( RM ) );
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
    emb := Objectify( KindOfDefaultGeneralMapping( R, RM,
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
    return [ FreeMagmaRingElement( F, Zero( elm ), [ elm ],
                 [ One( UnderlyingMagma( Range( emb ) ) ) ] ) ];
    end );


InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsFreeMagmaRingObjDefaultRep ], 0,
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= elm![2];
    if     Length( extrep ) = 2
       and extrep[1] = One( UnderlyingMagma( R ) ) then
      return extrep[2];
    else
      Error( "<elm> is not in the image of <emb>" );
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
    emb := Objectify( KindOfDefaultGeneralMapping( M, RM,
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
    return [ FreeMagmaRingElement( F, Zero( LeftActingDomain( R ) ),
                 [ One( LeftActingDomain( R ) ) ], [ elm ] ) ];
    end );


InstallMethod( PreImagesElm,
    FamRangeEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsFreeMagmaRingObjDefaultRep ], 0,
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= elm![2];
    if     Length( extrep ) = 2
       and extrep[2] = One( LeftActingDomain( R ) ) then
      return extrep[1];
    else
      return fail;
    fi;
    end );


#############################################################################
##
#E  mgmring.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



