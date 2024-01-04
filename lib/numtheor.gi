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
##  This file contains methods mainly for integer primes.
##


#############################################################################
##
#F  PrimeResidues( <m> )  . . . . . . . integers relative prime to an integer
##
BindGlobal( "PrimeResiduesCache",
    List( [[],[0],[1],[1,2],[1,3],[1,2,3,4],[1,5],[1,2,3,4,5,6]], Immutable ));

if IsHPCGAP then
    MakeImmutable(PrimeResiduesCache);
fi;

InstallGlobalFunction( PrimeResidues, function ( m )
    local  residues, p, i;

    # make <m> it nonnegative, handle trivial cases
    if m < 0  then m := -m;  fi;
    if m < Length(PrimeResiduesCache)  then
      return ShallowCopy(PrimeResiduesCache[m+1]);
    fi;

    # remove the multiples of all prime divisors
    residues := [1..m-1];
    for p in PrimeDivisors(m) do
        for i  in [1..m/p-1]  do
            residues[p*i] := 1;
        od;
    od;

    # return the set of residues
    return Set( residues );
end );


#############################################################################
##
#M  Phi( <m> )  . . . . . . . . . . . . . . . . . .  Euler's totient function
##
InstallMethod( Phi,
               "value of Euler's totient function of an integer",
               true, [ IsInt ], 0,

  function ( m )

    local  phi, p;

    # make <m> it nonnegative, handle trivial cases
    if m < 0  then m := -m;  fi;
    if m < Length(PrimeResiduesCache) then
      return Length(PrimeResiduesCache[m+1]);
    fi;

    # compute $phi$
    phi := m;
    for p in PrimeDivisors(m) do
        phi := phi / p * (p-1);
    od;

    # return the result
    return phi;
  end );


#############################################################################
##
#M  Lambda( <m> ) . . . . . . . . . . . . . . . . . . . . Carmichael function
##
InstallMethod( Lambda,
               "exponent of the group of prime residues modulo an integer",
               true, [ IsInt ], 0,

  function ( m )

    local  lambda, p, q, k;

    # make <m> it nonnegative, handle trivial cases
    if m < 0  then m := -m;  fi;
    if m < Length(PrimeResiduesCache) then
      return Length(PrimeResiduesCache[m+1]);
    fi;

    # loop over all prime factors $p$ of $m$
    lambda := 1;
    for p in PrimeDivisors(m) do

        # compute $p^e$ and $k = (p-1) p^(e-1)$
        q := p;  k := p-1;
        while m mod (q * p) = 0  do q := q * p;  k := k * p;  od;

        # multiples of 8 are special
        if q mod 8 = 0  then k := k / 2;  fi;

        # combine with the value known so far
        lambda := LcmInt( lambda, k );
    od;

    return lambda;
  end );


#############################################################################
##
#F  OrderMod( <n>, <m>[, <bound>] ) . . .  multiplicative order of an integer
##
#N  23-Apr-91 martin improve 'OrderMod' similar to 'IsPrimitiveRootMod'
##
InstallGlobalFunction( OrderMod, function ( n, m, bound... )
    local  x, o, d;

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    if n < 0   then n := n mod m + m;  fi;
    if m <= n  then n := n mod m;      fi;

    # return 0 if $m$ is not coprime to $n$
    if GcdInt(m,n) <> 1  then
        o := 0;

    # compute the order simply by iterated multiplying, $x= n^o$ mod $m$
    elif m < 100  then
        x := n;  o := 1;
        while x > 1  do
            x := x * n mod m;  o := o + 1;
        od;

    # otherwise try the divisors of $\lambda(m)$ and their divisors, etc.
    else
        if Length( bound ) = 1 then
            # We know a multiple of the desired order.
            o := bound[1];
        else
            # The default a priori known multiple is 'Lambda( m )'.
            o := Lambda( m );
        fi;
        for d in PrimeDivisors( o ) do
            while o mod d = 0  and PowerModInt(n,o/d,m) = 1  do
                o := o / d;
            od;
        od;

    fi;

    return o;
end );


#############################################################################
##
#F  IsPrimitiveRootMod( <r>, <m> )  . . . . . . . . test for a primitive root
##
InstallGlobalFunction( IsPrimitiveRootMod, function ( r, m )
    local   p,  facs,  pows,  i,  pow;

    # check the arguments and reduce $r$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    if r < 0   then r := r mod m + m;  fi;
    if m <= r  then r := r mod m;      fi;

    # handle trivial cases
    if m = 2        then return r = 1;  fi;
    if m = 4        then return r = 3;  fi;
    if m mod 4 = 0  then return false;  fi;

    # handle even numbers by testing modulo the odd part
    if m mod 2 = 0  then
        if r mod 2 = 0  then return false;  fi;
        m := m / 2;
    fi;

    # check that $m$ is a prime power, otherwise no primitive root exists
    p := SmallestRootInt( m );
    if not IsPrimeInt( p )  then
        return false;
    fi;

    # check that $r^((p-1)/2) \<> 1$ mod $p$ using the Jacobi symbol
    if Jacobi( r, p ) <> -1  then
        return false;
    fi;

    # compute $pows_i := r^{{p-1}/\prod_{k=2}^{i}{facs_k}}$ ($facs_1 = 2$)
    facs := PrimeDivisors( p-1 );
    pows := [];
    pows[Length(facs)] := PowerModInt( r, 2*(p-1)/Product(facs), p );
    for i  in Reversed( [2..Length(facs)-1] )  do
        pows[i] := PowerModInt( pows[i+1], facs[i+1], p );
    od;

    # check $1 \<> r^{{p-1}/{facs_i}} = pows_i^{\prod_{k=2}^{i-1}{facs_k}}$
    pow := 1;
    for i  in [2..Length(facs)]  do
        if PowerModInt( pows[i], pow, p ) = 1  then
            return false;
        fi;
        pow := pow * facs[i];
    od;

    # if $m$ is a prime we are done
    if p = m  then
        return true;
    fi;

    # for prime powers $n$ we have to test that $r$ is not a $p$-th root
    return PowerModInt( r, p-1, p^2 ) <> 1;
end );


