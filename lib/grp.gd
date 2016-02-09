#############################################################################
##
#W  grp.gd                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                             & Bettina Eick
#W                                                           & Heiko Theißen
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations of operations for groups.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{grp}">
##  Unless explicitly declared otherwise, all subgroup series are descending.
##  That is they are stored in decreasing order.
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[2]{grp}">
##  If a group <M>U</M> is created as a subgroup of another group <M>G</M>,
##  <M>G</M> becomes the parent of <M>U</M>.
##  There is no <Q>universal</Q> parent group,
##  parent-child chains can be arbitrary long.
##  &GAP; stores the result of some operations
##  (such as <Ref Func="Normalizer" Label="for two groups"/>)
##  with the parent as an attribute.
##  <#/GAPDoc>
##


#############################################################################
##
#V  InfoGroup
##
##  <#GAPDoc Label="InfoGroup">
##  <ManSection>
##  <InfoClass Name="InfoGroup"/>
##
##  <Description>
##  is the info class for the generic group theoretic functions
##  (see&nbsp;<Ref Sect="Info Functions"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoGroup" );


#############################################################################
##
#C  IsGroup( <obj> )
##
##  <#GAPDoc Label="IsGroup">
##  <ManSection>
##  <Filt Name="IsGroup" Arg='obj' Type='Category'/>
##
##  <Description>
##  A group is a magma-with-inverses (see&nbsp;<Ref Func="IsMagmaWithInverses"/>)
##  and associative (see&nbsp;<Ref Func="IsAssociative"/>) multiplication.
##  <P/>
##  <C>IsGroup</C> tests whether the object <A>obj</A> fulfills these conditions,
##  it does <E>not</E> test whether <A>obj</A> is a set of elements that forms a group
##  under multiplication;
##  use <Ref Func="AsGroup"/> if you want to perform such a test.
##  (See&nbsp;<Ref Sect="Categories"/> for details about categories.)
##  <Example><![CDATA[
##  gap> IsGroup(g);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsGroup", IsMagmaWithInverses and IsAssociative );

InstallTrueMethod( IsFiniteOrderElementCollection, IsGroup and IsFinite );


#############################################################################
##
#A  GeneratorsOfGroup( <G> )
##
##  <#GAPDoc Label="GeneratorsOfGroup">
##  <ManSection>
##  <Attr Name="GeneratorsOfGroup" Arg='G'/>
##
##  <Description>
##  returns a list of generators of the group <A>G</A>.
##  If <A>G</A> has been created by the command
##  <Ref Func="GroupWithGenerators"/> with argument <A>gens</A>,
##  then the list returned by <Ref Attr="GeneratorsOfGroup"/>
##  will be equal to <A>gens</A>. For such a group, each generator 
##  can also be accessed using the <C>.</C> operator 
##  (see <Ref Attr="GeneratorsOfDomain"/>): for a positive integer
##  <M>i</M>, <C><A>G</A>.i</C> returns the <M>i</M>-th element of
##  the list returned by <Ref Attr="GeneratorsOfGroup"/>. Moreover,
##  if <A>G</A> is a free group, and <C>name</C> is the name of a 
##  generator of <A>G</A> then <C><A>G</A>.name</C> also returns 
##  this generator. 
##  <Example><![CDATA[
##  gap> g:=GroupWithGenerators([(1,2,3,4),(1,2)]);
##  Group([ (1,2,3,4), (1,2) ])
##  gap> GeneratorsOfGroup(g);
##  [ (1,2,3,4), (1,2) ]
##  ]]></Example>
##  <P/>
##  While in this example &GAP; displays the group via the generating set
##  stored in the attribute <Ref Func="GeneratorsOfGroup"/>,
##  the methods installed for <Ref Func="View"/> will in general display only
##  some information about the group which may even be just the fact that it
##  is a group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "GeneratorsOfGroup", GeneratorsOfMagmaWithInverses );


#############################################################################
##
#O  GroupString( <G>, <name> )
##
##  <ManSection>
##  <Oper Name="GroupString" Arg='G, name'/>
##
##  <Description>
##  returns a short string (usually less than one line) with information
##  about the group <A>G</A>. <A>name</A> is a display name if the group <A>G</A> does
##  not have one.
##  </Description>
##  </ManSection>
##
DeclareOperation( "GroupString", [IsGroup,IsString] );


#############################################################################
##
#P  IsCyclic( <G> )
##
##  <#GAPDoc Label="IsCyclic">
##  <ManSection>
##  <Prop Name="IsCyclic" Arg='G'/>
##
##  <Description>
##  A group is <E>cyclic</E> if it can be generated by one element.
##  For a cyclic group, one can compute a generating set consisting of only
##  one element using <Ref Func="MinimalGeneratingSet"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsCyclic", IsGroup );

InstallSubsetMaintenance( IsCyclic, IsGroup and IsCyclic, IsGroup );

InstallFactorMaintenance( IsCyclic,
    IsGroup and IsCyclic, IsObject, IsGroup );

InstallTrueMethod( IsCyclic, IsGroup and IsTrivial );

InstallTrueMethod( IsCommutative, IsGroup and IsCyclic );


#############################################################################
##
#P  IsElementaryAbelian( <G> )
##
##  <#GAPDoc Label="IsElementaryAbelian">
##  <ManSection>
##  <Prop Name="IsElementaryAbelian" Arg='G'/>
##
##  <Description>
##  A group <A>G</A> is elementary abelian if it is commutative and if there is a
##  prime <M>p</M> such that the order of each element in <A>G</A> divides <M>p</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsElementaryAbelian", IsGroup );

InstallSubsetMaintenance( IsElementaryAbelian,
    IsGroup and IsElementaryAbelian, IsGroup );

InstallFactorMaintenance( IsElementaryAbelian,
    IsGroup and IsElementaryAbelian, IsObject, IsGroup );

InstallTrueMethod( IsElementaryAbelian, IsGroup and IsTrivial );

InstallTrueMethod( IsCommutative, IsGroup and IsElementaryAbelian );


#############################################################################
##
#P  IsFinitelyGeneratedGroup( <G> )
##
##  <#GAPDoc Label="IsFinitelyGeneratedGroup">
##  <ManSection>
##  <Prop Name="IsFinitelyGeneratedGroup" Arg='G'/>
##
##  <Description>
##  tests whether the group <A>G</A> can be generated by a finite number of
##  generators. (This property is mainly used to obtain finiteness
##  conditions.)
##  <P/>
##  Note that this is a pure existence statement. Even if a group is known
##  to be generated by a finite number of elements, it can be very hard or
##  even impossible to obtain such a generating set if it is not known.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFinitelyGeneratedGroup", IsGroup );

InstallFactorMaintenance( IsFinitelyGeneratedGroup,
    IsGroup and IsFinitelyGeneratedGroup, IsObject, IsGroup );

InstallTrueMethod( IsFinitelyGeneratedGroup, IsGroup and IsFinite );

#############################################################################
##
#P  IsSubsetLocallyFiniteGroup(<U>) . . . . test if a group is locally finite
##
##  <#GAPDoc Label="IsSubsetLocallyFiniteGroup">
##  <ManSection>
##  <Prop Name="IsSubsetLocallyFiniteGroup" Arg='U'/>
##
##  <Description>
##  A group is called locally finite if every finitely generated subgroup is
##  finite. This property checks whether the group <A>U</A> is a subset of a
##  locally finite group. This is used to check whether finite generation
##  will imply finiteness, as it does for example for permutation groups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSubsetLocallyFiniteGroup", IsGroup );

# this true method will enforce that many groups are finite, which is needed
# implicitly
InstallTrueMethod( IsFinite, IsFinitelyGeneratedGroup and IsGroup
                             and IsSubsetLocallyFiniteGroup );

InstallTrueMethod( IsSubsetLocallyFiniteGroup, IsFinite and IsGroup );

InstallSubsetMaintenance( IsSubsetLocallyFiniteGroup,
    IsGroup and IsSubsetLocallyFiniteGroup, IsGroup );


#############################################################################
##
#M  IsSubsetLocallyFiniteGroup( <G> ) . . . . . . . . . .  for magmas of FFEs
##
InstallTrueMethod( IsSubsetLocallyFiniteGroup, IsFFECollection and IsMagma );


#############################################################################
##
##  <#GAPDoc Label="[3]{grp}">
##  The following filters and operations indicate capabilities of &GAP;.
##  They can be used in the method selection or algorithms to check whether
##  it is feasible to compute certain operations for a given group.
##  In general, they return <K>true</K> if good algorithms for the given arguments
##  are available in &GAP;.
##  An answer <K>false</K> indicates that no method for this group may exist,
##  or that the existing methods might run into problems.
##  <P/>
##  Typical examples when this might happen is with finitely presented
##  groups, for which many of the methods cannot be guaranteed to succeed in
##  all situations.
##  <P/>
##  The willingness of &GAP; to perform certain operations may change,
##  depending on which further information is known about the arguments.
##  Therefore the filters used are not implemented as properties but as
##  <Q>other filters</Q> (see&nbsp;<Ref Sect="Properties"/> and&nbsp;<Ref Sect="Other Filters"/>).
##  <#/GAPDoc>
##


#############################################################################
##
#F  CanEasilyTestMembership( <G> )
##
##  <#GAPDoc Label="CanEasilyTestMembership">
##  <ManSection>
##  <Filt Name="CanEasilyTestMembership" Arg='G'/>
##
##  <Description>
##  This filter indicates whether &GAP; can test membership of elements in
##  the group <A>G</A>
##  (via the operation <Ref Oper="\in" Label="for a collection"/>)
##  in reasonable time.
##  It is used by the method selection to decide whether an algorithm
##  that relies on membership tests may be used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "CanEasilyTestMembership" );


#############################################################################
##
#F  CanEasilyComputeWithIndependentGensAbelianGroup( <G> )
##
##  <#GAPDoc Label="CanEasilyComputeWithIndependentGensAbelianGroup">
##  <ManSection>
##  <Filt Name="CanEasilyComputeWithIndependentGensAbelianGroup" Arg='G'/>
##
##  <Description>
##  This filter indicates whether &GAP; can in reasonable time compute
##  independent abelian generators of the group <A>G</A>
##  (via <Ref Func="IndependentGeneratorsOfAbelianGroup"/>) and
##  then can decompose arbitrary group elements with respect to these
##  generators using <Ref Func="IndependentGeneratorExponents"/>.
##  
##  It is used by the method selection to decide whether an algorithm
##  that relies on these two operations may be used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "CanEasilyComputeWithIndependentGensAbelianGroup" );


#############################################################################
##
#F  CanComputeSizeAnySubgroup( <G> )
##
##  <#GAPDoc Label="CanComputeSizeAnySubgroup">
##  <ManSection>
##  <Filt Name="CanComputeSizeAnySubgroup" Arg='G'/>
##
##  <Description>
##  This filter indicates whether &GAP; can easily compute the size of any
##  subgroup of the group <A>G</A>.
##  (This is for example advantageous if one can test that a stabilizer index
##  equals the length of the orbit computed so far to stop early.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "CanComputeSizeAnySubgroup" );

InstallTrueMethod(CanEasilyTestMembership,
  IsFinite and CanComputeSizeAnySubgroup);
InstallTrueMethod(CanComputeSize,CanComputeSizeAnySubgroup);

InstallTrueMethod( CanComputeSize, IsTrivial );

# these implications can create problems with some fp groups. Therefore we
# are a bit less eager
#InstallTrueMethod( CanComputeSizeAnySubgroup, IsTrivial );
#InstallTrueMethod( CanEasilyTestMembership, IsTrivial );


#############################################################################
##
#F  CanComputeIndex( <G>, <H> )
##
##  <#GAPDoc Label="CanComputeIndex">
##  <ManSection>
##  <Oper Name="CanComputeIndex" Arg='G, H'/>
##
##  <Description>
##  This function indicates whether the index <M>[<A>G</A>:<A>H</A>]</M>
##  (which might be <Ref Var="infinity"/>) can be computed.
##  It assumes that <M><A>H</A> \leq <A>G</A></M>
##  (see <Ref Func="CanComputeIsSubset"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CanComputeIndex", [IsGroup,IsGroup] );


#############################################################################
##
#P  KnowsHowToDecompose( <G>[, <gens>] )
##
##  <#GAPDoc Label="KnowsHowToDecompose">
##  <ManSection>
##  <Prop Name="KnowsHowToDecompose" Arg='G[, gens]'/>
##
##  <Description>
##  Tests whether the group <A>G</A> can decompose elements in the generators
##  <A>gens</A>.
##  If <A>gens</A> is not given it tests, whether it can decompose in the
##  generators given in the <Ref Func="GeneratorsOfGroup"/> value of
##  <A>G</A>.
##  <P/>
##  This property can be used for example to check whether a
##  group homomorphism by images
##  (see <Ref Func="GroupHomomorphismByImages"/>) can be reasonably defined
##  from this group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "KnowsHowToDecompose", IsGroup );
DeclareOperation( "KnowsHowToDecompose", [ IsGroup, IsList ] );


#############################################################################
##
#P  IsPGroup( <G> ) . . . . . . . . . . . . . . . . .  is a group a p-group ?
##
##  <#GAPDoc Label="IsPGroup">
##  <ManSection>
##  <Prop Name="IsPGroup" Arg='G'/>
##
##  <Description>
##  <Index Key="p-group"><M>p</M>-group</Index>
##  A <E><M>p</M>-group</E> is a finite group whose order
##  (see&nbsp;<Ref Func="Size"/>) is of the form <M>p^n</M> for a prime
##  integer <M>p</M> and a nonnegative integer <M>n</M>.
##  <Ref Prop="IsPGroup"/> returns <K>true</K> if <A>G</A> is a
##  <M>p</M>-group, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPGroup", IsGroup );

InstallSubsetMaintenance( IsPGroup,
    IsGroup and IsPGroup, IsGroup );

InstallFactorMaintenance( IsPGroup,
    IsGroup and IsPGroup, IsObject, IsGroup );

InstallTrueMethod( IsPGroup, IsGroup and IsTrivial );
InstallTrueMethod( IsPGroup, IsGroup and IsElementaryAbelian );


#############################################################################
##
#A  PrimePGroup( <G> )
##
##  <#GAPDoc Label="PrimePGroup">
##  <ManSection>
##  <Attr Name="PrimePGroup" Arg='G'/>
##
##  <Description>
##  If <A>G</A> is a nontrivial <M>p</M>-group
##  (see&nbsp;<Ref Func="IsPGroup"/>), <Ref Func="PrimePGroup"/> returns
##  the prime integer <M>p</M>;
##  if <A>G</A> is trivial then <Ref Func="PrimePGroup"/> returns
##  <K>fail</K>. 
##  Otherwise an error is issued.
##  <P/>
##  (One should avoid a common error of writing 
##  <C>if IsPGroup(g) then ... PrimePGroup(g) ...</C> where the code 
##  represented by dots assumes that <C>PrimePGroup(g)</C> is an integer.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PrimePGroup", IsPGroup );


#############################################################################
##
#A  PClassPGroup( <G> )
##
##  <#GAPDoc Label="PClassPGroup">
##  <ManSection>
##  <Attr Name="PClassPGroup" Arg='G'/>
##
##  <Description>
##  The <M>p</M>-class of a <M>p</M>-group <A>G</A>
##  (see&nbsp;<Ref Func="IsPGroup"/>)
##  is the length of the lower <M>p</M>-central series
##  (see&nbsp;<Ref Func="PCentralSeries"/>) of <A>G</A>.
##  If <A>G</A> is not a <M>p</M>-group then an error is issued.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PClassPGroup", IsPGroup );


#############################################################################
##
#A  RankPGroup( <G> )
##
##  <#GAPDoc Label="RankPGroup">
##  <ManSection>
##  <Attr Name="RankPGroup" Arg='G'/>
##
##  <Description>
##  For a <M>p</M>-group <A>G</A> (see&nbsp;<Ref Func="IsPGroup"/>),
##  <Ref Func="RankPGroup"/> returns the <E>rank</E> of <A>G</A>,
##  which is defined as the minimal size of a generating system of <A>G</A>.
##  If <A>G</A> is not a <M>p</M>-group then an error is issued.
##  <Example><![CDATA[
##  gap> h:=Group((1,2,3,4),(1,3));;
##  gap> PClassPGroup(h);
##  2
##  gap> RankPGroup(h);
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RankPGroup", IsPGroup );


#############################################################################
##
#P  IsNilpotentGroup( <G> )
##
##  <#GAPDoc Label="IsNilpotentGroup">
##  <ManSection>
##  <Prop Name="IsNilpotentGroup" Arg='G'/>
##
##  <Description>
##  A group is <E>nilpotent</E> if the lower central series
##  (see&nbsp;<Ref Func="LowerCentralSeriesOfGroup"/> for a definition)
##  reaches the trivial subgroup in a finite number of steps.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsNilpotentGroup", IsGroup );

InstallSubsetMaintenance( IsNilpotentGroup,
    IsGroup and IsNilpotentGroup, IsGroup );

InstallFactorMaintenance( IsNilpotentGroup,
    IsGroup and IsNilpotentGroup, IsObject, IsGroup );

InstallTrueMethod( IsNilpotentGroup, IsGroup and IsCommutative );

InstallTrueMethod( IsNilpotentGroup, IsGroup and IsPGroup );


#############################################################################
##
#P  IsPerfectGroup( <G> )
##
##  <#GAPDoc Label="IsPerfectGroup">
##  <ManSection>
##  <Prop Name="IsPerfectGroup" Arg='G'/>
##
##  <Description>
##  A group is <E>perfect</E> if it equals its derived subgroup
##  (see&nbsp;<Ref Func="DerivedSubgroup"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPerfectGroup", IsGroup );

InstallFactorMaintenance( IsPerfectGroup,
    IsGroup and IsPerfectGroup, IsObject, IsGroup );


