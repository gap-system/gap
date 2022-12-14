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
##  This file declares operations for integer primes.

##  <#GAPDoc Label="[1]{numtheor}">
##  &GAP; provides a couple of elementary number theoretic functions.
##  Most of these deal with the group of integers coprime to <M>m</M>,
##  called the <E>prime residue group</E>.
##  The order of this group is <M>\phi(m)</M> (see&nbsp;<Ref Oper="Phi"/>),
##  and <M>\lambda(m)</M> (see&nbsp;<Ref Oper="Lambda"/>) is its exponent.
##  This group is cyclic if and only if <M>m</M> is 2, 4,
##  an odd prime power <M>p^n</M>, or twice an odd prime power <M>2 p^n</M>.
##  In this case the generators  of the group, i.e., elements of order
##  <M>\phi(m)</M>,
##  are called <E>primitive roots</E>
##  (see&nbsp;<Ref Func="PrimitiveRootMod"/>).
##  <P/>
##  Note that neither the arguments nor the return values of the functions
##  listed below are groups or group elements in the sense of &GAP;.
##  The arguments are simply integers.
##  <#/GAPDoc>
##


##########################################################################
##
#V  InfoNumtheor
##
##  <#GAPDoc Label="InfoNumtheor">
##  <ManSection>
##  <InfoClass Name="InfoNumtheor"/>
##
##  <Description>
##  <Ref InfoClass="InfoNumtheor"/> is the info class
##  (see&nbsp;<Ref Sect="Info Functions"/>)
##  for the functions in the number theory chapter.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoNumtheor" );


#############################################################################
##
#F  PrimeResidues( <m> )  . . . . . . . integers relative prime to an integer
##
##  <#GAPDoc Label="PrimeResidues">
##  <ManSection>
##  <Func Name="PrimeResidues" Arg='m'/>
##
##  <Description>
##  <Ref Func="PrimeResidues"/> returns the set of integers from the range
##  <C>[ 0 .. Abs( <A>m</A> )-1 ]</C>
##  that are coprime to the integer <A>m</A>.
##  <P/>
##  <C>Abs(<A>m</A>)</C> must be less than <M>2^{28}</M>,
##  otherwise the set would probably be too large anyhow.
##  <P/>
##  <Example><![CDATA[
##  gap> PrimeResidues( 0 );  PrimeResidues( 1 );  PrimeResidues( 20 );
##  [  ]
##  [ 0 ]
##  [ 1, 3, 7, 9, 11, 13, 17, 19 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrimeResidues" );


#############################################################################
##
#O  Phi( <m> )  . . . . . . . . . . . . . . . . . .  Euler's totient function
##
##  <#GAPDoc Label="Phi">
##  <ManSection>
##  <Oper Name="Phi" Arg='m'/>
##
##  <Description>
##  <Index Subkey="of the prime residue group">order</Index>
##  <Index Subkey="order">prime residue group</Index>
##  <Index>Euler's totient function</Index>
##  <Ref Oper="Phi"/> returns the number <M>\phi(<A>m</A>)</M> of positive
##  integers less than the positive integer <A>m</A>
##  that are coprime to <A>m</A>.
##  <P/>
##  Suppose that <M>m = p_1^{{e_1}} p_2^{{e_2}} \cdots p_k^{{e_k}}</M>.
##  Then <M>\phi(m)</M> is
##  <M>p_1^{{e_1-1}} (p_1-1) p_2^{{e_2-1}} (p_2-1) \cdots p_k^{{e_k-1}} (p_k-1)</M>.
##  <Example><![CDATA[
##  gap> Phi( 12 );
##  4
##  gap> Phi( 2^13-1 );  # this proves that 2^(13)-1 is a prime
##  8190
##  gap> Phi( 2^15-1 );
##  27000
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Phi", [ IsObject ] );


