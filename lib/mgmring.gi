#############################################################################
##
#W  mgmring.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for free magma rings and their elements.
##
Revision.mgmring_gi :=
    "@(#)$Id$";


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
InstallOtherMethod( FreeMagmaRingElement, true,
    [ IsFamily, IsRingElement, IsList, IsList ], 0,
    function( Fam, zerocoeff, coeff, words )
    local extrep, i;

    # Check that the data is admissible.
    if not IsIdentical( FamilyObj( coeff ), Fam!.familyRing ) then
      Error( "<coeff> are not all in the correct domain" );
    fi;
    if not IsIdentical( FamilyObj( words ), Fam!.familyMagma ) then
      Error( "<words> are not all in the correct domain" );
    fi;
    if Length( coeff ) <> Length( words ) then
      Error( "<coeff> and <words> must have same length" );
    fi;

    # Create the external representation.
    extrep:= [];
    for i in [ 1 .. Length( coeff ) ] do
      extrep[ 2*i-1 ]:= words[i];
      extrep[ 2*i   ]:= coeff[i];
    od;

    # Remove all words with zero coefficients.
    return ObjByExtRep( Fam,
             [ zerocoeff, FMRRemoveZero( extrep, Fam!.zeroRing ) ] );
    end );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> )
##
InstallMethod( ObjByExtRep, true,
    [ IsFreeMagmaRingObjFamily, IsList ], 0,
    function( Fam, descr )
    return Objectify( Fam!.defaultKind, descr );
    end );


#############################################################################
##
#M  ExtRepOfObj( <elm> )
##
InstallMethod( ExtRepOfObj, true, [ IsFreeMagmaRingObj ], 0,
    elm -> elm![1] );


