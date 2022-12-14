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
##  This file contains the implementation of some basics for partial perm
##  semigroups.

DeclareSynonym("IsPartialPermSemigroup", IsSemigroup and
IsPartialPermCollection);
DeclareSynonym("IsPartialPermMonoid", IsMonoid and
IsPartialPermCollection);

DeclareAttribute("DegreeOfPartialPermSemigroup", IsPartialPermSemigroup);
DeclareAttribute("CodegreeOfPartialPermSemigroup", IsPartialPermSemigroup);
DeclareAttribute("RankOfPartialPermSemigroup", IsPartialPermSemigroup);

DeclareProperty("IsSymmetricInverseSemigroup", IsPartialPermSemigroup);
InstallTrueMethod(IsInverseSemigroup, IsSymmetricInverseSemigroup);
DeclareSynonym("IsSymmetricInverseMonoid", IsSymmetricInverseSemigroup);
DeclareOperation("SymmetricInverseSemigroup", [IsInt]);
DeclareSynonym("SymmetricInverseMonoid", SymmetricInverseSemigroup);

DeclareAttribute("IsomorphismPartialPermSemigroup", IsSemigroup);
DeclareAttribute("IsomorphismPartialPermMonoid", IsSemigroup);