#############################################################################
##
#P  IsSporadicSimpleGroup( <G> )
##
##  <ManSection>
##  <Prop Name="IsSporadicSimpleGroup" Arg='G'/>
##
##  <Description>
##  A group is <E>sporadic simple</E> if it is one of the
##  <M>26</M> sporadic simple groups;
##  these are (in &ATLAS; notation, see&nbsp;<Cite Key="CCN85"/>)
##  <M>M_{11}</M>, <M>M_{12}</M>, <M>J_1</M>, <M>M_{22}</M>, <M>J_2</M>,
##  <M>M_{23}</M>, <M>HS</M>, <M>J_3</M>, <M>M_{24}</M>, <M>M^cL</M>,
##  <M>He</M>, <M>Ru</M>, <M>Suz</M>, <M>O'N</M>, <M>Co_3</M>, <M>Co_2</M>,
##  <M>Fi_{22}</M>, <M>HN</M>, <M>Ly</M>, <M>Th</M>, <M>Fi_{23}</M>,
##  <M>Co_1</M>, <M>J_4</M>, <M>Fi_{24}'</M>, <M>B</M>, and <M>M</M>.
##  <P/>
##  This property can be used for example for selecting the character tables
##  of the sporadic simple groups,
##  see the documentation of the &GAP; package <Package>CTblLib</Package>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsSporadicSimpleGroup", IsGroup );

InstallIsomorphismMaintenance( IsSporadicSimpleGroup,
    IsGroup and IsSporadicSimpleGroup, IsGroup );


#############################################################################
##
#P  IsSimpleGroup( <G> )
##
##  <#GAPDoc Label="IsSimpleGroup">
##  <ManSection>
##  <Prop Name="IsSimpleGroup" Arg='G'/>
##
##  <Description>
##  A group is <E>simple</E> if it is nontrivial and has no nontrivial normal
##  subgroups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSimpleGroup", IsGroup );

InstallIsomorphismMaintenance( IsSimpleGroup,
    IsGroup and IsSimpleGroup, IsGroup );

InstallTrueMethod( IsSimpleGroup, IsGroup and IsSporadicSimpleGroup );


#############################################################################
##
#P  IsAlmostSimpleGroup( <G> )
##
##  <#GAPDoc Label="IsAlmostSimpleGroup">
##  <ManSection>
##  <Prop Name="IsAlmostSimpleGroup" Arg='G'/>
##
##  <Description>
##  A group <A>G</A> is <E>almost simple</E> if a nonabelian simple group
##  <M>S</M> exists such that <A>G</A> is isomorphic to a subgroup of the
##  automorphism group of <M>S</M> that contains all inner automorphisms of
##  <M>S</M>.
##  <P/>
##  Equivalently, <A>G</A> is almost simple if and only if it has a unique
##  minimal normal subgroup <M>N</M> and if <M>N</M> is a nonabelian simple
##  group.
##  <P/>
##  <!--
##  (Note that the centralizer of <M>N</M> in <A>G</A> is trivial because
##  it is a normal subgroup of <A>G</A> that intersects <M>N</M>
##  trivially,
##  so if it would be nontrivial then it would contain another minimal normal
##  subgroup of <A>G</A>.
##  Hence the conjugation action of <A>G</A> on <M>N</M> defines an embedding
##  of <A>G</A> into the automorphism group of <M>N</M>,
##  and this embedding maps <M>N</M> to the group of inner automorphisms of
##  <M>N</M>.)
##  <P/>
##  -->
##  Note that an almost simple group is <E>not</E> defined as an extension of
##  a simple group by outer automorphisms,
##  since we want to exclude extensions of groups of prime order.
##  In particular, a <E>simple</E> group is <E>almost simple</E> if and only
##  if it is nonabelian.
##  <P/>
##  <Example><![CDATA[
##  gap> IsAlmostSimpleGroup( AlternatingGroup( 5 ) );
##  true
##  gap> IsAlmostSimpleGroup( SymmetricGroup( 5 ) );
##  true
##  gap> IsAlmostSimpleGroup( SymmetricGroup( 3 ) );
##  false
##  gap> IsAlmostSimpleGroup( SL( 2, 5 ) );            
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsAlmostSimpleGroup", IsGroup );


#############################################################################
##
#P  IsSupersolvableGroup( <G> )
##
##  <#GAPDoc Label="IsSupersolvableGroup">
##  <ManSection>
##  <Prop Name="IsSupersolvableGroup" Arg='G'/>
##
##  <Description>
##  A finite group is <E>supersolvable</E> if it has a normal series
##  with cyclic factors.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSupersolvableGroup", IsGroup );

InstallSubsetMaintenance( IsSupersolvableGroup,
    IsGroup and IsSupersolvableGroup, IsGroup );

InstallFactorMaintenance( IsSupersolvableGroup,
    IsGroup and IsSupersolvableGroup, IsObject, IsGroup );

InstallTrueMethod( IsSupersolvableGroup, IsNilpotentGroup );


#############################################################################
##
#P  IsMonomialGroup( <G> )
##
##  <#GAPDoc Label="IsMonomialGroup">
##  <ManSection>
##  <Prop Name="IsMonomialGroup" Arg='G'/>
##
##  <Description>
##  A finite group is <E>monomial</E> if every irreducible complex character is
##  induced from a linear character of a subgroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsMonomialGroup", IsGroup );

InstallFactorMaintenance( IsMonomialGroup,
    IsGroup and IsMonomialGroup, IsObject, IsGroup );

InstallTrueMethod( IsMonomialGroup, IsSupersolvableGroup and IsFinite );


#############################################################################
##
#P  IsSolvableGroup( <G> )
##
##  <#GAPDoc Label="IsSolvableGroup">
##  <ManSection>
##  <Prop Name="IsSolvableGroup" Arg='G'/>
##
##  <Description>
##  A group is <E>solvable</E> if the derived series
##  (see&nbsp;<Ref Func="DerivedSeriesOfGroup"/> for a definition)
##  reaches the trivial subgroup in a finite number of steps.
##  <P/>
##  For finite groups this is the same as being polycyclic
##  (see&nbsp;<Ref Func="IsPolycyclicGroup"/>),
##  and each polycyclic group is solvable,
##  but there are infinite solvable groups that are not polycyclic.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSolvableGroup", IsGroup );

InstallSubsetMaintenance( IsSolvableGroup,
    IsGroup and IsSolvableGroup, IsGroup );

InstallFactorMaintenance( IsSolvableGroup,
    IsGroup and IsSolvableGroup, IsObject, IsGroup );

##  For finite groups, supersolvability implies monomiality, and this implies
##  solvability.
##  But monomiality is defined only for finite groups, for the general case
##  we need the direct implication from supersolvability to solvability.
InstallTrueMethod( IsSolvableGroup, IsMonomialGroup );
InstallTrueMethod( IsSolvableGroup, IsSupersolvableGroup );


#############################################################################
##
#P  IsPolycyclicGroup( <G> )
##
##  <#GAPDoc Label="IsPolycyclicGroup">
##  <ManSection>
##  <Prop Name="IsPolycyclicGroup" Arg='G'/>
##
##  <Description>
##  A group is polycyclic if it has a subnormal series with cyclic factors.
##  For finite groups this is the same as if the group is solvable
##  (see&nbsp;<Ref Func="IsSolvableGroup"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPolycyclicGroup", IsGroup );
InstallTrueMethod( IsSolvableGroup, IsPolycyclicGroup );
InstallTrueMethod( IsPolycyclicGroup, IsSolvableGroup and IsFinite );
InstallTrueMethod( IsPolycyclicGroup, 
                     IsNilpotentGroup and IsFinitelyGeneratedGroup );

#############################################################################
##
#A  AbelianInvariants( <G> )
##
##  <#GAPDoc Label="AbelianInvariants:grp">
##  <ManSection>
##  <Attr Name="AbelianInvariants" Arg='G'/>
##
##  <Description>
##  <Index Subkey="for groups" Key="AbelianInvariants">
##  <C>AbelianInvariants</C></Index>
##  returns the abelian invariants (also sometimes called primary
##  decomposition) of the commutator factor group of the
##  group <A>G</A>. These are given as a list of prime-powers or zeroes and
##  describe the structure of <M><A>G</A>/<A>G</A>'</M> as a direct product
##  of cyclic groups of prime power (or infinite) order.
##  <P/>
##  (See <Ref Func="IndependentGeneratorsOfAbelianGroup"/> to obtain actual
##  generators).
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2),(5,6));;
##  gap> AbelianInvariants(g);
##  [ 2, 2 ]
##  gap> h:=FreeGroup(2);;h:=h/[h.1^3];;
##  gap> AbelianInvariants(h);
##  [ 0, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AbelianInvariants", IsGroup );

#############################################################################
##
#A  IsInfiniteAbelianizationGroup( <G> )
##
##  <#GAPDoc Label="IsInfiniteAbelianizationGroup:grp">
##  <ManSection>
##  <Attr Name="IsInfiniteAbelianizationGroup" Arg='G'/>
##
##  <Description>
##  <Index Subkey="for groups" Key="IsInfiniteAbelianizationGroup">
##  <C>IsInfiniteAbelianizationGroup</C></Index>
##  returns true if the commutator factor group <M><A>G</A>/<A>G</A>'</M> is
##  infinite. This might be done without computing the full structure of the
##  commutator factor group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsInfiniteAbelianizationGroup", IsGroup );


#############################################################################
##
#A  AsGroup( <D> )  . . . . . . . . . . . . . collection <D>, viewed as group
##
##  <#GAPDoc Label="AsGroup">
##  <ManSection>
##  <Attr Name="AsGroup" Arg='D'/>
##
##  <Description>
##  if the elements of the collection <A>D</A> form a group the command returns
##  this group, otherwise it returns <K>fail</K>.
##  <Example><![CDATA[
##  gap> AsGroup([(1,2)]);
##  fail
##  gap> AsGroup([(),(1,2)]);
##  Group([ (1,2) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsGroup", IsCollection );


#############################################################################
##
#A  ChiefSeries( <G> )
##
##  <#GAPDoc Label="ChiefSeries">
##  <ManSection>
##  <Attr Name="ChiefSeries" Arg='G'/>
##
##  <Description>
##  is a series of normal subgroups of <A>G</A> which cannot be refined
##  further.
##  That is there is no normal subgroup <M>N</M> of <A>G</A> with
##  <M>U_i > N > U_{{i+1}}</M>.
##  This attribute returns <E>one</E> chief series (of potentially many
##  possibilities).
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> ChiefSeries(g);
##  [ Group([ (1,2,3,4), (1,2) ]), 
##    Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]), 
##    Group([ (1,4)(2,3), (1,3)(2,4) ]), Group(()) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ChiefSeries", IsGroup );


#############################################################################
##
#O  ChiefSeriesUnderAction( <H>, <G> )
##
##  <#GAPDoc Label="ChiefSeriesUnderAction">
##  <ManSection>
##  <Oper Name="ChiefSeriesUnderAction" Arg='H, G'/>
##
##  <Description>
##  returns a series of normal subgroups of <A>G</A> which are invariant under
##  <A>H</A> such that the series cannot be refined any further.
##  <A>G</A> must be a subgroup of <A>H</A>.
##  This attribute returns <E>one</E> such series (of potentially many
##  possibilities).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ChiefSeriesUnderAction", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ChiefSeriesThrough( <G>, <l> )
##
##  <#GAPDoc Label="ChiefSeriesThrough">
##  <ManSection>
##  <Oper Name="ChiefSeriesThrough" Arg='G, l'/>
##
##  <Description>
##  is a chief series of the group <A>G</A> going through
##  the normal subgroups in the list <A>l</A>, which must be a list of normal
##  subgroups of <A>G</A> contained in each other, sorted by descending size.
##  This attribute returns <E>one</E>
##  chief series (of potentially many possibilities).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ChiefSeriesThrough", [ IsGroup, IsList ] );


#############################################################################
##
#A  CommutatorFactorGroup( <G> )
##
##  <#GAPDoc Label="CommutatorFactorGroup">
##  <ManSection>
##  <Attr Name="CommutatorFactorGroup" Arg='G'/>
##
##  <Description>
##  computes the commutator factor group <M><A>G</A>/<A>G</A>'</M> of the group <A>G</A>.
##  <Example><![CDATA[
##  gap> CommutatorFactorGroup(g);
##  Group([ f1 ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CommutatorFactorGroup", IsGroup );


#############################################################################
##
#A  CompositionSeries( <G> )
##
##  <#GAPDoc Label="CompositionSeries">
##  <ManSection>
##  <Attr Name="CompositionSeries" Arg='G'/>
##
##  <Description>
##  A composition series is a subnormal series which cannot be refined.
##  This attribute returns <E>one</E> composition series (of potentially many
##  possibilities).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CompositionSeries", IsGroup );
#T and for module?


#############################################################################
##
#F  DisplayCompositionSeries( <G> )
##
##  <#GAPDoc Label="DisplayCompositionSeries">
##  <ManSection>
##  <Func Name="DisplayCompositionSeries" Arg='G'/>
##
##  <Description>
##  Displays a composition series of <A>G</A> in a nice way, identifying the
##  simple factors.
##  <Example><![CDATA[
##  gap> CompositionSeries(g);
##  [ Group([ (3,4), (2,4,3), (1,4)(2,3), (1,3)(2,4) ]), 
##    Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]), 
##    Group([ (1,4)(2,3), (1,3)(2,4) ]), Group([ (1,3)(2,4) ]), Group(()) 
##   ]
##  gap> DisplayCompositionSeries(Group((1,2,3,4,5,6,7),(1,2)));
##  G (2 gens, size 5040)
##   | Z(2)
##  S (5 gens, size 2520)
##   | A(7)
##  1 (0 gens, size 1)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DisplayCompositionSeries" );


#############################################################################
##
#A  ConjugacyClasses( <G> )
##
##  <#GAPDoc Label="ConjugacyClasses:grp">
##  <ManSection>
##  <Attr Name="ConjugacyClasses" Arg='G' Label="attribute"/>
##
##  <Description>
##  returns the conjugacy classes of elements of <A>G</A> as a list of
##  class objects of <A>G</A>
##  (see&nbsp;<Ref Func="ConjugacyClass"/> for details). 
##  It is guaranteed that the class of the
##  identity is in the first position, the further arrangement depends on
##  the method chosen (and might be different for equal but not identical
##  groups).
##  <P/>
##  For very small groups (of size up to 500) the classes will be computed
##  by the conjugation action of <A>G</A> on itself
##  (see&nbsp;<Ref Func="ConjugacyClassesByOrbits"/>).
##  This can be deliberately switched off using the <Q><C>noaction</C></Q>
##  option shown below.
##  <P/>
##  For solvable groups, the default method to compute the classes is by
##  homomorphic lift
##  (see section&nbsp;<Ref Sect="Conjugacy Classes in Solvable Groups"/>).
##  <P/>
##  For other groups the method of <Cite Key="HulpkeClasses"/> is employed.
##  <P/>
##  <Ref Attr="ConjugacyClasses" Label="attribute"/> supports the following
##  options that can be used to modify this strategy:
##  <List>
##  <Mark><C>random</C></Mark>
##  <Item>
##    The classes are computed by random search.
##    See <Ref Func="ConjugacyClassesByRandomSearch"/> below.
##  </Item>
##  <Mark><C>action</C></Mark>
##  <Item>
##    The classes are computed by action of <A>G</A> on itself.
##    See <Ref Func="ConjugacyClassesByOrbits"/> below.
##  </Item>
##  <Mark><C>noaction</C></Mark>
##  <Item>
##    Even for small groups
##    <Ref Func="ConjugacyClassesByOrbits"/>
##    is not used as a default. This can be useful if the elements of the
##    group use a lot of memory.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(4);;
##  gap> cl:=ConjugacyClasses(g);
##  [ ()^G, (1,2)^G, (1,2)(3,4)^G, (1,2,3)^G, (1,2,3,4)^G ]
##  gap> Representative(cl[3]);Centralizer(cl[3]);
##  (1,2)(3,4)
##  Group([ (1,2), (1,3)(2,4), (3,4) ])
##  gap> Size(Centralizer(cl[5]));
##  4
##  gap> Size(cl[2]);
##  6
##  ]]></Example>
##  <P/>
##  In general, you will not need to have to influence the method, but simply
##  call <Ref Func="ConjugacyClasses" Label="attribute"/>
##  &ndash;&GAP; will try to select a suitable method on its own.
##  The method specifications are provided here mainly for expert use.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConjugacyClasses", IsGroup );


#############################################################################
##
#A  ConjugacyClassesMaximalSubgroups( <G> )
##
##  <#GAPDoc Label="ConjugacyClassesMaximalSubgroups">
##  <ManSection>
##  <Attr Name="ConjugacyClassesMaximalSubgroups" Arg='G'/>
##
##  <Description>
##  returns the conjugacy classes of maximal subgroups of <A>G</A>.
##  Representatives of the classes can be computed directly by
##  <Ref Func="MaximalSubgroupClassReps"/>.
##  <Example><![CDATA[
##  gap> ConjugacyClassesMaximalSubgroups(g);
##  [ AlternatingGroup( [ 1 .. 4 ] )^G, Group( [ (1,2,3), (1,2) ] )^G, 
##    Group( [ (1,2), (3,4), (1,3)(2,4) ] )^G ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConjugacyClassesMaximalSubgroups", IsGroup );


#############################################################################
##
#A  MaximalSubgroups( <G> )
##
##  <#GAPDoc Label="MaximalSubgroups">
##  <ManSection>
##  <Attr Name="MaximalSubgroups" Arg='G'/>
##
##  <Description>
##  returns a list of all maximal subgroups of <A>G</A>. This may take up much
##  space, therefore the command should be avoided if possible. See
##  <Ref Func="ConjugacyClassesMaximalSubgroups"/>.
##  <Example><![CDATA[
##  gap> MaximalSubgroups(Group((1,2,3),(1,2)));
##  [ Group([ (1,2,3) ]), Group([ (2,3) ]), Group([ (1,2) ]), 
##    Group([ (1,3) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MaximalSubgroups", IsGroup );


