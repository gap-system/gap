#############################################################################
##
#W  numtheor.gd                 GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares operations for integer primes.

#1
##  {\GAP} provides a couple of elementary number theoretic functions.
##  Most of these deal with the group of integers coprime to $m$,
##  called the *prime residue group*.
##  $\phi(m)$ (see~"Phi") is the order of this group,
##  $\lambda(m)$ (see~"Lambda") the exponent.
##  If and only if $m$ is 2, 4, an odd prime power $p^e$,
##  or twice an odd prime power $2 p^e$, this group is cyclic.
##  In this case the generators  of the group, i.e., elements of order
##  $\phi(m)$, are called *primitive roots* (see~"PrimitiveRootMod",
##  "IsPrimitiveRootMod").
##
##  Note that neither the arguments nor the return values of the functions
##  listed below are groups or group elements in the sense of {\GAP}.
##  The arguments are simply integers.
##
Revision.numtheor_gd:=
    "@(#)$Id$";


##########################################################################
##
#V  InfoNumtheor
##
##  `InfoNumtheor' is the info class (see~"Info Functions") for the
##  functions in the number theory chapter.
##
DeclareInfoClass( "InfoNumtheor" );


#############################################################################
##
#F  PrimeResidues( <m> )  . . . . . . . integers relative prime to an integer
##
##  `PrimeResidues' returns the set of integers from the range  $0..Abs(m)-1$
##  that are coprime to the integer <m>.
##
##  $Abs(m)$ must be less than $2^{28}$, otherwise the set would probably  be
##  too large anyhow.
##
DeclareGlobalFunction( "PrimeResidues" );


#############################################################################
##
#F  Phi( <m> )  . . . . . . . . . . . . . . . . . .  Euler's totient function
##
##  `Phi' returns the number $\phi(<m>)$ of positive integers less than the
##  positive integer <m> that are coprime to <m>.
##
##  Suppose that $m = p_1^{e_1} p_2^{e_2} .. p_k^{e_k}$.  Then  $\phi(m)$  is
##  $p_1^{e_1-1} (p_1-1) p_2^{e_2-1} (p_2-1) ..  p_k^{e_k-1} (p_k-1)$.
##
DeclareGlobalFunction( "Phi" );


#############################################################################
##
#F  Lambda( <m> ) . . . . . . . . . . . . . . . . . . .  Carmichaels function
##
##  `Lambda' returns the exponent $\lambda(<m>)$ of the group of prime
##  residues modulo the integer <m>.
##
##  $\lambda(m)$ is the smallest positive integer $l$ such that for every $a$
##  relatively prime to $m$ we have $a^l=1$ mod $m$.
##  Fermat's theorem asserts $a^{\phi(m)}=1$ mod $m$,
##  thus $\lambda(m)$ divides $\phi(m)$ (see~"Phi").
##
##  Carmichael's theorem states that $\lambda$ can be computed as follows:
##  $\lambda(2) = 1$, $\lambda(4) = 2$ and $\lambda(2^e) = 2^{e-2}$
##  if $3 \le e$,
##  $\lambda(p^e) = (p-1) p^{e-1}$ (i.e. $\phi(m)$) if $p$ is an odd prime
##  and
##  $\lambda(n*m) = Lcm( \lambda(n), \lambda(m) )$ if $n, m$ are coprime.
##
##  Composites for which $\lambda(m)$ divides $m - 1$ are called Carmichaels.
##  If $6k+1$, $12k+1$ and $18k+1$ are primes their product is such a number.
##  There are only  1547  Carmichaels below $10^{10}$ but  455052511  primes.
##
DeclareGlobalFunction( "Lambda" );


#############################################################################
##
#F  OrderMod( <n>, <m> )  . . . . . . . .  multiplicative order of an integer
##
##  `OrderMod' returns the multiplicative order of the integer <n> modulo the
##  positive integer <m>.
##  If <n> and <m> are not coprime the order of <n> is not defined
##  and `OrderMod' will return 0.
##
##  If $n$ and $m$ are relatively prime the multiplicative order of $n$
##  modulo $m$ is the smallest positive integer $i$ such that $n^i = 1$ mod
##  $m$.
##  If the group of prime residues modulo $m$ is cyclic then each element
##  of maximal order is called a primitive root modulo $m$
##  (see~"IsPrimitiveRootMod").
##
##  `OrderMod' usually spends most of its time factoring <m> and $\phi(m)$
##  (see~"FactorsInt").
##
DeclareGlobalFunction( "OrderMod" );


