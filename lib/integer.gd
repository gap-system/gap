#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl, Werner Nickel, Alice Niemeyer, Martin Schönert, Alex Wegner.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for integers.
##


#############################################################################
##
#C  IsIntegers( <obj> )
#C  IsPositiveIntegers( <obj> )
#C  IsNonnegativeIntegers( <obj> )
##
##  <#GAPDoc Label="IsIntegers">
##  <ManSection>
##  <Filt Name="IsIntegers" Arg='obj' Type='Category'/>
##  <Filt Name="IsPositiveIntegers" Arg='obj' Type='Category'/>
##  <Filt Name="IsNonnegativeIntegers" Arg='obj' Type='Category'/>
##
##  <Description>
##  are the defining categories for the domains
##  <Ref Var="Integers" Label="global variable"/>,
##  <Ref Var="PositiveIntegers"/>, and <Ref Var="NonnegativeIntegers"/>.
##  <Example><![CDATA[
##  gap> IsIntegers( Integers );  IsIntegers( Rationals );  IsIntegers( 7 );
##  true
##  false
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IntegersGlobalVars">
##  <ManSection>
##  <Var Name="Integers" Label="global variable"/>
##  <Var Name="PositiveIntegers"/>
##  <Var Name="NonnegativeIntegers"/>
##
##  <Description>
##  These global variables represent the ring of integers and the semirings
##  of positive and nonnegative integers, respectively.
##  <Example><![CDATA[
##  gap> Size( Integers ); 2 in Integers;
##  infinity
##  true
##  ]]></Example>
##  <P/>
##  <Ref Var="Integers" Label="global variable"/> is a subset of
##  <Ref Var="Rationals"/>, which is a subset of <Ref Var="Cyclotomics"/>.
##  See Chapter&nbsp;<Ref Chap="Cyclotomic Numbers"/>
##  for arithmetic operations and comparison of integers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalName( "Integers" );

DeclareGlobalName( "PositiveIntegers" );

DeclareGlobalName( "NonnegativeIntegers" );


#############################################################################
##
#V  Primes  . . . . . . . . . . . . . . . . . . . . . .  list of small primes
##
##  <#GAPDoc Label="Primes">
##  <ManSection>
##  <Var Name="Primes"/>
##
##  <Description>
##  <Ref Var="Primes"/> is a strictly sorted list of the 168 primes less than
##  1000.
##  <P/>
##  This is used in <Ref Func="IsPrimeInt"/> and <Ref Func="FactorsInt"/>
##  to cast out small primes quickly.
##  <Example><![CDATA[
##  gap> Primes[1];
##  2
##  gap> Primes[100];
##  541
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalName( "Primes" );


#############################################################################
##
#V  Primes2 . . . . . . . . . . . . . . . . . . . . . . additional prime list
#V  ProbablePrimes2 . . . . . . . . . . .  additional list of probable primes
#V  InfoPrimeInt  . . . . . info class for usage of probable primes as primes
##
##  <ManSection>
##  <Var Name="Primes2"/>
##  <Var Name="ProbablePrimes2"/>
##  <InfoClass Name="InfoPrimeInt"/>
##
##  <Description>
##  <Ref Var="Primes2"/> contains those primes found by
##  <Ref Func="IsPrimeInt"/> that are not in <Ref Var="Primes"/>.
##  <Ref Var="Primes2"/> is kept sorted, but may contain holes.
##  <P/>
##  Similarly, <Ref Var="ProbablePrimes2"/> is used to store found
##  probable primes,
##  which are not strictly proven to be prime. When numbers from this list
##  are used (e.g., to factor numbers), a sensible warning should be printed
##  with <Ref InfoClass="InfoPrimeInt"/> in its standard level 1.
##  <P/>
##  <Ref Func="IsPrimeInt"/> and <Ref Func="FactorsInt"/> use this list
##  to cast out already found primes quickly.
##  If <Ref Func="IsPrimeInt"/> is called only for random integers
##  this list would be quite useless.
##  However, users do not behave randomly.
##  Instead, it is not uncommon to factor the same integer twice.
##  Likewise, once we have tested that <M>2^{31}-1</M> is prime, factoring
##  <M>2^{62}-1</M> is very cheap, because the former divides the latter.
##  <P/>
##  This list is initialized to contain at least all those prime factors of
##  the integers <M>2^n-1</M> with <M>n &lt; 201</M>,
##  <M>3^n-1</M> with <M>n &lt; 101</M>,
##  <M>5^n-1</M> with <M>n &lt; 101</M>,
##  <M>7^n-1</M> with <M>n &lt; 91</M>,
##  <M>11^n-1</M> with <M>n &lt; 79</M>,
##  and <M>13^n-1</M> with <M>n &lt; 37</M> that are larger than <M>10^7</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable( "Primes2", "sorted list of large primes" );
DeclareGlobalVariable( "ProbablePrimes2", "sorted list of probable primes" );
DeclareInfoClass( "InfoPrimeInt" );
SetInfoLevel( InfoPrimeInt, 1 );


