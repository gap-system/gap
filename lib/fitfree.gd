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
##  This file contains functions using the trivial-Fitting paradigm.
##

BindGlobal( "OverrideNice",
    {} -> Maximum( RankFilter( IsHandledByNiceMonomorphism ),
                   RankFilter( IsMatrixGroup and IsFinite ) ) );

#############################################################################
##
#V  InfoFitFree
##
##  The info class for Fitting-free calculations.
##
DeclareInfoClass("InfoFitFree");

#############################################################################
##
#F  CanComputeFittingFree( <grp> ) . . . . .  TF approach is possible
##
##  <#GAPDoc Label="CanComputeFittingFree">
##  <ManSection>
##  <Filt Name="CanComputeFittingFree" Arg='grp'/>
##
##  <Description>
##  This filter indicates whether algorithms using the TF paradigm
##  (Trivial Fitting / Solvable Radical) can be used for the group
##  <A>grp</A>, that is, whether a method for
##  <Ref Attr="FittingFreeLiftSetup"/> is available for <A>grp</A>.
##  Note that this filter may change its value from <K>false</K> to
##  <K>true</K>.
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);
##  A6 3^1
##  gap> CanComputeFittingFree(G);
##  true
##  gap> CanComputeFittingFree(FreeGroup(2));
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "CanComputeFittingFree" );

# To satisfy method installation requirements.
InstallTrueMethod(IsFinite,CanComputeFittingFree);
InstallTrueMethod(IsGroup,CanComputeFittingFree);

InstallTrueMethod(CanComputeFittingFree, IsPermGroup);
InstallTrueMethod(CanComputeFittingFree, IsPcGroup);

#############################################################################
##
#F  AttemptPermRadicalMethod( <grp>, <task> )
##
##  <#GAPDoc Label="AttemptPermRadicalMethod">
##  <ManSection>
##  <Func Name="AttemptPermRadicalMethod" Arg='grp, task'/>
##
##  <Description>
##  This function encodes (hard-coded) heuristics that decide whether it is
##  worth using Trivial Fitting / Solvable Radical methods for a problem in
##  the permutation group <A>grp</A>, in preference to a backtrack search.
##  It returns <K>true</K> or <K>false</K> if a decision can be made, and
##  <K>fail</K> otherwise.
##  <P/>
##  The kind of problem is described by the string <A>task</A>.
##  Currently the only supported value is <C>"CENT"</C>, for centralizer
##  and element conjugacy calculations.
##  <P/>
##  In the following example the group is small enough that a backtrack
##  search is preferable, so the heuristic advises against the TF approach.
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> AttemptPermRadicalMethod(G,"CENT");
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AttemptPermRadicalMethod");


#############################################################################
##
#A  FittingFreeLiftSetup( <G> )
##
##  <#GAPDoc Label="FittingFreeLiftSetup">
##  <ManSection>
##  <Attr Name="FittingFreeLiftSetup" Arg='G'/>
##
##  <Description>
##  For a finite group <A>G</A>, this attribute returns a record with (at
##  least) the following components:
##  <List>
##  <Mark><C>radical</C></Mark>
##  <Item>
##    The solvable radical <M>Rad(G)</M>.
##  </Item>
##  <Mark><C>pcgs</C></Mark>
##  <Item>
##    A pcgs for <M>Rad(G)</M> that refines a <M>G</M>-normal series with
##    elementary abelian factors.
##  </Item>
##  <Mark><C>depths</C></Mark>
##  <Item>
##    A list of indices in <C>pcgs</C>, indicating the <M>G</M>-normal
##    subgroups of the above series, including an entry for the trivial
##    subgroup.
##  </Item>
##  <Mark><C>pcisom</C></Mark>
##  <Item>
##    An effective isomorphism from a supergroup of <M>Rad(G)</M> to a pc
##    group.
##  </Item>
##  <Mark><C>factorhom</C></Mark>
##  <Item>
##    An epimorphism from <A>G</A> onto <M>G/Rad(G)</M>. The image group is
##    represented in a way that makes decomposition into generators
##    efficient. In particular, it is possible to use
##    <Ref Oper="PreImagesRepresentative"/> to take the pre-image of an
##    element of the image. For a subgroup <M>U\le G</M>, one can apply
##    <Ref Oper="RestrictedMapping"/> to this homomorphism to obtain a
##    corresponding homomorphism for <M>U</M>.
##  </Item>
##  </List>
##  <P/>
##  The redundancy amongst the components is deliberate: the redundant
##  objects can be created at minimal extra cost, and not creating them
##  risks the creation of duplicate objects by user code later on.
##  <P/>
##  The record may hold further components that are germane to the
##  recognition setup. None of the components may be modified by user code.
##  <P/>
##  In the following example <A>G</A> is a central extension
##  <M>3.A_6</M>, so its radical is the centre of order <M>3</M> and the
##  factor group modulo the radical is simple.
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> ffs:=FittingFreeLiftSetup(G);;
##  gap> Size(ffs.radical);
##  3
##  gap> ffs.depths;
##  [ 1, 2 ]
##  gap> Length(ffs.pcgs);
##  1
##  gap> Size(Image(ffs.factorhom));
##  360
##  gap> IsSimpleGroup(Image(ffs.factorhom));
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("FittingFreeLiftSetup",IsGroup);
InstallTrueMethod(CanComputeFittingFree,HasFittingFreeLiftSetup);

