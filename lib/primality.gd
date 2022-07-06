#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Jack Schmidt.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for the primality test in the integers.
##

##############################################################################
##
##  Bibiliography
##
##  http://www.ams.org/mathscinet-getitem?mr=572872
##  http://links.jstor.org/sici?sici=0025-5718%28197504%2929%3A130%3C620%3ANPCAFO%3E2.0.CO%3B2-N
##  @article{BLS1975,
##     AUTHOR = {Brillhart, John and Lehmer, D. H. and Selfridge, J. L.},
##      TITLE = {New primality criteria and factorizations of {$2\sp{m}\pm 1$}},
##    JOURNAL = {Math. Comp.},
##   FJOURNAL = {Mathematics of Computation},
##     VOLUME = {29},
##       YEAR = {1975},
##      PAGES = {620--647},
##       ISSN = {0025-5718},
##    MRCLASS = {10A25},
##   MRNUMBER = {MR0384673 (52 \#5546)},
## MRREVIEWER = {Jean-Marie De Koninck},
## }
##
##  http://www.ams.org/mathscinet-getitem?mr=572872
##  http://links.jstor.org/sici?sici=0025-5718%28198007%2935%3A151%3C1003%3ATPT%3E2.0.CO%3B2-D
##  @article{PSW1980,
##     AUTHOR = {Pomerance, Carl and Selfridge, J. L. and Wagstaff, Jr., Samuel
##               S.},
##      TITLE = {The pseudoprimes to {$25\cdot 10\sp{9}$}},
##    JOURNAL = {Math. Comp.},
##   FJOURNAL = {Mathematics of Computation},
##     VOLUME = {35},
##       YEAR = {1980},
##     NUMBER = {151},
##      PAGES = {1003--1026},
##       ISSN = {0025-5718},
##      CODEN = {MCMPAF},
##    MRCLASS = {10A40 (10-04 10A25)},
##   MRNUMBER = {MR572872 (82g:10030)},
## }
##
##  http://www.ams.org/mathscinet-getitem?mr=583518
##  http://links.jstor.org/sici?sici=0025-5718%28198010%2935%3A152%3C1391%3ALP%3E2.0.CO%3B2-N
##  @article {BW1980,
##     AUTHOR = {Baillie, Robert and Wagstaff, Jr., Samuel S.},
##      TITLE = {Lucas pseudoprimes},
##    JOURNAL = {Math. Comp.},
##   FJOURNAL = {Mathematics of Computation},
##     VOLUME = {35},
##       YEAR = {1980},
##     NUMBER = {152},
##      PAGES = {1391--1417},
##       ISSN = {0025-5718},
##      CODEN = {MCMPAF},
##    MRCLASS = {10A25},
##   MRNUMBER = {MR583518 (81j:10005)},
## MRREVIEWER = {V. C. Harris},
## }
##
##############################################################################


##  Section 1

#############################################################################
##
#F  IsSquareInt(<n>)
##
##  <#GAPDoc Label="IsSquareInt">
##  <ManSection>
##  <Func Name="IsSquareInt" Arg='n'/>
##
##  <Description>
##  <Ref Func="IsSquareInt"/> tests whether the integer <A>n</A> is the
##  square of an integer or not.
##  This test is much faster than the simpler <C>RootInt</C><M>(n)^2=n</M>
##  because it first tests whether <A>n</A> is a square residue modulo
##  some small integers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IsSquareInt");


##  Section 2

DeclareGlobalFunction("IsStrongPseudoPrimeBaseA");
DeclareGlobalFunction("IsBPSWLucasPseudoPrime");
DeclareGlobalFunction("IsLucasPseudoPrimeDP");
DeclareGlobalFunction("IsStrongLucasPseudoPrimeDP");
DeclareGlobalFunction("IsBPSWPseudoPrime");
DeclareGlobalFunction("IsBPSWPseudoPrime_VerifyCorrectness");

##  Section 3
DeclareGlobalFunction("PrimalityProof_FindFermat");
DeclareGlobalFunction("PrimalityProof_FindLucas");
DeclareGlobalFunction("PrimalityProof_FindStructure");

