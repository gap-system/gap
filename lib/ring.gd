#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for rings.
##


#############################################################################
##
#P  IsNearRing( <R> )
##
##  <ManSection>
##  <Prop Name="IsNearRing" Arg='R'/>
##
##  <Description>
##  A <E>near-ring</E> in &GAP; is a near-additive group
##  (see&nbsp;<Ref Func="IsNearAdditiveGroup"/>) that is also a semigroup (see&nbsp;<Ref Func="IsSemigroup"/>),
##  such that addition <C>+</C> and multiplication <C>*</C> are right distributive
##  (see&nbsp;<Ref Func="IsRDistributive"/>).
##  Any associative ring (see&nbsp;<Ref Func="IsRing"/>) is also a near-ring.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsNearRing",
    IsNearAdditiveGroup and IsMagma and IsRDistributive and IsAssociative );


#############################################################################
##
#P  IsNearRingWithOne( <R> )
##
##  <ManSection>
##  <Prop Name="IsNearRingWithOne" Arg='R'/>
##
##  <Description>
##  A <E>near-ring-with-one</E> in &GAP; is a near-ring (see&nbsp;<Ref Prop="IsNearRing"/>)
##  that is also a magma-with-one (see&nbsp;<Ref Func="IsMagmaWithOne"/>).
##  <P/>
##  Note that the identity and the zero of a near-ring-with-one need <E>not</E> be
##  distinct.
##  This means that a near-ring that consists only of its zero element can be
##  regarded as a near-ring-with-one.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsNearRingWithOne", IsNearRing and IsMagmaWithOne );


#############################################################################
##
#A  AsNearRing( <C> )
##
##  <ManSection>
##  <Attr Name="AsNearRing" Arg='C'/>
##
##  <Description>
##  If the elements in the collection <A>C</A> form a near-ring then <C>AsNearRing</C>
##  returns this near-ring, otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AsNearRing", IsNearRingElementCollection );


#############################################################################
##
#P  IsRing( <R> )
##
##  <#GAPDoc Label="IsRing">
##  <ManSection>
##  <Filt Name="IsRing" Arg='R'/>
##
##  <Description>
##  A <E>ring</E> in &GAP; is an additive group
##  (see&nbsp;<Ref Filt="IsAdditiveGroup"/>)
##  that is also a magma (see&nbsp;<Ref Filt="IsMagma"/>),
##  such that addition <C>+</C> and multiplication <C>*</C> are distributive,
##  see <Ref Prop="IsDistributive"/>.
##  <P/>
##  The multiplication need <E>not</E> be associative
##  (see&nbsp;<Ref Prop="IsAssociative"/>).
##  For example, a Lie algebra (see&nbsp;<Ref Chap="Lie Algebras"/>)
##  is regarded as a ring in &GAP;.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsRing",
    IsAdditiveGroup and IsMagma and IsDistributive );


#############################################################################
##
#P  IsRingWithOne( <R> )
##
##  <#GAPDoc Label="IsRingWithOne">
##  <ManSection>
##  <Filt Name="IsRingWithOne" Arg='R'/>
##
##  <Description>
##  A <E>ring-with-one</E> in &GAP; is a ring (see&nbsp;<Ref Filt="IsRing"/>)
##  that is also a magma-with-one (see&nbsp;<Ref Filt="IsMagmaWithOne"/>).
##  <P/>
##  Note that the identity and the zero of a ring-with-one need <E>not</E> be
##  distinct.
##  This means that a ring that consists only of its zero element can be
##  regarded as a ring-with-one.
##  <!-- shall we force <E>every</E> trivial ring to be a ring-with-one-->
##  <!-- by installing an implication?-->
##  <P/>
##  This is especially useful in the case of finitely presented rings,
##  in the sense that each factor of a ring-with-one is again a
##  ring-with-one.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsRingWithOne", IsRing and IsMagmaWithOne );


#############################################################################
##
#A  AsRing( <C> )
##
##  <#GAPDoc Label="AsRing">
##  <ManSection>
##  <Attr Name="AsRing" Arg='C'/>
##
##  <Description>
##  If the elements in the collection <A>C</A> form a ring then
##  <Ref Func="AsRing"/> returns this ring,
##  otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsRing", IsRingElementCollection );


#############################################################################
##
#A  GeneratorsOfRing( <R> )
##
##  <#GAPDoc Label="GeneratorsOfRing">
##  <ManSection>
##  <Attr Name="GeneratorsOfRing" Arg='R'/>
##
##  <Description>
##  <Ref Attr="GeneratorsOfRing"/> returns a list of elements such that the
##  ring <A>R</A> is the closure of these elements under addition,
##  multiplication, and taking additive inverses.
##  <Example><![CDATA[
##  gap> R:=Ring( 2, 1/2 );
##  <ring with 2 generators>
##  gap> GeneratorsOfRing( R );
##  [ 2, 1/2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfRing", IsRing );


#############################################################################
##
#A  GeneratorsOfRingWithOne( <R> )
##
##  <#GAPDoc Label="GeneratorsOfRingWithOne">
##  <ManSection>
##  <Attr Name="GeneratorsOfRingWithOne" Arg='R'/>
##
##  <Description>
##  <Ref Attr="GeneratorsOfRingWithOne"/> returns a list of elements
##  such that the ring <A>R</A> is the closure of these elements
##  under addition, multiplication, taking additive inverses, and taking
##  the identity element <C>One( <A>R</A> )</C>.
##  <P/>
##  <A>R</A> itself need <E>not</E> be known to be a ring-with-one.
##  <P/>
##  <Example><![CDATA[
##  gap> R:= RingWithOne( [ 4, 6 ] );
##  Integers
##  gap> GeneratorsOfRingWithOne( R );
##  [ 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfRingWithOne", IsRingWithOne );


#############################################################################
##
#O  RingByGenerators( <C> ) . . . . . . .  ring gener. by elements in a coll.
##
##  <#GAPDoc Label="RingByGenerators">
##  <ManSection>
##  <Oper Name="RingByGenerators" Arg='C'/>
##
##  <Description>
##  <Ref Oper="RingByGenerators"/> returns the ring generated by the elements
##  in the collection <A>C</A>,
##  i.&nbsp;e., the closure of <A>C</A> under addition, multiplication,
##  and taking additive inverses.
##  <Example><![CDATA[
##  gap> RingByGenerators([ 2, E(4) ]);
##  <ring with 2 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RingByGenerators", [ IsCollection ] );