#############################################################################
##
#F  AbsInt( <n> ) . . . . . . . . . . . . . . .  absolute value of an integer
##
##  <#GAPDoc Label="AbsInt">
##  <ManSection>
##  <Func Name="AbsInt" Arg='n'/>
##
##  <Description>
##  <Index>absolute value of an integer</Index>
##  <Ref Func="AbsInt"/> returns the absolute value of the integer <A>n</A>,
##  i.e., <A>n</A> if <A>n</A> is positive,
##  -<A>n</A> if <A>n</A> is negative and 0 if <A>n</A> is 0.
##  <P/>
##  <Ref Func="AbsInt"/> is a special case of the general operation
##  <Ref Oper="EuclideanDegree"/>.
##  <P/>
##  See also <Ref Attr="AbsoluteValue"/>.
##
##  <Example><![CDATA[
##  gap> AbsInt( 33 );
##  33
##  gap> AbsInt( -214378 );
##  214378
##  gap> AbsInt( 0 );
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AbsInt" );


#############################################################################
##
#F  BestQuoInt( <n>, <m> )
##
##  <#GAPDoc Label="BestQuoInt">
##  <ManSection>
##  <Func Name="BestQuoInt" Arg='n, m'/>
##
##  <Description>
##  <Ref Func="BestQuoInt"/> returns the best quotient <M>q</M>
##  of the integers <A>n</A> and <A>m</A>.
##  This is the quotient such that <M><A>n</A>-q*<A>m</A></M>
##  has minimal absolute value.
##  If there are two quotients whose remainders have the same absolute value,
##  then the quotient with the smaller absolute value is chosen.
##  <Example><![CDATA[
##  gap> BestQuoInt( 5, 3 );  BestQuoInt( -5, 3 );
##  2
##  -2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BestQuoInt" );


#############################################################################
##
#F  ChineseRem( <moduli>, <residues> )  . . . . . . . . . . chinese remainder
##
##  <#GAPDoc Label="ChineseRem">
##  <ManSection>
##  <Func Name="ChineseRem" Arg='moduli, residues'/>
##
##  <Description>
##  <Index>Chinese remainder</Index>
##  <Ref Func="ChineseRem"/> returns the combination of the <A>residues</A>
##  modulo the <A>moduli</A>, i.e.,
##  the unique integer <C>c</C>  from <C>[0..Lcm(<A>moduli</A>)-1]</C>
##  such that
##  <C>c = <A>residues</A>[i]</C> modulo <C><A>moduli</A>[i]</C>
##  for all <C>i</C>, if it exists.
##  If no such combination exists <Ref Func="ChineseRem"/> signals an error.
##  <P/>
##  Such a combination does exist if and only if
##  <C><A>residues</A>[i] = <A>residues</A>[k] mod Gcd( <A>moduli</A>[i], <A>moduli</A>[k] )</C>
##  for every pair <C>i</C>, <C>k</C>.
##  Note that this implies that such a combination exists
##  if the moduli are pairwise relatively prime.
##  This is called the Chinese remainder theorem.
##  <Example><![CDATA[
##  gap> ChineseRem( [ 2, 3, 5, 7 ], [ 1, 2, 3, 4 ] );
##  53
##  gap> ChineseRem( [ 6, 10, 14 ], [ 1, 3, 5 ] );
##  103
##  ]]></Example>
##  <Log><![CDATA[
##  gap> ChineseRem( [ 6, 10, 14 ], [ 1, 2, 3 ] );
##  Error, the residues must be equal modulo 2 called from
##  <function>( <arguments> ) called from read-eval-loop
##  Entering break read-eval-print loop ...
##  you can 'quit;' to quit to outer loop, or
##  you can 'return;' to continue
##  brk> gap>
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ChineseRem" );


