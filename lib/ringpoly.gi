#############################################################################
##
#W  ringpoly.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods  for attributes, properties and operations
##  for polynomial rings.
##
Revision.ringpoly_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  PolynomialRing( <ring>, <rank> )  . . .  full polynomial ring over a ring
##
#T polynomial rings should be special cases of free magma rings!  one needs
#T to set an underlying magma with one, and modify the kind to be
#T UnitalAlgebra and FreeMagmaUnitalRing.  (for example, ring generators in
#T the case of polynomial rings over finite fields are then automatically
#T computable ...)
##

#############################################################################
InstallMethod( PolynomialRing,
    true,
    [ IsRing,
      IsList ],
    0,

function( r, n )
    local   efam,  rfun,  zero,  one,  ind,  i,  kind,  prng;

    # get the elements family of the ring
    efam := ElementsFamily( FamilyObj(r) );

    # get the rational functions of the elements family
    rfun := RationalFunctionsFamily(efam);

    # first the indeterminates
    zero := Zero(r);
    one  := One(r);
    ind  := [];
    for i  in n  do
        Add( ind, UnivariatePolynomialByCoefficients(efam,[zero,one],i) );
    od;

    # construct a polynomial ring
    kind := IsPolynomialRing and IsAttributeStoringRep and IsFreeLeftModule;
    if Length(n) = 1 and HasIsField(r) and IsField(r)  then
        kind := kind and IsUnivariatePolynomialRing and IsEuclideanRing
                     and IsUnitalAlgebra;
    elif Length(n) = 1 and IsUnitalRing(r) then
        kind := kind and IsUnivariatePolynomialRing and IsUnitalFLMLOR;
    elif Length(n) = 1  then
        kind := kind and IsUnivariatePolynomialRing;
    fi;

    # set categories to allow method selection according to base ring
    if HasIsField(r) and IsField(r) then
        if IsFinite(r) then
            kind := kind and IsFiniteFieldPolynomialRing;
        elif IsRationals(r) then
            kind := kind and IsRationalsPolynomialRing;
        fi;
    fi;
    prng := Objectify( NewKind( CollectionsFamily(rfun), kind ), rec() );

    # set the left acting domain
    SetLeftActingDomain( prng, r );

    # set the indeterminates
    SetIndeterminatesOfPolynomialRing( prng, ind );

    # set known properties
    SetIsFinite( prng, false );
    SetIsFiniteDimensional( prng, false );
    SetSize( prng, infinity );

    # set the coefficients ring
    SetCoefficientsRing( prng, r );

    # set one and zero
    SetOne(  prng, ind[1]^0 );
    SetZero( prng, ind[1]*Zero(r) );

    # set the generators left operator unital ring if the rank is one
    if IsUnitalRing(r) then
        SetGeneratorsOfLeftOperatorUnitalRing( prng, ind );
    fi;

    # and return
    return prng;

end );


#############################################################################
InstallMethod( PolynomialRing,
    true,
    [ IsRing,
      IsInt and IsPosRat ],
    0,

function( r, n )
    if n = 1  then
        return UnivariatePolynomialRing(r);
    else
        return PolynomialRing( r, [ 1 .. n ] );
    fi;
end );


#############################################################################
InstallOtherMethod( PolynomialRing,
    true,
    [ IsRing ],
    0,

function( r )
    return UnivariatePolynomialRing(r);
end );


#############################################################################
##
#M  UnivariatePolynomialRing( <ring> )  . .  full polynomial ring over a ring
##
InstallMethod( UnivariatePolynomialRing,
    true,
    [ IsRing ],
    0,

function( r )
    return PolynomialRing( r, [1..1] );
end );


#############################################################################
##
#M  PrintObj( <pring> )
##
InstallMethod( PrintObj,
    true,
    [ IsPolynomialRing ],
    0,

function( obj )
    Print( "PolynomialRing( ..., ",
        Length(IndeterminatesOfPolynomialRing(obj)), " )" );
end );


#############################################################################
##

#M  Indeterminate( <ring> ) . . . . . . . . . . . . indeterminate over a ring
##
InstallMethod( Indeterminate,
    true,
    [ IsRing ],
    0,

function( ring )
    return IndeterminatesOfPolynomialRing(PolynomialRing(ring,1))[1];
end );


#############################################################################
##
#M  <poly> in <polyring>
##
InstallMethod( \in,
    "polynomial in polynomial ring",
    IsElmsColls,
    [ IsRationalFunction,
      IsPolynomialRing ],
    0,

function( p, R )
    local   ext,  crng,  inds,  exp,  i;

    # <p> must at least be a polynomial
    if not IsPolynomial(p)  then
        return false;
    fi;

    # get the external representation
    ext := ExtRepOfObj(NumeratorOfRationalFunction(p))[2];

    # and the indeterminates and coefficients ring of <R>
    crng := CoefficientsRing(R);
    inds := Set( List( IndeterminatesOfPolynomialRing(R),
                       x -> ExtRepOfObj(x)[2][1][1] ) );

    # first check the indeterminates
    for exp  in ext{[ 1, 3 .. Length(ext)-1 ]}  do
        for i  in exp{[ 1, 3 .. Length(exp)-1 ]}  do
            if not i in inds  then
                return false;
            fi;
        od;
    od;

    # then the coefficients
    for i  in ext{[ 2, 4 .. Length(ext) ]}  do
        if not i in crng  then
            return false;
        fi;
    od;
    return true;

end );


#############################################################################
##
#M  DefaultRingByGenerators( <gens> )   . . . .  ring containing a collection
##
InstallMethod( DefaultRingByGenerators,
    true,
    [ IsRationalFunctionCollection ],
    0,

function( gens )
    local   ind,  cfs,  g,  ext,  exp,  i;

    if not ForAll( gens, IsPolynomial )  then
        TryNextMethod();
    fi;
    ind := [];
    cfs := [];
    for g  in gens  do
        ext := ExtRepOfObj(NumeratorOfRationalFunction(g))[2];
        for exp  in ext{[ 1, 3 .. Length(ext)-1 ]}  do
            for i  in exp{[ 1, 3 .. Length(exp)-1 ]}  do
                AddSet( ind, i );
            od;
        od;
        for i  in ext{[ 2, 4 .. Length(ext) ]}  do
            Add( cfs, i );
        od;
    od;
    return PolynomialRing( DefaultField(cfs), ind );
    
end );


#############################################################################
##

#E  ringpoly.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