#############################################################################
##
#F  IsPrimitiveRootMod( <r>, <m> )  . . . . . . . . test for a primitive root
##
##  `IsPrimitiveRootMod' returns  `true' if the  integer <r>  is a  primitive
##  root modulo the positive integer <m> and `false' otherwise.   If  <r>  is
##  less than 0 or larger than <m> it is replaced by its remainder.
##
DeclareGlobalFunction( "IsPrimitiveRootMod" );


#############################################################################
##
#F  PrimitiveRootMod( <m>[,<start>] ) . . .  primitive root modulo an integer
##
##  `PrimitiveRootMod' returns the smallest primitive root modulo the
##  positive integer <m> and `fail' if no such primitive root exists.
##  If the optional second integer argument <start> is given
##  `PrimitiveRootMod' returns the smallest primitive root that is strictly
##  larger than <start>.
##
DeclareGlobalFunction( "PrimitiveRootMod" );


#############################################################################
##
#F  GeneratorsPrimeResidues( <n> ) . . . . . . generators of the Galois group
##
##  Let <n> be a positive integer.
##  `GeneratorsPrimeResidues' returns a description of generators of the
##  group of prime residues modulo <n>.
##  The return value is a record with components
##  \beginitems
##  `primes': &
##      a list of the prime factors of <n>,
##
##  `exponents': &
##      a list of the exponents of these primes in the factorization of <n>,
##      and
##
##  `generators': &
##      a list describing generators of the group of prime residues;
##      for the prime factor $2$, either a primitive root or a list of two
##      generators is stored,
##      for each other prime factor of <n>, a primitive root is stored.
##  \enditems
##
DeclareGlobalFunction( "GeneratorsPrimeResidues" );


#############################################################################
##
#F  Jacobi( <n>, <m> ) . . . . . . . . . . . . . . . . . . . .  Jacobi symbol
##
##  `Jacobi'  returns  the value of  the *Jacobi symbol*  of  the integer <n>
##  modulo the integer <m>.
##
##  Suppose that $m = p_1 p_2 .. p_k$ is a product of primes, not necessarily
##  distinct.   Then for $n$  coprime to $m$   the Jacobi  symbol is
##  defined by $J(n/m) =  L(n/p_1)  L(n/p_2) ..  L(n/p_k)$, where $L(n/p)$ is
##  the Legendre symbol (see~"Legendre").   By convention $J(n/1)  = 1$.  If
##  the gcd of $n$ and $m$ is larger than 1 we define $J(n/m) = 0$.
##
##  If $n$ is a *quadratic residue* modulo $m$, i.e., if there exists an $r$
##  such that  $r^2 =  n$ mod  $m$  then $J(n/m)  = 1$.  However $J(n/m) = 1$
##  implies the existence of such an $r$ only if $m$ is a prime.
##
##  `Jacobi' is very efficient, even for large values of <n> and <m>,  it  is
##  about as fast as the Euclidean algorithm (see~"Gcd").
##
DeclareGlobalFunction( "Jacobi" );


#############################################################################
##
#F  Legendre( <n>, <m> )  . . . . . . . . . . . . . . . . . . Legendre symbol
##
##  `Legendre' returns  the value of the *Legendre symbol* of the integer <n>
##  modulo the positive integer <m>.
##
##  The value  of  the Legendre  symbol $L(n/m)$ is 1 if  $n$ is a *quadratic
##  residue* modulo $m$, i.e., if there exists an  integer $r$ such that $r^2
##  = n$ mod $m$ and -1 otherwise.
##
##  If a root of <n> exists it can be found by `RootMod' (see "RootMod").
##
##  While the value of the Legendre symbol usually  is only defined for <m> a
##  prime, we have extended the  definition to include composite moduli  too.
##  The  Jacobi  symbol  (see "Jacobi")  is    another generalization  of the
##  Legendre symbol for composite moduli that is  much  cheaper  to  compute,
##  because it does not need the factorization of <m> (see "FactorsInt").
##
##  A description of the Jacobi symbol, the Legendre symbol, and related
##  topics can be found  in:
##  A. Baker, The theory of numbers, Cambridge University Press, 1984,  27-33
##
DeclareGlobalFunction( "Legendre" );


