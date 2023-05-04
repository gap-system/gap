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
##  This file is being maintained by Thomas Breuer.
##  Please do not make any changes without consulting him.
##  (This holds also for minor changes such as the removal of whitespace or
##  the correction of typos.)
##
##  This file contains methods for cyclotomics.
##


#############################################################################
##
#V  Cyclotomics . . . . . . . . . . . . . . . . . .  field of all cyclotomics
##
BindGlobal( "Cyclotomics", Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsField and IsAttributeStoringRep ),
    rec() ) );
SetName( Cyclotomics, "Cyclotomics" );
SetLeftActingDomain( Cyclotomics, Rationals );
SetIsFiniteDimensional( Cyclotomics, false );
SetIsFinite( Cyclotomics, false );
SetIsWholeFamily( Cyclotomics, true );
SetDegreeOverPrimeField( Cyclotomics, infinity );
SetDimension( Cyclotomics, infinity );
SetRepresentative(Cyclotomics, 0);


#############################################################################
##
#M  Conductor( <list> ) . . . . . . . . . . . . . . . . . . . . .  for a list
##
##  (This works not only for lists of cyclotomics but also for lists of
##  lists of cyclotomics etc.)
##
InstallOtherMethod( Conductor,
    "for a list",
    [ IsList ],
    function( list )
    local n, entry;
    n:= 1;
    for entry in list do
      n:= LcmInt( n, Conductor( entry ) );
    od;
    return n;
    end );


#############################################################################
##
#M  RoundCyc( <cyc> ) . . . . . . . . . . cyclotomic integer near to <cyc>
##
InstallMethod( RoundCyc, "general cyclotomic", [ IsCyclotomic ],
    function ( x )
    local n, cfs, int, i, c;
    n:= Conductor( x );
    cfs:= ExtRepOfObj( x );
    int:= EmptyPlist( n );
    for i in [ 1 .. n ] do
      c:= cfs[i];
      if IsInt( c ) then
        int[i]:= c;
      elif c < 0 then
        int[i]:= Int( c - 1/2 );
      else
        int[i]:= Int( c + 1/2 );
      fi;
    od;
    return CycList( int );
end );


#############################################################################
##
#M  RoundCycDown( <cyc> ) . . . . . . . . .  cyclotomic integer near to <cyc>
##                                                       rounding halves down
##
InstallMethod( RoundCycDown, "general cyclotomic", [ IsCyclotomic ],
    x -> CycList( List( ExtRepOfObj( x ), RoundCycDown ) ) );


#############################################################################
##
#M  ComplexConjugate( <cyc> )
#M  ComplexConjugate( <list> )
##
InstallMethod( ComplexConjugate,
    "for a cyclotomic",
    [ IsCyc ],
    cyc -> GaloisCyc( cyc, -1 ) );

InstallMethod( ComplexConjugate,
    "for a list",
    [ IsList ],
    function( list )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        result[i]:= ComplexConjugate( list[i] );
      fi;
    od;
    return result;
    end );


#############################################################################
##
#M  RealPart( <z> )
#M  RealPart( <list> )
##
InstallMethod( RealPart,
    "for a scalar",
    [ IsScalar ],
    z -> ( z + ComplexConjugate( z ) ) / 2 );

InstallMethod( RealPart,
    "for a list",
    [ IsList ],
    function( list )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        result[i]:= RealPart( list[i] );
      fi;
    od;
    return result;
    end );


#############################################################################
##
#M  ImaginaryPart( <z> )
#M  ImaginaryPart( <list> )
##
InstallMethod( ImaginaryPart,
    "for a cyclotomic",
    [ IsCyc ],
    z -> E(4) * ( ComplexConjugate( z ) - z ) / 2 );

InstallMethod( ImaginaryPart,
    "for a list",
    [ IsList ],
    function( list )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        result[i]:= ImaginaryPart( list[i] );
      fi;
    od;
    return result;
    end );


#############################################################################
##
#M  ExtRepOfObj( <cyc> )
##
##  <#GAPDoc Label="ExtRepOfObj:cyclotomics">
##  <ManSection>
##  <Meth Name="ExtRepOfObj" Arg='cyc' Label="for a cyclotomic"/>
##
##  <Description>
##  The external representation of a cyclotomic <A>cyc</A> with conductor
##  <M>n</M> (see <Ref Attr="Conductor" Label="for a cyclotomic"/> is
##  the list returned by <Ref Func="CoeffsCyc"/>,
##  called with <A>cyc</A> and <M>n</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> ExtRepOfObj( E(5) ); CoeffsCyc( E(5), 5 );
##  [ 0, 1, 0, 0, 0 ]
##  [ 0, 1, 0, 0, 0 ]
##  gap> CoeffsCyc( E(5), 15 );
##  [ 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( ExtRepOfObj,
    "for an internal cyclotomic",
    [ IsCyc and IsInternalRep ],
    COEFFS_CYC );


#############################################################################
##
#F  CoeffsCyc( <z>, <N> )
##
InstallGlobalFunction( CoeffsCyc, function( z, N )
    local coeffs,      # coefficients list (also intermediately)
          n,           # length of `coeffs'
          quo,         # factor by that we have to blow up
          s,           # denominator of `quo' (we have to reduce)
          factors,     #
          second,      # product of primes in second reduction step
          first,
          val,
          kk,
          pos,
          j,
          k,
          p,
          nn,
          newcoeffs;

    if IsCyc( z ) then

      # `z' is an internal cyclotomic, and therefore it is represented
      # in the smallest possible cyclotomic field.

      coeffs:= ExtRepOfObj( z ); # returns `CoeffsCyc( z, Conductor( z ) )'
      n:= Length( coeffs );
      quo:= N / n;
      if not IsInt( quo ) then
        return fail;
      fi;

    else

      # `z' is already a coefficients list
      coeffs:= z;
      n:= Length( coeffs );
      quo:= N / n;
      if not IsInt( quo ) then

        # Maybe `z' was not represented with respect to
        # the smallest possible cyclotomic field.
        # Try to reduce `z' until the denominator $s$ disappears.

        s:= DenominatorRat( quo );

        # step 1.
        # First we get rid of
        # - the $p$-parts for those primes $p$ that divide both $s$
        #   and $n / s$, and hence remain in the reduced expression,
        # - all primes but the squarefree part of the rest.

        factors:= PrimeDivisors( s );
        second:= 1;
        for p in factors do
          if s mod p <> 0 or ( n / s ) mod p <> 0 then
            second:= second * p;
          fi;
        od;
        if second mod 2 = 0 then
          second:= second / 2;
        fi;
        first:= s / second;
        if first > 1 then
          newcoeffs:= ListWithIdenticalEntries( n / first, 0 );
          for k in [ 1 .. n ] do
            if coeffs[k] <> 0 then
              pos:= ( k - 1 ) / first + 1;
              if not IsInt( pos ) then
                return fail;
              fi;
              newcoeffs[ pos ]:= coeffs[k];
            fi;
          od;
          n:= n / first;
          coeffs:= newcoeffs;
        fi;

        # step 2.
        # Now we process those primes that shall disappear
        # in the reduced form.
        # Note that $p-1$ of the coefficients congruent modulo $n/p$
        # must be equal, and the negative of this value is put at the
        # position of the $p$-th element of this congruence class.
        if second > 1 then
          for p in Factors(Integers, second ) do
            nn:= n / p;
            newcoeffs:= ListWithIdenticalEntries( nn, 0 );
            for k in [ 1 .. n ] do
              pos:= 0;
              if coeffs[k] <> 0 then
                val:= coeffs[k];
                for j in [ 1 .. p-1 ] do
                  kk:= ( ( k - 1 + j*nn ) mod n ) + 1;
                  if coeffs[ kk ] = val then
                    coeffs[ kk ]:= 0;
                  elif pos <> 0 or coeffs[kk] <> 0 or kk mod p <> 1 then
                    return fail;
                  else
                    pos:= ( kk - 1 ) / p + 1;
                  fi;
                od;
                newcoeffs[ pos ]:= - val;
              fi;
            od;
            n:= nn;
            coeffs:= newcoeffs;
          od;
        fi;
        quo:= NumeratorRat( quo );

      fi;

    fi;

    # If necessary then blow up the representation in two steps.

    # step 1.
    # For each prime `p' not dividing `n' we replace
    # `E(n)^k' by $ - \sum_{j=1}^{p-1} `E(n*p)^(p*k+j*n)'$.
    if quo <> 1 then

      for p in PrimeDivisors( quo ) do
        if p <> 2 and n mod p <> 0 then
          nn  := n * p;
          quo := quo / p;
          newcoeffs:= ListWithIdenticalEntries( nn, 0 );
          for k in [ 1 .. n ] do
            if coeffs[k] <> 0 then
              for j in [ 1 .. p-1 ] do
                newcoeffs[ ( ( (k-1)*p + j*n  ) mod nn ) + 1 ]:= -coeffs[k];
              od;
            fi;
          od;
          coeffs:= newcoeffs;
          n:= nn;
        fi;
      od;

    fi;

    # step 2.
    # For the remaining divisors of `quo' we have
    # `E(n*p)^(k*p)' in the basis for each basis element `E(n)^k'.
    if quo <> 1 then

      n:= Length( coeffs );
      newcoeffs:= ListWithIdenticalEntries( quo*n, 0 );
      for k in [ 1 .. Length( coeffs ) ] do
        if coeffs[k] <> 0 then
          newcoeffs[ (k-1)*quo + 1 ]:= coeffs[k];
        fi;
      od;
      coeffs:= newcoeffs;

    fi;

    # Return the coefficients list.
    return coeffs;
end );