#############################################################################
##
#O  Lambda( <m> ) . . . . . . . . . . . . . . . . . . . . Carmichael function
##
##  <#GAPDoc Label="Lambda">
##  <ManSection>
##  <Oper Name="Lambda" Arg='m'/>
##
##  <Description>
##  <Index>Carmichael's lambda function</Index>
##  <Index Subkey="exponent">prime residue group</Index>
##  <Index Subkey="of the prime residue group">exponent</Index>
##  <Ref Oper="Lambda"/> returns the exponent <M>\lambda(<A>m</A>)</M>
##  of the group of prime residues modulo the integer <A>m</A>.
##  <P/>
##  <M>\lambda(<A>m</A>)</M> is the smallest positive integer <M>l</M> such that for every
##  <M>a</M> relatively prime to <A>m</A> we have <M>a^l \equiv 1 \pmod{<A>m</A>}</M>.
##  Fermat's theorem asserts
##  <M>a^{{\phi(<A>m</A>)}} \equiv 1 \pmod{<A>m</A>}</M>;
##  thus <M>\lambda(<A>m</A>)</M> divides <M>\phi(<A>m</A>)</M> (see&nbsp;<Ref Oper="Phi"/>).
##  <P/>
##  Carmichael's theorem states that <M>\lambda</M> can be computed as follows:
##  <M>\lambda(2) = 1</M>, <M>\lambda(4) = 2</M> and
##  <M>\lambda(2^e) = 2^{{e-2}}</M>
##  if <M>3 \leq e</M>,
##  <M>\lambda(p^e) = (p-1) p^{{e-1}}</M> (i.e. <M>\phi(m)</M>) if <M>p</M>
##  is an odd prime and
##  <M>\lambda(m*n) = </M><C>Lcm</C><M>( \lambda(m), \lambda(n) )</M> if <M>m, n</M> are coprime.
##  <P/>
##  Composites for which <M>\lambda(m)</M> divides <M>m - 1</M> are called Carmichaels.
##  If <M>6k+1</M>, <M>12k+1</M> and <M>18k+1</M> are primes their product is such a number.
##  There are only  1547  Carmichaels below <M>10^{10}</M> but  455052511  primes.
##  <Example><![CDATA[
##  gap> Lambda( 10 );
##  4
##  gap> Lambda( 30 );
##  4
##  gap> Lambda( 561 );  # 561 is the smallest Carmichael number
##  80
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Lambda", [ IsObject ] );


#############################################################################
##
#F  OrderMod( <n>, <m>[, <bound>] ) . . .  multiplicative order of an integer
##
##  <#GAPDoc Label="OrderMod">
##  <ManSection>
##  <Func Name="OrderMod" Arg='n, m[, bound]'/>
##
##  <Description>
##  <Index>multiplicative order of an integer</Index>
##  <Ref Func="OrderMod"/> returns the multiplicative order of the integer
##  <A>n</A> modulo the positive integer <A>m</A>.
##  If <A>n</A> and <A>m</A> are not coprime the order of <A>n</A> is not
##  defined and <Ref Func="OrderMod"/> will return <C>0</C>.
##  <P/>
##  If <A>n</A> and <A>m</A> are relatively prime the multiplicative order of
##  <A>n</A> modulo <A>m</A> is the smallest positive integer <M>i</M>
##  such that  <M><A>n</A>^i \equiv 1 \pmod{<A>m</A>}</M>.
##  If the group of prime residues modulo <A>m</A> is cyclic then
##  each element of maximal order is called a primitive root modulo <A>m</A>
##  (see&nbsp;<Ref Func="IsPrimitiveRootMod"/>).
##  <P/>
##  If no a priori known multiple <A>bound</A> of the desired order is given,
##  <Ref Func="OrderMod"/> usually spends most of its time factoring <A>m</A>
##  for computing <M>\lambda(<A>m</A>)</M> (see <Ref Oper="Lambda"/>) as the
##  default for <A>bound</A>, and then factoring <A>bound</A>
##  (see&nbsp;<Ref Func="FactorsInt"/>).
##  <P/>
##  If an incorrect <A>bound</A> is given then the result will be wrong.
##  <Example><![CDATA[
##  gap> OrderMod( 2, 7 );
##  3
##  gap> OrderMod( 3, 7 );  # 3 is a primitive root modulo 7
##  6
##  gap> m:= (5^166-1) / 167;;   # about 10^113
##  gap> OrderMod( 5, m, 166 );  # needs minutes without third argument
##  166
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OrderMod" );


