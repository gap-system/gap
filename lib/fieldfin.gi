#############################################################################
##
#W  fieldfin.gi                 GAP library                     Werner Nickel
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file    contains  methods for  finite  fields.    Note that  we must
##  distinguish finite fields and fields that  consist of 'FFE's.  (The image
##  of the natural embedding of the field  'GF(<q>)' into a field of rational
##  functions is of  course a finite field  but  its elements are  not 'FFE's
##  since this would be a property given by their family.)
##
##  Special methods for 'FFE's can be found in the file 'ffe.gi'.
##
Revision.fieldfin_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  GeneratorsOfLeftModule( <F> ) . . . .  the vectors of the canonical basis
##
InstallMethod( GeneratorsOfLeftModule, true, [ IsField and IsFinite ], 0,
    function( F )
    local z;
    z:= PrimitiveRoot( F );
    return List( [ 0 .. Dimension( F ) - 1 ], i -> z^i );
#T call of 'UseBasis' ?
    end );


#############################################################################
##
#M  Random( <F> ) . . . . . . . . . . . .  random element from a finite field
##
##  We have special methods for finite prime fields and for fields with
##  primitive root, for efficiency reasons.
##  All other cases are handled by the vector space methods.
##
InstallMethod( Random, true, [ IsField and IsPrimeField and IsFinite ], 0,
    F -> Random( [ 1 .. Size( F ) ] ) * One( F ) );

InstallMethod( Random, true,
    [ IsField and IsFinite and HasPrimitiveRoot ], 0,
    function ( F )
    local   rnd;
    rnd := Random( [ 0 .. Size( F ) - 1 ] );
    if rnd = 0  then
      rnd := Zero( F );
    else
      rnd := PrimitiveRoot( F )^rnd;
    fi;
    return rnd;
    end );


#############################################################################
##
#R  IsBasisFiniteField( <F> )
##
##  Bases of finite fields in internal representation are treated in a
##  special way.
##
IsBasisFiniteField := NewRepresentation( "IsBasisFiniteField",
    IsBasis and IsAttributeStoringRep,
    [ "inverseBase", "d", "q" ] );


#############################################################################
##
#M  BasisOfDomain( <F> )
##
##  We know a canonical basis for finite fields.
##
InstallMethod( BasisOfDomain, true, [ IsField and IsFinite ], 0,
    CanonicalBasis );


#############################################################################
##
#M  NewBasis( <F>, <gens> )
##
InstallMethod( NewBasis, IsIdentical,
    [ IsField and IsFinite, IsFFECollection ], 0,
    function( F, gens )
    local B;
    B:= Objectify( NewKind( FamilyObj( gens ), IsBasisFiniteField ),
                   rec() );
    SetUnderlyingLeftModule( B, F );
    SetBasisVectors( B, gens );
    return B;
    end );


#############################################################################
##
#M  BasisByGenerators( <F>, <gens> )
#M  BasisByGeneratorsNC( <F>, <gens> )
##
InstallMethod( BasisByGenerators, IsIdentical,
    [ IsField and IsFinite, IsHomogeneousList ], 0,
    function( F, gens )

    local B,     # the basis, result
          q,     # size of the subfield
          d,     # dimension of the extension
          mat,
          b,
          cnjs,
          k;

    # Set up the basis object.
    B:= NewBasis( F, gens );

    # Get the size 'q' of the subfield and the dimension 'd'
    # of the extension with respect to the subfield.
    q:= Size( LeftActingDomain( F ) );
    d:= Dimension( F );

    # Test that the basis vectors really define the
    # (unique) finite field extension of degree 'd'.
    if d <> Length( gens ) then
      return fail;
    fi;

    # Build the matrix 'M[i][k] = vectors[i]^(q^k)'.
    mat:= [];
    for b in gens do
      cnjs := [];
      for k in [ 0 .. d-1 ] do
        Add( cnjs, b^(q^k) );
      od;
      Add( mat, cnjs );
    od;

    # It is a basis if and only if 'mat' is invertible.
    if DeterminantMat( mat ) = Zero( F ) then
      return fail;
    fi;

    # Add the coefficients information.
    B!.inverseBase:= mat ^ (-1);
#T cheaper possibility? (after calling det.)
    B!.d:= d;
    B!.q:= q;

    # Return the basis.
    return B;
    end );