#############################################################################
##
#F  CoefficientsQadic( <i>, <q> ) . . . . . .  <q>-adic representation of <i>
##
##  <#GAPDoc Label="CoefficientsQadic">
##  <ManSection>
##  <Oper Name="CoefficientsQadic" Arg='i, q'/>
##
##  <Description>
##  returns the <A>q</A>-adic representation of the integer <A>i</A>
##  as a list <M>l</M> of coefficients satisfying the equality
##  <M><A>i</A> = \sum_{{j = 0}} <A>q</A>^j \cdot l[j+1]</M>
##  for an integer <M><A>q</A> > 1</M>.
##  <Example><![CDATA[
##  gap> l:=CoefficientsQadic(462,3);
##  [ 0, 1, 0, 2, 2, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CoefficientsQadic", [ IsInt, IsInt ] );


#############################################################################
##
#F  CoefficientsMultiadic( <ints>, <int> )
##
##  <#GAPDoc Label="CoefficientsMultiadic">
##  <ManSection>
##  <Func Name="CoefficientsMultiadic" Arg='ints, int'/>
##
##  <Description>
##  returns the multiadic expansion of the integer <A>int</A>
##  modulo the integers given in <A>ints</A> (in ascending order).
##  It returns a list of coefficients in the <E>reverse</E> order
##  to that in <A>ints</A>.
##  <!-- The syntax is quite weird and should be adapted according to
##  CoefficientsQadic. -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CoefficientsMultiadic" );


#############################################################################
##
#F  DivisorsInt( <n> )  . . . . . . . . . . . . . . .  divisors of an integer
##
##  <#GAPDoc Label="DivisorsInt">
##  <ManSection>
##  <Func Name="DivisorsInt" Arg='n'/>
##
##  <Description>
##  <Index Subkey="of an integer">divisors</Index>
##  <Ref Func="DivisorsInt"/> returns a list of all divisors of the integer
##  <A>n</A>.
##  The list is sorted, so that it starts with 1 and ends with <A>n</A>.
##  We  define that <C>DivisorsInt( -<A>n</A> ) = DivisorsInt( <A>n</A> )</C>.
##  <P/>
##  Since the  set of divisors of 0 is infinite
##  calling <C>DivisorsInt( 0 )</C> causes an error.
##  <P/>
##  <Ref Func="DivisorsInt"/> may call <Ref Func="FactorsInt"/>
##  to obtain the prime factors.
##  <Ref Oper="Sigma"/> and <Ref Oper="Tau"/> compute the sum and the
##  number of positive divisors, respectively.
##  <Example><![CDATA[
##  gap> DivisorsInt( 1 ); DivisorsInt( 20 ); DivisorsInt( 541 );
##  [ 1 ]
##  [ 1, 2, 4, 5, 10, 20 ]
##  [ 1, 541 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DivisorsInt");


