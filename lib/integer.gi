#############################################################################
##
#W  integer.gi                  GAP library                     Thomas Breuer 
#W                                                             & Frank Celler
#W                                                            & Werner Nickel
#W                                                           & Alice Niemeyer
#W                                                         & Martin Schoenert
#W                                                              & Alex Wegner
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.integer_gi :=
    "@(#)$Id$";


#############################################################################
##

#V  Integers  . . . . . . . . . . . . . . . . . . . . .  ring of the integers
##
InstallValue( Integers, Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsIntegers and IsAttributeStoringRep ),
    rec() ) );

SetName( Integers, "Integers" );
SetIsLeftActedOnByDivisionRing( Integers, false );
SetSize( Integers, infinity );
SetLeftActingDomain( Integers, Integers );
SetGeneratorsOfRing( Integers, [ 1 ] );
SetGeneratorsOfLeftModule( Integers, [ 1 ] );
SetUnits( Integers, [ -1, 1 ] );


#############################################################################
##
#V  GaussianIntegers  . . . . . . . . . . . . . . . ring of Gaussian integers
##
InstallValue( GaussianIntegers, Objectify( NewType(
    CollectionsFamily(CyclotomicsFamily),
    IsGaussianIntegers and IsAttributeStoringRep ),
    rec() ) );

SetLeftActingDomain( GaussianIntegers, Integers );
SetName( GaussianIntegers, "GaussianIntegers" );
SetIsLeftActedOnByDivisionRing( GaussianIntegers, false );
SetSize( GaussianIntegers, infinity );
SetGeneratorsOfRing( GaussianIntegers, [ E(4) ] );
SetGeneratorsOfLeftModule( GaussianIntegers, [ 1, E(4) ] );
SetUnits( GaussianIntegers, [ -1, 1, -E(4), E(4) ] );


#############################################################################
##

#R  IsCanonicalBasisIntegersRep
##
DeclareRepresentation(
    "IsCanonicalBasisIntegersRep",
    IsAttributeStoringRep,
    [] );
#T is this needed at all?


#############################################################################
##

#M  BasisOfDomain( Integers )
##
InstallMethod( BasisOfDomain,
    "method for integers (use canonical basis)",
    true,
    [ IsIntegers ], 0,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( Integers )
##
InstallMethod( CanonicalBasis,
    "method for Integers",
    true,
    [ IsIntegers ], 0,
    function( Integers )
    local B;
    B:= Objectify( NewType( FamilyObj( Integers ),
                                IsBasis
                            and IsCanonicalBasis
                            and IsCanonicalBasisIntegersRep ),
                   rec() );
    SetUnderlyingLeftModule( B, Integers );
    SetBasisVectors( B, [ 1 ] );

    return B;
    end );

InstallMethod( Coefficients,
    "method for the canonical basis of Integers",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisIntegersRep,
      IsCyc ], 0,
    function( B, v )
    if IsInt( v ) then
      return [ v ];
    else
      return fail;
    fi;
    end );


#############################################################################
##
#F  BestQuoInt( <n>, <m> )
##
##  'BestQuoInt' returns the best quotient <q> of the integers  <n> and  <m>.
##  This is the quotient such that '<n>-<q>\*<m>' has minimal absolute value.
##  If there are two quotients whose remainders have the same absolute value,
##  then the quotient with the smaller absolute value is choosen.
##
InstallGlobalFunction(BestQuoInt,function ( n, m )
    if   0 <= m  and 0 <= n  then
        return QuoInt( n + QuoInt( m - 1, 2 ), m );
    elif 0 <= m  then
        return QuoInt( n - QuoInt( m - 1, 2 ), m );
    elif 0 <= n  then
        return QuoInt( n - QuoInt( m + 1, 2 ), m );
    else
        return QuoInt( n + QuoInt( m + 1, 2 ), m );
    fi;
end);


#############################################################################
##
#F  ChineseRem( <moduli>, <residues> )  . . . . . . . . . . chinese remainder
##
InstallGlobalFunction(ChineseRem,function ( moduli, residues )
    local   i, c, l, g;

    # combine the residues modulo the moduli
    i := 1;
    c := residues[1];
    l := moduli[1];
    while i < Length(moduli)  do
        i := i + 1;
        g := Gcdex( l, moduli[i] );
        if g.gcd <> 1  and (residues[i]-c) mod g.gcd <> 0  then
            Error("the residues must be equal modulo ",g.gcd);
        fi;
        c := l * (((residues[i]-c) / g.gcd * g.coeff1) mod moduli[i]) + c;
        l := moduli[i] / g.gcd * l;
    od;

    # reduce c into the range [0..l-1]
    c := c mod l;
    return c;
end);


#############################################################################
##
#F  CoefficientsQadic( <i>, <q> ) . . . . . .  <q>-adic representation of <i>
##
InstallGlobalFunction(CoefficientsQadic,function( i, q )
    local   v;

    # represent the integer <i> as <q>-adic number
    v := [];
    while i > 0  do
        Add( v, RemInt( i, q ) );
        i := QuoInt( i, q );
    od;
    return v;
end);


