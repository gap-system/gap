#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for Gaussian rationals and Gaussian integers.
##
##  Gaussian rationals are elements of the form $a + b * I$ where $I$ is the
##  square root of -1 and $a,b$ are rationals.
##  Note that $I$ is written as `E(4)', i.e., as a fourth root of unity in
##  {\GAP}.
##  Gauss was the first to investigate such numbers, and already proved that
##  the ring of integers of this field, i.e., the elements of the form
##  $a + b * I$ where $a,b$ are integers, forms a Euclidean Ring.
##  It follows that this ring is a Unique Factorization Domain.
##


#############################################################################
##
#V  GaussianIntegers  . . . . . . . . . . . . . . . ring of Gaussian integers
##
BindGlobal( "GaussianIntegers", Objectify( NewType(
    CollectionsFamily(CyclotomicsFamily),
    IsGaussianIntegers and IsAttributeStoringRep ),
    rec() ) );

SetLeftActingDomain( GaussianIntegers, Integers );
SetName( GaussianIntegers, "GaussianIntegers" );
SetString( GaussianIntegers, "GaussianIntegers" );
SetIsLeftActedOnByDivisionRing( GaussianIntegers, false );
SetSize( GaussianIntegers, infinity );
SetGeneratorsOfRing( GaussianIntegers, [ E(4) ] );
SetGeneratorsOfLeftModule( GaussianIntegers, [ 1, E(4) ] );
SetIsFinitelyGeneratedMagma( GaussianIntegers, false );
SetUnits( GaussianIntegers, [ -1, 1, -E(4), E(4) ] );
SetIsWholeFamily( GaussianIntegers, false );


#############################################################################
##
#V  GaussianRationals . . . . . . . . . . . . . . field of Gaussian rationals
##
BindGlobal( "GaussianRationals", Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsGaussianRationals and IsAttributeStoringRep ), rec() ) );
SetName( GaussianRationals, "GaussianRationals" );
SetLeftActingDomain( GaussianRationals, Rationals );
SetIsPrimeField( GaussianRationals, false );
SetIsCyclotomicField( GaussianRationals, true );
SetSize( GaussianRationals, infinity );
SetConductor( GaussianRationals, 4 );
SetDimension( GaussianRationals, 2 );
SetDegreeOverPrimeField( GaussianRationals, 2 );
SetGaloisStabilizer( GaussianRationals, [ 1 ] );
SetGeneratorsOfLeftModule( GaussianRationals, [ 1, E(4) ] );
SetIsFinitelyGeneratedMagma( GaussianRationals, false );
SetIsWholeFamily( GaussianRationals, false );


#############################################################################
##
#M  \in( <n>, GaussianIntegers )  . . . membership test for Gaussian integers
##
##  Gaussian integers are of the form `<a> + <b> * E(4)', where <a> and <b>
##  are integers.
##
InstallMethod( \in,
    "for Gaussian integers",
    IsElmsColls,
    [ IsCyc, IsGaussianIntegers ],
    function( cyc, GaussianIntegers )
    return IsCycInt( cyc ) and 4 mod Conductor( cyc ) = 0;
    end );