#############################################################################
##
#F  PrimitiveRootMod( <m> ) . . . . . . . .  primitive root modulo an integer
##
InstallGlobalFunction( PrimitiveRootMod, function ( arg )
    local   root, m, p, start, mm;

    # get and check the arguments
    if   Length(arg) = 1  then
        m := arg[1];  start := 1;
        if m <= 0  then Error("<m> must be positive");  fi;
    elif Length(arg) = 2  then
        m := arg[1];  start := arg[2];
        if m <= 0  then Error("<m> must be positive");  fi;
    else
        Error("usage: PrimitiveRootMod( <m>[, <start>] )");
    fi;

    # handle the trivial cases
    if m = 2 and start = 1   then return 1;     fi;
    if m = 2                 then return fail;  fi;
    if m = 4 and start <= 3  then return 3;     fi;
    if m mod 4 = 0           then return fail;  fi;

    # handle even numbers
    if m mod 2 = 0  then
        mm := 2;
        m := m / 2;
    else
        mm := 1;
    fi;

    # check that $m$ is a prime power otherwise no primitive root exists
    p := SmallestRootInt( m );
    if not IsPrimeInt( p )  then
        return fail;
    fi;

    # run through all candidates for a primitive root
    root := start+1;
    while root <= mm*m-1  do
        if      (mm = 1  or root mod 2 = 1)
            and IsPrimitiveRootMod( root, p )
            and (p = m  or PowerModInt( root, p-1, p^2 ) <> 1)
        then
            return root;
        fi;
        root := root + 1;
    od;

    # no primitive root found
    return fail;
end );


#############################################################################
##
#F  GeneratorsPrimeResidues( <n> ) . . . . . . generators of the Galois group
##
InstallGlobalFunction( GeneratorsPrimeResidues, function( n )
    local factors,     # collected list of prime factors of `n'
          primes,      # list of prime divisors of `n'
          exponents,   # exponents of the entries in `primes'
          generators,  # generator(s) of the prime part `ppart' of residues
          ppart,       # one prime part of `n'
          rest,        # `n / ppart'
          i,           # loop over the positions in `factors'
          gcd;         # one coefficient in the output of `Gcdex'

    if n = 1 then
      return rec(
                  primes     := [],
                  exponents  := [],
                  generators := []
                 );
    fi;

    factors:= Collected( Factors(Integers, n ) );

    primes     := [];
    exponents  := [];
    generators := [];

    # For each prime part `ppart',
    # the generator must be congruent to a primitive root modulo `ppart',
    # and congruent 1 modulo the rest `N/ppart'.

    for i in [ 1 .. Length( factors ) ] do

      primes[i]    := factors[i][1];
      exponents[i] := factors[i][2];
      ppart        := primes[i] ^ exponents[i];
      rest         := n / ppart;

      if primes[i] = 2 then

        gcd:= Gcdex( ppart, rest ).coeff2 * rest;
        if ppart mod 8 = 0 then
          # Choose the generators `**' and `*5'.
          generators[i]:= [ ( -2 * gcd + 1 ) mod n,   # generator `**'
                            (  4 * gcd + 1 ) mod n ]; # generator `*5'
        else
          # Choose the generator `**'.
          generators[i]:= ( -2 * gcd + 1 ) mod n;
        fi;

      else
        generators[i] := ( ( PrimitiveRootMod( ppart ) - 1 )
                           * Gcdex( ppart, rest ).coeff2 * rest + 1 ) mod n;
      fi;

    od;

    return rec(
                primes     := primes,
                exponents  := exponents,
                generators := generators
               );
end );


#############################################################################
##
#F  Jacobi( <n>, <m> ) . . . . . . . . . . . . . . . . . . . .  Jacobi symbol
##
##
InstallGlobalFunction( Jacobi, JACOBI_INT );


#############################################################################
##
#F  Legendre( <n>, <m> )  . . . . . . . . . . . . . . . . . . Legendre symbol
##
InstallGlobalFunction( Legendre, function ( n, m )
    local  p, q, o;

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    if n <  0  then n := n mod m + m;  fi;
    if m <= n  then n := n mod m;      fi;

    # handle small values
    if n in [0,1,4,9,16]  then return  1;  fi;
    if m < 6              then return -1;  fi;

    # check that $n$ is a quadratic residue modulo every prime power $q$
    for p  in PrimeDivisors( m )  do

        # find prime power $q$ and reduce $n$
        q := p;  while m mod (q * p) = 0  do q := q * p;  od;
        o := n mod q;

        # the largest power of $p$ that divides $o$ must be even
        while o > 0  and o mod p = 0  do
            if o mod p^2 <> 0  then return -1;  fi;
            o := o / p^2;
        od;

        # check that $m$ is a quadratic residue modulo $p$ with Jacobi
        if p = 2  then
            if o > 0  and o mod Minimum(8,q) <> 1  then return -1;  fi;
        else
            if Jacobi( o, p ) = -1                 then return -1;  fi;
        fi;

    od;

    # else $n$ is a quadratic residue modulo $m$
    return 1;
end );