#############################################################################
##
#F CoefficientsMultiadic( ints, int )
##
InstallGlobalFunction(CoefficientsMultiadic, function( ints, int )
    local vec, i;
    vec := List( ints, x -> 0 );
    for i in Reversed( [1..Length(ints)] ) do
        vec[i] := RemInt( int, ints[i] );
        int := QuoInt( int, ints[i] );
    od;
    return vec;
end);


#############################################################################
##
#F  DivisorsInt( <n> )  . . . . . . . . . . . . . . .  divisors of an integer
##
DivisorsSmall :=
    Immutable( [,[1],[1,2],[1,3],[1,2,4],[1,5],[1,2,3,6],[1,7]] );

InstallGlobalFunction(DivisorsInt,function ( n )
    local  divisors, factors, divs;

    # make <n> it nonnegative, handle trivial cases, and get prime factors
    if n < 0  then n := -n;  fi;
    if n = 0  then Error("DivisorsInt: <n> must not be 0");  fi;
    if n < 8  then return DivisorsSmall[n+1];  fi;
    factors := FactorsInt( n );

    # recursive function to compute the divisors
    divs := function ( i, m )
        if Length(factors) < i     then return [ m ];
        elif m mod factors[i] = 0  then return divs(i+1,m*factors[i]);
        else return Concatenation( divs(i+1,m), divs(i+1,m*factors[i]) );
        fi;
    end;

    divisors := divs( 1, 1 );
    Sort( divisors );
    return Immutable(divisors);
end);


#############################################################################
##
#F  FactorsRho( <n>, <inc>, <cluster>, <limit> )   Pollards rho factorization
##
##  'FactorsInt' does trial divisions by the primes less than 1000 to  detect
##  all composites with a factor less than 1000 and primes less than 1000000.
##  After that it calls 'FactorsRho(<n>,1,16,8192)' to do the hard work.
##
##  'FactorsRho'  will  return a  list  of factors   and a list  of composite
##  number.   Usually  'FactorsInt'  factors  integers  with   prime  factors
##  $\<1000$ faster.     However  for   integers  with  no   factor  $\<1000$
##  'FactorsRho' will be faster.
##
##  'FactorsRho' uses Pollards $\rho$ method to factor the integer $n = p q$.
##  For a small simple example lets assume we want to factor $667 = 23 * 29$.
##  'FactorsRho' first calls 'IsPrimeInt' to avoid trying to factor a prime.
##
##  Then it uses the sequence defined by  $x_0=1, x_{i+1}=(x_i^2+1)$ mod $n$.
##  In our example this is $1, 2, 5, 26, 10, 101, 197, 124, 36, 630, .. $.
##
##  Modulo $p$ it takes on at most $p-1$ different values, thus it eventually
##  becomes recurrent, usually this happens after roughly $2 \sqrt{p}$ steps.
##  In our example modulo 23 we get $1, 2, 5, 3, 10, 9, 13, 9, 13, 9, .. $.
##
##  Thus there exist pairs $i, j$ such that $x_i = x_j$ mod $p$,  i.e.,  such
##  that $p$ divides $Gcd( n, x_j-x_i )$.  With a bit of luck no other factor
##  of $n$ divides $x_j - x_i$ so we find $p$ if we know such a pair.  In our
##  example $5, 7$ is the first pair, $x_7-x_5=23$, and $Gcd(667,23) = 23$.
##
##  Now it is too expensive to check all pairs, but there also must be  pairs
##  of the form $2^i-1, j$ with $3*2^{i-1} <= j < 4*2^{i-1}$.  In our example
##  $7, 13$ is the first such pair, $x_13-x_7=506$, and $Gcd(667,506) = 23$.
##
##  Thus by taking the gcds of $n$ and $x_j-x_i$ for such pairs, we will find
##  the factor $p$ after approximately $2 \sqrt{p} \<= 2 \sqrt^4{n}$ steps.
##
##  If $Gcd( n, x_j - x_i )$  is not a prime 'FactorsRho'  will  call  itself
##  recursivly with a different value for <inc>, i.e., it  will try to factor
##  the gcd using a different sequence $x_{i+1} = (x_i^2 + inc)$ mod $n$.
##
##  Since the gcd computations are by far the most time consuming part of the
##  algorithm  one can save time by  clustering differences and computing the
##  gcd  only every <cluster>  iteration.  This slightly increases the chance
##  that a gcd is composite, but reduces the runtime by a large amount.
##
##  Finally 'FactorsRho' accepts an argument <limit>  which is the number  of
##  iterations  performed by 'FactorsRho' before giving up. The default value
##  is  8192  which corresponds to a few minutes  while guaranteing that  all
##  prime factors less than $10^6$ and most less than $10^9$ are found.
##
##  Better descriptions of the algorithm and related topics can be found  in:
##  J. Pollard, A Monte Carlo Method for Factorization, BIT 15, 1975, 331-334
##  R. Brent, An Improved Monte Carlo Method for Fact., BIT 20, 1980, 176-184
##  D. Knuth, Seminumerical Algorithms  (TACP II),  AddiWesl,  1973,  369-371
##
FactorsRho := function ( n, inc, cluster, limit )
    local   i, sign,  factors,  composite,  x,  y,  k,  z,  g,  tmp;

    # make $n$ positive and handle trivial cases
    sign := 1;
    if n < 0  then sign := -sign;  n := -n;  fi;
    if n < 4  then return [ [ sign * n ], [] ];  fi;
    factors   := [];
    composite := [];
    while n mod 2 = 0  do Add( factors, 2 );  n := n / 2;  od;
    while n mod 3 = 0  do Add( factors, 3 );  n := n / 3;  od;
    if IsPrimeInt(n)  then Add( factors, n );  n := 1;  fi;

    # initialize $x_0$
    x := 1;  z := 1;  i := 0;

    # loop until we have factored $n$ completely or run out of patience
    while 1 < n  and 2^i <= limit  do

        # $y = x_{2^i-1}$
        y := x;  i := i + 1;

        # $x_{2^i}, .., x_{3*2^{i-1}-1}$ need not be compared to $x_{2^i-1}$
        for k  in [1..2^(i-1)]  do
            x := (x^2 + inc) mod n;
        od;

        # compare $x_{3*2^{i-1}}, .., x_{4*2^{i-1}-1}$ with $x_{2^i-1}$
        for k  in [1..2^(i-1)]  do
            x := (x^2 + inc) mod n;
            z := z * (x - y) mod n;

            # from time to time compute the gcd
            if k mod cluster = 0  then
                g := GcdInt( n, z );

                # if it is > 1 we have found a factor which need not be prime
                if g > 1  then
                    tmp := FactorsRho(g,inc+1,QuoInt(cluster+1,2),limit);
                    factors   := Concatenation( factors,   tmp[1] );
                    composite := Concatenation( composite, tmp[2] );

                    n := n / g;
                    if IsPrimeInt(n)  then Add( factors, n );  n := 1;  fi;
                fi;
            fi;
        od;
    od;

    # add <n> to the list of composite numbers
    if 1 < n  then
        Add( composite, n );
    fi;

    # sort the list of factors and composite numbers and return it
    Sort(factors);
    Sort(composite);
    if 0 < Length(factors)  then
        factors[1] := sign * factors[1];
    else
        composite[1] := sign * composite[1];
    fi;
    return [ factors, composite ];

