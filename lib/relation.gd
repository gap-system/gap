#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for binary relations on sets.
##
##  Maintenance and further development by:
##  Robert Arthur
##  Robert F. Morse
##  Andrew Solomon
##


##
##  <#GAPDoc Label="[1]{relation}">
##  <Index>binary relation</Index>
##  <Index Key="IsBinaryRelation" Subkey="same as IsEndoGeneralMapping">
##  <C>IsBinaryRelation</C></Index>
##  <Index Key="IsEndoGeneralMapping" Subkey="same as IsBinaryRelation">
##  <C>IsEndoGeneralMapping</C></Index>
##  A <E>binary relation</E> <M>R</M> on a set <M>X</M> is a subset of
##  <M>X \times X</M>.
##  A binary relation can also be thought of as a (general) mapping
##  from <M>X</M> to itself or as a directed graph where each edge
##  represents an element of <M>R</M>.
##  <P/>
##  In &GAP;, a relation is conceptually represented as a general mapping
##  from <M>X</M> to itself.
##  The category <Ref Prop="IsBinaryRelation"/> is a synonym for
##  <Ref Prop="IsEndoGeneralMapping"/>.
##  Attributes and properties of relations in &GAP; are supported for
##  relations, via considering relations as a subset of <M>X \times X</M>,
##  or as a directed graph;
##  examples include finding the strongly connected components of a relation,
##  via <Ref Oper="StronglyConnectedComponents"/>,
##  or enumerating the tuples of the relation.
##  <#/GAPDoc>
##


##  The hierarchy of concepts around binary relations on a set are:
##
##  IsGeneralMapping >
##
##  IsEndoGeneralMapping [ = IsBinaryRelation] >
##
##  [IsEquivalenceRelation]
##
##
#############################################################################

#############################################################################
##
## General Binary Relations
##
#############################################################################

#############################################################################
##
#C  IsBinaryRelation( <R> )
##
##  <#GAPDoc Label="IsBinaryRelation">
##  <ManSection>
##  <Prop Name="IsBinaryRelation" Arg='R'/>
##
##  <Description>
##  is   exactly   the   same   category   as   (i.e.    a    synonym    for)
##  <Ref Prop="IsEndoGeneralMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym("IsBinaryRelation",IsEndoGeneralMapping);


#############################################################################
##
#F  BinaryRelationOnPoints( <list> )
#F  BinaryRelationOnPointsNC( <list> )
##
##  <#GAPDoc Label="BinaryRelationOnPoints">
##  <ManSection>
##  <Func Name="BinaryRelationOnPoints" Arg='list'/>
##  <Func Name="BinaryRelationOnPointsNC" Arg='list'/>
##
##  <Description>
##  Given a list of <M>n</M> lists,
##  each containing elements from the set <M>\{ 1, \ldots, n \}</M>,
##  this function constructs a binary relation such that <M>1</M> is related
##  to <A>list</A><C>[1]</C>, <M>2</M> to <A>list</A><C>[2]</C> and so on.
##  The first version checks whether the list supplied is valid.
##  The <C>NC</C> version skips this check.
##  <Example><![CDATA[
##  gap> R:=BinaryRelationOnPoints([[1,2],[2],[3]]);
##  Binary Relation on 3 points
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("BinaryRelationOnPoints");
DeclareGlobalFunction("BinaryRelationOnPointsNC");

#############################################################################
##
#F  RandomBinaryRelationOnPoints( <degree> )
##
##  <#GAPDoc Label="RandomBinaryRelationOnPoints">
##  <ManSection>
##  <Func Name="RandomBinaryRelationOnPoints" Arg='degree'/>
##
##  <Description>
##  creates a relation on points with degree <A>degree</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RandomBinaryRelationOnPoints");