#############################################################################
##
#F  RootMod( <n>, <m> ) . . . . . . . . . . . . . . .  root modulo an integer
#F  RootMod( <n>, <k>, <m> )  . . . . . . . . . . . .  root modulo an integer
##
##  Carried over from GAP3: This code requires that k is a prime.
BindGlobal( "RootModPrime", function ( n, k, p )
    local   r,                  # <k>th root of <n> mod <p>, result
            kk,                 # largest power of <k> dividing <p>-1
            s,                  # cofactor for <r>
            ss,                 # power of <s>
            t,                  # <kk>th root of unity mod <p>
            tt,                 # power of <t>
            i;                  # loop variable

    # reduce $n$ into the range $0..p-1$
    Info( InfoNumtheor, 1, "RootModPrime(", n, ",", k, ",", p, ")" );
    n := n mod p;

    # If n is non-zero, then the code below requires that p is a Fermat
    # pseudoprime with respect to n, i.e. that $n^(p-1) mod p = 1$ holds.
    # This is of course automatically true if $p$ is a prime, but for efficiency
    # reasons we actually use this with pseudo primes.
    if n <> 0 and PowerModInt( n, p-1, p ) <> 1 then
        Error( "<p> is not a Fermat pseudoprime with respect to <n>. Please report this error to the GAP team" );
    fi;

    # handle $p = 2$
    if p = 2  then
        r := n;

    # handle $n = 0$ (only possibility that <n> and <p> are not rel. prime)
    elif n = 0  then
        r := 0;

    # it's easy if $k$ is invertible mod $p-1 = \phi(p)$
    elif GcdInt( p-1, k ) = 1  then
        Info( InfoNumtheor, 2, " <r> = <n>^", 1/k mod (p-1), " mod <p>" );
        r := PowerModInt( n, 1/k mod (p-1), p );

    # check that $n$ has a $k$th root (Euler's criterium)
    elif PowerModInt( n, (p-1)/k, p ) = 1  then

        # $p-1 = x kk$, $x$ mod $k <> 0$
        kk := 1;  while (p-1)/kk mod k = 0  do kk := kk*k;  od;
        Info( InfoNumtheor, 2,
              " ", p, "-1 = <x> * ", kk, ", <x> mod ", k, " <> 1" );

        # find $r$ up to a $kk$-th root of 1, i.e., $n s = r^k, s^{kk/k} = 1$
        r := PowerModInt( n, 1/k mod ((p-1)/kk), p );
        s := PowerModInt( r, k, p ) / n mod p;
        Info( InfoNumtheor, 2,
              " <n>*", s, "=", r, "^", k, ", ", s, "^", kk/k, "=1" );

        # find a generator $t$ of the subgroup of $kk$-th roots of 1,
        # i.e., $t^{kk/k} <> 1,  t^{kk} = 1$, therefore $s = (t^l)^k$
        i:=2; t:=PowerModInt(i,(p-1)/kk,p); tt:=PowerModInt(t,kk/k,p);
        while tt=1  do
            i:=i+1; t:=PowerModInt(i,(p-1)/kk,p); tt:=PowerModInt(t,kk/k,p);
        od;
        Info( InfoNumtheor, 2,
              " ", t, "^", kk/k, " <> 1, ", t, "^", kk, " = 1" );

        # $n s = r^k,  s^{kk/k} = 1,  t^{kk/k} <> 1,  t^{kk} = 1$
        while kk <> k  do
            Info( InfoNumtheor, 2,
                  " <n>*", s, "=", r, "^", k, ", ", s, "^", kk/k, "=1" );
            kk := kk/k;
            i  := t;
            t  := PowerModInt( t, k, p );
            ss := PowerModInt( s, kk/k, p );
            while ss <> 1  do
                r  := r  * i  mod p;
                s  := s  * t  mod p;
                ss := ss * tt mod p;
            od;
        od;
        Info( InfoNumtheor, 2, " <n>*1=", r, "^", k, ", 1^1=1" );

    # otherwise $n$ has no root
    else
        r := fail;

    fi;

    # return the root $r$
    Info( InfoNumtheor, 1, "RootModPrime returns ", r );
    return r;
end );

DeclareGlobalName( "RootModPrimePower" );
BindGlobal( "RootModPrimePower", function ( n, k, p, l )
    local   r,                  # <k>th root of <n> mod <p>^<l>, result
            s,                  # <k>th root of <n> mod smaller power
            t;                  # temporary variable

    # delegate prime case
    Info( InfoNumtheor, 1,
          "RootModPrimePower(", n, ",", k, ",", p, "^", l, ")" );
    if l = 1  then
        r := RootModPrime( n, k, p );

    # special case
    elif n mod p^l = 0  then
        r := 0;

    # if $n$ is a multiple of $p^k$ return $p (\sqrt[k]{n/p^k} mod p^l/p^k)$
    elif n mod p^k = 0  then
        s := RootModPrimePower( n/p^k, k, p, l-k );
        if s <> fail  then
            r := s * p;
        else
            r := fail;
        fi;

    # if $n$ is a multiple of $p$ but not of $p^k$ then no root exists
    elif n mod p = 0  then
        r := fail;

    # handle the case that the root may not lift
    elif k = p  then

        Info( InfoNumtheor, 3, "k=p case" );

        # compute the root mod $p^{l/2}$, or $p^{l/2+1}$ if 32 divides $p^l$
        if 2 < p  or l < 5  then
            s := RootModPrimePower( n, k, p, QuoInt(l+1,2) );
        else
            s := RootModPrimePower( n, k, p, QuoInt(l+3,2) );
        fi;

        if s=fail then
          r:=fail;
        else
          # lift the root to $p^l$, use higher precision
          Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
          t := PowerModInt( s, k-1, p^(l+1) );
          r := (s + (n - t * s) / (k * t)) mod p^l;
          if PowerModInt(r,k,p^l) <> n mod p^l  then
              r := fail;
          fi;
        fi;

    # otherwise lift the root with Newton / Hensel
    else

        # compute the root mod $p^{l/2}$, or $p^{l/2+1}$ if 32 divides $p^l$
        if 2 < p  or l < 5  then
            s := RootModPrimePower( n, k, p, QuoInt(l+1,2) );
        else
            s := RootModPrimePower( n, k, p, QuoInt(l+3,2) );
        fi;
        Info( InfoNumtheor, 3, "lift case s=",s );

        if s=fail then
          r:=fail;
        else
          # lift the root to $p^l$
          Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
          t := PowerModInt( s, k-1, p^l );
          r := (s + (n - t * s) / (k * t)) mod p^l;
        fi;

    fi;

    # return the root $r$
    Info( InfoNumtheor, 1, "RootModPrimePower returns ", r );
    return r;
end );

