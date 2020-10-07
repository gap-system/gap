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
##  The group $H$ is guaranteed to act on points [1..n] without fixedpoints.
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
## This is considered an old function that will be superseded by
##  FittingFreeLiftSetup
DeclareGlobalFunction("PermliftSeries");

DeclareAttribute("StoredPermliftSeries",IsGroup);

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