InstallMethod( BasisByGeneratorsNC, IsIdentical,
    [ IsField and IsFinite, IsHomogeneousList ], 10,
    function( F, gens )

    local B,     # the basis, result
          q,     # size of the subfield
          d,     # dimension of the extension
          mat,
          b,
          cnjs,
          k;

    # Set up the basis object.
    B:= NewBasis( F, gens );

    # Get the size 'q' of the subfield and the dimension 'd'
    # of the extension with respect to the subfield.
    q:= Size( LeftActingDomain( F ) );
    d:= Dimension( F );

    # Build the matrix 'M[i][k] = vectors[i]^(q^k)'.
    mat:= [];
    for b in gens do
      cnjs := [];
      for k in [ 0 .. d-1 ] do
        Add( cnjs, b^(q^k) );
      od;
      Add( mat, cnjs );
    od;

    # Add the coefficients information.
    B!.inverseBase:= mat ^ (-1);
    B!.d:= d;
    B!.q:= q;

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  Coefficents( <B>, <z> ) . . . . . . . . . . . for basis of a finite field
##
InstallMethod( Coefficients,
    "method for a basis of a finite field, and a scalar",
    IsCollsElms,
    [ IsBasis and IsBasisFiniteField, IsScalar ], 0,
    function ( B, z )
    local   q, d, k, zz;

    if   not z in UnderlyingLeftModule( B ) then
      return fail;
    fi;

    # Get the size 'q' of the subfield and the degree 'd' of the extension
    # with respect to the subfield.
    q := B!.q;
    d := B!.d;

    # Compute the vector of conjugates of 'z'.
    zz := [];
    for k  in [0..d-1]  do
        Add( zz, z^(q^k) );
    od;

    # The 'inverseBase' component of the basis defines the base change
    # to the normal basis.
    return zz * B!.inverseBase;
    end );


#############################################################################
##
#M  LinearCombination( <B>, <coeffs> )
##
InstallMethod( LinearCombination, IsIdentical,
    [ IsBasisFiniteField, IsHomogeneousList ], 0,
    function ( B, coeffs )
    return coeffs * BasisVectors( B );
    end );


#############################################################################
##
#M  CanonicalBasis( <F> )
##
##  The canonical basis of the finite field with $p^n$ elements, viewed over
##  its subfield with $p^d$ elements, consists of the vectors '<z> ^ <i>',
##  $0 \leq i \< n/d$, where <z> is the primitive root of <F>.
##
InstallMethod( CanonicalBasis, true, [ IsField and IsFinite ], 0,
    function( F )

    local z,         # primitive root
          B;         # basis record, result

    z:= PrimitiveRoot( F );
    B:= BasisByGeneratorsNC( F, List( [ 0 .. Dimension( F ) - 1 ],
                                      i -> z ^ i ) );
    SetIsCanonicalBasis( B, true );

    # Return the basis object.
    return B;
    end );


#############################################################################
##
#R  IsFrobeniusAutomorphism( <obj> )  . test if an object is a Frobenius aut.
##
IsFrobeniusAutomorphism := NewRepresentation( "IsFrobeniusAutomorphism",
        IsFieldHomomorphism
    and IsMapping
    and IsMultiplicativeElementWithInverse
    and IsAttributeStoringRep,
    [ "power" ] );


#############################################################################
##
#F  FrobeniusAutomorphism(<F>)  . .  Frobenius automorphism of a finite field
##
FrobeniusAutomorphismI := function ( F, i )

    local Fam, frob;

    # Catch the bad case.
    if Size( F ) = 2 then
      i:= 1;
    else
      i:= i mod ( Size( F ) - 1 );
    fi;

    if i = 1 then
      return IdentityMapping( F );
    fi;

    Fam:= ElementsFamily( FamilyObj( F ) );

    # make the mapping object
    frob:= Objectify( KindOfDefaultGeneralMapping( F, F,
                              IsFrobeniusAutomorphism
                          and IsSPGeneralMapping
                          and IsRingWithOneHomomorphism
                          and IsBijective ),
                      rec() );

    frob!.power := i;
#T make this a list object!!

    return frob;
end;

FrobeniusAutomorphism := function ( F )

    # check the arguments
    if not IsField( F ) or not IsPosRat( Characteristic( F ) ) then
        Error( "<F> must be a field of nonzero characteristic" );
    fi;

    # return the automorphism
    return FrobeniusAutomorphismI( F, Characteristic( F ) );
end;

InstallMethod( \=, IsIdentical,
    [ IsFrobeniusAutomorphism, IsFrobeniusAutomorphism ], 0,
    function ( aut1, aut2 )
    return Source( aut1 ) = Source( aut2 ) and aut1!.power  = aut2!.power;
    end );

InstallMethod( \=, IsIdentical,
    [ IsMapping and IsOne, IsFrobeniusAutomorphism ], 0,
    function ( id, aut )
    return Source( id ) = Source( aut ) and aut!.power = 1;
#T ReturnFalse?
    end );

InstallMethod( \=, IsIdentical,
    [ IsFrobeniusAutomorphism, IsMapping and IsOne ], 0,
    function ( aut, id )
    return Source( id ) = Source( aut ) and aut!.power = 1;
#T ReturnFalse?
    end );

InstallMethod( ImageElm, FamSourceEqFamElm,
    [ IsFrobeniusAutomorphism, IsObject ], 0,
    function ( aut, elm )
    return elm ^ aut!.power;
    end );

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsFrobeniusAutomorphism, IsObject ], 0,
    function ( aut, elm )
    return [ elm ^ aut!.power ];
    end );