InstallGlobalFunction( RootMod, function ( arg )
    local   n,                  # <n>, first argument
            k,                  # <k>, optional second argument
            m,                  # <m>, third argument
            p,                  # prime divisor of <m>
            q,                  # power of <p>
            l,                  # <q> = <p>^<l>
            qq,                 # product of prime powers dividing <m>
            ii,                 # inverse of <qq> mod <q>
            r,                  # <k>th root of <n> mod <qq>
            s,                  # <k>th root of <n> mod <q>
            f, # factors
            i; # loop

    # get the arguments
    if   Length(arg) = 2  then n := arg[1];  k := 2;       m := arg[2];
    elif Length(arg) = 3  then n := arg[1];  k := arg[2];  m := arg[3];
    else Error("usage: RootMod( <n>, <m> ) or RootMod( <n>, <k>, <m> )");
    fi;
    Info( InfoNumtheor, 1, "RootMod(", n, ",", k, ",", m, ")" );

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    n := n mod m;

    if not IsPrime(k) then
      # try over factors of k
      f:=Factors(k);
      l:=n;
      for i in f do
        l:=RootMod(l,i,m);
        if l=fail then
          Info( InfoNumtheor, 2, "must try multiple roots");
          # it failed. This might have been because of taking the wrong root
          # do again with all roots
          l:=RootsMod(n,k,m);
          if Length(l)=0 then
            return fail;
          else
            return l[1];
          fi;

        fi;

      od;
      return l;
    fi;

    # combine the root modulo every prime power $p^l$
    r := 0;  qq := 1;
    for p  in PrimeDivisors( m : UseProbabilisticPrimalityTest ) do

        # find prime power $q = p^l$
        q := p;  l := 1;
        while m mod (q * p) = 0  do q := q * p;  l := l + 1;  od;

        # compute the root mod $p^l$
        s := RootModPrimePower( n, k, p, l );
        if s = fail  then
            Info( InfoNumtheor, 1, "RootMod returns 'fail'" );
            return fail;
        fi;

        # combine $r$ (the root mod $qq$) with $s$ (the root mod $p^l$)
        ii := 1/qq mod q;
        r := r + qq * ((s - r)*ii mod q);
        qq := qq * q;

    od;

    # return the root $rr$
    Info( InfoNumtheor, 1, "RootMod returns ", r );
    return r;
end );


#############################################################################
##
#F  RootsMod( <n>, <k>, <m> ) . . . . . . . . . . . . roots modulo an integer
##
BindGlobal( "RootsModPrime", function ( n, k, p )
    local   rr,                 # <k>th roots of <n> mod <p>, result
            r,                  # one particular <k>th root of <n> mod <p>
            kk,                 # largest power of <k> dividing <p>-1
            s,                  # cofactor for <r>
            ss,                 # power of <s>
            t,                  # <kk>th root of unity mod <p>
            tt,                 # power of <t>
            i;                  # loop variable

    # reduce $n$ into the range $0..p-1$
    Info( InfoNumtheor, 1, "RootsModPrime(", n, ",", k, ",", p, ")" );
    n := n mod p;

    # If n is non-zero, then the code below requires that p is a Fermat
    # pseudoprime with respect to n, i.e. that $n^(p-1) mod p = 1$ holds.
    # This is of course automatically true if $p$ is a prime, but for efficiency
    # reasons we actually use this with pseudo primes.
    if n <> 0 and PowerModInt( n, p-1, p ) <> 1 then
        Error( "<p> is not a Fermat pseudoprime with respect to <n>. Please report this error to the GAP team" );
    fi;

    # handle $p = 2$
    if p = 2  then
        rr := [ n ];

    # handle $n = 0$ (only possibility that <n> and <p> are not rel. prime)
    elif n = 0  then
        rr := [ 0 ];

    # it's easy if $k$ is invertible mod $p-1 = \phi(p)$
    elif GcdInt( p-1, k ) = 1  then
        Info( InfoNumtheor, 2, " <r> = <n>^", 1/k mod (p-1), " mod <p>" );
        rr := [ PowerModInt( n, 1/k mod (p-1), p ) ];

    # check that $n$ has a $k$th root (Euler's criterium)
    elif PowerModInt( n, (p-1)/k, p ) = 1  then

        # $p-1 = x kk$, $x$ mod $k <> 0$
        kk := 1;  while (p-1)/kk mod k = 0  do kk := kk*k;  od;
        Info( InfoNumtheor, 2,
              " ", p, "-1 = <x> * ", kk, ", <x> mod ", k, " <> 1" );

        # find $r$ up to a $kk$-th root of 1, i.e., $n s = r^k, s^{kk/k} = 1$
        r := PowerModInt( n, 1/k mod ((p-1)/kk), p );
        s := PowerModInt( r, k, p ) / n mod p;
        Info( InfoNumtheor, 2,
              " <n>*", s, "=", r, "^", k, ", ", s, "^", kk/k, "=1" );

        # find a generator $t$ of the subgroup of $kk$-th roots of 1,
        # i.e., $t^{kk/k} <> 1,  t^{kk} = 1$, therefore $s = (t^l)^k$
        i:=2; t:=PowerModInt(i,(p-1)/kk,p); tt:=PowerModInt(t,kk/k,p);
        while tt=1  do
            i:=i+1; t:=PowerModInt(i,(p-1)/kk,p); tt:=PowerModInt(t,kk/k,p);
        od;
        Info( InfoNumtheor, 2,
              " ", t, "^", kk/k, " <> 1, ", t, "^", kk, " = 1" );

        # $n s = r^k,  s^{kk/k} = 1,  t^{kk/k} <> 1,  t^{kk} = 1$
        while kk <> k  do
            Info( InfoNumtheor, 2,
                  " <n>*", s, "=", r, "^", k, ", ", s, "^", kk/k, "=1" );
            kk := kk/k;
            i  := t;
            t  := PowerModInt( t, k, p );
            ss := PowerModInt( s, kk/k, p );
            while ss <> 1  do
                r  := r  * i  mod p;
                s  := s  * t  mod p;
                ss := ss * tt mod p;
            od;
        od;
        Info( InfoNumtheor, 2, " <n>*1=", r, "^", k, ", 1^1=1" );

        # combine $r$ (a particular root) with the powers of $t$
        rr := [ r ];
        for i  in [2..k]  do
            r := r * t mod p;
            AddSet( rr, r );
        od;

    # otherwise $n$ has no root
    else
        rr := [];

    fi;

    # return the roots $rr$
    Info( InfoNumtheor, 1, "RootsModPrime returns ", rr );
    return rr;
end );

