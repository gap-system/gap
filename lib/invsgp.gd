#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include J. D. Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of operations for inverse semigroups.
##

# IsInverseMonoid is documented with IsInverseSemigroup in semigrp.gd
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

DeclareOperation("InverseSubsemigroup", [IsInverseSemigroup, IsCollection]);
DeclareOperation("InverseSubsemigroupNC", [IsInverseSemigroup, IsCollection]);
DeclareOperation("InverseSubmonoid", [IsInverseMonoid, IsCollection]);
DeclareOperation("InverseSubmonoidNC", [IsInverseMonoid, IsCollection]);

DeclareAttribute("AsInverseSemigroup", IsCollection);
DeclareAttribute("AsInverseMonoid", IsCollection);
DeclareOperation("AsInverseSubsemigroup", [IsDomain, IsCollection]);
DeclareOperation("AsInverseSubmonoid", [IsDomain, IsCollection]);

DeclareAttribute("ReverseNaturalPartialOrder", IsSemigroup);
DeclareAttribute("NaturalPartialOrder", IsSemigroup);
