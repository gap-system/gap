#############################################################################
##
#W  semitran.gd           GAP library         Isabel Araujo and Robert Arthur 
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for basics of transformation semigroup 

Revision.semitran_gd :=
    "@(#)$Id$";

#############################################################################
##
#P  IsTransformationSemigroup( <obj> )
#P  IsTransformationMonoid( <obj> )
##
##	A transformation semigroup (resp. monoid) is a subsemigroup
##	(resp. submonoid) of the full transformation monoid.
##	Note that for a transformation semigroup to be a transformation monoid
##	we necessarily require the identity transformation to be an element.
##
DeclareSynonymAttr("IsTransformationSemigroup", IsSemigroup and
	IsTransformationCollection);
DeclareProperty("IsTransformationMonoid", IsTransformationSemigroup);

#############################################################################
##
#A  DegreeOfTransformationSemigroup( <S> )
##
##	The number of points the semigroup acts on.
DeclareAttribute("DegreeOfTransformationSemigroup",
	IsTransformationSemigroup);

############################################################################
##
#A  IsomorphismTransformationSemigroup(<S>)
#O  HomomorphismTransformationSemigroup(<S>,<r>)
##
##
##  IsomorphismTransformationSemigroup is a generic attribute which 
##  is a transformation semigroup isomorphic to <S> (if such can 
##  be computed). In the case of an fp- semigroup, a todd-coxeter
##  will be attempted. For a semigroup of endomorphisms of a finite 
##  domain of <n> elements, it will be to a semigroup of transformations
##  of $\{1, \ldots, n\}$. Otherwise, it will be the right regular 
##  representation on $S$ or $S^1$ if $S$ has no 
##  MultiplicativeNeutralElement.
##
##  HomomorphismTransformationSemigroup
##  finds a representation of <S> as transformations of the set of
##  equivalence classes of the right congruence <r>.
##

DeclareAttribute("IsomorphismTransformationSemigroup",
  IsSemigroup);

DeclareOperation("HomomorphismTransformationSemigroup",
  [IsSemigroup,IsRightMagmaCongruence]);


#############################################################################
##
#E