DeclareGlobalName( "RootsModPrimePower" );
BindGlobal( "RootsModPrimePower", function ( n, k, p, l )
    local   rr,                 # <k>th roots of <n> mod <p>^<l>, result
            r,                  # one element of <rr>
            ss,                 # <k>th roots of <n> mod smaller power
            s,                  # one element of <ss>
            t;                  # temporary variable

    # delegate prime case
    Info( InfoNumtheor, 1,
          "RootsModPrimePower(", n, ",", k, ",", p, "^", l, ")" );
    if l = 1  then
        rr := RootsModPrime( n, k, p );

    # special case
    elif n mod p^l = 0  then
        t := QuoInt( l-1, k ) + 1;
        rr := [ 0 .. p^(l-t)-1 ] * p^t;

    # if $n$ is a multiple of $p^k$ return $p (\sqrt[k]{n/p^k} mod p^l/p^k)$
    elif n mod p^k = 0  then
        ss := RootsModPrimePower( n/p^k, k, p, l-k );
        rr := [];
        for s  in ss  do
            for t  in [ 0 .. p^(k-1)-1 ]   do
                AddSet( rr, s * p + t * p^(l-k+1) );
            od;
        od;

    # if $n$ is a multiple of $p$ but not of $p^k$ then no root exists
    elif n mod p = 0  then
        rr := [];

    # handle the case that the roots split
    elif k = p  then

        Info( InfoNumtheor, 3, "k=p case" );

        # compute the root mod $p^{l/2}$, or $p^{l/2+1}$ if 32 divides $p^l$
        if 2 < p  or l < 5  then
            ss := RootsModPrimePower( n, k, p, QuoInt(l+1,2) );
        else
            ss := RootsModPrimePower( n, k, p, QuoInt(l+3,2) );
        fi;

        # lift the roots to $p^l$, use higher precision
        rr := [];
        for s  in ss  do
            Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
            t := PowerModInt( s, k-1, p^(l+1) );
            r := (s + (n - t * s) / (k * t)) mod p^l;
            if PowerModInt(r,k,p^l) = n mod p^l  then
                for t  in [0..k-1]*p^(l-1)+1  do
                    AddSet( rr, r * t mod p^l );
                od;
            fi;
        od;

    # otherwise lift the roots with Newton / Hensel
    else

        # compute the root mod $p^{l/2}$, or $p^{l/2+1}$ if 32 divides $p^l$
        if 2 < p  or l < 5  then
            ss := RootsModPrimePower( n, k, p, QuoInt(l+1,2) );
        else
            ss := RootsModPrimePower( n, k, p, QuoInt(l+3,2) );
        fi;

        # lift the roots to $p^l$
        rr := [];
        for s  in ss  do
            Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
            t := PowerModInt( s, k-1, p^l );
            r := (s + (n - t * s) / (k * t)) mod p^l;
            AddSet( rr, r );
        od;

    fi;

    # return the roots $rr$
    Info( InfoNumtheor, 1, "RootsModPrimePower returns ", rr );
    return rr;
end );