#############################################################################
##
#A  MaximalSubgroupClassReps( <G> )
##
##  <#GAPDoc Label="MaximalSubgroupClassReps">
##  <ManSection>
##  <Attr Name="MaximalSubgroupClassReps" Arg='G'/>
##
##  <Description>
##  returns a list of conjugacy representatives of the maximal subgroups
##  of <A>G</A>.
##  <Example><![CDATA[
##  gap> MaximalSubgroupClassReps(g);
##  [ Alt( [ 1 .. 4 ] ), Group([ (1,2,3), (1,2) ]), 
##    Group([ (1,2), (3,4), (1,3)(2,4) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("MaximalSubgroupClassReps",IsGroup);

#############################################################################
##
#F  MaximalPropertySubgroups( <G>, <prop> )
##
##  <#GAPDoc Label="MaximalPropertySubgroups">
##  <ManSection>
##  <Func Name="MaximalPropertySubgroups" Arg='G,prop'/>
##
##  <Description>
##  For a function <A>prop</A> that tests for a property that persists
##  under taking subgroups, this function returns conjugacy class
##  representatives of the subgroups of <A>G</A> that are maximal subject to
##  this property. 
##  <Example><![CDATA[
##  gap> max:=MaximalPropertySubgroups(AlternatingGroup(8),IsNilpotent);;
##  gap> List(max,Size);
##  [ 64, 15, 12, 9, 7, 6 ]
##  gap> max:=MaximalSolvableSubgroups(AlternatingGroup(10));;
##  gap> List(max,Size);
##  [ 1152, 864, 648, 576, 400, 384, 320, 216, 126, 240, 168, 120 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MaximalPropertySubgroups");
DeclareGlobalFunction("MaximalSolvableSubgroups");


#############################################################################
##
#A  PerfectResiduum( <G> )
##
##  <#GAPDoc Label="PerfectResiduum">
##  <ManSection>
##  <Attr Name="PerfectResiduum" Arg='G'/>
##
##  <Description>
##  is the smallest normal subgroup of <A>G</A> that has a solvable factor group.
##  <Example><![CDATA[
##  gap> PerfectResiduum(Group((1,2,3,4,5),(1,2)));
##  Group([ (1,3,2), (1,4,3), (1,5,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PerfectResiduum", IsGroup );


#############################################################################
##
#A  RepresentativesPerfectSubgroups( <G> )
#A  RepresentativesSimpleSubgroups( <G> )
##
##  <#GAPDoc Label="RepresentativesPerfectSubgroups">
##  <ManSection>
##  <Attr Name="RepresentativesPerfectSubgroups" Arg='G'/>
##  <Attr Name="RepresentativesSimpleSubgroups" Arg='G'/>
##
##  <Description>
##  returns a list of conjugacy representatives of perfect (respectively
##  simple) subgroups of <A>G</A>.
##  This uses the library of perfect groups
##  (see <Ref Func="PerfectGroup" Label="for group order (and index)"/>),
##  thus it will issue an error if the library is insufficient to determine
##  all perfect subgroups.
##  <Example><![CDATA[
##  gap> m11:=TransitiveGroup(11,6);
##  M(11)
##  gap> r:=RepresentativesPerfectSubgroups(m11);;
##  gap> List(r,Size);
##  [ 60, 60, 360, 660, 7920, 1 ]
##  gap> List(r,StructureDescription);
##  [ "A5", "A5", "A6", "PSL(2,11)", "M11", "1" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RepresentativesPerfectSubgroups", IsGroup );
DeclareAttribute( "RepresentativesSimpleSubgroups", IsGroup );


#############################################################################
##
#A  ConjugacyClassesPerfectSubgroups( <G> )
##
##  <#GAPDoc Label="ConjugacyClassesPerfectSubgroups">
##  <ManSection>
##  <Attr Name="ConjugacyClassesPerfectSubgroups" Arg='G'/>
##
##  <Description>
##  returns a list of the conjugacy classes of perfect subgroups of <A>G</A>.
##  (see <Ref Func="RepresentativesPerfectSubgroups"/>.)
##  <Example><![CDATA[
##  gap> r := ConjugacyClassesPerfectSubgroups(m11);;
##  gap> List(r, x -> StructureDescription(Representative(x)));
##  [ "A5", "A5", "A6", "PSL(2,11)", "M11", "1" ]
##  gap> SortedList( List(r,Size) );
##  [ 1, 1, 11, 12, 66, 132 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConjugacyClassesPerfectSubgroups", IsGroup );


#############################################################################
##
#A  ConjugacyClassesSubgroups( <G> )
##
##  <#GAPDoc Label="ConjugacyClassesSubgroups">
##  <ManSection>
##  <Attr Name="ConjugacyClassesSubgroups" Arg='G'/>
##
##  <Description>
##  This attribute returns a list of all conjugacy classes of subgroups of
##  the group <A>G</A>.
##  It also is applicable for lattices of subgroups (see&nbsp;<Ref Func="LatticeSubgroups"/>).
##  The order in which the classes are listed depends on the method chosen by
##  &GAP;.
##  For each class of subgroups, a representative can be accessed using
##  <Ref Attr="Representative"/>.
##  <Example><![CDATA[
##  gap> ConjugacyClassesSubgroups(g);
##  [ Group( () )^G, Group( [ (1,3)(2,4) ] )^G, Group( [ (3,4) ] )^G, 
##    Group( [ (2,4,3) ] )^G, Group( [ (1,4)(2,3), (1,3)(2,4) ] )^G, 
##    Group( [ (3,4), (1,2)(3,4) ] )^G, 
##    Group( [ (1,3,2,4), (1,2)(3,4) ] )^G, Group( [ (3,4), (2,4,3) ] )^G,
##    Group( [ (1,4)(2,3), (1,3)(2,4), (3,4) ] )^G, 
##    Group( [ (1,4)(2,3), (1,3)(2,4), (2,4,3) ] )^G, 
##    Group( [ (1,4)(2,3), (1,3)(2,4), (2,4,3), (3,4) ] )^G ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConjugacyClassesSubgroups", IsGroup );


#############################################################################
##
#A  LatticeSubgroups( <G> )
##
##  <#GAPDoc Label="LatticeSubgroups">
##  <ManSection>
##  <Attr Name="LatticeSubgroups" Arg='G'/>
##
##  <Description>
##  computes the lattice of subgroups of the group <A>G</A>.  This lattice has
##  the conjugacy classes of subgroups as attribute
##  <Ref Func="ConjugacyClassesSubgroups"/> and
##  permits one to test maximality/minimality relations.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(4);;
##  gap> l:=LatticeSubgroups(g);
##  <subgroup lattice of Sym( [ 1 .. 4 ] ), 11 classes, 30 subgroups>
##  gap> ConjugacyClassesSubgroups(l);
##  [ Group( () )^G, Group( [ (1,3)(2,4) ] )^G, Group( [ (3,4) ] )^G, 
##    Group( [ (2,4,3) ] )^G, Group( [ (1,4)(2,3), (1,3)(2,4) ] )^G, 
##    Group( [ (3,4), (1,2)(3,4) ] )^G, 
##    Group( [ (1,3,2,4), (1,2)(3,4) ] )^G, Group( [ (3,4), (2,4,3) ] )^G,
##    Group( [ (1,4)(2,3), (1,3)(2,4), (3,4) ] )^G, 
##    Group( [ (1,4)(2,3), (1,3)(2,4), (2,4,3) ] )^G, 
##    Group( [ (1,4)(2,3), (1,3)(2,4), (2,4,3), (3,4) ] )^G ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LatticeSubgroups", IsGroup );


#############################################################################
##
#A  DerivedLength( <G> )
##
##  <#GAPDoc Label="DerivedLength">
##  <ManSection>
##  <Attr Name="DerivedLength" Arg='G'/>
##
##  <Description>
##  The derived length of a group is the number of steps in the derived
##  series. (As there is always the group, it is the series length minus 1.)
##  <Example><![CDATA[
##  gap> List(DerivedSeriesOfGroup(g),Size);
##  [ 24, 12, 4, 1 ]
##  gap> DerivedLength(g);
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DerivedLength", IsGroup );

#############################################################################
##
#A  HirschLength( <G> )
##
##  <ManSection>
##  <Attr Name="HirschLength" Arg='G'/>
##
##  <Description>
##  Suppose that <A>G</A> is polycyclic-by-finite; that is, there exists a
##  polycyclic normal subgroup N in <A>G</A> with [G : N] finite. Then the Hirsch
##  length of <A>G</A> is the number of infinite cyclic factors in a polycyclic
##  series of N. This is an invariant of <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "HirschLength", IsGroup );
InstallIsomorphismMaintenance( HirschLength, 
                               IsGroup and HasHirschLength,
                               IsGroup );


#############################################################################
##
#A  DerivedSeriesOfGroup( <G> )
##
##  <#GAPDoc Label="DerivedSeriesOfGroup">
##  <ManSection>
##  <Attr Name="DerivedSeriesOfGroup" Arg='G'/>
##
##  <Description>
##  The derived series of a group is obtained by <M>U_{{i+1}} = U_i'</M>.
##  It stops if <M>U_i</M> is perfect.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DerivedSeriesOfGroup", IsGroup );


#############################################################################
##
#A  DerivedSubgroup( <G> )
##
##  <#GAPDoc Label="DerivedSubgroup">
##  <ManSection>
##  <Attr Name="DerivedSubgroup" Arg='G'/>
##
##  <Description>
##  The derived subgroup <M><A>G</A>'</M> of <A>G</A> is the subgroup
##  generated by all commutators of pairs of elements of <A>G</A>.
##  It is normal in <A>G</A> and the factor group <M><A>G</A>/<A>G</A>'</M>
##  is the largest abelian factor group of <A>G</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> DerivedSubgroup(g);
##  Group([ (1,3,2), (2,4,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DerivedSubgroup", IsGroup );


#############################################################################
##
#A  MaximalAbelianQuotient( <G> )  . . . . Max abelian quotient
##
##  <#GAPDoc Label="MaximalAbelianQuotient">
##  <ManSection>
##  <Attr Name="MaximalAbelianQuotient" Arg='G'/>
##
##  <Description>
##  returns an epimorphism from <A>G</A> onto the maximal abelian quotient of
##  <A>G</A>.
##  The kernel of this epimorphism is the derived subgroup of <A>G</A>,
##  see <Ref Func="DerivedSubgroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MaximalAbelianQuotient",IsGroup);


#############################################################################
##
#A  CommutatorLength( <G> )
##
##  <#GAPDoc Label="CommutatorLength">
##  <ManSection>
##  <Attr Name="CommutatorLength" Arg='G'/>
##
##  <Description>
##  returns the minimal number <M>n</M> such that each element
##  in the derived subgroup (see&nbsp;<Ref Func="DerivedSubgroup"/>) of the
##  group <A>G</A> can be written as a product of (at most) <M>n</M>
##  commutators of elements in <A>G</A>.
##  <Example><![CDATA[
##  gap> CommutatorLength( g );
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CommutatorLength", IsGroup );


#############################################################################
##
#A  DimensionsLoewyFactors( <G> )
##
##  <#GAPDoc Label="DimensionsLoewyFactors">
##  <ManSection>
##  <Attr Name="DimensionsLoewyFactors" Arg='G'/>
##
##  <Description>
##  This operation computes the dimensions of the factors of the Loewy
##  series of <A>G</A>.
##  (See <Cite Key="Hup82" Where="p. 157"/> for the slightly complicated
##  definition of the Loewy Series.)
##  <P/>
##  The dimensions are computed via the <Ref Func="JenningsSeries"/> without computing
##  the Loewy series itself.
##  <Example><![CDATA[
##  gap> G:= SmallGroup( 3^6, 100 );
##  <pc group of size 729 with 6 generators>
##  gap> JenningsSeries( G );
##  [ <pc group of size 729 with 6 generators>, Group([ f3, f4, f5, f6 ]),
##    Group([ f4, f5, f6 ]), Group([ f5, f6 ]), Group([ f5, f6 ]), 
##    Group([ f5, f6 ]), Group([ f6 ]), Group([ f6 ]), Group([ f6 ]), 
##    Group([ <identity> of ... ]) ]
##  gap> DimensionsLoewyFactors(G);
##  [ 1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 16, 17, 19, 20, 22, 23, 25, 26, 
##    27, 27, 27, 27, 27, 27, 27, 27, 27, 26, 25, 23, 22, 20, 19, 17, 16, 
##    14, 13, 11, 10, 8, 7, 5, 4, 2, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DimensionsLoewyFactors", IsGroup );


#############################################################################
##
#A  ElementaryAbelianSeries( <G> )
#A  ElementaryAbelianSeriesLargeSteps( <G> )
#A  ElementaryAbelianSeries( [<G>,<NT1>,<NT2>,...] )
##
##  <#GAPDoc Label="ElementaryAbelianSeries">
##  <ManSection>
##  <Heading>ElementaryAbelianSeries</Heading>
##  <Attr Name="ElementaryAbelianSeries" Arg='G' Label="for a group"/>
##  <Attr Name="ElementaryAbelianSeriesLargeSteps" Arg='G'/>
##  <Attr Name="ElementaryAbelianSeries" Arg='list' Label="for a list"/>
##
##  <Description>
##  returns a series of normal subgroups of <M>G</M> such that all factors are
##  elementary abelian. If the group is not solvable (and thus no such series
##  exists) it returns <K>fail</K>.
##  <P/>
##  The variant <Ref Func="ElementaryAbelianSeriesLargeSteps"/> tries to make
##  the steps in this series large (by eliminating intermediate subgroups if
##  possible) at a small additional cost.
##  <P/>
##  In the third variant, an elementary abelian series through the given
##  series of normal subgroups in the list <A>list</A> is constructed.
##  <Example><![CDATA[
##  gap> List(ElementaryAbelianSeries(g),Size);
##  [ 24, 12, 4, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ElementaryAbelianSeries", IsGroup );
DeclareAttribute( "ElementaryAbelianSeriesLargeSteps", IsGroup );


#############################################################################
##
#A  Exponent( <G> )
##
##  <#GAPDoc Label="Exponent">
##  <ManSection>
##  <Attr Name="Exponent" Arg='G'/>
##
##  <Description>
##  The exponent <M>e</M> of a group <A>G</A> is the lcm of the orders of its
##  elements, that is, <M>e</M> is the smallest integer such that
##  <M>g^e = 1</M> for all <M>g \in <A>G</A></M>.
##  <Example><![CDATA[
##  gap> Exponent(g);
##  12
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Exponent", IsGroup );

InstallIsomorphismMaintenance( Exponent, IsGroup and HasExponent, IsGroup );


#############################################################################
##
#A  FittingSubgroup( <G> )
##
##  <#GAPDoc Label="FittingSubgroup">
##  <ManSection>
##  <Attr Name="FittingSubgroup" Arg='G'/>
##
##  <Description>
##  The Fitting subgroup of a group <A>G</A> is its largest nilpotent normal
##  subgroup.
##  <Example><![CDATA[
##  gap> FittingSubgroup(g);
##  Group([ (1,2)(3,4), (1,4)(2,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FittingSubgroup", IsGroup );


#############################################################################
##
#A  PrefrattiniSubgroup( <G> )
##
##  <#GAPDoc Label="PrefrattiniSubgroup">
##  <ManSection>
##  <Attr Name="PrefrattiniSubgroup" Arg='G'/>
##
##  <Description>
##  returns a Prefrattini subgroup of the finite solvable group <A>G</A>.
##  <P/>
##  A factor <M>M/N</M> of <A>G</A> is called a Frattini factor if
##  <M>M/N</M> is contained in the Frattini subgroup of <M><A>G</A>/N</M>.
##  A subgroup <M>P</M> is a Prefrattini subgroup of <A>G</A> if <M>P</M>
##  covers each Frattini chief factor of <A>G</A>, and if for each maximal
##  subgroup of <A>G</A> there exists a conjugate maximal subgroup, which
##  contains <M>P</M>.
##  In a finite solvable group <A>G</A> the Prefrattini subgroups
##  form a characteristic conjugacy class of subgroups and the intersection
##  of all these subgroups is the Frattini subgroup of <A>G</A>.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 60, 7 );
##  <pc group of size 60 with 4 generators>
##  gap> P := PrefrattiniSubgroup(G);
##  Group([ f2 ])
##  gap> Size(P);
##  2
##  gap> IsNilpotent(P);
##  true
##  gap> Core(G,P);
##  Group([  ])
##  gap> FrattiniSubgroup(G);
##  Group([  ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PrefrattiniSubgroup", IsGroup );


#############################################################################
##
#A  FrattiniSubgroup( <G> )
##
##  <#GAPDoc Label="FrattiniSubgroup">
##  <ManSection>
##  <Attr Name="FrattiniSubgroup" Arg='G'/>
##
##  <Description>
##  The Frattini subgroup of a group <A>G</A> is the intersection of all
##  maximal subgroups of <A>G</A>.
##  <Example><![CDATA[
##  gap> FrattiniSubgroup(g);
##  Group(())
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FrattiniSubgroup", IsGroup );


#############################################################################
##
#A  InvariantForm( <D> )
##
##  <ManSection>
##  <Attr Name="InvariantForm" Arg='D'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "InvariantForm", IsGroup );


#############################################################################
##
#A  JenningsSeries( <G> )
##
##  <#GAPDoc Label="JenningsSeries">
##  <ManSection>
##  <Attr Name="JenningsSeries" Arg='G'/>
##
##  <Description>
##  For a <M>p</M>-group <A>G</A>, this function returns its Jennings series.
##  This series is defined by setting
##  <M>G_1 = <A>G</A></M> and for <M>i \geq 0</M>,
##  <M>G_{{i+1}} = [G_i,<A>G</A>] G_j^p</M>,
##  where <M>j</M> is the smallest integer <M>\geq i/p</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "JenningsSeries", IsGroup );


