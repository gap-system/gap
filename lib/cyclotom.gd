#############################################################################
##
#W  cyclotom.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares operations for cyclotomics.
##
Revision.cyclotom_gd :=
    "@(#)$Id$";


#############################################################################
##
#M  IsIntegralRing( <R> ) . . . . . .  Every ring of cyclotomics is integral.
##
InstallTrueMethod( IsIntegralRing,
    IsCyclotomicCollection and IsRing and IsNonTrivial );


#############################################################################
##
#F  RoundCyc( <z> )
##
##  is the cyclotomic integer (see "Cyclotomic Integers") with Zumbroich base
##  coefficients (see "ZumbroichBase") `List( <zumb>, x -> Int( x+1/2 ) )',
##  where <zumb> is the vector of Zumbroich base coefficients of
##  the cyclotomic <z>.
##
DeclareGlobalFunction( "RoundCyc" );


#############################################################################
##
#F  CoeffsCyc( <z>, <N> )
##
##  If <z> is a cyclotomic that lies in the field of <N>-th roots of unity,
##  `CoeffsCyc' returns a list of length <N> which is the Zumbroich basis
##  representation of <z> *in the <N>-th cyclotomic field*, i.e., at position
##  `i' the coefficient of `E(N)^(i-1)' is stored.
##
##  If <z> is a coefficients list then it must be the Zumbroich basis
##  representation of a cyclotomic that lies in the field of <N>-th roots
##  of unity,
##
DeclareGlobalFunction( "CoeffsCyc" );


#############################################################################
##
#F  IsGaussInt( <x> ) . . . . . . . . test if an object is a Gaussian integer
##
##  `IsGaussInt' returns `true' if the  object <x> is  a Gaussian integer and
##  `false' otherwise.  Gaussian integers are of the form  `<a> + <b>\*E(4)',
##  where <a> and <b> are integers.
##
DeclareGlobalFunction( "IsGaussInt" );


#############################################################################
##
#F  IsGaussRat( <x> ) . . . . . . .  test if an object is a Gaussian rational
##
##  `IsGaussRat' returns `true' if the  object <x> is a Gaussian rational and
##  `false' otherwise.  Gaussian rationals are of the form `<a> + <b>\*E(4)',
##  where <a> and <b> are rationals.
##
DeclareGlobalFunction( "IsGaussRat" );


#############################################################################
##
#F  EB( <n> ), EC( <n> ), \ldots, EH( <n> ) . . .  some ATLAS irrationalities
##
DeclareGlobalFunction( "EB" );
DeclareGlobalFunction( "EC" );
DeclareGlobalFunction( "ED" );
DeclareGlobalFunction( "EE" );
DeclareGlobalFunction( "EF" );
DeclareGlobalFunction( "EG" );
DeclareGlobalFunction( "EH" );


#############################################################################
##
#F  EY(<n>), EY(<n>,<deriv>) . . . . . . .  ATLAS irrationalities $y_n$ resp.
#F                                          $y_n^{<deriv>}$
#F  ... ES(<n>), ES(<n>,<deriv>)              ... $s_n$ resp. $s_n^{<deriv>}$
##
DeclareGlobalFunction( "EY" );
DeclareGlobalFunction( "EX" );
DeclareGlobalFunction( "EW" );
DeclareGlobalFunction( "EV" );
DeclareGlobalFunction( "EU" );
DeclareGlobalFunction( "ET" );
DeclareGlobalFunction( "ES" );


#############################################################################
##
#F  EM( <n> ), EM( <n>, <deriv> ) .. EJ( <n> ), EJ( <n>, <deriv> )
##
DeclareGlobalFunction( "EM" );
DeclareGlobalFunction( "EL" );
DeclareGlobalFunction( "EK" );
DeclareGlobalFunction( "EJ" );


#############################################################################
##
#F  ER( <n> ) . . . . ATLAS irrationality $r_{<n>}$ (pos. square root of <n>)
#F  Sqrt( <n> )
##
DeclareGlobalFunction( "ER" );

DeclareSynonym( "Sqrt", ER );


#############################################################################
##
#F  EI( <n> ) . . . . ATLAS irrationality $i_{<n>}$ (the square root of -<n>)
##
DeclareGlobalFunction( "EI" );


#############################################################################
##
#F  StarCyc( <cyc> )  . . . . the unique nontrivial galois conjugate of <cyc>
##
##   If <z> is an irrational  element of a  quadratic number field (i.e. if
##   <z> is a quadratic irrationality), `StarCyc( <z> )' returns the unique
##   Galois  conjugate  of <z> that is different from  <z>;  this is  often
##   called  $<z>\ast$   (see  "DisplayCharTable").
##  If <cyc> is not contained in a quadratic field or if <cyc> is rational
##  then `fail' is returned.
##
DeclareGlobalFunction( "StarCyc" );