#############################################################################
##
#F  IsGaussInt(<x>) . . . . . . . . . test if an object is a Gaussian integer
##
InstallGlobalFunction( IsGaussInt,
    x -> IsCycInt( x ) and (Conductor( x ) = 1 or Conductor( x ) = 4) );


#############################################################################
##
#F  IsGaussRat( <x> ) . . . . . . .  test if an object is a Gaussian rational
##
InstallGlobalFunction( IsGaussRat,
    x -> IsCyc( x ) and (Conductor( x ) = 1 or Conductor( x ) = 4) );


##############################################################################
##
#F  DescriptionOfRootOfUnity( <root> )
##
##  Let $\zeta$ denote the primitive $n$-th root of unity $`E'(n)$,
##  and suppose that we know the coefficients of $\pm\zeta^i$ w.r.t.
##  the $n$-th Zumbroich basis (see~"ZumbroichBasis").
##  These coefficients are either all $1$ or all $-1$.
##  More precisely, they arise in the base conversion from (formally)
##  successively multiplying $\pm\zeta^i$ by
##  $1 = - \sum_{j=1}^{p-1} \zeta^{jn/p}$,
##  for suitable prime diviors $p$ of $n$,
##  and then treating the summands $\pm\zeta^{i + jn/p}$ in the same way
##  until roots in the basis are reached.
##  It should be noted that all roots obtained this way are distinct.
##
##  Suppose the above procedure must be applied for the primes
##  $p_1$, $p_2$, \ldots, $p_r$.
##  Then $\zeta^i$ is equal to
##  $(-1)^r \sum_{j_1=1}^{p_1-1} \cdots \sum_{j_r=1}^{p_r-1}
##  \zeta^{i + \sum_{k=1}^r j_k n/p_k}$.
##  The number of summands is $m = \prod_{k=1}^r (p_k-1)$.
##  Since these roots are all distinct, we can compute the sum $s$ of their
##  exponents modulo $n$ from the known coefficients of $\zeta^i$,
##  and we get $s \equiv m ( i + r n/2 ) \pmod{n}$.
##  Either $m = 1$ or $m$ is even,
##  hence this congruence determines $\zeta^i$ at most up to its sign.
##
##  Now suppose that $g = \gcd( m, n )$ is nontrivial.
##  Then $i$ is determined only modulo $n/g$, and we have to decide which
##  of the $g$ possible values $i$ is.
##  This could be done by computing the values $j_{0,p}$ for one
##  candidate $i$, where $p$ runs over the prime divisors $p$ of $n$
##  for which $m$ is the product of $(p-1)$.
##
##  (Recall that each $n$-th root of unity is of the form
##  $\prod_{p\in P} \prod_{k_p=1}^{\nu_p-1} \zeta^{j_{k,p}n/p^{k_p+1}}$,
##  with $j_{0,p} \in \{ 0, 1, \ldots, p-1 \}$, $j_{k,2} \in \{ 0, 1 \}$
##  for $k > 0$, and $j_{k,p} \in \{ -(p-1)/2, \ldots, (p-1)/2 \}$ for
##  $p > 2$.
##  The root is in the $n$-th Zumbroich basis if and only if $j_{0,2} = 0$
##  and $j_{0,p} \not= 0$ for $p > 2$.)
##
##  But note that we do not have an easy access to the decomposition
##  of $m$ into factors $(p-1)$,
##  although in fact this decomposition is unique for $n \leq 65000$.
##
##  So the exponent is identified by dividing off one of the candidates
##  and then identifying the quotient, which is a $g$-th or $2 g$-th
##  root of unity.
##  (Note that $g$ is small compared to $n$.
##  $m$ divides the product of $(p-1)$ for prime divisors $p$
##  that divide $n$ at least with exponent $2$.
##  The maximum of $g$ for $n \leq 65000$ is $40$, so $2$ steps suffice
##  for these values of $n$.)
##
InstallGlobalFunction( DescriptionOfRootOfUnity, function( root )
    local coeffs,   # Zumbroich basis coefficients of `root'
          n,        # conductor of `n'
          sum,      # sum of exponents with nonzero coefficients
          num,      # number of nonzero coefficients
          i,        # loop variable
          val,      # one coefficient
          coeff,    # one nonzero coefficient (either `1' or `-1')
          exp,      # candidate for the exponent
          g,        # `Gcd( n, num )'
          groot;    # root in recursion

    # Handle the trivial cases that `root' is an integer.
    if root = 1 then
      return [ 1, 1 ];
    elif root = -1 then
      return [ 2, 1 ];
    fi;
    Assert( 1, not IsRat( root ) );

    # Compute the Zumbroich basis coefficients,
    # and number and sum of exponents with nonzero coefficient (mod `n').
    coeffs:= ExtRepOfObj( root );
    n:= Length( coeffs );
    sum:= 0;
    num:= 0;
    for i in [ 1 .. n ] do
      val:= coeffs[i];
      if val <> 0 then
        sum:= sum + i;
        num:= num + 1;
        coeff:= val;
      fi;
    od;
    sum:= sum - num;

    # `num' is equal to `1' if and only if `root' or its negative
    # belongs to the basis.
    # (The coefficient is equal to `-1' if and only if either
    # `n' is a multiple of $4$ or
    # `n' is odd and `root' is a primitive $2 `n'$-th root of unity.)
    if num = 1 then
      if coeff < 0 then
        if n mod 2 = 0 then
          sum:= sum + n/2;
        else
          sum:= 2*sum + n;
          n:= 2*n;
        fi;
      fi;
      Assert( 1, root = E(n)^sum );
      return [ n, sum mod n ];
    fi;

    # Let $N$ be `n' if `n' is even, and equal to $2 `n'$ otherwise.
    # The exponent is determined modulo $N / \gcd( N, `num' )$.
    g:= GcdInt( n, num );
    if g = 1 then

      # If `n' and `num' are coprime then `root' is identified up to its sign.
      exp:= ( sum / num ) mod n;
      if root <> E(n)^exp then
        exp:= 2*exp + n;
        n:= 2*n;
      fi;

    elif g = 2 then

      # `n' is even, and again `root' is determined up to its sign.
      exp:= ( sum / num ) mod ( n / 2 );
      if root <> E(n)^exp then
        exp:= exp + n / 2;
      fi;

    else

      # Divide off one of the candidates.
      # The quotient is a `g'-th or $2 `g'$-th root of unity,
      # which can be identified by recursion.
      exp:= ( sum / num ) mod ( n / g );
      groot:= DescriptionOfRootOfUnity( root * E(n)^(n-exp) );
      if n mod 2 = 1 and groot[1] mod 2 = 0 then
        exp:= 2*exp;
        n:= 2*n;
      fi;
      exp:= exp + groot[2] * n / groot[1];

    fi;

    # Return the result.
    Assert( 1, root = E(n)^exp );
    return [ n, exp mod n ];
end );