#############################################################################
##
#M  PrintObj( <elm> )
##
InstallMethod( PrintObj, true, [ IsFreeMagmaRingObj ], 0,
    function( elm )

    local coeffs_and_words,
          i;

    coeffs_and_words:= ExtRepOfObj( elm );
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
#M  \=( <x>, <y> )
#M  \<( <x>, <y> )
#M  \+( <x>, <y> )
#M  \-( <x>, <y> )
#M  \*( <x>, <y> )
##
##  operators with left *and* right operands in the free magma ring family
##
InstallMethod( \=, IsIdentical, [ IsFreeMagmaRingObj, IsFreeMagmaRingObj ],0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );

InstallMethod( \<, IsIdentical, [ IsFreeMagmaRingObj, IsFreeMagmaRingObj ],0,
    function( x, y )
    local i;
    x:= ExtRepOfObj( x );
    y:= ExtRepOfObj( y );
    for i in [ 1 .. Minimum( Length( x ), Length( y ) ) ] do
      if   x[i] < y[i] then
        return true;
      elif y[i] < x[i] then
        return false;
      fi;
    od;
    return Length( x ) <= Length( y );
    end );
#T change ??

InstallMethod( \+, IsIdentical, [ IsFreeMagmaRingObj, IsFreeMagmaRingObj ],0,
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
    x    := ExtRepOfObj( x )[2];
    y    := ExtRepOfObj( y )[2];

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

    return ObjByExtRep( F, [ zero, coeff ] );
    end );


InstallMethod( AdditiveInverse, true, [ IsFreeMagmaRingObj ], 0,
    function( x )
    local ext, i;
    ext:= ShallowCopy( ExtRepOfObj( x ) );
    for i in [ 2, 4 .. Length( ext[2] ) ] do
      ext[2][i]:= AdditiveInverse( ext[2][i] );
    od;
    return ObjByExtRep( FamilyObj( x ), ext );
    end );


InstallMethod( \*, IsIdentical, [ IsFreeMagmaRingObj, IsFreeMagmaRingObj ],0,
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
    x := ExtRepOfObj( x )[2];
    y := ExtRepOfObj( y )[2];

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
    return ObjByExtRep( F,
                      [ F!.zeroRing, FMRRemoveZero( coeff, F!.zeroRing ) ] );
    end );


#############################################################################
##
#F  MagmaRingRing( <FamRM>, <FamR> )
#F  RingMagmaRing( <FamR>, <FamRM> )
#F  MagmaMagmaRing( <FamM>, <FamRM> )
##
MagmaRingRing := function( FamRM, FamR )
    return     IsBound( FamRM!.familyRing )
           and IsIdentical( ElementsFamily( FamRM!.familyRing ), FamR );
end;

RingMagmaRing := function( FamR, FamRM )
    return     IsBound( FamRM!.familyRing )
           and IsIdentical( ElementsFamily( FamRM!.familyRing ), FamR );
end;

MagmaMagmaRing := function( FamM, FamRM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdentical( ElementsFamily( FamRM!.familyMagma ), FamM );
end;
#T install multiplication with magma elements from left and right !


#############################################################################
##
#M  \*( x, r )
#M  \*( r, x )
#M  \/( x, r )
##
##  operations with only one operand in the free magma ring, and the other
##  in the family of the left acting ring.
##
    # Note that multiplication with zero or zero divisors
    # may cause zero coefficients in the result.
    # So we must normalize the elements.
#T (But we can avoid the argument check)
#T Should these two aspects be treated separately in general?
#T Should multiplication with zero be avoided (store the zero)?
#T Should the nonexistence of zero divisors be known/used?

ElmTimesRingElm := function( x, y )
    local F, i;
    F:= FamilyObj( x );
    x:= ShallowCopy( ExtRepOfObj( x )[2] );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] * y;
    od;
    return ObjByExtRep( F,
                        [ F!.zeroRing, FMRRemoveZero( x, F!.zeroRing ) ] );
end;

InstallMethod( \*, MagmaRingRing, [ IsFreeMagmaRingObj, IsRingElement ], 0,
    ElmTimesRingElm );

InstallMethod( \*, true, [ IsFreeMagmaRingObj, IsInt ], 0,
    ElmTimesRingElm );

RingElmTimesElm := function( x, y )
    local F, i;
    F:= FamilyObj( y );
    y:= ShallowCopy( ExtRepOfObj( y )[2] );
    for i in [ 2, 4 .. Length(y) ] do
      y[i]:= x * y[i];
    od;
    return ObjByExtRep( F,
                        [ F!.zeroRing, FMRRemoveZero( y, F!.zeroRing ) ] );
end;

InstallMethod( \*, RingMagmaRing, [ IsRingElement, IsFreeMagmaRingObj ],0,
    RingElmTimesElm );

InstallMethod( \*, true, [ IsInt, IsFreeMagmaRingObj ],0,
    RingElmTimesElm );

ElmDivRingElm := function( x, y )
    local F, i;
    F:= FamilyObj( x );
    x:= ShallowCopy( ExtRepOfObj( x )[2] );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] / y;
    od;
    return ObjByExtRep( F, [ F!.zeroRing, x ] );
end;

InstallOtherMethod( \/, MagmaRingRing, [ IsFreeMagmaRingObj, IsRingElement ],
    0, ElmDivRingElm );

InstallMethod( \/, true, [ IsFreeMagmaRingObj, IsInt ],0,
    ElmDivRingElm );