end;


#############################################################################
##
#F  FactorsInt( <n> ) . . . . . . . . . . . . . . prime factors of an integer
InstallGlobalFunction(FactorsInt,function ( n )
    local  sign,  factors,  p,  tmp;

    # make $n$ positive and handle trivial cases
    sign := 1;
    if n < 0  then sign := -sign;  n := -n;  fi;
    if n < 4  then return [ sign * n ];  fi;
    factors := [];

    # do trial divisions by the primes less than 1000
    # faster than anything fancier because $n$ mod <small int> is very fast
    for p  in Primes  do
        while n mod p = 0  do Add( factors, p );  n := n / p;  od;
        if n < (p+1)^2 and 1 < n  then Add(factors,n);  n := 1;  fi;
        if n = 1  then factors[1] := sign*factors[1];  return factors;  fi;
    od;

    # do trial divisions by known factors
    for p  in Primes2  do
        while n mod p = 0  do Add( factors, p );  n := n / p;  od;
        if n = 1  then factors[1] := sign*factors[1];  return factors;  fi;
    od;

    # handle perfect powers
    p := SmallestRootInt( n );
    if p < n  then
        while 1 < n  do
            Append( factors, FactorsInt(p) );
            n := n / p;
        od;
        Sort( factors );
        factors[1] := sign * factors[1];
        return factors;
    fi;

    # let 'FactorsRho' do the work
    tmp := FactorsRho( n, 1, 16, 8192 );
    if 0 < Length(tmp[2])  then
        Error( "sorry,  cannot factor ", tmp[2] );
    fi;
    factors := Concatenation( factors, tmp[1] );
    Sort( factors );
    factors[1] := sign * factors[1];
    return factors;
end);


#############################################################################
##
#F  Gcdex( <m>, <n> ) . . . . . . . . . . greatest common divisor of integers
##
InstallGlobalFunction(Gcdex,function ( m, n )
    local   f, g, h, fm, gm, hm, q;
    if 0 <= m  then f:=m; fm:=1; else f:=-m; fm:=-1; fi;
    if 0 <= n  then g:=n; gm:=0; else g:=-n; gm:=0;  fi;
    while g <> 0  do
        q := QuoInt( f, g );
        h := g;          hm := gm;
        g := f - q * g;  gm := fm - q * gm;
        f := h;          fm := hm;
    od;
    if n = 0  then
        return rec( gcd := f, coeff1 := fm, coeff2 := 0,
                              coeff3 := gm, coeff4 := 1 );
    else
        return rec( gcd := f, coeff1 := fm, coeff2 := (f - fm * m) / n,
                              coeff3 := gm, coeff4 := (0 - gm * m) / n );
    fi;
end);