#############################################################################
##
#F  Atlas1( <n>, <i> )  . . . . . . . . . . . . . . . utility for EB, ..., EH
##
##  is the value $\frac{1}{i} \sum{j=1}^{n-1} z_n^{j^i}$
##  for $2 \leq i \leq 8$ and $<n> \equiv 1 \pmod{i}$;
##  if $i > 2$, <n> should be a prime to get sure that the result is
##  well-defined;
##  `Atlas1' returns the value given above if it is a cyclotomic integer.
##  (see: Conway et al, ATLAS of finite groups, Oxford University Press 1985,
##        Chapter 7, Section 10)
##
BindGlobal( "Atlas1", function( n, i )
    local atlas, k, pos;

    if not IsInt( n ) or n < 1 then
      Error( "usage: EB(<n>), EC(<n>), ..., EH(<n>) with appropriate ",
             "integer <n>" );
    elif n mod i <> 1 then
      Error( "<n> not congruent 1 mod ", i );
    fi;

    if n = 1 then
      return 0;
    fi;

    atlas:= [ 1 .. n ] * 0;

    if i mod 2 = 0 then
      # Note that `n' is odd in this case.
      for k in [ 1 .. QuoInt( n-1, 2 ) ] do
        # summand `2 * E(n)^(k^i)'
        pos:= ( (k^i) mod n ) + 1;
        atlas[ pos ]:= atlas[ pos ] + 2;
      od;
    else
      for k in [ 1 .. QuoInt( n-1, 2 ) ] do
        # summand `E(n)^(k^i) + E(n)^(n - k^i)'
        pos:= ( (k^i) mod n ) + 1;
        atlas[ pos ]:= atlas[ pos ] + 1;
        pos:= ( n - pos + 1 ) mod n + 1;
        atlas[ pos ]:= atlas[ pos ] + 1;
      od;
      if n mod 2 = 0 then
        # summand `E(n)^( (n/2)^i )'
        pos:= ( ( (n/2)^i ) mod n ) + 1;
        atlas[ pos ]:= atlas[ pos ] + 1;
      fi;
    fi;
    atlas:= CycList( atlas / i );
    if not IsCycInt( atlas ) then
      Error( "result divided by ", i, " is not a cyclotomic integer" );
    fi;
    return atlas;
end );


#############################################################################
##
#F  EB( <n> ), EC( <n> ), \ldots, EH( <n> ) . . .  some ATLAS irrationalities
##
InstallGlobalFunction( EB, n -> Atlas1( n, 2 ) );
InstallGlobalFunction( EC, n -> Atlas1( n, 3 ) );
InstallGlobalFunction( ED, n -> Atlas1( n, 4 ) );
InstallGlobalFunction( EE, n -> Atlas1( n, 5 ) );
InstallGlobalFunction( EF, n -> Atlas1( n, 6 ) );
InstallGlobalFunction( EG, n -> Atlas1( n, 7 ) );
InstallGlobalFunction( EH, n -> Atlas1( n, 8 ) );


#############################################################################
##
#F  NK( <n>, <k>, <d> ) . . . . . . . . . . utility for ATLAS irrationalities
##
##  Find the (<d>+1)-st automorphism *nk of order <k> on primitive <n>-th
##  roots of unity.
##
##  Optimization steps:
##  - Since <k> is very small, `PowerModInt' should be avoided, compared to
##    powering and then reducing mod <n>.
##  - Do not call `Phi' but look at the prime factors of <n> directly.
##  - Use multiplication instead of powering for computing squares.
##
InstallGlobalFunction( NK, function( n, k, deriv )
    local nk,
          nkn,   # nk mod n
          n1,    # n-1
          pow, pow2, pow3;

    if n <= 2 then
      return fail;
    fi;

    nk:= 1;
    nkn:= 1;
    n1:= n-1;
    if k = 2 then
      # We have always `Phi( n ) mod k = 0'.
      while true do
        if nkn <> 1 then
          # `*nk' has order larger than 1.
          pow:= (nkn * nkn) mod n;
          if pow = 1 then
            # `*nk' has order 2.
            if deriv = 0 then return nk; fi;
            deriv:= deriv - 1;
            if nkn <> n1 then
              # `**nk' has order larger than 1 and thus equal to 2.
              if deriv = 0 then return -nk; fi;
              deriv:= deriv - 1;
            fi;
          fi;
        elif nkn <> n1 then
          # `**nk' has order larger than 1.
          pow:= (nkn * nkn) mod n;
          if pow = 1 then
            # `**nk' has order dividing 2.
            if deriv = 0 then return -nk; fi;
            deriv:= deriv - 1;
          fi;
        fi;
        nk:= nk + 1;
        nkn:= nk mod n;
      od;
    elif k in [ 3, 5, 7 ] then   # for odd primes
      if ( n mod ( k*k ) <> 0 ) and
         ForAll( PrimeDivisors( n ), p -> (p-1) mod k <> 0 ) then
        return fail;
      fi;
      while true do
        if nkn <> 1 then
          # `*nk' has order larger than 1.
          pow:= (nkn ^ k) mod n;
          if pow = 1 then
            # `*nk' has order dividing `k'.
            if deriv = 0 then return nk; fi;
            deriv:= deriv - 1;
          fi;
          if nkn <> n1 and pow = n1 then
            # `**nk' has order larger than 1 and dividing `k'.
            if deriv = 0 then return -nk; fi;
            deriv:= deriv - 1;
          fi;
        elif nkn <> n1 then
          # `**nk' has order larger than 1.
          pow:= (nkn ^ k) mod n;
          if pow = n1 then
            # `**nk' has order dividing `k'.
            if deriv = 0 then return -nk; fi;
            deriv:= deriv - 1;
          fi;
        fi;
        nk:= nk + 1;
        nkn:= nk mod n;
      od;
    elif k = 4 then
      # An automorphism of order 4 exists if 4 divides $p-1$ for an odd
      # prime divisor $p$ of `n', or if 16 divides `n'.
      if ForAll( PrimeDivisors( n ), p -> (p-1) mod k <> 0 )
         and n mod 16 <> 0 then
        return fail;
      fi;
      while true do
        if nkn <> 1 and nkn <> n1 then
          # `*nk' and `**nk' have order at least 2.
          pow:= (nkn * nkn) mod n;
          if pow <> 1 and ( pow * pow ) mod n = 1 then
            # `*nk' (and thus also `**nk') has order 4.
            if deriv = 0 then
              return nk;
            elif deriv = 1 then
              return -nk;
            fi;
            deriv:= deriv - 2;
          fi;
        fi;
        nk:= nk + 1;
        nkn:= nk mod n;
      od;
    elif k = 6 then
      # An automorphism of order 6 exists if automorphisms of the orders
      # 2 and 3 exist; the former is always true.
      if ( n mod 9 <> 0 ) and
         ForAll( PrimeDivisors( n ), p -> (p-1) mod 3 <> 0 ) then
        return fail;
      fi;
      while true do
        if nkn <> 1 and nkn <> n1 then
          # `*nk' and `**nk' have order at least 2.
          pow2:= (nkn * nkn) mod n;
          if pow2 <> 1 then
            # `*nk' (and thus `**nk') has order larger than 2.
            pow:= (pow2 ^ 3) mod n;
            if pow = 1 then
              # `*nk' (and thus `**nk') has order dividing 6.
              pow3:= (nkn * pow2) mod n;
              if pow3 <> 1 then
                if deriv = 0 then return nk; fi;
                deriv:= deriv - 1;
              fi;
              if pow3 <> n1 then
                if deriv = 0 then return -nk; fi;
                deriv:= deriv - 1;
              fi;
            fi;
          fi;
        fi;
        nk:= nk + 1;
        nkn:= nk mod n;
      od;
    elif k = 8 then
      # An automorphism of order 8 exists if 8 divides $p-1$ for an odd
      # prime divisor $p$ of `n', or if 32 divides `n'.
      if ForAll( PrimeDivisors( n ), p -> (p-1) mod k <> 0 )
         and n mod 32 <> 0 then
        return fail;
      fi;
      while true do
        if nkn <> 1 and nkn <> n1 then
          # `*nk' and `**nk' have order at least 2.
          pow:= (nkn ^ 4) mod n;
          if pow <> 1 and ( pow * pow ) mod n = 1 then
            # `*nk' (and thus also `**nk') has order 8.
            if deriv = 0 then
              return nk;
            elif deriv = 1 then
              return -nk;
            fi;
            deriv:= deriv - 2;
          fi;

        fi;
        nk:= nk + 1;
        nkn:= nk mod n;
      od;
    fi;

    # We have `k < 2' or `k > 8'.
    return fail;
end );