#############################################################################
##
#O  DefaultRingByGenerators( <coll> ) . . . . default ring containing a coll.
##
##  <#GAPDoc Label="DefaultRingByGenerators">
##  <ManSection>
##  <Oper Name="DefaultRingByGenerators" Arg='coll'/>
##
##  <Description>
##  For a collection <A>coll</A>, returns a default ring in which
##  <A>coll</A> is contained.
##  <Example><![CDATA[
##  gap> DefaultRingByGenerators([ 2, E(4) ]);
##  GaussianIntegers
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DefaultRingByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Ring( <r>, <s>, ... )  . . . . . . . . . . ring generated by a collection
#F  Ring( <coll> ) . . . . . . . . . . . . . . ring generated by a collection
##
##  <#GAPDoc Label="Ring">
##  <ManSection>
##  <Heading>Ring</Heading>
##  <Func Name="Ring" Arg='r, s, ...' Label="for ring elements"/>
##  <Func Name="Ring" Arg='coll' Label="for a collection"/>
##
##  <Description>
##  In the first form <Ref Func="Ring" Label="for ring elements"/>
##  returns the smallest ring that contains all the elements
##  <A>r</A>, <A>s</A>, <M>\ldots</M>
##  In the second form <Ref Func="Ring" Label="for a collection"/> returns
##  the smallest ring that contains all the elements in the collection
##  <A>coll</A>.
##  If any element is not an element of a ring or if the elements lie in no
##  common ring an error is raised.
##  <P/>
##  <Ref Func="Ring" Label="for ring elements"/> differs from
##  <Ref Func="DefaultRing" Label="for ring elements"/> in that it returns
##  the smallest ring in which the elements lie,
##  while <Ref Func="DefaultRing" Label="for ring elements"/>
##  may return a larger ring if that makes sense.
##  <Example><![CDATA[
##  gap> Ring( 2, E(4) );
##  <ring with 2 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Ring" );


#############################################################################
##
#O  RingWithOneByGenerators( <coll> )
##
##  <#GAPDoc Label="RingWithOneByGenerators">
##  <ManSection>
##  <Oper Name="RingWithOneByGenerators" Arg='coll'/>
##
##  <Description>
##  <Ref Oper="RingWithOneByGenerators"/> returns the ring-with-one
##  generated by the elements in the collection <A>coll</A>,
##  i.&nbsp;e., the closure of <A>coll</A> under
##  addition, multiplication, taking additive inverses,
##  and taking the identity of an element.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RingWithOneByGenerators", [ IsCollection ] );


#############################################################################
##
#F  RingWithOne( <r>, <s>, ... )  . . ring-with-one generated by a collection
#F  RingWithOne( <C> )  . . . . . . . ring-with-one generated by a collection
##
##  <#GAPDoc Label="RingWithOne">
##  <ManSection>
##  <Heading>RingWithOne</Heading>
##  <Func Name="RingWithOne" Arg='r, s, ...' Label="for ring elements"/>
##  <Func Name="RingWithOne" Arg='coll' Label="for a collection"/>
##
##  <Description>
##  In the first form <Ref Func="RingWithOne" Label="for ring elements"/>
##  returns the smallest ring with one that contains all the elements
##  <A>r</A>, <A>s</A>, <M>\ldots</M>
##  In the second form <Ref Func="RingWithOne" Label="for a collection"/>
##  returns the smallest ring with one that contains all the elements
##  in the collection <A>C</A>.
##  If any element is not an element of a ring or if the elements lie in no
##  common ring an error is raised.
##  <Example><![CDATA[
##  gap> RingWithOne( [ 4, 6 ] );
##  Integers
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RingWithOne" );


#############################################################################
##
#F  DefaultRing( <r>, <s>, ... )  . . .  default ring containing a collection
#F  DefaultRing( <coll> ) . . . . . . .  default ring containing a collection
##
##  <#GAPDoc Label="DefaultRing">
##  <ManSection>
##  <Heading>DefaultRing</Heading>
##  <Func Name="DefaultRing" Arg='r, s, ...' Label="for ring elements"/>
##  <Func Name="DefaultRing" Arg='coll' Label="for a collection"/>
##
##  <Description>
##  In the first form <Ref Func="DefaultRing" Label="for ring elements"/>
##  returns a ring that contains all the elements <A>r</A>, <A>s</A>,
##  <M>\ldots</M> etc.
##  In the second form <Ref Func="DefaultRing" Label="for a collection"/>
##  returns a ring that contains all the elements in the collection
##  <A>coll</A>.
##  If any element is not an element of a ring or if the elements lie in no
##  common ring an error is raised.
##  <P/>
##  The ring returned by <Ref Func="DefaultRing" Label="for ring elements"/>
##  need not be the smallest ring in which the elements lie.
##  For example for elements from cyclotomic fields,
##  <Ref Func="DefaultRing" Label="for ring elements"/> may return the ring
##  of integers of the smallest cyclotomic field in which the elements lie,
##  which need not be the smallest ring overall,
##  because the elements may in fact lie in a smaller number field
##  which is itself not a cyclotomic field.
##  <P/>
##  (For the exact definition of the default ring of a certain type of
##  elements, look at the corresponding method installation.)
##  <P/>
##  <Ref Func="DefaultRing" Label="for ring elements"/> is used
##  by ring functions such as <Ref Oper="Quotient"/>, <Ref Oper="IsPrime"/>,
##  <Ref Oper="Factors"/>,
##  or <Ref Func="Gcd" Label="for (a ring and) several elements"/>
##  if no explicit ring is given.
##  <P/>
##  <Ref Func="Ring" Label="for ring elements"/> differs from
##  <Ref Func="DefaultRing" Label="for ring elements"/> in that it returns
##  the smallest ring in which the elements lie,
##  while <Ref Func="DefaultRing" Label="for ring elements"/> may return
##  a larger ring if that makes sense.
##  <P/>
##  <Example><![CDATA[
##  gap> DefaultRing( 2, E(4) );
##  GaussianIntegers
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DefaultRing" );