InstallGlobalFunction( RootsMod, function ( arg )
    local   n,                  # <n>, first argument
            k,                  # <k>, optional second argument
            m,                  # <m>, third argument
            p,                  # prime divisor of <m>
            q,                  # power of <p>
            l,                  # <q> = <p>^<l>
            f,                  # factors
            qq,                 # product of prime powers dividing <m>
            ii,                 # inverse of <qq> mod <q>
            rr,                 # <k>th roots of <n> mod <qq>
            r,                  # one element of <rr>
            ss,                 # <k>th roots of <n> mod <q>
            s,                  # one element of <ss>
            tt;                 # temporary variable

    # get the arguments
    if   Length(arg) = 2  then n := arg[1];  k := 2;       m := arg[2];
    elif Length(arg) = 3  then n := arg[1];  k := arg[2];  m := arg[3];
    else Error("usage: RootsMod( <n>, <m> ) or RootsMod( <n>, <k>, <m> )");
    fi;
    Info( InfoNumtheor, 1, "RootsMod(", n, ",", k, ",", m, ")" );

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    n := n mod m;

    if not IsPrime(k) then
      # try over factors of k
      f:=Factors(k);
      l:=[n];
      for ii in f do
        l:=Concatenation(List(l,x->RootsMod(x,ii,m)));
      od;
      return l;
    fi;

    # combine the roots modulo every prime power $p^l$
    rr := [0];  qq := 1;
    for p  in PrimeDivisors( m : UseProbabilisticPrimalityTest )  do

        # find prime power $q = p^l$
        q := p;  l := 1;
        while m mod (q * p) = 0  do q := q * p;  l := l + 1;  od;

        # compute the roots mod $p^l$
        ss := RootsModPrimePower( n, k, p, l );

        # combine $rr$ (the roots mod $qq$) with $ss$ (the roots mod $p^l$)
        tt := [];
        ii := 1/qq mod q;
        for r  in rr  do
            for s  in ss  do
                Add( tt, r + qq * ((s-r)*ii mod q) );
            od;
        od;
        rr := tt;
        qq := qq * q;

    od;

    # return the roots $rr$
    Info( InfoNumtheor, 1, "RootsMod returns ", rr );
    return Set( rr );
end );


#############################################################################
##
#F  RootsUnityMod( <m> )  . . . . . . . . .  roots of unity modulo an integer
#F  RootsUnityMod( <k>, <m> ) . . . . . . .  roots of unity modulo an integer
##
BindGlobal( "RootsUnityModPrime", function ( k, p )
    local   rr,                 # <k>th roots of 1 mod <p>, result
            r,                  # <k>th root of unity mod <p>
            t,                  # <k>th root of unity mod <p>
            i;                  # loop variable

    # reduce $n$ into the range $0..p-1$
    Info( InfoNumtheor, 1, "RootsUnityModPrime(", k, ",", p, ")" );

    # handle $p = 2$
    if p = 2  then
        rr := [ 1 ];

    # it's easy if $k$ is invertible mod $p-1 = \phi(p)$
    elif GcdInt( p-1, k ) = 1  then
        rr := [ 1 ];

    # check that $n$ has a $k$th root (Euler's criterium)
    else

        # find a generator $t$ of the subgroup of $k$-th roots of 1.
        i:=2; t:=PowerModInt(i,(p-1)/k,p);
        while t=1  do
            i:=i+1; t:=PowerModInt(i,(p-1)/k,p);
        od;

        # combine $r$ (a particular root) with the powers of $t$
        r := 1;
        rr := [ 1 ];
        for i  in [2..k]  do
            r := r * t mod p;
            AddSet( rr, r );
        od;

    fi;

    # return the roots $rr$
    Info( InfoNumtheor, 1, "RootsUnityModPrime returns ", rr );
    return rr;
end );

DeclareGlobalName( "RootsUnityModPrimePower" );
BindGlobal( "RootsUnityModPrimePower", function ( k, p, l )
    local   rr,                 # <k>th roots of <n> mod <p>^<l>, result
            r,                  # one element of <rr>
            ss,                 # <k>th roots of <n> mod smaller power
            s,                  # one element of <ss>
            t;                  # temporary variable

    # delegate prime case
    Info( InfoNumtheor, 1,
          "RootsUnityModPrimePower(", k, ",", p, "^", l, ")" );
    if l = 1  then
        rr := RootsUnityModPrime( k, p );

    # if $k$ is invertible mod $\phi(p^l)$ then there is only one root
    elif GcdInt(k,(p-1)*p) = 1  then
        rr := [ 1 ];

    # if $p = k = 2$
    elif p = 2  and k = 2  then
        rr := Set( [ 1, p^(l-1)-1, p^(l-1)+1, p^l-1 ] );

    # if $p = k$
    elif p = k  then
        rr := [0..k-1]*p^(l-1)+1;

    # special case to speed up things a little bit
    elif k = 2  then
        rr := [ 1, p^l-1 ];

    # otherwise lift the roots with Newton / Hensel
    else

        # compute the root mod $p^{l/2}$
        ss := RootsUnityModPrimePower( k, p, QuoInt(l+1,2) );

        # lift the roots to $p^l$
        rr := [];
        for s  in ss  do
            Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
            t := PowerModInt( s, k-1, p^l );
            r := (s + (1 - t * s) / (k * t)) mod p^l;
            AddSet( rr, r );
        od;

    fi;

    # return the roots $rr$
    Info( InfoNumtheor, 1, "RootsUnityModPrimePower returns ", rr );
    return rr;
end );

InstallGlobalFunction( RootsUnityMod, function ( arg )
    local   k,                  # <k>, optional first argument
            m,                  # <m>, second argument
            p,                  # prime divisor of <m>
            q,                  # power of <p>
            l,                  # <q> = <p>^<l>
            qq,                 # product of prime powers dividing <m>
            ii,                 # inverse of <qq> mod <q>
            rr,                 # <k>th roots of <n> mod <qq>
            r,                  # one element of <rr>
            ss,                 # <k>th roots of <n> mod <q>
            s,                  # one element of <ss>
            tt;                 # temporary variable

    # get the arguments
    if   Length(arg) = 1  then k := 2;       m := arg[1];
    elif Length(arg) = 2  then k := arg[1];  m := arg[2];
    else Error("usage: RootsUnityMod( <m> ) or RootsUnityMod( <k>, <m> )");
    fi;
    Info( InfoNumtheor, 1, "RootsUnityMod(", k, ",", m, ")" );

    # combine the roots modulo every prime power $p^l$
    rr := [0];  qq := 1;
    for p in PrimeDivisors( m ) do

        # find prime power $q = p^l$
        q := p;  l := 1;
        while m mod (q * p) = 0  do q := q * p;  l := l + 1;  od;

        # compute the roots mod $p^l$
        ss := RootsUnityModPrimePower( k, p, l );

        # combine $rr$ (the roots mod $qq$) with $ss$ (the roots mod $p^l$)
        tt := [];
        ii := 1/qq mod q;
        for r  in rr  do
            for s  in ss  do
                Add( tt, r + qq * ((s-r)*ii mod q) );
            od;
        od;
        rr := tt;
        qq := qq * q;

    od;

    # return the roots $rr$
    Info( InfoNumtheor, 1, "RootsUnityMod returns ", rr );
    return Set( rr );
end );


