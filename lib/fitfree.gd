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
##  This file contains functions using the trivial-fitting paradigm.
##

BindGlobal("OVERRIDENICE",Maximum(NICE_FLAGS,
               RankFilter(IsMatrixGroup and IsFinite)));

#############################################################################
##
#V  InfoFitFree
##
##  the info class for fitting free calculations
DeclareInfoClass("InfoFitFree");

#############################################################################
##
#F  CanComputeFittingFree( <grp> ) . . . . .  TF approach is possible
##
##  <#GAPDoc Label="CanComputeFittingFree">
##  <ManSection>
##  <Func Name="CanComputeFittingFree" Arg='grp'/>
##
##  <Description>
##  This filter indicates whether algorithms using the TF-paradigm (Trivial
##  Fitting/Solvable Radical)
##  can be used for a group, that is whether a method for
##  <Ref Func="FittingFreeLiftSetup"/> is available for <A>grp</A>.
##  Note that this filter may change its value from <K>false</K> to
##  <K>true</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "CanComputeFittingFree" );

# to satisfy method installation requirements
InstallTrueMethod(IsFinite,CanComputeFittingFree);
InstallTrueMethod(IsGroup,CanComputeFittingFree);

InstallTrueMethod(CanComputeFittingFree, IsPermGroup);
InstallTrueMethod(CanComputeFittingFree, IsPcGroup);

#############################################################################
##
#F  AttemptPermRadicalMethod( <grp>,<task> )
##
##  <#GAPDoc Label="AttemptPermRadicalMethod">
##  <ManSection>
##  <Func Name="AttemptPermRadicalMethod" Arg='grp,task'/>
##
##  <Description>
##  Function that encodes (hard-coded) heuristics on whether it is worth to use
##  Trivial-Fitting/Solvable Radical methods for problems in permutation
##  groups in favor over backtrack solutions. Returns <K>fail</K> if decision
##  cannot be made.
##  The kind of problem is described by a string. Currently supported are
##  <K>"CENT"</K> for centralizer/element conjugacy.
##  </Description>
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
##  for a finite group <A>G</A>, this returns a record with the following
##  components:
##  <C>radical</C> The solvable radical <M>Rad(G)</M>.
##  <C>pcgs</C> A pcgs for <M>Rad(G)</M> that refines a
##  <M>G</M>-normal series
##  with elementary abelian factors.
##  <C>depths</C>
##  A list of indices in the pcgs, indicating the <M>G</M>-normal subgroups in
##  the series for the pcgs, including an entry for the trivial subgroup.
##  <C>pcisom</C>  An effective isomorphism from a supergroup of <M>Rad(G)</M> to a pc group
##  <C>factorhom</C> A epimorphism from <M>G</M> onto <M>G/Rad(G)</M>,
##  the image group being
##  represented in a way that decomposition into generators will work
##  efficiently. In particular, it is possible to use
##  <Ref Func="PreImagesRepresentative"/> to take the pre-image of elements
##  in the image. For a subgroup <M>U\le G</M>, it is possible to apply
##  <Ref Func="RestrictedMapping"> to the homomorphism to obtain a
##  corresponding homomorphism for <M>U</M>.
##
##  The redundancy amongst the components is deliberate, as the redundant
##  objects can be created at minimal extra cost and not doing so risks the
##  creation of duplicate objects by user code later on.
##  The record may hold other components that are germane to the recognition
##  setup. These components may not be modified by user code.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareAttribute("FittingFreeLiftSetup",IsGroup);
InstallTrueMethod(CanComputeFittingFree,HasFittingFreeLiftSetup);