#############################################################################
##
#F  Atlas2( <n>, <k>, <deriv> ) . . . . . . utility for ATLAS irrationalities
##
BindGlobal( "Atlas2", function( n, k, deriv )
    local nk, result, i, pos;

    if not ( IsInt( n ) and IsInt( k ) and IsInt( deriv ) ) then
      Error( "usage: ATLAS irrationalities require integral arguments" );
    fi;

    nk:= NK( n, k, deriv );
    if nk = fail then
      return fail;
    fi;

    result:= [ 1 .. n ] * 0;
    for i in [ 0 .. k-1 ] do
      # summand `E(n)^(nk^i);
      pos:= ( (nk^i) mod n ) + 1;
      result[ pos ]:= result[ pos ] + 1;
    od;
    return CycList( result );
end );


#############################################################################
##
#F  EY(<n>), EY(<n>,<deriv>) . . . . . . .  ATLAS irrationalities $y_n$ resp.
#F                                          $y_n^{<deriv>}$
#F  ... ES(<n>), ES(<n>,<deriv>)              ... $s_n$ resp. $s_n^{<deriv>}$
##
InstallGlobalFunction( EY, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],2,0);
    elif Length(arg)=2 then return Atlas2(arg[1],2,arg[2]);
    else Error( "usage: EY(n) resp. EY(n,deriv)" ); fi;
end );

InstallGlobalFunction( EX, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],3,0);
    elif Length(arg)=2 then return Atlas2(arg[1],3,arg[2]);
    else Error( "usage: EX(n) resp. EX(n,deriv)" ); fi;
end );

InstallGlobalFunction( EW, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],4,0);
    elif Length(arg)=2 then return Atlas2(arg[1],4,arg[2]);
    else Error( "usage: EW(n) resp. EW(n,deriv)" ); fi;
end );

InstallGlobalFunction( EV, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],5,0);
    elif Length(arg)=2 then return Atlas2(arg[1],5,arg[2]);
    else Error( "usage: EV(n) resp. EV(n,deriv)" ); fi;
end );

InstallGlobalFunction( EU, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],6,0);
    elif Length(arg)=2 then return Atlas2(arg[1],6,arg[2]);
    else Error( "usage: EU(n) resp. EU(n,deriv)" ); fi;
end );

InstallGlobalFunction( ET, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],7,0);
    elif Length(arg)=2 then return Atlas2(arg[1],7,arg[2]);
    else Error( "usage: ET(n) resp. ET(n,deriv)" ); fi;
end );

InstallGlobalFunction( ES, function(arg)
    if   Length(arg)=1 then return Atlas2(arg[1],8,0);
    elif Length(arg)=2 then return Atlas2(arg[1],8,arg[2]);
    else Error( "usage: ES(n) resp. ES(n,deriv)" ); fi;
end );


#############################################################################
##
#F  Atlas3( <n>, <k>, <deriv> ) . . . . . . utility for ATLAS irrationalities
##
BindGlobal( "Atlas3", function( n, k, deriv )
    local nk, l, pow, val, i;

    nk:= NK( n, k, deriv );
    if nk = fail then
      return fail;
    fi;
    l:= 0 * [ 1 .. n ];
    pow:= 1;
    val:= 1;
    for i in [ 1 .. k ] do
      l[ pow + 1 ]:= val;
      pow:= (nk * pow) mod n;
      val:= -val;
    od;

    return CycList( l );
end );


#############################################################################
##
#F  EM( <n>[, <deriv>] )  . . . . . . . . ATLAS irrationality $m_{<n>}$ resp.
##                                                        $m_{<n>}^{<deriv>}$
InstallGlobalFunction( EM, function( arg )
    local n;

    n:= arg[1];
    if 2 < Length( arg ) or not IsInt( n ) or n < 3 then
      Error( "usage: EM( <n>[, <deriv>] )" );
    elif Length( arg ) = 1 then
      return Atlas3( n, 2, 0 );
    else
      return Atlas3( n, 2, arg[2] );
    fi;
end );


#############################################################################
##
#F  EL( <n>[, <deriv>] )  . . . . . . . . ATLAS irrationality $l_{<n>}$ resp.
##                                                        $l_{<n>}^{<deriv>}$
InstallGlobalFunction( EL, function( arg )
    local n;

    n:= arg[1];
    if 2 < Length( arg ) or not IsInt( n ) or n < 3 then
      Error( "usage: EL( <n>[, <deriv>] )" );
    elif Length( arg ) = 1 then
      return Atlas3( n, 4, 0 );
    else
      return Atlas3( n, 4, arg[2] );
    fi;
end );


#############################################################################
##
#F  EK( <n>[, <deriv>] )  . . . . . . . . ATLAS irrationality $k_{<n>}$ resp.
##                                                        $k_{<n>}^{<deriv>}$
InstallGlobalFunction( EK, function( arg )
    local n;

    n:= arg[1];
    if 2 < Length( arg ) or not IsInt( n ) or n < 3 then
      Error( "usage: EK( <n>[, <deriv>] )" );
    elif Length( arg ) = 1 then
      return Atlas3( n, 6, 0 );
    else
      return Atlas3( n, 6, arg[2] );
    fi;
end );


#############################################################################
##
#F  EJ( <n>[, <deriv>] )  . . . . . . . . ATLAS irrationality $j_{<n>}$ resp.
##                                                        $j_{<n>}^{<deriv>}$
InstallGlobalFunction( EJ, function( arg )
    local n;

    n:= arg[1];
    if 2 < Length( arg ) or not IsInt( n ) or n < 3 then
      Error( "usage: EJ( <n>[, <deriv>] )" );
    elif Length( arg ) = 1 then
      return Atlas3( n, 8, 0 );
    else
      return Atlas3( n, 8, arg[2] );
    fi;
end );


#############################################################################
##
#F  ER( <n> ) . . . . ATLAS irrationality $r_{<n>}$ (pos. square root of <n>)
##
##  Different from other {\ATLAS} irrationalities,
##  `ER' (and its synonym `Sqrt') can be applied also to noninteger
##  rationals.
##
InstallGlobalFunction( ER, function( n )
    local factor, factors, pair;

    if IsInt( n ) then

      if n = 0 then
        return 0;
      elif n < 0 then
        factor:= E(4);
        n:= -n;
      else
        factor:= 1;
      fi;

      # Split `n' into the product of a square and a squarefree number.
      factors:= Collected( Factors( n ) );
      n:= 1;
      for pair in factors do
        if pair[2] mod 2 = 0 then
          factor:= factor * pair[1]^(pair[2]/2);
        else
          n:= n * pair[1];
          if pair[2] <> 1 then
            factor:= factor * pair[1]^((pair[2]-1)/2);
          fi;
        fi;
      od;
      if   n mod 4 = 1 then
        return factor * ( 2 * EB(n) + 1 );
      elif n mod 4 = 2 then
        return factor * ( E(8) - E(8)^3 ) * ER( n / 2 );
      elif n mod 4 = 3 then
        return factor * (-E(4)) * ( 2 * EB(n) + 1 );
      fi;

    elif IsRat( n ) then
      factor:= DenominatorRat( n );
      return ER( NumeratorRat( n ) * factor ) / factor;
    else
      Error( "argument must be rational" );
    fi;
end );


#############################################################################
##
#F  EI( <n> ) . . . . ATLAS irrationality $i_{<n>}$ (the square root of -<n>)
##
InstallGlobalFunction( EI, n -> E(4) * ER(n) );


#############################################################################
##
#M  Sqrt( <rat> ) . . . . . . . . . . . . . . . . .  square root of rationals
##
InstallMethod( Sqrt,
    "for a rational",
    [ IsRat ],
    ER );


#############################################################################
##
#F  StarCyc( <cyc> )  . . . . the unique nontrivial Galois conjugate of <cyc>
##
InstallGlobalFunction( StarCyc, function( cyc )
    local n, gens, cand, exp, img;

    n:= Conductor( cyc );
    if n = 1 then
      return fail;
    fi;
    gens:= Flat( GeneratorsPrimeResidues( n ).generators );
    cand:= fail;
    for exp in gens do
      img:= GaloisCyc( cyc, exp );
      if img <> cyc then
        if cand = fail then
          cand:= img;
        elif cand <> img then
          return fail;
        fi;
      fi;
    od;
    for exp in gens do
      img:= GaloisCyc( cand, exp );
      if img <> cyc and img <> cand then
        return fail;
      fi;
    od;
    return cand;
    end );