#############################################################################
##
#F  IsPrimitiveRootMod( <r>, <m> )  . . . . . . . . test for a primitive root
##
##  <#GAPDoc Label="IsPrimitiveRootMod">
##  <ManSection>
##  <Func Name="IsPrimitiveRootMod" Arg='r, m'/>
##
##  <Description>
##  <Index Subkey="for a primitive root">test</Index>
##  <Index Subkey="generator">prime residue group</Index>
##  <Index Subkey="of the prime residue group">generator</Index>
##  <Ref Func="IsPrimitiveRootMod"/> returns <K>true</K> if the integer
##  <A>r</A> is a primitive root modulo the positive integer <A>m</A>,
##  and <K>false</K> otherwise.
##  If <A>r</A> is less than 0 or larger than <A>m</A> it is replaced by its
##  remainder.
##  <Example><![CDATA[
##  gap> IsPrimitiveRootMod( 2, 541 );
##  true
##  gap> IsPrimitiveRootMod( -539, 541 );  # same computation as above;
##  true
##  gap> IsPrimitiveRootMod( 4, 541 );
##  false
##  gap> ForAny( [1..29], r -> IsPrimitiveRootMod( r, 30 ) );
##  false
##  gap> # there is no a primitive root modulo 30
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsPrimitiveRootMod" );


#############################################################################
##
#F  PrimitiveRootMod( <m>[, <start>] )  . .  primitive root modulo an integer
##
##  <#GAPDoc Label="PrimitiveRootMod">
##  <ManSection>
##  <Func Name="PrimitiveRootMod" Arg='m[, start]'/>
##
##  <Description>
##  <Index>primitive root modulo an integer</Index>
##  <Index Subkey="generator">prime residue group</Index>
##  <Index Subkey="of the prime residue group">generator</Index>
##  <Ref Func="PrimitiveRootMod"/> returns the smallest primitive root modulo
##  the positive integer <A>m</A> and <K>fail</K> if no such primitive root
##  exists.
##  If the optional second integer argument <A>start</A> is given
##  <Ref Func="PrimitiveRootMod"/> returns the smallest primitive root that
##  is strictly larger than <A>start</A>.
##  <Example><![CDATA[
##  gap> # largest primitive root for a prime less than 2000:
##  gap> PrimitiveRootMod( 409 );
##  21
##  gap> PrimitiveRootMod( 541, 2 );
##  10
##  gap> # 327 is the largest primitive root mod 337:
##  gap> PrimitiveRootMod( 337, 327 );
##  fail
##  gap> # there exists no primitive root modulo 30:
##  gap> PrimitiveRootMod( 30 );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrimitiveRootMod" );


#############################################################################
##
#F  GeneratorsPrimeResidues( <n> ) . . . . . . generators of the Galois group
##
##  <#GAPDoc Label="GeneratorsPrimeResidues">
##  <ManSection>
##  <Func Name="GeneratorsPrimeResidues" Arg='n'/>
##
##  <Description>
##  Let <A>n</A> be a positive integer.
##  <Ref Func="GeneratorsPrimeResidues"/> returns a description of generators
##  of the group of prime residues modulo <A>n</A>.
##  The return value is a record with components
##  <List>
##  <Mark><C>primes</C>: </Mark>
##  <Item>
##      a list of the prime factors of <A>n</A>,
##  </Item>
##  <Mark><C>exponents</C>: </Mark>
##  <Item>
##      a list of the exponents of these primes in the factorization of <A>n</A>,
##      and
##  </Item>
##  <Mark><C>generators</C>: </Mark>
##  <Item>
##      a list describing generators of the group of prime residues;
##      for the prime factor <M>2</M>, either a primitive root or a list of two
##      generators is stored,
##      for each other prime factor of <A>n</A>, a primitive root is stored.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> GeneratorsPrimeResidues( 1 );
##  rec( exponents := [  ], generators := [  ], primes := [  ] )
##  gap> GeneratorsPrimeResidues( 4*3 );
##  rec( exponents := [ 2, 1 ], generators := [ 7, 5 ],
##    primes := [ 2, 3 ] )
##  gap> GeneratorsPrimeResidues( 8*9*5 );
##  rec( exponents := [ 3, 2, 1 ],
##    generators := [ [ 271, 181 ], 281, 217 ], primes := [ 2, 3, 5 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GeneratorsPrimeResidues" );


