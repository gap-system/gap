#############################################################################
##
#W  csetgrp.gd                      GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of operations for cosets.
##
Revision.csetgrp_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoCoset
##
##  The information class for routines computing cosets and double cosets.
DeclareInfoClass("InfoCoset");

#############################################################################
##
#F  AscendingChain(<G>,<U>) . . . . . . .  chain of subgroups G=G_1>...>G_n=U
##
##  This function computes an ascending chain of subgroups from <U> to <G>.
##  This chain is given as a list whose first entry is <U> and the last entry
##  is <G>. The function tries to make the links in this chain small.
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
#O  CanonicalRightCosetElement(U,g)    canonical representative of U*g 
##                                  (Representation dependent!)
##
##  returns an element of the coset <Ug> which is independent of the
##  representative <g> chosen. This can be used to compare cosets by comparing
##  their canonical representatives. The representative chosen to be the
##  canonical one is representative dependent and only guaranteed to remain the
##  same within one {\GAP} session.
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
#O  DoubleCoset(<U>,<g>,<V>)
##
##  The groups <U> and <V> must be subgroups of a common supergroup <G> of which
##  <g> is an element. This command constructs the double coset <UgV> which is
##  the set of all elements of the form $ugv$ for any $u\in<U>$, $v\in<V>$.
##  For element operations like `in' a double coset behaves like a set of group
##  elements.
DeclareOperation("DoubleCoset",[IsGroup,IsObject,IsGroup]);

#############################################################################
##
#O  DoubleCosets(<G>,<U>,<V>)
#O  DoubleCosetsNC(<G>,<U>,<V>)
##
##  computes a duplicate free list of all double cosets <UgV> for $<g>\in<G>$.
##  <U> and <V> must be subgroups of the group <G>.
##  The NC version does not check the validity of the parameters.
##
DeclareGlobalFunction("DoubleCosets");
DeclareOperation("DoubleCosetsNC",[IsGroup,IsGroup,IsGroup]);

#############################################################################
##
#A  RepresentativesContainedRightCosets(<D>)
##
##  A double coset <UgV> can be considered as an union of right cosets $<U>h_i$.
##  (it is the orbit of $<Ug>$ under right multiplication by $V$.) For a double
##  coset <D>=<UgV> this returns a set of representatives $h_i$ such that
##  $<D>=\bigcup_{h_i}<U>h_i$. The representatives returned are canonical
##  for <U> (see "CanonicalRightCosetElement") and form a set.
DeclareAttribute( "RepresentativesContainedRightCosets", IsDoubleCoset );

#############################################################################
##
#C  IsRightCoset(<obj>)
##
##  The category of right cosets.
DeclareCategory("IsRightCoset",
    IsDomain and IsExternalSet);

#############################################################################
##
#O  RightCoset(<U>,<g>)
##
##  returns the right coset of <U> with representative <g>, which is 
##  the set of all elements of the form $ug$ for any $u\in<U>$.
##  <g> must be an element of a supergroup <G> which contains <U>.
##  Right cosets are external orbits for the action of <U> which acts via
##  `OnLeftInverse'.
##  For element operations like `in' a right coset behaves like a set of group
##  elements.
DeclareOperation("RightCoset",[IsGroup,IsObject]);


#############################################################################
##
#O  RightCosets(<G>,<U>)
#O  RightCosetsNC(<G>,<U>)
##
##  computes a duplicate free list of right cosets $<U>g$ for $g\in<G>$. A set
##  of representatives for the elements in this list forms a right transversal
##  of <U> in <G>. (By inverting the representatives one obtains a list
##  of left cosets.) The NC version does not check the parameters.
DeclareGlobalFunction("RightCosets");
DeclareOperation("RightCosetsNC",[IsGroup,IsGroup]);

#############################################################################
##
#A  RightCosetsDefaultType(<fam>)
##
##  If $U$ is a group and <fam> the family of <U>, this attribute stores the
##  default type of right cosets of $U$. This is the type a right coset has once
##  it is created without any further knowledge about its properties.
##  The function is used to speed up the creation of large numbers of cosets
##  which initially all have the same type.
DeclareAttribute("RightCosetsDefaultType",IsFamily);

#############################################################################
##
#A  DoubleCosetsDefaultType(<fam>)
##
##  If $U$ and <V> are groups and <fam> their family, this attribute stores the
##  default type of double cosets $UgV$. This is the type a double coset has
##  once it is created without any further knowledge about its properties.
##  The function is used to speed up the creation of large numbers of cosets
##  which initially all have the same type.
DeclareAttribute("DoubleCosetsDefaultType",IsFamily);

#############################################################################
##
#F  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  This routine tries to find a subgroup <E> of <G>, such that $G>E>U$. If
##  $U$ is
##  maximal, it returns false. This is done by finding minimal blocks for
##  the operation of <G> on the right cosets of <U>.
##
DeclareGlobalFunction("IntermediateGroup");

#############################################################################
##
#E  csetgrp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
