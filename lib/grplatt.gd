#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains declarations for subgroup latices
##


#############################################################################
##
#V  InfoLattice                                    Information
##
##  <#GAPDoc Label="InfoLattice">
##  <ManSection>
##  <InfoClass Name="InfoLattice"/>
##
##  <Description>
##  is the information class used by the cyclic extension methods for
##  subgroup lattice calculations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoLattice");


#############################################################################
##
#R  IsConjugacyClassSubgroupsRep( <obj> )
#R  IsConjugacyClassSubgroupsByStabilizerRep( <obj> )
##
##  <#GAPDoc Label="IsConjugacyClassSubgroupsRep">
##  <ManSection>
##  <Filt Name="IsConjugacyClassSubgroupsRep" Arg='obj'
##   Type='Representation'/>
##  <Filt Name="IsConjugacyClassSubgroupsByStabilizerRep" Arg='obj'
##   Type='Representation'/>
##
##  <Description>
##  Is the representation &GAP; uses for conjugacy classes of subgroups.
##  It can be used to check whether an object is a class of subgroups.
##  The second representation
##  <Ref Filt="IsConjugacyClassSubgroupsByStabilizerRep"/> in
##  addition is an external orbit by stabilizer and will compute its
##  elements via a transversal of the stabilizer.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation("IsConjugacyClassSubgroupsRep",
  IsExternalOrbit,[]);
DeclareRepresentation("IsConjugacyClassSubgroupsByStabilizerRep",
  IsConjugacyClassSubgroupsRep and IsExternalOrbitByStabilizerRep,[]);


#############################################################################
##
#O  ConjugacyClassSubgroups( <G>, <U> )
##
##  <#GAPDoc Label="ConjugacyClassSubgroups">
##  <ManSection>
##  <Oper Name="ConjugacyClassSubgroups" Arg='G, U'/>
##
##  <Description>
##  generates the conjugacy class of subgroups of <A>G</A> with
##  representative <A>U</A>.
##  This class is an external set,
##  so functions such as <Ref Attr="Representative"/>,
##  (which returns <A>U</A>),
##  <Ref Attr="ActingDomain"/> (which returns <A>G</A>),
##  <Ref Attr="StabilizerOfExternalSet"/> (which returns the normalizer of
##  <A>U</A>), and <Ref Attr="AsList"/> work for it.
##  <P/>
##  (The use of the <C>[]</C>
##  list access to select elements of the class is considered obsolescent
##  and will be removed in future versions.
##  Use <Ref Oper="ClassElementLattice"/> instead.)
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;IsNaturalSymmetricGroup(g);;
##  gap> cl:=ConjugacyClassSubgroups(g,Subgroup(g,[(1,2)]));
##  Group( [ (1,2) ] )^G
##  gap> Size(cl);
##  6
##  gap> ClassElementLattice(cl,4);
##  Group([ (2,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ConjugacyClassSubgroups", [IsGroup,IsGroup]);

#############################################################################
##
#O  ClassElementLattice(<C>,<n>)
##
##  <#GAPDoc Label="ClassElementLattice">
##  <ManSection>
##  <Oper Name="ClassElementLattice" Arg='C, n'/>
##
##  <Description>
##  For a class <A>C</A> of subgroups, obtained by a lattice computation,
##  this operation returns the <A>n</A>-th conjugate subgroup in the class.
##  <P/>
##  <E>Because of other methods installed, calling <Ref Attr="AsList"/> with
##  <A>C</A> can give a different arrangement of the class elements!</E>
##  <P/>
##  The &GAP; package <Package>XGAP</Package> permits a graphical display of
##  the lattice of subgroups in a nice way.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ClassElementLattice", [IsExternalOrbit,IsPosInt]);

#############################################################################
##
#R  IsLatticeSubgroupsRep(<obj>)
##
##  <ManSection>
##  <Filt Name="IsLatticeSubgroupsRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  This representation indicates lattices of subgroups.
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsLatticeSubgroupsRep",
  IsComponentObjectRep and IsAttributeStoringRep,
  ["group","conjugacyClassesSubgroups"]);

#############################################################################
##
#A  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
##  <#GAPDoc Label="Zuppos">
##  <ManSection>
##  <Attr Name="Zuppos" Arg='G'/>
##
##  <Description>
##  The <E>Zuppos</E> of a group are the cyclic subgroups of prime power order.
##  (The name <Q>Zuppo</Q> derives from the German abbreviation for <Q>zyklische
##  Untergruppen von Primzahlpotenzordnung</Q>.) This attribute
##  gives generators of all such subgroups of a group <A>G</A>. That is all elements
##  of <A>G</A> of prime power order up to the equivalence that they generate the
##  same cyclic subgroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Zuppos",IsGroup);