#############################################################################
##
#F  IsPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . .  test for a prime
##
##  'IsPrimeInt' does trial divisions by the primes less  than 1000 to detect
##  composites with a factor less than 1000 and  primes  less  than  1000000.
##
##  'IsPrimeInt' then checks that $n$ is a strong pseudoprime to the  base 2.
##  This uses Fermats theorem which says $2^{n-1}=1$ mod $n$ for a prime $n$.
##  If $2^{n-1}\<>1$ mod $n$, $n$ is composite, 'IsPrimeInt' returns 'false'.
##  There are composite numbers for which $2^{n-1}=1$,  but they are  seldom.
##
##  Then 'IsPrimeInt' checks that $n$ is a Lucas pseudoprime for $p$, choosen
##  so that the discriminant $d=p^2/4-1$ is an  quadratic nonresidue mod $n$.
##  I.e., 'IsPrimeInt' takes the root $a = p/2+\sqrt{d}$ of $x^2 - px + 1$ in
##  the  ring $Z_n[\sqrt{d}] and computes the  traces of $a^n$ and $a^{n+1}$.
##  If $n$ is a prime, this  ring is the field of  order $n^2$ and raising to
##  the $n$th power is conjugation, so $trace(a^n)=p$ and $trace(a^{n+1})=2$.
##  However, these identities hold only for extremly few composite numbers.
##
##  Note that  this  test  for $trace(a^n) = p$  and  $trace(a^{n+1}) = 2$ is
##  usually formulated using the Lucas sequences  $U_k = (a^k-b^k)/(a-b)$ and
##  $V_k = (a^k+b^k)=trace(a^k)$, where one tests $U_{n+1} = 0, V_{n+1} = 2$.
##  However, the trace test is equivalent and requires fewer multiplications.
##  Thanks to Daniel R. Grayson (dan@symcom.math.uiuc.edu)  for  telling  me.
##
##  'IsPrimeInt' can be shown to return the correct answer for $n < 10^{13}$,
##  by testing against R.G.E. Pinch's list of all pseudoprimes to base 2 less
##  than $10^{13}$ ('ftp://cmms.cam.ac.uk/pub/rgep/PSP/psp13').
##
##  Better descriptions of the algorithm and related topics can be found  in:
##  G. Miller, cf. Algorithms and Complexity ed. Traub, AcademPr, 1976, 35-36
##  C. Pomerance et.al., Pseudoprimes to 25*10^9, MathComp 35 1980, 1003-1026
##  D. Knuth, Seminumerical Algorithms  (TACP II),  AddiWesl,  1973,  378-380
##  G. Gonnet, Heuristic Primality Testing, Maple Newsletter 4,  1989,  36-38
##  R. Baillie, S. Wagstaff, Lucas Pseudoprimes, MathComp 35 1980,  1391-1417
##  R. Pinch, Some Primality Testing Algorithms, Notic. AMS 9 1993, 1203-1210
##
TraceModQF := function ( p, k, n )
    local  trc;
    if k = 1  then
        trc := [ p, 2 ];
    elif k mod 2 = 0  then
        trc := TraceModQF( p, k/2, n );
        trc := [ (trc[1]^2 - 2) mod n, (trc[1]*trc[2] - p) mod n ];
    else
        trc := TraceModQF( p, (k+1)/2, n );
        trc := [ (trc[1]*trc[2] - p) mod n, (trc[2]^2 - 2) mod n ];
    fi;
    return trc;
end;

