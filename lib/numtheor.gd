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
##
Revision.numtheor_gd:=
    "@(#)$Id$";


##########################################################################
##
#V  InfoNumtheor
##
DeclareInfoClass( "InfoNumtheor" );


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
DeclareGlobalFunction( "PrimeResidues" );


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
DeclareGlobalFunction( "Phi" );


#############################################################################
##
#F  Lambda( <m> ) . . . . . . . . . . . . . . . . . . .  Carmichaels function
##
##  'Lambda' returns the exponent of the group  of  relative  prime  residues
##  modulo the integer <m>.
##
##  Carmichaels theorem states that 'Lambda'  can  be  computed  as  follows:
##  $Lambda(2) = 1$, $Lambda(4) = 2$ and $Lambda(2^e) = 2^{e-2}$ if $3 \le e$,
##  $Lambda(p^e) = (p-1) p^{e-1}$ (i.e. $Phi(m)$) if $p$ is an odd prime  and
##  $Lambda(n*m) = Lcm( Lambda(n), Lambda(m) )$ if $n, m$ are relative prime.
##
DeclareGlobalFunction( "Lambda" );


#############################################################################
##
#F  OrderMod( <n>, <m> )  . . . . . . . .  multiplicative order of an integer
##
##  'OrderMod' returns the multiplicative order of the integer <n> modulo the
##  positive integer <m>.  If <n> and <m> are not relativ prime the order  if
##  <n> is not defined and 'OrderInt' will return 0.
##
DeclareGlobalFunction( "OrderMod" );


#############################################################################
##
#F  IsPrimitiveRootMod( <r>, <m> )  . . . . . . . . test for a primitive root
##
##  'IsPrimitiveRootMod' returns  'true' if the  integer <r>  is a  primitive
##  root modulo the positive integer <m> and 'false' otherwise.
##
DeclareGlobalFunction( "IsPrimitiveRootMod" );


#############################################################################
##
#F  PrimitiveRootMod( <m> ) . . . . . . . .  primitive root modulo an integer
##
##  'PrimitiveRootMod' returns the smallest primitive root modulo the integer
##  <m> and 'false' if no such primitive root exists.  If the optional second
##  integer argument <start> is given 'PrimitiveRootMod' returns the smallest
##  primitive root that is strictly larger than <start>.
##
DeclareGlobalFunction( "PrimitiveRootMod" );


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
DeclareGlobalFunction( "Jacobi" );


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
DeclareGlobalFunction( "Legendre" );


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
DeclareGlobalFunction( "RootMod" );


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
DeclareGlobalFunction( "RootsMod" );


#############################################################################
##
#F  RootsUnityMod(<k>,<m>)  . . . . . . . .  roots of unity modulo an integer
##
##  'RootsUnityMod' returns a list of <k>-th roots of unity modulo a positive
##  integer <m>, i.e., the list of all solutions <r> of <r>^<k> = 1 mod <m>.
##
##  In the current implementation <k> must be a prime.
##
DeclareGlobalFunction( "RootsUnityMod" );


#############################################################################
##
#F  LogMod( <n>, <r>, <m> ) . . . . . .  discrete logarithm modulo an integer
##
##  computes the discrete <r>-logarithm of <n> modulo the integer <m>. It
##  returns a number <l> such that $<r>^{<l>}\equiv <n>\pmod{<m>}$.
##
DeclareGlobalFunction( "LogMod" );


#############################################################################
##
#F  TwoSquares(<n>) . .  representation of an integer as a sum of two squares
##
##  'TwoSquares' returns a list of two integers $x\le y$ such that  the sum of
##  the squares of $x$ and $y$ is equal to the nonnegative integer <n>, i.e.,
##  $n = x^2+y^2$.  If no such representation exists 'TwoSquares' will return
##  'false'.  'TwoSquares' will return a representation for which the  gcd of
##  $x$  and   $y$ is  as  small  as  possible.    It is not  specified which
##  representation 'TwoSquares' returns, if there are more than one.
##
##  Let $a$ be the product of all maximal powers of primes of the form $4k+3$
##  dividing $n$.  A representation of $n$ as a sum of two squares  exists if
##  and only if $a$ is a perfect square.  Let $b$ be the maximal power of $2$
##  dividing $n$ or its half, whichever is a perfect square.  Then the minmal
##  possible gcd of $x$ and $y$ is the square root $c$ of $a b$.  The  number
##  of different minimal representation with $x\le y$ is $2^{l-1}$, where  $l$
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
#E  numtheor.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



