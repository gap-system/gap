#############################################################################
##
#W  permdeco.gd                  GAP library                  Alexander Hulpke
##
##
#Y  Copyright (C) 2004 The GAP Group
##
##  This file contains functions that deal with action on chief factors or
##  composition factors and the representation of such groups in a nice way
##  as permutation groups.
##

#############################################################################
##
#F  AutomorphismRepresentingGroup( <G>, <autos> )
##
##  Let $G$ be a permutation group and <autos> a set of automorphisms of
##  <G>. This function returns a permutation group $H$, isomorphic to $G$,
##  such that all the automorphisms in <autos> can be represented by
##  conjugation of $H$ with elements of the symmetric group. It returns a
##  list $[H2,\phi,a]$ where $\phi is the isomorphism $G\to H$, and $a$ a
##  list of permutations corresponding to <autos> that induce the same
##  automorphisms of $H$. Finally $H2=\left\langle H,a\right\rangle$.
##  The algorithm may fail if <G> is not almost simple.
DeclareGlobalFunction("AutomorphismRepresentingGroup");

#############################################################################
##
#F  EmbedAutomorphisms(<G>,<H>,<GT>,<HT>[,<outs>])
##
##  Suposet that $GT$ and $HT$ are isomorphic simple groups and $GT\le
##  G\le\Aut(GT)$ and $HT\le H\le \Aut(HT)$. This function returns a new
##  group $P$ isomorphic to a subgroup of $\Aut(GT)$ and monomorphisms
##  $\phi\colon G\to P$ and $\psi\colon H\to P$ in the form of a list
##  $[P,\phi,\psi]$.
##  The size of the outer automorphism group of $T$ may be given in <outs>
##  and will speed up the calculation.
DeclareGlobalFunction("EmbedAutomorphisms");

#############################################################################
##
#F  WreathActionChiefFactor( <G>, <M>, <N> )
##
##  Suppose that $M/N$ is a chief factor of <G> and $M/N$ is isomorphic to
##  $T^n$ where $T$ is simple. Then the action of $G$ on $M/N$ embeds in
##  $\Aut(T)\wr S_n$. This function creates this embedding. It returns
##  a list $[W,\phi,A,T,n]$, where $T$ is the simple group, $A\ge T$ the group of
##  automorphisms of $T$ induced (not necessarily the full automorphism
##  group), $W=A\wr S_n$ and $\phi\colon G\to W$ the map embedding $G$ into
##  $W$.
DeclareGlobalFunction("WreathActionChiefFactor");

#############################################################################
##
#F  PermliftSeries( <G> )
##
## This function constructs a descending series of normal subgroups of <G>,
## starting with the radical (the largest solvable normal subgroup) of <G>,
## such that the factors of subsequent subgroups in the series are
## elementary abelian.
## It returns a list of length 2. The first argument is the series, the
## second argument is either a List of (induced) Pcgs for the subgroups in
## the series (if such pcgs can be obtained cheaply as a byproduct of the
## way the series was obtained) or `false'.
## The option `limit' can be used to limit the orders of the solvable
## factors (if possible).
##
## This is considered an old function that will be superceded by
##  FittingFreeLiftSetup
DeclareGlobalFunction("PermliftSeries");

DeclareAttribute("StoredPermliftSeries",IsGroup);

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
##  <C>pcisom</C>  An effective isomorphism from <M>Rad(G)</M> to a pc group
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
DeclareAttribute("FittingFreeLiftSetup",IsGroup);

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
DeclareGlobalFunction("FittingFreeSubgroupSetup");

# This attribute is used for groups treated by constructive recognition and
# a composition tree. It is declared in the library such that the function
# FittingFreeSubgroupSetup can maintain it.
DeclareAttribute("RecogDecompinfoHomomorphism",IsMapping);

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
DeclareGlobalFunction("SubgroupByFittingFreeData");


#############################################################################
##
#F  EmbeddingWreathInWreath( <W2>,<W>,<emb>,<start> )
##
##  Let $W=A\wr B$ and $W2=C\wr D$ be two wreath products with $B\le D$
##  (considering $B$ and $D$ as permutation groups) and
##  $<emb>\colon A\to C$. This function returns a monomorphism from $W$ into
##  $W2$, involving the copies of $C$ at position <start> and at the following
##  indices.
DeclareGlobalFunction("EmbeddingWreathInWreath");

#############################################################################
##
#F  EmbedFullAutomorphismWreath(<W>,<A>,<T>,<n>)
##
##  Suppose that $T\le G\le A\le\Aut(T)$ and that $W=G\wr S$ with $S\le
##  S_n$. This function calculates the wreath product $W2=\Aut(T)\wr S$ and
##  the embedding.
DeclareGlobalFunction("EmbedFullAutomorphismWreath");

#############################################################################
##
#E  permdeco.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