#############################################################################
##
#F  FittingFreeSubgroupSetup( <G>, <U> )
##
##  <#GAPDoc Label="FittingFreeSubgroupSetup">
##  <ManSection>
##  <Func Name="FittingFreeSubgroupSetup" Arg='G, U'/>
##
##  <Description>
##  Let <A>U</A> be a subgroup of a finite group <A>G</A> for which
##  <Ref Attr="FittingFreeLiftSetup"/> has been computed. This function
##  computes a setup for <A>U</A> that is compatible with the one for
##  <A>G</A>. (The result is cached in <A>U</A> for later calculations.)
##  <P/>
##  It returns a record with (at least) the following components:
##  <List>
##  <Mark><C>parentffs</C></Mark>
##  <Item>
##    The record returned by <Ref Attr="FittingFreeLiftSetup"/> for
##    <A>G</A>.
##  </Item>
##  <Mark><C>rest</C></Mark>
##  <Item>
##    The restriction of the component <C>factorhom</C> for <A>G</A> to
##    <A>U</A>, defined on the generators of <A>U</A>.
##  </Item>
##  <Mark><C>ker</C></Mark>
##  <Item>
##    The kernel of this restriction.
##  </Item>
##  <Mark><C>pcgs</C></Mark>
##  <Item>
##    A pcgs for this kernel.
##  </Item>
##  <Mark><C>serdepths</C></Mark>
##  <Item>
##    For each depth step in the pcgs for the radical of <A>G</A>, as stored
##    in <C>parentffs</C>, the index in the above <C>pcgs</C> for <A>U</A>
##    at which this depth is reached.
##  </Item>
##  </List>
##  <P/>
##  The record may hold further components that are germane to the
##  recognition setup. None of the components may be modified by user code.
##  <P/>
##  In the following example <A>U</A> is a Sylow <M>3</M>-subgroup of
##  <M>3.A_6</M>; it meets the radical in the centre of order <M>3</M> and
##  therefore has an image of order <M>9</M> in the factor group.
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> U:=SylowSubgroup(G,3);;
##  gap> Size(U);
##  27
##  gap> sub:=FittingFreeSubgroupSetup(G,U);;
##  gap> Size(sub.ker);
##  3
##  gap> Length(sub.pcgs);
##  1
##  gap> sub.serdepths;
##  [ 1, 2 ]
##  gap> Size(Image(sub.rest));
##  9
##  gap> sub.parentffs=FittingFreeLiftSetup(G);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("FittingFreeSubgroupSetup");
DeclareOperation("DoFFSS",[IsGroup,IsGroup]);

# This attribute is used for groups treated by constructive recognition and
# a composition tree. It is declared in the library so that the function
# FittingFreeSubgroupSetup can maintain it.
DeclareAttribute("RecogDecompinfoHomomorphism",IsMapping,"mutable");

#############################################################################
##
#F  SubgroupByFittingFreeData( <G>, <gens>, <imgs>, <ipcgs> )
##
##  <#GAPDoc Label="SubgroupByFittingFreeData">
##  <ManSection>
##  <Func Name="SubgroupByFittingFreeData" Arg='G, gens, imgs, ipcgs'/>
##
##  <Description>
##  Let <A>G</A> be a finite group for which the record <C>ffs</C> returned
##  by <Ref Attr="FittingFreeLiftSetup"/> has been computed. This function
##  returns the subgroup <M>U</M> of <A>G</A> generated by <A>gens</A> and
##  <A>ipcgs</A>, built from data that are compatible with <C>ffs</C>.
##  <P/>
##  Here <A>ipcgs</A> must be an induced pcgs for <M>U\cap Rad(G)</M> with
##  respect to the pcgs stored in <C>ffs</C>, and <A>imgs</A> must be the
##  list of images of <A>gens</A> under <C>ffs.factorhom</C>.
##  <P/>
##  The data required here are exactly those provided by
##  <Ref Func="FittingFreeSubgroupSetup"/>, so a subgroup can be rebuilt
##  from them:
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> ffs:=FittingFreeLiftSetup(G);;
##  gap> U:=SylowSubgroup(G,3);;
##  gap> sub:=FittingFreeSubgroupSetup(G,U);;
##  gap> gens:=GeneratorsOfGroup(U);;
##  gap> imgs:=List(gens,x->ImagesRepresentative(ffs.factorhom,x));;
##  gap> V:=SubgroupByFittingFreeData(G,gens,imgs,sub.pcgs);;
##  gap> Size(V);
##  27
##  gap> V=U;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SubgroupByFittingFreeData");

