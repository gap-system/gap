#############################################################################
##
#W  numtheor.gi                 GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods mainly for integer primes.
##
Revision.numtheor_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  PrimeResidues( <m> )  . . . . . . . integers relative prime to an integer
##
##  'PrimeResidues' returns the set of integers from the range  $0..Abs(m)-1$
##  that are relative prime to the integer <m>.
##
##  $Abs(m)$ must be less than $2^{28}$, otherwise the set would probably  be
##  too large anyhow.
##
PrimeResiduesSmall := [[],[0],[1],[1,2],[1,3],[1,2,3,4],[1,5],[1,2,3,4,5,6]];
PrimeResidues := function ( m )
    local  residues, p, i;

    # make <m> it nonnegative, handle trivial cases
    if m < 0  then m := -m;  fi;
    if m < 8  then return ShallowCopy(PrimeResiduesSmall[m+1]);  fi;

    # remove the multiples of all prime divisors
    residues := [1..m-1];
    for p  in Set(FactorsInt(m))  do
        for i  in [1..m/p-1]  do
            residues[p*i] := 1;
        od;
    od;

    # return the set of residues
    return Set( residues );
end;


#############################################################################
##
#F  Phi( <m> )  . . . . . . . . . . . . . . . . . . . Eulers totient function
##
##  'Phi' returns  the number of positive integers  less  than  the  positive
##  integer <m> that are relativ prime to <m>.
##
##  Suppose that $m = p_1^{e_1} p_2^{e_2} .. p_k^{e_k}$.  Then  $\phi(m)$  is
##  $p_1^{e_1-1} (p_1-1) p_2^{e_2-1} (p_2-1) ..  p_k^{e_k-1} (p_k-1)$.
##
Phi := function ( m )
    local  phi, p;

    # make <m> it nonnegative, handle trivial cases
    if m < 0  then m := -m;  fi;
    if m < 8  then return Length(PrimeResiduesSmall[m+1]);  fi;

    # compute $phi$
    phi := m;
    for p  in Set(FactorsInt(m))  do
        phi := phi / p * (p-1);
    od;

    # return the result
    return phi;
end;


#############################################################################
##
#F  Lambda( <m> ) . . . . . . . . . . . . . . . . . . .  Carmichaels function
##
##  'Lambda' returns the exponent of the group  of  relative  prime  residues
##  modulo the integer <m>.
##
##  Carmichaels theorem states that 'Lambda'  can  be  computed  as  follows:
##  $Lambda(2) = 1$, $Lambda(4) = 2$ and $Lambda(2^e) = 2^{e-2}$ if $3 <= e$,
##  $Lambda(p^e) = (p-1) p^{e-1}$ (i.e. $Phi(m)$) if $p$ is an odd prime  and
##  $Lambda(n*m) = Lcm( Lambda(n), Lambda(m) )$ if $n, m$ are relative prime.
##
Lambda := function ( m )
    local  lambda, p, q, k;

    # make <m> it nonnegative, handle trivial cases
    if m < 0  then m := -m;  fi;
    if m < 8  then return Length(PrimeResiduesSmall[m+1]);  fi;

    # loop over all prime factors $p$ of $m$
    lambda := 1;
    for p  in Set(FactorsInt(m))  do

        # compute $p^e$ and $k = (p-1) p^(e-1)$
        q := p;  k := p-1;
        while m mod (q * p) = 0  do q := q * p;  k := k * p;  od;

        # multiples of 8 are special
        if q mod 8 = 0  then k := k / 2;  fi;

        # combine with the value known so far
        lambda := LcmInt( lambda, k );
    od;

    return lambda;
end;


#############################################################################
##
#F  OrderMod( <n>, <m> )  . . . . . . . .  multiplicative order of an integer
##
##  'OrderMod' returns the multiplicative order of the integer <n> modulo the
##  positive integer <m>.  If <n> and <m> are not relativ prime the order  if
##  <n> is not defined and 'OrderInt' will return 0.
##
#N  23-Apr-91 martin improve 'OrderMod' similar to 'IsPrimitiveRootMod'
##
OrderMod := function ( n, m )
    local  x, o, d;

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    if n < 0   then n := n mod m + m;  fi;
    if m <= n  then n := n mod m;      fi;

    # return 0 if the $n$ is not relativ prime to $n$
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
        o := Lambda( m );
        for d in Set( FactorsInt( o ) )  do
            while o mod d = 0  and PowerModInt(n,o/d,m) = 1  do
                o := o / d;
            od;
        od;

    fi;

    return o;
