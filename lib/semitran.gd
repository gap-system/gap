#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Isabel Araújo and Robert Arthur.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for basics of transformation semigroup
##

DeclareSynonym("IsTransformationSemigroup", IsSemigroup and
        IsTransformationCollection);
DeclareSynonym("IsTransformationMonoid", IsMonoid and
IsTransformationCollection);

DeclareProperty("IsFullTransformationSemigroup", IsSemigroup);
InstallTrueMethod(IsSemigroup, IsFullTransformationSemigroup);

DeclareSynonym("IsFullTransformationMonoid", IsFullTransformationSemigroup);

DeclareGlobalFunction("FullTransformationSemigroup");
DeclareSynonym("FullTransformationMonoid", FullTransformationSemigroup);

DeclareAttribute("DegreeOfTransformationSemigroup", IsTransformationSemigroup);

DeclareAttribute("IsomorphismPermGroup", IsGreensHClass);
DeclareAttribute("IsomorphismTransformationSemigroup", IsSemigroup);
DeclareAttribute("IsomorphismTransformationMonoid", IsSemigroup);
DeclareOperation("HomomorphismTransformationSemigroup",
  [IsSemigroup, IsRightMagmaCongruence]);

DeclareAttribute("AntiIsomorphismTransformationSemigroup", IsSemigroup);

