#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations of operations for cosets.
##

#############################################################################
##
#V  InfoCoset
##
##  <#GAPDoc Label="InfoCoset">
##  <ManSection>
##  <InfoClass Name="InfoCoset"/>
##
##  <Description>
##  The information function for coset and double coset operations is
##  <Ref InfoClass="InfoCoset"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoCoset");

#############################################################################
##
#F  AscendingChain( <G>, <U> )  .  chain of subgroups G = G_1 > ... > G_n = U
##
##  <#GAPDoc Label="AscendingChain">
##  <ManSection>
##  <Func Name="AscendingChain" Arg='G, U'/>
##
##  <Description>
##  This function computes an ascending chain of subgroups from <A>U</A> to
##  <A>G</A>.
##  This chain is given as a list whose first entry is <A>U</A> and the last
##  entry is <A>G</A>.
##  The function tries to make the links in this chain small.
##  <P/>
##  The option <C>refineIndex</C> can be used to give a bound for refinements
##  of steps to avoid &GAP; trying to enforce too small steps.
##  The option <C>cheap</C> (if set to <K>true</K>) will overall limit the
##  amount of heuristic searches.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AscendingChain");

#############################################################################
##
#O  AscendingChainOp(<G>,<U>)  chain of subgroups
##
##  <ManSection>
##  <Oper Name="AscendingChainOp" Arg='G,U'/>
##
##  <Description>
##  This operation does the actual work of computing ascending chains. It
##  gets called from <C>AscendingChain</C> if no chain is found stored in
##  <C>ComputedAscendingChains</C>.
##  </Description>
##  </ManSection>
##
DeclareOperation("AscendingChainOp",[IsGroup,IsGroup]);

#############################################################################
##
#A  ComputedAscendingChains(<U>)    list of already computed ascending chains
##
##  <ManSection>
##  <Attr Name="ComputedAscendingChains" Arg='U'/>
##
##  <Description>
##  This attribute stores ascending chains. It is a list whose entries are
##  of the form [<A>G</A>,<A>chain</A>] where <A>chain</A> is an ascending chain from <A>U</A> up
##  to <A>G</A>. This storage is used by <C>AscendingChain</C> to avoid duplicate
##  calculations.
##  </Description>
##  </ManSection>
##
DeclareAttribute("ComputedAscendingChains",IsGroup,
                                        "mutable");

#############################################################################
##
#F  RefinedChain(<G>,<c>) . . . . . . . . . . . . . . . .  refine chain links
##
##  <ManSection>
##  <Func Name="RefinedChain" Arg='G,c'/>
##
##  <Description>
##  <A>c</A> is an ascending chain in the Group <A>G</A>. The task of this routine is
##  to refine <A>c</A>, i.e., if there is a "link" <M>U>L</M> in <A>c</A> with <M>[U:L]</M> too big,
##  this procedure tries to find subgroups <M>G_0,...,G_n</M> of <A>G</A>; such that
##  <M>U=G_0>...>G_n=L</M>. This is done by extending L inductively: Since normal
##  steps can help in further calculations, the routine first tries to
##  extend to the normalizer in U. If the subgroup is self-normalizing,
##  the group is extended via a random element. If this results in a step
##  too big, it is repeated several times to find hopefully a small
##  extension!
##  <P/>
##  The option <C>refineIndex</C> can be used to tell &GAP; that a specified
##  step index is good enough. The option <C>refineChainActionLimit</C> can be
##  used to give an upper limit up to which index guaranteed refinement
##  should be tried.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RefinedChain");

#############################################################################
##
#O  CanonicalRightCosetElement( U, g )    canonical representative of U*g
##
##  <#GAPDoc Label="CanonicalRightCosetElement">
##  <ManSection>
##  <Oper Name="CanonicalRightCosetElement" Arg='U, g'/>
##
##  <Description>
##  returns a <Q>canonical</Q> representative of the right coset
##  <A>U</A> <A>g</A>
##  which is independent of the given representative <A>g</A>.
##  This can be used to compare cosets by comparing their canonical
##  representatives.
##  <P/>
##  The representative chosen to be the <Q>canonical</Q> one
##  is representation dependent and only guaranteed to remain the same
##  within one &GAP; session.
##  <Example><![CDATA[
##  gap> CanonicalRightCosetElement(u,(2,4,3));
##  (3,4)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("CanonicalRightCosetElement",
  [IsGroup,IsObject]);

#############################################################################
##
#C  IsDoubleCoset(<obj>)
##
##  <#GAPDoc Label="IsDoubleCoset">
##  <ManSection>
##  <Filt Name="IsDoubleCoset" Arg='obj' Type='Category' Label="operation"/>
##
##  <Description>
##  The category of double cosets.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsDoubleCoset",
    IsDomain and IsExtLSet and IsExtRSet);

#############################################################################
##
#A  LeftActingGroup(<dcos>)
#A  RightActingGroup(<dcos>)
##
##  <ManSection>
##  <Attr Name="LeftActingGroup" Arg='dcos'/>
##  <Attr Name="RightActingGroup" Arg='dcos'/>
##
##  <Description>
##  return the two groups that define a double coset <A>dcos</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("LeftActingGroup",IsDoubleCoset);
DeclareAttribute("RightActingGroup",IsDoubleCoset);