end;


#############################################################################
##
#F  IsPrimitiveRootMod( <r>, <m> )  . . . . . . . . test for a primitive root
##
##  'IsPrimitiveRootMod' returns  'true' if the  integer <r>  is a  primitive
##  root modulo the positive integer <m> and 'false' otherwise.
##
IsPrimitiveRootMod := function ( r, m )
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
    facs := Set( FactorsInt( p-1 ) );
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
end;


#############################################################################
##
#F  PrimitiveRootMod( <m> ) . . . . . . . .  primitive root modulo an integer
##
##  'PrimitiveRootMod' returns the smallest primitive root modulo the integer
##  <m> and 'false' if no such primitive root exists.  If the optional second
##  integer argument <start> is given 'PrimitiveRootMod' returns the smallest
##  primitive root that is strictly larger than <start>.
##
PrimitiveRootMod := function ( arg )
    local   root, m, p, start, mm;

    # get and check the arguments
    if   Length(arg) = 1  then
        m := arg[1];  start := 1;
        if m <= 0  then Error("<m> must be positive");  fi;
    elif Length(arg) = 2  then
        m := arg[1];  start := arg[2];
        if m <= 0  then Error("<m> must be positive");  fi;
    else
        Error("usage: PrimitiveRootMod( <m> [, <start>] )");
    fi;

    # handle the trivial cases
    if m = 2 and start = 1   then return 1;      fi;
    if m = 2                 then return false;  fi;
    if m = 4 and start <= 3  then return 3;      fi;
    if m mod 4 = 0           then return false;  fi;

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
        return false;
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
    return false;
end;


#############################################################################
##
#F  Jacobi( <n>, <m> ) . . . . . . . . . . . . . . . . . . . .  Jacobi symbol
##
##  'Jacobi'  returns  the  value of the  Jacobian symbol of the  integer <n>
##  modulo the nonnegative integer <m>.
##
##  A description of the Jacobi symbol and related topics can  be  found  in:
##  A. Baker, The theory of numbers, Cambridge University Press, 1984,  27-33
##
#N  29-Apr-91 martin remember to change the description of 'Jacobi'
##
Jacobi := function ( n, m )
    local  jac, t;

    # check the argument
    if m <= 0  then Error("<m> must be positive");  fi;

    # compute the jacobi symbol similar to euclids algorithm
    jac := 1;
    while m <> 1  do

        # if the gcd of $n$ and $m$ is $>1$ Jacobi returns $0$
        if n = 0 or (n mod 2 = 0 and m mod 2 = 0)  then
            jac := 0;  m := 1;

        # $J(n,2*m) = J(n,m) * J(n,2) = J(n,m) * (-1)^{(n^2-1)/8}$
        elif m mod 2 = 0  then
            if n mod 8 = 3  or  n mod 8 = 5  then jac := -jac;  fi;
            m := m / 2;

        # $J(2*n,m) = J(n,m) * J(2,m) = J(n,m) * (-1)^{(m^2-1)/8}$
        elif n mod 2 = 0  then
            if m mod 8 = 3  or  m mod 8 = 5  then jac := -jac;  fi;
            n := n / 2;

        # $J(-n,m) = J(n,m) * J(-1,m) = J(n,m) * (-1)^{(m-1)/2}$
        elif n < 0  then
            if m mod 4 = 3  then jac := -jac;  fi;
            n := -n;

        # $J(n,m) = J(m,n) * (-1)^{(n-1)*(m-1)/4}$ (quadratic reciprocity)
        else
            if n mod 4 = 3  and m mod 4 = 3  then jac := -jac;  fi;
            t := n;  n := m mod n;  m := t;

        fi;
    od;

    return jac;
end;