#############################################################################
##
#F  FactorsInt( <n> ) . . . . . . . . . . . . . . prime factors of an integer
#F  FactorsInt( <n> : RhoTrials := <trials>)
##
##  <#GAPDoc Label="FactorsInt">
##  <ManSection>
##  <Func Name="FactorsInt" Arg='n'/>
##  <Func Name="FactorsInt" Arg='n:RhoTrials:=trials' Label="using Pollard's Rho"/>
##
##  <Description>
##  <Ref Func="FactorsInt"/> returns a list of factors of a given integer
##  <A>n</A> such that <C>Product( FactorsInt( <A>n</A> ) ) = <A>n</A></C>.
##  If <M>|n| \leq 1</M> the list <C>[<A>n</A>]</C> is returned. Otherwise
##  the result contains probable primes, sorted by absolute value. The
##  entries will all be positive except for the first one in case of
##  a negative <A>n</A>.
##  <P/>
##  See <Ref Attr="PrimeDivisors"/> for a function that returns a set of
##  (probable) primes dividing <A>n</A>.
##  <P/>
##  Note that <Ref Func="FactorsInt"/> uses a probable-primality test
##  (see&nbsp;<Ref Func="IsPrimeInt"/>).
##  Thus <Ref Func="FactorsInt"/> might return a list which contains
##  composite integers.
##  In such a case you will get a warning about the use of a probable prime.
##  You can switch off these warnings by
##  <C>SetInfoLevel( InfoPrimeInt, 0 );</C>
##  (also see <Ref Oper="SetInfoLevel"/>).
##  <P/>
##  The time taken by <Ref Func="FactorsInt"/> is approximately proportional
##  to the square root of the second largest prime factor of <A>n</A>,
##  which is the last one that <Ref Func="FactorsInt"/> has to find,
##  since the largest factor is simply
##  what remains when all others have been removed.  Thus the time is roughly
##  bounded by the fourth root of <A>n</A>.
##  <Ref Func="FactorsInt"/> is guaranteed to find all factors less than
##  <M>10^6</M> and will find most factors less than <M>10^{10}</M>.
##  If <A>n</A> contains multiple factors larger than that
##  <Ref Func="FactorsInt"/> may not be able to factor <A>n</A>
##  and will then signal an error.
##  <P/>
##  <Ref Func="FactorsInt"/> is used in a method for the general operation
##  <Ref Oper="Factors"/>.
##  <P/>
##  In the second form, <Ref Func="FactorsInt"/> calls
##  <C>FactorsRho</C> with a limit of <A>trials</A>
##  on the number of trials it performs. The default is 8192.
##  Note that Pollard's Rho is the fastest method for finding prime
##  factors with roughly 5-10 decimal digits, but becomes more and more
##  inferior to other factorization techniques like e.g. the Elliptic
##  Curves Method (ECM) the bigger the prime factors are. Therefore
##  instead of performing a huge number of Rho <A>trials</A>, it is usually
##  more advisable to install the <Package>FactInt</Package> package and
##  then simply to use the operation <Ref Oper="Factors"/>. The factorization
##  of the 8-th Fermat number by Pollard's Rho below takes already a while.
##
##  <Example><![CDATA[
##  gap> FactorsInt( -Factorial(6) );
##  [ -2, 2, 2, 2, 3, 3, 5 ]
##  gap> Set( FactorsInt( Factorial(13)/11 ) );
##  [ 2, 3, 5, 7, 13 ]
##  gap> FactorsInt( 2^63 - 1 );
##  [ 7, 7, 73, 127, 337, 92737, 649657 ]
##  gap> FactorsInt( 10^42 + 1 );
##  [ 29, 101, 281, 9901, 226549, 121499449, 4458192223320340849 ]
##  gap> FactorsInt(2^256+1:RhoTrials:=100000000);
##  [ 1238926361552897,
##    93461639715357977769163558199606896584051237541638188580280321 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FactorsInt" );

#############################################################################
##
#F  PrimeDivisors( <n> ) . . . . . . . . . . . . . . . list of prime factors
##
##  <#GAPDoc Label="PrimeDivisors">
##  <ManSection>
##  <Attr Name="PrimeDivisors" Arg='n'/>
##  <Description>
##  <Ref Attr="PrimeDivisors"/> returns for a non-zero integer <A>n</A> a set
##  of its positive (probable) primes divisors. In rare cases the result could
##  contain a composite number which passed certain primality tests, see
##  <Ref Func="IsProbablyPrimeInt"/> and <Ref Func="FactorsInt"/> for more details.
##  <Example>
##  gap> PrimeDivisors(-12);
##  [ 2, 3 ]
##  gap> PrimeDivisors(1);
##  [  ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("PrimeDivisors", IsInt);

