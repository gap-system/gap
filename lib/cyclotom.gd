#############################################################################
##
#W  cyclotom.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares operations for cyclotomics.
##
Revision.cyclotom_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  RoundCyc( <z> )
##
##  is the cyclotomic integer (see "Cyclotomic Integers") with Zumbroich base
##  coefficients (see "ZumbroichBase") 'List( <zumb>, x -> Int( x+1/2 ) )',
##  where <zumb> is the vector of Zumbroich base coefficients of
##  the cyclotomic <z>.
##
RoundCyc := NewOperationArgs( "RoundCyc" );


#############################################################################
##
#F  CoeffsCyc( <z>, <N> )
##
##  If <z> is a cyclotomic that lies in the field of <N>-th roots of unity,
##  'CoeffsCyc' returns a list of length <N> which is the Zumbroich basis
##  representation of <z> *in the <N>-th cyclotomic field*, i.e., at position
##  'i' the coefficient of 'E(N)^(i-1)' is stored.
##
##  If <z> is a coefficients list then it must be the Zumbroich basis
##  representation of a cyclotomic that lies in the field of <N>-th roots
##  of unity,
##
CoeffsCyc := NewOperationArgs( "CoeffsCyc" );


#############################################################################
##
#F  IsGaussInt( <x> ) . . . . . . . . test if an object is a Gaussian integer
##
##  'IsGaussInt' returns 'true' if the  object <x> is  a Gaussian integer and
##  'false' otherwise.  Gaussian integers are of the form  '<a> + <b>\*E(4)',
##  where <a> and <b> are integers.
##
IsGaussInt := NewOperationArgs( "IsGaussInt" );


#############################################################################
##
#F  IsGaussRat( <x> ) . . . . . . .  test if an object is a Gaussian rational
##
##  'IsGaussRat' returns 'true' if the  object <x> is a Gaussian rational and
##  'false' otherwise.  Gaussian rationals are of the form '<a> + <b>\*E(4)',
##  where <a> and <b> are rationals.
##
IsGaussRat := NewOperationArgs( "IsGaussRat" );


#############################################################################
##
#F  EB( <n> ), EC( <n> ), \ldots, EH( <n> ) . . .  some ATLAS irrationalities
##
EB := NewOperationArgs( "EB" );
EC := NewOperationArgs( "EC" );
ED := NewOperationArgs( "ED" );
EE := NewOperationArgs( "EE" );
EF := NewOperationArgs( "EF" );
EG := NewOperationArgs( "EG" );
EH := NewOperationArgs( "EH" );


#############################################################################
##
#F  EY(<n>), EY(<n>,<deriv>) . . . . . . .  ATLAS irrationalities $y_n$ resp.
#F                                          $y_n^{<deriv>}$
#F  ... ES(<n>), ES(<n>,<deriv>)              ... $s_n$ resp. $s_n^{<deriv>}$
##
EY := NewOperationArgs( "EY" );
EX := NewOperationArgs( "EX" );
EW := NewOperationArgs( "EW" );
EV := NewOperationArgs( "EV" );
EU := NewOperationArgs( "EU" );
ET := NewOperationArgs( "ET" );
ES := NewOperationArgs( "ES" );


#############################################################################
##
#F  EM( <n> ), EM( <n>, <deriv> ) .. EJ( <n> ), EJ( <n>, <deriv> )
##
EM := NewOperationArgs( "EM" );
EL := NewOperationArgs( "EL" );
EK := NewOperationArgs( "EK" );
EJ := NewOperationArgs( "EJ" );


#############################################################################
##
#F  ER( <n> ) . . . . ATLAS irrationality $r_{<n>}$ (pos. square root of <n>)
##
ER := NewOperationArgs( "ER" );


#############################################################################
##
#F  EI( <n> ) . . . . ATLAS irrationality $i_{<n>}$ (the square root of -<n>)
##
EI := NewOperationArgs( "EI" );


#############################################################################
##
#F  StarCyc( <cyc> )  . . . . the unique nontrivial galois conjugate of <cyc>
##
StarCyc := NewOperationArgs( "StarCyc" );


#############################################################################
##
#F  Quadratic( <cyc> ) . . . . . informations about quadratic irrationalities
##
##  If <cyc> is a quadratic irrationality, Quadratic( <cyc> ) calculates the
##  representation $<cyc> = \frac{ a + b \sqrt{ 'root' } }{'d'}$ and a
##  (not necessarily shortest) representation by a combination of the
##  {\ATLAS} irrationalities $b_{'root'}, i_{'root'}$ and $r_{'root'}$.
##  In this case, a record with the components 'a', 'b', 'root', 'd', 'ATLAS'
##  is returned.
##  Otherwise 'fail' is returned.
##
##  1. If the denominator 'd' is 2, necessarily 'root' is congruent 1 mod 4,
##     and $r_n$, $i_n$ are not possible;
##     '<cyc> = x + y * EB( root )' with y = b, x = ( a + b ) / 2.
##  2. If the denominator 'd' is 1, we have the possibilities
##     $i_n$ for $'root' \< -1$, 'a + b * i' for 'root' = -1, $a + b * r_n$
##     for $'root' > 0$. Furthermore if 'root' is congruent 1 modulo 4, also
##     '<cyc> = (a+b) + 2 * b * EB( root )' is possible; the shortest string
##     of these is taken as value for the component 'ATLAS'.
##
Quadratic := NewOperationArgs( "Quadratic" );


#############################################################################
##
#F  GeneratorsPrimeResidues( <n> ) . . . . . . generators of the Galois group
##
##  is a record with components
##  'primes'\:
##     list of the prime factors of 'n',
##  'exponents'\:
##     list of the exponents of these primes, and
##  'generators'\:
##     list of generators of the prime parts of the group of prime residues;
##     for p = 2, either a primitive root or a list of two generators is
##     stored, for other primes a primitive root.
#T other file?
##
GeneratorsPrimeResidues := NewOperationArgs( "GeneratorsPrimeResidues" );


#############################################################################
##
#F  GaloisMat( <mat> )
##
##  calculates the completions of orbits under the operation of the galois
##  group of the irrationalities of <mat>, and the permutations of rows
##  corresponding to the generators of the galois group.
##
##  If some rows of <mat> are identical, only the first one is considered
##  for the permutations, and a warning will be printed.
##
GaloisMat := NewOperationArgs( "GaloisMat" );


#############################################################################
##
#F  RationalizedMat( <mat> ) . .  list of rationalized rows of <mat>
##
RationalizedMat := NewOperationArgs( "RationalizedMat" );


#############################################################################
##
#E  cyclotom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