#############################################################################
##
#A  LowerCentralSeriesOfGroup( <G> )
##
##  <#GAPDoc Label="LowerCentralSeriesOfGroup">
##  <ManSection>
##  <Attr Name="LowerCentralSeriesOfGroup" Arg='G'/>
##
##  <Description>
##  The lower central series of a group <A>G</A> is defined as
##  <M>U_{{i+1}}:= [<A>G</A>, U_i]</M>.
##  It is a central series of normal subgroups.
##  The name derives from the fact that <M>U_i</M> is contained in the
##  <M>i</M>-th step subgroup of any central series.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LowerCentralSeriesOfGroup", IsGroup );

#############################################################################
##
#A  NilpotencyClassOfGroup( <G> )
##
##  <#GAPDoc Label="NilpotencyClassOfGroup">
##  <ManSection>
##  <Attr Name="NilpotencyClassOfGroup" Arg='G'/>
##
##  <Description>
##  The nilpotency class of a nilpotent group <A>G</A> is the number of steps in
##  the lower central series of <A>G</A> (see <Ref Func="LowerCentralSeriesOfGroup"/>);
##  <P/>
##  If <A>G</A> is not nilpotent an error is issued.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NilpotencyClassOfGroup", IsGroup );


#############################################################################
##
#A  MaximalNormalSubgroups( <G> )
##
##  <#GAPDoc Label="MaximalNormalSubgroups">
##  <ManSection>
##  <Attr Name="MaximalNormalSubgroups" Arg='G'/>
##
##  <Description>
##  is a list containing those proper normal subgroups of the group <A>G</A>
##  that are maximal among the proper normal subgroups.
##  <Example><![CDATA[
##  gap> MaximalNormalSubgroups( g );
##  [ Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MaximalNormalSubgroups", IsGroup );


#############################################################################
##
#A  NormalMaximalSubgroups( <G> )
##
##  <ManSection>
##  <Attr Name="NormalMaximalSubgroups" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "NormalMaximalSubgroups", IsGroup );


#############################################################################
##
#A  MinimalNormalSubgroups( <G> )
##
##  <#GAPDoc Label="MinimalNormalSubgroups">
##  <ManSection>
##  <Attr Name="MinimalNormalSubgroups" Arg='G'/>
##
##  <Description>
##  is a list containing those nontrivial normal subgroups of the group <A>G</A>
##  that are minimal among the nontrivial normal subgroups.
##  <Example><![CDATA[
##  gap> MinimalNormalSubgroups( g );
##  [ Group([ (1,4)(2,3), (1,3)(2,4) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MinimalNormalSubgroups", IsGroup );


#############################################################################
##
#A  NormalSubgroups( <G> )
##
##  <#GAPDoc Label="NormalSubgroups">
##  <ManSection>
##  <Attr Name="NormalSubgroups" Arg='G'/>
##
##  <Description>
##  returns a list of all normal subgroups of <A>G</A>.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(4);;NormalSubgroups(g);
##  [ Sym( [ 1 .. 4 ] ), Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]), 
##    Group([ (1,4)(2,3), (1,3)(2,4) ]), Group(()) ]
##  ]]></Example>
##  <P/>
##  The algorithm for the computation of normal subgroups is described in
##  <Cite Key="Hulpke98"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NormalSubgroups", IsGroup );


#############################################################################
##
#F  NormalSubgroupsAbove( <G>, <N>, <avoid> )
##
##  <ManSection>
##  <Func Name="NormalSubgroupsAbove" Arg='G, N, avoid'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("NormalSubgroupsAbove");


############################################################################
##
#A  NrConjugacyClasses( <G> )
##
##  <#GAPDoc Label="NrConjugacyClasses">
##  <ManSection>
##  <Attr Name="NrConjugacyClasses" Arg='G'/>
##
##  <Description>
##  returns the number of conjugacy classes of <A>G</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> NrConjugacyClasses(g);
##  5
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NrConjugacyClasses", IsGroup );


#############################################################################
##
#O  Omega( <G>, <p>[, <n>] )
##
##  <#GAPDoc Label="Omega">
##  <ManSection>
##  <Oper Name="Omega" Arg='G, p[, n]'/>
##
##  <Description>
##  For a <A>p</A>-group <A>G</A>, one defines
##  <M>\Omega_{<A>n</A>}(<A>G</A>) =
##  \{ g \in <A>G</A> \mid g^{{<A>p</A>^{<A>n</A>}}} = 1 \}</M>.
##  The default value for <A>n</A> is <C>1</C>.
##  <P/>
##  <E>@At the moment methods exist only for abelian <A>G</A> and <A>n</A>=1.@</E>
##  <Example><![CDATA[
##  gap> h:=SmallGroup(16,10);
##  <pc group of size 16 with 4 generators>
##  gap> Omega(h,2);
##  Group([ f2, f3, f4 ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Omega", [ IsGroup, IsPosInt ] );
DeclareOperation( "Omega", [ IsGroup, IsPosInt, IsPosInt ] );

DeclareOperation( "OmegaOp", [ IsGroup, IsPosInt, IsPosInt ] );
DeclareAttribute( "ComputedOmegas", IsGroup, "mutable" );


#############################################################################
##
#F  Agemo( <G>, <p>[, <n>] )
##
##  <#GAPDoc Label="Agemo">
##  <ManSection>
##  <Func Name="Agemo" Arg='G, p[, n]'/>
##
##  <Description>
##  For a <A>p</A>-group <A>G</A>, one defines
##  <M>\mho_{<A>n</A>}(G) =
##  \langle g^{{<A>p</A>^{<A>n</A>}}} \mid g \in <A>G</A> \rangle</M>.
##  The default value for <A>n</A> is <C>1</C>.
##  <Example><![CDATA[
##  gap> Agemo(h,2);Agemo(h,2,2);
##  Group([ f4 ])
##  Group([  ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Agemo" );
DeclareOperation( "AgemoOp", [ IsGroup, IsPosInt, IsPosInt ] );
DeclareAttribute( "ComputedAgemos", IsGroup, "mutable" );


#############################################################################
##
#A  RadicalGroup( <G> )
##
##  <#GAPDoc Label="RadicalGroup">
##  <ManSection>
##  <Attr Name="RadicalGroup" Arg='G'/>
##
##  <Description>
##  is the radical of <A>G</A>, i.e., the largest solvable normal subgroup of <A>G</A>.
##  <Example><![CDATA[
##  gap> RadicalGroup(SL(2,5));
##  <group of 2x2 matrices of size 2 over GF(5)>
##  gap> Size(last);
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RadicalGroup", IsGroup );


#############################################################################
##
#A  RationalClasses( <G> )
##
##  <#GAPDoc Label="RationalClasses">
##  <ManSection>
##  <Attr Name="RationalClasses" Arg='G'/>
##
##  <Description>
##  returns a list of the rational classes of the group <A>G</A>. (See
##  <Ref Func="RationalClass"/>.)
##  <Example><![CDATA[
##  gap> RationalClasses(DerivedSubgroup(g));
##  [ RationalClass( AlternatingGroup( [ 1 .. 4 ] ), () ), 
##    RationalClass( AlternatingGroup( [ 1 .. 4 ] ), (1,2)(3,4) ), 
##    RationalClass( AlternatingGroup( [ 1 .. 4 ] ), (1,2,3) ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RationalClasses", IsGroup );


#############################################################################
##
#A  GeneratorsSmallest( <G> )
##
##  <#GAPDoc Label="GeneratorsSmallest">
##  <ManSection>
##  <Attr Name="GeneratorsSmallest" Arg='G'/>
##
##  <Description>
##  returns a <Q>smallest</Q> generating set for the group <A>G</A>.
##  This is the lexicographically (using &GAP;s order of group elements)
##  smallest list <M>l</M> of elements of <A>G</A> such that
##  <M>G = \langle l \rangle</M> and
##  <M>l_i \not \in \langle l_1, \ldots, l_{{i-1}} \rangle</M>
##  (in particular <M>l_1</M> is not the identity element of the group).
##  The comparison of two groups via
##  lexicographic comparison of their sorted element lists yields the same
##  relation as lexicographic comparison of their smallest generating sets.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(4);;
##  gap> GeneratorsSmallest(g);
##  [ (3,4), (2,3), (1,2) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsSmallest", IsMagma );


#############################################################################
##
#A  LargestElementGroup( <G> )
##
##  <#GAPDoc Label="LargestElementGroup">
##  <ManSection>
##  <Attr Name="LargestElementGroup" Arg='G'/>
##
##  <Description>
##  returns the largest element of <A>G</A> with respect to the ordering <C>&lt;</C> of
##  the elements family.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LargestElementGroup", IsGroup );


#############################################################################
##
#A  MinimalGeneratingSet( <G> )
##
##  <#GAPDoc Label="MinimalGeneratingSet">
##  <ManSection>
##  <Attr Name="MinimalGeneratingSet" Arg='G'/>
##
##  <Description>
##  returns a generating set of <A>G</A> of minimal possible length.
##  <P/>
##  Note that &ndash;apart from special cases&ndash; currently there are only
##  efficient methods known to compute minimal generating sets of finite
##  solvable groups and of finitely generated nilpotent groups.
##  Hence so far these are the only cases for which methods are available.
##  The former case is covered by a method implemented in the &GAP; library,
##  while the second case requires the package <Package>Polycyclic</Package>.
##  <P/>
##  If you do not really need a minimal generating set, but are satisfied
##  with getting a reasonably small set of generators, you better use
##  <Ref Func="SmallGeneratingSet"/>.
##  <P/>
##  Information about the minimal generating sets of the finite simple
##  groups of order less than <M>10^6</M> can be found in <Cite Key="MY79"/>.
##  See also the package <Package>AtlasRep</Package>.
##  <Example><![CDATA[
##  gap> MinimalGeneratingSet(g);
##  [ (2,4,3), (1,4,2,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MinimalGeneratingSet", IsGroup );


#############################################################################
##
#A  SmallGeneratingSet(<G>) small generating set (hopefully even irredundant)
##
##  <#GAPDoc Label="SmallGeneratingSet">
##  <ManSection>
##  <Attr Name="SmallGeneratingSet" Arg='G'/>
##
##  <Description>
##  returns a generating set of <A>G</A> which has few elements. As neither
##  irredundancy, nor minimal length is proven it runs much faster than
##  <Ref Func="MinimalGeneratingSet"/>.
##  It can be used whenever a short generating set is desired which not
##  necessarily needs to be optimal.
##  <Example><![CDATA[
##  gap> SmallGeneratingSet(g);
##  [ (1,2,3,4), (1,2) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SmallGeneratingSet", IsGroup );


#############################################################################
##
#A  SupersolvableResiduum( <G> )
##
##  <#GAPDoc Label="SupersolvableResiduum">
##  <ManSection>
##  <Attr Name="SupersolvableResiduum" Arg='G'/>
##
##  <Description>
##  is the supersolvable residuum of the group <A>G</A>, that is,
##  its smallest normal subgroup <M>N</M> such that the factor group
##  <M><A>G</A> / N</M> is supersolvable.
##  <Example><![CDATA[
##  gap> SupersolvableResiduum(g);
##  Group([ (1,2)(3,4), (1,4)(2,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SupersolvableResiduum", IsGroup );


#############################################################################
##
#F  SupersolvableResiduumDefault( <G> ) . . . . supersolvable residuum of <G>
##
##  <ManSection>
##  <Func Name="SupersolvableResiduumDefault" Arg='G'/>
##
##  <Description>
##  For a group <A>G</A>, <C>SupersolvableResiduumDefault</C> returns a record with the
##  following components.
##  <List>
##  <Mark><C>ssr</C>: </Mark>
##  <Item>
##      the supersolvable residuum of <A>G</A>, that is,
##      the largest normal subgroup <M>N</M> of <A>G</A> such that the factor group
##      <M><A>G</A> / N</M> is supersolvable,
##  </Item>
##  <Mark><C>ds</C>: </Mark>
##  <Item>
##      a chain of normal subgroups of <A>G</A>,
##      descending from <A>G</A> to the supersolvable residuum,
##      such that any refinement of this chain is a normal series.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SupersolvableResiduumDefault" );


#############################################################################
##
#A  ComplementSystem( <G> )
##
##  <#GAPDoc Label="ComplementSystem">
##  <ManSection>
##  <Attr Name="ComplementSystem" Arg='G'/>
##
##  <Description>
##  A complement system of a group <A>G</A> is a set of Hall
##  <M>p'</M>-subgroups of <A>G</A>,
##  where <M>p'</M> runs through the subsets of prime factors of
##  <M>|<A>G</A>|</M> that omit exactly one prime.
##  Every pair of subgroups from this set commutes as subgroups.
##  Complement systems exist only for solvable groups, therefore
##  <Ref Func="ComplementSystem"/> returns <K>fail</K> if the group <A>G</A>
##  is not solvable.
##  <Example><![CDATA[
##  gap> ComplementSystem(h);
##  [ Group([ f3, f4 ]), Group([ f1, f2, f4 ]), Group([ f1, f2, f3 ]) ]
##  gap> List(last,Size);
##  [ 15, 20, 12 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ComplementSystem", IsGroup );


#############################################################################
##
#A  SylowSystem( <G> )
##
##  <#GAPDoc Label="SylowSystem">
##  <ManSection>
##  <Attr Name="SylowSystem" Arg='G'/>
##
##  <Description>
##  A Sylow system of a group <A>G</A> is a set of Sylow subgroups of
##  <A>G</A> such that every pair of subgroups from this set commutes as
##  subgroups.
##  Sylow systems exist only for solvable groups. The operation returns
##  <K>fail</K> if the group <A>G</A> is not solvable.
##  <Example><![CDATA[
##  gap> h:=SmallGroup(60,10);;
##  gap> SylowSystem(h);
##  [ Group([ f1, f2 ]), Group([ f3 ]), Group([ f4 ]) ]
##  gap> List(last,Size);
##  [ 4, 3, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SylowSystem", IsGroup );


#############################################################################
##
#A  HallSystem( <G> )
##
##  <#GAPDoc Label="HallSystem">
##  <ManSection>
##  <Attr Name="HallSystem" Arg='G'/>
##
##  <Description>
##  returns a list containing one Hall <M>P</M>-subgroup for each set
##  <M>P</M> of prime divisors of the order of <A>G</A>.
##  Hall systems exist only for solvable groups. The operation returns
##  <K>fail</K> if the group <A>G</A> is not solvable.
##  <Example><![CDATA[
##  gap> HallSystem(h);
##  [ Group([  ]), Group([ f1, f2 ]), Group([ f1, f2, f3 ]), 
##    Group([ f1, f2, f3, f4 ]), Group([ f1, f2, f4 ]), Group([ f3 ]), 
##    Group([ f3, f4 ]), Group([ f4 ]) ]
##  gap> List(last,Size);
##  [ 1, 4, 12, 60, 20, 3, 15, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "HallSystem", IsGroup );


#############################################################################
##
#A  TrivialSubgroup( <G> ) . . . . . . . . . .  trivial subgroup of group <G>
##
##  <#GAPDoc Label="TrivialSubgroup">
##  <ManSection>
##  <Attr Name="TrivialSubgroup" Arg='G'/>
##
##  <Description>
##  <Example><![CDATA[
##  gap> TrivialSubgroup(g);
##  Group(())
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "TrivialSubgroup", TrivialSubmagmaWithOne );


#############################################################################
##
#A  Socle( <G> ) . . . . . . . . . . . . . . . . . . . . . . . . socle of <G>
##
##  <#GAPDoc Label="Socle">
##  <ManSection>
##  <Attr Name="Socle" Arg='G'/>
##
##  <Description>
##  The socle of the group <A>G</A> is the subgroup generated by
##  all minimal normal subgroups.
##  <Example><![CDATA[
##  gap> Socle(g);
##  Group([ (1,4)(2,3), (1,2)(3,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Socle", IsGroup );


#############################################################################
##
#A  UpperCentralSeriesOfGroup( <G> )
##
##  <#GAPDoc Label="UpperCentralSeriesOfGroup">
##  <ManSection>
##  <Attr Name="UpperCentralSeriesOfGroup" Arg='G'/>
##
##  <Description>
##  The upper central series of a group <A>G</A> is defined as an ending
##  series <M>U_i / U_{{i+1}}:= Z(<A>G</A>/U_{{i+1}})</M>.
##  It is a central series of normal subgroups.
##  The name derives from the fact that <M>U_i</M> contains every <M>i</M>-th
##  step subgroup of a central series.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UpperCentralSeriesOfGroup", IsGroup );


#############################################################################
##
#O  EulerianFunction( <G>, <n> )
##
##  <#GAPDoc Label="EulerianFunction">
##  <ManSection>
##  <Oper Name="EulerianFunction" Arg='G, n'/>
##
##  <Description>
##  returns the number of <A>n</A>-tuples <M>(g_1, g_2, \ldots, g_n)</M>
##  of elements of the group <A>G</A> that generate the whole group <A>G</A>.
##  The elements of such an <A>n</A>-tuple need not be different.
##  <P/>
##  In <Cite Key="Hal36"/>, the notation <M>\phi_{<A>n</A>}(<A>G</A>)</M>
##  is used for the value returned by <Ref Func="EulerianFunction"/>,
##  and the quotient of <M>\phi_{<A>n</A>}(<A>G</A>)</M> by the order of the
##  automorphism group of <A>G</A> is called <M>d_{<A>n</A>}(<A>G</A>)</M>.
##  If <A>G</A> is a nonabelian simple group then
##  <M>d_{<A>n</A>}(<A>G</A>)</M> is the greatest number <M>d</M> for which
##  the direct product of <M>d</M> groups isomorphic with <A>G</A>
##  can be generated by <A>n</A> elements.
##  <P/>
##  If the Library of Tables of Marks
##  (see Chapter <Ref Chap="Tables of Marks"/>) covers the group <A>G</A>,
##  you may also use <Ref Func="EulerianFunctionByTom"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> EulerianFunction( g, 2 );
##  432
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EulerianFunction", [ IsGroup, IsPosInt ] );


#############################################################################
##
#F  AgemoAbove( <G>, <C>, <p> )
##
##  <ManSection>
##  <Func Name="AgemoAbove" Arg='G, C, p'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AgemoAbove" );