#############################################################################
##
#F  LatticeByCyclicExtension( <G>[, <func>[, <noperf>]] )
##
##  <#GAPDoc Label="LatticeByCyclicExtension">
##  <ManSection>
##  <Func Name="LatticeByCyclicExtension" Arg='G[, func[, noperf]]'/>
##
##  <Description>
##  computes the lattice of <A>G</A> using the cyclic extension algorithm. If the
##  function <A>func</A> is given, the algorithm will discard all subgroups not
##  fulfilling <A>func</A> (and will also not extend them), returning a partial
##  lattice. This can be useful to compute only subgroups with certain
##  properties. Note however that this will <E>not</E> necessarily yield all
##  subgroups that fulfill <A>func</A>, but the subgroups whose subgroups are used
##  for the construction must also fulfill <A>func</A> as well.
##  (In fact the filter <A>func</A> will simply discard subgroups in the cyclic
##  extension algorithm. Therefore the trivial subgroup will always be
##  included.) Also note, that for such a partial lattice
##  maximality/minimality inclusion relations cannot be computed.
##  (If <A>func</A> is a list of length 2, its first entry is such a
##  discarding function, the second a function for discarding zuppos.)
##  <P/>
##  The cyclic extension algorithm requires the perfect subgroups of <A>G</A>.
##  However &GAP; cannot analyze the function <A>func</A> for its implication
##  but can only apply it. If it is known that <A>func</A> implies solvability,
##  the computation of the perfect subgroups can be avoided by giving a
##  third parameter <A>noperf</A> set to <K>true</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=WreathProduct(Group((1,2,3),(1,2)),Group((1,2,3,4)));;
##  gap> l:=LatticeByCyclicExtension(g,function(G)
##  > return Size(G) in [1,2,3,6];end);
##  <subgroup lattice of <permutation group of size 5184 with
##  9 generators>, 47 classes,
##  2628 subgroups, restricted under further condition l!.func>
##  ]]></Example>
##  <P/>
##  The total number of classes in this example is much bigger, as the
##  following example shows:
##  <Example><![CDATA[
##  gap> LatticeSubgroups(g);
##  <subgroup lattice of <permutation group of size 5184 with
##  9 generators>, 566 classes, 27134 subgroups>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("LatticeByCyclicExtension");

#############################################################################
##
#F  LatticeViaRadical(<G>)
##
##  <ManSection>
##  <Func Name="LatticeViaRadical" Arg='G'/>
##
##  <Description>
##  computes the lattice of <A>G</A> using the homomorphism principle to lift the
##  result from factor groups.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("LatticeViaRadical");

#############################################################################
##
#A  MaximalSubgroupsLattice(<lat>)
##
##  <#GAPDoc Label="MaximalSubgroupsLattice">
##  <ManSection>
##  <Attr Name="MaximalSubgroupsLattice" Arg='lat'/>
##
##  <Description>
##  For a lattice <A>lat</A> of subgroups this attribute contains the maximal
##  subgroup relations among the subgroups of the lattice.
##  It is a list corresponding to the <Ref Attr="ConjugacyClassesSubgroups"/>
##  value of the lattice, each entry giving a list of the maximal subgroups
##  of the representative of this class.
##  Every maximal subgroup is indicated by a list of the form <M>[ c, n ]</M>
##  which means that the <M>n</M>-th subgroup in class number <M>c</M> is a
##  maximal subgroup of the representative.
##  <P/>
##  The number <M>n</M> corresponds to access via
##  <Ref Oper="ClassElementLattice"/>
##  and <E>not</E> necessarily the <Ref Attr="AsList"/> arrangement!
##  See also <Ref Attr="MinimalSupergroupsLattice"/>.
##  <Example><![CDATA[
##  gap> MaximalSubgroupsLattice(l);
##  [ [  ], [ [ 1, 1 ] ], [ [ 1, 1 ] ], [ [ 1, 1 ] ],
##    [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ] ], [ [ 3, 1 ], [ 3, 6 ], [ 2, 3 ] ],
##    [ [ 2, 3 ] ], [ [ 4, 1 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ],
##    [ [ 7, 1 ], [ 6, 1 ], [ 5, 1 ] ],
##    [ [ 5, 1 ], [ 4, 1 ], [ 4, 2 ], [ 4, 3 ], [ 4, 4 ] ],
##    [ [ 10, 1 ], [ 9, 1 ], [ 9, 2 ], [ 9, 3 ], [ 8, 1 ], [ 8, 2 ],
##        [ 8, 3 ], [ 8, 4 ] ] ]
##  gap> last[6];
##  [ [ 3, 1 ], [ 3, 6 ], [ 2, 3 ] ]
##  gap> u1:=Representative(ConjugacyClassesSubgroups(l)[6]);
##  Group([ (3,4), (1,2)(3,4) ])
##  gap> u2:=ClassElementLattice(ConjugacyClassesSubgroups(l)[3],1);;
##  gap> u3:=ClassElementLattice(ConjugacyClassesSubgroups(l)[3],6);;
##  gap> u4:=ClassElementLattice(ConjugacyClassesSubgroups(l)[2],3);;
##  gap> IsSubgroup(u1,u2);IsSubgroup(u1,u3);IsSubgroup(u1,u4);
##  true
##  true
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("MaximalSubgroupsLattice",IsLatticeSubgroupsRep);

