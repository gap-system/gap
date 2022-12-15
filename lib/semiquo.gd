#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon and Isabel Araújo.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for quotient semigroups.
##
##  <#GAPDoc Label="[1]{semiquo}">
##  For a semigroup <M>S</M>,
##  elements of a quotient semigroup are equivalence classes of
##  elements of the <Ref Attr="QuotientSemigroupPreimage"/> value
##  under the congruence given by the value of
##  <Ref Attr="QuotientSemigroupCongruence"/>.
##  <P/>
##  It is probably most useful for calculating the elements of
##  the equivalence classes by using <Ref Func="Elements"/> or by looking at
##  the images of elements of <Ref Attr="QuotientSemigroupPreimage"/> under
##  the map returned by <Ref Attr="QuotientSemigroupHomomorphism"/>,
##  which maps the <Ref Attr="QuotientSemigroupPreimage"/> value to <A>S</A>.
##  <P/>
##  For intensive computations in a quotient semigroup, it is probably
##  worthwhile finding another representation as the equality test
##  could involve enumeration of the elements of the congruence classes
##  being compared.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsQuotientSemigroup( <S> )
##
##  <#GAPDoc Label="IsQuotientSemigroup">
##  <ManSection>
##  <Filt Name="IsQuotientSemigroup" Arg='S' Type='Category'/>
##
##  <Description>
##  is the category of semigroups constructed from another semigroup
##  and a congruence on it.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsQuotientSemigroup", IsSemigroup);

#############################################################################
##
#F  HomomorphismQuotientSemigroup(<cong>)
##
##  <#GAPDoc Label="HomomorphismQuotientSemigroup">
##  <ManSection>
##  <Func Name="HomomorphismQuotientSemigroup" Arg='cong'/>
##
##  <Description>
##  for a congruence <A>cong</A> and a semigroup <A>S</A>.
##  Returns the homomorphism from <A>S</A> to the quotient of <A>S</A>
##  by <A>cong</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("HomomorphismQuotientSemigroup");

#############################################################################
##
#A  QuotientSemigroupPreimage(<S>)
#A  QuotientSemigroupCongruence(<S>)
#A  QuotientSemigroupHomomorphism(<S>)
##
##  <#GAPDoc Label="QuotientSemigroupPreimage">
##  <ManSection>
##  <Attr Name="QuotientSemigroupPreimage" Arg='S'/>
##  <Attr Name="QuotientSemigroupCongruence" Arg='S'/>
##  <Attr Name="QuotientSemigroupHomomorphism" Arg='S'/>
##
##  <Description>
##  for a quotient semigroup <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("QuotientSemigroupPreimage", IsQuotientSemigroup);
DeclareAttribute("QuotientSemigroupCongruence", IsQuotientSemigroup);
DeclareAttribute("QuotientSemigroupHomomorphism", IsQuotientSemigroup);
