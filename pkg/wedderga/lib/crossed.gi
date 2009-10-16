#############################################################################
##
#W  crossed.gi             The Wedderga package           Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              Ángel del Río
##
#H  $Id: crossed.gi,v 1.15 2008/01/03 14:43:22 alexk Exp $
##
#############################################################################


#############################################################################
##
#R  IsCrossedProductObjDefaultRep( <obj> )
##
##  The default representation of an element object is a list of length 2,
##  at first position the zero coefficient, at second position a list with
##  the coefficients at the even positions, and the magma elements at the
##  odd positions, with the ordering as defined for the magma elements.
##
##  It is assumed that the arithmetic operations of $G$ produce only
##  normalized elements.
##
DeclareRepresentation( "IsCrossedProductObjDefaultRep", 
    IsPositionalObjectRep,
    [ 1, 2 ] );


#############################################################################
##
#M  ElementOfCrossedProduct( <Fam>, <zerocoeff>, <coeffs>, <words> )
##
##  check whether <coeffs> and <words> lie in the correct domains,
##  and remove zeroes.
##
InstallMethod( ElementOfCrossedProduct,
    "for family, ring element, and two homogeneous lists",
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ],
    function( Fam, zerocoeff, coeffs, words )
    local rep, i, j;

    # Check that the data is admissible.
    if not IsBound( Fam!.defaultType ) then
      TryNextMethod();
    elif IsEmpty( coeffs ) and IsEmpty( words ) then
      return Objectify( Fam!.defaultType, [ zerocoeff, [] ] );
    elif not IsIdenticalObj( FamilyObj( coeffs ), Fam!.familyRing ) then
      Error( "<coeffs> are not all in the correct domain" );
    elif not IsIdenticalObj( FamilyObj( words ), Fam!.familyMagma ) then
      Error( "<words> are not all in the correct domain" );
    elif Length( coeffs ) <> Length( words ) then
      Error( "<coeffs> and <words> must have same length" );
    fi;

    # Make sure that the list of words is strictly sorted.
    if not IsSSortedList( words ) then
      words:= ShallowCopy( words );
      coeffs:= ShallowCopy( coeffs );
      SortParallel( words, coeffs );
      if not IsSSortedList( words ) then
        j:= 1;
        for i in [ 2 .. Length( coeffs ) ] do
          if words[i] = words[j] then
            coeffs[j]:= coeffs[j] + coeffs[i];
          else
            j:= j+1;
            words[j]:= words[i];
            coeffs[j]:= coeffs[i];
          fi;
        od;
        for i in [ j+1 .. Length( coeffs ) ] do
          Unbind( words[i] );
          Unbind( coeffs[i] );
        od;
      fi;
    fi;

    # Create the default representation, and remove zeros.
    rep:= [];
    j:= 1;
    for i in [ 1 .. Length( coeffs ) ] do
      if coeffs[i] <> zerocoeff then
        rep[  j  ]:= words[i];
        rep[ j+1 ]:= coeffs[i];
        j:= j+2;
      fi;
    od;

    # Return the result
    return Objectify( Fam!.defaultType, [ zerocoeff, rep ] );
    end );


#############################################################################
##
#M  ZeroCoefficient( <elm> )
##
InstallMethod( ZeroCoefficient,
    "for crossed product element in default repr.",
    [ IsElementOfCrossedProduct and IsCrossedProductObjDefaultRep ],
    elm -> FamilyObj( elm )!.zeroRing );


#############################################################################
##
#M  CoefficientsAndMagmaElements( <elm> )
##
InstallMethod( CoefficientsAndMagmaElements,
    "for crossed product element in default repr.",
    [ IsElementOfCrossedProduct and IsCrossedProductObjDefaultRep ],
    elm -> elm![2] );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . for crossed product element in default repr.