#############################################################################
##
#M  Inverse( <elm> ) . . . . . . . . . . inverse of a free magma ring element
##
InstallMethod( Inverse, true,
    [ IsFreeMagmaRingObj and IsMultiplicativeElementWithInverse ], 0,
    function( elm )
    local F;
    F:= FamilyObj( elm );
    elm:= ExtRepOfObj( elm );
    if Length( elm ) = 2 then
      return ObjByExtRep( F, [ F!.zeroRing, [ elm[1]^-1, elm[2]^-1 ] ] );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  One( <elm> )
##
InstallMethod( One, true, [ IsFreeMagmaRingObj ], 0,
    function( elm )
    local F, zerocoeff;
    F:= FamilyObj( elm );
    zerocoeff:= F!.zeroRing;
    return ObjByExtRep( F, [ zerocoeff, [ One( zerocoeff ), One( F.familyMagma ) ] ] );
#T problem!!
    end );


#############################################################################
##
#M  Zero( <elm> )
##
InstallMethod( Zero, true, [ IsFreeMagmaRingObj ], 0,
    x -> ObjByExtRep( FamilyObj(x), [ FamilyObj(x)!.zeroRing, [] ] ) );


#############################################################################
##
#M  Print( <R> )
##
InstallMethod( PrintObj, true, [ IsFreeMagmaRing ], 0,
    function( R )
    Print( "FreeMagmaRing( ", LeftActingDomain( R ), ", ",
                              UnderlyingMagma( R ), " )" );
    end );


#############################################################################
##
#M  GeneratorsOfLeftOperatorRing( <RM> )
#M  GeneratorsOfLeftOperatorUnitalRing( <RM> )
##
InstallMethod( GeneratorsOfLeftOperatorRing, true, [ IsFreeMagmaRing ], 0,
    function( RM )
    local one, F;
    one:= One( LeftActingDomain( RM ) );
    F:= ElementsFamily( FamilyObj( RM ) );
    return List( GeneratorsOfMagma( UnderlyingMagma( RM ) ),
                 x -> ObjByExtRep( F, [ F!.zeroRing, [ x, one ] ] ) );
    end );

InstallMethod( GeneratorsOfLeftOperatorUnitalRing, true,
    [ IsFreeMagmaUnitalRing ], 0,
    function( RM )
    local one, F;
    one:= One( LeftActingDomain( RM ) );
    F:= ElementsFamily( FamilyObj( RM ) );
    return List( GeneratorsOfMagmaWithOne( UnderlyingMagma( RM ) ),
                 x -> ObjByExtRep( F, [ F!.zeroRing, [ x, one ] ] ) );
    end );


#############################################################################
##
#F  FreeMagmaRing( <R>, <M> )
##
FreeMagmaRing := function( R, M )

    local F,   # family of magma ring elements
          RM;  # free magma ring, result

    # Check the arguments.
    if not IsRing( R ) or One( R ) = fail then
#T change?
      Error( "<R> must be a ring with multiplicative identity" );
    fi;

    # Construct the family of elements of our ring.
    if   IsMultiplicativeElementWithInverseCollection( M ) then
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsFreeMagmaRingObj,
                     IsMultiplicativeElementWithInverse );
    elif IsMultiplicativeElementWithOneCollection( M ) then
      F:= NewFamily( "FreeMagmaRingObjFamily",
                     IsFreeMagmaRingObj,
                     IsMultiplicativeElementWithOne );
    else
      F:= NewFamily( "FreeMagmaRingObjFamily",
                      IsFreeMagmaRingObj,
                      IsMultiplicativeElement );
    fi;
#T how to improve?
    F!.defaultKind := NewKind( F, IsFreeMagmaRingObj );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( M );
    F!.zeroRing    := Zero( R );
#T no !!

    # Make the magma ring object.
    if IsMagmaWithOne( M ) then
      RM:= Objectify( NewKind( CollectionsFamily( F ),
                                   IsFreeMagmaUnitalRing
                               and IsAttributeStoringRep ),
                      rec() );
    else
      RM:= Objectify( NewKind( CollectionsFamily( F ),
                                   IsFreeMagmaRing
                               and IsAttributeStoringRep ),
                      rec() );
    fi;

    SetLeftActingDomain( RM, R );
    SetUnderlyingMagma(  RM, M );

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

    # Return the ring.
    return RM;
end;


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . for canon. basis of free magma ring
##
InstallMethod( Coefficients,
    "method for canon. basis of a free magma ring, and a vector",
    IsCollsElms,
    [ IsCanonicalBasisFreeMagmaRing, IsVector ], 0,
    function( B, v )

    local coeffs,
          data,
          elms,
          i;

    data:= ExtRepOfObj( v )[2];
    coeffs:= ShallowCopy( B!.zerovector );
    elms:= EnumeratorSorted( UnderlyingMagma( UnderlyingLeftModule( B ) ) );
    for i in [ 1, 3 .. Length( data )-1 ] do
      coeffs[ Position( elms, data[i] ) ]:= data[i+1];
    od;
    return coeffs;
    end );


