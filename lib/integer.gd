#############################################################################
##
#W  integer.gd                  GAP library                     Werner Nickel
#W                                                           & Alice Niemeyer
#W                                                         & Martin Schoenert
#W                                                              & Alex Wegner
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for integers.
##
Revision.integer_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsIntegers( <obj> )
#C  IsPositiveIntegers( <obj> )
#C  IsNonnegativeIntegers( <obj> )
##
##  are the defining categories for the domains `Integers',
##  `PositiveIntegers', and `NonnegativeIntegers'.
##
DeclareCategory( "IsIntegers", IsEuclideanRing and IsFLMLOR );

DeclareCategory( "IsPositiveIntegers", IsSemiringWithOne );

DeclareCategory( "IsNonnegativeIntegers", IsSemiringWithOneAndZero );


#############################################################################
##
#V  Integers  . . . . . . . . . . . . . . . . . . . . .  ring of the integers
#V  PositiveIntegers  . . . . . . . . . . . . . semiring of positive integers
#V  NonnegativeIntegers . . . . . . . . . .  semiring of nonnegative integers
##
##  These global variables represent the ring of integers and the semirings
##  of positive and nonnegative integers, respectively.
##
DeclareGlobalVariable( "Integers", "ring of integers" );

DeclareGlobalVariable( "PositiveIntegers", "semiring of positive integers" );

DeclareGlobalVariable( "NonnegativeIntegers",
    "semiring of nonnegative integers" );


#############################################################################
##
#C  IsGaussianIntegers( <obj> )
##
##  is the defining category for the domain `GaussianIntegers'.
##
DeclareCategory( "IsGaussianIntegers", IsEuclideanRing and IsFLMLOR );


#############################################################################
##
#V  GaussianIntegers  . . . . . . . . . . . . . . . ring of Gaussian integers
##
##  is the ring of Gaussian integers.
##  This is the subring $Z[i]$ of the complex numbers,
##  where $i$ is a square root of $-1$.
##
DeclareGlobalVariable( "GaussianIntegers", "ring of Gaussian integers" );


#############################################################################
##
#V  Primes  . . . . . . . . . . . . . . . . . . . . . .  list of small primes
##
##  `Primes' is a strictly sorted list of the 168 primes less than 1000.
##
##  This is used in `IsPrimeInt' and `FactorsInt' to cast out small primes
##  quickly.
##
DeclareGlobalVariable( "Primes", "list of the 168 primes less than 1000" );


#############################################################################
##
#V  Primes2 . . . . . . . . . . . . . . . . . . . . . . additional prime list
##
##  `Primes2' contains those primes found by `IsPrimeInt' that are not in
##  `Primes'.  `Primes2' is kept sorted, but may contain holes.
##
##  `IsPrimeInt' and `FactorsInt' use this list to  cast out already found
##  primes quickly.
##  If `IsPrimeInt' is called only for random integers this list would be
##  quite useless.
##  However, users do not behave randomly.
##  Instead, it is not uncommon to factor the same integer twice.
##  Likewise, once we have tested that $2^{31}-1$ is prime, factoring
##  $2^{62}-1$ is very cheap, because the former divides the latter.
##
##  This list is initialized to contain at least all those prime factors of
##  the integers $2^n-1$ with $n \< 201$, $3^n-1$ with $n \< 101$,
##  $5^n-1$ with $n \< 101$, $7^n-1$ with $n \< 91$, $11^n-1$ with $n \< 79$,
##  and $13^n-1$ with $n \< 37$ that are larger than $10^7$.
##
DeclareGlobalVariable( "Primes2", "sorted list of large primes" );


#############################################################################
##
#F  AbsInt( <n> ) . . . . . . . . . . . . . . .  absolute value of an integer
##
##  `AbsInt' returns the absolute value of the integer <n>, i.e., <n> if <n>
##  is positive, -<n> if <n> is negative and 0 if <n> is 0.
##
##  `AbsInt' is a special case of the general operation `EuclideanDegree'
##  see~"EuclideanDegree").
##
DeclareGlobalFunction( "AbsInt" );
#T attribute `Abs' ?
#T should be internal method!


#############################################################################
##
#F  BestQuoInt( <n>, <m> )
##
##  `BestQuoInt' returns the best quotient <q> of the integers <n> and <m>.
##  This is the quotient such that `<n>-<q>*<m>' has minimal absolute value.
##  If there are two quotients whose remainders have the same absolute value,
##  then the quotient with the smaller absolute value is chosen.
##
DeclareGlobalFunction( "BestQuoInt" );