##
InstallMethod( PrintObj,
    "for crossed product element",
    [ IsElementOfCrossedProduct ],
    function( elm )

    local coeffs_and_words,
          i;

    coeffs_and_words:= CoefficientsAndMagmaElements( elm );
    for i in [ 1, 3 .. Length( coeffs_and_words ) - 3 ] do
      Print( "(", coeffs_and_words[i], ")*(", coeffs_and_words[i+1], ")+" );
    od;
    i:= Length( coeffs_and_words );
    if i = 0 then
      Print( "<zero> of ..." );
    else
      Print( "(", coeffs_and_words[i-1], ")*(", coeffs_and_words[i], ")" );
    fi;
    end );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . for two crossed product elements in default repr.
##
InstallMethod( \=,
    "for two crossed product elements",
    IsIdenticalObj,
    [ IsElementOfCrossedProduct,
      IsElementOfCrossedProduct ],
    function( x, y )
    return   CoefficientsAndMagmaElements( x )
           = CoefficientsAndMagmaElements( y );
    end );


#############################################################################
##
#M  \<( <x>, <y> )  . . . . for two crossed product elements in default repr.
##
InstallMethod( \<,
    "for two crossed product elements",
    IsIdenticalObj,
    [ IsElementOfCrossedProduct,
      IsElementOfCrossedProduct ],
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
#M  \+( <x>, <y> )  . . . . for two crossed product elements in default repr.
##
InstallMethod( \+,
    "for two crossed product elements",
    IsIdenticalObj,
    [ IsElementOfCrossedProduct,
      IsElementOfCrossedProduct ],
    function( x, y )
    local F, sum, z;
    F := FamilyObj( x );
    z := ZeroCoefficient( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );
    sum:= ZippedSum( x, y, z, [ \<, \+ ] );
    return Objectify( F!.defaultType, [ z, sum ] );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <x> ) . . for crossed product element in default repr.
##
InstallMethod( AdditiveInverseOp,
    "for crossed product element",
    [ IsElementOfCrossedProduct ],
    function( x )
    local ext, i;
    ext:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length( ext ) ] do
      ext[i]:= AdditiveInverse( ext[i] );
    od;
    return Objectify( FamilyObj( x )!.defaultType, [ ZeroCoefficient(x), ext] );
    end );


#############################################################################
##
#M  \*( <x>, <y> )  . . . . for two crossed product elements in default repr.
##
InstallMethod( \*,
    "for two crossed product elements",
    IsIdenticalObj,
    [ IsElementOfCrossedProduct,
      IsElementOfCrossedProduct ],
    function( x, y )
    local F, prod, z, mons, cofs, i, j, c, Twisting, Action, R;
    F := FamilyObj( x );
    Twisting := F!.twisting;
    Action := F!.action;
    R := F!.crossedProduct;
    z := ZeroCoefficient( x );
    x := CoefficientsAndMagmaElements( x );
    y := CoefficientsAndMagmaElements( y );

    # fold the product
    mons := [];
    cofs := [];
    for i  in [ 1, 3 .. Length(x)-1 ]  do
      for j  in [ 1, 3 .. Length(y)-1 ]  do
	# we compute product of the coefficients as follows 
        # (x * a1) * (y * a2) = (x) * (y) * a1^action(y) * a2 = 
        # (x * y) * twisting(x,y) *a1^action(y) * a2 
        c := Twisting(R,x[i],y[j]) * ( x[i+1]^Action(R,y[j]) * y[j+1] );
	    if c <> z  then
	      ##  add the product of the monomials
	      Add( mons, x[i] * y[j] );
	      ##  and the coefficient
	      Add( cofs, c );
	    fi;
      od;
    od;

    # sort monomials
    SortParallel( mons, cofs );

    # sum coeffs
    prod := [];
    i := 1;
    while i <= Length(mons)  do
      c := cofs[i];
      while i < Length(mons) and mons[i] = mons[i+1]  do
	      i := i+1;
	      c := c + cofs[i];    ##  add coefficients
      od;
      if c <> z  then
	      ## add the term to the product
	      Add( prod, mons[i] );
	      Add( prod, c );
      fi;
      i := i+1;
    od;

    return Objectify( F!.defaultType, [ z, prod ] );
    end );