#############################################################################
##
#M  BasisOfDomain( <RM> )
##
InstallMethod( BasisOfDomain, true, [ IsFreeMagmaRing ], 0,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <RM> )
##
InstallMethod( CanonicalBasis, true, [ IsFreeMagmaRing ], 0,
    function( RM )

    local B, one, zero, F;

    one  := One(  LeftActingDomain( RM ) );
    zero := Zero( LeftActingDomain( RM ) );

    B:= Objectify( NewKind( FamilyObj( RM ),
                                IsCanonicalBasisFreeMagmaRing
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, RM );
    F:= ElementsFamily( FamilyObj( RM ) );
    SetBasisVectors( B,
        List( EnumeratorSorted( UnderlyingMagma( RM ) ),
            x -> ObjByExtRep( F, [ F!.zeroRing, [ x, one ] ] ) ) );
    B!.zerovector:= List( BasisVectors( B ), x -> zero );

    return B;
    end );


#############################################################################
##
#M  IsFinite( <RM> )
##
InstallMethod( IsFinite, true, [ IsFreeMagmaRing ], 0,
    RM ->     IsFinite( LeftActingDomain( RM ) )
          and IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsFiniteDimensional( <RM> ) . . . . . . . . . . . . for a free magma ring
##
InstallMethod( IsFiniteDimensional,
    "method for a free magma ring",
    true,
    [ IsFreeMagmaRing and HasUnderlyingMagma ], 0,
    function( RM )
    RM:= UnderlyingMagma( RM );
    if HasIsFinite( RM ) then
      return IsFinite( RM );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsFiniteDimensional, true, [ IsFreeMagmaRing ], 0,
    RM -> IsFinite( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  Dimension( <RM> )
##
InstallMethod( Dimension, true, [ IsFreeMagmaRing ], 0,
    RM -> Size( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <RM> )
##
InstallMethod( GeneratorsOfLeftModule, true, [ IsFreeMagmaRing ], 0,
    function( RM )
    local F, one;
    if IsFiniteDimensional( RM ) then
      F:= ElementsFamily( FamilyObj( RM ) );
      one:= One( LeftActingDomain( RM ) );
      return List( Enumerator( UnderlyingMagma( RM ) ),
                   m -> ObjByExtRep( F, [ F!.zeroRing, [ m, one ] ] ) );
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
InstallMethod( Centre, true, [ IsGroupRing ], 0,
    function( RG )

    local F,     # family of elements of 'RG'
          one,   # identity of the coefficients ring
          ccl,   # conjugacy classes of the group
          gens,  # list of (module) generators of the result
          c,     # loop over 'ccl'
          elms,  # set of elements of a conjugacy class
          elm,
          i;

    if not IsFiniteDimensional( RG ) then
      TryNextMethod();
    fi;
    F:= ElementsFamily( FamilyObj( RG ) );
    one:= One( LeftActingDomain( RG ) );
    ccl:= ConjugacyClasses( UnderlyingMagma( RG ) );
    gens:= [];
    for c in ccl do
      elms:= EnumeratorSorted( c );
      elm:= [];
      for i in [ 1 .. Length( elms ) ] do
        elm[ 2*i-1 ]:= elms[i]; 
        elm[ 2*i   ]:= one;
      od;
      Add( gens, ObjByExtRep( F, [ F!.zeroRing, elm ] ) );
    od;
    return FLMLOR( Centre( LeftActingDomain( RG ) ), gens, "basis" );
    end );


#############################################################################
##
#M  \in( <r>, <RM> )
##
InstallMethod( \in, IsElmsColls, [ IsRingElement, IsFreeMagmaRing ], 0,
    function( r, RM )
    r:= ExtRepOfObj( r )[2];
    return     ForAll( [ 2, 4 .. Length( r ) ],
                       i -> r[i] in LeftActingDomain( RM ) )
           and ForAll( [ 1, 3 .. Length( r ) - 1 ],
                       i -> r[i] in UnderlyingMagma( RM ) );
    end );


#############################################################################
##
#M  IsAssociative( <RM> )
##
InstallMethod( IsAssociative, true, [ IsFreeMagmaRing ], 0,
    RM ->     IsAssociative( LeftActingDomain( RM ) )
          and IsAssociative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsCommutative( <RM> )
##
InstallMethod( IsCommutative, true, [ IsFreeMagmaRing ], 0,
    RM ->     IsCommutative( LeftActingDomain( RM ) )
          and IsCommutative( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  IsWholeFamily( <RM> )
##
InstallMethod( IsWholeFamily, true, [ IsFreeMagmaRing ], 0,
    RM ->     IsWholeFamily( LeftActingDomain( RM ) )
          and IsWholeFamily( UnderlyingMagma( RM ) ) );


#############################################################################
##
#M  GeneratorsOfRing( <RM> )
#M  GeneratorsOfUnitalRing( <RM> )
##
##  If the underlying magma has an identity and if we know ring generators
##  for the ring <R>, we take the left operator ring generators together
##  with the images of the ring generators under the natural embedding.
##
InstallMethod( GeneratorsOfRing, true, [ IsFreeMagmaRing ], 0,
    function( RM )
    local R, emb;
    R:= LeftActingDomain( RM );
    emb:= Embedding( R, RM );
    if emb <> fail then
      return Concatenation( GeneratorsOfLeftOperatorRing( RM ),
                            List( GeneratorsOfRing( R ),
                                  r -> ImageElm( emb, r ) ) );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( GeneratorsOfUnitalRing, true, [ IsFreeMagmaUnitalRing ], 0,
    function( RM )
    local R, emb;
    R:= LeftActingDomain( RM );
    emb:= Embedding( R, RM );
    if emb <> fail then
      return Concatenation( GeneratorsOfLeftOperatorUnitalRing( RM ),
                            List( GeneratorsOfUnitalRing( R ),
                                  r -> ImageElm( emb, r ) ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Embedding( <R>, <RM> )
##
InstallMethod( Embedding, RingMagmaRing, [ IsRing, IsFreeMagmaRing ], 0,
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

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsRingElement ], 0,
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return [ ObjByExtRep( F,
                 [ F!.zeroRing, [ One( UnderlyingMagma( Range( emb ) ) ), elm ] ] ) ];
    end );

#T InstallMethod( ImagesSet, true, [ IsEmbeddingRingMagmaRing, IsDomain ], 0,
#T     function ( emb, elms )
#T     ...
#T     end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsEmbeddingRingMagmaRing, IsFreeMagmaRingObj ], 0,
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= ExtRepOfObj( elm )[2];
    if     Length( extrep ) = 2
       and extrep[1] = One( UnderlyingMagma( R ) ) then
      return extrep[2];
    else
      Error( "<elm> is not in the image of <emb>" );
    fi;
    end );

#T InstallMethod( PreImagesSet, true, [ IsEmbeddingRingMagmaRing, IsDomain ], 0,
#T     function ( emb, elms )
#T     ...
#T     end );


#############################################################################
##
#F  Embedding( <M>, <RM> )
##
InstallMethod( Embedding, MagmaMagmaRing, [ IsMagma, IsFreeMagmaRing ], 0,
    function( M, RM )

    local   emb;

    # Check that this is the right method.
    if not Parent( M ) = UnderlyingMagma( RM ) then
      TryNextMethod();
    fi;

    # Make the mapping object.
    emb := Objectify( KindOfDefaultGeneralMapping( M, RM,
                               IsEmbeddingMagmaMagmaRing ),
                      rec() );

    # Return the embedding.
    return emb;
    end );

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsFreeMagmaRingObj ], 0,
    function ( emb, elm )
    local R, F;
    R:= Range( emb );
    F:= ElementsFamily( FamilyObj( R ) );
    return [ ObjByExtRep( F,
                          [ F!.zeroRing, [ elm, One( LeftActingDomain( R ) ) ] ] ) ];
    end );

#T InstallMethod( ImagesSet, true, [ IsEmbeddingMagmaMagmaRing, IsDomain ], 0,
#T     function ( emb, elms )
#T     ...
#T     end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsEmbeddingMagmaMagmaRing, IsFreeMagmaRingObj ], 0,
    function ( emb, elm )
    local R, extrep;
    R:= Range( emb );
    extrep:= ExtRepOfObj( elm )[2];
    if     Length( extrep ) = 2
       and extrep[2] = One( LeftActingDomain( R ) ) then
      return extrep[1];
    else
      Error( "<elm> is not in the image of <emb>" );
    fi;
    end );

#T InstallMethod( PreImagesSet, true, [ IsEmbeddingMagmaMagmaRing, IsDomain ], 0,
#T     function ( emb, elms )
#T     ...
#T     end );


#############################################################################
##
#E  mgmring.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



