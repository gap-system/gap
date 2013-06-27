#############################################################################
##
#W  invsgp.gd              GAP library                         J. D. Mitchell
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declaration of operations for inverse semigroups.
##

DeclareSynonym("IsInverseMonoid", IsMonoid and IsInverseSemigroup);

DeclareOperation("IsInverseSubsemigroup", [IsSemigroup, IsSemigroup]);

DeclareGlobalFunction("InverseMonoid");
DeclareGlobalFunction("InverseSemigroup");

DeclareAttribute("GeneratorsOfInverseMonoid", IsInverseSemigroup);
DeclareAttribute("GeneratorsOfInverseSemigroup", IsInverseSemigroup);

DeclareOperation("InverseMonoidByGenerators",
[IsAssociativeElementWithUniqueSemigroupInverseCollection]);
DeclareOperation("InverseSemigroupByGenerators",
[IsAssociativeElementWithUniqueSemigroupInverseCollection]);

DeclareOperation("InverseSubsemigroup",
[IsInverseSemigroup, IsAssociativeElementWithUniqueSemigroupInverseCollection]);
DeclareOperation("InverseSubsemigroupNC",
[IsInverseSemigroup, IsAssociativeElementWithUniqueSemigroupInverseCollection]);
DeclareOperation("InverseSubmonoid",
[IsInverseMonoid, IsAssociativeElementWithUniqueSemigroupInverseCollection]);
DeclareOperation("InverseSubmonoidNC",
[IsInverseMonoid, IsAssociativeElementWithUniqueSemigroupInverseCollection]);

DeclareAttribute("AsInverseSemigroup", IsCollection);
DeclareAttribute("AsInverseMonoid", IsCollection);
DeclareOperation("AsInverseSubsemigroup", [IsDomain, IsCollection]);
DeclareOperation("AsInverseSubmonoid", [IsDomain, IsCollection]);

DeclareAttribute("ReverseNaturalPartialOrder", IsInverseSemigroup);
DeclareAttribute("NaturalPartialOrder", IsInverseSemigroup);