#############################################################################
##
#F  Subring( <R>, <gens> ) . . . . . . . . subring of <R> generated by <gens>
#F  SubringNC( <R>, <gens> ) . . . . . . . subring of <R> generated by <gens>
##
##  <#GAPDoc Label="Subring">
##  <ManSection>
##  <Func Name="Subring" Arg='R, gens'/>
##  <Func Name="SubringNC" Arg='R, gens'/>
##
##  <Description>
##  returns the ring with parent <A>R</A> generated by the elements in
##  <A>gens</A>.
##  When the second form, <Ref Func="SubringNC"/> is used,
##  it is <E>not</E> checked whether all elements in <A>gens</A> lie in
##  <A>R</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> R:= Integers;
##  Integers
##  gap> S:= Subring( R, [ 4, 6 ] );
##  <ring with 1 generator>
##  gap> Parent( S );
##  Integers
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Subring" );
DeclareGlobalFunction( "SubringNC" );


#############################################################################
##
#F  SubringWithOne( <R>, <gens> )   .  subring-with-one of <R> gen. by <gens>
#F  SubringWithOneNC( <R>, <gens> ) .  subring-with-one of <R> gen. by <gens>
##
##  <#GAPDoc Label="SubringWithOne">
##  <ManSection>
##  <Func Name="SubringWithOne" Arg='R, gens'/>
##  <Func Name="SubringWithOneNC" Arg='R, gens'/>
##
##  <Description>
##  returns the ring with one with parent <A>R</A> generated by the elements
##  in <A>gens</A>.
##  When the second form, <Ref Func="SubringWithOneNC"/> is used,
##  it is <E>not</E> checked whether all elements in <A>gens</A> lie in
##  <A>R</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> R:= SubringWithOne( Integers, [ 4, 6 ] );
##  Integers
##  gap> Parent( R );
##  Integers
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubringWithOne" );
DeclareGlobalFunction( "SubringWithOneNC" );


#############################################################################
##
#O  ClosureRing( <R>, <r> )
#O  ClosureRing( <R>, <S> )
##
##  <#GAPDoc Label="ClosureRing">
##  <ManSection>
##  <Heading>ClosureRing</Heading>
##  <Oper Name="ClosureRing" Arg='R, r'
##   Label="for a ring and a ring element"/>
##  <Oper Name="ClosureRing" Arg='R, S' Label="for two rings"/>
##
##  <Description>
##  For a ring <A>R</A> and either an element <A>r</A> of its elements family
##  or a ring <A>S</A>,
##  <Ref Oper="ClosureRing" Label="for a ring and a ring element"/>
##  returns the ring generated by both arguments.
##  <P/>
##  <Example><![CDATA[
##  gap> ClosureRing( Integers, E(4) );
##  <ring-with-one, with 2 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClosureRing", [ IsRing, IsObject ] );


#############################################################################
##
#C  IsUniqueFactorizationRing( <R> )
##
##  <#GAPDoc Label="IsUniqueFactorizationRing">
##  <ManSection>
##  <Filt Name="IsUniqueFactorizationRing" Arg='R' Type='Category'/>
##
##  <Description>
##  A ring <A>R</A> is called a <E>unique factorization ring</E> if
##  every nonzero element has a unique factorization into
##  irreducible elements,
##  i.e., a  unique representation as product of irreducibles
##  (see <Ref Oper="IsIrreducibleRingElement"/>).
##  Unique in this context means unique up to permutations of the factors and
##  up to multiplication of the factors by units
##  (see&nbsp;<Ref Attr="Units"/>).
##  <P/>
##  (Note that we cannot install a subset maintained method for this filter
##  since the factorization of an element needs not exist in a subring.
##  As an example, consider the subring <M>4 &NN; + 1</M> of the ring
##  <M>4 &ZZ; + 1</M>;
##  in the subring, the element <M>3 \cdot 3 \cdot 11 \cdot 7</M> has the two
##  factorizations <M>33 \cdot 21 = 9 \cdot 77</M>,
##  but in the large ring there is the unique factorization
##  <M>(-3) \cdot (-3) \cdot (-11) \cdot (-7)</M>,
##  and it is easy to see that every element in <M>4 &ZZ; + 1</M> has a
##  unique factorization.)
##  <P/>
##  <Example><![CDATA[
##  gap> IsUniqueFactorizationRing( PolynomialRing( Rationals, 1 ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsUniqueFactorizationRing", IsRing );


#############################################################################
##
#C  IsEuclideanRing( <R> )
##
##  <#GAPDoc Label="IsEuclideanRing">
##  <ManSection>
##  <Filt Name="IsEuclideanRing" Arg='R' Type='Category'/>
##
##  <Description>
##  A ring <M>R</M> is called a Euclidean ring if it is a non-trivial commutative ring and
##  there exists a function <M>\delta</M>, called the Euclidean degree, from
##  <M>R-\{0_R\}</M> into a well-ordered set (such as the nonnegative integers),
##  such that for every pair <M>r \in R</M> and <M>s \in  R-\{0_R\}</M> there
##  exists an element <M>q</M> such that either
##  <M>r - q s = 0_R</M> or <M>\delta(r - q s) &lt; \delta( s )</M>.
##  In &GAP; the Euclidean degree <M>\delta</M> is implicitly built into a
##  ring and cannot be changed.
##  The existence of this division with remainder implies that the
##  Euclidean algorithm can be applied to compute a greatest common divisor
##  of two elements,
##  which in turn implies that <M>R</M> is a unique factorization ring.
##  <P/>
##  <!-- more general: new category <Q>valuated domain</Q>?-->
##  <Example><![CDATA[
##  gap> IsEuclideanRing( GaussianIntegers );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsEuclideanRing",
    IsRingWithOne and IsUniqueFactorizationRing );


#############################################################################
##
#P  IsAnticommutative( <R> )
##
##  <#GAPDoc Label="IsAnticommutative">
##  <ManSection>
##  <Prop Name="IsAnticommutative" Arg='R'/>
##
##  <Description>
##  is <K>true</K> if the relation <M>a * b = - b * a</M>
##  holds for all elements <M>a</M>, <M>b</M> in the ring <A>R</A>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsAnticommutative", IsRing );