#############################################################################
##
#F  RootMod( <n>[, <k>], <m> )  . . . . . . . . . . .  root modulo an integer
##
##  `RootMod' computes a <k>th root of the integer <n> modulo the positive
##  integer <m>, i.e., a <r> such that $r^k = n$ mod <m>.
##  If no such root exists `RootMod' returns `fail'.
##  If only the arguments <n> and <m> are given,
##  the default value for <k> is $2$.
##
##  In the current implementation <k> must be a prime.
##
##  A square root of <n> exists only if `Legendre(<n>,<m>) = 1'
##  (see~"Legendre").
##  If <m> has $r$ different prime factors then  there are $2^r$  different
##  roots of <n> mod  <m>.  It is  unspecified  which  one `RootMod' returns.
##  You can, however, use `RootsMod' (see~"RootsMod") to compute the full set
##  of roots.
##
##  `RootMod' is efficient even for large values of <m>, in fact the  most
##  time is usually spent factoring <m> (see "FactorsInt").
##
DeclareGlobalFunction( "RootMod" );


#############################################################################
##
#F  RootsMod( <n>[, <k>], <m> ) . . . . . . . . . . . roots modulo an integer
##
##  `RootsMod' computes the set of <k>th roots of the integer <n>
##  modulo the positive integer <m>, ie. the <r> such that $r^k = n$ mod <m>.
##  If only the arguments <n> and <m> are given,
##  the default value for <k> is $2$.
##
##  In the current implementation <k> must be a prime.
##
DeclareGlobalFunction( "RootsMod" );


#############################################################################
##
#F  RootsUnityMod( [<k>,] <m> ) . . . . . .  roots of unity modulo an integer
##
##  `RootsUnityMod' returns the set of <k>-th roots of unity modulo the
##  positive integer <m>, i.e.,
##  the list of all solutions $r$ of $r^<k> = 1$ mod <m>.
##  If only the argument <m> is given, the default value for <k> is $2$.
##
##  In  general  there are  $k^n$ such  roots if  the  modulus  <m>  has  <n>
##  different prime factors <p> such that $p  = 1$ mod $k$.  If $k^2$ divides
##  $m$ then there are $k^{n+1}$ such roots; and especially if $k = 2$  and 8
##  divides $m$ there are $2^{n+2}$ such roots.
##
##  In the current implementation <k> must be a prime.
##
DeclareGlobalFunction( "RootsUnityMod" );


#############################################################################
##
#F  LogMod( <n>, <r>, <m> ) . . . . . .  discrete logarithm modulo an integer
##
##  computes the discrete <r>-logarithm of the integer <n> modulo the integer
##  <m>.
##  It returns a number <l> such that $<r>^{<l>}\equiv <n>\pmod{<m>}$
##  if such a number exists.
##  Otherwise `fail' is returned.
##
DeclareGlobalFunction( "LogMod" );


#############################################################################
##
#F  Sigma( <n> )  . . . . . . . . . . . . . . . sum of divisors of an integer
##
##  `Sigma' returns the sum of the positive divisors of the integer <n>.
##
##  `Sigma' is a multiplicative arithmetic function, i.e., if $n$ and $m$ are
##  relatively prime we have $\sigma(n m) = \sigma(n) \sigma(m)$.
##
##  Together with the formula $\sigma(p^e) = (p^{e+1}-1) / (p-1)$ this allows
##  us to compute $\sigma(n)$.
##
##  Integers  $n$ for which $\sigma(n)=2 n$ are called perfect.  Even perfect
##  integers are exactly of the form $2^{n-1}(2^n-1)$ where $2^n-1$ is prime.
##  Primes of the form  $2^n-1$ are called *Mersenne  primes*, the known ones
##  are obtained for $n =$ 2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521,
##  607, 1279, 2203, 2281, 3217, 4253, 4423, 9689, 9941, 11213, 19937, 21701,
##  23209,  44497, 86243, 110503, 132049,  216091, 756839, and 859433.  It is
##  not known whether odd  perfect integers  exist, however~\cite{BC89}  show
##  that any such integer must have at least 300 decimal digits.
##
##  `Sigma' usually spends most of its time factoring <n> (see "FactorsInt").
##
DeclareGlobalFunction( "Sigma" );