#############################################################################
##
#F  LogMod( <n>, <r>, <m> ) . . . . . .  discrete logarithm modulo an integer
##
InstallGlobalFunction( LogModShanks,function(b,a,n)
local ai, m, m2, am, l, g, c, p, i;
  b:=b mod n;
  a:=a mod n;
  ai:=Gcdex(a,n);
  if ai.gcd=1 then
    # coprime case -- use Shanks's method
    # don't make the list longer than 5 million entries
    m:=Minimum(RootInt(n,2)+1,5*10^6);
    m2:=QuoInt(n,m)+1; # remaining part
    # calculate a^m mod n once
    am:=PowerMod(a,m,n);
    l:=[0..m-1];
    g:=[];
    c:=1;
    # create powers of a^m
    for i in l do
      Add(g,c);
      c:=c*am mod n;
    od;
    # dort the list (we'll potentially have to search often)
    SortParallel(g,l);
    c:=b;
    ai:=ai.coeff1;
    for i in [0..m2] do
      p:=PositionSorted(g,c);
      # positionsorted gives position to insert -- so we have to check
      if p<=m and g[p]=c then
        return l[p]*m+i;
      fi;
      c:=c*ai mod n;
    od;
    return fail;
  else
    Error("not coprime");
  fi;
end);

# Pollard Rho method for Index.
# Implemented by Sean Gage and AH

BindGlobal("LogModRhoIterate",function(n,g,p)
local p3, zp3, q, x, xd, a, ad, b, bd, m, r;
  p3:=QuoInt(p,3);
  zp3:=QuoInt(2*p,3);
  q := p-1;
  x := 1;
  xd := 1;
  a := 0;
  ad := 0;
  b := 0;
  bd := 0;
  repeat
    if x < p3 then
      x := (x * n) mod p;
      a := (a + 1) mod q;
    elif x < zp3 then
      x := (x * x) mod p;
      a := (a*2) mod q;
      b := (b*2) mod q;
    else
      x := (x * g) mod p;
      b := (b + 1) mod q;
    fi;
    if xd <p3 then
      xd := (xd * n) mod p;
      ad := (ad + 1) mod q;
    elif xd < zp3 then
      xd := (xd * xd) mod p;
      ad := (ad*2) mod q;
      bd := (bd*2) mod q;
    else
      xd := (xd * g) mod p;
      bd := (bd + 1) mod q;
    fi;
    if xd < p3 then
      xd := (xd * n) mod p;
      ad := (ad + 1) mod q;
    elif xd < zp3 then
      xd := (xd * xd) mod p;
      ad := (ad*2) mod q;
      bd := (bd*2) mod q;
    else
      xd := (xd * g) mod p;
      bd := (bd + 1) mod q;
    fi;
  until x=xd;

  m := (a-ad) mod q;
  r := (bd-b) mod q;
  return [m,r];
end);

InstallGlobalFunction(DoLogModRho,function(q,r,ord,f,p)
local fact, s, t, Q, R, MN, M, N, rep, d, k, theta, Qp,o,i;
  Info(InfoNumtheor,1,"DoLogModRho(",q,",",r,",",ord,",",p,")");
  fact:=[];
  s:=ord;
  for i in f do
    t:=s/i;
    if IsInt(t) then
      s:=t;
      Add(fact,i);
    fi;
  od;

  if Length(fact)>1 then
    d:=ord;
    while (d=ord) and Length(fact)>0 do
      s:=Remove(fact);
      t:=ord/s;
      Q:=PowerMod(q,s,p);
      R:=PowerMod(r,s,p);
      # iterate
      MN:=LogModRhoIterate(Q,R,p);
      M:=MN[1];
      N:=MN[2];
      rep:=GcdRepresentation(ord,s*M);
      d:=rep[1]*ord+rep[2]*s*M;
    od;
    if d<ord then
      k:=(rep[2]*s*N/d);
      if Gcd(DenominatorRat(k),ord)<>1 then
        return fail; # can't invert (can't happen if not primitive root)
      fi;
      k:=k mod ord;
      theta:=PowerMod(r,ord/d,p);
      Qp:=q/PowerMod(r,k,p) mod p;
      i:=DoLogModRho(Qp,theta,d,f,p);
      if i=fail then return i;fi; # bail out
      o:=(k+i*(ord/d)) mod ord;
      Assert(1,PowerMod(r,o,p)=q);
      return o;
    fi;
  fi;
  # naive case, iterate
  MN:=LogModRhoIterate(q,r,p);
  M:=MN[1];
  N:=MN[2];
  rep:=GcdRepresentation(ord,M);
  d:=rep[1]*ord+rep[2]*M;
  k:=(rep[2]*N/d);
  if Gcd(DenominatorRat(k),ord)<>1 then
    return fail; # can't invert (can't happen if not primitive root)
  fi;
  k:=k mod ord;
  theta:=PowerMod(r,ord/d,p);
  Qp:=q/PowerMod(r,k,p) mod p;
  for i in [1..d] do
    if Qp=1 then
      Assert(1,PowerMod(r,k,p)=q);
      return k;
    fi;
    k:=(k+ord/d) mod ord;
    Qp:=Qp/theta mod p;
  od;
  # process failed (because r was not a primitive root)
  return fail;
end);