#############################################################################
##
#F  Legendre( <n>, <m> )  . . . . . . . . . . . . . . . . . . Legendre symbol
##
##  'Legendre' returns  the value of the Legendre  symbol of the  integer <n>
##  modulo the positive integer <m>.
##
##  A description of the Legendre symbol and related topics can be found  in:
##  A. Baker, The theory of numbers, Cambridge University Press, 1984,  27-33
##
Legendre := function ( n, m )
    local  p, q, o;

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    if n <  0  then n := n mod m + m;  fi;
    if m <= n  then n := n mod m;      fi;

    # handle small values
    if n in [0,1,4,9,16]  then return  1;  fi;
    if m < 6              then return -1;  fi;

    # check that $n$ is a quadratic residue modulo every prime power $q$
    for p  in Set( FactorsInt( m ) )  do

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
end;


#############################################################################
##
#F  RootMod( <n>, <k>, <m> )  . . . . . . . . . . . .  root modulo an integer
##
##  In the  second form  'RootMod' computes a  <k>th root  of the integer <n>
##  modulo the positive integer <m>, i.e., a <r> such that $r^k = n$ mod <m>.
##  If no such root exists 'RootMod' returns 'false'.
##
##  In the current implementation <k> must be a prime.
##
RootModPrime := function ( n, k, p )
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

    # handle $p = 2$
    if p = 2  then
        r := n;

    # handle $n = 0$ (only possibility that <n> and <p> are not rel. prime)
    elif n = 0  then
        r := 0;

    # its easy if $k$ is invertable mod $p-1 = \phi(p)$
    elif GcdInt( p-1, k ) = 1  then
        Info( InfoNumtheor, 2, " <r> = <n>^", 1/k mod (p-1), " mod <p>" );
        r := PowerModInt( n, 1/k mod (p-1), p );

    # check that $n$ has a $k$th root (Eulers criterium)
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
        # i.e., $t^{kk/k} <> 1,  t^{kk} = 1$, therefor $s = (t^l)^k$
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
        r := false;

    fi;

    # return the root $r$
    Info( InfoNumtheor, 1, "RootModPrime returns ", r );
    return r;
end;

RootModPrimePower := function ( n, k, p, l )
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
        if s <> false  then
            r := s * p;
        else
            r := false;
        fi;

    # if $n$ is a multiple of $p$ but not of $p^k$ then no root exists
    elif n mod p = 0  then
        r := false;

    # handle the case that the root may not lift
    elif k = p  then

        # compute the root mod $p^{l/2}$, or $p^{l/2+1}$ if 32 divides $p^l$
        if 2 < p  or l < 5  then
            s := RootModPrimePower( n, k, p, QuoInt(l+1,2) );
        else
            s := RootModPrimePower( n, k, p, QuoInt(l+3,2) );
        fi;

        # lift the root to $p^l$, use higher precision
        Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
        t := PowerModInt( s, k-1, p^(l+1) );
        r := (s + (n - t * s) / (k * t)) mod p^l;
        if PowerModInt(r,k,p^l) <> n mod p^l  then
            r := false;
        fi;

    # otherwise lift the root with Newton / Hensel
    else

        # compute the root mod $p^{l/2}$, or $p^{l/2+1}$ if 32 divides $p^l$
        if 2 < p  or l < 5  then
            s := RootModPrimePower( n, k, p, QuoInt(l+1,2) );
        else
            s := RootModPrimePower( n, k, p, QuoInt(l+3,2) );
        fi;

        # lift the root to $p^l$
        Info( InfoNumtheor, 2, " lift root with Newton / Hensel" );
        t := PowerModInt( s, k-1, p^l );
        r := (s + (n - t * s) / (k * t)) mod p^l;

    fi;

    # return the root $r$
    Info( InfoNumtheor, 1, "RootModPrimePower returns ", r );
    return r;
end;

