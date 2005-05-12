#############################################################################
##
#W  csetgrp.gd                      GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations of operations for cosets.
##
Revision.csetgrp_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoCoset
##
##  The information function for coset and double coset operations is
##  `InfoCoset'.
DeclareInfoClass("InfoCoset");

#############################################################################
##
#F  AscendingChain(<G>,<U>) . . . . . . .  chain of subgroups G=G_1>...>G_n=U
##
##  This function computes an ascending chain of subgroups from <U> to <G>.
##  This chain is given as a list whose first entry is <U> and the last entry
##  is <G>. The function tries to make the links in this chain small.
## 
##  The option `refineIndex' can be used to give a bound for refinements of
##  steps to avoid {\GAP} trying to enforce too small steps.
##
DeclareGlobalFunction("AscendingChain");

#############################################################################
##
#O  AscendingChainOp(<G>,<U>)  chain of subgroups
##
##  This operation does the actual work of computing ascending chains. It
##  gets called from `AscendingChain' if no chain is found stored in
##  `ComputedAscendingChains'.
##
DeclareOperation("AscendingChainOp",[IsGroup,IsGroup]);

#############################################################################
##
#A  ComputedAscendingChains(<U>)    list of already computed ascending chains
##
##  This attribute stores ascending chains. It is a list whose entries are
##  of the form [<G>,<chain>] where <chain> is an ascending chain from <U> up
##  to <G>. This storage is used by `AscendingChain' to avoid duplicate
##  calculations.
DeclareAttribute("ComputedAscendingChains",IsGroup,
                                        "mutable");

#############################################################################
##
#F  RefinedChain(<G>,<c>) . . . . . . . . . . . . . . . .  refine chain links
##
##  <c> is an ascending chain in the Group <G>. The task of this routine is
##  to refine c, i.e. if there is a "link" U>L in c with [U:L] too big,
##  this procedure tries to find Subgroups G_0,...,G_n of G; such that 
##  U=G_0>...>G_n=L. This is done by extending L inductively: Since normal
##  steps can help in further calculations, the routine first tries to
##  extend to the normalizer in U. If the subgroup is self-normalizing,
##  the group is extended via a random element. If this results in a step
##  too big, it is repeated several times to find hopefully a small
##  extension!
##
##  The option `refineIndex' can be used to tell {\GAP} that a specified
##  step index is good enough. The option `refineChainActionLimit' can be
##  used to give an upper limit up to which index guaranteed refinement
##  should be tried.
##
DeclareGlobalFunction("RefinedChain");

#############################################################################
##
#O  CanonicalRightCosetElement(U,g)    canonical representative of U*g 
##                                  (Representation dependent!)
##
##  returns a ``canonical'' representative of the coset <Ug> which is
##  independent of the given representative <g>. This can be used to compare
##  cosets by comparing their canonical representatives. The representative
##  chosen to be the ``canonical'' one is representation dependent and only
##  guaranteed to remain the same within one {\GAP} session.
##
DeclareOperation("CanonicalRightCosetElement",
  [IsGroup,IsObject]);

#############################################################################
##
#C  IsDoubleCoset(<obj>)
##
##  The category of double cosets.
DeclareCategory("IsDoubleCoset",
    IsDomain and IsExtLSet and IsExtRSet);

#############################################################################
##
#A  LeftActingGroup(<dcos>)
#A  RightActingGroup(<dcos>)
##
##  return the two groups that define a double coset <dcos>.
DeclareAttribute("LeftActingGroup",IsDoubleCoset);
DeclareAttribute("RightActingGroup",IsDoubleCoset);

#############################################################################
##
#O  DoubleCoset(<U>,<g>,<V>)
##
##  The groups <U> and <V> must be subgroups of a common supergroup <G> of
##  which <g> is an element. This command constructs the double coset <UgV>
##  which is the set of all elements of the form $ugv$ for any $u\in<U>$,
##  $v\in<V>$.  For element operations such as `in', a double coset behaves
##  like a set of group elements. The double coset stores <U> in the
##  attribute `LeftActingGroup', <g> as `Representative', and <V> as
##  `RightActingGroup'.
DeclareOperation("DoubleCoset",[IsGroup,IsObject,IsGroup]);

#############################################################################
##
#O  DoubleCosets(<G>,<U>,<V>)
#O  DoubleCosetsNC(<G>,<U>,<V>)
##
##  computes a duplicate free list of all double cosets <UgV> for $<g>\in<G>$.
##  <U> and <V> must be subgroups of the group <G>.
##  The NC version does not check whether <U> and <V> are both subgroups
##  of <G>.
##
DeclareGlobalFunction("DoubleCosets");
DeclareOperation("DoubleCosetsNC",[IsGroup,IsGroup,IsGroup]);

#############################################################################
##
#O  DoubleCosetRepsAndSizes(<G>,<U>,<V>)
##
##  returns a list of double coset representatives and their sizes, the
##  entries are lists of the form $[<rep>,<size>]$. This operation is faster
##  that `DoubleCosetsNC' because no double coset objects have to be
##  created.
DeclareOperation("DoubleCosetRepsAndSizes",[IsGroup,IsGroup,IsGroup]);

#############################################################################
##
#A  RepresentativesContainedRightCosets(<D>)
##
##  A double coset <UgV> can be considered as an union of right cosets
##  $<U>h_i$.  (it is the union of the orbit of $<Ug>$ under right
##  multiplication by $V$.) For a double coset <D>=<UgV> this returns a set
##  of representatives $h_i$ such that $<D>=\bigcup_{h_i}<U>h_i$. The
##  representatives returned are canonical for <U> (see
##  "CanonicalRightCosetElement") and form a set.
DeclareAttribute( "RepresentativesContainedRightCosets", IsDoubleCoset );

#############################################################################
##
#C  IsRightCoset(<obj>)
##
##  The category of right cosets.
DeclareCategory("IsRightCoset", IsDomain and IsExternalOrbit);

#############################################################################
##
#O  RightCoset(<U>,<g>)
##
##  returns the right coset of <U> with representative <g>, which is the set
##  of all elements of the form $ug$ for all $u\in<U>$.  <g> must be an
##  element of a larger group <G> which contains <U>. 
##  For element operations such as `in' a right coset behaves like a set of
##  group elements.
##
##  Right cosets are
##  external orbits for the action of <U> which acts via `OnLeftInverse'. Of
##  course the action of a larger group <G> on right cosets is via `OnRight'.
DeclareOperation("RightCoset",[IsGroup,IsObject]);


#############################################################################
##
#F  RightCosets(<G>,<U>)
#O  RightCosetsNC(<G>,<U>)
##
##  computes a duplicate free list of right cosets $Ug$ for $g\in<G>$. A set
##  of representatives for the elements in this list forms a right
##  transversal of <U> in <G>. (By inverting the representatives one obtains
##  a list of representatives of the left cosets of $U$.) The NC version
##  does not check whether <U> is a subgroup of <G>.
DeclareGlobalFunction("RightCosets");
DeclareOperation("RightCosetsNC",[IsGroup,IsGroup]);

#############################################################################
##
#F  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  This routine tries to find a subgroup <E> of <G>, such that $G>E>U$. If
##  $U$ is
##  maximal, it returns `fail'. This is done by finding minimal blocks for
##  the operation of <G> on the right cosets of <U>.
##
DeclareGlobalFunction("IntermediateGroup");

#############################################################################
##
#E  csetgrp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