InstallGlobalFunction(IsPrimeInt,function ( n )
    local  p, e, o, x, i, d;

    # make $n$ positive and handle trivial cases
    if n < 0         then n := -n;       fi;
    if n in Primes   then return true;   fi;
    if n in Primes2  then return true;   fi;
    if n <= 1000     then return false;  fi;

    # do trial divisions by the primes less than 1000
    # faster than anything fancier because $n$ mod <small int> is very fast
    for p  in Primes  do
        if n mod p = 0  then return false;  fi;
        if n < (p+1)^2  then AddSet(Primes2,n);  return true;   fi;
    od;

    # do trial division by the other known primes
    for p  in Primes2  do
        if n mod p = 0  then return false;  fi;
    od;

    # find $e$ and $o$ odd such that $n-1 = 2^e * o$
    e := 0;  o := n-1;   while o mod 2 = 0  do e := e+1;  o := o/2;  od;

    # look at the seq $2^o, 2^{2 o}, 2^{4 o}, .., 2^{2^e o}=2^{n-1}$
    x := PowerModInt( 2, o, n );
    i := 0;
    while i < e  and x <> 1  and x <> n-1  do
        x := x * x mod n;
        i := i + 1;
    od;

    # if it is not of the form $.., -1, 1, 1, ..$ then $n$ is composite
    if not (x = n-1 or (i = 0 and x = 1))  then
        return false;
    fi;

    # there are no strong pseudo-primes to base 2 smaller than 2047
    if n < 2047  then
        AddSet( Primes2, n );
        return true;
    fi;

    # make sure that $n$ is not a perfect power (especially not a square)
    if SmallestRootInt(n) < n  then
        return false;
    fi;

    # find a quadratic nonresidue $d = p^2/4-1$ mod $n$
    p := 2;  while Jacobi( p^2-4, n ) <> -1  do p := p+1;  od;

    # for a prime $n$ the trace of $(p/2+\sqrt{d})^n$ must be $p$
    # and the trace of $(p/2+\sqrt{d})^{n+1}$ must be 2
    if TraceModQF( p, n+1, n ) = [ 2, p ]  then
        AddSet( Primes2, n );
        return true;
    fi;

    # $n$ is not a prime
    return false;
end);


#############################################################################
##
#F  IsPrimePowerInt( <n> )  . . . . . . . . . . . test for a power of a prime
##
InstallGlobalFunction(IsPrimePowerInt,function ( n )
    return IsPrimeInt( SmallestRootInt( n ) );
end);


#############################################################################
##
#F  LcmInt( <m>, <n> )  . . . . . . . . . . least common multiple of integers
##
InstallGlobalFunction(LcmInt,function ( n, m )
    if m = 0  and n = 0  then
        return 0;
    else
        return AbsInt( m / GcdInt( m, n ) * n );
    fi;
end);


#############################################################################
##
#F  LogInt( <n>, <base> ) . . . . . . . . . . . . . . logarithm of an integer
##
InstallGlobalFunction(LogInt,function ( n, base )
    local   log;

    # check arguments
    if n    <= 0  then Error("<n> must be positive");  fi;
    if base <= 1  then Error("<base> must be greater than 1");  fi;

    # 'log(b)' returns $log_b(n)$ and divides 'n' by 'b^log(b)'
    log := function ( b )
        local   i;
        if b > n  then return 0;  fi;
        i := log( b^2 );
        if b > n  then return 2 * i;
        else  n := QuoInt( n, b );  return 2 * i + 1;  fi;
    end;

    return log( base );
end);


#############################################################################
##
#F  MoebiusMu( <n> )  . . . . . . . . . . . . . .  Moebius inversion function
##
InstallGlobalFunction(MoebiusMu,function ( n )
    local  factors;

    if n < 0  then n := -n;  fi;
    if n = 0  then Error("MoebiusMu: <n> must be nonzero");  fi;
    if n = 1  then return 1;  fi;

    factors := FactorsInt( n );
    if factors <> Set( factors )  then return 0;  fi;
    return (-1) ^ Length(factors);
end);


#############################################################################
##
#F  NextPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . next larger prime
##
InstallGlobalFunction(NextPrimeInt,function ( n )
    if   -3 = n             then n := -2;
    elif -3 < n  and n < 2  then n :=  2;
    elif n mod 2 = 0        then n := n+1;
    else                         n := n+2;
    fi;
    while not IsPrimeInt(n)  do
        if n mod 6 = 1  then n := n+4;
        else                 n := n+2;
        fi;
    od;
    return n;
end);


#############################################################################
##
#F  PowerModInt(<r>,<e>,<m>)  . . . . . . power of one integer modulo another
##
InstallGlobalFunction(PowerModInt,function ( r, e, m )
    local   pow, f;

    # handle special cases
    if e = 0  then
        return 1;
    elif m = 1 then
        return 0;
    fi;

    # reduce `r' initially
    r := r mod m;

    # if `e' is negative then invert `r' modulo `m' with Euclids algorithm
    if e < 0  then
        r := 1/r mod m;
        e := -e;
    fi;

    # now use the repeated squaring method (right-to-left)
    pow := 1;
    f := 2 ^ (LogInt( e, 2 ) + 1);
    while 1 < f  do
        pow := (pow * pow) mod m;
        f := QuoInt( f, 2 );
        if f <= e  then
            pow := (pow * r) mod m;
            e := e - f;
        fi;
    od;

    # return the power
    return pow;
end);


#############################################################################
##
#F  PrevPrimeInt( <n> ) . . . . . . . . . . . . . . .  previous smaller prime
##
##  'PrevPrimeInt' returns the largest prime  which is strictly smaller  than
##  the integer <n>.
##
InstallGlobalFunction(PrevPrimeInt,function ( n )
    if    3 = n             then n :=  2;
    elif -2 < n  and n < 3  then n := -2;
    elif n mod 2 = 0        then n := n-1;
    else                         n := n-2;
    fi;
    while not IsPrimeInt(n)  do
        if n mod 6 = 5  then n := n-4;
        else                 n := n-2;
        fi;
    od;
    return n;
end);