#############################################################################
##
#O  PartialFactorization( <n> ) . . . . . partial factorization of an integer
#O  PartialFactorization( <n>, <effort> )
##
##  <#GAPDoc Label="PartialFactorization">
##  <ManSection>
##  <Oper Name="PartialFactorization" Arg='n[, effort]'/>
##
##  <Description>
##  <Ref Oper="PartialFactorization"/> returns a partial factorization of the
##  integer <A>n</A>.
##  No assertions are made about the primality of the factors,
##  except of those mentioned below.
##  <P/>
##  The argument <A>effort</A>, if given, specifies how intensively the
##  function should try to determine factors of <A>n</A>.
##  The default is <A>effort</A>&nbsp;=&nbsp;5.
##  <P/>
##  <List>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;0, trial division by the primes below 100
##   is done.
##   Returned factors below <M>10^4</M> are guaranteed to be prime.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;1, trial division by the primes below 1000
##   is done.
##   Returned factors below <M>10^6</M> are guaranteed to be prime.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;2, additionally trial division by the
##   numbers in the lists <C>Primes2</C> and
##   <C>ProbablePrimes2</C> is done, and perfect powers are detected.
##   Returned factors below <M>10^6</M> are guaranteed to be prime.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;3, additionally <C>FactorsRho</C>
##   (Pollard's Rho) with <C>RhoTrials</C> = 256 is used.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;4, as above, but <C>RhoTrials</C> = 2048.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;5, as above, but <C>RhoTrials</C> = 8192.
##   Returned factors below <M>10^{12}</M> are guaranteed to be prime,
##   and all prime factors below <M>10^6</M> are guaranteed to be found.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;6 and the package <Package>FactInt</Package>
##   is loaded, in addition to the above quite a number of special cases are
##   handled.
##  </Item>
##  <Item>
##   If <A>effort</A>&nbsp;=&nbsp;7 and the package <Package>FactInt</Package>
##   is loaded, the only thing which is not attempted to obtain a full
##   factorization into Baillie-Pomerance-Selfridge-Wagstaff pseudoprimes
##   is the application of the MPQS to a remaining composite with more
##   than 50 decimal digits.
##  </Item>
##  </List>
##  <P/>
##  Increasing the value of the argument <A>effort</A> by one usually results
##  in an increase of the runtime requirements by a factor of (very roughly!)
##  3 to&nbsp;10.
##  (Also see <Ref Func="CheapFactorsInt" BookName="EDIM"/>).
##  <Example><![CDATA[
##  gap> List([0..5],i->PartialFactorization(97^35-1,i));
##  [ [ 2, 2, 2, 2, 2, 3, 11, 31, 43,
##        2446338959059521520901826365168917110105972824229555319002965029 ],
##    [ 2, 2, 2, 2, 2, 3, 11, 31, 43, 967,
##        2529823122088440042297648774735177983563570655873376751812787 ],
##    [ 2, 2, 2, 2, 2, 3, 11, 31, 43, 967,
##        2529823122088440042297648774735177983563570655873376751812787 ],
##    [ 2, 2, 2, 2, 2, 3, 11, 31, 43, 967, 39761, 262321,
##        242549173950325921859769421435653153445616962914227 ],
##    [ 2, 2, 2, 2, 2, 3, 11, 31, 43, 967, 39761, 262321, 687121,
##        352993394104278463123335513593170858474150787 ],
##    [ 2, 2, 2, 2, 2, 3, 11, 31, 43, 967, 39761, 262321, 687121,
##        20241187, 504769301, 34549173843451574629911361501 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PartialFactorization",
                  [ IsMultiplicativeElement, IsInt ] );


#############################################################################
##
#F  Gcdex( <m>, <n> ) . . . . . . . . . . greatest common divisor of integers
##
##  <#GAPDoc Label="Gcdex">
##  <ManSection>
##  <Func Name="Gcdex" Arg='m, n'/>
##
##  <Description>
##  returns a record <C>g</C> describing the extended greatest common divisor
##  of <A>m</A> and <A>n</A>.
##  The component <C>gcd</C> is this gcd,
##  the components <C>coeff1</C> and <C>coeff2</C> are integer cofactors
##  such that <C>g.gcd = g.coeff1 * <A>m</A> + g.coeff2 * <A>n</A></C>,
##  and the components <C>coeff3</C> and <C>coeff4</C> are integer cofactors
##  such that <C>0 = g.coeff3 * <A>m</A> + g.coeff4 * <A>n</A></C>.
##  <P/>
##  If <A>m</A> and <A>n</A> both are nonzero,
##  <C>AbsInt( g.coeff1 )</C> is less than or
##  equal to <C>AbsInt(<A>n</A>) / (2 * g.gcd)</C>,
##  and <C>AbsInt( g.coeff2 )</C> is less
##  than or equal to <C>AbsInt(<A>m</A>) / (2 * g.gcd)</C>.
##  <P/>
##  If <A>m</A> or <A>n</A> or both are zero
##  <C>coeff3</C> is <C>-<A>n</A> / g.gcd</C> and
##  <C>coeff4</C> is <C><A>m</A> / g.gcd</C>.
##  <P/>
##  The coefficients always form a unimodular matrix, i.e.,
##  the determinant
##  <C>g.coeff1 * g.coeff4 - g.coeff3 * g.coeff2</C>
##  is <M>1</M> or <M>-1</M>.
##  <Example><![CDATA[
##  gap> Gcdex( 123, 66 );
##  rec( coeff1 := 7, coeff2 := -13, coeff3 := -22, coeff4 := 41,
##    gcd := 3 )
##  ]]></Example>
##  This means <M>3 = 7 * 123 - 13 * 66</M>, <M>0 = -22 * 123 + 41 * 66</M>.
##  <Example><![CDATA[
##  gap> Gcdex( 0, -3 );
##  rec( coeff1 := 0, coeff2 := -1, coeff3 := 1, coeff4 := 0, gcd := 3 )
##  gap> Gcdex( 0, 0 );
##  rec( coeff1 := 1, coeff2 := 0, coeff3 := 0, coeff4 := 1, gcd := 0 )
##  ]]></Example>
##  <P/>
##  <Ref Func="GcdRepresentation" Label="for (a ring and) several elements"/>
##  provides similar functionality over arbitrary Euclidean rings.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Gcdex" );