RootMod := function ( arg )
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
            t;                  # temporary variable

    # get the arguments
    if   Length(arg) = 2  then n := arg[1];  k := 2;       m := arg[2];
    elif Length(arg) = 3  then n := arg[1];  k := arg[2];  m := arg[3];
    else Error("usage: RootMod( <n>, <m> ) or RootMod( <n>, <k>, <m> )");
    fi;
    Info( InfoNumtheor, 1, "RootMod(", n, ",", k, ",", m, ")" );

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    n := n mod m;

    # combine the root modulo every prime power $p^l$
    r := 0;  qq := 1;
    for p  in Set( FactorsInt( m ) )  do

        # find prime power $q = p^l$
        q := p;  l := 1;
        while m mod (q * p) = 0  do q := q * p;  l := l + 1;  od;

        # compute the root mod $p^l$
        s := RootModPrimePower( n, k, p, l );
        if s = false  then
            Info( InfoNumtheor, 1, "RootMod returns 'false'" );
            return false;
        fi;

        # combine $r$ (the root mod $qq$) with $s$ (the root mod $p^l$)
        ii := 1/qq mod q;
        t := r + qq * ((s - r)*ii mod q);
        r := t;
        qq := qq * q;

    od;

    # return the root $rr$
    Info( InfoNumtheor, 1, "RootMod returns ", r );
    return r;
end;


#############################################################################
##
#F  RootsMod( <n>, <k>, <m> ) . . . . . . . . . . . . roots modulo an integer
##
##  In the second form 'RootsMod' computes the <k>th roots of the integer <n>
##  modulo the positive integer <m>, ie. the <r> such that $r^k = n$ mod <m>.
##  If no such roots exist 'RootsMod' returns '[]'.
##
##  In the current implementation <k> must be a prime.
##
RootsModPrime := function ( n, k, p )
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

    # handle $p = 2$
    if p = 2  then
        rr := [ n ];

    # handle $n = 0$ (only possibility that <n> and <p> are not rel. prime)
    elif n = 0  then
        rr := [ 0 ];

    # its easy if $k$ is invertable mod $p-1 = \phi(p)$
    elif GcdInt( p-1, k ) = 1  then
        Info( InfoNumtheor, 2, " <r> = <n>^", 1/k mod (p-1), " mod <p>" );
        rr := [ PowerModInt( n, 1/k mod (p-1), p ) ];

    # check that $n$ has a $k$th root (Eulers criterium)
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
        # i.e., $t^{kk/k} <> 1,  t^{kk} = 1$, therefor $s = (t^l)^k$
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
end;

RootsModPrimePower := function ( n, k, p, l )
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
    Info( InfoNumtheor, 1, "RootsModPrimePower returns ", r );
    return rr;
end;

RootsMod := function ( arg )
    local   n,                  # <n>, first argument
            k,                  # <k>, optional second argument
            m,                  # <m>, third argument
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
    if   Length(arg) = 2  then n := arg[1];  k := 2;       m := arg[2];
    elif Length(arg) = 3  then n := arg[1];  k := arg[2];  m := arg[3];
    else Error("usage: RootsMod( <n>, <m> ) or RootsMod( <n>, <k>, <m> )");
    fi;
    Info( InfoNumtheor, 1, "RootsMod(", n, ",", k, ",", m, ")" );

    # check the arguments and reduce $n$ into the range $0..m-1$
    if m <= 0  then Error("<m> must be positive");  fi;
    n := n mod m;

    # combine the roots modulo every prime power $p^l$
    rr := [0];  qq := 1;
    for p  in Set( FactorsInt( m ) )  do

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
end;


#############################################################################
##
#F  RootsUnityMod(<k>,<m>)  . . . . . . . .  roots of unity modulo an integer
##
##  'RootsUnityMod' returns a list of <k>-th roots of unity modulo a positive
##  integer <m>, i.e., the list of all solutions <r> of <r>^<k> = 1 mod <m>.
##
##  In the current implementation <k> must be a prime.
##
RootsUnityModPrime := function ( k, p )
    local   rr,                 # <k>th roots of 1 mod <p>, result
            r,                  # <k>th root of unity mod <p>
            t,                  # <k>th root of unity mod <p>
            i;                  # loop variable

    # reduce $n$ into the range $0..p-1$
    Info( InfoNumtheor, 1, "RootsUnityModPrime(", k, ",", p, ")" );

    # handle $p = 2$
    if p = 2  then
        rr := [ 1 ];

    # its easy if $k$ is invertable mod $p-1 = \phi(p)$
    elif GcdInt( p-1, k ) = 1  then
        rr := [ 1 ];

    # check that $n$ has a $k$th root (Eulers criterium)
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
end;