#############################################################################
##
#M  OneOp( <elm> )
##
InstallMethod( OneOp,
    "for crossed product element",
    [ IsElementOfCrossedProduct ],
    function( elm )
    local F, z;
    F:= FamilyObj( elm );
    if not IsBound( F!.oneGroup ) then
      return fail;
    fi;
    z:= ZeroCoefficient( elm );
    return Objectify( F!.defaultType, [ z, [ F!.oneGroup, One( z ) ] ] );
    end );


#############################################################################
##
#M  ZeroOp( <elm> )
##
InstallMethod( ZeroOp,
    "for crossed product element",
    [ IsElementOfCrossedProduct ],
    x -> Objectify( FamilyObj(x)!.defaultType,
             [ ZeroCoefficient( x ), [] ] ) );


#############################################################################
##
#M  \*( x, r )  . . . . . . . . . for crossed product element and coefficient
#M  \*( x, r )  . . . . . . . . . .  for crossed product element and rational
##
##  We multiply an element of crossed product on the ring element from
##  the right, so action is not involved in this multiplication. Note that
##  multiplication with zero or zero divisors may cause zero coefficients
##  in the result, so we use FMRRemoveZero( <coeffs_and_words>, <zero> )
##  from lib/mgmring.gi. It removes all pairs from <coeffs_and_words> in
##  which the coefficient is <zero>, where <coeffs_and_words> is assumed
##  to be sorted.
##
CrossedElmTimesRingElm := function( x, y )
    local F, i, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] * y;
    od;
    return Objectify( F!.defaultType, [ z, FMRRemoveZero( x, z ) ] );
end;

InstallMethod( \*,
    "for crossed product element, and ring element",
    function( FamRM, FamR )
      return IsBound( FamRM!.familyRing )
        and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
    end,
    [ IsElementOfCrossedProduct, IsRingElement ],
    CrossedElmTimesRingElm );

InstallMethod( \*,
    "for crossed product element, and rational",
    [ IsElementOfCrossedProduct, IsRat ],
    CrossedElmTimesRingElm );


#############################################################################
##
#M  \*( <r>, <x> )  . .  . . . .  for coefficient and crossed product element
#M  \*( <r>, <x> )  . . . . . . . .  for rational and crossed product element
##
RingElmTimesCrossedElm := function( x, y )
    local F, i, z, Action, R;
    F:= FamilyObj( y );
    Action := F!.action;
    R := F!.crossedProduct;
    z:= ZeroCoefficient( y );
    y:= ShallowCopy( CoefficientsAndMagmaElements( y ) );
    # if x is rational, it will be fixed by action
    if IsRat( x ) then
      for i in [ 2, 4 .. Length(y) ] do
        y[i]:= x * y[i];
      od;
    else
      for i in [ 2, 4 .. Length(y) ] do
        y[i]:= x^Action(R,y[i-1]) * y[i];
      od;
    fi;
    return Objectify( F!.defaultType, [ z, FMRRemoveZero( y, z ) ] );
end;

InstallMethod( \*,
    "for ring element, and crossed product element",
    function( FamR, FamRM )
      return IsBound( FamRM!.familyRing )
        and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
    end,
    [ IsRingElement, IsElementOfCrossedProduct ],
    RingElmTimesCrossedElm );

InstallMethod( \*,
    "for rational, and crossed product element",
    [ IsRat, IsElementOfCrossedProduct ],
    RingElmTimesCrossedElm );


#############################################################################
##
#M  \*( <m>, <x> )  . . . . . . for group element and crossed product element
#M  \*( <x>, <m> )  . . . . . . for crossed product element and group element
##
InstallMethod( \*,
    "for group element and crossed product element",
    function( FamM, FamRM )
      return IsBound( FamRM!.familyMagma ) and
        IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
    end,
    [ IsMultiplicativeElement, IsElementOfCrossedProduct ],
    function( m, x )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    return Objectify( F!.defaultType, [ z, [ m, One(z) ] ] ) * x;
    end );

