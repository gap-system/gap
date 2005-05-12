#############################################################################
##
#W  semiquo.gd           GAP library          Andrew Solomon and Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for quotient semigroups.
##

#1
##  Elements of a quotient semigroup are equivalence classes of 
##  elements of `QuotientSemigroupPreimage(<S>)'
##  under the congruence `QuotientSemigroupCongruence(<S>)'.
##
##  It is probably most useful for calculating the elements of 
##  the equivalence classes by using Elements or by looking at the
##  images of elements of the `QuotientSemigroupPreimage(<S>)' under
##  `QuotientSemigroupHomomorphism(<S>)':`QuotientSemigroupPreimage(<S>)'
##  $\rightarrow$ <S>.
##
##  For intensive computations in a quotient semigroup, it is probably
##  worthwhile finding another representation as the equality test 
##  could involve enumeration of the elements of the congruence classes
##  being compared.
##

Revision.semiquo_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsQuotientSemigroup( <S> )
##
##	is the category of semigroups constructed from another semigroup 
##	and a congruence on it
##
DeclareCategory("IsQuotientSemigroup", IsSemigroup);

#############################################################################
##
#F  HomomorphismQuotientSemigroup(<cong>)
##
##  for a congruence <cong> and a semigroup <S>. 
##  Returns the homomorphism from <S> to the quotient of <S> 
##  by <cong>.
##
DeclareGlobalFunction("HomomorphismQuotientSemigroup");

#############################################################################
##
#A  QuotientSemigroupPreimage(<S>)
#A  QuotientSemigroupCongruence(<S>)
#A  QuotientSemigroupHomomorphism(<S>)
##  
##	for a quotient semigroup <S>.
##
DeclareAttribute("QuotientSemigroupPreimage", IsQuotientSemigroup);
DeclareAttribute("QuotientSemigroupCongruence", IsQuotientSemigroup);
DeclareAttribute("QuotientSemigroupHomomorphism", IsQuotientSemigroup);


#############################################################################
##
#E