#############################################################################
##
#F  IsEvenInt( <n> )  . . . . . . . . . . . . . . . . . . test if <n> is even
##
##  <#GAPDoc Label="IsEvenInt">
##  <ManSection>
##  <Func Name="IsEvenInt" Arg='n'/>
##
##  <Description>
##  tests if the integer <A>n</A> is divisible by 2.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsEvenInt" );


#############################################################################
##
#F  IsOddInt( <n> ) . . . . . . . . . . . . . . . . . . .  test if <n> is odd
##
##  <#GAPDoc Label="IsOddInt">
##  <ManSection>
##  <Func Name="IsOddInt" Arg='n'/>
##
##  <Description>
##  tests if the integer <A>n</A> is not divisible by 2.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsOddInt" );


#############################################################################
##
#F  IsPrimePowerInt( <n> )  . . . . . . . . . . . test for a power of a prime
##
##  <#GAPDoc Label="IsPrimePowerInt">
##  <ManSection>
##  <Func Name="IsPrimePowerInt" Arg='n'/>
##
##  <Description>
##  <Ref Func="IsPrimePowerInt"/> returns <K>true</K> if the integer <A>n</A>
##  is a prime power and <K>false</K> otherwise.
##  <P/>
##  An integer <M>n</M> is a <E>prime power</E> if there exists a prime <M>p</M> and a
##  positive integer <M>i</M> such that <M>p^i = n</M>.
##  If <M>n</M> is negative the condition is that there
##  must exist a negative prime <M>p</M> and an odd positive integer <M>i</M>
##  such that <M>p^i = n</M>.
##  The integers 1 and -1 are not prime powers.
##  <P/>
##  Note that <Ref Func="IsPrimePowerInt"/> uses
##  <Ref Func="SmallestRootInt"/>
##  and a probable-primality test (see <Ref Func="IsPrimeInt"/>).
##  <Example><![CDATA[
##  gap> IsPrimePowerInt( 31^5 );
##  true
##  gap> IsPrimePowerInt( 2^31-1 );  # 2^31-1 is actually a prime
##  true
##  gap> IsPrimePowerInt( 2^63-1 );
##  false
##  gap> Filtered( [-10..10], IsPrimePowerInt );
##  [ -8, -7, -5, -3, -2, 2, 3, 4, 5, 7, 8, 9 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsPrimePowerInt" );


#############################################################################
##
#F  LcmInt( <m>, <n> )  . . . . . . . . . . least common multiple of integers
##
##  <#GAPDoc Label="LcmInt">
##  <ManSection>
##  <Func Name="LcmInt" Arg='m, n'/>
##
##  <Description>
##  returns the least common multiple of the integers <A>m</A> and <A>n</A>.
##  <P/>
##  <Ref Func="LcmInt"/> is a method used by the general operation
##  <Ref Func="Lcm" Label="for (a ring and) several elements"/>.
##  <Example><![CDATA[
##  gap> LcmInt( 123, 66 );
##  2706
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LcmInt" );