#############################################################################
##
#F  IdentityBinaryRelation( <degree> )
#F  IdentityBinaryRelation( <domain> )
##
##  <#GAPDoc Label="IdentityBinaryRelation">
##  <ManSection>
##  <Heading>IdentityBinaryRelation</Heading>
##  <Func Name="IdentityBinaryRelation" Arg='degree' Label="for a degree"/>
##  <Func Name="IdentityBinaryRelation" Arg='domain' Label="for a domain"/>
##
##  <Description>
##  is the binary relation which consists of diagonal pairs, i.e., pairs of
##  the form <M>(x,x)</M>.
##  In the first form if a positive integer <A>degree</A> is given then
##  the domain is the set of the integers
##  <M>\{ 1, \ldots, <A>degree</A> \}</M>.
##  In the second form, the objects <M>x</M> are from the domain
##  <A>domain</A>.
##  <Example><![CDATA[
##  gap> IdentityBinaryRelation(5);
##  <equivalence relation on Domain([ 1 .. 5 ]) >
##  gap> s4:=SymmetricGroup(4);
##  Sym( [ 1 .. 4 ] )
##  gap> IdentityBinaryRelation(s4);
##  IdentityMapping( Sym( [ 1 .. 4 ] ) )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IdentityBinaryRelation");

#############################################################################
##
#F  BinaryRelationByElements( <domain>, <elms> )
##
##  <#GAPDoc Label="BinaryRelationByElements">
##  <ManSection>
##  <Func Name="BinaryRelationByElements" Arg='domain, elms'/>
##
##  <Description>
##  is the binary relation on <A>domain</A> and with underlying relation
##  consisting of the tuples collection <A>elms</A>.
##  This construction is similar to <Ref Func="GeneralMappingByElements"/>
##  where the source and range are the same set.
##  <Example><![CDATA[
##  gap> r:=BinaryRelationByElements(Domain([1..3]),[DirectProductElement([1,2]),DirectProductElement([1,3])]);
##  <general mapping: Domain([ 1 .. 3 ]) -> Domain([ 1 .. 3 ]) >
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("BinaryRelationByElements");

#############################################################################
##
#F  EmptyBinaryRelation( <degree> )
#F  EmptyBinaryRelation( <domain> )
##
##  <#GAPDoc Label="EmptyBinaryRelation">
##  <ManSection>
##  <Func Name="EmptyBinaryRelation" Arg='degree' Label="for a degree"/>
##  <Func Name="EmptyBinaryRelation" Arg='domain' Label="for a domain"/>
##
##  <Description>
##  is the relation with <A>R</A> empty.
##  In the first form of the command with <A>degree</A> an integer,
##  the domain is the set of points <M>\{ 1, \ldots, <A>degree</A> \}</M>.
##  In the second form, the domain is that given by the argument
##  <A>domain</A>.
##  <Example><![CDATA[
##  gap> EmptyBinaryRelation(3) = BinaryRelationOnPoints([ [], [], [] ]);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EmptyBinaryRelation");

#############################################################################
##
#F  AsBinaryRelationOnPoints( <trans> )
#F  AsBinaryRelationOnPoints( <perm> )
#F  AsBinaryRelationOnPoints( <rel> )
##
##  <#GAPDoc Label="AsBinaryRelationOnPoints">
##  <ManSection>
##  <Heading>AsBinaryRelationOnPoints</Heading>
##  <Func Name="AsBinaryRelationOnPoints" Arg='trans'
##   Label="for a transformation"/>
##  <Func Name="AsBinaryRelationOnPoints" Arg='perm'
##   Label="for a permutation"/>
##  <Func Name="AsBinaryRelationOnPoints" Arg='rel'
##   Label="for a binary relation"/>
##
##  <Description>
##  return the relation on points represented by general relation <A>rel</A>,
##  transformation <A>trans</A> or permutation <A>perm</A>.
##  If <A>rel</A> is already a binary relation on points then <A>rel</A> is
##  returned.
##  <P/>
##  Transformations and permutations are special general endomorphic
##  mappings and have a natural representation as a binary relation on
##  points.
##  <P/>
##  In the last form, an isomorphic relation on points is constructed
##  where the points are indices of the elements of the underlying domain
##  in sorted order.
##  <Example><![CDATA[
##  gap> t:=Transformation([2,3,1]);;
##  gap> r1:=AsBinaryRelationOnPoints(t);
##  Binary Relation on 3 points
##  gap> r2:=AsBinaryRelationOnPoints((1,2,3));
##  Binary Relation on 3 points
##  gap> r1=r2;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AsBinaryRelationOnPoints");