#############################################################################
##
#F  Quadratic( <cyc> ) . . . . .  information about quadratic irrationalities
##
##  If <cyc> is a quadratic irrationality, `Quadratic( <cyc> )' calculates
##  the representation $<cyc> = \frac{ a + b \sqrt{ \hbox{`root'} }%
##  }{\hbox{`d'}}$ and a (not necessarily shortest) representation by a
##  combination of the {\sf ATLAS} irrationalities $b_{\hbox{`root'}},
##  i_{\hbox{`root'}}$ and
##  $r_{\hbox{`root'}}$.  In this case, a record with the components `a', `b',
##  `root', `d', `ATLAS' is returned.  Otherwise `fail' is returned.
##
##  If the denominator `d' is 2, necessarily `root' is congruent 1 mod 4,
##  and $r_n$, $i_n$ are not possible;
##  `<cyc> = x + y * EB( root )' with `y = b', `x = ( a + b ) / 2'.
##
##  If the denominator `d' is 1, we have the possibilities
##  $i_n$ for $'root' \< -1$, `a + b * i' for `root' = -1, $a + b * r_n$
##  for $'root' > 0$. Furthermore if `root' is congruent 1 modulo 4, also
##  `<cyc> = (a+b) + 2 * b * EB( root )' is possible; the shortest string
##  of these is taken as value for the component `ATLAS'.
##
DeclareGlobalFunction( "Quadratic" );


#############################################################################
##
#F  GeneratorsPrimeResidues( <n> ) . . . . . . generators of the Galois group
##
##  is a record with components
##  \beginitems
##  `primes':&
##     list of the prime factors of <n>,
##
##  `exponents':&
##     list of the exponents of these primes, and
##
##  `generators':&
##     list of generators of the prime parts of the group of prime residues;
##     for $p = 2$, either a primitive root or a list of two generators is
##     stored, for other primes a primitive root.
##  \enditems
#T other file?
##
DeclareGlobalFunction( "GeneratorsPrimeResidues" );


#############################################################################
##
#A  GaloisMat( <mat> )
##
##  calculates the completions of orbits under the operation of the galois
##  group of the irrationalities of <mat>, and the permutations of rows
##  corresponding to the generators of the galois group.
##
##  If some rows of <mat> are identical, only the first one is considered
##  for the permutations, and a warning will be printed.
##
##  
##  `GaloisMat( <mat> )' returns a record  with fields `mat', `galoisfams'
##  and `generators'
##  
##  \beginitems
##  `mat':& 
##  a list with initial  segment <mat> (*not* a  copy of <mat>); the
##  list  consists of  full  orbits under the  action of  the Galois
##  group  of the entries of  <mat> defined above. The last  entries
##  are those rows  which had to be added to complete the orbits; so
##  if  they were already complete, <mat> and `mat'  have  identical
##  entries.
##
##  `galoisfams':&
##   a list that has the same length as `mat'; its entries are either
##   1, 0, -1 or lists: `galoisfams[i]  = 1' means that `mat[i]'
##   consists of rationals,  i.e. `[ mat[i] ]'  forms  an orbit.
## 
##   $'galoisfams[i]' =-1$  means that `mat[i]' contains unknowns; in
##   this case $[ `mat[i]'  ]$ is regarded as  an orbit, too, even if
##   `mat[i]' contains irrational entries.\ If $`galoisfams[i]' =  [
##   l_1, l_2 ]$ is  a list then `mat[i]' is the first element of its
##   orbit in  `mat'; $l_1$  is  the list of positions  of rows which
##   form  the orbit, and $l_2$ is the  list of  corresponding Galois
##   automorphisms  (as  exponents,  not  as  functions); so  we have
##   $`mat'[  l_1[j] ][k]  =  `GaloisCyc'(  `mat'[i][k], l_2[j] )$.
## 
##   $`galoisfams[i]' =  0$  means that  `mat[i]'  is an element of a
##   nontrivial orbit but not the first element of it.
## 
## `generators':&
##   a  list  of  permutations  generating  the   permutation   group
##   corresponding  to the  action of the Galois group on the rows of
##   `mat'.
##  \enditems
DeclareAttribute( "GaloisMat", IsMatrix );


#############################################################################
##
#A  RationalizedMat( <mat> )  . . . . . .  list of rationalized rows of <mat>
##
##  returns the set  of rationalized rows of <mat>, i.e. the  set  of sums
##  over  orbits under the action  of the Galois  group of the elements of
##  <mat> (see "GaloisMat").
##
##  This may be viewed as a kind of trace operation for the rows.
##
##  Note that <mat> should be a set, i.e. no two rows should be equal.
DeclareAttribute( "RationalizedMat", IsMatrix );


#############################################################################
##
#E  cyclotom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