#############################################################################
##
#F  Jacobi( <n>, <m> ) . . . . . . . . . . . . . . . . . . . .  Jacobi symbol
##
##  <#GAPDoc Label="Jacobi">
##  <ManSection>
##  <Func Name="Jacobi" Arg='n, m'/>
##
##  <Description>
##  <Index>quadratic residue</Index>
##  <Index Subkey="quadratic">residue</Index>
##  <Ref Func="Jacobi"/> returns the value of the
##  <E>Kronecker-Jacobi symbol</E> <M>J(<A>n</A>,<A>m</A>)</M> of the integer
##  <A>n</A> modulo the integer <A>m</A>.
##  It is defined as follows:
##  <P/>
##  If <M>n</M> and <M>m</M> are not coprime then <M>J(n,m) = 0</M>.
##  Furthermore, <M>J(n,1) = 1</M> and <M>J(n,-1) = -1</M> if <M>m &lt; 0</M>
##  and  <M>+1</M>  otherwise.
##  And for odd <M>n</M> it is <M>J(n,2) = (-1)^k</M> with
##  <M>k = (n^2-1)/8</M>.
##  For odd primes <M>m</M> which are coprime to <M>n</M> the
##  Kronecker-Jacobi symbol has the same value as the Legendre symbol
##  (see&nbsp;<Ref Func="Legendre"/>).
##  <P/>
##  For the general case suppose that <M>m = p_1 \cdot p_2 \cdots p_k</M>
##  is a product of <M>-1</M> and of primes, not necessarily distinct,
##  and that <M>n</M> is coprime to <M>m</M>.
##  Then  <M>J(n,m) = J(n,p_1) \cdot J(n,p_2) \cdots J(n,p_k)</M>.
##  <P/>
##  Note that the Kronecker-Jacobi symbol coincides with the Jacobi symbol
##  that is defined for odd <M>m</M> in many number theory books.
##  For odd primes <M>m</M> and <M>n</M> coprime to <M>m</M> it coincides
##  with the Legendre symbol.
##  <P/>
##  <Ref Func="Jacobi"/> is very efficient, even for large values of
##  <A>n</A> and <A>m</A>, it is about as fast as the Euclidean algorithm
##  (see&nbsp;<Ref Func="Gcd" Label="for (a ring and) several elements"/>).
##
##  <Example><![CDATA[
##  gap> Jacobi( 11, 35 );  # 9^2 = 11 mod 35
##  1
##  gap> # this is -1, thus there is no r such that r^2 = 6 mod 35
##  gap> Jacobi( 6, 35 );
##  -1
##  gap> # this is 1 even though there is no r with r^2 = 3 mod 35
##  gap> Jacobi( 3, 35 );
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Jacobi" );


#############################################################################
##
#F  Legendre( <n>, <m> )  . . . . . . . . . . . . . . . . . . Legendre symbol
##
##  <#GAPDoc Label="Legendre">
##  <ManSection>
##  <Func Name="Legendre" Arg='n, m'/>
##
##  <Description>
##  <Index>quadratic residue</Index>
##  <Index Subkey="quadratic">residue</Index>
##  <Ref Func="Legendre"/> returns the value of the <E>Legendre symbol</E>
##  of the integer <A>n</A> modulo the positive integer <A>m</A>.
##  <P/>
##  The value  of  the Legendre  symbol <M>L(n/m)</M> is 1 if  <M>n</M> is a
##  <E>quadratic residue</E> modulo <M>m</M>, i.e., if there exists an integer <M>r</M> such
##  that <M>r^2 \equiv n \pmod{m}</M> and <M>-1</M> otherwise.
##  <P/>
##  If a root of <A>n</A> exists it can be found by <Ref Func="RootMod"/>.
##  <P/>
##  While the value of the Legendre symbol usually  is only defined for <A>m</A> a
##  prime, we have extended the  definition to include composite moduli  too.
##  The  Jacobi  symbol  (see <Ref Func="Jacobi"/>)  is    another generalization  of the
##  Legendre symbol for composite moduli that is  much  cheaper  to  compute,
##  because it does not need the factorization of <A>m</A> (see <Ref Func="FactorsInt"/>).
##  <P/>
##  A description of the Jacobi symbol, the Legendre symbol, and related
##  topics can be found  in <Cite Key="Baker84"/>.
##
##  <Example><![CDATA[
##  gap> Legendre( 5, 11 );  # 4^2 = 5 mod 11
##  1
##  gap> # this is -1, thus there is no r such that r^2 = 6 mod 11
##  gap> Legendre( 6, 11 );
##  -1
##  gap> # this is -1, thus there is no r such that r^2 = 3 mod 35
##  gap> Legendre( 3, 35 );
##  -1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Legendre" );