#############################################################################
##
#O  AsSubgroup( <G>, <U> )
##
##  <#GAPDoc Label="AsSubgroup">
##  <ManSection>
##  <Oper Name="AsSubgroup" Arg='G, U'/>
##
##  <Description>
##  creates a subgroup of <A>G</A> which contains the same elements as <A>U</A>
##  <Example><![CDATA[
##  gap> v:=AsSubgroup(g,Group((1,2,3),(1,4)));
##  Group([ (1,2,3), (1,4) ])
##  gap> Parent(v);
##  Group([ (1,2,3,4), (1,2) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsSubgroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ClassMultiplicationCoefficient( <G>, <i>, <j>, <k> )
#O  ClassMultiplicationCoefficient( <G>, <Ci>, <Cj>, <Ck> )
##
##  <ManSection>
##  <Oper Name="ClassMultiplicationCoefficient" Arg='G, i, j, k'/>
##  <Oper Name="ClassMultiplicationCoefficient" Arg='G, Ci, Cj, Ck'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "ClassMultiplicationCoefficient",
    [ IsGroup, IsPosInt, IsPosInt, IsPosInt ] );
DeclareOperation( "ClassMultiplicationCoefficient",
    [ IsGroup, IsCollection, IsCollection, IsCollection ] );


#############################################################################
##
#F  ClosureGroupDefault( <G>, <elm> ) . . . . . closure of group with element
##
##  <#GAPDoc Label="ClosureGroupDefault">
##  <ManSection>
##  <Func Name="ClosureGroupDefault" Arg='G, elm'/>
##
##  <Description>
##  This functions returns the closure of the group <A>G</A> with the element
##  <A>elm</A>.
##  If <A>G</A> has the attribute <Ref Func="AsSSortedList"/> then also the
##  result has this attribute.
##  This is used to implement the default method for
##  <Ref Func="Enumerator"/> and <Ref Func="EnumeratorSorted"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ClosureGroupDefault" );


#############################################################################
##
#O  ClosureGroup( <G>, <obj> )  . . .  closure of group with element or group
##
##  <#GAPDoc Label="ClosureGroup">
##  <ManSection>
##  <Oper Name="ClosureGroup" Arg='G, obj'/>
##
##  <Description>
##  creates the group generated by the elements of <A>G</A> and <A>obj</A>.
##  <A>obj</A> can be either an element or a collection of elements,
##  in particular another group.
##  <Example><![CDATA[
##  gap> g:=SmallGroup(24,12);;u:=Subgroup(g,[g.3,g.4]);
##  Group([ f3, f4 ])
##  gap> ClosureGroup(u,g.2);
##  Group([ f2, f3, f4 ])
##  gap> ClosureGroup(u,[g.1,g.2]);
##  Group([ f1, f2, f3, f4 ])
##  gap> ClosureGroup(u,Group(g.2*g.1));
##  Group([ f1*f2^2, f3, f4 ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClosureGroup", [ IsGroup, IsObject ] );


#############################################################################
##
#F  ClosureGroupAddElm( <G>, <elm> )
#F  ClosureGroupCompare( <G>, <elm> )
#F  ClosureGroupIntest( <G>, <elm> )
##
##  <#GAPDoc Label="ClosureGroupAddElm">
##  <ManSection>
##  <Func Name="ClosureGroupAddElm" Arg='G, elm'/>
##  <Func Name="ClosureGroupCompare" Arg='G, elm'/>
##  <Func Name="ClosureGroupIntest" Arg='G, elm'/>
##
##  <Description>
##  These three functions together with <Ref Func="ClosureGroupDefault"/>
##  implement the main methods for <Ref Func="ClosureGroup"/>.
##  In the ordering given, they just add <A>elm</A> to the generators, remove
##  duplicates and identity elements, and test whether <A>elm</A> is already
##  contained in <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ClosureGroupAddElm" );
DeclareGlobalFunction( "ClosureGroupCompare" );
DeclareGlobalFunction( "ClosureGroupIntest" );


#############################################################################
##
#F  ClosureSubgroup( <G>, <obj> )
#F  ClosureSubgroupNC( <G>, <obj> )
##
##  <#GAPDoc Label="ClosureSubgroup">
##  <ManSection>
##  <Func Name="ClosureSubgroup" Arg='G, obj'/>
##  <Func Name="ClosureSubgroupNC" Arg='G, obj'/>
##
##  <Description>
##  For a group <A>G</A> that stores a parent group (see&nbsp;<Ref Sect="Parents"/>),
##  <Ref Func="ClosureSubgroup"/> calls <Ref Func="ClosureGroup"/> with the same
##  arguments;
##  if the result is a subgroup of the parent of <A>G</A> then the parent of <A>G</A>
##  is set as parent of the result, otherwise an error is raised.
##  The check whether the result is contained in the parent of <A>G</A> is omitted
##  by the <C>NC</C> version. As a wrong parent might imply wrong properties this
##  version should be used with care.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ClosureSubgroup" );
DeclareGlobalFunction( "ClosureSubgroupNC" );


#############################################################################
##
#O  CommutatorSubgroup( <G>, <H> )
##
##  <#GAPDoc Label="CommutatorSubgroup">
##  <ManSection>
##  <Oper Name="CommutatorSubgroup" Arg='G, H'/>
##
##  <Description>
##  If <A>G</A> and <A>H</A> are two groups of elements in the same family,
##  this operation returns the group generated by all commutators
##  <M>[ g, h ] = g^{{-1}} h^{{-1}} g h</M> (see&nbsp;<Ref Func="Comm"/>)
##  of elements <M>g \in <A>G</A></M> and
##  <M>h \in <A>H</A></M>, that is the group
##  <M>\left \langle [ g, h ] \mid g \in <A>G</A>, h \in <A>H</A> \right \rangle</M>.
##  <Example><![CDATA[
##  gap> CommutatorSubgroup(Group((1,2,3),(1,2)),Group((2,3,4),(3,4)));
##  Group([ (1,4)(2,3), (1,3,4) ])
##  gap> Size(last);
##  12
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CommutatorSubgroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ConjugateGroup( <G>, <obj> )  . . . . . . conjugate of group <G> by <obj>
##
##  <#GAPDoc Label="ConjugateGroup">
##  <ManSection>
##  <Oper Name="ConjugateGroup" Arg='G, obj'/>
##
##  <Description>
##  returns the conjugate group of <A>G</A>, obtained by applying the 
##  conjugating element <A>obj</A>.
##  <P/>
##  To form a conjugate (group) by any object acting via <C>^</C>, 
##  one can also use the infix operator <C>^</C>.
##  <Example><![CDATA[
##  gap> ConjugateGroup(g,(1,5));
##  Group([ (2,3,4,5), (2,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ConjugateGroup", [ IsGroup, IsObject ] );


#############################################################################
##
#O  ConjugateSubgroup( <G>, <g> )
##
##  <#GAPDoc Label="ConjugateSubgroup">
##  <ManSection>
##  <Oper Name="ConjugateSubgroup" Arg='G, g'/>
##
##  <Description>
##  For a group <A>G</A> which has a parent group <C>P</C>
##  (see <Ref Func="Parent"/>), returns the subgroup of <C>P</C>,
##  obtained by conjugating <A>G</A> using the conjugating
##  element <A>g</A>.
##  <P/>
##  If <A>G</A> has no parent group, it just delegates to the
##  call to <Ref Oper="ConjugateGroup"/> with the same arguments. 
##  <P/>
##  To form a conjugate (subgroup) by any object acting via <C>^</C>, 
##  one can also use the infix operator <C>^</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ConjugateSubgroup",
    [ IsGroup and HasParent, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#O  ConjugateSubgroups( <G>, <U> )
##
##  <#GAPDoc Label="ConjugateSubgroups">
##  <ManSection>
##  <Oper Name="ConjugateSubgroups" Arg='G, U'/>
##
##  <Description>
##  returns a list of all images of the group <A>U</A> under conjugation action
##  by <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ConjugateSubgroups", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  Core( <S>, <U> )
##
##  <#GAPDoc Label="Core">
##  <ManSection>
##  <Oper Name="Core" Arg='S, U'/>
##
##  <Description>
##  If <A>S</A> and <A>U</A> are groups of elements in the same family, this
##  operation
##  returns the core of <A>U</A> in <A>S</A>, that is the intersection of all
##  <A>S</A>-conjugates of <A>U</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> Core(g,Subgroup(g,[(1,2,3,4)]));
##  Group(())
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "Core", IsGroup, IsGroup, DeclareAttribute );


#############################################################################
##
#O  CosetTable( <G>, <H> )
##
##  <#GAPDoc Label="CosetTable">
##  <ManSection>
##  <Oper Name="CosetTable" Arg='G, H'/>
##
##  <Description>
##  returns the coset table of the finitely presented group <A>G</A>
##  on the cosets of the subgroup <A>H</A>.
##  <P/>
##  Basically a coset table is the permutation representation of the finitely
##  presented group on the cosets of a subgroup  (which need  not be faithful
##  if the subgroup has a nontrivial  core).  Most  of  the set theoretic and
##  group functions use the regular representation of <A>G</A>,
##  i.e., the coset table of <A>G</A> over the trivial subgroup.
##  <P/>
##  The coset table is returned as a list of lists. For each generator of
##  <A>G</A> and its inverse the table contains a generator list. A generator
##  list is simply a list of integers.
##  If <M>l</M> is the generator list for the generator <M>g</M> and if
##  <M>l[i] = j</M> then generator <M>g</M> takes the coset
##  <M>i</M> to the coset <M>j</M> by multiplication from the right.
##  Thus the permutation representation of <A>G</A> on the cosets of <A>H</A>
##  is obtained by applying <Ref Func="PermList"/> to each generator list.
##  <P/>
##  The coset table is standard (see below).
##  <P/>
##  For finitely presented groups, a coset table is computed by a
##  Todd-Coxeter coset enumeration.
##  Note that you may influence the performance of that enumeration by
##  changing the values of the global variables
##  <Ref Var="CosetTableDefaultLimit"/> and
##  <Ref Var="CosetTableDefaultMaxLimit"/> described below and that the
##  options described under <Ref Func="CosetTableFromGensAndRels"/> are
##  recognized.
##  <P/>
##  <Example><![CDATA[
##  gap> tab := CosetTable(g, Subgroup(g, [ g.1, g.2*g.1*g.2*g.1*g.2^-1 ]));
##  [ [ 1, 4, 5, 2, 3 ], [ 1, 4, 5, 2, 3 ], [ 2, 3, 1, 4, 5 ], 
##    [ 3, 1, 2, 4, 5 ] ]
##  gap> List( last, PermList );
##  [ (2,4)(3,5), (2,4)(3,5), (1,2,3), (1,3,2) ]
##  gap> PrintArray( TransposedMat( tab ) );
##  [ [  1,  1,  2,  3 ],
##    [  4,  4,  3,  1 ],
##    [  5,  5,  1,  2 ],
##    [  2,  2,  4,  4 ],
##    [  3,  3,  5,  5 ] ]
##  ]]></Example>
##  <P/>
##  The last printout in the preceding example provides the coset table in
##  the form in which it is usually used in hand calculations:
##  The rows correspond to the cosets, the columns correspond to the
##  generators and their inverses in the ordering
##  <M>g_1, g_1^{{-1}}, g_2, g_2^{{-1}}</M>.
##  (See section&nbsp;<Ref Sect="Standardization of coset tables"/>
##  for a description on the way the numbers are assigned.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CosetTable", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  CosetTableNormalClosure( <G>, <H> )
##
##  <ManSection>
##  <Oper Name="CosetTableNormalClosure" Arg='G, H'/>
##
##  <Description>
##  returns the coset table of the finitely presented group <A>G</A> on the cosets
##  of the normal closure of the subgroup <A>H</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "CosetTableNormalClosure", [ IsGroup, IsGroup ] );


#############################################################################
##
#F  FactorGroup( <G>, <N> )
#O  FactorGroupNC( <G>, <N> )
##
##  <#GAPDoc Label="FactorGroup">
##  <ManSection>
##  <Func Name="FactorGroup" Arg='G, N'/>
##  <Oper Name="FactorGroupNC" Arg='G, N'/>
##
##  <Description>
##  returns the image of the <C>NaturalHomomorphismByNormalSubgroup(<A>G</A>,<A>N</A>)</C>.
##  The homomorphism will be returned by calling the function
##  <C>NaturalHomomorphism</C> on the result.
##  The <C>NC</C> version does not test whether <A>N</A> is normal in <A>G</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;n:=Subgroup(g,[(1,2)(3,4),(1,3)(2,4)]);;
##  gap> hom:=NaturalHomomorphismByNormalSubgroup(g,n);
##  [ (1,2,3,4), (1,2) ] -> [ f1*f2, f1 ]
##  gap> Size(ImagesSource(hom));
##  6
##  gap> FactorGroup(g,n);;
##  gap> StructureDescription(last);
##  "S3"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FactorGroup" );
DeclareOperation( "FactorGroupNC", [ IsGroup, IsGroup ] );

#############################################################################
##
#A  NaturalHomomorphism(<F>)
##
##  <#GAPDoc Label="NaturalHomomorphism">
##  <ManSection>
##  <Oper Name="NaturalHomomorphism" Arg='F'/>
##
##  <Description>
##  For a group <A>F</A> obtained via <C>FactorGroup</C>, this operation
##  returns the natural homomorphism onto <A>F</A>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NaturalHomomorphism", [ IsGroup ] );



#############################################################################
##
#O  Index( <G>, <U> )
#O  IndexNC( <G>, <U> )
##
##  <#GAPDoc Label="Index">
##  <ManSection>
##  <Heading>Index (&GAP; operation)</Heading>
##  <Oper Name="Index" Arg='G, U' Label="for a group and its subgroup"/>
##  <Oper Name="IndexNC" Arg='G, U' Label="for a group and its subgroup"/>
##
##  <Description>
##  For a subgroup <A>U</A> of the group <A>G</A>,
##  <Ref Func="Index" Label="for a group and its subgroup"/> returns the index
##  <M>[<A>G</A>:<A>U</A>] = |<A>G</A>| / |<A>U</A>|</M>
##  of <A>U</A> in <A>G</A>.
##  The <C>NC</C> version does not test whether <A>U</A> is contained in
##  <A>G</A>.
##  <Example><![CDATA[
##  gap> Index(g,u);
##  4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "Index", IsGroup, IsGroup, DeclareAttribute );

DeclareOperation( "IndexNC", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  IndexInWholeGroup( <G> )
##
##  <#GAPDoc Label="IndexInWholeGroup">
##  <ManSection>
##  <Attr Name="IndexInWholeGroup" Arg='G'/>
##
##  <Description>
##  If the family of elements of <A>G</A> itself forms a group <A>P</A>, this
##  attribute returns the index of <A>G</A> in <A>P</A>. It is used
##  primarily for free groups or finitely presented groups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndexInWholeGroup", IsGroup );


#############################################################################
##
#A  IndependentGeneratorsOfAbelianGroup( <A> )
##
##  <#GAPDoc Label="IndependentGeneratorsOfAbelianGroup">
##  <ManSection>
##  <Attr Name="IndependentGeneratorsOfAbelianGroup" Arg='A'/>
##
##  <Description>
##  returns a list of generators <M>a_1, a_2, \ldots</M> of prime power order
##  or infinite order of the abelian group <A>A</A> such that <A>A</A> is the
##  direct product of the cyclic groups generated by the <M>a_i</M>.
##  The list of orders of the returned generators must match the result of
##  <Ref Func="AbelianInvariants"/> (taking into account that zero
##  and <Ref Var="infinity"/> are identified).
##  <Example><![CDATA[
##  gap> g:=AbelianGroup(IsPermGroup,[15,14,22,78]);;
##  gap> List(IndependentGeneratorsOfAbelianGroup(g),Order);
##  [ 2, 2, 2, 3, 3, 5, 7, 11, 13 ]
##  gap> AbelianInvariants(g);
##  [ 2, 2, 2, 3, 3, 5, 7, 11, 13 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndependentGeneratorsOfAbelianGroup",
  IsGroup and IsAbelian );

#############################################################################
##
#O  IndependentGeneratorExponents( <G>, <g> )
##
##  <#GAPDoc Label="IndependentGeneratorExponents">
##  <ManSection>
##  <Oper Name="IndependentGeneratorExponents" Arg='G, g'/>
##
##  <Description>
##  For an abelian group <A>G</A>,
##  with <Ref Func="IndependentGeneratorsOfAbelianGroup"/> value the
##  list <M>[ a_1, \ldots, a_n ]</M>,
##  this operation returns the exponent vector
##  <M>[ e_1, \ldots, e_n ]</M> to represent
##  <M><A>g</A> = \prod_i a_i^{{e_i}}</M>.
##  <Example><![CDATA[
##  gap> g := AbelianGroup([16,9,625]);;
##  gap> gens := IndependentGeneratorsOfAbelianGroup(g);;
##  gap> List(gens, Order);
##  [ 9, 16, 625 ]
##  gap> AbelianInvariants(g);
##  [ 9, 16, 625 ]
##  gap> r:=gens[1]^4*gens[2]^12*gens[3]^128;;
##  gap> IndependentGeneratorExponents(g,r);
##  [ 4, 12, 128 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IndependentGeneratorExponents",
  [IsGroup and IsAbelian,IsMultiplicativeElementWithInverse] );