InstallMethod( \*,
    "for crossed product element and group element",
    function( FamRM, FamM )
      return IsBound( FamRM!.familyMagma ) and
        IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
    end,
    [ IsElementOfCrossedProduct, IsMultiplicativeElement ],
    function( x, m )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    return x * Objectify( F!.defaultType, [ z, [ m, One(z) ] ] );
    end );


#############################################################################
##
#M  \+( <m>, <x> )  . . . . . . for group element and crossed product element
#M  \+( <x>, <m> )  . . . . . . for crossed product element and group element
##
InstallOtherMethod( \+,
    "for group element and crossed product element",
    function( FamM, FamRM )
      return IsBound( FamRM!.familyMagma ) and
        IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
    end,
    [ IsMultiplicativeElement, IsElementOfCrossedProduct ],
    function( m, x )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ZippedSum( [ m, One( z ) ],
                   CoefficientsAndMagmaElements( x ),
                   z, [ \<, \+ ] );
    return Objectify( F!.defaultType, [ z, x ] );
    end );

InstallOtherMethod( \+,
    "for crossed product element and group element",
    function( FamRM, FamM )
      return IsBound( FamRM!.familyMagma ) and
        IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
    end,
    [ IsElementOfCrossedProduct, IsMultiplicativeElement ],
    function( x, m )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ZippedSum( CoefficientsAndMagmaElements( x ),
                   [ m, One( z ) ],
                   z, [ \<, \+ ] );
    return Objectify( F!.defaultType, [ z, x ] );
    end );


#############################################################################
##
#M  \-( <x>, <m> )  . . . . . . for crossed product element and group element
#M  \-( <m>, <x> )  . . . . . . for group element and crossed product element
##
InstallOtherMethod( \-,
    "for crossed product element and group element",
    function( FamRM, FamM )
      return IsBound( FamRM!.familyMagma ) and
        IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
    end,
    [ IsElementOfCrossedProduct, IsMultiplicativeElement ],
    function( x, m )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    return x - ElementOfCrossedProduct( F, z, [ One( z ) ], [ m ] );
    end );

InstallOtherMethod( \-,
    "for group element and crossed product element",
    function( FamM, FamRM )
      return IsBound( FamRM!.familyMagma ) and
        IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
    end,
    [ IsMultiplicativeElement, IsElementOfCrossedProduct ],
    function( m, x )
    local F, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    return ElementOfCrossedProduct( F, z, [ One( z ) ], [ m ] ) - x;
    end );


#############################################################################
##
#M  \/( x, r )  . . . . . . . . . for crossed product element and coefficient
##
CrossedElmDivRingElm := function( x, y )
    local F, i, z;
    F:= FamilyObj( x );
    z:= ZeroCoefficient( x );
    x:= ShallowCopy( CoefficientsAndMagmaElements( x ) );
    for i in [ 2, 4 .. Length(x) ] do
      x[i]:= x[i] / y;
    od;
    return Objectify( F!.defaultType, [ z, x ] );
end;

InstallOtherMethod( \/,
    "for crossed product element, and ring element",
    function( FamRM, FamR )
      return IsBound( FamRM!.familyRing )
        and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
    end,
    [ IsElementOfCrossedProduct, IsRingElement ],
    CrossedElmDivRingElm );

InstallMethod( \/,
    "for crossed product element, and integer",
    [ IsElementOfCrossedProduct, IsInt ],
    CrossedElmDivRingElm );
    
    