###############################################################################
##
#A  Successors( <R> )
##
##  <#GAPDoc Label="Successors">
##  <ManSection>
##  <Attr Name="Successors" Arg='R'/>
##
##  <Description>
##  returns the list of images of a binary relation <A>R</A>.
##  If the underlying domain of the relation is not <M>\{ 1, \ldots, n \}</M>,
##  for some positive integer <M>n</M>, then an error is signalled.
##  <P/>
##  The returned value of <Ref Attr="Successors"/> is a list of lists where
##  the lists are ordered as the elements according to the sorted order of
##  the underlying set of <A>R</A>.
##  Each list consists of the images of the element whose index is the same
##  as the list with the underlying set in sorted order.
##  <P/>
##  The <Ref Attr="Successors"/> of a relation is the adjacency list
##  representation of the relation.
##  <Example><![CDATA[
##  gap> r1:=BinaryRelationOnPoints([[2],[3],[1]]);;
##  gap> Successors(r1);
##  [ [ 2 ], [ 3 ], [ 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Successors", IsBinaryRelation);

###############################################################################
##
#A  DegreeOfBinaryRelation(<R>)
##
##  <#GAPDoc Label="DegreeOfBinaryRelation">
##  <ManSection>
##  <Attr Name="DegreeOfBinaryRelation" Arg='R'/>
##
##  <Description>
##  returns the size of the underlying domain of the binary relation
##  <A>R</A>.
##  This is most natural when working with a binary relation on points.
##  <Example><![CDATA[
##  gap> DegreeOfBinaryRelation(r1);
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("DegreeOfBinaryRelation", IsBinaryRelation);

############################################################################
##
#A  UnderlyingDomainOfBinaryRelation(<R>)
##
##  <ManSection>
##  <Attr Name="UnderlyingDomainOfBinaryRelation" Arg='R'/>
##
##  <Description>
##  is a synonym for <Ref Func="Source"/>.
##  </Description>
##  </ManSection>
##
DeclareSynonym("UnderlyingDomainOfBinaryRelation",Source);

#############################################################################
##
##  Properties of binary relations.
##
#############################################################################

#############################################################################
##
#P  IsReflexiveBinaryRelation(<R>)
##
##  <#GAPDoc Label="IsReflexiveBinaryRelation">
##  <ManSection>
##  <Prop Name="IsReflexiveBinaryRelation" Arg='R'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>R</A> is reflexive,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>reflexive relation</Index>
##  A binary relation <M>R</M> (as a set of pairs) on a set <M>X</M> is
##  <E>reflexive</E> if for all <M>x \in X</M>, <M>(x,x) \in R</M>.
##  Alternatively, <M>R</M> as a mapping
##  is reflexive if for all <M>x \in X</M>,
##  <M>x</M> is an element of the image set <M>R(x)</M>.
##  <P/>
##  A reflexive binary relation is necessarily a total endomorphic
##  mapping (tested via <Ref Prop="IsTotal"/>).
##  <Example><![CDATA[
##  gap> IsReflexiveBinaryRelation(BinaryRelationOnPoints([[1,3],[2],[3]]));
##  true
##  gap> IsReflexiveBinaryRelation(BinaryRelationOnPoints([[2],[2]]));
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsReflexiveBinaryRelation", IsBinaryRelation);