#############################################################################
##
#A  MinimalSupergroupsLattice(<lat>)
##
##  <#GAPDoc Label="MinimalSupergroupsLattice">
##  <ManSection>
##  <Attr Name="MinimalSupergroupsLattice" Arg='lat'/>
##
##  <Description>
##  For a lattice <A>lat</A> of subgroups this attribute contains the minimal
##  supergroup relations among the subgroups of the lattice.
##  It is a list corresponding to the <Ref Attr="ConjugacyClassesSubgroups"/>
##  value of the lattice, each entry giving a list of the minimal supergroups
##  of the representative of this class.
##  Every minimal supergroup is indicated by a list of the form
##  <M>[ c, n ]</M>, which means that the <M>n</M>-th subgroup in class
##  number <M>c</M> is a minimal supergroup of the representative.
##  <P/>
##  The number <M>n</M> corresponds to access via
##  <Ref Oper="ClassElementLattice"/>
##  and <E>not</E> necessarily the <Ref Attr="AsList"/> arrangement!
##  See also <Ref Attr="MaximalSubgroupsLattice"/>.
##  <Example><![CDATA[
##  gap> MinimalSupergroupsLattice(l);
##  [ [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ],
##        [ 3, 4 ], [ 3, 5 ], [ 3, 6 ], [ 4, 1 ], [ 4, 2 ], [ 4, 3 ],
##        [ 4, 4 ] ], [ [ 5, 1 ], [ 6, 2 ], [ 7, 2 ] ],
##    [ [ 6, 1 ], [ 8, 1 ], [ 8, 3 ] ], [ [ 8, 1 ], [ 10, 1 ] ],
##    [ [ 9, 1 ], [ 9, 2 ], [ 9, 3 ], [ 10, 1 ] ], [ [ 9, 1 ] ],
##    [ [ 9, 1 ] ], [ [ 11, 1 ] ], [ [ 11, 1 ] ], [ [ 11, 1 ] ], [  ] ]
##  gap> last[3];
##  [ [ 6, 1 ], [ 8, 1 ], [ 8, 3 ] ]
##  gap> u5:=ClassElementLattice(ConjugacyClassesSubgroups(l)[8],1);
##  Group([ (3,4), (2,4,3) ])
##  gap> u6:=ClassElementLattice(ConjugacyClassesSubgroups(l)[8],3);
##  Group([ (1,3), (1,3,4) ])
##  gap> IsSubgroup(u5,u2);
##  true
##  gap> IsSubgroup(u6,u2);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("MinimalSupergroupsLattice",IsLatticeSubgroupsRep);

#############################################################################
##
#F  DotFileLatticeSubgroups( <L>, <file> )
##
##  <#GAPDoc Label="DotFileLatticeSubgroups">
##  <ManSection>
##  <Func Name="DotFileLatticeSubgroups" Arg='L, file'/>
##
##  <Description>
##  <Index>dot-file</Index>
##  <Index>graphviz</Index>
##  <Index>OmniGraffle</Index>
##  This function produces a graphical representation of the subgroup
##  lattice <A>L</A> in file <A>file</A>. The output is in <C>.dot</C> (also known as
##  <C>GraphViz</C> format). For details on the format, and information about how to
##  display or edit this format see <URL>https://www.graphviz.org</URL>. (On the
##  Macintosh, the program <C>OmniGraffle</C> is also able to read this format.)
##  <P/>
##  Subgroups are labelled in the form <C><A>i</A>-<A>j</A></C> where <A>i</A> is the number of
##  the class of subgroups and <A>j</A> the number within this class. Normal
##  subgroups are represented by a box.
##  <P/>
##  <Log><![CDATA[
##  gap> DotFileLatticeSubgroups(l,"s4lat.dot");
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DotFileLatticeSubgroups");