#############################################################################
##
#O  DoubleCoset(<U>,<g>,<V>)
##
##  <#GAPDoc Label="DoubleCoset">
##  <ManSection>
##  <Oper Name="DoubleCoset" Arg='U, g, V'/>
##
##  <Description>
##  The groups <A>U</A> and <A>V</A> must be subgroups of a common supergroup
##  <A>G</A> of which <A>g</A> is an element.
##  This command constructs the double coset <A>U</A> <A>g</A> <A>V</A>
##  which is the set of all elements of the form <M>ugv</M> for any
##  <M>u \in <A>U</A></M>, <M>v \in <A>V</A></M>.
##  For element operations such as <K>in</K>, a double coset behaves
##  like a set of group elements. The double coset stores <A>U</A> in the
##  attribute <C>LeftActingGroup</C>,
##  <A>g</A> as <Ref Attr="Representative"/>,
##  and <A>V</A> as <C>RightActingGroup</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DoubleCoset",[IsGroup,IsObject,IsGroup]);

#############################################################################
##
#O  DoubleCosets(<G>,<U>,<V>)
#O  DoubleCosetsNC(<G>,<U>,<V>)
##
##  <#GAPDoc Label="DoubleCosets">
##  <ManSection>
##  <Func Name="DoubleCosets" Arg='G, U, V'/>
##  <Oper Name="DoubleCosetsNC" Arg='G, U, V'/>
##
##  <Description>
##  computes a duplicate free list of all double cosets
##  <A>U</A> <M>g</M> <A>V</A> for <M>g \in <A>G</A></M>.
##  The groups <A>U</A> and <A>V</A> must be subgroups of the group <A>G</A>.
##  The <C>NC</C> version does not check whether <A>U</A> and <A>V</A> are
##  subgroups of <A>G</A>.
##  <Example><![CDATA[
##  gap> dc:=DoubleCosets(g,u,v);
##  [ DoubleCoset(Group( [ (1,2,3), (1,2) ] ),(),Group( [ (3,4) ] )),
##    DoubleCoset(Group( [ (1,2,3), (1,2) ] ),(1,3)(2,4),Group(
##      [ (3,4) ] )), DoubleCoset(Group( [ (1,2,3), (1,2) ] ),(1,4)
##      (2,3),Group( [ (3,4) ] )) ]
##  gap> List(dc,Representative);
##  [ (), (1,3)(2,4), (1,4)(2,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DoubleCosets");
DeclareOperation("DoubleCosetsNC",[IsGroup,IsGroup,IsGroup]);
DeclareGlobalFunction("CalcDoubleCosets");

#############################################################################
##
#O  DoubleCosetRepsAndSizes(<G>,<U>,<V>)
##
##  <#GAPDoc Label="DoubleCosetRepsAndSizes">
##  <ManSection>
##  <Oper Name="DoubleCosetRepsAndSizes" Arg='G, U, V'/>
##
##  <Description>
##  returns a list of double coset representatives and their sizes,
##  the entries are lists of the form <M>[ r, n ]</M>
##  where <M>r</M> and <M>n</M> are an element of the double coset and the
##  size of the coset, respectively.
##  This operation is faster than <Ref Oper="DoubleCosetsNC"/> because no
##  double coset objects have to be created.
##  <Example><![CDATA[
##  gap> dc:=DoubleCosetRepsAndSizes(g,u,v);
##  [ [ (), 12 ], [ (1,3)(2,4), 6 ], [ (1,4)(2,3), 6 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DoubleCosetRepsAndSizes",[IsGroup,IsGroup,IsGroup]);

#############################################################################
##
#A  RepresentativesContainedRightCosets(<D>)
##
##  <#GAPDoc Label="RepresentativesContainedRightCosets">
##  <ManSection>
##  <Attr Name="RepresentativesContainedRightCosets" Arg='D'/>
##
##  <Description>
##  A double coset <M><A>D</A> = U g V</M> can be considered as a union of
##  right cosets <M>U h_i</M>.
##  (It is the union of the orbit of <M>U g</M> under right multiplication by
##  <M>V</M>.)
##  For a double coset <A>D</A> this function returns a set
##  of representatives <M>h_i</M> such that
##  <A>D</A> <M>= \bigcup_{{h_i}} U h_i</M>.
##  The representatives returned are canonical for <M>U</M> (see
##  <Ref Oper="CanonicalRightCosetElement"/>) and form a set.
##  <Example><![CDATA[
##  gap> u:=Subgroup(g,[(1,2,3),(1,2)]);;v:=Subgroup(g,[(3,4)]);;
##  gap> c:=DoubleCoset(u,(2,4),v);
##  DoubleCoset(Group( [ (1,2,3), (1,2) ] ),(2,4),Group( [ (3,4) ] ))
##  gap> (1,2,3) in c;
##  false
##  gap> (2,3,4) in c;
##  true
##  gap> LeftActingGroup(c);
##  Group([ (1,2,3), (1,2) ])
##  gap> RightActingGroup(c);
##  Group([ (3,4) ])
##  gap> RepresentativesContainedRightCosets(c);
##  [ (2,3,4) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RepresentativesContainedRightCosets", IsDoubleCoset );