#############################################################################
##
#P  IsSymmetricBinaryRelation(<R>)
##
##  <#GAPDoc Label="IsSymmetricBinaryRelation">
##  <ManSection>
##  <Prop Name="IsSymmetricBinaryRelation" Arg='R'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>R</A> is symmetric,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>symmetric relation</Index>
##  A binary relation <M>R</M> (as a set of pairs) on a set <M>X</M> is
##  <E>symmetric</E> if <M>(x,y) \in R</M> then <M>(y,x) \in R</M>.
##  Alternatively, <M>R</M> as a mapping is symmetric
##  if for all <M>x \in X</M>, the preimage set of <M>x</M> under <M>R</M>
##  equals the image set <M>R(x)</M>.
##  <Example><![CDATA[
##  gap> IsSymmetricBinaryRelation(BinaryRelationOnPoints([[2],[1]]));
##  true
##  gap> IsSymmetricBinaryRelation(BinaryRelationOnPoints([[2],[2]]));
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsSymmetricBinaryRelation", IsBinaryRelation);

#############################################################################
##
#P  IsTransitiveBinaryRelation(<R>)
##
##  <#GAPDoc Label="IsTransitiveBinaryRelation">
##  <ManSection>
##  <Prop Name="IsTransitiveBinaryRelation" Arg='R'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>R</A> is transitive,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>transitive relation</Index>
##  A binary relation <A>R</A> (as a set of pairs) on a set <M>X</M> is
##  <E>transitive</E> if <M>(x,y), (y,z) \in R</M> implies
##  <M>(x,z) \in R</M>.
##  Alternatively, <M>R</M> as a mapping is transitive if for all
##  <M>x \in X</M>, the image set <M>R(R(x))</M> of the image
##  set <M>R(x)</M> of <M>x</M> is a subset of <M>R(x)</M>.
##  <Example><![CDATA[
##  gap> IsTransitiveBinaryRelation(BinaryRelationOnPoints([[1,2,3],[2,3],[]]));
##  true
##  gap> IsTransitiveBinaryRelation(BinaryRelationOnPoints([[1,2],[2,3],[]]));
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsTransitiveBinaryRelation", IsBinaryRelation);

#############################################################################
##
#P  IsAntisymmetricBinaryRelation(<rel>)
##
##  <#GAPDoc Label="IsAntisymmetricBinaryRelation">
##  <ManSection>
##  <Prop Name="IsAntisymmetricBinaryRelation" Arg='rel'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>rel</A> is antisymmetric,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>antisymmetric relation</Index>
##  A binary relation <A>R</A> (as a set of pairs) on a set <M>X</M> is
##  <E>antisymmetric</E> if <M>(x,y), (y,x) \in R</M> implies <M>x = y</M>.
##  Alternatively, <M>R</M> as a mapping is antisymmetric if for all
##  <M>x \in X</M>, the intersection of the preimage set of <M>x</M>
##  under <M>R</M> and the image set <M>R(x)</M> is <M>\{ x \}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsAntisymmetricBinaryRelation",IsBinaryRelation);

#############################################################################
##
#P  IsPreOrderBinaryRelation(<rel>)
##
##  <#GAPDoc Label="IsPreOrderBinaryRelation">
##  <ManSection>
##  <Prop Name="IsPreOrderBinaryRelation" Arg='rel'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>rel</A> is a preorder,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>preorder</Index>
##  A <E>preorder</E> is a binary relation that is both reflexive and
##  transitive.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsPreOrderBinaryRelation",IsBinaryRelation);

#############################################################################
##
#P  IsPartialOrderBinaryRelation(<rel>)
##
##  <#GAPDoc Label="IsPartialOrderBinaryRelation">
##  <ManSection>
##  <Prop Name="IsPartialOrderBinaryRelation" Arg='rel'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>rel</A> is a partial order,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>partial order</Index>
##  A <E>partial order</E> is a preorder which is also antisymmetric.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsPartialOrderBinaryRelation",IsBinaryRelation);

InstallTrueMethod(IsPreOrderBinaryRelation, IsReflexiveBinaryRelation and
    IsTransitiveBinaryRelation);
InstallTrueMethod(IsPartialOrderBinaryRelation, IsPreOrderBinaryRelation and
    IsAntisymmetricBinaryRelation);
InstallTrueMethod(IsTotal, IsReflexiveBinaryRelation);