RootsUnityModPrimePower := function ( k, p, l )
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

    # if $k$ is invertable mod $\phi(p^l)$ then there is only one root
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
    Info( InfoNumtheor, 1, "RootsUnityModPrimePower returns ", r );
    return rr;
end;

RootsUnityMod := function ( arg )
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
    for p  in Set( FactorsInt( m ) )  do

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
end;


#############################################################################
##
#F  LogMod( <n>, <r>, <m> ) . . . . . .  discrete logarithm modulo an integer
##
LogMod := function ( n, r, m )
    local   x, l;
    n := n mod m;
    x := 1;
    l := 0;
    while x <> n  do
        x := (x * r) mod m;
        l := l + 1;
        if l = m  then
            return false;
        fi;
    od;
    return l;
end;


#############################################################################
##
#F  TwoSquares(<n>) . .  representation of an integer as a sum of two squares
##
TwoSquares := function ( n )
    local  c, d, p, q, l, x, y;

    # check arguments and handle special cases
    if   n < 0  then Error("<n> must be positive");
    elif n = 0  then return [ 0, 0 ];
    elif n = 1  then return [ 0, 1 ];
    fi;

    # write $n = c^2 d$, where $c$ has only  prime factors  $2$  and  $4k+3$,
    # and $d$ has at most one  $2$ and otherwise only  prime factors  $4k+1$.
    c := 1;  d := 1;
    for p  in Set( FactorsInt( n ) )  do
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
            return false;
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
end;