#############################################################################
##
#F  AtlasIrrationality( <irratname> )
##
InstallGlobalFunction( AtlasIrrationality, function( irratname )
    local len, pos, sign, pos2, coeff, letts, funcs, recurse, lpos, N,
          dashes, irrat, qN, gal, oldpos;

    # Check the argument.
    if not IsString( irratname ) or IsEmpty( irratname ) then
      return fail;
    fi;
    len:= Length( irratname );

    # Get the first sign.
    pos:= 1;
    sign:= 1;
    if irratname[1] = '-' then
      sign:= -1;
      pos:= 2;
    elif irratname[1] = '+' then
      pos:= 2;
    fi;

    # Get the first coefficient.
    if pos <= len and IsDigitChar( irratname[ pos ] ) then
      pos2:= pos;
      while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
        pos2:= pos2+1;
      od;
      coeff:= sign * Int( irratname{ [ pos .. pos2-1 ] } );
      pos:= pos2;
    else
      coeff:= sign;
    fi;
    if len < pos then
      return coeff;
    fi;

    # Get the first atomic irrationality (with dashes).
    letts:= "bcdefghijklmrstuvwxyz";
    funcs:= List( "BCDEFGHIJKLMRSTUVWXY", x -> ValueGlobal( [ 'E', x ] ) );
    Add( funcs, E );

    # Is the coefficient an integer summand?
    if irratname[ pos ] in "+-" then
      recurse:= AtlasIrrationality( irratname{ [ pos ..
                    Length( irratname ) ] } );
      if recurse = fail then
        return fail;
      else
        return coeff + recurse;
      fi;
    fi;

    lpos:= Position( letts, irratname[ pos ] );
    if lpos = fail then
      return fail;
    fi;
    pos:= pos + 1;
    dashes:= 0;
    while pos <= len and irratname[ pos ] in "\'\"" do
      dashes:= dashes + 1;
      if irratname[ pos ] = '\"' then
        dashes:= dashes + 1;
      fi;
      pos:= pos + 1;
    od;
    pos2:= pos;
    while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
      pos2:= pos2+1;
    od;
    if pos2 = pos and lpos = 8 then
      N:= 1;
    else
      N:= Int( irratname{ [ pos .. pos2 - 1 ] } );
    fi;
    if dashes = 0 then
      qN:= funcs[ lpos ]( N );
    else
      qN:= funcs[ lpos ]( N, dashes );
    fi;
    pos:= pos2;
    irrat:= coeff * qN;
    if len < pos then
      return irrat;
    fi;

    # Get the Galois automorphism.
    if irratname[ pos ] = '*' then
      pos:= pos + 1;
      if pos <= len and irratname[ pos ] = '*' then
        pos:= pos + 1;
        pos2:= pos;
        while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
          pos2:= pos2 + 1;
        od;
        gal:= Int( irratname{ [ pos .. pos2-1 ] } );
        if gal = 0 then
          irrat:= ComplexConjugate( irrat );
        else
          irrat:= GaloisCyc( irrat, -gal );
        fi;
        pos:= pos2;
      elif len < pos or irratname[ pos ] in "+-&" then
        irrat:= StarCyc( irrat );
      else
        pos2:= pos;
        while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
          pos2:= pos2 + 1;
        od;
        gal:= Int( irratname{ [ pos .. pos2-1 ] } );
        irrat:= GaloisCyc( irrat, gal );
        pos:= pos2;
      fi;
    fi;

    while pos <= len do

      # Get ampersand summands.
      if irratname[ pos ] = '&' then
        pos2:= pos + 1;
        while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
          pos2:= pos2 + 1;
        od;
        gal:= Int( irratname{ [ pos+1 .. pos2-1 ] } );
        irrat:= irrat + coeff * GaloisCyc( qN, gal );
        pos:= pos2;
      elif irratname[ pos ] in "+-" then
        if irratname[ pos ] = '+' then
          sign:= 1;
          oldpos:= pos+1;
        else
          sign:= -1;
          oldpos:= pos;
        fi;
        pos2:= pos + 1;
        while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
          pos2:= pos2 + 1;
        od;
        if pos2 = pos + 1 then
          coeff:= sign;
        else
          coeff:= sign * Int( irratname{ [ pos+1 .. pos2-1 ] } );
        fi;
        pos:= pos2;
        if pos <= len then
          if irratname[ pos ] = '&' then
            pos2:= pos + 1;
            while pos2 <= len and IsDigitChar( irratname[ pos2 ] ) do
              pos2:= pos2 + 1;
            od;
            gal:= Int( irratname{ [ pos+1 .. pos2-1 ] } );
            irrat:= irrat + coeff * GaloisCyc( qN, gal );
            pos:= pos2;
          else
            recurse:= AtlasIrrationality( irratname{ [ oldpos .. len ] } );
            if recurse = fail then
              return fail;
            fi;
            irrat:= irrat + recurse;
            pos:= len+1;
          fi;
        else
          irrat:= irrat + coeff;
        fi;
      else
        return fail;
      fi;

    od;

    # Return the result.
    return irrat;
end );


#############################################################################
##
#F  Quadratic( <cyc>[, <rat>] ) . information about quadratic irrationalities
##
InstallGlobalFunction( Quadratic, function( arg )
    local cyc,
          rat,
          denom,
          coeffs,     # Zumbroich basis coefficients of `cyc'
          facts,      # factors of conductor of `cyc'
          factsset,   # set of `facts'
          two_part,   # 2-part of the conductor of `cyc'
          root,       # `root' component of the result
          a,          # `a'    component of the result
          b,          # `b'    component of the result
          d,          # `d'    component of the result
          ATLAS,      # string that expresses `cyc' in {\sf ATLAS} format
          ATLAS2,     # another string, maybe shorter ...
          display;    # string that shows a way to input `cyc'

    cyc:= arg[1];
    rat:= Length( arg ) = 2 and arg[2] = true;

    if not IsCyc( cyc ) then
      return fail;
    fi;
    denom:= DenominatorCyc( cyc );
    if not ( rat or denom = 1 ) then
      return fail;
    fi;
    if IsRat( cyc ) then
      return rec(
                  a       := NumeratorRat( cyc ),
                  b       := 0,
                  root    := 1,
                  d       := denom,
                  ATLAS   := String( cyc ),
                  display := String( cyc )
                 );
    fi;
    if denom <> 1 then
      cyc:= cyc * denom;
    fi;

    coeffs:= ExtRepOfObj( cyc );
    facts:= Factors(Integers, Length( coeffs ) );
    factsset:= Set( facts );
    two_part:= Number( facts, x -> x = 2 );

    # Compute candidates for `a', `b', `root', `d'.
    if two_part = 0 and Length( facts ) = Length( factsset ) then

      root:= Length( coeffs );
      if root mod 4 = 3 then
        root:= -root;
      fi;
      a:= StarCyc( cyc );
      if a = fail then
        return fail;
      fi;

      # Set `a' to the trace of `cyc' over the rationals.
      a:= cyc + a;

      if Length( factsset ) mod 2 = 0 then
        b:= 2 * coeffs[2] - a;
      else
        b:= 2 * coeffs[2] + a;
      fi;
      if a mod 2 = 0 and b mod 2 = 0 then
        a:= a / 2;
        b:= b / 2;
        d:= 1;
      else
        d:= 2;
      fi;

    elif two_part = 2 and Length( facts ) = Length( factsset ) + 1 then

      root:= Length( coeffs ) / 4;
      if root = 1 then
        a:= coeffs[1];
        b:= - coeffs[2];
      else
        a:= coeffs[5];
        if Length( factsset ) mod 2 = 0 then a:= -a; fi;
        b:= - coeffs[ root + 5 ];
      fi;
      if root mod 4 = 1 then
        root:= -root;
        b:= -b;
      fi;
      d:= 1;

    elif two_part = 3 then

      root:= Length( coeffs ) / 4;
      if root = 2 then
        a:= coeffs[1];
        b:= coeffs[2];
        if b = coeffs[4] then
          root:= -2;
        fi;
      else
        a:= coeffs[9];
        if Length( factsset ) mod 2 = 0 then a:= -a; fi;
        b:= coeffs[ root / 2 + 9 ];
        if b <> - coeffs[ 3 * root / 2 - 7 ] then
          root:= -root;
        elif ( root / 2 ) mod 4 = 3 then
          b:= -b;
        fi;
      fi;
      d:= 1;

    else
      return fail;
    fi;

    # Check whether the candidates `a', `b', `d', `root' are correct.
    if d * cyc <> a + b * ER( root ) then
      return fail;
    fi;

    # Compute a string for the irrationality in {\ATLAS} format.
    if d = 2 then

      # Necessarily `root' is congruent 1 mod 4, only $b_{'root'}$ possible.
      # We have $'cyc' = ('a' + `b') / 2 + `b' b_{'root'}$.
      if a + b = 0 then
        if b = 1 then
          ATLAS:= "";
        elif b = -1 then
          ATLAS:= "-";
        else
          ATLAS:= ShallowCopy( String( b ) );
        fi;
      elif b = 1 then
        ATLAS:= Concatenation( String( ( a + b ) / 2 ), "+" );
      elif b = -1 then
        ATLAS:= Concatenation( String( ( a + b ) / 2 ), "-" );
      elif 0 < b then
        ATLAS:= Concatenation( String( ( a + b ) / 2 ), "+", String( b ) );
      else
        ATLAS:= Concatenation( String( ( a + b ) / 2 ), String( b ) );
      fi;

      Append( ATLAS, "b" );
      if 0 < root then
        Append( ATLAS, String( root ) );
      else
        Append( ATLAS, String( -root ) );
      fi;

    else

      # `d' = 1, so we may use $i_{'root'}$ and $r_{'root'}$.
      if a = 0 then
        ATLAS:= "";
      else
        ATLAS:= ShallowCopy( String( a ) );
      fi;
      if a <> 0 and b > 0 then Append( ATLAS, "+" ); fi;
      if b = -1 then
        Append( ATLAS, "-" );
      elif b <> 1 then
        Append( ATLAS, String( b ) );
      fi;
      if root > 0 then
        ATLAS:= Concatenation( ATLAS, "r", String( root ) );
      elif root = -1 then
        Append( ATLAS, "i" );
      else
        ATLAS:= Concatenation( ATLAS, "i", String( -root ) );
      fi;

      if ( root - 1 ) mod 4 = 0 then

        # In this case, also $b_{|'root'|}$ is possible.
        # Note that here the coefficients are never equal to $\pm 1$.
        if a = -b then
          ATLAS2:= String( 2 * b );
        else
          ATLAS2:= Concatenation( String( a+b ), "+", String( 2*b ) );
        fi;
        if root > 0 then
          ATLAS2:= Concatenation( ATLAS2, "b", String( root ) );
        else
          ATLAS2:= Concatenation( ATLAS2, "b", String( -root ) );
        fi;

        if Length( ATLAS2 ) < Length( ATLAS ) then
          ATLAS:= ATLAS2;
        fi;

      fi;

    fi;
    if denom <> 1 then
      ATLAS:= Concatenation( "(", ATLAS, ")/", String( denom ) );
    fi;
    ConvertToStringRep( ATLAS );

    # Compute a string used by the `Display' function for character tables.
    if a = 0 then
      if b = 1 then
        display:= "";
      elif b = -1 then
        display:= "-";
      else
        display:= Concatenation( String( b ), "*" );
      fi;
    elif b = 1 then
      display:= Concatenation( String( a ), "+" );
    elif b = -1 then
      display:= Concatenation( String( a ), "-" );
    elif 0 < b then
      display:= Concatenation( String( a ), "+", String( b ), "*" );
    else
      display:= Concatenation( String( a ), String( b ), "*" );
    fi;
    Append( display, Concatenation( "Sqrt(", String( root ), ")" ) );
    d:= d * denom;
    if d <> 1 then
      if a <> 0 then
        display:= Concatenation( "(", display, ")" );
      fi;
      display:= Concatenation( display, "/", String( d ) );
    fi;
    ConvertToStringRep( display );

    # Return the result.
    return rec(
                a       := a,
                b       := b,
                root    := root,
                d       := d,
                ATLAS   := ATLAS,
                display := display
               );
end );