#############################################################################
##
#P  IsLatticeOrderBinaryRelation(<rel>)
##
##  <ManSection>
##  <Prop Name="IsLatticeOrderBinaryRelation" Arg='rel'/>
##
##  <Description>
##  return <K>true</K> if the binary relation is a lattice order,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>lattice order</Index>
##  A <E>lattice order</E> is a partial order in which each pair of elements
##  has a greatest lower bound and a least upper bound.
##  </Description>
##  </ManSection>
##
DeclareProperty("IsLatticeOrderBinaryRelation",IsBinaryRelation);

InstallTrueMethod(IsPartialOrderBinaryRelation, IsLatticeOrderBinaryRelation);

############################################################################
##
## Equivalence Relations
##
#############################################################################

#############################################################################
##
#P  IsEquivalenceRelation( <R> )
##
##  <#GAPDoc Label="IsEquivalenceRelation">
##  <ManSection>
##  <Prop Name="IsEquivalenceRelation" Arg='R'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>R</A> is an equivalence
##  relation, and <K>false</K> otherwise.
##  <P/>
##  <Index>equivalence relation</Index>
##  Recall, that a relation <A>R</A> is an <E>equivalence relation</E>
##  if it is symmetric, transitive, and reflexive.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsEquivalenceRelation", IsBinaryRelation);

InstallTrueMethod(IsBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsReflexiveBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsTransitiveBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsSymmetricBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsEquivalenceRelation,
    IsReflexiveBinaryRelation and
    IsTransitiveBinaryRelation and IsSymmetricBinaryRelation);

#############################################################################
##
##  Closure operations for binary relations.
##
#############################################################################

#############################################################################
##
#O  ReflexiveClosureBinaryRelation( <R> )
##
##  <#GAPDoc Label="ReflexiveClosureBinaryRelation">
##  <ManSection>
##  <Oper Name="ReflexiveClosureBinaryRelation" Arg='R'/>
##
##  <Description>
##  is the smallest binary relation containing the binary relation <A>R</A>
##  which is reflexive.
##  This closure inherits the properties symmetric and transitive from
##  <A>R</A>.
##  E.g., if <A>R</A> is symmetric then its reflexive closure
##  is also.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ReflexiveClosureBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#O  SymmetricClosureBinaryRelation( <R> )
##
##  <#GAPDoc Label="SymmetricClosureBinaryRelation">
##  <ManSection>
##  <Oper Name="SymmetricClosureBinaryRelation" Arg='R'/>
##
##  <Description>
##  is the smallest binary relation containing the binary relation <A>R</A>
##  which is symmetric.
##  This closure inherits the properties reflexive and transitive from
##  <A>R</A>.
##  E.g., if <A>R</A> is reflexive then its symmetric closure is also.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("SymmetricClosureBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#O  TransitiveClosureBinaryRelation( <rel> )
##
##  <#GAPDoc Label="TransitiveClosureBinaryRelation">
##  <ManSection>
##  <Oper Name="TransitiveClosureBinaryRelation" Arg='rel'/>
##
##  <Description>
##  is the smallest binary relation containing the binary relation <A>R</A>
##  which is transitive.
##  This closure inherits the properties reflexive and symmetric from
##  <A>R</A>.
##  E.g., if <A>R</A> is symmetric then its transitive closure is also.
##  <P/>
##  <Ref Oper="TransitiveClosureBinaryRelation"/> is a modified version of
##  the Floyd-Warshall method of solving the all-pairs shortest-paths problem
##  on a directed graph.
##  Its asymptotic runtime is <M>O(n^3)</M> where <M>n</M> is the size of the
##  vertex set.
##  It only assumes there is an arbitrary (but fixed) ordering of the vertex
##  set.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("TransitiveClosureBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#O  HasseDiagramBinaryRelation(<partial-order>)
##
##  <#GAPDoc Label="HasseDiagramBinaryRelation">
##  <ManSection>
##  <Oper Name="HasseDiagramBinaryRelation" Arg='partial-order'/>
##
##  <Description>
##  is the smallest relation contained in the partial order
##  <A>partial-order</A> whose reflexive and transitive closure is equal to
##  <A>partial-order</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("HasseDiagramBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#P  IsHasseDiagram(<rel>)
##
##  <#GAPDoc Label="IsHasseDiagram">
##  <ManSection>
##  <Prop Name="IsHasseDiagram" Arg='rel'/>
##
##  <Description>
##  returns <K>true</K> if the binary relation <A>rel</A> is a Hasse Diagram
##  of a partial order, i.e., was computed via
##  <Ref Oper="HasseDiagramBinaryRelation"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsHasseDiagram", IsBinaryRelation);