#############################################################################
##
#F  IsPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . .  test for a prime
#F  IsProbablyPrimeInt( <n> ) . . . . . . . . . . . . . . .  test for a prime
##
##  <#GAPDoc Label="IsPrimeInt">
##  <ManSection>
##  <Func Name="IsPrimeInt" Arg='n'/>
##  <Func Name="IsProbablyPrimeInt" Arg='n'/>
##
##  <Description>
##  <Ref Func="IsPrimeInt"/> returns <K>false</K> if it can  prove that
##  the integer <A>n</A> is composite and <K>true</K> otherwise.
##  By  convention <C>IsPrimeInt(0) = IsPrimeInt(1) = false</C>
##  and we define
##  <C>IsPrimeInt(-</C><A>n</A><C>) = IsPrimeInt(</C><A>n</A><C>)</C>.
##  <P/>
##  <Ref Func="IsPrimeInt"/> will return <K>true</K> for every prime <A>n</A>.
##  <Ref Func="IsPrimeInt"/> will return <K>false</K> for all composite
##  <A>n</A> <M>&lt; 10^{18}</M> and for all composite <A>n</A> that have
##  a factor <M>p &lt; 1000</M>. So for integers <A>n</A> <M>&lt; 10^{18}</M>,
##  <Ref Func="IsPrimeInt"/> is a proper primality test. It is conceivable that
##  <Ref Func="IsPrimeInt"/> may  return <K>true</K> for some  composite
##  <A>n</A> <M>&gt; 10^{18}</M>, but no such <A>n</A> is currently known.
##  So for integers <A>n</A> <M>&gt; 10^{18}</M>, <Ref Func="IsPrimeInt"/>
##  is a  probable-primality test. <Ref Func="IsPrimeInt"/> will issue a
##  warning when its argument is probably prime but not a proven prime.
##  (The function <Ref Func="IsProbablyPrimeInt"/> will do a similar
##  calculation but not issue a warning.) The warning can be switched off by
##  <C>SetInfoLevel( InfoPrimeInt, 0 );</C>, the default level is <M>1</M>
##  (also see <Ref Oper="SetInfoLevel"/> ).
##  <P/>
##  If composites that  fool <Ref Func="IsPrimeInt"/> do exist, they  would be extremely
##  rare, and finding one by pure chance might be less likely than finding a
##  bug in &GAP;. We would appreciate being informed about any example of a
##  composite number <A>n</A> for which <Ref Func="IsPrimeInt"/> returns <K>true</K>.
##  <P/>
##  <Ref Func="IsPrimeInt"/> is a deterministic algorithm, i.e., the computations involve
##  no random numbers, and repeated calls will always return the same result.
##  <Ref Func="IsPrimeInt"/> first does trial divisions by the primes less than 1000.
##  Then it tests that <A>n</A> is a strong pseudoprime w.r.t. the base 2.
##  Finally it tests whether <A>n</A> is a Lucas pseudoprime w.r.t. the smallest
##  quadratic nonresidue of  <A>n</A>. A better description can be found in the
##  comment in the library file <File>primality.gi</File>.
##  <P/>
##  The time taken by <Ref Func="IsPrimeInt"/> is approximately proportional to the third
##  power  of  the number  of  digits of <A>n</A>. Testing numbers with several
##  hundreds digits is quite feasible.
##  <P/>
##  <Ref Func="IsPrimeInt"/> is a method for the general operation <Ref Oper="IsPrime"/>.
##  <P/>
##  Remark: In future versions of &GAP; we hope to change the definition of
##  <Ref Func="IsPrimeInt"/> to return <K>true</K> only for proven primes (currently, we lack
##  a sufficiently good primality proving function). In applications, use
##  explicitly <Ref Func="IsPrimeInt"/> or <Ref Func="IsProbablyPrimeInt"/>
##  with this change in mind.
##  <Example><![CDATA[
##  gap> IsPrimeInt( 2^31 - 1 );
##  true
##  gap> IsPrimeInt( 10^42 + 1 );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
UnbindGlobal( "IsPrimeInt" );
DeclareGlobalFunction( "IsPrimeInt" );
DeclareGlobalFunction( "IsProbablyPrimeInt" );

#############################################################################
##
#F  PrimalityProof(<n>)
##
##  <#GAPDoc Label="PrimalityProof">
##  <ManSection>
##  <Func Name="PrimalityProof" Arg='n'/>
##
##  <Description>
##  Construct a machine verifiable proof of the primality of (the probable
##  prime) <A>n</A>, following the ideas of <Cite Key="BLS1975"/>.
##
##  The proof consists of various Fermat and Lucas pseudoprimality tests,
##  which taken as a whole prove the primality.  The proof is represented
##  as a list of witnesses of two kinds.  The first kind, <C>[ "F", divisor,
##  base ]</C>, indicates a successful Fermat pseudoprimality test, where
##  <A>n</A> is a strong pseudoprime at <K>base</K> with order not divisible by
##  <M>(<A>n</A>-1)/divisor</M>.  The second kind, <C>[ "L", divisor,
##  discriminant, P ]</C> indicates a successful Lucas pseudoprimality test,
##  for a quadratic form of given <K>discriminant</K> and middle term <K>P</K>
##  with an extra check at <M>(<A>n</A>+1)/divisor</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PrimalityProof");

##  Section 4
DeclareGlobalFunction("PrimalityProof_VerifyWitness");
DeclareGlobalFunction("PrimalityProof_VerifyStructure");
DeclareGlobalFunction("PrimalityProof_Verify");

##  Section 5
DeclareGlobalVariable("PrimesProofs");