#############################################################################
##
#F  RootMod( <n>[, <k>], <m> )  . . . . . . . . . . .  root modulo an integer
##
##  <#GAPDoc Label="RootMod">
##  <ManSection>
##  <Func Name="RootMod" Arg='n[, k], m'/>
##
##  <Description>
##  <Index>quadratic residue</Index>
##  <Index Subkey="quadratic">residue</Index>
##  <Index Subkey="of an integer modulo another">root</Index>
##  <Ref Func="RootMod"/> computes a <A>k</A>th root of the integer <A>n</A>
##  modulo the positive integer <A>m</A>,
##  i.e., a <M>r</M> such that
##  <M>r^{<A>k</A>} \equiv <A>n</A> \pmod{<A>m</A>}</M>.
##  If no such root exists <Ref Func="RootMod"/> returns <K>fail</K>.
##  If only the arguments <A>n</A> and <A>m</A> are given,
##  the default value for <A>k</A> is <M>2</M>.
##  <P/>
##  A square root of <A>n</A> exists only if <C>Legendre(<A>n</A>,<A>m</A>) = 1</C>
##  (see&nbsp;<Ref Func="Legendre"/>).
##  If <A>m</A> has <M>r</M> different prime factors then  there are <M>2^r</M>  different
##  roots of <A>n</A> mod  <A>m</A>.
##  It is unspecified which one <Ref Func="RootMod"/> returns.
##  You can, however, use <Ref Func="RootsMod"/> to compute the full set
##  of roots.
##  <P/>
##  <Ref Func="RootMod"/> is efficient even for large values of <A>m</A>,
##  in fact the most time is usually spent factoring <A>m</A>
##  (see <Ref Func="FactorsInt"/>).
##
##  <Example><![CDATA[
##  gap> # note 'RootMod' does not return 8 in this case but -8:
##  gap> RootMod( 64, 1009 );
##  1001
##  gap> RootMod( 64, 3, 1009 );
##  518
##  gap> RootMod( 64, 5, 1009 );
##  656
##  gap> List( RootMod( 64, 1009 ) * RootsUnityMod( 1009 ),
##  >       x -> x mod 1009 );  # set of all square roots of 64 mod 1009
##  [ 1001, 8 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RootMod" );


#############################################################################
##
#F  RootsMod( <n>[, <k>], <m> ) . . . . . . . . . . . roots modulo an integer
##
##  <#GAPDoc Label="RootsMod">
##  <ManSection>
##  <Func Name="RootsMod" Arg='n[, k], m'/>
##
##  <Description>
##  <Ref Func="RootsMod"/> computes the set of <A>k</A>th roots of the
##  integer <A>n</A> modulo the positive integer <A>m</A>, i.e., the list of
##  all <M>r</M> such that <M>r^{<A>k</A>} \equiv <A>n</A> \pmod{<A>m</A>}</M>.
##  If only the arguments <A>n</A> and <A>m</A> are given,
##  the default value for <A>k</A> is <M>2</M>.
##  <Example><![CDATA[
##  gap> RootsMod( 1, 7*31 );  # the same as `RootsUnityMod( 7*31 )'
##  [ 1, 92, 125, 216 ]
##  gap> RootsMod( 7, 7*31 );
##  [ 21, 196 ]
##  gap> RootsMod( 5, 7*31 );
##  [  ]
##  gap> RootsMod( 1, 5, 7*31 );
##  [ 1, 8, 64, 78, 190 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RootsMod" );