InstallGlobalFunction( LogMod,function(b,a,n)
local c, p,f,l;

  b:=b mod n;
  a:=a mod n;
  if IsPrime(n) and Gcd(a,n)=1 then
    # use rho method
    f:=Factors(Integers,n-1:quiet); # Quick factorization, don't stop if its too hard
    l:=DoLogModRho(b,a,n-1,f,n);
    if l<>fail then
      return l;
    fi;
  fi;
  if Gcd(a,n)=1 then
    return LogModShanks(b,a,n);
  else
    # not coprime -- use old method
    c := 1;
    p := 0;
    while c <> b  do
        c := (c * a) mod n;
        p := p + 1;
        if p = n  then
            return fail;
        fi;
    od;
    return p;
  fi;
end);


#############################################################################
##
#M  Sigma( <n> )  . . . . . . . . . . . . . . . sum of divisors of an integer
##
InstallMethod( Sigma,
               "sum of divisors of an integer",
               true, [ IsInt ], 0,

  function( n )

    local  sigma, p, q, k;

    # make <n> it nonnegative, handle trivial cases
    if n < 0  then n := -n;  fi;
    if n = 0  then Error("Sigma: <n> must not be 0");  fi;
    if n <= Length(DivisorsIntCache) then
      return Sum(DivisorsIntCache[n]);
    fi;

    # loop over all prime $p$ factors of $n$
    sigma := 1;
    for p in PrimeDivisors(n) do

        # compute $p^e$ and $k = 1+p+p^2+..p^e$
        q := p;  k := 1 + p;
        while n mod (q * p) = 0  do q := q * p;  k := k + q;  od;

        # combine with the value found so far
        sigma := sigma * k;
    od;

    return sigma;
  end );


#############################################################################
##
#M  Tau( <n> )  . . . . . . . . . . . . . .  number of divisors of an integer
##
InstallMethod( Tau,
               "number of divisors of an integer",
               true, [ IsInt ], 0,

  function( n )

    local  tau, p, q, k;

    # make <n> it nonnegative, handle trivial cases
    if n < 0  then n := -n;  fi;
    if n = 0  then Error("Tau: <n> must not be 0");  fi;
    if n <= Length(DivisorsIntCache) then
      return Length(DivisorsIntCache[n]);
    fi;

    # loop over all prime factors $p$ of $n$
    tau := 1;
    for p in PrimeDivisors(n) do

        # compute $p^e$ and $k = e+1$
        q := p;  k := 2;
        while n mod (q * p) = 0  do q := q * p;  k := k + 1;  od;

        # combine with the value found so far
        tau := tau * k;
    od;

    return tau;
  end );


#############################################################################
##
#F  MoebiusMu( <n> )  . . . . . . . . . . . . . .  Moebius inversion function
##
InstallGlobalFunction( MoebiusMu, function ( n )
    local  factors;

    if n < 0  then n := -n;  fi;
    if n = 0  then Error("MoebiusMu: <n> must be nonzero");  fi;
    if n = 1  then return 1;  fi;

    factors := Factors(Integers, n );
    if factors <> Set( factors )  then return 0;  fi;
    return (-1) ^ Length(factors);
end );


#############################################################################
##
#F  TwoSquares( <n> ) . . . . . repres. of an integer as a sum of two squares
##
InstallGlobalFunction( TwoSquares, function ( n )
    local  c, d, p, q, l, x, y;

    # check arguments and handle special cases
    if   n < 0  then Error("<n> must be positive");
    elif n = 0  then return [ 0, 0 ];
    elif n = 1  then return [ 0, 1 ];
    fi;

    # write $n = c^2 d$, where $c$ has only  prime factors  $2$  and  $4k+3$,
    # and $d$ has at most one  $2$ and otherwise only  prime factors  $4k+1$.
    c := 1;  d := 1;
    for p in PrimeDivisors( n ) do
        q := p;  l := 1;
        while n mod (q * p) = 0  do q := q * p;  l := l + 1;  od;
        if p = 2  and l mod 2 = 0  then
            c := c * 2 ^ (l/2);
        elif p = 2  and l mod 2 = 1  then
            c := c * 2 ^ ((l-1)/2);
            d := d * 2;
        elif p mod 4 = 1  then
            d := d * q;
        elif p mod 4 = 3  and l mod 2 = 0  then
            c := c * p ^ (l/2);
        else # p mod 4 = 3  and l mod 2 = 1
            return fail;
        fi;
    od;

    # handle special cases
    if   d = 1  then return [ 0, c ];
    elif d = 2  then return [ c, c ];
    fi;

    # compute a square root $x$ of $-1$ mod $d$,  which must exist  since  it
    # exists modulo all prime powers that divide $d$
    x := RootMod( -1, d );

    # and now the Euclidean Algorithm strikes again
    y := d;
    while d < y^2  do
        p := x;
        x := y mod x;
        y := p;
    od;

    # return the representation
    return [ c * x, c * y ];
end );


InstallGlobalFunction(PValuation,function(n,p)
  if not IsInt(p) or not IsRat(n) or p = 0 then
    Error("wrong parameters");
  fi;
  if n = 0 then
    return infinity;
  elif IsInt(n) then
    return PVALUATION_INT(n,p);
  fi;
  return PVALUATION_INT(NumeratorRat(n),p) - PVALUATION_INT(DenominatorRat(n),p);
end);