#############################################################################
##
#F  PrimePowerInt( <n> )  . . . . . . . . . . . . . . . . prime powers of <n>
##
InstallGlobalFunction(PrimePowersInt,function( n )
    local   p,  pows,  lst;

    if n = 1  then
	return [];
    elif n = 0  then
    	Error( "<n> must be non zero" );
    elif n < 0  then
    	n := -1 * n;
    fi;
    lst  := Factors( Integers, n );
    pows := [];
    for p  in Set( lst )  do
	Add( pows, p );
        Add( pows, Number( lst, x -> x = p ) );
    od;
    return pows;

end);


#############################################################################
##
#F  RootInt( <n> )  . . . . . . . . . . . . . . . . . . .  root of an integer
#F  RootInt( <n>, <k> )
##
InstallGlobalFunction(RootInt,function ( arg )
    local   n, k, r, s, t;

    # get the arguments
    if   Length(arg) = 1  then n := arg[1];  k := 2;
    elif Length(arg) = 2  then n := arg[1];  k := arg[2];
    else Error("usage: 'Root( <n> )' or 'Root( <n>, <k> )'");
    fi;

    # check the arguments and handle trivial cases
    if  k <= 0                  then Error("<k> must be positive");
    elif k = 1                  then return n;
    elif n < 0 and k mod 2 = 0  then Error("<n> must be positive");
    elif n < 0 and k mod 2 = 1  then return -RootInt( -n, k );
    elif n = 0                  then return 0;
    elif n <= k                 then return 1;
    fi;

    # r is the first approximation, s the second, we need: root <= s < r
    r := n;  s := 2^( QuoInt( LogInt(n,2), k ) + 1 ) - 1;

    # do Newton iterations until the approximations stop decreasing
    while s < r  do
        r := s;  t := r^(k-1);  s := QuoInt( n + (k-1)*r*t, k*t );
    od;

    # and thats the integer part of the root
    return r;
end);


#############################################################################
##
#F  Sigma( <n> )  . . . . . . . . . . . . . . . sum of divisors of an integer
##
InstallGlobalFunction(Sigma,function ( n )
    local  sigma, p, q, k;

    # make <n> it nonnegative, handle trivial cases
    if n < 0  then n := -n;  fi;
    if n = 0  then Error("Sigma: <n> must not be 0");  fi;
    if n < 8  then return Sum(DivisorsSmall[n+1]);  fi;

    # loop over all prime $p$ factors of $n$
    sigma := 1;
    for p  in Set(FactorsInt(n))  do

        # compute $p^e$ and $k = 1+p+p^2+..p^e$
        q := p;  k := 1 + p;
        while n mod (q * p) = 0  do q := q * p;  k := k + q;  od;

        # combine with the value found so far
        sigma := sigma * k;
    od;

    return sigma;
end);


#############################################################################
##
#F  SmallestRootInt( <n> )  . . . . . . . . . . . smallest root of an integer
##
InstallGlobalFunction(SmallestRootInt,function ( n )
    local   k, r, s, p, l, q;

    # check the argument
    if   n > 0  then k := 2;  s :=  1;
    elif n < 0  then k := 3;  s := -1;  n := -n;
    else return 0;
    fi;

    # exclude small divisors, and thereby large exponents
    if n mod 2 = 0  then
        p := 2;
    else
        p := 3;  while p < 100  and n mod p <> 0  do p := p+2;  od;
    fi;
    l := LogInt( n, p );

    # loop over the possible prime divisors of exponents
    # use Euler's criterion to cast out impossible ones
    while k <= l  do
        q := 2*k+1;  while not IsPrimeInt(q)  do q := q+2*k;  od;
        if PowerModInt( n, (q-1)/k, q ) <= 1  then
            r := RootInt( n, k );
            if r ^ k = n  then
                n := r;
                l := QuoInt( l, k );
            else
                k := NextPrimeInt( k );
            fi;
        else
            k := NextPrimeInt( k );
        fi;
    od;

    return s * n;
end);


#############################################################################
##
#F  Tau( <n> )  . . . . . . . . . . . . . .  number of divisors of an integer
##
InstallGlobalFunction(Tau,function ( n )
    local  tau, p, q, k;

    # make <n> it nonnegative, handle trivial cases
    if n < 0  then n := -n;  fi;
    if n = 0  then Error("Tau: <n> must not be 0");  fi;
    if n < 8  then return Length(DivisorsSmall[n+1]);  fi;

    # loop over all prime factors $p$ of $n$
    tau := 1;
    for p  in Set(FactorsInt(n))  do

        # compute $p^e$ and $k = e+1$
        q := p;  k := 2;
        while n mod (q * p) = 0  do q := q * p;  k := k + 1;  od;

        # combine with the value found so far
        tau := tau * k;
    od;

    return tau;
end);


