#############################################################################
##
#W  gaussian.gi                 GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for Gaussian rationals and Gaussian integers.
##
##  Gaussian rationals are elements of the form $a + b * I$ where $I$ is the
##  square root of -1 and $a,b$ are rationals.
##  Note that $I$ is written as 'E(4)', i.e., as a fourth root of unity in
##  {\GAP}.
##  Gauss was the first to investigate such numbers, and already proved that
##  the ring of integers of this field, i.e., the elements of the form
##  $a + b * I$ where $a,b$ are integers, forms a Euclidean Ring.
##  It follows that  this ring is a Unique Factorization Domain.
##
##
Revision.gaussian_gi :=
    "@(#)$Id$";

#T make 'Integers' a FLMLOR over 'Integers'!
#T (then 'Enumerator' etc. for 'GaussianIntegers' should automatically work)


#############################################################################
##
#M  \in( <n>, <GaussianIntegers> )  . . membership test for Gaussian integers
##
##  Gaussian integers are of the form '<a> + <b>\*E(4)', where <a> and <b>
##  are integers.
##
InstallMethod( \in,
    "method for Gaussian integers",
    IsElmsColls, [ IsCyc, IsGaussianIntegers ], 0,
    function( cyc, GaussianIntegers )
    return IsCycInt( cyc ) and 4 mod NofCyc( cyc ) = 0;
    end );


#############################################################################
##
#M  BasisOfDomain( <GaussianIntegers> ) . . . . . . . . for Gaussian integers
##
InstallMethod( BasisOfDomain,
    "method for Gaussian integers",
    true, [ IsGaussianIntegers ], 0,
    CanonicalBasis );

    
#############################################################################
##
#M  CanonicalBasis( <GaussianIntegers> )  . . . . . . . for Gaussian integers
##
IsCanonicalBasisGaussianIntegersRep := NewRepresentation(
    "IsCanonicalBasisGaussianIntegersRep", IsAttributeStoringRep,
    [ "conductor", "zumbroichbase" ] );

InstallMethod( CanonicalBasis,
    "method for Gaussian integers",
    true, [ IsGaussianIntegers ], 0,
    function( GaussianIntegers )
    local B;

    B:= Objectify( NewKind( FamilyObj( GaussianIntegers ),
                                IsBasis
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
InstallMethod( Coefficients, true,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisGaussianIntegersRep,
      IsCyc ], 0,
    function( B, z )
    local N,
          coeffs,
          F;

    F:= UnderlyingLeftModule( B );
    if not z in F then return fail; fi;

    N:= B!.conductor;

    # Get the Zumbroich basis representation of <z> in 'N'-th roots.
    coeffs:= CoeffsCyc( z, N );
    if coeffs = fail then return fail; fi;

    # Get the Zumbroich basis coefficients (basis $B_{n,1}$)
    coeffs:= coeffs{ B!.zumbroichbase + 1 };

    # Return the list of coefficients.
    return coeffs;
    end );


#T #############################################################################
#T ##
#T #M  Random( <GaussianIntegers> )  . . . . . . . . . . . for Gaussian integers
#T ##
#T InstallMethod( Random,
#T     "method for Gaussian integers",
#T     true, [ IsGaussianIntegers ], 0,
#T     function( GaussianIntegers )
#T     return Random( Integers ) + Random( Integers ) * E(4);
#T     end );
#T #T necessary?


#############################################################################
##
#M  Quotient( GaussianIntegers, <n>, <m> )
##
InstallMethod( Quotient,
    "method for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ], 0,
    function ( GaussianIntegers, x, y )
    local   q;
    q := x / y;
    if not IsCycInt( q )  then
        q := fail;
    fi;
    return q;
    end );


#############################################################################
##
#M  IsAssociated( <GaussianIntegers>, <x>, <y> )
##
InstallMethod( IsAssociated,
    "method for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ], 0,
    function( GaussianIntegers, x, y )
    return x = y  or x = -y  or x = E(4)*y  or x = -E(4)*y;
    end );


#############################################################################
##
#M  StandardAssociate( <GaussianIntegers>, <x> )  . . . for Gaussian integers
##
##  The standard associate of <x> is an associated element <y> of <x> that
##  lies in the  first quadrant of the complex plane.
##  That is <y> is that element from '<x> * [1,-1,E(4),-E(4)]' that has
##  positive real part and nonnegative imaginary part.
##
##  (This is the generalization of 'Abs' (see "Abs") for Gaussian integers.)
##
InstallMethod( StandardAssociate,
    "method for Gaussian integers",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ], 0,
    function ( GaussianIntegers, x )
    if not IsGaussInt( x )  then
        Error( "<x> must lie in <GaussianIntegers>" );
    elif IsRat(x)  and 0 <= x  then
        return x;
    elif IsRat(x)  then
        return -x;
    elif 0 <  COEFFSCYC(x)[1]       and 0 <= COEFFSCYC(x)[2]       then
        return x;
    elif      COEFFSCYC(x)[1] <= 0  and 0 <  COEFFSCYC(x)[2]       then
        return - E(4) * x;
    elif      COEFFSCYC(x)[1] <  0  and      COEFFSCYC(x)[2] <= 0  then
        return - x;
    else
        return E(4) * x;
    fi;
    end );


#############################################################################
##
#M  EuclideanDegree( GaussianIntegers, <n> )
##
InstallMethod( EuclideanDegree,
    "method for Gaussian integers",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ], 0,
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
    "method for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ], 0,
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
    "method for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ], 0,
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
    "method for Gaussian integers",
    IsCollsElmsElms,
    [ IsGaussianIntegers, IsCyc, IsCyc ], 0,
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
    "method for Gaussian integers and integer",
    IsCollsElms,
    [ IsGaussianIntegers, IsInt ], 0,
    function ( GaussianIntegers, x )
    return x mod 4 = 3  and IsPrimeInt( x );
    end );