InstallSubsetMaintenance( IsAnticommutative,
    IsRing and IsAnticommutative, IsRing );

InstallFactorMaintenance( IsAnticommutative,
    IsRing and IsAnticommutative, IsObject, IsRing );


#############################################################################
##
#P  IsIntegralRing( <R> )
##
##  <#GAPDoc Label="IsIntegralRing">
##  <ManSection>
##  <Prop Name="IsIntegralRing" Arg='R'/>
##
##  <Description>
##  A ring-with-one <A>R</A> is integral if it is commutative,
##  contains no nontrivial zero divisors,
##  and if its identity is distinct from its zero.
##  <Example><![CDATA[
##  gap> IsIntegralRing( Integers );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsIntegralRing", IsRing );

InstallSubsetMaintenance( IsIntegralRing,
    IsRing and IsIntegralRing, IsRing and IsNonTrivial );

InstallTrueMethod( IsIntegralRing,
    IsRing and IsMagmaWithInversesIfNonzero and IsNonTrivial );
InstallTrueMethod( IsIntegralRing,
    IsRing and IsCyclotomicCollection and IsNonTrivial );


#############################################################################
##
#P  IsJacobianRing( <R> )
##
##  <#GAPDoc Label="IsJacobianRing">
##  <ManSection>
##  <Prop Name="IsJacobianRing" Arg='R'/>
##
##  <Description>
##  is <K>true</K> if the Jacobi identity holds in the ring <A>R</A>,
##  and <K>false</K> otherwise.
##  The Jacobi identity means that
##  <M>x * (y * z) + z * (x * y) +  y * (z * x)</M>
##  is the zero element of <A>R</A>,
##  for all elements <M>x</M>, <M>y</M>, <M>z</M> in <A>R</A>.
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( GF( 5 ), 7 );
##  <Lie algebra over GF(5), with 13 generators>
##  gap> IsJacobianRing( L );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsJacobianRing", IsRing );

InstallTrueMethod( IsJacobianRing,
    IsJacobianElementCollection and IsRing );

InstallSubsetMaintenance( IsJacobianRing,
    IsRing and IsJacobianRing, IsRing );

InstallFactorMaintenance( IsJacobianRing,
    IsRing and IsJacobianRing, IsObject, IsRing );


#############################################################################
##
#P  IsZeroSquaredRing( <R> )
##
##  <#GAPDoc Label="IsZeroSquaredRing">
##  <ManSection>
##  <Prop Name="IsZeroSquaredRing" Arg='R'/>
##
##  <Description>
##  is <K>true</K> if <M>a * a</M> is the zero element of the ring <A>R</A>
##  for all <M>a</M> in <A>R</A>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsZeroSquaredRing", IsRing );

InstallTrueMethod( IsAnticommutative, IsRing and IsZeroSquaredRing );

InstallTrueMethod( IsZeroSquaredRing,
    IsZeroSquaredElementCollection and IsRing );

InstallSubsetMaintenance( IsZeroSquaredRing,
    IsRing and IsZeroSquaredRing, IsRing );

InstallFactorMaintenance( IsZeroSquaredRing,
    IsRing and IsZeroSquaredRing, IsObject, IsRing );


#############################################################################
##
#P  IsZeroMultiplicationRing( <R> )
##
##  <ManSection>
##  <Prop Name="IsZeroMultiplicationRing" Arg='R'/>
##
##  <Description>
##  is <K>true</K> if <M>a * b</M> is the zero element of the ring <A>R</A>
##  for all <M>a, b</M> in <A>R</A>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsZeroMultiplicationRing", IsRing );

# FIXME: the following implication is correct, but triggers a bug in
# the Sophus package. Until that is fixed, we disable it. To reproduce
# the bug, load Sophus, and enter this command:
#   f:= FullMatrixAlgebra( Rationals, 2 );
# If the bug is still present, this will trigger an error due to
# LeftActingDomain being called on an object which does not (yet)
# have LeftActingDomain set.
#InstallTrueMethod( IsZeroMultiplicationRing, IsRing and IsTrivial );

InstallTrueMethod( IsZeroSquaredRing, IsRing and IsZeroMultiplicationRing );
InstallTrueMethod( IsAssociative, IsRing and IsZeroMultiplicationRing );
InstallTrueMethod( IsCommutative, IsRing and IsZeroMultiplicationRing );
# The implication to `IsAnticommutative' follows from `IsZeroSquaredRing'.

InstallSubsetMaintenance( IsZeroMultiplicationRing,
    IsRing and IsZeroMultiplicationRing, IsRing );

InstallFactorMaintenance( IsZeroMultiplicationRing,
    IsRing and IsZeroMultiplicationRing, IsObject, IsRing );


#############################################################################
##
#A  Units( <R> )
##
##  <#GAPDoc Label="Units">
##  <ManSection>
##  <Attr Name="Units" Arg='R'/>
##
##  <Description>
##  <Ref Attr="Units"/> returns the group of units of the ring <A>R</A>.
##  This may either be returned as a list or as a group.
##  <P/>
##  An element <M>r</M> is called a <E>unit</E> of a ring <M>R</M>
##  if <M>r</M> has an inverse in <M>R</M>.
##  It is easy to see that the set of units forms a multiplicative group.
##  <P/>
##  <Example><![CDATA[
##  gap> Units( GaussianIntegers );
##  [ -1, 1, -E(4), E(4) ]
##  gap> Units( GF( 16 ) );
##  <group of size 15 with 1 generator>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Units", IsRing );