#############################################################################
##
#M  Basis( GaussianIntegers ) . . . . . . . . . . . . . for Gaussian integers
##
InstallMethod( Basis,
    "for Gaussian integers (delegate to `CanonicalBasis')",
    [ IsGaussianIntegers ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( GaussianIntegers )  . . . . . . . . for Gaussian integers
##
DeclareRepresentation(
    "IsCanonicalBasisGaussianIntegersRep", IsAttributeStoringRep,
    [ "conductor", "zumbroichbase" ] );

InstallMethod( CanonicalBasis,
    "for Gaussian integers",
    [ IsGaussianIntegers ],
    function( GaussianIntegers )
    local B;

    B:= Objectify( NewType( FamilyObj( GaussianIntegers ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsCanonicalBasisGaussianIntegersRep ),
#T generalize this to integral rings of cyclotomics!
                   rec() );
    SetUnderlyingLeftModule( B, GaussianIntegers );
    SetIsIntegralBasis( B, true );
    SetBasisVectors( B, Immutable( [ 1, E(4) ] ) );
    B!.conductor:= 4;
    B!.zumbroichbase := [ 0, 1 ];

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  Coefficients( <B>, <z> )  . for the canon. basis of the Gaussian integers
##
InstallMethod( Coefficients,
    "for canon. basis of Gaussian integers, and cyclotomic",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisGaussianIntegersRep,
      IsCyc ],
    function( B, z )
    local N,
          coeffs,
          F;

    F:= UnderlyingLeftModule( B );
    if not z in F then return fail; fi;

    N:= B!.conductor;

    # Get the Zumbroich basis representation of <z> in `N'-th roots.
    coeffs:= CoeffsCyc( z, N );
    if coeffs = fail then return fail; fi;

    # Get the Zumbroich basis coefficients (basis $B_{n,1}$)
    coeffs:= coeffs{ B!.zumbroichbase + 1 };

    # Return the list of coefficients.
    return coeffs;
    end );


#############################################################################
##
#M  Quotient( GaussianIntegers, <n>, <m> )
##
InstallMethod( Quotient,
    "for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ],
    function ( GaussianIntegers, x, y )
    local   q;
    if y = 0 then
        return fail;
    fi;
    q := x / y;
    if not IsCycInt( q )  then
        q := fail;
    fi;
    return q;
    end );


#############################################################################
##
#M  StandardAssociateUnit( GaussianIntegers, <x> )  . . for Gaussian integers
##
##  The standard associate of <x> is an associated element <y> of <x> that
##  lies in the  first quadrant of the complex plane.
##  That is <y> is that element from `<x> * [1,-1,E(4),-E(4)]' that has
##  positive real part and nonnegative imaginary part.
##  (This is the generalization of `Abs' (see "Abs") for Gaussian integers.)
##
##  This function returns the unit <z> equal to <y> / <x>. The default
##  StandardAssociate method then uses this to compute the standard associate.
##
InstallMethod( StandardAssociateUnit,
    "for Gaussian integers",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ],
    function ( GaussianIntegers, x )
    if not IsGaussInt( x )  then
        Error( "<x> must lie in <GaussianIntegers>" );
    elif IsRat(x)  and 0 <= x  then
        return 1;
    elif IsRat(x)  then
        return -1;
    elif 0 <  COEFFS_CYC(x)[1]       and 0 <= COEFFS_CYC(x)[2]       then
        return 1;
    elif      COEFFS_CYC(x)[1] <= 0  and 0 <  COEFFS_CYC(x)[2]       then
        return -E(4);
    elif      COEFFS_CYC(x)[1] <  0  and      COEFFS_CYC(x)[2] <= 0  then
        return -1;
    else
        return E(4);
    fi;
    end );


#############################################################################
##
#M  EuclideanDegree( GaussianIntegers, <n> )
##
InstallMethod( EuclideanDegree,
    "for Gaussian integers",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ],
    function( GaussianIntegers, x )
    if IsGaussInt( x ) then
      return x * GaloisCyc( x, -1 );
    else
      Error( "<x> must lie in <GaussianIntegers>" );
    fi;
    end );


#############################################################################
##
#M  EuclideanRemainder( GaussianIntegers, <n>, <m> )
##
InstallMethod( EuclideanRemainder,
    "for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ],
    function ( GaussianIntegers, x, y )
    if IsGaussInt( x ) and IsGaussInt( y ) then
      return x - RoundCyc( x/y ) * y;
    else
      Error( "<x> and <y> must lie in <GaussianIntegers>" );
    fi;
    end );


#############################################################################
##
#M  EuclideanQuotient( GaussianIntegers, <x>, <y> )
##
InstallMethod( EuclideanQuotient,
    "for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ],
    function ( GaussianIntegers, x, y )
    if IsGaussInt( x ) and IsGaussInt( y ) then
      return RoundCyc( x/y );
    else
      Error( "<x> and <y> must lie in <GaussianIntegers>" );
    fi;
    end );


#############################################################################
##
#M  QuotientRemainder( GaussianIntegers, <x>, <y> )
##
InstallMethod( QuotientRemainder,
    "for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ],
    function ( GaussianIntegers, x, y )
    local   q;
    if IsGaussInt( x ) and IsGaussInt( y ) then
      q := RoundCyc(x/y);
      return [ q, x-q*y ];
    else
      Error( "<x> and <y> must lie in <GaussianIntegers>" );
    fi;
    end );


#############################################################################
##
#M  IsPrime( GaussianIntegers, <n> )
##
InstallMethod( IsPrime,
    "for Gaussian integers and integer",
    IsCollsElms,
    [ IsGaussianIntegers, IsInt ],
    function ( GaussianIntegers, x )
    return x mod 4 = 3  and IsPrimeInt( x );
    end );

InstallMethod( IsPrime,
    "for Gaussian integers and cyclotomic",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ],
    function ( GaussianIntegers, x )
    if IsGaussInt( x ) then
      return IsPrimeInt( x * GaloisCyc( x, -1 ) );
    else
      Error( "<x> must lie in <GaussianIntegers>" );
    fi;
    end );


#############################################################################
##
#M  Factors( GaussianIntegers, <x> )
##
InstallMethod( Factors,
    "for Gaussian integers",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ],
    function ( GaussianIntegers, x )
    local   facs,       # factors (result)
            prm,        # prime factors of the norm
            tsq;        # representation of `prm' as $x^2 + y^2$

    # handle trivial cases
    if x in [ 0, 1, -1, E(4), -E(4) ]  then
        return [ x ];
    elif not IsGaussInt( x ) then
        Error( "<x> must lie in <GaussianIntegers>" );
    fi;

    # loop over all factors of the norm of x
    facs := [];
    for prm in PrimeDivisors( EuclideanDegree( GaussianIntegers, x ) ) do

        # $p = 2$ and primes $p = 1$ mod 4 split according to $p = x^2 + y^2$
        if prm = 2  or prm mod 4 = 1  then
            tsq := TwoSquares( prm );
            while IsCycInt( x / (tsq[1]+tsq[2]*E(4)) )  do
                Add( facs, (tsq[1]+tsq[2]*E(4)) );
                x := x / (tsq[1]+tsq[2]*E(4));
            od;
            while IsCycInt( x / (tsq[2]+tsq[1]*E(4)) )  do
                Add( facs, (tsq[2]+tsq[1]*E(4)) );
                x := x / (tsq[2]+tsq[1]*E(4));
            od;

        # primes $p = 3$ mod 4 stay prime
        else
            while IsCycInt( x / prm )  do
                Add( facs, prm );
                x := x / prm;
            od;
        fi;

    od;

    Assert( 1, x in [ 1, -1, E(4), -E(4) ],
            "'Factors' for Gaussian integers: Cofactor must be a unit\n" );

    # the first factor takes the unit
    facs[1] := x * facs[1];

    # return the result
    return facs;
    end );