#############################################################################
##
#F  FittingFreeSubgroupSetup( <G>, <U> )
##
##  <#GAPDoc Label="FittingFreeSubgroupSetup">
##  <ManSection>
##  <Attr Name="FittingFreeSubgroupSetup" Arg='G,U'/>
##
##  <Description>
##  for a subgroup <A>U</A> of a finite group <A>G</A>, for which
##  <Ref Func="FittingFreeLiftSetup"> has been computed, this function
##  computes a compatible setup for <A>U</A>. (This information is cached in
##  <A>U</A>
##  for further calculation later.)
##  It returns a record with the following
##  components:
##  <C>parentffs</C> The record returned by
##  <Ref Func="FittingFreeLiftSetup"> for <G>.
##  <C>rest</C> A restriction of
##  the <C>factorhom</C> for <A>G</A> to <A>U</A>, defined on generators of
##  <A>U</A>.
##  <C>ker</C> The kernel of this map.
##  <C>pcgs</C> A pcgs for this kernel.
##  <C>serdepths</C>
##  For each depth step in the pcgs for the radical of <G>, as stored in
##  <C>parentffs</C>, this indicates the index in <C>pcgs</C> for <A>U</A>,
##  at which this depth is achieved.
##
##  The record may hold other components that are germane to the recognition
##  setup. These components may not be modified by user code.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("FittingFreeSubgroupSetup");
DeclareOperation("DoFFSS",[IsGroup,IsGroup]);

# This attribute is used for groups treated by constructive recognition and
# a composition tree. It is declared in the library such that the function
# FittingFreeSubgroupSetup can maintain it.
DeclareAttribute("RecogDecompinfoHomomorphism",IsMapping,"mutable");

#############################################################################
##
#F  SubgroupByFittingFreeData( <G>, <gens>, <imgs>, <ipcgs> )
##
##  <#GAPDoc Label="SubgroupByFittingFreeData">
##  <ManSection>
##  <Attr Name="SubgroupByFittingFreeData" Arg='G,U'/>
##
##  <Description>
##  For a finite group <A>G</A>, for which
##  <Ref Func="FittingFreeLiftSetup"> <A>ffs</A> has been computed,
##  this function returns a subgroup <A>U</A> build from data compatible with
##  <A>ffs</A>: <A>U</A> is the subgroup generated by <A>gens</A> and
##  <A>ipcgs</A>.
##  <A>ipcgs</A> is an induced Pcgs for <M>U\cap Rad(G)</M>, with respect to
##  the Pcgs stored in <A>ffs</A>. <A>imgs</A> are images of <A>gens</A>
##  under <A>ffs<C>.factorhom</C></A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("SubgroupByFittingFreeData");

# Utility function: function(pcgs,gens,ignoredepths)
# for forming an induced modulo pcgs after correction on the lowest level
# We will be in the situation that an IGS has been corrected only on the
# lowest level, i.e. the only obstacle to being an IGS is on the lowest
# level. Thus the situation is that of a vector space and we do not need to
# consider commutators and powers, but simply do a Gaussian elimination.
DeclareGlobalFunction("TFMakeInducedPcgsModulo");

# Utility function: Orbit algorithms when acting with a GPCGS
DeclareGlobalFunction("OrbitsRepsAndStabsVectorsMultistage");
DeclareGlobalFunction("OrbitMinimumMultistage");

#############################################################################
##
#F  FittingFreeElementarySeries( <G>, [<A>, <wholesocle>])
##
##  <#GAPDoc Label="FittingFreeElementarySeries">
##  <ManSection>
##  <Attr Name="FittingFreeElementarySeries" Arg='G,A,wholesocle'/>
##
##  <Description>
##  For a finite group <A>G</A>, for which
##  <Ref Func="FittingFreeLiftSetup"> <A>ffs</A> has been computed,
##  this function returns a subgroup series with elementary factors, each
##  invariant under action by <A>A</A> if given,
##  compatible with radical, socle factor and pker.
##  If <A>wholesocle</A> is given and set to true the socles are not split
##  up according to isomorphism types, but are kept whole.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  for a finite fitting-free group <A>G</A>, this function returns a list of
##  the direct factors of the socle of <A>G</A>. If <A>G</A> is not
##  fitting-free then <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  A chief series for <A>G</A> that fits with the FittingFreeLiftSetup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareAttribute("ChiefSeriesTF",IsGroup);

#############################################################################
##
#F  HallViaRadical( <G>, <pi> )
##
DeclareGlobalFunction("HallViaRadical");