#############################################################################
##
#M  GaloisMat( <mat> )  . . . . . . . . . . . . . for a matrix of cyclotomics
##
##  Note that we must not mix up plain lists and class functions, since
##  these objects lie in different families.
##
InstallMethod( GaloisMat,
    "for a matrix of cyclotomics",
    [ IsMatrix and IsCyclotomicCollColl ],
    function( mat )
    local warned,      # at most one warning will be printed if `mat' grows
          ncha,        # number of rows in `mat'
          nccl,        # number of columns in `mat'
          galoisfams,  # list with information about conjugate characters:
                       #       1 means rational character,
                       #      -1 means character with undefs,
                       #       0 means dependent irrational character,
                       #  [ .. ] means leading irrational character.
          n,           # conductor of irrationalities in `mat'
          genexp,      # generators of prime residues mod `n'
          generators,  # permutation of `mat' induced by elements in `genexp'
          X,           # one row of `mat'
          i, j,        # loop over rows of `mat'
          irrats,      # set of irrationalities in `X'
          fusion,      # positions of `irrats' in `X'
          k, l, m,     # loop variables
          generator,
          irratsimages,
          automs,
          family,
          orders,
          exp,
          image,
          oldorder,
          cosets,
          auto,
          conj,
          blocklength,
          innerlength;

    warned := false;
    ncha   := Length( mat );
    mat    := ShallowCopy( mat );

    # Step 1:
    # Find the minimal cyclotomic field $Q_n$ containing all irrational
    # entries of <mat>.

    galoisfams:= [];
    n:= 1;
    for i in [ 1 .. ncha ] do
      if ForAny( mat[i], IsUnknown ) then
        galoisfams[i]:= -1;
      elif ForAll( mat[i], IsRat ) then
        galoisfams[i]:= 1;
      else
        n:= LcmInt( n, Conductor( mat[i] ) );
      fi;
    od;

    # Step 2:
    # Compute generators for Aut( Q(n):Q ), that is,
    # compute generators for (Z/nZ)* and convert them to exponents.

    if 1 < n then

      # Each Galois automorphism induces a permutation of rows.
      # Compute the permutations for each generating automorphism.
      # (Initialize with the identity permutation.)
      genexp:= Flat( GeneratorsPrimeResidues( n ).generators );
      generators:= List( genexp, x -> [ 1 .. ncha ] );

    else

      # The matrix is rational.
      generators:= [];

    fi;

    # Step 3:
    # For each character X, find and complete the family of conjugates.

    if 0 < ncha then
      nccl:= Length( mat[1] );
    fi;

    for i in [ 1 .. ncha ] do
      if not IsBound( galoisfams[i] ) then

        # We have found an independent character that is not integral
        # and contains no unknowns.

        X:= mat[i];
        for j in [ i+1 .. ncha ] do
          if mat[j] = X then
            galoisfams[j]:= Unknown();
            Info( InfoWarning, 1,
                  "GaloisMat: row ", i, " is equal to row ", j );
          fi;
        od;

        # Initialize the list of distinct irrationalities of `X'
        # (not ordered).
        # Each Galois automorphism induces a permutation of that list
        # rather than of the entries of `X' themselves.
        irrats:= [];

        # Store how to distribute the entries of irrats to `X'.
        fusion:= [];

        for j in [ 1 .. nccl ] do
          if IsCyc( X[j] ) and not IsRat( X[j] ) then
            k:= 1;
            while k <= Length( irrats ) and X[j] <> irrats[k] do
              k:= k+1;
            od;
            if k > Length( irrats ) then
              # This is the first appearance of `X[j]' in `X'.
              irrats[k]:= X[j];
            fi;

            # Store the position in `irrats'.
            fusion[j]:= k;
          else
            fusion[j]:= 0;
          fi;
        od;

        irratsimages:= [ irrats ];
        automs:= [ 1 ];
        family:= [ i ]; # indices of family members (same ordering as automs)
        orders:= [];    # orders[k] will be the order of the k-th generator
        for j in [ 1 .. Length( genexp ) ] do
          exp:= genexp[j];
          image:= List( irrats, x -> GaloisCyc( x, exp ) );
          oldorder:= Length( automs );  # group order up to now
          cosets:= [];
          orders[j]:= 1;
          while not image in irratsimages do
            orders[j]:= orders[j] + 1;
            for k in [ 1 .. oldorder ] do
              auto:= ( automs[k] * exp ) mod n;
              image:= List( irrats, x -> GaloisCyc( x, auto ) );
              conj:= [];    # the conjugate character
              for l in [ 1 .. nccl ] do
                if fusion[l] = 0 then
                  conj[l]:= X[l];
                else
                  conj[l]:= image[ fusion[l] ];
                fi;
              od;
              l:= Position( mat, conj, i );
              if l <> fail then

                galoisfams[l]:= 0;
                Add( family, l );
                for m in [ l+1 .. ncha ] do
                  if mat[m] = conj then galoisfams[m]:= 0; fi;
                od;

              else

                if not warned and 500 < Length( mat ) then
                  Info( InfoWarning, 1,
                        "GaloisMat: completion of <mat> will have",
                        " more than 500 rows" );
                  warned:= true;
                fi;

                Add( mat, conj );
                galoisfams[ Length( mat ) ]:= 0;
                Add( family, Length( mat ) );

              fi;
              Add( automs, auto );
              Add( cosets, image );
            od;
            exp:= exp * genexp[j];
            image:= List( irrats, x -> GaloisCyc( x, exp ) );
          od;
          irratsimages:= Concatenation( irratsimages, cosets );
        od;

        # Store the conjugates and automorphisms.
        galoisfams[i]:= [ family, automs ];

        # Now the length of `family' is the size of the Galois family of the
        # row `X'.
        # Compute the permutation operation of the generators on the set of
        # rows in `family'.

        blocklength:= 1;
        for j in [ 1 .. Length( genexp ) ] do

          innerlength:= blocklength;
          blocklength:= blocklength * orders[j];
          generator:= [ 1 .. blocklength ];

          # `genexp[j]' maps the conjugates under the action of
          # $\langle `genexp[1]', \ldots, `genexp[j-1]' \rangle$
          # (a set of length `innerlength') as one block to their images,
          # preserving the order of succession.

          for l in [ 1 .. blocklength - innerlength ] do
            generator[l]:= l + innerlength;
          od;

          # Compute how a power of `genexp[j]' maps back to the block.

          exp:= ( genexp[j] ^ orders[j] ) mod n;
          for l in [ 1 .. innerlength ] do
            generator[ l + blocklength - innerlength ]:=
                 Position( irratsimages, List( irrats,
                             x -> GaloisCyc( x, exp*automs[l] ) ) );
          od;

          # Transfer this operation to the cosets under the operation of
          # $\langle `genexp[j+1]',\ldots,`genexp[Length(genexp)]' \rangle$,
          # and transfer this to <mat> via `family'.

          for k in [ 0 .. Length( family ) / blocklength - 1 ] do
            for l in [ 1 .. blocklength ] do
              generators[j][ family[ l + k*blocklength ] ]:=
                           family[ generator[ l ] + k*blocklength ];
            od;
          od;

        od;

      fi;
    od;

    # Convert the `generators' component to a set of generating permutations.
    generators:= Set( generators, PermList );
    RemoveSet( generators, () );  # `generators' arose from `PermList'
    if IsEmpty( generators ) then
      generators:= [ () ];  # `generators' arose from `PermList'
    fi;

    # Return the result.
    return rec(
                mat        := mat,
                galoisfams := galoisfams,
                generators := generators
               );
    end );