#############################################################################
##
#F  LogInt( <n>, <base> ) . . . . . . . . . . . . . . logarithm of an integer
##
##  <#GAPDoc Label="LogInt">
##  <ManSection>
##  <Func Name="LogInt" Arg='n, base'/>
##
##  <Description>
##  <Ref Func="LogInt"/> returns the integer part of the logarithm of the
##  positive integer <A>n</A> with respect to the positive integer
##  <A>base</A>, i.e.,
##  the largest positive integer <M>e</M> such that
##  <M><A>base</A>^e \leq <A>n</A></M>.
##  The function
##  <Ref Func="LogInt"/>
##  will signal an error if either <A>n</A> or <A>base</A> is not positive.
##  <P/>
##  For <A>base</A> <M>= 2</M> this is very efficient because the internal
##  binary representation of the integer is used.
##  <P/>
##  <Example><![CDATA[
##  gap> LogInt( 1030, 2 );
##  10
##  gap> 2^10;
##  1024
##  gap> LogInt( 1, 10 );
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LogInt" );


#############################################################################
##
#F  NextPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . next larger prime
##
##  <#GAPDoc Label="NextPrimeInt">
##  <ManSection>
##  <Func Name="NextPrimeInt" Arg='n'/>
##
##  <Description>
##  <Ref Func="NextPrimeInt"/> returns the smallest prime which is strictly
##  larger than the integer <A>n</A>.
##  <P/>
##  Note that <Ref Func="NextPrimeInt"/> uses a probable-primality test
##  (see <Ref Func="IsPrimeInt"/>).
##  <Example><![CDATA[
##  gap> NextPrimeInt( 541 ); NextPrimeInt( -1 );
##  547
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NextPrimeInt" );


#############################################################################
##
#F  PowerModInt( <r>, <e>, <m> )  . . . . power of one integer modulo another
##
##  <#GAPDoc Label="PowerModInt">
##  <ManSection>
##  <Func Name="PowerModInt" Arg='r, e, m'/>
##
##  <Description>
##  returns <M><A>r</A>^{<A>e</A>} \pmod{<A>m</A>}</M> for integers <A>r</A>,
##  <A>e</A> and <A>m</A>.
##  <P/>
##  Note that <Ref Func="PowerModInt"/> can reduce intermediate results and
##  thus will generally be faster than using
##  <A>r</A><C>^</C><A>e</A><C> mod </C><A>m</A>,
##  which would compute <M><A>r</A>^{<A>e</A>}</M> first and reduces
##  the result afterwards.
##  <P/>
##  <Ref Func="PowerModInt"/> is a method for the general operation
##  <Ref Oper="PowerMod"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PowerModInt" );


#############################################################################
##
#F  PrevPrimeInt( <n> ) . . . . . . . . . . . . . . .  previous smaller prime
##
##  <#GAPDoc Label="PrevPrimeInt">
##  <ManSection>
##  <Func Name="PrevPrimeInt" Arg='n'/>
##
##  <Description>
##  <Ref Func="PrevPrimeInt"/> returns the largest prime which is strictly
##  smaller than the integer <A>n</A>.
##  <P/>
##  Note that <Ref Func="PrevPrimeInt"/> uses a probable-primality test
##  (see <Ref Func="IsPrimeInt"/>).
##  <Example><![CDATA[
##  gap> PrevPrimeInt( 541 ); PrevPrimeInt( 1 );
##  523
##  -2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrevPrimeInt" );


#############################################################################
##
#F  PrimePowersInt( <n> ) . . . . . . . . . . . . . . . . prime powers of <n>
##
##  <#GAPDoc Label="PrimePowersInt">
##  <ManSection>
##  <Func Name="PrimePowersInt" Arg='n'/>
##
##  <Description>
##  returns the prime factorization of the integer <A>n</A> as a list
##  <M>[ p_1, e_1, \ldots, p_k, e_k ]</M> with
##  <A>n</A> = <M>p_1^{{e_1}} \cdot p_2^{{e_2}} \cdot ... \cdot p_k^{{e_k}}</M>.
##  <P/>
##  For negative integers, the absolute value is taken. Zero is not allowed as input.
##  <Example><![CDATA[
##  gap> PrimePowersInt( Factorial( 7 ) );
##  [ 2, 4, 3, 2, 5, 1, 7, 1 ]
##  gap> PrimePowersInt( 1 );
##  [  ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrimePowersInt" );