# Utility function: function(pcgs,gens,ignoredepths)
# Forms an induced modulo pcgs after correction on the lowest level.
# We will be in the situation that an IGS has been corrected only on the
# lowest level, i.e. the only obstacle to being an IGS is on the lowest
# level. Thus the situation is that of a vector space and we do not need to
# consider commutators and powers, but simply do a Gaussian elimination.
DeclareGlobalFunction("TFMakeInducedPcgsModulo");

# Utility functions: orbit algorithms when acting with a GPCGS.
DeclareGlobalFunction("OrbitsRepsAndStabsVectorsMultistage");
DeclareGlobalFunction("OrbitMinimumMultistage");

#############################################################################
##
#F  FittingFreeElementarySeries( <G>[, <A>, <wholesocle>] )
##
##  <#GAPDoc Label="FittingFreeElementarySeries">
##  <ManSection>
##  <Func Name="FittingFreeElementarySeries" Arg='G[, A, wholesocle]'/>
##
##  <Description>
##  Let <A>G</A> be a finite group for which the record <C>ffs</C> returned
##  by <Ref Attr="FittingFreeLiftSetup"/> has been computed. This function
##  returns a descending subgroup series of <A>G</A> with elementary
##  factors that is compatible with the subgroups determined by <C>ffs</C>,
##  namely the radical, the socle of the factor group modulo the radical,
##  and the kernel of the action of that factor group on the direct factors
##  of its socle.
##  <P/>
##  The arguments <A>A</A> and <A>wholesocle</A> must be given together.
##  <A>A</A> is a group of automorphisms of <A>G</A>, and every subgroup in
##  the returned series is invariant under <A>A</A>; if a subgroup of
##  <A>G</A> is given instead, the corresponding inner automorphisms are
##  used. If <A>wholesocle</A> is <K>true</K>, the socle is not split up
##  according to the orbits on its direct factors, but is kept whole.
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> ser:=FittingFreeElementarySeries(G);;
##  gap> List(ser,Size);
##  [ 1080, 3, 1 ]
##  gap> List(FittingFreeElementarySeries(G,G,true),Size);
##  [ 1080, 3, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("FittingFreeElementarySeries");

#############################################################################
##
#A  DirectFactorsFittingFreeSocle( <G> )
##
##  <#GAPDoc Label="DirectFactorsFittingFreeSocle">
##  <ManSection>
##  <Attr Name="DirectFactorsFittingFreeSocle" Arg='G'/>
##
##  <Description>
##  For a finite Fitting-free group <A>G</A>, this attribute returns a list
##  of the direct factors of the socle of <A>G</A>. If <A>G</A> is not
##  Fitting-free, then <K>fail</K> is returned.
##  <P/>
##  The group <M>3.A_6</M> below has a non-trivial radical, but its factor
##  group modulo the radical is Fitting-free with simple socle:
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> DirectFactorsFittingFreeSocle(G);
##  fail
##  gap> f:=Image(FittingFreeLiftSetup(G).factorhom);;
##  gap> List(DirectFactorsFittingFreeSocle(f),Size);
##  [ 360 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("DirectFactorsFittingFreeSocle",IsGroup);

#############################################################################
##
#A  ChiefSeriesTF( <G> )
##
##  <#GAPDoc Label="ChiefSeriesTF">
##  <ManSection>
##  <Attr Name="ChiefSeriesTF" Arg='G'/>
##
##  <Description>
##  A chief series for <A>G</A> that is compatible with the data stored in
##  <Ref Attr="FittingFreeLiftSetup"/>.
##  <Example><![CDATA[
##  gap> G:=PerfectGroup(1080,1);;
##  gap> List(ChiefSeriesTF(G),Size);
##  [ 1080, 3, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ChiefSeriesTF",IsGroup);

#############################################################################
##
#F  HallViaRadical( <G>, <pi> )
##
DeclareGlobalFunction("HallViaRadical");