#############################################################################
##
#F  RootsUnityMod( [<k>,] <m> ) . . . . . .  roots of unity modulo an integer
##
##  <#GAPDoc Label="RootsUnityMod">
##  <ManSection>
##  <Func Name="RootsUnityMod" Arg='[k,] m'/>
##
##  <Description>
##  <Index>modular roots</Index>
##  <Index Subkey="of 1 modulo an integer">root</Index>
##  <Ref Func="RootsUnityMod"/> returns the set of <A>k</A>-th roots of unity
##  modulo the positive integer <A>m</A>, i.e.,
##  the list of all solutions <M>r</M> of
##  <M>r^{<A>k</A>} \equiv <A>n</A> \pmod{<A>m</A>}</M>.
##  If only the argument <A>m</A> is given,
##  the default value for <A>k</A> is <M>2</M>.
##  <P/>
##  In general there are <M><A>k</A>^n</M> such roots if the modulus <A>m</A>
##  has  <M>n</M> different prime factors <M>p</M> such that
##  <M>p \equiv 1 \pmod{<A>k</A>}</M>.
##  If <M><A>k</A>^2</M> divides <A>m</A> then there are
##  <M><A>k</A>^{{n+1}}</M> such roots;
##  and especially if <M><A>k</A> = 2</M> and 8 divides <A>m</A>
##  there are <M>2^{{n+2}}</M> such roots.
##  <P/>
##  In the current implementation <A>k</A> must be a prime.
##  <Example><![CDATA[
##  gap> RootsUnityMod( 7*31 );  RootsUnityMod( 3, 7*31 );
##  [ 1, 92, 125, 216 ]
##  [ 1, 25, 32, 36, 67, 149, 156, 191, 211 ]
##  gap> RootsUnityMod( 5, 7*31 );
##  [ 1, 8, 64, 78, 190 ]
##  gap> List( RootMod( 64, 1009 ) * RootsUnityMod( 1009 ),
##  >          x -> x mod 1009 );  # set of all square roots of 64 mod 1009
##  [ 1001, 8 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RootsUnityMod" );


#############################################################################
##
#F  LogMod( <n>, <r>, <m> ) . . . . . .  discrete logarithm modulo an integer
#F  LogModShanks( <n>, <r>, <m> )
##
##  <#GAPDoc Label="LogMod">
##  <ManSection>
##  <Func Name="LogMod" Arg='n, r, m'/>
##  <Func Name="LogModShanks" Arg='n, r, m'/>
##
##  <Description>
##  <Index Subkey="discrete">logarithm</Index>
##  computes the discrete <A>r</A>-logarithm of the integer <A>n</A>
##  modulo the integer <A>m</A>.
##  It returns a number <A>l</A> such that
##  <M><A>r</A>^{<A>l</A>} \equiv <A>n</A> \pmod{<A>m</A>}</M>
##  if such a number exists.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  <Ref Func="LogModShanks"/> uses the Baby Step - Giant Step Method
##  of Shanks (see for example <Cite Key="Coh93" Where="section 5.4.1"/>)
##  and in general requires more memory than a call to <Ref Func="LogMod"/>.
##  <Example><![CDATA[
##  gap> l:= LogMod( 2, 5, 7 );  5^l mod 7 = 2;
##  4
##  true
##  gap> LogMod( 1, 3, 3 );  LogMod( 2, 3, 3 );
##  0
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LogMod" );
DeclareGlobalFunction( "LogModShanks" );

DeclareGlobalFunction( "DoLogModRho" );