#############################################################################
##
#F  ChineseRem( <moduli>, <residues> )  . . . . . . . . . . chinese remainder
##
##  `ChineseRem' returns the combination   of   the  <residues>  modulo   the
##  <moduli>, i.e., the  unique integer <c>  from `[0..Lcm(<moduli>)-1]' such
##  that  `<c>  = <residues>[i]' modulo `<moduli>[i]'   for  all  <i>, if  it
##  exists.  If no such combination exists `ChineseRem' signals an error.
##
##  Such a combination does exist if and only if
##  `<residues>[<i>]=<residues>[<k>]'  mod `Gcd(<moduli>[<i>],<moduli>[<k>])'
##  for every pair <i>, <k>.  Note  that this implies that such a combination
##  exists if the  moduli  are pairwise relatively prime.  This is called the
##  Chinese remainder theorem.
##
DeclareGlobalFunction( "ChineseRem" );


#############################################################################
##
#F  CoefficientsQadic( <i>, <q> ) . . . . . .  <q>-adic representation of <i>
##
##  returns the <q>-adic representation of the integer <i> as a list <l> of
##  coefficients where $i = \sum_{j=0} q^j \cdot l[j+1]$.
##
DeclareGlobalFunction( "CoefficientsQadic" );


#############################################################################
##
#F  CoefficientsMultiadic( <ints>, <int> )
##
##  returns the multiadic expansion of the integer <int> modulo the integers
##  given in <ints> (in ascending order).
##  It returns a list of coefficients in the *reverse* order to that in <ints>.
##
#T  The syntax is quite weird and should be adapted according to
#T  `CoefficientsQadic'.
DeclareGlobalFunction( "CoefficientsMultiadic" );


#############################################################################
##
#F  DivisorsInt( <n> )  . . . . . . . . . . . . . . .  divisors of an integer
##
##  `DivisorsInt' returns a list of all divisors  of  the  integer  <n>.  The
##  list is sorted, so that it starts with 1 and  ends  with <n>.  We  define
##  that `Divisors( -<n> ) = Divisors( <n> )'.
##
##  Since the  set of divisors of 0 is infinite calling `DivisorsInt( 0 )'
##  causes an error.
##
##  `DivisorsInt' may call `FactorsInt' to obtain the prime factors.
##  `Sigma' and `Tau' (see~"Sigma" and "Tau") compute the sum and the
##  number of positive divisors, respectively.
##
DeclareGlobalFunction( "DivisorsInt");


#############################################################################
##
#F  FactorsInt( <n> ) . . . . . . . . . . . . . . prime factors of an integer
#F  FactorsInt( <n> : RhoTrials := <trials>)
##
##  `FactorsInt' returns a list of prime factors of the integer <n>.
##
##  If the <i>th power of a prime divides <n> this prime appears <i> times.
##  The list is sorted, that is the smallest prime factors come first.
##  The first element has the same sign as <n>, the others are positive.
##  For any integer <n> it holds that `Product( FactorsInt( <n> ) ) = <n>'.
##
##  Note that `FactorsInt' uses a probable-primality test (see~"IsPrimeInt").
##  Thus `FactorsInt' might return a list which contains composite integers.
##
##  The time taken by   `FactorsInt'  is approximately  proportional to   the
##  square root of the second largest prime factor  of <n>, which is the last
##  one that `FactorsInt'  has to find,   since the largest  factor is simply
##  what remains when all others have been removed.  Thus the time is roughly
##  bounded by  the fourth  root of <n>.   `FactorsInt' is guaranteed to find
##  all factors   less than  $10^6$  and will find  most    factors less than
##  $10^{10}$.    If <n>    contains   multiple  factors   larger  than  that
##  `FactorsInt' may not be able to factor <n> and will then signal an error.
##
##  `FactorsInt' is used in a method for the general operation `Factors'.
##
##  In the second form, FactorsInt calls FactorsRho with a limit of <trials>
##  on the number of trials is performs. The  default is 8192.
##
DeclareGlobalFunction( "FactorsInt" );


#############################################################################
##
#F  Gcdex( <m>, <n> ) . . . . . . . . . . greatest common divisor of integers
##
##  returns a record <g> describing the extended greatest common divisor of
##  <m> and <n>.
##  The component `gcd' is this gcd,
##  the components `coeff1' and `coeff2' are integer cofactors such that
##  `<g>.gcd =  <g>.coeff1 * <m> + <g>.coeff2 * <n>',
##  and the components `coeff3' and `coeff4' are integer cofactors such that
##  `0 = <g>.coeff3 * <m> + <g>.coeff4 * <n>'.
##
##  If <m> and <n> both are nonzero, `AbsInt( <g>.coeff1 )' is less than or
##  equal to `AbsInt(<n>) / (2 * <g>.gcd)' and `AbsInt( <g>.coeff2 )' is less
##  than or equal to `AbsInt(<m>) / (2 * <g>.gcd)'.
##  
##  If <m> or <n> or both are zero `coeff3' is `-<n> / <g>.gcd' and
##  `coeff4' is `<m> / <g>.gcd'.
##  
##  The coefficients always form a unimodular matrix, i.e.,
##  the determinant `<g>.coeff1 * <g>.coeff4 - <g>.coeff3 * <g>.coeff2'
##  is $1$ or $-1$.
#T not documented in the GAP 3 manual,
#T shall this be an official function in GAP 4?
##
DeclareGlobalFunction( "Gcdex" );