#############################################################################
##
#F  RootInt( <n> )  . . . . . . . . . . . . . . . . . . .  root of an integer
#F  RootInt( <n>, <k> )
##
##  <#GAPDoc Label="RootInt">
##  <ManSection>
##  <Func Name="RootInt" Arg='n[, k]'/>
##
##  <Description>
##  <Index Subkey="of an integer">root</Index>
##  <Index Subkey="of an integer">square root</Index>
##  <Ref Func="RootInt"/> returns the integer part of the <A>k</A>th root of
##  the integer <A>n</A>.
##  If the optional integer argument <A>k</A> is not given it defaults to 2,
##  i.e., <Ref Func="RootInt"/> returns the integer part of the square root
##  in this case.
##  <P/>
##  If <A>n</A> is positive, <Ref Func="RootInt"/> returns the largest
##  positive integer <M>r</M> such that <M>r^{<A>k</A>} \leq <A>n</A></M>.
##  If <A>n</A> is negative and <A>k</A> is odd <Ref Func="RootInt"/>
##  returns <C>-RootInt( -<A>n</A>,  <A>k</A> )</C>.
##  If <A>n</A> is negative and <A>k</A> is even
##  <Ref Func="RootInt"/> will cause an error.
##  <Ref Func="RootInt"/> will also cause an error if <A>k</A>
##  is 0 or negative.
##  <Example><![CDATA[
##  gap> RootInt( 361 );
##  19
##  gap> RootInt( 2 * 10^12 );
##  1414213
##  gap> RootInt( 17000, 5 );
##  7
##  gap> 7^5;
##  16807
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RootInt" );


#############################################################################
##
#F  SignInt( <n> )  . . . . . . . . . . . . . . . . . . .  sign of an integer
##
##  <#GAPDoc Label="SignInt">
##  <ManSection>
##  <Func Name="SignInt" Arg='n'/>
##
##  <Description>
##  <Index Subkey="of an integer">sign</Index>
##  <Ref Func="SignInt"/> returns the sign of the integer <A>n</A>,
##  i.e., 1 if <A>n</A> is positive,
##  -1 if <A>n</A> is negative and 0 if <A>n</A> is 0.
##  <Example><![CDATA[
##  gap> SignInt( 33 );
##  1
##  gap> SignInt( -214378 );
##  -1
##  gap> SignInt( 0 );
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SignInt" );
#T attribute `Sign' (also for e.g. permutations)?
#T should be internal method!


#############################################################################
##
#F  SmallestRootInt( <n> )  . . . . . . . . . . . smallest root of an integer
##
##  <#GAPDoc Label="SmallestRootInt">
##  <ManSection>
##  <Func Name="SmallestRootInt" Arg='n'/>
##
##  <Description>
##  <Index Subkey="of an integer, smallest">root</Index>
##  <Ref Func="SmallestRootInt"/> returns the smallest root of the integer
##  <A>n</A>.
##  <P/>
##  The smallest root of an integer <A>n</A> is the integer <M>r</M> of
##  smallest absolute value for which a positive integer <M>k</M> exists
##  such that <M><A>n</A> = r^k</M>.
##  <Example><![CDATA[
##  gap> SmallestRootInt( 2^30 );
##  2
##  gap> SmallestRootInt( -(2^30) );
##  -4
##  ]]></Example>
##  <P/>
##  Note that <M>(-2)^{30} = +(2^{30})</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> SmallestRootInt( 279936 );
##  6
##  gap> LogInt( 279936, 6 );
##  7
##  gap> SmallestRootInt( 1001 );
##  1001
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SmallestRootInt" );


#############################################################################
##
#F  PrintFactorsInt( <n> )  . . . . . . . . print factorization of an integer
##
##  <#GAPDoc Label="PrintFactorsInt">
##  <ManSection>
##  <Func Name="PrintFactorsInt" Arg='n'/>
##
##  <Description>
##  prints the prime factorization of the integer <A>n</A> in human-readable
##  form.
##  See also <Ref Func="StringPP"/>.
##  <Example><![CDATA[
##  gap> PrintFactorsInt( Factorial( 7 ) ); Print( "\n" );
##  2^4*3^2*5*7
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrintFactorsInt" );