#############################################################################
##
#O  IsConjugate( <G>, <x>, <y> )
#O  IsConjugate( <G>, <U>, <V> )
##
##  <#GAPDoc Label="IsConjugate">
##  <ManSection>
##  <Heading>IsConjugate</Heading>
##  <Oper Name="IsConjugate" Arg='G, x, y'
##   Label="for a group and two elements"/>
##  <Oper Name="IsConjugate" Arg='G, U, V'
##   Label="for a group and two groups"/>
##
##  <Description>
##  tests whether the elements <A>x</A> and <A>y</A>
##  or the subgroups <A>U</A> and <A>V</A> are
##  conjugate under the action of <A>G</A>.
##  (They do not need to be <E>contained in</E> <A>G</A>.)
##  This command is only a shortcut to <Ref Func="RepresentativeAction"/>.
##  <Example><![CDATA[
##  gap> IsConjugate(g,Group((1,2,3,4),(1,3)),Group((1,3,2,4),(1,2)));
##  true
##  ]]></Example>
##  <P/>
##  <Ref Func="RepresentativeAction"/> can be used to
##  obtain conjugating elements.
##  <Example><![CDATA[
##  gap> RepresentativeAction(g,(1,2),(3,4));
##  (1,3)(2,4)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsConjugate", [ IsGroup, IsObject, IsObject ] );


#############################################################################
##
#O  IsNormal( <G>, <U> )
##
##  <#GAPDoc Label="IsNormal">
##  <ManSection>
##  <Oper Name="IsNormal" Arg='G, U'/>
##
##  <Description>
##  returns <K>true</K> if the group <A>G</A> normalizes the group <A>U</A>
##  and <K>false</K> otherwise.
##  <P/>
##  A group <A>G</A> <E>normalizes</E> a group <A>U</A> if and only if for every <M>g \in <A>G</A></M>
##  and <M>u \in <A>U</A></M> the element <M>u^g</M> is a member of <A>U</A>.
##  Note that <A>U</A> need not be a subgroup of <A>G</A>.
##  <Example><![CDATA[
##  gap> IsNormal(g,u);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "IsNormal", IsGroup, IsGroup, DeclareProperty );


#############################################################################
##
#O  IsCharacteristicSubgroup(<G>,<N>)
##
##  <#GAPDoc Label="IsCharacteristicSubgroup">
##  <ManSection>
##  <Oper Name="IsCharacteristicSubgroup" Arg='G,N'/>
##
##  <Description>
##  tests whether <A>N</A> is invariant under all automorphisms of <A>G</A>.
##  <Example><![CDATA[
##  gap> IsCharacteristicSubgroup(g,u);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsCharacteristicSubgroup", [IsGroup,IsGroup] );


#############################################################################
##
#F  IsPNilpotent( <G>, <p> )
##
##  <#GAPDoc Label="IsPNilpotent">
##  <ManSection>
##  <Func Name="IsPNilpotent" Arg='G, p'/>
##
##  <Description>
##  A group is <M>p</M>-nilpotent if it possesses a normal <M>p</M>-complement.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "IsPNilpotent", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#F  IsPSolvable( <G>, <p> )
##
##  <#GAPDoc Label="IsPSolvable">
##  <ManSection>
##  <Func Name="IsPSolvable" Arg='G, p'/>
##
##  <Description>
##  A finite group is <M>p</M>-solvable if every chief factor either has
##  order not divisible by <M>p</M>, or is solvable.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "IsPSolvable", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#F  IsSubgroup( <G>, <U> )
##
##  <#GAPDoc Label="IsSubgroup">
##  <ManSection>
##  <Func Name="IsSubgroup" Arg='G, U'/>
##
##  <Description>
##  <C>IsSubgroup</C> returns <K>true</K> if <A>U</A> is a group that is a subset of the
##  domain <A>G</A>.
##  This is actually checked by calling <C>IsGroup( <A>U</A> )</C> and
##  <C>IsSubset( <A>G</A>, <A>U</A> )</C>;
##  note that special methods for <Ref Func="IsSubset"/> are available
##  that test only generators of <A>U</A> if <A>G</A> is closed under the group
##  operations.
##  So in most cases,
##  for example whenever one knows already that <A>U</A> is a group,
##  it is better to call only <Ref Func="IsSubset"/>.
##  <Example><![CDATA[
##  gap> IsSubgroup(g,u);
##  true
##  gap> v:=Group((1,2,3),(1,2));
##  Group([ (1,2,3), (1,2) ])
##  gap> u=v;
##  true
##  gap> IsSubgroup(g,v);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsSubgroup" );


#############################################################################
##
#O  IsSubnormal( <G>, <U> )
##
##  <#GAPDoc Label="IsSubnormal">
##  <ManSection>
##  <Oper Name="IsSubnormal" Arg='G, U'/>
##
##  <Description>
##  A subgroup <A>U</A> of the group <A>G</A> is subnormal if it is contained in a
##  subnormal series of <A>G</A>.
##  <Example><![CDATA[
##  gap> IsSubnormal(g,Group((1,2,3)));
##  false
##  gap> IsSubnormal(g,Group((1,2)(3,4)));
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsSubnormal", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  NormalClosure( <G>, <U> )
##
##  <#GAPDoc Label="NormalClosure">
##  <ManSection>
##  <Oper Name="NormalClosure" Arg='G, U'/>
##
##  <Description>
##  The normal closure of <A>U</A> in <A>G</A> is the smallest normal subgroup 
##  of the closure of <A>G</A> and <A>U</A> which contains <A>U</A>.
##  <Example><![CDATA[
##  gap> NormalClosure(g,Subgroup(g,[(1,2,3)]));
##  Group([ (1,2,3), (2,3,4) ])
##  gap> NormalClosure(g,Group((3,4,5)));
##  Group([ (3,4,5), (1,5,4), (1,2,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "NormalClosure", IsGroup, IsGroup, DeclareAttribute );


#############################################################################
##
#O  NormalIntersection( <G>, <U> )
##
##  <#GAPDoc Label="NormalIntersection">
##  <ManSection>
##  <Oper Name="NormalIntersection" Arg='G, U'/>
##
##  <Description>
##  computes the intersection of <A>G</A> and <A>U</A>, assuming that <A>G</A> is normalized
##  by <A>U</A>. This works faster than <C>Intersection</C>, but will not produce the
##  intersection if <A>G</A> is not normalized by <A>U</A>.
##  <Example><![CDATA[
##  gap> NormalIntersection(Group((1,2)(3,4),(1,3)(2,4)),Group((1,2,3,4)));
##  Group([ (1,3)(2,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NormalIntersection", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  Normalizer( <G>, <U> )
#O  Normalizer( <G>, <g> )
##
##  <#GAPDoc Label="Normalizer">
##  <ManSection>
##  <Heading>Normalizer</Heading>
##  <Oper Name="Normalizer" Arg='G, U' Label="for two groups"/>
##  <Oper Name="Normalizer" Arg='G, g'
##   Label="for a group and a group element"/>
##
##  <Description>
##  For two groups <A>G</A>, <A>U</A>,
##  <Ref Func="Normalizer" Label="for two groups"/> computes the
##  normalizer <M>N_{<A>G</A>}(<A>U</A>)</M>,
##  that is, the stabilizer of <A>U</A>
##  under the conjugation action of <A>G</A>.
##  <P/>
##  For a group <A>G</A> and a group element <A>g</A>,
##  <Ref Func="Normalizer" Label="for a group and a group element"/>
##  computes <M>N_{<A>G</A>}(\langle <A>g</A> \rangle)</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> Normalizer(g,Subgroup(g,[(1,2,3)]));
##  Group([ (1,2,3), (2,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "Normalizer", IsGroup, IsObject, DeclareAttribute );


#############################################################################
##
#O  CentralizerModulo(<G>,<N>,<elm>)   full preimage of C_(G/N)(elm.N)
##
##  <#GAPDoc Label="CentralizerModulo">
##  <ManSection>
##  <Oper Name="CentralizerModulo" Arg='G, N, elm'/>
##
##  <Description>
##  Computes the full preimage of the centralizer
##  <M>C_{{<A>G</A>/<A>N</A>}}(<A>elm</A> \cdot <A>N</A>)</M> in <A>G</A>
##  (without necessarily constructing the factor group).
##  <Example><![CDATA[
##  gap> CentralizerModulo(g,n,(1,2));
##  Group([ (3,4), (1,3)(2,4), (1,4)(2,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("CentralizerModulo", [IsGroup,IsGroup,IsObject]);


#############################################################################
##
#F  PCentralSeries( <G>, <p> )
##
##  <#GAPDoc Label="PCentralSeries">
##  <ManSection>
##  <Oper Name="PCentralSeries" Arg='G, p'/>
##
##  <Description>
##  The <A>p</A>-central series of <A>G</A> is defined by
##  <M>U_1:= <A>G</A></M>,
##  <M>U_i:= [<A>G</A>, U_{{i-1}}] U_{{i-1}}^{<A>p</A>}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "PCentralSeries", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#F  PRump( <G>, <p> )
##
##  <#GAPDoc Label="PRump">
##  <ManSection>
##  <Func Name="PRump" Arg='G, p'/>
##
##  <Description>
##  For a prime <M>p</M>, the <E><A>p</A>-rump</E> of a group <A>G</A> is
##  the subgroup <M><A>G</A>' <A>G</A>^{<A>p</A>}</M>.
##  <P/>
##  <E>@example missing!@</E>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "PRump", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#F  PCore( <G>, <p> )
##
##  <#GAPDoc Label="PCore">
##  <ManSection>
##  <Oper Name="PCore" Arg='G, p'/>
##
##  <Description>
##  <Index Key="Op(G)" Subkey="see PCore"><C>PCore</C></Index>
##  The <E><A>p</A>-core</E> of <A>G</A> is the largest normal
##  <A>p</A>-subgroup of <A>G</A>.
##  It is the core of a Sylow <A>p</A> subgroup of <A>G</A>,
##  see <Ref Func="Core"/>.
##  <Example><![CDATA[
##  gap> PCore(g,2);
##  Group([ (1,4)(2,3), (1,2)(3,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "PCore", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#O  SubnormalSeries( <G>, <U> )
##
##  <#GAPDoc Label="SubnormalSeries">
##  <ManSection>
##  <Oper Name="SubnormalSeries" Arg='G, U'/>
##
##  <Description>
##  If <A>U</A> is a subgroup of <A>G</A> this operation returns a subnormal
##  series that descends from <A>G</A> to a subnormal subgroup
##  <M>V \geq </M><A>U</A>. If <A>U</A> is subnormal, <M>V =</M> <A>U</A>.
##  <Example><![CDATA[
##  gap> s:=SubnormalSeries(g,Group((1,2)(3,4)));
##  [ Group([ (1,2,3,4), (1,2) ]), Group([ (1,2)(3,4), (1,4)(2,3) ]),
##    Group([ (1,2)(3,4) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "SubnormalSeries", IsGroup, IsGroup, DeclareAttribute );


#############################################################################
##
#F  SylowSubgroup( <G>, <p> )
##
##  <#GAPDoc Label="SylowSubgroup">
##  <ManSection>
##  <Oper Name="SylowSubgroup" Arg='G, p'/>
##
##  <Description>
##  returns a Sylow <A>p</A> subgroup of the finite group <A>G</A>.
##  This is a <A>p</A>-subgroup of <A>G</A> whose index in <A>G</A> is
##  coprime to <A>p</A>.
##  <Ref Oper="SylowSubgroup"/> computes Sylow subgroups via the operation
##  <C>SylowSubgroupOp</C>.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(4);;
##  gap> SylowSubgroup(g,2);
##  Group([ (1,2), (3,4), (1,3)(2,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "SylowSubgroup", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#F  SylowComplement( <G>, <p> )
##
##  <#GAPDoc Label="SylowComplement">
##  <ManSection>
##  <Oper Name="SylowComplement" Arg='G, p'/>
##
##  <Description>
##  returns a Sylow <A>p</A>-complement of the finite group <A>G</A>.
##  This is a subgroup <M>U</M> of order coprime to <A>p</A> such that the
##  index <M>[<A>G</A>:U]</M> is a <A>p</A>-power.
##  <P/>
##  At the moment methods exist only if <A>G</A> is solvable and &GAP; will
##  issue an error if <A>G</A> is not solvable.
##  <P/>
##  <Example><![CDATA[
##  gap> SylowComplement(g,3);
##  Group([ (1,2), (3,4), (1,3)(2,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "SylowComplement", IsGroup, IsPosInt, "prime" );


#############################################################################
##
#F  HallSubgroup( <G>, <P> )
##
##  <#GAPDoc Label="HallSubgroup">
##  <ManSection>
##  <Oper Name="HallSubgroup" Arg='G, P'/>
##
##  <Description>
##  computes a <A>P</A>-Hall subgroup for a set <A>P</A> of primes.
##  This is a subgroup the order of which is only divisible by primes in
##  <A>P</A> and whose index is coprime to all primes in <A>P</A>. Such a
##  subgroup is unique up to conjugacy if <A>G</A> is solvable.
##  The function computes Hall subgroups via the operation
##  <C>HallSubgroupOp</C>.
##  <P/>
##  If <A>G</A> is solvable this function always returns a subgroup. If
##  <A>G</A> is not solvable this function might return a subgroup (if it is
##  unique up to conjugacy), a list of subgroups (which are representatives of
##  the conjugacy classes in case there are several such classes) or <K>fail</K>
##  if no such subgroup exists.
##  <Example><![CDATA[
##  gap> h:=SmallGroup(60,10);;
##  gap> u:=HallSubgroup(h,[2,3]);
##  Group([ f1, f2, f3 ])
##  gap> Size(u);
##  12
##  gap> h:=PSL(3,5);;
##  gap> HallSubgroup(h,[2,3]);  
##  [ <permutation group of size 96 with 6 generators>, 
##    <permutation group of size 96 with 6 generators> ]
##  gap> u := HallSubgroup(h,[3,31]);;
##  gap> Size(u); StructureDescription(u);
##  93
##  "C31 : C3"
##  gap> HallSubgroup(h,[5,31]);
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
KeyDependentOperation( "HallSubgroup", IsGroup, IsList, ReturnTrue );


#############################################################################
##
#O  NrConjugacyClassesInSupergroup( <U>, <G> )
##
##  <ManSection>
##  <Oper Name="NrConjugacyClassesInSupergroup" Arg='U, G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "NrConjugacyClassesInSupergroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  Factorization( <G>, <elm> )
##
##  <#GAPDoc Label="Factorization">
##  <ManSection>
##  <Oper Name="Factorization" Arg='G, elm'/>
##
##  <Description>
##  returns a factorization of <A>elm</A> as word in the generators of the
##  group <A>G</A> given in the attribute <Ref Func="GeneratorsOfGroup"/>.
##  The attribute <Ref Func="EpimorphismFromFreeGroup"/> of <A>G</A>
##  will contain a map from the group <A>G</A> to the free group
##  in which the word is expressed.
##  The attribute <Ref Attr="MappingGeneratorsImages"/> of this map gives a
##  list of generators and corresponding letters.
##  <P/>
##  The algorithm used forms all elements of the group to ensure a short
##  word is found. Therefore this function should <E>not</E> be used when the
##  group <A>G</A> has more than a few million elements.
##  Because of this, one should not call this function within algorithms,
##  but use homomorphisms instead.
##  <Example><![CDATA[
##  gap> G:=SymmetricGroup( 6 );;
##  gap> r:=(3,4);; s:=(1,2,3,4,5,6);;
##  gap> # create subgroup to force the system to use the generators r and s:
##  gap> H:= Subgroup(G, [ r, s ] );
##  Group([ (3,4), (1,2,3,4,5,6) ])
##  gap> Factorization( H, (1,2,3) );
##  (x2*x1)^2*x2^-2
##  gap> s*r*s*r*s^-2;
##  (1,2,3)
##  gap> MappingGeneratorsImages(EpimorphismFromFreeGroup(H));
##  [ [ x1, x2 ], [ (3,4), (1,2,3,4,5,6) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Factorization",
                  [ IsGroup, IsMultiplicativeElementWithInverse ] );

#############################################################################
##
#O  GrowthFunctionOfGroup( <G> )
#O  GrowthFunctionOfGroup( <G>, <r> )
##
##  <#GAPDoc Label="GrowthFunctionOfGroup">
##  <ManSection>
##  <Oper Name="GrowthFunctionOfGroup" Arg='G'/>
##  <Oper Name="GrowthFunctionOfGroup" Arg='G, radius' Label="with word length limit"/>
##
##  <Description>
##  For a group <A>G</A> with a generating set given in
##  <Ref Func="GeneratorsOfGroup"/>, 
##  this function calculates the number of elements whose shortest expression as
##  words in the generating set is of a particular length. It returns a list
##  <A>L</A>, whose <M>i+1</M> entry counts the number of elements whose
##  shortest word expression has length <M>i</M>.
##  If a maximal length <A>radius</A> is given, only words up to length
##  <A>radius</A> are counted. Otherwise the group must be finite and all
##  elements are enumerated.
##  <Example><![CDATA[
##  gap> GrowthFunctionOfGroup(MathieuGroup(12));  
##  [ 1, 5, 19, 70, 255, 903, 3134, 9870, 25511, 38532, 16358, 382 ]
##  gap> GrowthFunctionOfGroup(MathieuGroup(12),2);
##  [ 1, 5, 19 ]
##  gap> GrowthFunctionOfGroup(MathieuGroup(12),99);
##  [ 1, 5, 19, 70, 255, 903, 3134, 9870, 25511, 38532, 16358, 382 ]
##  gap> free:=FreeGroup("a","b");
##  <free group on the generators [ a, b ]>
##  gap> product:=free/ParseRelators(free,"a2,b3");
##  <fp group on the generators [ a, b ]>
##  gap> SetIsFinite(product,false);
##  gap> GrowthFunctionOfGroup(product,10);
##  [ 1, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GrowthFunctionOfGroup",IsGroup and HasGeneratorsOfGroup);
DeclareOperation( "GrowthFunctionOfGroup",
                  [ IsGroup and HasGeneratorsOfGroup,IsPosInt]);