#############################################################################
##
#F  IsEvenInt( <n> )  . . . . . . . . . . . . . . . . . . test if <n> is even
##
##  tests if the integer <n> is divisible by 2.
##
DeclareGlobalFunction( "IsEvenInt" );


#############################################################################
##
#F  IsOddInt( <n> ) . . . . . . . . . . . . . . . . . . .  test if <n> is odd
##
##  tests if the integer <n> is not divisible by 2.
##
DeclareGlobalFunction( "IsOddInt" );


#############################################################################
##
#F  IsPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . .  test for a prime
#F  IsProbablyPrimeInt( <n> ) . . . . . . . . . . . . . . .  test for a prime
##
##  `IsPrimeInt' returns `false'  if it can  prove that <n>  is composite and
##  `true' otherwise.
##  By  convention `IsPrimeInt(0) = IsPrimeInt(1) = false'
##  and we define `IsPrimeInt( -<n> ) = IsPrimeInt( <n> )'.
##
##  `IsPrimeInt' will return  `true' for every prime $n$.  `IsPrimeInt'  will
##  return `false' for all composite $n \< 10^{13}$ and for all composite $n$
##  that have   a factor  $p \<  1000$.   So for  integers $n    \< 10^{13}$,
##  `IsPrimeInt' is  a    proper primality test.    It  is  conceivable  that
##  `IsPrimeInt' may  return `true' for some  composite $n > 10^{13}$, but no
##  such $n$ is currently known.  So for integers $n > 10^{13}$, `IsPrimeInt'
##  is a  probable-primality test. Therefore `IsPrimeInt' will issue a
##  warning when called with an argument $>10^{13}$. (The function
##  `IsProbablyPrimeInt' will do the same calculations but not issue a
##  warning.)
##
##  If composites  that fool  `IsPrimeInt' do
##  exist,  they would be  extremely rare, and finding one  by  pure chance
##  might be 
##  less likely than finding a bug in {\GAP}.
##  We would appreciate being informed about any example of a composite
##  number <n> for which `IsPrimeInt' returns `true'.
##
##  `IsPrimeInt' is a deterministic algorithm, i.e., the computations involve
##  no random numbers, and repeated calls will always return the same result.
##  `IsPrimeInt' first   does trial divisions  by the  primes less than 1000.
##  Then it tests  that  $n$  is a   strong  pseudoprime w.r.t. the base   2.
##  Finally it  tests whether $n$ is  a Lucas pseudoprime w.r.t. the smallest
##  quadratic nonresidue of  $n$.  A better  description can be found in  the
##  comment in the library file `integer.gi'.
##
##  The time taken by `IsPrimeInt' is approximately proportional to the third
##  power  of  the number  of  digits of <n>.   Testing numbers  with several
##  hundreds digits is quite feasible.
##
##  `IsPrimeInt' is a method for the general operation `IsPrime'.
##
UnbindGlobal( "IsPrimeInt" );
DeclareGlobalFunction( "IsPrimeInt" );
DeclareGlobalFunction( "IsProbablyPrimeInt" );


#############################################################################
##
#F  IsPrimePowerInt( <n> )  . . . . . . . . . . . test for a power of a prime
##
##  `IsPrimePowerInt' returns `true' if the integer <n>  is a prime power and
##  `false' otherwise.
##
##  $n$ is a *prime power* if there exists a prime $p$ and a positive integer
##  $i$ such that $p^i = n$.  If $n$ is negative the  condition is that there
##  must exist a negative prime $p$ and an odd positive integer $i$ such that
##  $p^i = n$.  1 and -1 are not prime powers.
##
##  Note    that `IsPrimePowerInt'      uses       `SmallestRootInt'     (see
##  "SmallestRootInt") and a probable-primality test (see "IsPrimeInt").
##
DeclareGlobalFunction( "IsPrimePowerInt" );