#############################################################################
##
#O  Factors( [<R>, ]<r> )
##
##  <#GAPDoc Label="Factors">
##  <ManSection>
##  <Oper Name="Factors" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="Factors"/> returns the factorization of the ring element
##  <A>r</A> in the ring <A>R</A>, if given,
##  and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  The factorization is returned as a list of primes
##  (see <Ref Oper="IsPrime"/>).
##  Each element in the list is a standard associate
##  (see <Ref Oper="StandardAssociate"/>) except the first one,
##  which is multiplied by a unit as necessary to have
##  <C>Product( Factors( <A>R</A>, <A>r</A> )  )  = <A>r</A></C>.
##  This list is usually also sorted, thus smallest prime factors come first.
##  If <A>r</A> is a unit or zero,
##  <C>Factors( <A>R</A>, <A>r</A> ) = [ <A>r</A> ]</C>.
##  <P/>
##  <!-- Who does really need the additive structure?
##       We could define <C>Factors</C> for arbitrary commutative monoids.-->
##  <Example><![CDATA[
##  gap> x:= Indeterminate( GF(2), "x" );;
##  gap> pol:= x^2+x+1;
##  x^2+x+Z(2)^0
##  gap> Factors( pol );
##  [ x^2+x+Z(2)^0 ]
##  gap> Factors( PolynomialRing( GF(4) ), pol );
##  [ x+Z(2^2), x+Z(2^2)^2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Factors", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  IsAssociated( [<R>, ]<r>, <s> )
##
##  <#GAPDoc Label="IsAssociated">
##  <ManSection>
##  <Oper Name="IsAssociated" Arg='[R, ]r, s'/>
##
##  <Description>
##  <Ref Oper="IsAssociated"/> returns <K>true</K> if the two ring elements
##  <A>r</A> and <A>s</A> are associated in the ring <A>R</A>, if given,
##  and otherwise in their default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  If the two elements are not associated then <K>false</K> is returned.
##  <P/>
##  Two elements <A>r</A> and <A>s</A> of a ring <A>R</A> are called
##  <E>associated</E> if there is a unit <M>u</M> of <A>R</A> such that
##  <A>r</A> <M>u = </M><A>s</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsAssociated", [ IsRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  Associates( [<R>, ]<r> )
##
##  <#GAPDoc Label="Associates">
##  <ManSection>
##  <Oper Name="Associates" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="Associates"/> returns the set of associates of <A>r</A> in
##  the ring <A>R</A>, if given,
##  and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <P/>
##  Two elements <A>r</A> and <M>s</M> of a ring <M>R</M> are called
##  <E>associated</E> if there is a unit <M>u</M> of <M>R</M> such that
##  <M><A>r</A> u = s</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> Associates( Integers, 2 );
##  [ -2, 2 ]
##  gap> Associates( GaussianIntegers, 2 );
##  [ -2, 2, -2*E(4), 2*E(4) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Associates", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  IsUnit( [<R>, ]<r> ). . . . . . . . .  check whether <r> is a unit in <R>
##
##  <#GAPDoc Label="IsUnit">
##  <ManSection>
##  <Oper Name="IsUnit" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="IsUnit"/> returns <K>true</K> if <A>r</A> is a unit in the
##  ring <A>R</A>, if given, and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  If <A>r</A> is not a unit then <K>false</K> is returned.
##  <P/>
##  An element <A>r</A> is called a <E>unit</E> in a ring <A>R</A>,
##  if <A>r</A> has an inverse in <A>R</A>.
##  <P/>
##  <Ref Oper="IsUnit"/> may call <Ref Oper="Quotient"/>.
##  <!-- really?-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsUnit", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  InterpolatedPolynomial( <R>, <x>, <y> ) . . . . . . . . . . interpolation
##
##  <#GAPDoc Label="InterpolatedPolynomial">
##  <ManSection>
##  <Oper Name="InterpolatedPolynomial" Arg='R, x, y'/>
##
##  <Description>
##  <Ref Oper="InterpolatedPolynomial"/> returns, for given lists <A>x</A>,
##  <A>y</A> of elements in a ring <A>R</A> of the same length <M>n</M>
##  the unique  polynomial of  degree less than <M>n</M> which has value
##  <A>y</A>[<M>i</M>] at <A>x</A><M>[i]</M>,
##  for all <M>i \in \{ 1, \ldots, n \}</M>.
##  Note that the elements in <A>x</A> must be distinct.
##  <Example><![CDATA[
##  gap> InterpolatedPolynomial( Integers, [ 1, 2, 3 ], [ 5, 7, 0 ] );
##  -9/2*x^2+31/2*x-6
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "InterpolatedPolynomial",
    [ IsRing, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  Quotient( [<R>, ]<r>, <s> )
##
##  <#GAPDoc Label="Quotient">
##  <ManSection>
##  <Oper Name="Quotient" Arg='[R, ]r, s'/>
##
##  <Description>
##  <Ref Oper="Quotient"/> returns a (right) quotient of the two ring elements
##  <A>r</A> and <A>s</A> in the ring <A>R</A>, if given,
##  and otherwise in their default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  More specifically, it returns a ring element <M>q</M> such that
##  <M>r = q * s</M> holds, or <K>fail</K> if no such elements exists in the
##  respective ring.
##  <P/>
##  The result may not be unique if the ring contains zero divisors.
##  <P/>
##  (To perform the division in the quotient field of a ring, use the
##  quotient operator <C>/</C>.)
##  <Example><![CDATA[
##  gap> Quotient( 2, 3 );
##  fail
##  gap> Quotient( 6, 3 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Quotient", [ IsRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  StandardAssociate( [<R>, ]<r> )
##
##  <#GAPDoc Label="StandardAssociate">
##  <ManSection>
##  <Oper Name="StandardAssociate" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="StandardAssociate"/> returns the standard associate of the
##  ring element <A>r</A> in the ring <A>R</A>, if given,
##  and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <P/>
##  The <E>standard associate</E> of a ring element <A>r</A> of <A>R</A> is
##  an associated element of <A>r</A> which is, in a ring dependent way,
##  distinguished among the set of associates of <A>r</A>.
##  For example, in the ring of integers the standard associate is the
##  absolute value.
##  <P/>
##  <Example><![CDATA[
##  gap> x:= Indeterminate( Rationals, "x" );;
##  gap> StandardAssociate( -x^2-x+1 );
##  x^2+x-1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "StandardAssociate", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  StandardAssociateUnit( [<R>, ]<r> )
##
##  <#GAPDoc Label="StandardAssociateUnit">
##  <ManSection>
##  <Oper Name="StandardAssociateUnit" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="StandardAssociateUnit"/> returns a unit in the ring <A>R</A>
##  such that the ring element <A>r</A> times this unit equals the
##  standard associate of <A>r</A> in <A>R</A>.
##  <P/>
##  If <A>R</A> is not given, the default ring of <A>r</A> is used instead.
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <P/>
##  <P/>
##  <Example><![CDATA[
##  gap> y:= Indeterminate( Rationals, "y" );;
##  gap> r:= -y^2-y+1;
##  -y^2-y+1
##  gap> StandardAssociateUnit( r );
##  -1
##  gap> StandardAssociateUnit( r ) * r = StandardAssociate( r );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "StandardAssociateUnit", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  IsPrime( [<R>, ]<r> )
##
##  <#GAPDoc Label="IsPrime">
##  <ManSection>
##  <Oper Name="IsPrime" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="IsPrime"/> returns <K>true</K> if the ring element <A>r</A> is
##  a prime in the ring <A>R</A>, if given,
##  and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  If <A>r</A> is not a prime then <K>false</K> is returned.
##  <P/>
##  An element <A>r</A> of a ring <A>R</A> is called <E>prime</E> if for each
##  pair <M>s</M> and <M>t</M> such that <A>r</A> divides <M>s t</M>
##  the element <A>r</A> divides either <M>s</M> or <M>t</M>.
##  Note that there are rings where not every irreducible element
##  (see <Ref Oper="IsIrreducibleRingElement"/>) is a prime.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsPrime", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  IsIrreducibleRingElement( [<R>, ]<r> )
##
##  <#GAPDoc Label="IsIrreducibleRingElement">
##  <ManSection>
##  <Oper Name="IsIrreducibleRingElement" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="IsIrreducibleRingElement"/> returns <K>true</K> if the ring
##  element <A>r</A> is irreducible in the ring <A>R</A>, if given,
##  and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  If <A>r</A> is not irreducible then <K>false</K> is returned.
##  <P/>
##  An element <A>r</A> of a ring <A>R</A> is called <E>irreducible</E>
##  if <A>r</A> is not a unit in <A>R</A> and if there is no nontrivial
##  factorization of <A>r</A> in <A>R</A>,
##  i.e., if there is no representation of <A>r</A> as product <M>s t</M>
##  such that neither <M>s</M> nor <M>t</M> is a unit
##  (see <Ref Oper="IsUnit"/>).
##  Each prime element (see <Ref Oper="IsPrime"/>) is irreducible.
##  <Example><![CDATA[
##  gap> IsIrreducibleRingElement( Integers, 2 );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsIrreducibleRingElement", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  EuclideanDegree( [<R>, ]<r> )
##
##  <#GAPDoc Label="EuclideanDegree">
##  <ManSection>
##  <Oper Name="EuclideanDegree" Arg='[R, ]r'/>
##
##  <Description>
##  <Ref Oper="EuclideanDegree"/> returns the Euclidean degree of the
##  ring element <A>r</A> in the ring <A>R</A>, if given,
##  and otherwise in its default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <P/>
##  The ring <A>R</A> must be a Euclidean ring
##  (see <Ref Filt="IsEuclideanRing"/>).
##  <Example><![CDATA[
##  gap> EuclideanDegree( GaussianIntegers, 3 );
##  9
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EuclideanDegree", [ IsEuclideanRing, IsRingElement ] );


#############################################################################
##
#O  EuclideanRemainder( [<R>, ]<r>, <m> )
##
##  <#GAPDoc Label="EuclideanRemainder">
##  <ManSection>
##  <Oper Name="EuclideanRemainder" Arg='[R, ]r, m'/>
##
##  <Description>
##  <Ref Oper="EuclideanRemainder"/> returns the Euclidean remainder of the
##  ring element <A>r</A> modulo the ring element <A>m</A>
##  in the ring <A>R</A>, if given,
##  and otherwise in their default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <P/>
##  The ring <A>R</A> must be a Euclidean ring
##  (see <Ref Filt="IsEuclideanRing"/>), otherwise an error is signalled.
##  <Example><![CDATA[
##  gap> EuclideanRemainder( 8, 3 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EuclideanRemainder",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  EuclideanQuotient( [<R>, ]<r>, <m> )
##
##  <#GAPDoc Label="EuclideanQuotient">
##  <ManSection>
##  <Oper Name="EuclideanQuotient" Arg='[R, ]r, m'/>
##
##  <Description>
##  <Ref Oper="EuclideanQuotient"/> returns the Euclidean quotient of the
##  ring elements <A>r</A> and <A>m</A> in the ring <A>R</A>, if given,
##  and otherwise in their default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <P/>
##  The ring <A>R</A> must be a Euclidean ring
##  (see <Ref Filt="IsEuclideanRing"/>), otherwise an error is signalled.
##  <Example><![CDATA[
##  gap> EuclideanQuotient( 8, 3 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EuclideanQuotient",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  QuotientRemainder( [<R>, ]<r>, <m> )
##
##  <#GAPDoc Label="QuotientRemainder">
##  <ManSection>
##  <Oper Name="QuotientRemainder" Arg='[R, ]r, m'/>
##
##  <Description>
##  <Ref Oper="QuotientRemainder"/> returns the Euclidean quotient
##  and the Euclidean remainder of the ring elements <A>r</A> and <A>m</A>
##  in the ring <A>R</A>, if given,
##  and otherwise in their default ring
##  (see <Ref Func="DefaultRing" Label="for ring elements"/>).
##  The result is a pair of ring elements.
##  <P/>
##  The ring <A>R</A> must be a Euclidean ring
##  (see <Ref Filt="IsEuclideanRing"/>), otherwise an error is signalled.
##  <Example><![CDATA[
##  gap> QuotientRemainder( GaussianIntegers, 8, 3 );
##  [ 3, -1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "QuotientRemainder",
    [ IsRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  QuotientMod( [<R>, ]<r>, <s>, <m> )
##
##  <#GAPDoc Label="QuotientMod">
##  <ManSection>
##  <Oper Name="QuotientMod" Arg='[R, ]r, s, m'/>
##
##  <Description>
##  <Ref Oper="QuotientMod"/> returns a quotient of the ring
##  elements <A>r</A> and <A>s</A> modulo the ring element <A>m</A>
##  in the ring <A>R</A>, if given,
##  and otherwise in their default ring, see
##  <Ref Func="DefaultRing" Label="for ring elements"/>.
##  <P/>
##  <A>R</A> must be a Euclidean ring (see <Ref Filt="IsEuclideanRing"/>)
##  so that <Ref Oper="EuclideanRemainder"/> can be applied.
##  If no modular quotient exists, <K>fail</K> is returned.
##  <P/>
##  A quotient <M>q</M> of <A>r</A> and <A>s</A> modulo <A>m</A> is an
##  element of <A>R</A> such that <M>q <A>s</A> = <A>r</A></M> modulo
##  <M>m</M>, i.e., such that <M>q <A>s</A> - <A>r</A></M> is divisible by
##  <A>m</A> in <A>R</A> and that <M>q</M> is either zero (if <A>r</A> is
##  divisible by <A>m</A>) or the Euclidean degree of <M>q</M> is strictly
##  smaller than the Euclidean degree of <A>m</A>.
##  <Example><![CDATA[
##  gap> QuotientMod( 7, 2, 3 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "QuotientMod",
    [ IsRing, IsRingElement, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  PowerMod( [<R>, ]<r>, <e>, <m> )
##
##  <#GAPDoc Label="PowerMod">
##  <ManSection>
##  <Oper Name="PowerMod" Arg='[R, ]r, e, m'/>
##
##  <Description>
##  <Ref Oper="PowerMod"/> returns the <A>e</A>-th power of the ring
##  element <A>r</A> modulo the ring element <A>m</A>
##  in the ring <A>R</A>, if given,
##  and otherwise in their default ring, see
##  <Ref Func="DefaultRing" Label="for ring elements"/>.
##  <A>e</A> must be an integer.
##  <P/>
##  <A>R</A> must be a Euclidean ring (see <Ref Filt="IsEuclideanRing"/>)
##  so that <Ref Oper="EuclideanRemainder"/> can be applied to its elements.
##  <P/>
##  If <A>e</A> is positive the result is <A>r</A><C>^</C><A>e</A> modulo
##  <A>m</A>.
##  If <A>e</A> is negative then <Ref Oper="PowerMod"/> first tries to find
##  the inverse of <A>r</A> modulo <A>m</A>, i.e.,
##  <M>i</M> such that <M>i <A>r</A> = 1</M> modulo <A>m</A>.
##  If the inverse does not exist an error is signalled.
##  If the inverse does exist <Ref Oper="PowerMod"/> returns
##  <C>PowerMod( <A>R</A>, <A>i</A>, -<A>e</A>, <A>m</A> )</C>.
##  <P/>
##  <Ref Oper="PowerMod"/> reduces the intermediate values modulo <A>m</A>,
##  improving performance drastically when <A>e</A> is large and <A>m</A>
##  small.
##  <Example><![CDATA[
##  gap> PowerMod( 12, 100000, 7 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PowerMod",
    [ IsRing, IsRingElement, IsInt, IsRingElement ] );


#############################################################################
##
#F  Gcd( [<R>, ]<r1>, <r2>, ... )
#F  Gcd( [<R>, ]<list> )
##
##  <#GAPDoc Label="Gcd">
##  <ManSection>
##  <Heading>Gcd</Heading>
##  <Func Name="Gcd" Arg='[R, ]r1, r2, ...'
##   Label="for (a ring and) several elements"/>
##  <Func Name="Gcd" Arg='[R, ]list'
##   Label="for (a ring and) a list of elements"/>
##
##  <Description>
##  <Ref Func="Gcd" Label="for (a ring and) several elements"/> returns
##  the greatest common divisor of the ring elements <A>r1</A>, <A>r2</A>,
##  <M>\ldots</M> resp. of the ring elements in the list <A>list</A>
##  in the ring <A>R</A>, if given, and otherwise in their default ring,
##  see <Ref Func="DefaultRing" Label="for ring elements"/>.
##  <P/>
##  <Ref Func="Gcd" Label="for (a ring and) several elements"/> returns
##  the standard associate (see <Ref Oper="StandardAssociate"/>) of the
##  greatest common divisors.
##  <P/>
##  A divisor of an element <M>r</M> in the ring <M>R</M> is an element
##  <M>d\in R</M> such that <M>r</M> is a multiple of <M>d</M>.
##  A common divisor of the elements <M>r_1, r_2, \ldots</M> in the
##  ring <M>R</M> is an element <M>d\in R</M> which is a divisor of
##  each <M>r_1, r_2, \ldots</M>.
##  A greatest common divisor <M>d</M> in addition has the property that every
##  other common divisor of <M>r_1, r_2, \ldots</M> is a divisor of <M>d</M>.
##  <P/>
##  Note that this in particular implies the following:
##  For the zero element <M>z</M> of <A>R</A>, we have
##  <C>Gcd( <A>r</A>, </C><M>z</M><C> ) = Gcd( </C><M>z</M><C>, <A>r</A> )
##  = StandardAssociate( <A>r</A> )</C>
##  and <C>Gcd( </C><M>z</M><C>, </C><M>z</M><C> ) = </C><M>z</M>.
##  <Example><![CDATA[
##  gap> Gcd( Integers, [ 10, 15 ] );
##  5
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Gcd" );


#############################################################################
##
#O  GcdOp( [<R>, ]<r>, <s> )
##
##  <#GAPDoc Label="GcdOp">
##  <ManSection>
##  <Oper Name="GcdOp" Arg='[R, ]r, s'/>
##
##  <Description>
##  <Ref Oper="GcdOp"/> is the operation to compute
##  the greatest common divisor of two ring elements <A>r</A>, <A>s</A>
##  in the ring <A>R</A> or in their default ring.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GcdOp",
    [ IsUniqueFactorizationRing, IsRingElement, IsRingElement ] );

# The following function allows installing two and three argument methods
# for GcdOp at the same time. This can be desirable over just installing a
# three argument version, as a lot of code will invoke the two argument
# version, which by default uses DefaultRing to construct a ring object,
# based on the two arguments, and then redispatches to the three argument
# version. But constructing this ring object can be costly compared to the
# cost of the actual Gcd computation. By installing a custom two-argument
# method for GcdOp, we can avoid this and the overhead of the second method
# dispatch.
BindGlobal("InstallRingAgnosticGcdMethod",
function(info,fampred3,fampred2,filters,rank,fun)
  InstallMethod(GcdOp,Concatenation(info,": with ring"),
    fampred3,filters,rank,function(R,a,b) return fun(a,b);end);
  InstallOtherMethod(GcdOp,Concatenation(info,": no ring"),fampred2,
  filters{[2,3]},
  # Adjust the method rank by taking the rank of the (omitted) ring argument
  # into account
  {} -> rank+Maximum(0,RankFilter(filters[1])
                   -RankFilter(IsUniqueFactorizationRing)),fun);
end);

#############################################################################
##
#F  GcdRepresentation( [<R>, ]<r1>, <r2>, ... )
#F  GcdRepresentation( [<R>, ]<list> )
##
##  <#GAPDoc Label="GcdRepresentation">
##  <ManSection>
##  <Heading>GcdRepresentation</Heading>
##  <Func Name="GcdRepresentation" Arg='[R, ]r1, r2, ...'
##   Label="for (a ring and) several elements"/>
##  <Func Name="GcdRepresentation" Arg='[R, ]list'
##   Label="for (a ring and) a list of elements"/>
##
##  <Description>
##  <Ref Func="GcdRepresentation" Label="for (a ring and) several elements"/>
##  returns a representation of
##  the greatest common divisor of the ring elements
##  <A>r1</A>, <A>r2</A>, <M>\ldots</M> resp. of the ring elements
##  in the list <A>list</A> in the Euclidean ring <A>R</A>, if given,
##  and otherwise in their default ring,
##  see <Ref Func="DefaultRing" Label="for ring elements"/>.
##  <P/>
##  A representation of the gcd <M>g</M> of the elements
##  <M>r_1, r_2, \ldots</M> of a ring <M>R</M> is a list of ring elements
##  <M>s_1, s_2, \ldots</M> of <M>R</M>,
##  such that <M>g = s_1 r_1 + s_2  r_2 + \cdots</M>.
##  Such representations do not exist in all rings, but they
##  do exist in Euclidean rings (see <Ref Filt="IsEuclideanRing"/>),
##  which can be shown using the Euclidean algorithm, which in fact can
##  compute those coefficients.
##  <Example><![CDATA[
##  gap> a:= Indeterminate( Rationals, "a" );;
##  gap> GcdRepresentation( a^2+1, a^3+1 );
##  [ -1/2*a^2-1/2*a+1/2, 1/2*a+1/2 ]
##  ]]></Example>
##  <P/>
##  <Ref Func="Gcdex"/> provides similar functionality over the integers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GcdRepresentation" );


#############################################################################
##
#O  GcdRepresentationOp( [<R>, ]<r>, <s> )
##
##  <#GAPDoc Label="GcdRepresentationOp">
##  <ManSection>
##  <Oper Name="GcdRepresentationOp" Arg='[R, ]r, s'/>
##
##  <Description>
##  <Ref Oper="GcdRepresentationOp"/> is the operation to compute
##  the representation of the greatest common divisor of two ring elements
##  <A>r</A>, <A>s</A> in the Euclidean ring <A>R</A> or in their default ring,
##  respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GcdRepresentationOp",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#F  Lcm( [<R>, ]<r1>, <r2>, ... )
#F  Lcm( [<R>, ]<list> )
##
##  <#GAPDoc Label="Lcm">
##  <ManSection>
##  <Heading>Lcm</Heading>
##  <Func Name="Lcm" Arg='[R, ]r1, r2, ...'
##   Label="for (a ring and) several elements"/>
##  <Func Name="Lcm" Arg='[R, ]list'
##   Label="for (a ring and) a list of elements"/>
##
##  <Description>
##  <Ref Func="Lcm" Label="for (a ring and) several elements"/> returns
##  the least common multiple of the ring elements
##  <A>r1</A>, <A>r2</A>, <M>\ldots</M> resp. of the ring elements
##  in the list <A>list</A> in the ring <A>R</A>, if given,
##  and otherwise in their default ring,
##  see <Ref Func="DefaultRing" Label="for ring elements"/>.
##  <P/>
##  <Ref Func="Lcm" Label="for (a ring and) several elements"/> returns
##  the standard associate (see&nbsp;<Ref Oper="StandardAssociate"/>)
##  of the least common multiples.
##  <P/>
##  A least common multiple of the elements <M>r_1, r_2, \ldots</M> of the
##  ring <M>R</M> is an element <M>m</M> that is a multiple of <M>r_1, r_2, \ldots</M>,
##  and every other multiple of these elements is a multiple of <M>m</M>.
##  <P/>
##  Note that this in particular implies the following:
##  For the zero element <M>z</M> of <A>R</A>, we have
##  <C>Lcm( <A>r</A>, </C><M>z</M><C> ) = Lcm( </C><M>z</M><C>, <A>r</A> )
##  = StandardAssociate( <A>r</A> )</C>
##  and <C>Lcm( </C><M>z</M><C>, </C><M>z</M><C> ) = </C><M>z</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Lcm" );


#############################################################################
##
#O  LcmOp( [<R>, ]<r>, <s> )
##
##  <#GAPDoc Label="LcmOp">
##  <ManSection>
##  <Oper Name="LcmOp" Arg='[R, ]r, s'/>
##
##  <Description>
##  <Ref Oper="LcmOp"/> is the operation to compute the least common multiple
##  of two ring elements <A>r</A>, <A>s</A> in the ring <A>R</A>
##  or in their default ring, respectively.
##  <P/>
##  The default methods for this uses the equality
##  <M>lcm( m, n ) = m*n / gcd( m, n )</M> (see&nbsp;<Ref Oper="GcdOp"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LcmOp",
    [ IsUniqueFactorizationRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  PadicValuation( <r>, <p> )
##
##  <#GAPDoc Label="PadicValuation">
##  <ManSection>
##  <Oper Name="PadicValuation" Arg='r, p'/>
##
##  <Description>
##  <Ref Oper="PadicValuation"/> is the operation to compute
##  the <A>p</A>-adic valuation of a ring element <A>r</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PadicValuation", [ IsRingElement, IsPosInt ] );