#############################################################################
##
#F  Tau( <n> )  . . . . . . . . . . . . . .  number of divisors of an integer
##
##  `Tau' returns the number of the positive divisors of the integer <n>.
##
##  `Tau' is a multiplicative arithmetic function, i.e., if $n$ and  $m$  are
##  relative prime we have $\tau(n m) = \tau(n) \tau(m)$.
##  Together with the formula $\tau(p^e) = e+1$ this allows us to compute
##  $\tau(n)$.
##
##  `Tau' usually spends most of its time factoring <n> (see "FactorsInt").
##
DeclareGlobalFunction( "Tau" );


#############################################################################
##
#F  MoebiusMu( <n> )  . . . . . . . . . . . . . .  Moebius inversion function
##
##  `MoebiusMu'  computes the value  of  Moebius  inversion function for  the
##  integer <n>.   This  is 0 for  integers  which are not squarefree,  i.e.,
##  which are divided by a square $r^2$.  Otherwise it is 1 if <n> has a even
##  number and -1 if <n> has an odd number of prime factors.
##
##  The importance   of $\mu$ stems  from the   so called  inversion formula.
##  Suppose $f(n)$ is a multiplicative arithmetic function defined on the
##  positive integers and  let
##  $g(n)=\sum_{d \mid n}{f(d)}$. Then $f(n)=\sum_{d \mid n}{\mu(d) g(n/d)}$.
##  As a special case we have  $\phi(n) = \sum_{d  \mid n}{\mu(d) n/d}$ since
##  $n = \sum_{d \mid n}{\phi(d)}$ (see~"Phi").
##
##  `MoebiusMu' usually   spends  all of   its    time   factoring <n>   (see
##  "FactorsInt").
##
DeclareGlobalFunction( "MoebiusMu" );


#############################################################################
##
#F  TwoSquares( <n> ) . . . . . repres. of an integer as a sum of two squares
##
##  `TwoSquares' returns a list of two integers $x\le y$ such that the sum of
##  the squares of $x$ and $y$ is equal to the nonnegative integer <n>, i.e.,
##  $n = x^2+y^2$.  If no such representation exists `TwoSquares' will return
##  `fail'.   `TwoSquares' will return a representation for which the  gcd of
##  $x$  and   $y$ is  as  small  as  possible.    It is not  specified which
##  representation `TwoSquares' returns, if there is more than one.
##
##  Let $a$ be the product of all maximal powers of primes of the form $4k+3$
##  dividing $n$.  A representation of $n$ as a sum of two squares  exists if
##  and only if $a$ is a perfect square.  Let $b$ be the maximal power of $2$
##  dividing $n$ or its half, whichever is a perfect square.  Then the minmal
##  possible gcd of $x$ and $y$ is the square root $c$ of $a b$.  The  number
##  of different minimal representation with $x\le y$ is $2^{l-1}$, where $l$
##  is the number of different prime factors of the form $4k+1$ of $n$.
##
##  The algorithm first finds a square root $r$ of $-1$  modulo  $n / (a b)$,
##  which must exist, and applies the Euclidean algorithm  to  $r$  and  $n$.
##  The first residues in the sequence that are smaller than $\sqrt{n/(a b)}$
##  times $c$ are a possible pair $x$ and $y$.
##
##  Better descriptions of the algorithm and related topics can be found  in:
##  S. Wagon,  The Euclidean Algorithm Strikes Again, AMMon 97, 1990, 125-129
##  D. Zagier, A One-Sentence Proof that Every Pri.., AMMon 97, 1990, 144-144
##
DeclareGlobalFunction( "TwoSquares" );


#############################################################################
##
#E