#############################################################################
##
#M  DefaultRingByGenerators( <elms> ) default ring generated by some integers
##
InstallMethod( DefaultRingByGenerators,
    "method that catches the cases of `Integers' and `GaussianIntegers'",
    true,
    [ IsCyclotomicCollection ], SUM_FLAGS,
    function ( elms )
    if ForAll( elms, IsInt ) then
      return Integers;
    elif ForAll( elms, IsGaussInt ) then
      return GaussianIntegers;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Enumerator( Integers )
##
##  $a_n = \frac{n}{2}$ if $n$ is even, and
##  $a_n = \frac{1-n}{2}$ otherwise.
##
DeclareRepresentation( "IsIntegersEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep, [] );

InstallMethod( Enumerator,
    "method for integers",
    true,
    [ IsIntegers ], 0,
    function( Integers )
    local enum;
    enum:= Objectify( NewType( FamilyObj( Integers ), IsIntegersEnumerator ),
                      rec() );
    SetUnderlyingCollection( enum, Integers );
    return enum;
    end );

InstallMethod( \[\],
    "method for enumerator of `Integers'",
    true,
    [ IsIntegersEnumerator, IsPosInt ], 0,
    function( e, n )
    if n mod 2 = 0 then
      return n / 2;
    else
      return ( 1 - n ) / 2;
    fi;
    end );

InstallMethod( Position,
    "method for enumerator of `Integers'",
    true,
    [ IsIntegersEnumerator, IsCyc, IsZeroCyc ], 0,
    function( e, x, zero )
    if not IsInt( x ) then
      return fail;
    elif 0 < x then
      return 2 * x;
    else
      return -2 * x + 1;
    fi;
    end );


############################################################################
##
#M  EuclideanDegree( Integers, <n> )  . . . . . . . . . . . . . absolut value
##
InstallMethod( EuclideanDegree,
    "method for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    if n < 0  then
        return -n;
    else
        return n;
    fi;
    end );


#############################################################################
##
#M  EuclideanQuotient( Integers, <n>, <m> )   . . . . . .  Euclidean quotient
##
InstallMethod( EuclideanQuotient,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return QuoInt( n, m );
    end );


#############################################################################
##
#M  EuclideanRemainder( Integers, <n>, <m> )  . . . . . . Euclidean remainder
##
InstallMethod( EuclideanRemainder,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return RemInt( n, m );
    end );


#############################################################################
##
#M  Factors( Integers, <n> )  . . . . . . . . . . factorization of an integer
##
InstallMethod( Factors,
    "method for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    return FactorsInt( n );
    end );


#############################################################################
##
#M  GcdOp( Integers, <n>, <m> ) . . . . . . . . . . . . . gcd of two integers
##
InstallMethod( GcdOp,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return GcdInt( n, m );
    end );


#############################################################################
##
#M  IsIrreducibleRingElement( Integers, <n> )
##
InstallMethod( IsIrreducibleRingElement,
    "method for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    return IsPrimeInt( n );
    end );


#############################################################################
##
#M  IsPrime( Integers, <n> )  . . . . . .  test whether an integer is a prime
##
InstallMethod( IsPrime,
    "method for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    return IsPrimeInt( n );
    end );


#############################################################################
##
#M  Iterator( Integers )
##
##  uses the succession $0, 1, -1, 2, -2, 3, -3, \ldots$, that is,
##  $a_n = \frac{n}{2}$ if $n$ is even, and $a_n = \frac{1-n}{2}$
##  otherwise.
##
DeclareRepresentation( "IsIntegersIterator",
    IsIterator,
    [ "structure", "counter" ] );

InstallMethod( Iterator,
    "method for `Integers'",
    true,
    [ IsIntegers ], 0,
    function( Integers )
    return Objectify( NewType( IteratorsFamily, IsIntegersIterator ),
                      rec(
                           structure := Integers,
                           counter   := 0         ) );
    end );

InstallMethod( IsDoneIterator,
    "method for iterator of `Integers'",
    true,
    [ IsIntegersIterator ], 0,
    ReturnFalse );

InstallMethod( NextIterator,
    "method for iterator of `Integers'",
    true,
    [ IsIntegersIterator ], 0,
    function( iter )
    iter!.counter:= iter!.counter + 1;
    if iter!.counter mod 2 = 0 then
      return iter!.counter / 2;
    else
      return ( 1 - iter!.counter ) / 2;
    fi;
    end );


#############################################################################
##
#M  LcmOp( Integers, <n>, <m> ) . . . . . . least common multiple of integers
##
InstallMethod( LcmOp,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return LcmInt( n, m );
    end );


#############################################################################
##
#M  Log( <n>, <base> )
##
InstallMethod( Log,
    "method for two integers",
    true,
    [ IsInt, IsInt ], 0,
    LogInt );


#############################################################################
##
#M  PowerMod( Integers, <r>, <e>, <m> ) . . . power of an integer mod another
##
InstallMethod( PowerMod,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt, IsInt ], 0,
    function ( Integers, r, e, m )
    return PowerModInt( r, e, m );
    end );


#############################################################################
##
#M  Quotient( <Integers>, <n>, <m> )  . . . . . . .  quotient of two integers
##
InstallMethod( Quotient,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    local   q;
    q := QuoInt( n, m );
    if n <> q * m  then
        q := fail;
    fi;
    return q;
    end );


#############################################################################
##
#M  QuotientMod( Integers , <r>, <s>, <m> ) . . . . . . . quotient modulo <m>
##
InstallMethod( QuotientMod,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt, IsInt ], 0,
    function ( Integers, r, s, m )
    if   m = 1 then
        return 0;
    elif r mod GcdInt( s, m ) = 0  then
        return r/s mod m;
    else
        return fail;
    fi;
    end );