InstallMethod( ImagesSet, CollFamSourceEqFamElms,
    [ IsFrobeniusAutomorphism, IsField ], 0,
    function ( aut, elms )
    if IsSubset( Source( aut ), elms )  then
      return elms;
    else
      Error( "<elms> must lie in the source of <aut>" );
    fi;
    end );

InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsFrobeniusAutomorphism, IsObject ], 0,
    function ( aut, elm )
    return elm ^ aut!.power;
    end );

InstallMethod( CompositionMapping2, IsIdentical,
    [ IsFrobeniusAutomorphism, IsFrobeniusAutomorphism ], 0,
    function ( aut1, aut2 )
    if Characteristic( Source( aut1 ) )
       = Characteristic( Source( aut2 ) ) then
      return FrobeniusAutomorphismI( Source( aut1 ),
                                     aut1!.power * aut2!.power );
    else
      Error( "Frobenius automorphisms of different characteristics" );
    fi;
    end );

InstallMethod( Inverse, true, [ IsFrobeniusAutomorphism ], 0,
    aut -> FrobeniusAutomorphismI( Source( aut ),
                                   Size( Source( aut ) ) / aut!.power ) );

InstallMethod( \^, true, [ IsFrobeniusAutomorphism, IsInt ], 0,
    function ( aut, i )
    return FrobeniusAutomorphismI( Source( aut ),
                   PowerModInt( aut!.power, i, Size( Source( aut ) ) - 1 ) );
    end );

InstallMethod( \<, IsIdentical,
    [ IsMapping and IsOne, IsFrobeniusAutomorphism ], 0,
    function ( id, aut )
    local source1, # source of 'id'
          source2, # source of 'aut'
          p,       # characteristic
          root,    # primitive root of source
          size,    # size of source
          d,       # degree
          gen;     # generator of cyclic group of subfield

    source1:= Source( id );
    source2:= Source( aut );
    if source1 <> source2 then
      return source1 < source2;
    elif    PrimitiveRoot( source1 )
         <> PrimitiveRoot( source2 ) then
      return   PrimitiveRoot( source1 )
             < PrimitiveRoot( source2 );
#T o.k.?
    else
        p := Characteristic( source1 );
        root:= PrimitiveRoot( source1 );
        size:= Size( source1 );
        for d  in DivisorsInt( LogInt( size, p ) )  do
            gen:= root^( ( size - 1 ) / ( p^d - 1 ) );
            if gen <> gen ^ aut!.power  then
                return gen < gen ^ aut!.power;
            fi;
        od;
        return false;
    fi;
    end );