#############################################################################
##
#F  ExtendSubgroupsOfNormal( <G>, <N>,<Nsubs> )
##
##  <#GAPDoc Label="ExtendSubgroupsOfNormal">
##  <ManSection>
##  <Func Name="ExtendSubgroupsOfNormal" Arg='G,N,Nsubs'/>
##
##  <Description>
##  If $N$ is normal in $G$ and $Nsubs$ is a list of subgroups of $N$ up to
##  conjugacy, this function extends this list to that of all subgroups of $G$.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ExtendSubgroupsOfNormal");

#############################################################################
##
#F  SubdirectSubgroups( <D> )
##
##  <#GAPDoc Label="SubdirectSubgroups">
##  <ManSection>
##  <Func Name="SubdirectSubgroups" Arg='D'/>
##
##  <Description>
##  If $D$ is created as a direct product, this function determines all
##  subgroups of $D$ up to conjugacy, using subdirect products.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SubdirectSubgroups");

#############################################################################
##
#F  SubgroupsTrivialFitting( <G> )
##
##  <#GAPDoc Label="SubgroupsTrivialFitting">
##  <ManSection>
##  <Func Name="SubgroupsTrivialFitting" Arg='G'/>
##
##  <Description>
##  Determines representatives of the conjugacy classes of subgroups of a
##  trivial-fitting group $G$.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SubgroupsTrivialFitting");

#############################################################################
##
#A  TomDataAlmostSimpleRecognition(<G>) Tom Library Identification
##
##  <#GAPDoc Label="TomDataAlmostSimpleRecognition">
##  <ManSection>
##  <Attr Name="TomDataAlmostSimpleRecognition" Arg='G'/>
##
##  <Description>
##  For an almost simple group, this returns a list: isomorphism, table of
##  marks
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("TomDataAlmostSimpleRecognition",IsGroup);

# functions return list of (maximal/all) subgroups of almost simple fetched
# from tom library, or `fail' if data is not there.
DeclareGlobalFunction("TomDataMaxesAlmostSimple");
DeclareGlobalFunction("TomDataSubgroupsAlmostSimple");

#############################################################################
##
#F  LowLayerSubgroups( [<act>,]<G>, <lim> [,<cond> [,<dosub>]] )
##
##  <#GAPDoc Label="LowLayerSubgroups">
##  <ManSection>
##  <Func Name="LowLayerSubgroups" Arg='[act,]G,lim [,cond,dosub]'/>
##
##  <Description>
##  This function computes representatives of the conjugacy classes of
##  subgroups of the finite group <A>G</A> such that the subgroups can be
##  obtained as <A>lim</A>-fold iterated maximal subgroups.
##
##  If a function <A>cond</A> is given, only subgroups for which this
##  function returns true (also for their intermediate overgroups) is
##  returned. If also a function <A>dosub</A> is given, maximal subgroups
##  are only attempted if this function returns true (this is separated for
##  performance reasons).
##  In the example below, the result would be the same with leaving out the
##  fourth function, but calculation this way is slightly faster.
##  If an initial argument <A>act</A> is given, it must be a group
##  containing and normalizing <A>G</A>,
##  and representatives for classes under the action of this group are chosen.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(12);;
##  gap> l:=LowLayerSubgroups(g,2,x->Size(x)>100000,x->Size(x)>200000);;
##  gap> Collected(List(l,Size));
##  [ [ 100800, 1 ], [ 120960, 1 ], [ 161280, 1 ], [ 241920, 1 ], [ 302400, 3 ],
##    [ 322560, 1 ], [ 483840, 3 ], [ 518400, 3 ], [ 604800, 1 ], [ 725760, 1 ],
##    [ 967680, 1 ], [ 1036800, 1 ], [ 1088640, 3 ], [ 2177280, 1 ],
##    [ 3628800, 3 ], [ 7257600, 1 ], [ 19958400, 1 ], [ 39916800, 1 ],
##    [ 239500800, 1 ], [ 479001600, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("LowLayerSubgroups");

