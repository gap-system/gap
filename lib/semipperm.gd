############################################################################
##
#W  semipperm.gd           GAP library                         J. D. Mitchell
##
##
#Y  Copyright (C)  2013,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