#############################################################################
##
#A  PartialOrderOfHasseDiagram(<HD>)
##
##  <#GAPDoc Label="PartialOrderOfHasseDiagram">
##  <ManSection>
##  <Attr Name="PartialOrderOfHasseDiagram" Arg='HD'/>
##
##  <Description>
##  is the partial order associated with the Hasse Diagram <A>HD</A>
##  i.e. the partial order generated by the reflexive and
##  transitive closure of <A>HD</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("PartialOrderOfHasseDiagram",IsBinaryRelation);

#############################################################################
##
#F  PartialOrderByOrderingFunction(<dom>, <orderfunc>)
##
##  <#GAPDoc Label="PartialOrderByOrderingFunction">
##  <ManSection>
##  <Func Name="PartialOrderByOrderingFunction" Arg='dom, orderfunc'/>
##
##  <Description>
##  constructs a partial order whose elements are from the domain <A>dom</A>
##  and are ordered using the ordering function <A>orderfunc</A>.
##  The ordering function must be a binary function returning a boolean
##  value.
##  If the ordering function does not describe a partial order then
##  <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PartialOrderByOrderingFunction");

#############################################################################
##
#O  StronglyConnectedComponents(<R>)
##
##  <#GAPDoc Label="StronglyConnectedComponents">
##  <ManSection>
##  <Oper Name="StronglyConnectedComponents" Arg='R'/>
##
##  <Description>
##  returns an equivalence relation on the vertices of the binary relation
##  <A>R</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("StronglyConnectedComponents", [IsBinaryRelation]);

#############################################################################
##
##  Special definitions for exponentiation with sets, lists, and Zero
##
DeclareOperation("POW", [IsListOrCollection, IsBinaryRelation]);
DeclareOperation("+", [IsBinaryRelation, IsBinaryRelation]);
DeclareOperation("-", [IsBinaryRelation, IsBinaryRelation]);

#############################################################################
##
#A  EquivalenceRelationPartition(<equiv>)
##
##  <#GAPDoc Label="EquivalenceRelationPartition">
##  <ManSection>
##  <Attr Name="EquivalenceRelationPartition" Arg='equiv'/>
##
##  <Description>
##  returns a list of lists of elements
##  of the underlying set of the equivalence relation <A>equiv</A>.
##  The lists are precisely the nonsingleton equivalence classes of the
##  equivalence.
##  This allows us to describe <Q>small</Q> equivalences on infinite sets.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("EquivalenceRelationPartition", IsEquivalenceRelation);

#############################################################################
##
#A  GeneratorsOfEquivalenceRelationPartition(<equiv>)
##
##  <#GAPDoc Label="GeneratorsOfEquivalenceRelationPartition">
##  <ManSection>
##  <Attr Name="GeneratorsOfEquivalenceRelationPartition" Arg='equiv'/>
##
##  <Description>
##  is a set of generating pairs for the equivalence relation <A>equiv</A>.
##  This set is not unique.
##  The equivalence <A>equiv</A> is the smallest equivalence relation over
##  the underlying set which contains the generating pairs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("GeneratorsOfEquivalenceRelationPartition",
    IsEquivalenceRelation);