#############################################################################
##
#F  CrossedProduct( <R>, <G>, act, twist )
##
## An example of trivial action and twisting for the crossed product RG:
## action should return a mapping R->R that can be applied via "^" operation
##
##   function( RG, a )
##     return IdentityMapping( LeftActingDomain( RG ) );
##   end,
##
## twisting should return an (invertible) element of R
## 
##   function( RG, g, h )
##     return One( LeftActingDomain( RG ) );
##   end );
##
## to be used in the following way:
##
##   g * h = g * h * twisting(g,h)    for g,h in G
##   a * g = g * a^action(g)          for a in R and g in G
##
InstallGlobalFunction( CrossedProduct, 
function( R, G, act, twist )
    local filter,  # implied filter of all elements in the new domain
          F,       # family of crossed product elements
          one,     # identity of `R'
          zero,    # zero of `R'
          m,       # one element of `G'
          RG,      # free magma ring, result
          gens;    # generators of the magma ring

    # Check the arguments.
    if not IsRing( R ) or One( R ) = fail then
      Error( "<R> must be a ring with identity" );
    fi;
    
    if not IsGroup( G ) then
      Error( "<G> must be a group" );
    fi;

    F:= NewFamily( "CrossedProductObjFamily",
                   IsElementOfCrossedProduct,
                   IsMultiplicativeElementWithInverse and
                   IsAssociativeElement );

    one:= One( R );
    zero:= Zero( R );

    F!.defaultType := NewType( F, IsCrossedProductObjDefaultRep );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( G );
    F!.zeroRing    := zero;
    F!.oneGroup    := One( G );
    F!.action      := act;
    F!.twisting    := twist;

    # Set the characteristic.
    if HasCharacteristic( R ) or HasCharacteristic( FamilyObj( R ) ) then
      SetCharacteristic( F, Characteristic( R ) );
    fi;

    RG:= Objectify( NewType( CollectionsFamily( F ),
                            IsCrossedProduct and IsAttributeStoringRep ),
                      rec() );

    # Store RG in the family of its elements to make it possible
    # to extract from RG the data for action and twisting, stored 
    # in OperationRecord( RG )
    F!.crossedProduct := RG;

    # Set the necessary attributes.
    SetLeftActingDomain( RG, R );
    SetUnderlyingMagma(  RG, G );
    SetIsAssociative( RG, true );
       
    # Deduce other useful information.
    if HasIsFinite( G ) then
      SetIsFiniteDimensional( RG, IsFinite( G ) );
    fi;
    
    # What about IsCommutative ? In MagmaRings it is as below:   
    # if HasIsCommutative( R ) and HasIsCommutative( G ) then
    #   SetIsCommutative( RG, IsCommutative( R ) and IsCommutative( G ) );
    # fi;
    
    if HasIsWholeFamily( R ) and HasIsWholeFamily( G ) then
      SetIsWholeFamily( RG, IsWholeFamily( R ) and IsWholeFamily( G ) );
    fi;

    # Construct the generators. To get meaningful generators, 
    # we have to handle the case that the groups is trivial.
    
    gens:= GeneratorsOfGroup( G );
    if IsEmpty( gens ) then
      SetGeneratorsOfLeftOperatorRingWithOne( RG,
              [ ElementOfCrossedProduct( F, zero, [ one ], [ One( G ) ] ) ] );
    else
      SetGeneratorsOfLeftOperatorRingWithOne( RG,
        List( gens,
                x -> ElementOfCrossedProduct( F, zero, [ one ], [ x ] ) ) );
    fi;

    # Return the crossed product
    return RG;
end );


#############################################################################
##
#M  ViewObj( <RG> ) . . . . . . . . . . . . . . . . . . for a crossed product
##
InstallMethod( ViewObj,
    "for a crossed product",
    [ IsCrossedProduct ],
    10,
    function( RG )
    if HasCenterOfCrossedProduct(RG) then
      Print( "<crossed product with center ", CenterOfCrossedProduct(RG), 
             " over ", LeftActingDomain( RG ),
             " of a group of size ", Size(UnderlyingMagma(RG)), ">" );    
    else
      Print( "<crossed product over ", LeftActingDomain( RG ),
             " of a group of size ", Size(UnderlyingMagma(RG)), ">" );    
    fi;                  
    end );


#############################################################################
##
#M  PrintObj( <RG> )  . . . . . . . . . . . . . . . . . for a crossed product
##
InstallMethod( PrintObj,
    "for a crossed product",
    [ IsCrossedProduct ],
    10,
    function( RG )
    Print( "CrossedProduct( ", LeftActingDomain( RG ), ", ",
                               UnderlyingMagma(  RG ), " )" );
    end );