#T ##########################################################################
#T ##
#T #F  IsResidueClass(<obj>) . . . . . . .  test if an object is a residue class
#T ##
#T IsResidueClass := function ( obj )
#T     return IsRec( obj )
#T            and IsBound( obj.isResidueClass )
#T            and obj.isResidueClass;
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #F  ResidueClass(<representative>,<modulus>)  . . . .  create a residue class
#T ##
#T ResidueClass := function ( representative, modulus )
#T     local res;
#T     res := rec();
#T     res.isGroupElement  := true;
#T     res.isDomain        := true;
#T     res.isResidueClass  := true;
#T     res.representative  := representative mod modulus;
#T     res.modulus         := modulus;
#T     res.isFinite        := false;
#T     res.size            := "infinity";
#T     res.domain          := ResidueClasses;
#T     res.operations      := ResidueClassOps;
#T     return res;
#T end;
#T
#T ResidueClassOps := MergedRecord( GroupElementOps, DomainOps );
#T
#T ResidueClassOps.\= := function ( l, r )
#T     local   isEql;
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             isEql :=    l.representative = r.representative
#T                     and l.modulus        = r.modulus;
#T         else
#T             isEql := false;
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             isEql := false;
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return isEql;
#T end;
#T
#T ResidueClassOps.\< := function ( l, r )
#T     local   isLess;
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             isLess :=   l.representative < r.representative
#T                     or (l.representative = r.representative
#T                         and l.modulus    < r.modulus);
#T         else
#T             isLess := not IsInt( r ) and not IsRat( r )
#T                   and not IsCyc( r ) and not IsPerm( r )
#T                   and not IsWord( r ) and not IsAgWord( r );
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             isLess :=  IsInt( l ) or IsRat( l )
#T                     or IsCyc( l ) or IsPerm( l )
#T                     or IsWord( l ) or IsAgWord( l );
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return isLess;
#T end;
#T
#T ResidueClassOps.\* := function ( l, r )
#T     local   prd;        # product of <l> and <r>, result
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             if l.modulus <> r.modulus  then
#T                 Error( "<l> and <r> must have the same modulus" );
#T             fi;
#T             prd := ResidueClass(
#T                         l.representative * r.representative,
#T                         l.modulus );
#T         elif IsList( r )  then
#T             prd := List( r, x -> l * x );
#T         else
#T             Error("product of <l> and <r> must be defined");
#T         fi;
#T     elif IsList( l )  then
#T         if IsResidueClass( r )  then
#T             prd := List( l, x -> x * r );
#T         else
#T             Error("panic: neither <l> nor <r> is a residue class");
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             if IsRec( l )  and IsBound( l.operations )
#T                 and IsBound( l.operations.\* )
#T                 and l.operations.\* <> ResidueClassOps.\*
#T             then
#T                 prd := l.operations.\*( l, r );
#T             else
#T                 Error("product of <l> and <r> must be defined");
#T             fi;
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return prd;
#T end;
#T
#T ResidueClassOps.\^ := function ( l, r )
#T     local    pow;
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             if l.modulus <> r.modulus  then
#T                 Error("<l> and <r> must have the same modulus");
#T             fi;
#T             if GcdInt( r.representative, r.modulus ) <> 1  then
#T                 Error("<r> must be invertable");
#T             fi;
#T             pow := l;
#T         elif IsInt( r )  then
#T             pow := ResidueClass(
#T                         PowerMod( l.representative, r, l.modulus ),
#T                         l.modulus );
#T         else
#T             Error("power of <l> and <r> must be defined");
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             Error("power of <l> and <r> must be defined");
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return pow;
#T end;
#T
#T ResidueClassOps.\in := function ( element, class )
#T     if IsInt( element )  then
#T         return (element mod class.modulus = class.representative);
#T     else
#T         return false;
#T     fi;
#T end;
#T
#T ResidueClassOps.Intersection := function ( R, S )
#T     local   I,          # intersection of <R> and <S>, result
#T             gcd;        # gcd of the moduli
#T     if IsResidueClass( R )  then
#T         if IsResidueClass( S )  then
#T             gcd := GcdInt( R.modulus, S.modulus );
#T             if     R.representative mod gcd
#T                 <> S.representative mod gcd
#T             then
#T                 I := [];
#T             else
#T                 I := ResidueClass(
#T                         ChineseRem(
#T                                [ R.representative, S.representative ],
#T                                [ R.modulus,        S.modulus ] ),
#T                         LcmInt(  R.modulus,        S.modulus ) );
#T             fi;
#T         else
#T             I := DomainOps.Intersection( R, S );
#T         fi;
#T     else
#T         I := DomainOps.Intersection( R, S );
#T     fi;
#T     return I;
#T end;
#T
#T ResidueClassOps.Print := function ( r )
#T     Print("ResidueClass( ",r.representative,", ",r.modulus," )");
#T end;
#T
#T ResidueClassOps.Group := function ( R )
#T     return ResidueClassesOps.Group( ResidueClasses, [R], R^0 );
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #V  ResidueClasses  . . . . . . . . . . . . . . domain of all residue classes
#T ##
#T ResidueClasses            := Copy( GroupElements );
#T ResidueClasses.name       := "ResidueClasses";
#T ResidueClassesOps         := OperationsRecord( "ResidueClassesOps",
#T                                                GroupElementsOps );
#T ResidueClasses.operations := ResidueClassesOps;
#T
#T ResidueClassesOps.Group := function ( ResidueClasses, gens, id )
#T     local   G,          # group <G>, result
#T             gen;        # one generator from <gens>
#T     for gen  in gens  do
#T         if gen.modulus <> id.modulus  then
#T             Error("the generators must all have the same modulus");
#T         fi;
#T         if GcdInt( gen.representative, gen.modulus ) <> 1  then
#T           Error("the generators must all be prime residue classes");
#T         fi;
#T     od;
#T     G := GroupElementsOps.Group( ResidueClasses, gens, id );
#T     G.modulus    := id.modulus;
#T     G.operations := ResidueClassGroupOps;
#T     return G;
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #V  ResidueClassGroupOps  . . . . operations record of residue classes groups
#T ##
#T ResidueClassGroupOps := OperationsRecord( "ResidueClassGroupOps", GroupOps );
#T
#T ResidueClassGroupOps.Subgroup := function ( G, gens )
#T     local   S,          # subgroup of <G>, result
#T             gen;        # one generator from <gens>
#T     for gen  in gens  do
#T         if gen.modulus <> G.modulus  then
#T             Error("the generators must all have the same modulus");
#T         fi;
#T         if GcdInt( gen.representative, gen.modulus ) <> 1  then
#T           Error("the generators must all be prime residue classes");
#T         fi;
#T     od;
#T     S := GroupOps.Subgroup( G, gens );
#T     S.modulus    := G.modulus;
#T     S.operations := ResidueClassGroupOps;
#T     return S;
#T end;
#T
#T ResidueClassGroupOps.TrivialSubgroup := function ( G )
#T     local   T;
#T     T := GroupOps.TrivialSubgroup( G );
#T     Unbind( T.elements );
#T     return T;
#T end;
#T
#T ResidueClassGroupOps.SylowSubgroup := function ( G, p )
#T     local   S,          # Sylow subgroup of <G>, result
#T             gen,        # one generator of <G>
#T             ord,        # order of <gen>
#T             gens;       # generators of <S>
#T     gens := [];
#T     for gen  in G.generators  do
#T         ord := OrderMod( gen.representative, G.modulus );
#T         while ord mod p = 0  do ord := ord / p;  od;
#T         Add( gens, gen ^ ord );
#T     od;
#T     S := Subgroup( Parent( G ), gens );
#T     return S;
#T end;
#T
#T ResidueClassGroupOps.MakeFactors := function ( G )
#T     local   p, q,       # prime factor of modulus and largest power
#T             r, s,       # two rows of the standard generating system
#T             g,          # extended gcd of leading entries in <r>, <s>
#T             x, y,       # two entries in <r> and <s>
#T             i, k, l;    # loop variables
#T
#T     # find the factors of the direct product
#T     G.facts := [];
#T     G.roots := [];
#T     G.sizes := [];
#T     for p  in Set( Factors( G.modulus ) )  do
#T         q := p;
#T         while G.modulus mod (p*q) = 0  do q := p*q;  od;
#T         if q mod 4 = 0  then
#T             Add( G.facts, 4 );
#T             Add( G.roots, 3 );
#T             Add( G.sizes, 2 );
#T         fi;
#T         if q mod 8 = 0  then
#T             Add( G.facts, q );
#T             Add( G.roots, 5 );
#T             Add( G.sizes, q/4 );
#T         fi;
#T         if p <> 2  then
#T             Add( G.facts, q );
#T             Add( G.roots, PrimitiveRootMod( q ) );
#T             Add( G.sizes, (p-1)*q/p );
#T         fi;
#T     od;
#T
#T     # represent each generator in this factorization
#T     G.sgs := [];
#T     for k  in [ 1 .. Length( G.generators ) ]  do
#T         G.sgs[k] := [];
#T         for i  in [ 1 .. Length( G.facts ) ]  do
#T             if G.facts[i] mod 8 = 0  then
#T                 if G.generators[k].representative mod 4 = 1  then
#T                     G.sgs[k][i] := LogMod(
#T                         G.generators[k].representative,
#T                         G.roots[i], G.facts[i] );
#T                 else
#T                     G.sgs[k][i] := LogMod(
#T                         -G.generators[k].representative,
#T                         G.roots[i], G.facts[i] );
#T                 fi;
#T             else
#T                 G.sgs[k][i] := LogMod(
#T                         G.generators[k].representative,
#T                         G.roots[i], G.facts[i] );
#T             fi;
#T         od;
#T     od;
#T     for i  in [ Length( G.sgs ) + 1 .. Length( G.facts ) ]  do
#T         G.sgs[i] := 0 * G.facts;
#T     od;
#T
#T     # bring this matrix to diagonal form
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         r := G.sgs[i];
#T         for k  in [ i+1 .. Length( G.sgs ) ]  do
#T             s := G.sgs[k];
#T             g := Gcdex( r[i], s[i] );
#T             for l  in [ i .. Length( r ) ]  do
#T                 x := r[l];  y := s[l];
#T                 r[l] := (g.coeff1 * x + g.coeff2 * y) mod G.sizes[l];
#T                 s[l] := (g.coeff3 * x + g.coeff4 * y) mod G.sizes[l];
#T             od;
#T         od;
#T         s := [];
#T         x := G.sizes[i] / GcdInt( G.sizes[i], r[i] );
#T         for l  in [ 1 .. Length( r ) ]  do
#T             s[l] := (x * r[l]) mod G.sizes[l];
#T         od;
#T         Add( G.sgs, s );
#T     od;
#T
#T end;
#T
#T ResidueClassGroupOps.Size := function ( G )
#T     local   s,          # size of <G>, result
#T             i;          # loop variable
#T     if not IsBound( G.facts )  then
#T         G.operations.MakeFactors( G );
#T     fi;
#T     s := 1;
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         s := s * G.sizes[i] / GcdInt( G.sizes[i], G.sgs[i][i] );
#T     od;
#T     return s;
#T end;
#T
#T ResidueClassGroupOps.\in := function ( res, G )
#T     local   s,          # exponent vector of <res>
#T             g,          # extended gcd
#T             x, y,       # two entries in <s> and '<G>.sgs[i]'
#T             i, l;       # loop variables
#T     if not IsResidueClass( res )
#T         or res.modulus <> G.modulus
#T         or GcdInt( res.representative, res.modulus ) <> 1
#T     then
#T         return false;
#T     fi;
#T     if not IsBound( G.facts )  then
#T         G.operations.MakeFactors( G );
#T     fi;
#T     s := [];
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         if G.facts[i] mod 8 = 0  then
#T             if res.representative mod 4 = 1  then
#T                 s[i] := LogMod( res.representative,
#T                                 G.roots[i], G.facts[i] );
#T             else
#T                 s[i] := LogMod( -res.representative,
#T                                 G.roots[i], G.facts[i] );
#T             fi;
#T         else
#T             s[i] := LogMod( res.representative,
#T                             G.roots[i], G.facts[i] );
#T         fi;
#T     od;
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         if s[i] mod GcdInt( G.sizes[i], G.sgs[i][i] ) <> 0  then
#T             return false;
#T         fi;
#T         g := Gcdex( G.sgs[i][i], s[i] );
#T         for l  in [ i .. Length( G.facts ) ]  do
#T             x := G.sgs[i][l];  y := s[l];
#T             s[l] := (g.coeff3 * x + g.coeff4 * y) mod G.sizes[l];
#T         od;
#T     od;
#T     return true;
#T end;
#T
#T ResidueClassGroupOps.Random := function ( G )
#T     local   s,          # exponent vector of random element
#T             r,          # vector of remainders in each factor
#T             i, k, l;    # loop variables
#T     if not IsBound( G.facts )  then
#T         G.operations.MakeFactors( G );
#T     fi;
#T     s := 0 * G.facts;
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         l := G.sizes[i] / GcdInt( G.sizes[i], G.sgs[i][i] );
#T         k := Random( [ 0 .. l-1 ] );
#T         for l  in [ i .. Length( s ) ]  do
#T             s[l] := (s[l] + k * G.sgs[i][l]) mod G.sizes[l];
#T         od;
#T     od;
#T     r := [];
#T     for l  in [ 1 .. Length( s ) ]  do
#T         r[l] := PowerModInt( G.roots[l], s[l], G.facts[l] );
#T         if G.facts[l] mod 8 = 0  and r[1] = 3  then
#T             r[l] := G.facts[l] - r[l];
#T         fi;
#T     od;
#T     return ResidueClass( ChineseRem( G.facts, r ), G.modulus );
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #F  PrimeResidueClassGroup(<m>) . . . . . . .  full prime residue class group
#T ##
#T PrimeResidueClassGroup := function ( m )
#T     local   G,          # group $Z/mZ$, result
#T             gens,       # generators of <G>
#T             p, q,       # prime and prime power dividing <m>
#T             r,          # primitive root modulo <q>
#T             g;          # is = <r> mod <q> and = 1 mod <m> / <q>
#T
#T     # add generators for each prime power factor <q> of <m>
#T     gens := [];
#T     for p  in Set( Factors( m ) )  do
#T         q := p;
#T         while m mod (q * p) = 0  do q := q * p;  od;
#T
#T         # $ Z / 4Z = < 3 > $
#T         if   q = 4  then
#T             r := 3;
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T
#T         # $ Z / 8nZ = < 5, -1 > $ is *not* cyclic
#T         elif q mod 8 = 0  then
#T             r := q-1;
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T             r := 5;
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T
#T         # for odd <q> $ Z / qZ $ is cyclic
#T         elif q <> 2  then
#T             r :=  PrimitiveRootMod( q );
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T         fi;
#T
#T     od;
#T
#T     # return the group generated by <gens>
#T     G := Group( gens, ResidueClass( 1, m ) );
#T     G.size := Phi( m );
#T     return G;
#T end;


#############################################################################
##
#E  numtheor.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



