#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include James D. Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later

DeclareUserPreference(rec(
  name := ["PartialPermDisplayLimit", "NotationForPartialPerms"],
  description := ["options for the display of partial perms"],
  default := [100, "component"],
  check := function(a, b)
    return IsPosInt(a)
           or (IsString(b) and b in ["component", "domainimage", "input"]);
  end));

DeclareGlobalFunction("ComponentStringOfPartialPerm");

# creating partial perms
DeclareGlobalFunction("PartialPerm");
DeclareGlobalFunction("PartialPermNC");
DeclareGlobalFunction("RandomPartialPerm");

# attributes
DeclareAttribute("DomainOfPartialPerm", IsPartialPerm);
DeclareAttribute("ImageListOfPartialPerm", IsPartialPerm);
DeclareSynonym("CodegreeOfPartialPerm", CoDegreeOfPartialPerm);
DeclareAttribute("ImageSetOfPartialPerm", IsPartialPerm);
DeclareAttribute("IndexPeriodOfPartialPerm", IsPartialPerm);
DeclareAttribute("ComponentRepsOfPartialPerm", IsPartialPerm);
DeclareAttribute("NrComponentsOfPartialPerm", IsPartialPerm);
DeclareAttribute("ComponentsOfPartialPerm", IsPartialPerm);
DeclareAttribute("FixedPointsOfPartialPerm", IsPartialPerm);
DeclareAttribute("FixedPointsOfPartialPerm", IsPartialPermCollection);
DeclareAttribute("NrFixedPoints", IsPartialPerm);
DeclareAttribute("NrFixedPoints", IsPartialPermCollection);
DeclareAttribute("MovedPoints", IsPartialPerm);
DeclareAttribute("MovedPoints", IsPartialPermCollection);
DeclareAttribute("NrMovedPoints", IsPartialPerm);
DeclareAttribute("NrMovedPoints", IsPartialPermCollection);
DeclareAttribute("LargestMovedPoint", IsPartialPerm);
DeclareAttribute("LargestMovedPoint", IsPartialPermCollection);
DeclareAttribute("SmallestMovedPoint", IsPartialPerm);
DeclareAttribute("SmallestMovedPoint", IsPartialPermCollection);
DeclareAttribute("LargestImageOfMovedPoint", IsPartialPerm);
DeclareAttribute("LargestImageOfMovedPoint", IsPartialPermCollection);
DeclareAttribute("SmallestImageOfMovedPoint", IsPartialPerm);
DeclareAttribute("SmallestImageOfMovedPoint", IsPartialPermCollection);

# operations
DeclareOperation("PreImagePartialPerm", [IsPartialPerm, IsPosInt]);
DeclareOperation("ComponentPartialPermInt", [IsPartialPerm, IsPosInt]);
DeclareOperation("AsPartialPerm", [IsAssociativeElement, IsList]);
DeclareOperation("AsPartialPerm", [IsAssociativeElement]);
DeclareOperation("AsPartialPerm", [IsAssociativeElement, IsPosInt]);
DeclareOperation("AsPartialPerm", [IsAssociativeElement, IsZeroCyc]);
DeclareGlobalFunction("JoinOfPartialPerms");
DeclareGlobalFunction("JoinOfIdempotentPartialPermsNC");
DeclareGlobalFunction("MeetOfPartialPerms");
DeclareOperation("RestrictedPartialPerm", [IsPartialPerm, IsList]);
DeclareOperation("RestrictedPartialPerm", [IsPartialPerm]);
DeclareOperation("PermLeftQuoPartialPermNC", [IsPartialPerm, IsPartialPerm]);
DeclareOperation("PermLeftQuoPartialPerm", [IsPartialPerm, IsPartialPerm]);
DeclareOperation("TrimPartialPerm", [IsPartialPerm]);
DeclareOperation("PartialPermOp", [IsObject, IsList, IsFunction]);
DeclareOperation("PartialPermOp", [IsObject, IsList]);
DeclareOperation("PartialPermOp", [IsObject, IsDomain]);
DeclareOperation("PartialPermOp", [IsObject, IsDomain, IsFunction]);

DeclareOperation("PartialPermOpNC", [IsObject, IsList, IsFunction]);
DeclareOperation("PartialPermOpNC", [IsObject, IsList]);
DeclareOperation("PartialPermOpNC", [IsObject, IsDomain]);
DeclareOperation("PartialPermOpNC", [IsObject, IsDomain, IsFunction]);

# collections

DeclareAttribute("DegreeOfPartialPermCollection", IsPartialPermCollection);
DeclareAttribute("CodegreeOfPartialPermCollection", IsPartialPermCollection);
DeclareAttribute("RankOfPartialPermCollection", IsPartialPermCollection);
DeclareAttribute("DomainOfPartialPermCollection", IsPartialPermCollection);
DeclareAttribute("ImageOfPartialPermCollection", IsPartialPermCollection);

DeclareAttribute("OneImmutable", IsPartialPermCollection);
DeclareOperation("OneMutable", [IsPartialPermCollection]);

InstallTrueMethod(IsGeneratorsOfInverseSemigroup, IsPartialPermCollection);