#############################################################################
##
#M  RationalizedMat( <mat> )  . . . . . .  list of rationalized rows of <mat>
##
InstallMethod( RationalizedMat,
    "for a matrix",
    [ IsMatrix ],
    function( mat )
    local i, rationalizedmat, rationalfams;

    rationalfams:= GaloisMat( mat );
    mat:= rationalfams.mat;
    rationalfams:= rationalfams.galoisfams;
    rationalizedmat:= [];
    for i in [ 1 .. Length( mat ) ] do
      if rationalfams[i] = 1 or rationalfams[i] = -1 then
        # The row is rational or contains unknowns.
        Add( rationalizedmat, mat[i] );
      elif IsList( rationalfams[i] ) then
        # The row is a leading character of a family.
        Add( rationalizedmat, Sum( mat{ rationalfams[i][1] } ) );
      fi;
    od;
    return rationalizedmat;
    end );


InstallOtherMethod( RationalizedMat,
    "for an empty list",
    [ IsList and IsEmpty ],
    empty -> [] );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <cycs> ) . .  for a coll. of cyclotomics
##
##  Disallow to create groups of cyclotomics because the `\^' operator has
##  a meaning for cyclotomics that makes it not compatible with that for
##  groups:
##  `E(4)^-1' is the *inverse* of `E(4)',
##  but in the group generated by `E(4)',
##  {\GAP} would use this term for the *conjugate* of `E(4)' by `-1'.
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a collection of cyclotomics (return false)",
    [ IsCyclotomicCollection ],
    SUM_FLAGS, # override everything else
    function( gens )
    Info( InfoWarning, 1,
          "no groups of cyclotomics allowed because of incompatible ^" );
    return false;
    end );


#############################################################################
##
##  Functions for factorizing polynomials over fields of cyclotomics
##  (For arbitrary number fields, the explicit embedding of the field of
##  rationals may cause that the functions below do not work.)
##


#############################################################################
##
#M  FactorsSquarefree( <R>, <cycpol>, <opt> )
##
##  The function uses Algorithm~3.6.4 in~\cite{Coh93}.
##  (The record <opt> is ignored.)
##
InstallMethod( FactorsSquarefree,
    "for a polynomial over a field of cyclotomics",
    IsCollsElmsX,
    [ IsAbelianNumberFieldPolynomialRing, IsUnivariatePolynomial, IsRecord ],
    function( R, U, opt )
    local coeffring, theta, xind, yind, x, y, T, coeffs, G, powers, pow, i,
          B, c, val, j, k, N, factors;

    if IsRationalsPolynomialRing( R ) then
      TryNextMethod();
    fi;

    # Let $K = \Q(\theta)$ be a number field,
    # $T \in \Q[X]$ the minimal monic polynomial of $\theta$.
    # Let $U(X) be a monic squarefree polynomial in $K[x]$.
    coeffring:= CoefficientsRing( R );
    theta:= PrimitiveElement( coeffring );

    xind:= IndeterminateNumberOfUnivariateRationalFunction( U );
    if xind = 1 then
      yind:= 2;
    else
      yind:= 1;
    fi;
    x:= Indeterminate( Rationals, xind );
    y:= Indeterminate( Rationals, yind );

    # Let $U(X) = \sum_{i=0}^m u_i X^i$ and write $u_i = g_i(\theta)$
    # for some polynomial $g_i \in \Q[X]$.
    # Set $G(X,Y) = \sum_{i=0}^m g_i(Y) X^i \in \Q[X,Y]$.
    coeffs:= CoefficientsOfUnivariatePolynomial( U );
    if ForAll( coeffs, IsRat ) then
      G:= U;
    else
      powers:= [ 1 ];
      pow:= 1;
      for i in [ 2 .. DegreeOverPrimeField( coeffring ) ] do
        pow:= pow * theta;
        powers[i]:= pow;
      od;
      B:= Basis( coeffring, powers );
      G:= Zero( U );
      for i in [ 1 .. Length( coeffs ) ] do
        if IsRat( coeffs[i] ) then
          G:= G + coeffs[i] * x^i;
        else
          c:= Coefficients( B, coeffs[i] );
          val:= c[1];
          for j in [ 2 .. Length( c ) ] do
            val:= val + c[j] * y^(j-1);
          od;
          G:= G + val * x^i;
        fi;
      od;
    fi;

    # Set $k = 0$.
    k:= 0;

    # Compute $N(X) = R_Y( T(Y), G(X - kY,Y) )$
    # where $R_Y$ denotes the resultant with respect to the variable $Y$.
    # If $N(X)$ is not squarefree, increase $k$.
    T:= MinimalPolynomial( Rationals, theta, yind );
    repeat
      k:= k+1;
      N:= Resultant( T, Value( G, [ x, y ], [ x-k*y, y ] ), y );
    until DegreeOfUnivariateLaurentPolynomial( Gcd( N, Derivative(N) ) ) = 0;

    # Let $N = \prod_{i=1}^g N_i$ be a factorization of $N$.
    # For $1 \leq i \leq g$, set $A_i(X) = \gcd( U(X), N_i(X + k \theta) )$.
    # The desired factorization of $U(X)$ is $\prod_{i=1}^g A_i$.
    factors:= List( Factors( PolynomialRing( Rationals, [ xind ] ), N ),
                    f -> Gcd( R, U, Value( f, x + k*theta ) ) );
    return Filtered( factors,
                     x -> DegreeOfUnivariateLaurentPolynomial( x ) <> 0 );
    end );


