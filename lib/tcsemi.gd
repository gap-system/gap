#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Götz Pfeiffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Installed in GAP4 by Andrew Solomon for Semigroups instead of Monoids.
##
##  This file contains declarations for Todd-Coxeter procedure for
##  fp semigroups.
##

############################################################################
##
#A  CosetTableOfFpSemigroup(<r>)
##
##  <#GAPDoc Label="CosetTableOfFpSemigroup">
##  <ManSection>
##  <Attr Name="CosetTableOfFpSemigroup" Arg='r'/>
##
##  <Description>
##  <A>r</A> is a right congruence of an fp-semigroup <A>S</A>.
##  This attribute is the coset table of FP semigroup
##  <A>S</A> on a right congruence <A>r</A>.
##  Given a right congruence <A>r</A> we represent <A>S</A> as a set of
##  transformations of the congruence classes of <A>r</A>.
##  <P/>
##  The images   of the cosets under the   generators are compiled in  a list
##  <A>table</A> such that  <A>table[i][s]</A> contains  the image  of  coset <A>s</A> under
##  generator <A>i</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareAttribute("CosetTableOfFpSemigroup", IsRightMagmaCongruence);

##  The preimages are  stored in a similar  way  in the list
##  |occur|.  Here |occur[i][s]|  contains the set  of  all cosets  which are
##  mapped to |s| under generator |i|.  There the empty set is represented by
##  0. The  list |occur| is needed  for the sole   purpose of identifying the
##  places in |table| where a coset |t|  occurs if this  needs to be replaced
##  by a coset |s|.
##

SemigroupTCInitialTableSize:= 5000000;