#############################################################################
##
#M  QuotientRemainder( Integers, <n>, <m> ) . . . . . . . . . . . quo and rem
##
InstallMethod( QuotientRemainder,
    "method for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return [ QuoInt(n,m), RemInt(n,m) ];
    end );


#############################################################################
##
#M  Random( <low>, <high> )
##
InstallOtherMethod( Random,
    "method for two integers",
    IsIdenticalObj,
    [ IsInt,
      IsInt ],
    0,

function( a, b )
    local   d,  x,  r,  y;

    d := b-a;
    if d < 0  then
        return fail;
    elif a = b  then
        return a;
    else
        x := LogInt( d, 2 ) + 1;
        r := 0;
        while 0 < x  do
            y := Minimum( 10, x );
            x := x - y;
            r := r*2^y + Random([0..2^y-1]);
        od;
        if d < r  then
            return Random( a, b );
        else
            return a+r;
        fi;
    fi;
end );


#############################################################################
##
#M  Random( Integers )  . . . . . . . . . . . . . . . . . . .  random integer
##
NrBitsInt := function ( n )
    local   nr, nr64;
    nr64:=[0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,
           1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6];
    nr := 0;
    while 0 < n  do
        nr := nr + nr64[ n mod 64 + 1 ];
        n := QuoInt( n, 64 );
    od;
    return nr;
end;

InstallMethod( Random,
    "method for `Integers'",
    true,
    [ IsIntegers ], 0,
    function( Integers )
    return NrBitsInt( Random( [0..2^20-1] ) ) - 10;
    end );


#############################################################################
##
#M  DefaultRingByGenerators( <elms> )  . . default ring gen. by some integers
##
InstallMethod( DefaultRingByGenerators,
    "method that treats the cases of 'Integers' and 'GaussianIntegers'",
    true,
    [ IsCyclotomicCollection ], SUM_FLAGS,
    function ( elms )
    if ForAll( elms, IsInt ) then
      return Integers;
    elif ForAll( elms, IsGaussInt ) then
      return GaussianIntegers;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Root( <n>, <k> )
##
InstallMethod( Root,
    "method for two integers",
    true,
    [ IsInt, IsInt ], 0,
    RootInt );


#############################################################################
##
#M  StandardAssociate( Integers, <n> )  . . . . . . . . . . .  absolute value
##
InstallMethod( StandardAssociate,
    "method for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    if n < 0  then
        return -n;
    else
        return n;
    fi;
    end );


#############################################################################
##
#M  Valuation( <n>, <m> )
##
InstallOtherMethod( Valuation,
    "method for two integers",
    IsIdenticalObj,
    [ IsInt,
      IsInt ],
    0,

function( n, m )
    local val;

    if n = 0  then
        val := infinity;
    else
        val := 0;
        while n mod m = 0  do
            val := val + 1;
            n   := n / m;
        od;
    fi;
    return val;

end );


#############################################################################
##
#M  \in( <n>, <Integers> )  . . . . . . . . . .  membership test for integers
##
InstallMethod( \in,
    "method for integers",
    IsElmsColls,
    [ IsInt, IsIntegers ], 0,
    ReturnTrue );


#############################################################################
##
#F  PrintFactorsInt( <n> )  . . . . . . . . print factorization of an integer
##
##  'PrintFactorsInt'  prints the prime decomposition of the given integer n.
##
InstallGlobalFunction(PrintFactorsInt,function ( n )
    local decomp, i;

    if -4 < n and n < 4 then
        Print( n );
    else
        decomp := Collected( Factors( AbsInt( n ) ) );
        if n > 0 then
            Print( decomp[1][1] );
        else
            Print( -decomp[1][1] );
        fi;
        if decomp[1][2] > 1 then
            Print( "^", decomp[1][2] );
        fi;
        for i in [ 2 .. Length( decomp ) ] do
            Print( "*", decomp[i][1] );
            if decomp[i][2] > 1 then
                Print( "^", decomp[i][2] );
            fi;
        od;
    fi;
end);


#############################################################################
##
#E  integer.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