#############################################################################
##
#F  LcmInt( <m>, <n> )  . . . . . . . . . . least common multiple of integers
##
##  returns the least common multiple of the integers <m> and <n>.
##
##  `LcmInt' is a method used by the general function `Lcm'.
##
DeclareGlobalFunction( "LcmInt" );


#############################################################################
##
#F  LogInt( <n>, <base> ) . . . . . . . . . . . . . . logarithm of an integer
##
##  `LogInt'   returns  the  integer part  of  the logarithm of  the positive
##  integer  <n> with  respect to   the positive integer   <base>, i.e.,  the
##  largest positive integer <exp> such  that $base^{exp} \leq  n$.  `LogInt'
##  will signal an error if either <n> or <base> is not positive.
##
DeclareGlobalFunction( "LogInt" );


#############################################################################
##
#F  NextPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . next larger prime
##
##  `NextPrimeInt' returns the smallest prime  which is strictly larger  than
##  the integer <n>.
##
##  Note  that     `NextPrimeInt'  uses  a    probable-primality  test   (see
##  "IsPrimeInt").
##
DeclareGlobalFunction( "NextPrimeInt" );


#############################################################################
##
#F  PowerModInt( <r>, <e>, <m> )  . . . . power of one integer modulo another
##
##  returns $r^e\pmod{m}$ for integers <r>,<e> and <m> ($e\ge 0$).
##  Note that using `<r> ^ <e> mod <m>' will generally  be slower,
##  because it can not reduce intermediate results the way `PowerModInt'
##  does but would compute `<r>^<e>' first and then reduce the result
##  afterwards.
##
##  `PowerModInt' is a method for the general operation `PowerMod'.
##
DeclareGlobalFunction( "PowerModInt" );


#############################################################################
##
#F  PrevPrimeInt( <n> ) . . . . . . . . . . . . . . .  previous smaller prime
##
##  `PrevPrimeInt' returns the largest prime  which is  strictly smaller than
##  the integer <n>.
##
##  Note  that    `PrevPrimeInt'   uses   a  probable-primality    test  (see
##  "IsPrimeInt").
##
DeclareGlobalFunction( "PrevPrimeInt" );


#############################################################################
##
#F  PrimePowersInt( <n> ) . . . . . . . . . . . . . . . . prime powers of <n>
##
##  returns the prime factorization of the integer <n> as a list
##  $[ p_1, e_1, \ldots, p_n, e_n ]$ with $n = \prod_{i=1}^n p_i^{e_i}$.
##
DeclareGlobalFunction( "PrimePowersInt" );


#############################################################################
##
#F  RootInt( <n> )  . . . . . . . . . . . . . . . . . . .  root of an integer
#F  RootInt( <n>, <k> )
##
##  `RootInt' returns the integer part of the <k>th root  of the integer <n>.
##  If the optional integer argument <k> is not given it defaults to 2, i.e.,
##  `RootInt' returns the integer part of the square root in this case.
##
##  If  <n> is positive, `RootInt' returns  the  largest positive integer $r$
##  such that $r^k \leq n$.  If <n>  is negative and  <k>  is  odd  `RootInt'
##  returns `-RootInt( -<n>,  <k> )'.  If  <n> is negative   and <k> is  even
##  `RootInt' will cause an error.  `RootInt' will also cause an error if <k>
##  is 0 or negative.
##
DeclareGlobalFunction( "RootInt" );


#############################################################################
##
#F  SignInt( <n> )  . . . . . . . . . . . . . . . . . . .  sign of an integer
##
##  `SignInt' returns the sign of the integer <n>, i.e., 1 if <n> is
##  positive, -1 if <n> is negative and 0 if <n> is 0.
##
DeclareGlobalFunction( "SignInt" );
#T attribute `Sign' (also for e.g. permutations)?
#T should be internal method!


#############################################################################
##
#F  SmallestRootInt( <n> )  . . . . . . . . . . . smallest root of an integer
##
##  `SmallestRootInt' returns the smallest root of the integer <n>.
##
##  The  smallest  root of an  integer $n$  is  the  integer $r$  of smallest
##  absolute  value for which  a  positive integer $k$ exists such  that $n =
##  r^k$.
##
DeclareGlobalFunction( "SmallestRootInt" );


#############################################################################
##
#F  PrintFactorsInt( <n> )  . . . . . . . . print factorization of an integer
##
##  prints the prime factorization of the integer <n> in human-readable
##  form.
##
DeclareGlobalFunction( "PrintFactorsInt" );

#############################################################################
##
#F  PowerDecompositions( <n> )
##
##  returns a list of all nontrivial decompositions of the integer <n> as a
##  power of integers.
##
DeclareGlobalFunction( "PowerDecompositions" );


#############################################################################
##
#E  integer.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