#############################################################################
##
#F  EquivalenceRelationByPartition( <domain>, <list> )
#F  EquivalenceRelationByPartitionNC( <domain>, <list> )
##
##  <#GAPDoc Label="EquivalenceRelationByPartition">
##  <ManSection>
##  <Func Name="EquivalenceRelationByPartition" Arg='domain, list'/>
##  <Func Name="EquivalenceRelationByPartitionNC" Arg='domain, list'/>
##
##  <Description>
##  constructs the equivalence relation over the set <A>domain</A>
##  which induces the partition represented by <A>list</A>.
##  This representation includes only the non-trivial blocks
##  (or equivalent classes). <A>list</A> is a list of lists,
##  each of these lists contain elements of <A>domain</A> and are
##  pairwise mutually exclusive.
##  <P/>
##  The list of lists do not need to be in any order nor do the
##  elements in the blocks
##  (see <Ref Attr="EquivalenceRelationPartition"/>).
##  a list of elements of <A>domain</A>
##  The partition <A>list</A> is a
##  list of lists, each of these is a list of elements of <A>domain</A>
##  that makes up a block (or equivalent class). The
##  <A>domain</A> is the domain over which the relation is defined, and
##  <A>list</A> is a list of lists, each of these is a list of elements
##  of <A>domain</A> which are related to each other.
##  <A>list</A> need only contain the nontrivial blocks
##  and singletons will be ignored. The <C>NC</C> version will not check
##  to see if the lists are pairwise mutually exclusive or that
##  they contain only elements of the domain.
##  <Example><![CDATA[
##  gap> er:=EquivalenceRelationByPartition(Domain([1..10]),[[1,3,5,7,9],[2,4,6,8,10]]);
##  <equivalence relation on Domain([ 1 .. 10 ]) >
##  gap> IsEquivalenceRelation(er);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EquivalenceRelationByPartition");
DeclareGlobalFunction("EquivalenceRelationByPartitionNC");

#############################################################################
##
#F  EquivalenceRelationByProperty( <domain>, <property> )
##
##  <#GAPDoc Label="EquivalenceRelationByProperty">
##  <ManSection>
##  <Func Name="EquivalenceRelationByProperty" Arg='domain, property'/>
##
##  <Description>
##  creates an equivalence relation on <A>domain</A> whose only defining
##  datum is that of having the property <A>property</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EquivalenceRelationByProperty");

#############################################################################
##
#F  EquivalenceRelationByRelation( <rel> )
##
##  <#GAPDoc Label="EquivalenceRelationByRelation">
##  <ManSection>
##  <Func Name="EquivalenceRelationByRelation" Arg='rel'/>
##
##  <Description>
##  returns the smallest equivalence
##  relation containing the binary relation <A>rel</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EquivalenceRelationByRelation");

#############################################################################
##
##  Some other creation functions which might be useful in the future
##
##  EquivalenceRelationByFunction( <X>, <function> )
##
##  EquivalenceRelationByFunction - the function goes from
##  $X  \times X \rightarrow $ {<true>, <false>}.

#############################################################################
##
#O  JoinEquivalenceRelations( <equiv1>, <equiv2> )
#O  MeetEquivalenceRelations( <equiv1>, <equiv2> )
##
##  <#GAPDoc Label="JoinEquivalenceRelations">
##  <ManSection>
##  <Oper Name="JoinEquivalenceRelations" Arg='equiv1, equiv2'/>
##  <Oper Name="MeetEquivalenceRelations" Arg='equiv1, equiv2'/>
##
##  <Description>
##  <Ref Oper="JoinEquivalenceRelations"/> returns the smallest
##  equivalence relation containing both the equivalence relations
##  <A>equiv1</A> and <A>equiv2</A>.
##  <P/>
##  <Ref Oper="MeetEquivalenceRelations"/> returns the
##  intersection of the two equivalence relations
##  <A>equiv1</A> and <A>equiv2</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("JoinEquivalenceRelations",
    [IsEquivalenceRelation,IsEquivalenceRelation]);
DeclareOperation("MeetEquivalenceRelations",
    [IsEquivalenceRelation,IsEquivalenceRelation]);