#############################################################################
##
#C  IsRightCoset(<obj>)
##
##  <#GAPDoc Label="IsRightCoset">
##  <ManSection>
##  <Filt Name="IsRightCoset" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of right cosets.
##  <P/>
##  <Index>left cosets</Index>
##  &GAP; does not provide left cosets as a separate data type, but as the
##  left coset <M>gU</M> consists of exactly the inverses of the elements of
##  the right coset <M>Ug^{{-1}}</M> calculations with left cosets can be
##  emulated using right cosets by inverting the representatives.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsRightCoset", IsDomain and IsExternalOrbit and
  IsMultiplicativeElementWithInverse);

#############################################################################
##
#P  IsBiCoset( <C> )
##
##  <#GAPDoc Label="IsBiCoset">
##  <ManSection>
##  <Prop Name="IsBiCoset" Arg='C'/>
##
##  <Description>
##  <Index>bicoset</Index>
##  A (right) coset <M>Ug</M> is considered a <E>bicoset</E> if its set of
##  elements simultaneously forms a left coset for the same subgroup. This is
##  the case if and only if the coset representative <M>g</M> normalizes the
##  subgroup <M>U</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsBiCoset", IsRightCoset );

#############################################################################
##
#O  RightCoset( <U>, <g> )
##
##  <#GAPDoc Label="RightCoset">
##  <ManSection>
##  <Oper Name="RightCoset" Arg='U, g'/>
##
##  <Description>
##  returns the right coset of <A>U</A> with representative <A>g</A>,
##  which is the set of all elements of the form <M>ug</M> for all
##  <M>u \in <A>U</A></M>.  <A>g</A> must be an
##  element of a larger group <A>G</A> which contains <A>U</A>.
##  For element operations such as <K>in</K> a right coset behaves like a set of
##  group elements.
##  <P/>
##  Right cosets are
##  external orbits for the action of <A>U</A> which acts via
##  <Ref Func="OnLeftInverse"/>.
##  Of course the action of a larger group <A>G</A> on right cosets is via
##  <Ref Func="OnRight"/>.
##  <Example><![CDATA[
##  gap> u:=Group((1,2,3), (1,2));;
##  gap> c:=RightCoset(u,(2,3,4));
##  RightCoset(Group( [ (1,2,3), (1,2) ] ),(2,3,4))
##  gap> ActingDomain(c);
##  Group([ (1,2,3), (1,2) ])
##  gap> Representative(c);
##  (2,3,4)
##  gap> Size(c);
##  6
##  gap> AsList(c);
##  [ (2,3,4), (1,4,2), (1,3,4,2), (1,3)(2,4), (2,4), (1,4,2,3) ]
##  gap> IsBiCoset(c);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("RightCoset",[IsGroup,IsObject]);


#############################################################################
##
#F  RightCosets(<G>,<U>)
#O  RightCosetsNC(<G>,<U>)
##
##  <#GAPDoc Label="RightCosets">
##  <ManSection>
##  <Func Name="RightCosets" Arg='G, U'/>
##  <Oper Name="RightCosetsNC" Arg='G, U'/>
##
##  <Description>
##  computes a duplicate free list of right cosets <A>U</A> <M>g</M> for
##  <M>g \in</M> <A>G</A>.
##  A set of representatives for the elements in this list forms a right
##  transversal of <A>U</A> in <A>G</A>.
##  (By inverting the representatives one obtains
##  a list of representatives of the left cosets of <A>U</A>.)
##  The <C>NC</C> version does not check whether <A>U</A> is a subgroup of
##  <A>G</A>.
##  <Example><![CDATA[
##  gap> RightCosets(g,u);
##  [ RightCoset(Group( [ (1,2,3), (1,2) ] ),()),
##    RightCoset(Group( [ (1,2,3), (1,2) ] ),(1,3)(2,4)),
##    RightCoset(Group( [ (1,2,3), (1,2) ] ),(1,4)(2,3)),
##    RightCoset(Group( [ (1,2,3), (1,2) ] ),(1,2)(3,4)) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RightCosets");
DeclareOperation("RightCosetsNC",[IsGroup,IsGroup]);

#############################################################################
##
#F  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  <#GAPDoc Label="IntermediateGroup">
##  <ManSection>
##  <Func Name="IntermediateGroup" Arg='G, U'/>
##
##  <Description>
##  This routine tries to find a subgroup <M>E</M> of <A>G</A>,
##  such that <M><A>G</A> > E > <A>U</A></M> holds.
##  If <A>U</A> is maximal in <A>G</A>, the function returns <K>fail</K>.
##  This is done by finding minimal blocks for
##  the operation of <A>G</A> on the right cosets of <A>U</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IntermediateGroup");

# forward declaration for recursive call.
DeclareGlobalFunction("DoConjugateInto");

