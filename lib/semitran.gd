#############################################################################
##
#W  semitran.gd           GAP library         Isabel Araújo and Robert Arthur 
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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