#############################################################################
##
#R  IsCanonicalBasisCrossedProductRep( <B> )
##
DeclareRepresentation( "IsCanonicalBasisCrossedProductRep",
    IsCanonicalBasis and IsAttributeStoringRep,
    [ "zerovector" ] );

        
#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . for canon. basis of crossed product
##
InstallMethod( Coefficients,
    "for canon. basis of a crossed product, and an element of a crossed product",
    IsCollsElms,
    [ IsCanonicalBasisCrossedProductRep, IsElementOfCrossedProduct ],
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
#M  Basis( <RG> ) . . . . . . . . . . . . . . . . . . . for a crossed product
##
InstallMethod( Basis,
    "for a crossed product (delegate to `CanonicalBasis')",
    [ IsCrossedProduct ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <RG> )  . . . . . . . . . . . . . . for a crossed product
##
InstallMethod( CanonicalBasis,
    "for a crossed product",
    [ IsCrossedProduct ],
    function( RG )

    local B, one, zero, F;

    F:= ElementsFamily( FamilyObj( RG ) );
    if not IsBound( F!.defaultType ) then
      TryNextMethod();
    fi;

    one  := One(  LeftActingDomain( RG ) );
    zero := Zero( LeftActingDomain( RG ) );

    B:= Objectify( NewType( FamilyObj( RG ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasisCrossedProductRep ),
                   rec() );

    SetUnderlyingLeftModule( B, RG );
    if IsFiniteDimensional( RG ) then
      SetBasisVectors( B,
          List( EnumeratorSorted( UnderlyingMagma( RG ) ),
                x -> ElementOfCrossedProduct( F, zero, [ one ], [ x ] ) ) );
      B!.zerovector:= List( BasisVectors( B ), x -> zero );
    fi;

    return B;
    end );


#############################################################################
##
#M  IsFinite( <RG> )  . . . . . . . . . . . . . . . . . for a crossed product
##
InstallMethod( IsFinite,
    "for a crossed product",
    [ IsCrossedProduct ],
    RG -> IsFinite( LeftActingDomain( RG ) ) and 
          IsFinite( UnderlyingMagma( RG ) ) );


#############################################################################
##
#M  Representative( <RG> )  . . . . . . . . . . . . . . for a crossed product
##
##  this is a quick-hack solution, should be replaced
##  
InstallMethod( Representative,
    "for a crossed product",
    [ IsCrossedProduct ],
    RG -> GeneratorsOfLeftOperatorRingWithOne(RG)[1] );
   

#############################################################################
##
#M  IsFiniteDimensional( <RG> ) . . . . . . . . . . . . for a crossed product
##
InstallMethod( IsFiniteDimensional,
    "for a crossed product",
    [ IsCrossedProduct ],
    RG -> IsFinite( UnderlyingMagma( RG ) ) );


#############################################################################
##
#M  ActionForCrossedProduct( <RG> ) . . . . . . . . . . for a crossed product
##
InstallMethod( ActionForCrossedProduct,
    "for a crossed product",
    [ IsCrossedProduct ],
    RG -> ElementsFamily(FamilyObj(RG))!.action );


#############################################################################
##
#M  TwistingForCrossedProduct( <RG> ) . . . . . . . . . . for a crossed product
##
InstallMethod( TwistingForCrossedProduct,
    "for a crossed product",
    [ IsCrossedProduct ],
    RG -> ElementsFamily(FamilyObj(RG))!.twisting );
    
    
#############################################################################
##
#R  IsEmbeddingRingCrossedProduct( <R>, <RM> )
##
DeclareRepresentation( "IsEmbeddingRingCrossedProduct",
        IsSPGeneralMapping
    and IsMapping
    and IsInjective
    and RespectsAddition
    and RespectsZero
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#M  Embedding( <R>, <RM> )  . . . . . . . . . .  for ring and crossed product
##
InstallMethod( Embedding,
    "for ring and crossed product",
    IsRingCollsMagmaRingColls,
    [ IsRing, IsCrossedProduct ],
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
                               IsEmbeddingRingCrossedProduct ),
                      rec() );

    # Return the embedding.
    return emb;
    end );


InstallMethod( ImagesElm,
    "for embedding of ring into crossed product, and ring element",
    FamSourceEqFamElm,
    [ IsEmbeddingRingCrossedProduct, IsRingElement ],
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return [ ElementOfCrossedProduct( F, Zero( elm ), [ elm ],
                 [ One( UnderlyingMagma( Range( emb ) ) ) ] ) ];
    end );

InstallMethod( ImagesRepresentative,
    "for embedding of ring into crossed product, and ring element",
    FamSourceEqFamElm,
    [ IsEmbeddingRingCrossedProduct, IsRingElement ],
    function ( emb, elm )
    local F;
    F:= ElementsFamily( FamilyObj( Range( emb ) ) );
    return ElementOfCrossedProduct( F, Zero( elm ), [ elm ],
               [ One( UnderlyingMagma( Range( emb ) ) ) ] );
    end );


InstallMethod( PreImagesElm,
    "for embedding of ring into crossed product, and crossed product element",
    FamRangeEqFamElm,
    [ IsEmbeddingRingCrossedProduct, IsElementOfCrossedProduct ],
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
    "for embedding of ring into crossed product, and crossed product element",
    FamRangeEqFamElm,
    [ IsEmbeddingRingCrossedProduct, IsElementOfCrossedProduct ],
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
#R  IsEmbeddingMagmaCrossedProduct( <M>, <RM> )
##
DeclareRepresentation( "IsEmbeddingMagmaCrossedProduct",
        IsSPGeneralMapping
    and IsMapping
    and IsInjective
    and IsAttributeStoringRep,
    [] );


#############################################################################
##
#F  Embedding( <M>, <RM> )  . . . . . . . . . . for magma and crossed product
##
InstallMethod( Embedding,
    "for magma and crossed product",
    IsMagmaCollsMagmaRingColls,
    [ IsMagma, IsCrossedProduct ],
    function( M, RM )

    local   emb;

    # Check that this is the right method.
    if not IsSubset( UnderlyingMagma( RM ), M ) then
      TryNextMethod();
    fi;

    # Make the mapping object.
    emb := Objectify( TypeOfDefaultGeneralMapping( M, RM,
                               IsEmbeddingMagmaCrossedProduct ),
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
    "for embedding of magma into crossed product, and mult. element",
    FamSourceEqFamElm,
    [ IsEmbeddingMagmaCrossedProduct, IsMultiplicativeElement ],
    function ( emb, elm )
    local R, F;
    R:= Range( emb );
    F:= ElementsFamily( FamilyObj( R ) );
    return [ ElementOfCrossedProduct( F, Zero( LeftActingDomain( R ) ),
                 [ One( LeftActingDomain( R ) ) ], [ elm ] ) ];
    end );

InstallMethod( ImagesRepresentative,
    "for embedding of magma into crossed product, and mult. element",
    FamSourceEqFamElm,
    [ IsEmbeddingMagmaCrossedProduct, IsMultiplicativeElement ],
    function ( emb, elm )
    local R, F;
    R:= Range( emb );
    F:= ElementsFamily( FamilyObj( R ) );
    return ElementOfCrossedProduct( F, Zero( LeftActingDomain( R ) ),
               [ One( LeftActingDomain( R ) ) ], [ elm ] );
    end );


InstallMethod( PreImagesElm,
    "for embedding of magma into crossed product, and crossed product element",
    FamRangeEqFamElm,
    [ IsEmbeddingMagmaCrossedProduct, IsElementOfCrossedProduct ],
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
    "for embedding of magma into crossed product, and crossed product element",
    FamRangeEqFamElm,
    [ IsEmbeddingMagmaCrossedProduct, IsElementOfCrossedProduct ],
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
#E
##