#############################################################################
##
#O  ContainedConjugates(<G>,<A>,<B>[,<onlyone>])
##
##  <#GAPDoc Label="ContainedConjugates">
##  <ManSection>
##  <Oper Name="ContainedConjugates" Arg='G, A, B [,onlyone]'/>
##
##  <Description>
##  For <M>A,B \leq G</M> this operation returns representatives of the <A>A</A>
##  conjugacy classes of subgroups that are conjugate to <A>B</A> under <A>G</A>.
##  The function returns a list of pairs of subgroup and conjugating element.
##  If the optional fourth argument <A>onlyone</A> is given as <A>true</A>,
##  then only one pair (or <A>fail</A> if none exists) is returned.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(8);;
##  gap> a:=TransitiveGroup(8,47);;b:=TransitiveGroup(8,9);;
##  gap> ContainedConjugates(g,a,b);
##  [ [ Group([ (1,8)(2,3)(4,5)(6,7), (1,3)(2,8)(4,6)(5,7), (1,5)(2,6)(3,7)(4,8),
##          (4,5)(6,7) ]), () ],
##    [ Group([ (1,8)(2,3)(4,5)(6,7), (1,5)(2,6)(3,7)(4,8), (1,3)(2,8)(4,6)(5,7),
##          (2,3)(6,7) ]), (2,4)(3,5) ] ]
##  gap> ContainedConjugates(g,a,b,true);
##  [ Group([ (1,8)(2,3)(4,5)(6,7), (1,3)(2,8)(4,6)(5,7), (1,5)(2,6)(3,7)(4,8),
##      (4,5)(6,7) ]), () ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ContainedConjugates",[IsGroup,IsGroup,IsGroup]);
DeclareSynonym("EmbeddedConjugates",ContainedConjugates);

#############################################################################
##
#O  ContainingConjugates(<G>,<A>,<B>)
##
##  <#GAPDoc Label="ContainingConjugates">
##  <ManSection>
##  <Oper Name="ContainingConjugates" Arg='G, A, B'/>
##
##  <Description>
##  For <M>A,B \leq G</M> this operation returns all <A>G</A> conjugates of <A>A</A>
##  that contain <A>B</A>.
##  The function returns a list of pairs of subgroup and conjugating element.
##  <Example><![CDATA[
##  gap> g:=SymmetricGroup(8);;
##  gap> a:=TransitiveGroup(8,47);;b:=TransitiveGroup(8,7);;
##  gap> ContainingConjugates(g,a,b);
##  [ [ Group([ (1,3,5,7), (3,5), (1,4)(2,7)(3,6)(5,8) ]), (2,3,5,4)(7,8) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ContainingConjugates",[IsGroup,IsGroup,IsGroup]);
DeclareSynonym("EmbeddingConjugates",ContainingConjugates);

#############################################################################
##
#O  MinimalFaithfulPermutationDegree(<G>)
##
##  <#GAPDoc Label="MinimalFaithfulPermutationDegree">
##  <ManSection>
##  <Oper Name="MinimalFaithfulPermutationDegree" Arg='G'/>
##  <Oper Name="MinimalFaithfulPermutationRepresentation" Arg='G'/>
##
##  <Description>
##  For  a finite group <A>G</A>,
##  <Ref Oper="MinimalFaithfulPermutationDegree"/>
##  calculates the least
##  positive integer <M>n=\mu(G)</M> such that <A>G</A> is isomorphic to a
##  subgroup of the symmetric group of degree <M>n</M>.
##  This can require calculating the whole subgroup lattice.
##  The operation
##  <Ref Oper="MinimalFaithfulPermutationRepresentation"/>
##  returns a
##  corresponding isomorphism.
##  <Example><![CDATA[
##  gap> MinimalFaithfulPermutationDegree(SmallGroup(96,3));
##  12
##  gap> g:=TransitiveGroup(10,32);;
##  gap> MinimalFaithfulPermutationDegree(g);
##  6
##  gap> map:=MinimalFaithfulPermutationRepresentation(g);;
##  gap> Size(Image(map));
##  720
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("MinimalFaithfulPermutationDegree",[IsGroup and IsFinite]);
DeclareOperation("MinimalFaithfulPermutationRepresentation",
  [IsGroup and IsFinite]);

#############################################################################
##
#F  DescSubgroupIterator( <G> )
##
##  <#GAPDoc Label="DescSubgroupIterator">
##  <ManSection>
##  <Func Name="DescSubgroupIterator" Arg='G'/>
##
##  <Description>
##  Iterator to
##  descend through (representatives of) conjugacy classes of subgroups,
##  by increasing index. If the option <C>skip</C> is set to an integer, the
##  iterator will jump to subgroups containing $U'$ if their index is at most
##  skip and they are "nice" (In this case not all subgroups will be found.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DescSubgroupIterator");

DeclareGlobalFunction("SubgroupConditionAbove");

# Utility function
# MinimalInclusionsGroups(l)
# returns a list of all inclusion indices [a,b] where l[a] is maximal subgroup
# of l[b].
DeclareGlobalFunction("MinimalInclusionsGroups");