#############################################################################
##
#M  Factors( <R>, <cycpol> )  .  for a polynomial over a field of cyclotomics
##
InstallMethod( Factors,
    "for a polynomial over a field of cyclotomics",
    IsCollsElms,
    [ IsAbelianNumberFieldPolynomialRing, IsUnivariatePolynomial ],
    function( R, pol )
    local irrfacs, coeffring, i, factors, ind, coeffs, val,
          lc, der, g, factor, q;

    if IsRationalsPolynomialRing( R ) then
      TryNextMethod();
    fi;

    # Check whether the desired factorization is already stored.
    irrfacs:= IrrFacsPol( pol );
    coeffring:= CoefficientsRing( R );
    i:= PositionProperty( irrfacs, pair -> pair[1] = coeffring );
    if i <> fail then
      return ShallowCopy(irrfacs[i][2]);
    fi;

    # Handle (at most) linear polynomials.
    if DegreeOfLaurentPolynomial( pol ) < 2  then
      factors:= [ pol ];
      StoreFactorsPol( coeffring, pol, factors );
      return factors;
    fi;

    # Compute the valuation, split off the indeterminate as a zero.
    ind:= IndeterminateNumberOfLaurentPolynomial( pol );
    coeffs:= CoefficientsOfLaurentPolynomial( pol );
    val:= coeffs[2];
    coeffs:= coeffs[1];
    factors:= ListWithIdenticalEntries( val,
                  IndeterminateOfUnivariateRationalFunction( pol ) );

    if Length( coeffs ) = 1 then

      # The polynomial is a power of the indeterminate.
      factors[1]:= coeffs[1] * factors[1];
      StoreFactorsPol( coeffring, pol, factors );
      return factors;

    elif Length( coeffs ) = 2 then

      # The polynomial is a linear polynomial times a power of the indet.
      factors[1]:= coeffs[2] * factors[1];
      factors[ val+1 ]:= LaurentPolynomialByExtRepNC( FamilyObj( pol ),
                             [ coeffs[1] / coeffs[2], 1 ], 0, ind );
      StoreFactorsPol( coeffring, pol, factors );
      return factors;

    fi;

    # We really have to compute the factorization.
    # First split the polynomial into leading coefficient and monic part.
    lc:= coeffs[ Length( coeffs ) ];
    if not IsOne( lc ) then
      coeffs:= coeffs / lc;
    fi;
    if val = 0 then
      pol:= pol / lc;
    else
      pol:= LaurentPolynomialByExtRepNC( FamilyObj( pol ), coeffs, 0, ind );
    fi;

    # Now compute the quotient of `pol' by the g.c.d. with its derivative,
    # and factorize the squarefree part.
    der:= Derivative( pol );
    g:= Gcd( R, pol, der );
    if DegreeOfLaurentPolynomial( g ) = 0 then
      Append( factors, FactorsSquarefree( R, pol, rec() ) );
    else
      for factor in FactorsSquarefree( R, Quotient( R, pol, g ), rec() ) do
        Add( factors, factor );
        q:= Quotient( R, g, factor );
        while q <> fail do
          Add( factors, factor );
          g:= q;
          q:= Quotient( R, g, factor );
        od;
      od;
    fi;

    # Sort the factorization.
    Sort( factors );

    # Adjust the first factor by the constant term.
    Assert( 2, DegreeOfLaurentPolynomial(g) = 0 );
    if not IsOne( g ) then
      lc:= g * lc;
    fi;
    if not IsOne( lc ) then
      factors[1]:= lc * factors[1];
    fi;

    # Store the factorization.
    Assert( 2, Product( factors ) = lc * pol * IndeterminateOfUnivariateRationalFunction( pol )^val );
    StoreFactorsPol( coeffring, pol, factors );

    # Return the factorization.
    return factors;
    end );


#############################################################################
##
#F  DenominatorCyc( <cyc> )
##
InstallGlobalFunction( DenominatorCyc, function( cyc )
    if IsRat( cyc ) then
      return DenominatorRat( cyc );
    else
      return Lcm( List( COEFFS_CYC( cyc ), DenominatorRat ) );
    fi;
    end );


#############################################################################


#
# The following code is meant to allow comparisons between some select
# cyclotomics domains. So you can do things like
#   Integers = GaussianRationals;
#   IsSubset(Rationals, PositiveIntegers);
# without GAP running into an error. However, this code currently only
# works for a small fixed set of domains. It will not, for example, work
# with cyclotomic field extensions, or manually defined rings over the
# integers such as ClosureRing(1, E(3)).
# It would be nice if we eventually, were able to compare and intersect
# such objects, too.
#

# The following are three lists of equal length. At position i of the first
# list is a certain known cyclotomic (semi)ring. At position i of the second
# list is the corresponding filter. At position i of the third list is a
# finite list which can act as a "proxy" for the corresponding semiring when
# it comes to comparing it for inclusion resp. computing intersections with
# any of the other semirings.
# To simplify the code using these lists, the final entry of each list is
# fail, resp. the trivial filter IsObject.
BindGlobal("CompareCyclotomicCollectionHelper_Semirings", MakeImmutable( [
        PositiveIntegers, NonnegativeIntegers,
        Integers, GaussianIntegers,
        Rationals, GaussianRationals,
        Cyclotomics, fail
] ) );

BindGlobal("CompareCyclotomicCollectionHelper_Filters", MakeImmutable( [
        IsPositiveIntegers, IsNonnegativeIntegers,
        IsIntegers, IsGaussianIntegers,
        IsRationals, IsGaussianRationals,
        HasIsWholeFamily and IsWholeFamily, IsObject
] ) );

BindGlobal("CompareCyclotomicCollectionHelper_Proxies", MakeImmutable( [
        [ 1 ], [ 0, 1 ],
        [ -1, 0, 1 ], [ -1, 0, 1, E(4) ],
        [ -1, 0, 1/2, 1 ], [ -1, 0, 1/2, 1, E(4), 1/2+E(4) ],
        [ -1, 0, 1/2, 1, E(4), 1/2+E(4), E(9) ], fail
] ) );

ForAll(CompareCyclotomicCollectionHelper_Proxies, IsSet);
if IsHPCGAP then
    MakeReadOnlySingleObj(CompareCyclotomicCollectionHelper_Semirings);
    MakeReadOnlyObj(CompareCyclotomicCollectionHelper_Filters);
fi;


BindGlobal("CompareCyclotomicCollectionHelper", function (A, B)
  local a, b;
  a := PositionProperty( CompareCyclotomicCollectionHelper_Filters, p -> p(A) );
  b := PositionProperty( CompareCyclotomicCollectionHelper_Filters, p -> p(B) );
  return CompareCyclotomicCollectionHelper_Proxies{[a,b]};
end );


InstallMethod( \=, "for certain cyclotomic semirings",
             [IsCyclotomicCollection and IsSemiringWithOne,
              IsCyclotomicCollection and IsSemiringWithOne],
function (A,B)
  local ab;
  ab := CompareCyclotomicCollectionHelper(A, B);
  # It suffices if we "recognize" at least on of A and B; but if we
  # recognize neither, we give up.
  if ab = [fail,fail] then TryNextMethod(); fi;
  return ab[1] = ab[2];
end );


InstallMethod( IsSubset, "for certain cyclotomic semirings",
             [IsCyclotomicCollection and IsSemiringWithOne,
              IsCyclotomicCollection and IsSemiringWithOne],
function (A,B)
  local ab;
  ab := CompareCyclotomicCollectionHelper(A, B);
  # Verify that we recognized both A and B, otherwise give up.
  if fail in ab then TryNextMethod(); fi;
  return IsSubset(ab[1], ab[2]);
end );


InstallMethod( Intersection2, "for certain cyclotomic semirings",
             [IsCyclotomicCollection and IsSemiringWithOne,
              IsCyclotomicCollection and IsSemiringWithOne],
function (A,B)
  local ab, i;
  ab := CompareCyclotomicCollectionHelper(A, B);
  # Verify that we recognized both A and B, otherwise give up.
  if fail in ab then TryNextMethod(); fi;
  i := Position( CompareCyclotomicCollectionHelper_Proxies, Intersection2( ab[1], ab[2] ) );
  return CompareCyclotomicCollectionHelper_Semirings[i];
end );


InstallMethod( Union2, "for certain cyclotomic semirings",
             [IsCyclotomicCollection and IsSemiringWithOne,
              IsCyclotomicCollection and IsSemiringWithOne],
function (A,B)
  local ab, i;
  ab := CompareCyclotomicCollectionHelper(A, B);
  # Verify that we recognized both A and B, otherwise give up.
  if fail in ab then TryNextMethod(); fi;
  i := Position( CompareCyclotomicCollectionHelper_Proxies, Union2( ab[1], ab[2] ) );
  if i = fail then TryNextMethod(); fi;
  return CompareCyclotomicCollectionHelper_Semirings[i];
end );