#############################################################################
##
#O  Sigma( <n> )  . . . . . . . . . . . . . . . sum of divisors of an integer
##
##  <#GAPDoc Label="Sigma">
##  <ManSection>
##  <Oper Name="Sigma" Arg='n'/>
##
##  <Description>
##  <Ref Oper="Sigma"/> returns the sum of the positive divisors of the
##  nonzero integer <A>n</A>.
##  <P/>
##  <Ref Oper="Sigma"/> is a multiplicative arithmetic function, i.e.,
##  if <M>n</M> and <M>m</M> are relatively prime we have that
##  <M>\sigma(n \cdot m) = \sigma(n) \sigma(m)</M>.
##  <P/>
##  Together with the formula <M>\sigma(p^k) = (p^{{k+1}}-1) / (p-1)</M>
##  this allows us to compute <M>\sigma(<A>n</A>)</M>.
##  <P/>
##  Integers <A>n</A> for which <M>\sigma(<A>n</A>) = 2 <A>n</A></M>
##  are called perfect.
##  Even perfect integers are exactly of the form
##  <M>2^{{<A>n</A>-1}}(2^{<A>n</A>}-1)</M>
##  where <M>2^{<A>n</A>}-1</M> is prime.
##  Primes of the form <M>2^{<A>n</A>}-1</M> are called
##  <E>Mersenne primes</E>, and
##  42 among the known Mersenne primes are obtained for <A>n</A> <M>=</M> 2, 3, 5, 7, 13, 17, 19,
##  31, 61, 89, 107, 127, 521, 607, 1279, 2203, 2281, 3217, 4253, 4423, 9689,
##  9941, 11213, 19937, 21701, 23209, 44497, 86243, 110503, 132049, 216091,
##  756839, 859433, 1257787, 1398269, 2976221, 3021377, 6972593, 13466917,
##  20996011, 24036583 and 25964951. Please find more up to date information
##  about Mersenne primes at <URL>https://www.mersenne.org</URL>.
##  It is not known whether odd perfect integers exist,
##  however&nbsp;<Cite Key="BC89"/> show that any such integer must have
##  at least 300 decimal digits.
##  <P/>
##  <Ref Oper="Sigma"/> usually spends most of its time factoring <A>n</A>
##  (see&nbsp;<Ref Func="FactorsInt"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> Sigma( 1 );
##  1
##  gap> Sigma( 1009 );  # 1009 is a prime
##  1010
##  gap> Sigma( 8128 ) = 2*8128;  # 8128 is a perfect number
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Sigma", [ IsObject ] );


#############################################################################
##
#O  Tau( <n> )  . . . . . . . . . . . . . .  number of divisors of an integer
##
##  <#GAPDoc Label="Tau">
##  <ManSection>
##  <Oper Name="Tau" Arg='n'/>
##
##  <Description>
##  <Ref Oper="Tau"/> returns the number of the positive divisors of the
##  nonzero integer <A>n</A>.
##  <P/>
##  <Ref Oper="Tau"/> is a multiplicative arithmetic function, i.e.,
##  if <M>n</M> and  <M>m</M> are relative prime we have
##  <M>\tau(n \cdot m) = \tau(n) \tau(m)</M>.
##  Together with the formula <M>\tau(p^k) = k+1</M> this allows us
##  to compute <M>\tau(<A>n</A>)</M>.
##  <P/>
##  <Ref Oper="Tau"/> usually spends most of its time factoring <A>n</A>
##  (see&nbsp;<Ref Func="FactorsInt"/>).
##  <Example><![CDATA[
##  gap> Tau( 1 );
##  1
##  gap> Tau( 1013 );  # thus 1013 is a prime
##  2
##  gap> Tau( 8128 );
##  14
##  gap> # result is odd if and only if argument is a perfect square:
##  gap> Tau( 36 );
##  9
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Tau", [ IsObject ] );


#############################################################################
##
#F  MoebiusMu( <n> )  . . . . . . . . . . . . . .  Moebius inversion function
##
##  <#GAPDoc Label="MoebiusMu">
##  <ManSection>
##  <Func Name="MoebiusMu" Arg='n'/>
##
##  <Description>
##  <Ref Func="MoebiusMu"/> computes the value of Moebius inversion function
##  for the nonzero integer <A>n</A>.
##  This is 0 for integers which are not squarefree, i.e.,
##  which are divided by a square <M>r^2</M>.
##  Otherwise it is 1 if <A>n</A> has a even number and <M>-1</M> if <A>n</A>
##  has an odd number of prime factors.
##  <P/>
##  The importance of <M>\mu</M> stems from the so called inversion formula.
##  Suppose <M>f</M> is a multiplicative arithmetic function
##  defined on the positive integers and let
##  <M>g(n) = \sum_{{d \mid  n}} f(d)</M>.
##  Then <M>f(n) = \sum_{{d \mid n}} \mu(d) g(n/d)</M>.
##  As a special case we have
##  <M>\phi(n) = \sum_{{d \mid n}} \mu(d) n/d</M>
##  since <M>n = \sum_{{d \mid n}} \phi(d)</M>
##  (see&nbsp;<Ref Oper="Phi"/>).
##  <P/>
##  <Ref Func="MoebiusMu"/> usually spends all of its time factoring <A>n</A>
##  (see <Ref Func="FactorsInt"/>).
##  <Example><![CDATA[
##  gap> MoebiusMu( 60 );  MoebiusMu( 61 );  MoebiusMu( 62 );
##  0
##  -1
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MoebiusMu" );