InstallMethod( IsPrime,
    "method for Gaussian integers and cyclotomic",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ], 0,
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
    "method for Gaussian integers",
    IsCollsElms,
    [ IsGaussianIntegers, IsCyc ], 0,
    function ( GaussianIntegers, x )
    local   facs,       # factors (result)
            prm,        # prime factors of the norm
            tsq;        # representation of 'prm' as $x^2 + y^2$

    # handle trivial cases
    if x in [ 0, 1, -1, E(4), -E(4) ]  then
        return [ x ];
    elif not IsGaussInt( x ) then
        Error( "<x> must lie in <GaussianIntegers>" );
    fi;

    # loop over all factors of the norm of x
    facs := [];
    for prm in Set( FactorsInt( EuclideanDegree( GaussianIntegers, x ) ) ) do

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


#T hier!
#T #############################################################################
#T ##
#T #F  GaussianRationalsOps.CharPol(<GaussRat>,<x>)  . .  characteristic polynom
#T #F                                                     of a Gaussian rational
#T ##
#T GaussianRationalsOps.CharPol := function ( GaussRat, x )
#T     return [ x * GaloisCyc(x,-1), -x-GaloisCyc(x,-1), 1 ];
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #F  GaussianRationalsOps.MinPol(<GaussRat>,<x>) . . . . . . . minimal polynom
#T #F                                                     of a Gaussian rational
#T ##
#T GaussianRationalsOps.MinPol := function ( GaussRat, x )
#T     if IsRat( x )  then
#T         return [ -x, 1 ];
#T     else
#T         return [ x * GaloisCyc(x,-1), -x-GaloisCyc(x,-1), 1 ];
#T     fi;
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #E  gaussian.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
#T 
#T 
#T 
#T #############################################################################
#T ##
#T #M  Enumerator( Integers )
#T ##
#T ##  $a_n = \frac{n}{2}$ if $n$ is even, and
#T ##  $a_n = \frac{1-n}{2}$ otherwise.
#T ##
#T IsIntegersEnumerator := NewRepresentation( "IsIntegersEnumerator",
#T     IsDomainEnumerator and IsAttributeStoringRep, [] );
#T 
#T InstallMethod( Enumerator, true, [ IsIntegers ], 0,
#T     function( Integers )
#T     local enum;
#T     enum:= Objectify( NewKind( FamilyObj( Integers ), IsIntegersEnumerator ),
#T                       rec() );
#T     SetUnderlyingCollection( enum, Integers );
#T     return enum;
#T     end );
#T 
#T InstallMethod( \[\], true, [ IsIntegersEnumerator, IsPosRat and IsInt ], 0,
#T     function( e, x )
#T     if x > 0 then
#T       return 2 * x;
#T     else
#T       return -2 * x + 1;
#T     fi;
#T     end );
#T 
#T InstallMethod( Position, true, [ IsIntegersEnumerator, IsCyc, IsZeroCyc ], 0,
#T     function( e, n, zero )
#T     if not IsInt(n)  then
#T         return fail;
#T     elif n mod 2 = 0 then
#T         return n / 2;
#T     else
#T         return ( 1 - n ) / 2;
#T     fi;
#T     end );
#T 
#T 
#T ############################################################################
#T ##
#T #M  Iterator( Integers )
#T ##
#T ##  uses the succession $0, 1, -1, 2, -2, 3, -3, \ldots$, that is,
#T ##  $a_n = \frac{n}{2}$ if $n$ is even, and $a_n = \frac{1-n}{2}$
#T ##  otherwise.
#T ##
#T IsIntegersIterator := NewRepresentation( "IsIntegersIterator",
#T     IsIterator,
#T     [ "structure", "counter" ] );
#T 
#T InstallMethod( Iterator, true, [ IsIntegers ], 0,
#T     function( Integers )
#T     return Objectify( NewKind( IteratorsFamily, IsIntegersIterator ),
#T                       rec(
#T                            structure := Integers,
#T                            counter   := 0         ) );
#T     end );
#T 
#T InstallMethod( IsDoneIterator, true, [ IsIntegersIterator ], 0,
#T     ReturnFalse );
#T 
#T InstallMethod( NextIterator, true, [ IsIntegersIterator ], 0,
#T     function( iter )
#T     iter!.counter:= iter!.counter + 1;
#T     if iter!.counter mod 2 = 0 then
#T       return iter!.counter / 2;
#T     else
#T       return ( 1 - iter!.counter ) / 2;
#T     fi;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  QuotientMod( Integers , <r>, <s>, <m> ) . . . . . . . quotient modulo <m>
#T ##
#T InstallMethod( QuotientMod, true, [ IsIntegers, IsInt, IsInt, IsInt ], 0,
#T     function ( Integers, r, s, m )
#T     if r mod GcdInt( s, m ) = 0  then
#T         return r/s mod m;
#T     else
#T         return false;
#T     fi;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  PowerMod( Integers, <r>, <e>, <m> ) . . . power of an integer mod another
#T ##
#T InstallMethod( PowerMod, true, [ IsIntegers, IsInt, IsInt, IsInt ], 0,
#T     function ( Integers, r, e, m )
#T     return PowerModInt( r, e, m );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Gcd( Integers, <n>, <m> ) . . . . . . . . . . . . . . gcd of two integers
#T ##
#T InstallMethod( Gcd, true, [ IsIntegers, IsInt, IsInt ], 0,
#T     function ( Integers, n, m )
#T     return GcdInt( n, m );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Gcd( <int-list> )
#T ##
#T InstallOtherMethod( Gcd,
#T     true,
#T     [ IsRowVector ],
#T     0,
#T 
#T function( list )
#T     local   gcd,  i;
#T 
#T     if not ForAll( list, IsInt )  then
#T         TryNextMethod();
#T     fi;
#T     gcd := list[1];
#T     for i  in [ 2 .. Length(list) ]  do
#T         gcd := GcdInt( gcd, list[i] );
#T     od;
#T     return gcd;
#T end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Lcm( Integers, <n>, <m> ) . . . . . . . least common multiple of integers
#T ##
#T InstallMethod( Lcm, true, [ IsIntegers, IsInt, IsInt ], 0,
#T     function ( Integers, n, m )
#T     return LcmInt( n, m );
#T     end );
#T 
