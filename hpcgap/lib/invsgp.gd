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

DeclareProperty("IsGeneratorsOfInverseSemigroup", IsListOrCollection);

DeclareAttribute("GeneratorsOfInverseMonoid", IsInverseSemigroup);
DeclareAttribute("GeneratorsOfInverseSemigroup", IsInverseSemigroup);

DeclareOperation("InverseMonoidByGenerators", [IsGeneratorsOfSemigroup]);
DeclareOperation("InverseSemigroupByGenerators", [IsGeneratorsOfSemigroup]);

DeclareOperation("InverseSubsemigroup",
[IsInverseSemigroup, IsGeneratorsOfSemigroup]);
DeclareOperation("InverseSubsemigroupNC",
[IsInverseSemigroup, IsGeneratorsOfSemigroup]);
DeclareOperation("InverseSubmonoid",
[IsInverseMonoid, IsGeneratorsOfSemigroup]);
DeclareOperation("InverseSubmonoidNC",
[IsInverseMonoid, IsGeneratorsOfSemigroup]);

DeclareAttribute("AsInverseSemigroup", IsCollection);
DeclareAttribute("AsInverseMonoid", IsCollection);
DeclareOperation("AsInverseSubsemigroup", [IsDomain, IsCollection]);
DeclareOperation("AsInverseSubmonoid", [IsDomain, IsCollection]);

DeclareAttribute("ReverseNaturalPartialOrder", IsSemigroup);
DeclareAttribute("NaturalPartialOrder", IsSemigroup);