InstallMethod( \<, IsIdentical,
    [ IsFrobeniusAutomorphism, IsMapping and IsOne ], 0,
    function ( aut, id )
    local source1, # source of 'aut'
          source2, # source of 'id'
          p,       # characteristic
          root,    # primitive root of source
          size,    # size of source
          d,       # degree
          gen;     # generator of cyclic group of subfield

    source1:= Source( aut );
    source2:= Source( id );
    if source1 <> source2 then
      return source1 < source2;
    elif    PrimitiveRoot( source1 )
         <> PrimitiveRoot( source2 ) then
      return   PrimitiveRoot( source1 )
             < PrimitiveRoot( source2 );
#T o.k.?
    else
        p := Characteristic( source1 );
        root:= PrimitiveRoot( source1 );
        size:= Size( source1 );
        for d  in DivisorsInt( LogInt( size, p ) )  do
            gen:= root^( ( size - 1 ) / ( p^d - 1 ) );
            if gen ^ aut!.power <> gen then
                return gen ^ aut!.power < gen;
            fi;
        od;
        return false;
    fi;
    end );

InstallMethod( \<, IsIdentical,
    [ IsFrobeniusAutomorphism, IsFrobeniusAutomorphism ], 0,
    function ( aut1, aut2 )
    local source1, # source of 'aut1'
          source2, # source of 'aut2'
          p,       # characteristic
          root,    # primitive root of source
          size,    # size of source
          d,       # degree
          gen;     # generator of cyclic group of subfield

    source1:= Source( aut1 );
    source2:= Source( aut2 );
    if source1 <> source2 then
      return source1 < source2;
    elif    PrimitiveRoot( source1 )
         <> PrimitiveRoot( source2 ) then
      return   PrimitiveRoot( source1 )
             < PrimitiveRoot( source2 );
#T o.k.?
    else
        p := Characteristic( source1 );
        root:= PrimitiveRoot( source1 );
        size:= Size( source1 );
        for d  in DivisorsInt( LogInt( size, p ) )  do
            gen:= root^( ( size - 1 ) / ( p^d - 1 ) );
            if gen ^ aut1!.power <> gen ^ aut2!.power  then
                return gen ^ aut1!.power < gen ^ aut2!.power;
            fi;
        od;
        return false;
    fi;
    end );

InstallMethod( PrintObj, true, [ IsFrobeniusAutomorphism ], 0,
    function ( aut )
    if aut!.power = Characteristic( Source( aut ) ) then
        Print( "FrobeniusAutomorphism( ", Source( aut ), " )" );
    else
        Print( "FrobeniusAutomorphism( ", Source( aut ), " )^",
               LogInt( aut!.power, Characteristic( Source( aut ) ) ) );
    fi;
    end );


#############################################################################
##
#M  GaloisGroup( <F> )  . . . . . . . . . . .  Galois group of a finite field
##
InstallMethod( GaloisGroup, true, [ IsField and IsFinite ], 0,
    F -> Group( FrobeniusAutomorphismI( F, Size( LeftActingDomain(F) ) ) ) );


#############################################################################
##
#M  MinimalPolynomial( <F>, <z> )
##
InstallMethod( MinimalPolynomial,
    "finite field and finite field element",
    IsCollsElms,
    [ IsField and IsFinite,
      IsScalar ],
    0,

function( F, z )
    local   df,  dz,  q,  dd,  pol,  deg,  con,  i;

    # get the field in which <z> lies
    df := DegreeOverPrimeField(F);
    dz := DegreeOverPrimeField(DefaultField(z));
    q  := Size(F);
    dd := LcmInt(df,dz) / df;

    # compute the minimal polynomial simply by multiplying $x-cnj$
    pol := [ One(F) ];
    deg := 0;
    for con  in Set( List( [ 0 .. dd ], x -> z^(q^x) ) )  do
        pol[deg+2] := pol[deg+1];
        for i  in [ deg+1, deg .. 2 ]  do
            pol[i] := pol[i-1] -  con*pol[i];
        od;
        pol[1] := -con*pol[1];
        deg := deg + 1;
    od;

    # return the coefficients list of the minimal polynomial
    return UnivariatePolynomial( LeftActingDomain( F ), pol );
end );


#############################################################################
##

#E  fieldfin.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