#############################################################################
##
#O  GroupByGenerators( <gens> ) . . . . . . . . . . . . . group by generators
#O  GroupByGenerators( <gens>, <id> ) . . . . . . . . . . group by generators
##
##  <#GAPDoc Label="GroupByGenerators">
##  <ManSection>
##  <Oper Name="GroupByGenerators" Arg='gens'/>
##  <Oper Name="GroupByGenerators" Arg='gens, id'
##   Label="with explicitly specified identity element"/>
##
##  <Description>
##  <Ref Oper="GroupByGenerators"/> returns the group <M>G</M> generated by the list <A>gens</A>.
##  If a second argument <A>id</A> is present then this is stored as the identity
##  element of the group.
##  <P/>
##  The value of the attribute <Ref Attr="GeneratorsOfGroup"/> of <M>G</M> need not be equal
##  to <A>gens</A>.
##  <Ref Oper="GroupByGenerators"/> is the underlying operation called by <Ref Func="Group" Label="for several generators"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GroupByGenerators", [ IsCollection ] );
DeclareOperation( "GroupByGenerators",
    [ IsCollection, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#O  GroupWithGenerators( <gens>[, <id>] ) . . . . group with given generators
##
##  <#GAPDoc Label="GroupWithGenerators">
##  <ManSection>
##  <Oper Name="GroupWithGenerators" Arg='gens[, id]'/>
##
##  <Description>
##  <Ref Oper="GroupWithGenerators"/> returns the group <M>G</M> generated by
##  the list <A>gens</A>.
##  If a second argument <A>id</A> is present then this is stored as the
##  identity element of the group.
##  The value of the attribute <Ref Attr="GeneratorsOfGroup"/> of <M>G</M>
##  is equal to <A>gens</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GroupWithGenerators", [ IsCollection ] );
DeclareOperation( "GroupWithGenerators",
    [ IsCollection, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#F  Group( <gen>, ... )
#F  Group( <gens>[, <id>] )
##
##  <#GAPDoc Label="Group">
##  <ManSection>
##  <Func Name="Group" Arg='gen, ...' Label="for several generators"/>
##  <Func Name="Group" Arg='gens[, id]'
##   Label="for a list of generators (and an identity element)"/>
##
##  <Description>
##  <C>Group( <A>gen</A>, ... )</C> is the group generated by the arguments
##  <A>gen</A>, ...
##  <P/>
##  If the only argument <A>gens</A> is a list that is not a matrix then
##  <C>Group( <A>gens</A> )</C> is the group generated by the elements of
##  that list.
##  <P/>
##  If there are two arguments, a list <A>gens</A> and an element <A>id</A>,
##  then <C>Group( <A>gens</A>, <A>id</A> )</C> is the group generated by the
##  elements of <A>gens</A>, with identity <A>id</A>.
##  <P/>
##  Note that the value of the attribute <Ref Func="GeneratorsOfGroup"/>
##  need not be equal to the list <A>gens</A> of generators entered as
##  argument.
##  Use <Ref Func="GroupWithGenerators"/> if you want to be
##  sure that the argument <A>gens</A> is stored as value of
##  <Ref Attr="GeneratorsOfGroup"/>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));
##  Group([ (1,2,3,4), (1,2) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Group" );


#############################################################################
##
#F  Subgroup( <G>, <gens> ) . . . . . . . subgroup of <G> generated by <gens>
#F  SubgroupNC( <G>, <gens> )
#F  Subgroup( <G> )
##
##  <#GAPDoc Label="Subgroup">
##  <ManSection>
##  <Func Name="Subgroup" Arg='G, gens'/>
##  <Func Name="SubgroupNC" Arg='G, gens'/>
##  <Func Name="Subgroup" Arg='G' Label="for a group"/>
##
##  <Description>
##  creates the subgroup <A>U</A> of <A>G</A> generated by <A>gens</A>.
##  The <Ref Func="Parent"/> value of <A>U</A> will be <A>G</A>.
##  The <C>NC</C> version does not check, whether the elements in <A>gens</A>
##  actually lie in <A>G</A>.
##  <P/>
##  The unary version of <Ref Func="Subgroup" Label="for a group"/>
##  creates a (shell) subgroup that does not even
##  know generators but can be used to collect information about a
##  particular subgroup over time.
##  <Example><![CDATA[
##  gap> u:=Subgroup(g,[(1,2,3),(1,2)]);
##  Group([ (1,2,3), (1,2) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "Subgroup", SubmagmaWithInverses );

DeclareSynonym( "SubgroupNC", SubmagmaWithInversesNC );

#############################################################################
##
#F  SubgroupByProperty( <G>, <prop> )
##
##  <#GAPDoc Label="SubgroupByProperty">
##  <ManSection>
##  <Func Name="SubgroupByProperty" Arg='G, prop'/>
##
##  <Description>
##  creates a subgroup of <A>G</A> consisting of those elements fulfilling
##  <A>prop</A> (which is a tester function).
##  No test is done whether the property actually defines a subgroup.
##  <P/>
##  Note that currently very little functionality beyond an element test
##  exists for groups created this way.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubgroupByProperty" );

#############################################################################
##
#A  ElementTestFunction( <G> )
##
##  <ManSection>
##  <Attr Name="ElementTestFunction" Arg='G'/>
##
##  <Description>
##  This attribute contains a function that provides an element test for the
##  group <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ElementTestFunction", IsGroup );

#############################################################################
##
#F  SubgroupShell( <G> )
##
##  <#GAPDoc Label="SubgroupShell">
##  <ManSection>
##  <Func Name="SubgroupShell" Arg='G'/>
##
##  <Description>
##  creates a subgroup of <A>G</A> which at this point is not yet specified
##  further (but will be later, for example by assigning a generating set).
##  <Example><![CDATA[
##  gap> u:=SubgroupByProperty(g,i->3^i=3);
##  <subgrp of Group([ (1,2,3,4), (1,2) ]) by property>
##  gap> (1,3) in u; (1,4) in u; (1,5) in u;
##  false
##  true
##  false
##  gap> GeneratorsOfGroup(u);
##  [ (1,2), (1,4,2) ]
##  gap> u:=SubgroupShell(g);
##  <group>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubgroupShell" );


#############################################################################
##
#C  IsRightTransversal( <obj> )
##
##  <ManSection>
##  <Filt Name="IsRightTransversal" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory("IsRightTransversal",IsCollection);
DeclareCategoryCollections("IsRightTransversal");

#############################################################################
##
#O  RightTransversal( <G>, <U> )
##
##  <#GAPDoc Label="RightTransversal">
##  <ManSection>
##  <Oper Name="RightTransversal" Arg='G, U'/>
##
##  <Description>
##  A right transversal <M>t</M> is a list of representatives for the set
##  <M><A>U</A> \setminus <A>G</A></M> of right
##  cosets (consisting of cosets <M>Ug</M>) of <M>U</M> in <M>G</M>.
##  <P/>
##  The object returned by <Ref Func="RightTransversal"/> is not a
##  plain list, but an object that behaves like an immutable list of length
##  <M>[<A>G</A>:<A>U</A>]</M>,
##  except if <A>U</A> is the trivial subgroup of <A>G</A>
##  in which case <Ref Func="RightTransversal"/> may return the
##  sorted plain list of coset representatives.
##  <P/>
##  The operation <Ref Func="PositionCanonical"/>,
##  called for a transversal <M>t</M>
##  and an element <M>g</M> of <A>G</A>, will return the position of the
##  representative in <M>t</M> that lies in the same coset of <A>U</A> as the
##  element <M>g</M> does.
##  (In comparison, <Ref Func="Position"/> will return <K>fail</K> if the
##  element is not equal to the representative.)
##  Functions that implement group actions such as
##  <Ref Func="Action" Label="for a group, an action domain, etc."/> or
##  <Ref Func="Permutation" Label="for a group, an action domain, etc."/>
##  (see Chapter&nbsp;<Ref Chap="Group Actions"/>)
##  use <Ref Func="PositionCanonical"/>, therefore it is possible to
##  <Q>act</Q> on a right transversal to implement the action on the cosets.
##  This is often much more efficient than acting on cosets.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> u:=Subgroup(g,[(1,2,3),(1,2)]);;
##  gap> rt:=RightTransversal(g,u);
##  RightTransversal(Group([ (1,2,3,4), (1,2) ]),Group([ (1,2,3), (1,2) ]))
##  gap> Length(rt);
##  4
##  gap> Position(rt,(1,2,3));
##  fail
##  ]]></Example>
##  <P/>
##  Note that the elements of a right transversal are not necessarily
##  <Q>canonical</Q> in the sense of
##  <Ref Func="CanonicalRightCosetElement"/>, but we may compute a list of
##  canonical coset representatives by calling that function.
##  (See also <Ref Func="PositionCanonical"/>.)
##  <P/>
##  <Example><![CDATA[
##  gap> List(RightTransversal(g,u),i->CanonicalRightCosetElement(u,i));
##  [ (), (2,3,4), (1,2,3,4), (3,4) ]
##  gap> PositionCanonical(rt,(1,2,3));
##  1
##  gap> rt[1];
##  ()
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "RightTransversal", IsGroup, IsGroup, DeclareAttribute );


#############################################################################
##
#O  IntermediateSubgroups( <G>, <U> )
##
##  <#GAPDoc Label="IntermediateSubgroups">
##  <ManSection>
##  <Oper Name="IntermediateSubgroups" Arg='G, U'/>
##
##  <Description>
##  returns a list of all subgroups of <A>G</A> that properly contain
##  <A>U</A>; that is all subgroups between <A>G</A> and <A>U</A>.
##  It returns a record with a component <C>subgroups</C>, which is a list of
##  these subgroups, as well as a component <C>inclusions</C>,
##  which lists all maximality inclusions among these subgroups.
##  A maximality inclusion is given as a list <M>[i, j]</M> indicating that
##  the subgroup number <M>i</M> is a maximal subgroup of the subgroup number
##  <M>j</M>,
##  the numbers <M>0</M> and <M>1 +</M> <C>Length(subgroups)</C> are used to
##  denote <A>U</A> and <A>G</A>, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IntermediateSubgroups", [IsGroup, IsGroup] );


#############################################################################
##
#A  IsomorphismTypeInfoFiniteSimpleGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismTypeInfoFiniteSimpleGroup">
##  <ManSection>
##  <Heading>IsomorphismTypeInfoFiniteSimpleGroup</Heading>
##  <Attr Name="IsomorphismTypeInfoFiniteSimpleGroup" Arg='G'
##   Label="for a group"/>
##  <Attr Name="IsomorphismTypeInfoFiniteSimpleGroup" Arg='n'
##   Label="for a group order"/>
##
##  <Description>
##  For a finite simple group <A>G</A>,
##  <Ref Func="IsomorphismTypeInfoFiniteSimpleGroup" Label="for a group"/>
##  returns a record with the components <C>series</C>, <C>name</C>
##  and possibly <C>parameter</C>,
##  describing the isomorphism type of <A>G</A>.
##  The component <C>name</C> is a string that gives name(s) for <A>G</A>,
##  and <C>series</C> is a string that describes the following series.
##  <P/>
##  (If different characterizations of <A>G</A> are possible
##  only one is given by <C>series</C> and <C>parameter</C>,
##  while <C>name</C> may give several names.)
##  <List>
##  <Mark><C>"A"</C></Mark>
##  <Item>
##   Alternating groups, <C>parameter</C> gives the natural degree.
##  </Item>
##  <Mark><C>"L"</C></Mark>
##  <Item>
##   Linear groups (Chevalley type <M>A</M>),
##   <C>parameter</C> is a list <M>[ n, q ]</M> that indicates
##   <M>L(n,q)</M>.
##  </Item>
##  <Mark><C>"2A"</C></Mark>
##  <Item>
##   Twisted Chevalley type <M>{}^2A</M>,
##   <C>parameter</C> is a list <M>[ n, q ]</M> that indicates
##   <M>{}^2A(n,q)</M>.
##  </Item>
##  <Mark><C>"B"</C></Mark>
##  <Item>
##   Chevalley type <M>B</M>,
##   <C>parameter</C> is a list <M>[n, q ]</M> that indicates
##   <M>B(n,q)</M>.
##  </Item>
##  <Mark><C>"2B"</C></Mark>
##  <Item>
##   Twisted Chevalley type <M>{}^2B</M>,
##   <C>parameter</C> is a value <M>q</M> that indicates <M>{}^2B(2,q)</M>.
##  </Item>
##  <Mark><C>"C"</C></Mark>
##  <Item>
##   Chevalley type <M>C</M>,
##   <C>parameter</C> is a list <M>[ n, q ]</M> that indicates
##   <M>C(n,q)</M>.
##  </Item>
##  <Mark><C>"D"</C></Mark>
##  <Item>
##   Chevalley type <M>D</M>,
##   <C>parameter</C> is a list <M>[ n, q ]</M> that indicates
##   <M>D(n,q)</M>.
##  </Item>
##  <Mark><C>"2D"</C></Mark>
##  <Item>
##   Twisted Chevalley type <M>{}^2D</M>,
##   <C>parameter</C> is a list <M>[ n, q ]</M> that indicates
##   <M>{}^2D(n,q)</M>.
##  </Item>
##  <Mark><C>"3D"</C></Mark>
##  <Item>
##   Twisted Chevalley type <M>{}^3D</M>,
##   <C>parameter</C> is a value <M>q</M> that indicates <M>{}^3D(4,q)</M>.
##  </Item>
##  <Mark><C>"E"</C></Mark>
##  <Item>
##   Exceptional Chevalley type <M>E</M>,
##   <C>parameter</C> is a list <M>[ n, q ]</M> that indicates
##   <M>E_n(q)</M>.
##   The value of <A>n</A> is 6, 7, or 8.
##  </Item>
##  <Mark><C>"2E"</C></Mark>
##  <Item>
##   Twisted exceptional Chevalley type <M>E_6</M>,
##   <C>parameter</C> is a value <M>q</M> that indicates <M>{}^2E_6(q)</M>.
##  </Item>
##  <Mark><C>"F"</C></Mark>
##  <Item>
##   Exceptional Chevalley type <M>F</M>,
##   <C>parameter</C> is a value <M>q</M> that indicates <M>F(4,q)</M>.
##  </Item>
##  <Mark><C>"2F"</C></Mark>
##  <Item>
##   Twisted exceptional Chevalley type <M>{}^2F</M> (Ree groups),
##   <C>parameter</C> is a value <M>q</M> that indicates <M>{}^2F(4,q)</M>.
##  </Item>
##  <Mark><C>"G"</C></Mark>
##  <Item>
##   Exceptional Chevalley type <M>G</M>,
##   <C>parameter</C> is a value <M>q</M> that indicates <M>G(2,q)</M>.
##  </Item>
##  <Mark><C>"2G"</C></Mark>
##  <Item>
##   Twisted exceptional Chevalley type <M>{}^2G</M> (Ree groups),
##   <C>parameter</C> is a value <M>q</M> that indicates <M>{}^2G(2,q)</M>.
##  </Item>
##  <Mark><C>"Spor"</C></Mark>
##  <Item>
##   Sporadic simple groups, <C>name</C> gives the name.
##  </Item>
##  <Mark><C>"Z"</C></Mark>
##  <Item>
##   Cyclic groups of prime size, <C>parameter</C> gives the size.
##  </Item>
##  </List>
##  <P/>
##  An equal sign in the name denotes different naming schemes for the same
##  group, a tilde sign abstract isomorphisms between groups constructed
##  in a different way.
##  <P/>
##  <Example><![CDATA[
##  gap> IsomorphismTypeInfoFiniteSimpleGroup(
##  >                             Group((4,5)(6,7),(1,2,4)(3,5,6)));
##  rec( 
##    name := "A(1,7) = L(2,7) ~ B(1,7) = O(3,7) ~ C(1,7) = S(2,7) ~ 2A(1,\
##  7) = U(2,7) ~ A(2,2) = L(3,2)", parameter := [ 2, 7 ], series := "L" )
##  ]]></Example>
##  <P/>
##  For a positive integer <A>n</A>,
##  <Ref Func="IsomorphismTypeInfoFiniteSimpleGroup" Label="for a group order"/>
##  returns <K>fail</K> if <A>n</A> is not the order of a finite simple
##  group, and a record as described for the case of a group <A>G</A>
##  otherwise.
##  If more than one simple group of order <A>n</A> exists then the result
##  record contains only the <C>name</C> component, a string that lists the
##  two possible isomorphism types of simple groups of this order.
##  <P/>
##  <Example><![CDATA[
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( 5 );    
##  rec( name := "Z(5)", parameter := 5, series := "Z" )
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( 6 );
##  fail
##  gap> IsomorphismTypeInfoFiniteSimpleGroup(Size(SymplecticGroup(6,3))/2);
##  rec( 
##    name := "cannot decide from size alone between B(3,3) = O(7,3) and C\
##  (3,3) = S(6,3)", parameter := [ 3, 3 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismTypeInfoFiniteSimpleGroup", IsGroup );
DeclareAttribute( "IsomorphismTypeInfoFiniteSimpleGroup", IsPosInt );


#############################################################################
##
#F  SmallSimpleGroup( <order>[, <i>] )
##
##  <#GAPDoc Label="SmallSimpleGroup">
##  <ManSection>
##  <Func Name="SmallSimpleGroup" Arg='order[, i]'/>
##  <Returns>
##    The <A>i</A>th simple group of order <A>order</A> in the stored list,
##    given in a small-degree permutation representation, or <Ref Var="fail"/>
##    if no such simple group exists.
##  </Returns>
##  <Description>
##    If <A>i</A> is not given, it defaults to&nbsp;1.
##    Currently, all simple groups of order less than <M>10^6</M> are
##    available via this function.
##  <Example>
##  gap> SmallSimpleGroup(60);
##  A5
##  gap> SmallSimpleGroup(20160,1);
##  A8
##  gap> SmallSimpleGroup(20160,2);
##  PSL(3,4)
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SmallSimpleGroup" );


#############################################################################
##
#F  AllSmallNonabelianSimpleGroups( <orders> )
##
##  <#GAPDoc Label="AllSmallNonabelianSimpleGroups">
##  <ManSection>
##  <Func Name="AllSmallNonabelianSimpleGroups" Arg='orders'/>
##  <Returns>
##    A list of all nonabelian simple groups whose order lies in the range
##    <A>orders</A>.
##  </Returns>
##  <Description>
##    The groups are given in small-degree permutation representations.
##    The returned list is sorted by ascending group order.
##    Currently, all simple groups of order less than <M>10^6</M> are
##    available via this function.
##  <Example>
##  gap> List(AllSmallNonabelianSimpleGroups([1..1000000]),
##  >         StructureDescription);
##  [ "A5", "PSL(3,2)", "A6", "PSL(2,8)", "PSL(2,11)", "PSL(2,13)", 
##    "PSL(2,17)", "A7", "PSL(2,19)", "PSL(2,16)", "PSL(3,3)", 
##    "PSU(3,3)", "PSL(2,23)", "PSL(2,25)", "M11", "PSL(2,27)", 
##    "PSL(2,29)", "PSL(2,31)", "A8", "PSL(3,4)", "PSL(2,37)", "O(5,3)", 
##    "Sz(8)", "PSL(2,32)", "PSL(2,41)", "PSL(2,43)", "PSL(2,47)", 
##    "PSL(2,49)", "PSU(3,4)", "PSL(2,53)", "M12", "PSL(2,59)", 
##    "PSL(2,61)", "PSU(3,5)", "PSL(2,67)", "J1", "PSL(2,71)", "A9", 
##    "PSL(2,73)", "PSL(2,79)", "PSL(2,64)", "PSL(2,81)", "PSL(2,83)", 
##    "PSL(2,89)", "PSL(3,5)", "M22", "PSL(2,97)", "PSL(2,101)", 
##    "PSL(2,103)", "HJ", "PSL(2,107)", "PSL(2,109)", "PSL(2,113)", 
##    "PSL(2,121)", "PSL(2,125)", "O(5,4)" ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AllSmallNonabelianSimpleGroups" );


#############################################################################
##
#A  IsomorphismPcGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismPcGroup">
##  <ManSection>
##  <Attr Name="IsomorphismPcGroup" Arg='G'/>
##
##  <Description>
##  <Index Subkey="pc group">isomorphic</Index>
##  returns an isomorphism from <A>G</A> onto an isomorphic pc group.
##  The series chosen for this pc representation depends on
##  the method chosen.
##  <A>G</A> must be a polycyclic group of any kind, for example a solvable
##  permutation group.
##  <Example><![CDATA[
##  gap> G := Group( (1,2,3), (3,4,1) );;
##  gap> iso := IsomorphismPcGroup( G );
##  Pcgs([ (2,4,3), (1,2)(3,4), (1,3)(2,4) ]) -> [ f1, f2, f3 ]
##  gap> H := Image( iso );
##  Group([ f1, f2, f3 ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismPcGroup", IsGroup );


#############################################################################
##
#A  IsomorphismSpecialPcGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismSpecialPcGroup">
##  <ManSection>
##  <Attr Name="IsomorphismSpecialPcGroup" Arg='G'/>
##
##  <Description>
##  returns an isomorphism from <A>G</A> onto an isomorphic pc group
##  whose family pcgs is a special pcgs.
##  (This can be beneficial to the runtime of calculations.)
##  <A>G</A> may be a polycyclic group of any kind, for example a solvable
##  permutation group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismSpecialPcGroup", IsGroup );


#############################################################################
##
#A  IsomorphismPermGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismPermGroup">
##  <ManSection>
##  <Attr Name="IsomorphismPermGroup" Arg='G'/>
##
##  <Description>
##  returns an isomorphism from the group <A>G</A> onto a permutation group
##  which is isomorphic to <A>G</A>.
##  The method will select a suitable permutation representation.
##  <Example><![CDATA[
##  gap> g:=SmallGroup(24,12);
##  <pc group of size 24 with 4 generators>
##  gap> iso:=IsomorphismPermGroup(g);
##  <action isomorphism>
##  gap> Image(iso,g.3*g.4);
##  (1,12)(2,16)(3,19)(4,5)(6,22)(7,8)(9,23)(10,11)(13,24)(14,15)(17,
##  18)(20,21)
##  ]]></Example>
##  <P/>
##  In many cases the permutation representation constructed by
##  <Ref Func="IsomorphismPermGroup"/> is regular.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("IsomorphismPermGroup",IsSemigroup);


#############################################################################
##
#A  IsomorphismFpGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismFpGroup">
##  <ManSection>
##  <Attr Name="IsomorphismFpGroup" Arg='G'/>
##
##  <Description>
##  returns an isomorphism from the given finite group <A>G</A> to a finitely
##  presented group isomorphic to <A>G</A>.
##  The function first <E>chooses a set of generators of <A>G</A></E>
##  and then computes a presentation in terms of these generators.
##  <Example><![CDATA[
##  gap> g := Group( (2,3,4,5), (1,2,5) );;
##  gap> iso := IsomorphismFpGroup( g );
##  [ (4,5), (1,2,3,4,5), (1,3,2,4,5) ] -> [ F1, F2, F3 ]
##  gap> fp := Image( iso );
##  <fp group on the generators [ F1, F2, F3 ]>
##  gap> RelatorsOfFpGroup( fp );
##  [ F1^2, F1^-1*F2*F1*F2^-1*F3*F2^-2, F1^-1*F3*F1*F2*F3^-1*F2*F3*F2^-1, 
##    F2^5*F3^-5, F2^5*(F3^-1*F2^-1)^2, (F2^-2*F3^2)^2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismFpGroup", IsGroup );


#############################################################################
##
#A  IsomorphismFpGroupByGenerators( <G>,<gens>[,<string>] )
#A  IsomorphismFpGroupByGeneratorsNC( <G>,<gens>,<string> )
##
##  <#GAPDoc Label="IsomorphismFpGroupByGenerators">
##  <ManSection>
##  <Attr Name="IsomorphismFpGroupByGenerators" Arg='G,gens[,string]'/>
##  <Attr Name="IsomorphismFpGroupByGeneratorsNC" Arg='G,gens,string'/>
##
##  <Description>
##  returns an isomorphism from a finite group <A>G</A>
##  to a finitely presented group <A>F</A> isomorphic to <A>G</A>.
##  The generators of <A>F</A> correspond to the
##  <E>generators of <A>G</A> given in the list <A>gens</A></E>.
#   If <A>string</A> is given it is used to name the generators of the
##  finitely presented group.
##  <P/>
##  The <C>NC</C> version will avoid testing whether the elements in
##  <A>gens</A> generate <A>G</A>.
##  <Example><![CDATA[
##  gap> SetInfoLevel( InfoFpGroup, 1 );
##  gap> iso := IsomorphismFpGroupByGenerators( g, [ (1,2), (1,2,3,4,5) ] );
##  #I  the image group has 2 gens and 5 rels of total length 39
##  [ (1,2), (1,2,3,4,5) ] -> [ F1, F2 ]
##  gap> fp := Image( iso );
##  <fp group of size 120 on the generators [ F1, F2 ]>
##  gap> RelatorsOfFpGroup( fp );
##  [ F1^2, F2^5, (F2^-1*F1)^4, (F2^-1*F1*F2*F1)^3, (F2^2*F1*F2^-2*F1)^2 ]
##  ]]></Example>
##  <P/>
##  The main task of the function
##  <Ref Func="IsomorphismFpGroupByGenerators"/> is to find a presentation of
##  <A>G</A> in the provided generators <A>gens</A>.
##  In the case of a permutation group <A>G</A> it does this by first
##  constructing a stabilizer chain of <A>G</A> and then it works through
##  that chain from the bottom to the top, recursively computing a
##  presentation for each of the involved stabilizers.
##  The method used is essentially an implementation of John Cannon's
##  multi-stage relations-finding algorithm as described in
##  <Cite Key="Neu82"/> (see also <Cite Key="Can73"/> for a more graph
##  theoretical description).
##  Moreover, it makes heavy use of Tietze transformations in each stage to
##  avoid an explosion of the total length of the relators.
##  <P/>
##  Note that because of the random methods involved in the construction of
##  the stabilizer chain the resulting presentations of <A>G</A> will in
##  general be different for repeated calls with the same arguments.
##  <P/>
##  <Example><![CDATA[
##  gap> M12 := MathieuGroup( 12 );
##  Group([ (1,2,3,4,5,6,7,8,9,10,11), (3,7,11,8)(4,10,5,6), 
##    (1,12)(2,11)(3,6)(4,8)(5,9)(7,10) ])
##  gap> gens := GeneratorsOfGroup( M12 );;
##  gap> iso := IsomorphismFpGroupByGenerators( M12, gens );;
##  #I  the image group has 3 gens and 23 rels of total length 628
##  gap> iso := IsomorphismFpGroupByGenerators( M12, gens );;
##  #I  the image group has 3 gens and 23 rels of total length 569
##  ]]></Example>
##  <P/>
##  Also in the case of a permutation group <A>G</A>, the function
##  <Ref Func="IsomorphismFpGroupByGenerators"/> supports the option
##  <C>method</C> that can be used to modify the strategy.
##  The option <C>method</C> may take the following values.
##  <P/>
##  <List>
##  <Mark><C>method := "regular"</C></Mark>
##  <Item>
##    This may be specified for groups of small size, up to <M>10^5</M> say.
##    It implies that the function first constructs a regular representation
##    <A>R</A> of <A>G</A> and then a presentation of <A>R</A>.
##    In general, this presentation will be much more concise than the
##    default one, but the price is the time needed for the construction of
##    <A>R</A>.
##  </Item>
##  <Mark><C>method := [ "regular", bound ]</C></Mark>
##  <Item>
##    This is a refinement of the previous possibility.
##    In this case, <C>bound</C> should be an integer, and if so the method
##    <C>"regular"</C> as described above is applied to the largest
##    stabilizer in the stabilizer chain of <A>G</A> whose size does not
##    exceed the given bound and then the multi-stage algorithm is used to
##    work through the chain from that subgroup to the top.
##  </Item>
##  <Mark><C>method := "fast"</C></Mark>
##  <Item>
##    This chooses an alternative method which essentially is a kind of
##    multi-stage algorithm for a stabilizer chain of <A>G</A> but does not
##    make any attempt do reduce the number of relators as it is done in
##    Cannon's algorithm or to reduce their total length.
##    Hence it is often much faster than the default method, but the total
##    length of the resulting presentation may be huge.
##  </Item>
##  <Mark><C>method := "default"</C></Mark>
##  <Item>
##    This simply means that the default method shall be used, which is the
##    case if the option <C>method</C> is not given a value.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> iso := IsomorphismFpGroupByGenerators( M12, gens : 
##  >                                           method := "regular" );;
##  #I  the image group has 3 gens and 11 rels of total length 92
##  gap> iso := IsomorphismFpGroupByGenerators( M12, gens : 
##  >                                           method := "fast" );;
##  #I  the image group has 3 gens and 150 rels of total length 3336
##  ]]></Example>
##  <P/>
##  Though the option <C>method := "regular"</C> is only checked in the case
##  of a permutation group it also affects the performance and the results of
##  the function <Ref Func="IsomorphismFpGroupByGenerators"/> for other
##  groups, e. g. for matrix groups.
##  This happens because, for these groups, the function first calls the
##  function <Ref Func="NiceMonomorphism"/> to get a bijective action
##  homomorphism from <A>G</A> to a suitable permutation group,
##  <M>P</M> say, and then, recursively, calls itself for the group <M>P</M>
##  so that now the option becomes relevant.
##  <P/>
##  <Example><![CDATA[
##  gap> G := ImfMatrixGroup( 5, 1, 3 );
##  ImfMatrixGroup(5,1,3)
##  gap> gens := GeneratorsOfGroup( G );
##  [ [ [ -1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 0, 1, 0 ], 
##        [ -1, -1, -1, -1, 2 ], [ -1, 0, 0, 0, 1 ] ], 
##    [ [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ], 
##        [ 1, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 1 ] ] ]
##  gap> iso := IsomorphismFpGroupByGenerators( G, gens );;
##  #I  the image group has 2 gens and 10 rels of total length 126
##  gap> iso := IsomorphismFpGroupByGenerators( G, gens : 
##  >                                           method := "regular");;
##  #I  the image group has 2 gens and 6 rels of total length 56
##  gap> SetInfoLevel( InfoFpGroup, 0 );
##  gap> iso;
##  <composed isomorphism:[ [ [ -1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, \
##  0, 0, 1, 0 ], [ -1, -1, -1, -1, 2 ], [ -1, 0, 0, 0, 1 ] ], [ [ 0, 1, 0\
##  , 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ], [ 1, 0, 0, 0, 0 ], [ 0\
##  , 0, 0, 0, 1 ] ] ]->[ F1, F2 ]>
##  gap> ConstituentsCompositionMapping(iso);
##  [ <action isomorphism>, 
##    [ (2,3,4)(5,6)(8,9,10), (1,2,3,5)(6,7,8,9) ] -> [ F1, F2 ] ]
##  ]]></Example>
##  <P/>
##  Since &GAP; cannot decompose elements of a matrix group into generators,
##  the resulting isomorphism is stored as a composition of a (faithful)
##  permutation action on vectors and a homomorphism from the permutation image
##  to the finitely presented group. In such a situation the constituent
##  mappings can be obtained via <Ref Func="ConstituentsCompositionMapping"/>
##  as separate &GAP; objects.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IsomorphismFpGroupByGenerators");
DeclareOperation( "IsomorphismFpGroupByGeneratorsNC",
    [ IsGroup, IsList, IsString ] );

DeclareOperation(
    "IsomorphismFpGroupBySubnormalSeries", [IsGroup, IsList, IsString] );

DeclareOperation(
    "IsomorphismFpGroupByCompositionSeries", [IsGroup, IsString] );

DeclareOperation(
    "IsomorphismFpGroupByChiefSeries", [IsGroup, IsString] );

DeclareGlobalFunction( "IsomorphismFpGroupByPcgs" );


#############################################################################
##
#A  PrimePowerComponents( <g> )
##
##  <ManSection>
##  <Attr Name="PrimePowerComponents" Arg='g'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "PrimePowerComponents", IsMultiplicativeElement );


#############################################################################
##
#O  PrimePowerComponent( <g>, <p> )
##
##  <ManSection>
##  <Oper Name="PrimePowerComponent" Arg='g, p'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "PrimePowerComponent",
    [ IsMultiplicativeElement, IsPosInt ] );


#############################################################################
##
#O  PowerMapOfGroup( <G>, <n>, <ccl> )
##
##  <ManSection>
##  <Oper Name="PowerMapOfGroup" Arg='G, n, ccl'/>
##
##  <Description>
##  is a list of positions,
##  at position <M>i</M> the position of the conjugacy class containing
##  the <A>n</A>-th powers of the elements in the <M>i</M>-th class
##  of the list <A>ccl</A> of conjugacy classes.
##  </Description>
##  </ManSection>
##
DeclareOperation( "PowerMapOfGroup", [ IsGroup, IsInt, IsHomogeneousList ] );


#############################################################################
##
#F  PowerMapOfGroupWithInvariants( <G>, <n>, <ccl>, <invariants> )
##
##  <ManSection>
##  <Func Name="PowerMapOfGroupWithInvariants" Arg='G, n, ccl, invariants'/>
##
##  <Description>
##  is a list of integers, at position <M>i</M> the position of the conjugacy
##  class containimg the <A>n</A>-th powers of elements in class <M>i</M>
##  of <A>ccl</A>.
##  The list <A>invariants</A> contains all invariants besides element order
##  that shall be used before membership tests.
##  <P/>
##  Element orders are tested first in any case since they may allow a
##  decision without forming the <A>n</A>-th powers of elements.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PowerMapOfGroupWithInvariants" );


#############################################################################
##
#O  HasAbelianFactorGroup( <G>, <N> )
##
##  <#GAPDoc Label="HasAbelianFactorGroup">
##  <ManSection>
##  <Oper Name="HasAbelianFactorGroup" Arg='G, N'/>
##
##  <Description>
##  tests whether <A>G</A> <M>/</M> <A>N</A> is abelian
##  (without explicitly constructing the factor group).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("HasAbelianFactorGroup");

#############################################################################
##
#O  HasSolvableFactorGroup( <G>, <N> )
##
##  <#GAPDoc Label="HasSolvableFactorGroup">
##  <ManSection>
##  <Oper Name="HasSolvableFactorGroup" Arg='G, N'/>
##
##  <Description>
##  tests whether <A>G</A> <M>/</M> <A>N</A> is solvable
##  (without explicitly constructing the factor group).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("HasSolvableFactorGroup");


#############################################################################
##
#O  HasElementaryAbelianFactorGroup( <G>, <N> )
##
##  <#GAPDoc Label="HasElementaryAbelianFactorGroup">
##  <ManSection>
##  <Oper Name="HasElementaryAbelianFactorGroup" Arg='G, N'/>
##
##  <Description>
##  tests whether <A>G</A> <M>/</M> <A>N</A> is elementary abelian
##  (without explicitly constructing the factor group).
##  <Example><![CDATA[
##  gap> HasAbelianFactorGroup(g,n);
##  false
##  gap> HasAbelianFactorGroup(DerivedSubgroup(g),n);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("HasElementaryAbelianFactorGroup");


#############################################################################
##
#F  IsGroupOfFamily(<G>)
##
##  <ManSection>
##  <Func Name="IsGroupOfFamily" Arg='G'/>
##
##  <Description>
##  This filter indicates that the group <A>G</A> is the group
##  which is stored in the family <A>fam</A> of its elements
##  as <C><A>fam</A>!.wholeGroup</C>.
##  </Description>
##  </ManSection>
##
DeclareFilter("IsGroupOfFamily");


#############################################################################
##
#F  Group_PseudoRandom(<G>)
##
##  <ManSection>
##  <Func Name="Group_PseudoRandom" Arg='G'/>
##
##  <Description>
##  Computes a pseudo-random element of <A>G</A> by product replacement.
##  (This is installed as a method for <C>PseudoRandom</C>
##  under the condition that generators are known.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("Group_PseudoRandom");

DeclareGlobalFunction("GroupEnumeratorByClosure");

#############################################################################
##
#E

