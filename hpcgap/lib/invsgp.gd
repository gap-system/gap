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
InstallTrueMethod(IsGeneratorsOfSemigroup, IsGeneratorsOfInverseSemigroup);

DeclareAttribute("GeneratorsOfInverseMonoid", IsInverseSemigroup);
DeclareAttribute("GeneratorsOfInverseSemigroup", IsInverseSemigroup);

DeclareOperation("InverseMonoidByGenerators", [IsCollection]);
DeclareOperation("InverseSemigroupByGenerators", [IsCollection]);

DeclareOperation("InverseSubsemigroup",
[IsInverseSemigroup, IsCollection]);
DeclareOperation("InverseSubsemigroupNC",
[IsInverseSemigroup, IsCollection]);
DeclareOperation("InverseSubmonoid",
[IsInverseMonoid, IsCollection]);
DeclareOperation("InverseSubmonoidNC",
[IsInverseMonoid, IsCollection]);

DeclareAttribute("AsInverseSemigroup", IsCollection);
DeclareAttribute("AsInverseMonoid", IsCollection);
DeclareOperation("AsInverseSubsemigroup", [IsDomain, IsCollection]);
DeclareOperation("AsInverseSubmonoid", [IsDomain, IsCollection]);

DeclareAttribute("ReverseNaturalPartialOrder", IsSemigroup);
DeclareAttribute("NaturalPartialOrder", IsSemigroup);