#############################################################################
##
#F  TwoSquares( <n> ) . . . . . repres. of an integer as a sum of two squares
##
##  <#GAPDoc Label="TwoSquares">
##  <ManSection>
##  <Func Name="TwoSquares" Arg='n'/>
##
##  <Description>
##  <Index Subkey="as a sum of two squares">representation</Index>
##  <Ref Func="TwoSquares"/> returns a list of two integers <M>x \leq y</M>
##  such that the sum of the squares of <M>x</M> and <M>y</M> is equal to the
##  nonnegative integer <A>n</A>, i.e., <M>n = x^2 + y^2</M>.
##  If no such representation exists
##  <Ref Func="TwoSquares"/> will return <K>fail</K>.
##  <Ref Func="TwoSquares"/> will return a representation for which the gcd
##  of <M>x</M> and <M>y</M> is as small as possible.
##  It is not specified which representation <Ref Func="TwoSquares"/> returns
##  if there is more than one.
##  <P/>
##  Let <M>a</M> be the product of all maximal powers of primes of the form
##  <M>4k+3</M> dividing <A>n</A>.
##  A representation of <A>n</A> as a sum of two squares exists
##  if and only if <M>a</M> is a perfect square.
##  Let <M>b</M> be the maximal power of <M>2</M> dividing <A>n</A> or its
##  half, whichever is a perfect square.
##  Then the minimal possible gcd of <M>x</M> and <M>y</M> is the square root
##  <M>c</M> of <M>a \cdot b</M>.
##  The number of different minimal representation with <M>x \leq y</M> is
##  <M>2^{{l-1}}</M>, where <M>l</M> is the number of different prime factors
##  of the form <M>4k+1</M> of <A>n</A>.
##  <P/>
##  The algorithm first finds a square root <M>r</M> of <M>-1</M> modulo
##  <M><A>n</A> / (a \cdot b)</M>, which must exist,
##  and applies the Euclidean algorithm to <M>r</M> and <A>n</A>.
##  The first residues in the sequence that are smaller than
##  <M>\sqrt{{<A>n</A>/(a \cdot b)}}</M> times <M>c</M> are a possible pair
##  <M>x</M> and <M>y</M>.
##  <P/>
##  Better descriptions of the algorithm and related topics can be found in
##  <Cite Key="Wagon90"/> and <Cite Key="Zagier90"/>.
##
##  <Example><![CDATA[
##  gap> TwoSquares( 5 );
##  [ 1, 2 ]
##  gap> TwoSquares( 11 );  # there is no representation
##  fail
##  gap> TwoSquares( 16 );
##  [ 0, 4 ]
##  gap> # 3 is the minimal possible gcd because 9 divides 45:
##  gap> TwoSquares( 45 );
##  [ 3, 6 ]
##  gap> # it is not [5,10] because their gcd is not minimal:
##  gap> TwoSquares( 125 );
##  [ 2, 11 ]
##  gap> # [10,11] would be the other possible representation:
##  gap> TwoSquares( 13*17 );
##  [ 5, 14 ]
##  gap> TwoSquares( 848654483879497562821 );  # argument is prime
##  [ 6305894639, 28440994650 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TwoSquares" );

#############################################################################
##
#F  PValuation( <n>, <p> ) . . . . . . . . . . . prime part exponent
##
##  <#GAPDoc Label="PValuation">
##  <ManSection>
##  <Func Name="PValuation" Arg='n, p'/>
##
##  <Description>
##  For an integer <A>n</A> and a prime <A>p</A> this function returns
##  the <A>p</A>-valuation of <A>n</A>,
##  that is the exponent <M>e</M> such that <M>p^e</M> is the largest
##  power of <A>p</A> that divides <A>n</A>.
##  The valuation of zero is infinity.
##
##  <Example><![CDATA[
##  gap> PValuation(100,2);
##  2
##  gap> PValuation(100,3);
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PValuation" );