#############################################################################
##
#C  IsEquivalenceClass( <obj> )
##
##  <#GAPDoc Label="IsEquivalenceClass">
##  <ManSection>
##  <Filt Name="IsEquivalenceClass" Arg='obj' Type='Category'/>
##
##  <Description>
##  returns <K>true</K> if the object <A>obj</A> is an equivalence class,
##  and <K>false</K> otherwise.
##  <P/>
##  <Index>equivalence class</Index>
##  An <E>equivalence class</E> is a collection of elements which are mutually
##  related to each other in the associated equivalence relation.
##  Note, this is a special category of objects
##  and not just a list of elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsEquivalenceClass",IsDomain and IsDuplicateFreeCollection);

#############################################################################
##
#A  EquivalenceClassRelation(<C>)
##
##  <#GAPDoc Label="EquivalenceClassRelation">
##  <ManSection>
##  <Attr Name="EquivalenceClassRelation" Arg='C'/>
##
##  <Description>
##  returns the equivalence relation of which <A>C</A> is a class.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("EquivalenceClassRelation", IsEquivalenceClass);

#############################################################################
##
#A  EquivalenceClasses(<rel>)
##
##  <#GAPDoc Label="EquivalenceClasses">
##  <ManSection>
##  <Attr Name="EquivalenceClasses" Arg='rel' Label="attribute"/>
##
##  <Description>
##  returns a list of all equivalence classes of the equivalence relation
##  <A>rel</A>.
##  Note that it is possible for different methods to yield the list
##  in different orders, so that for two equivalence relations
##  <M>c1</M> and <M>c2</M> we may have <M>c1 = c2</M> without having
##  <C>EquivalenceClasses</C><M>( c1 ) =
##  </M><C>EquivalenceClasses</C><M>( c2 )</M>.
##  <Example><![CDATA[
##  gap> er:=EquivalenceRelationByPartition(Domain([1..10]),[[1,3,5,7,9],[2,4,6,8,10]]);
##  <equivalence relation on Domain([ 1 .. 10 ]) >
##  gap> classes := EquivalenceClasses(er);
##  [ {1}, {2} ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("EquivalenceClasses", IsEquivalenceRelation);

#############################################################################
##
#O  EquivalenceClassOfElement( <rel>, <elt> )
#O  EquivalenceClassOfElementNC( <rel>, <elt> )
##
##  <#GAPDoc Label="EquivalenceClassOfElement">
##  <ManSection>
##  <Oper Name="EquivalenceClassOfElement" Arg='rel, elt'/>
##  <Oper Name="EquivalenceClassOfElementNC" Arg='rel, elt'/>
##
##  <Description>
##  return the equivalence class of <A>elt</A> in the binary relation
##  <A>rel</A>,
##  where <A>elt</A> is an element (i.e. a pair) of the domain of <A>rel</A>.
##  In the <C>NC</C> form, it is not checked that <A>elt</A> is in the domain
##  over which <A>rel</A> is defined.
##  <Example><![CDATA[
##  gap> EquivalenceClassOfElement(er,3);
##  {3}
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("EquivalenceClassOfElement",
    [IsEquivalenceRelation, IsObject]);

DeclareOperation("EquivalenceClassOfElementNC",
    [IsEquivalenceRelation, IsObject]);

#############################################################################
##
#F  EquivalenceRelationByPairs( <D>, <elms> )
#F  EquivalenceRelationByPairsNC( <D>, <elms> )
##
##  <#GAPDoc Label="EquivalenceRelationByPairs">
##  <ManSection>
##  <Func Name="EquivalenceRelationByPairs" Arg='D, elms'/>
##  <Func Name="EquivalenceRelationByPairsNC" Arg='D, elms'/>
##
##  <Description>
##  return the smallest equivalence relation
##  on the domain <A>D</A> such that every pair in <A>elms</A>
##  is in the relation.
##  <P/>
##  In the <C>NC</C> form, it is not checked that <A>elms</A> are in the
##  domain <A>D</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EquivalenceRelationByPairs");
DeclareGlobalFunction("EquivalenceRelationByPairsNC");

#############################################################################
