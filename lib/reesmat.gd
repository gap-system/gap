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
##  This file contains the declarations for Rees Matrix semigroups

# Elements...

DeclareCategory( "IsReesMatrixSemigroupElement", IsAssociativeElement);
DeclareCategory( "IsReesZeroMatrixSemigroupElement", IsAssociativeElement);

DeclareCategoryCollections( "IsReesMatrixSemigroupElement");
DeclareCategoryCollections( "IsReesZeroMatrixSemigroupElement");

DeclareGlobalFunction( "RMSElement" );
DeclareSynonym( "ReesMatrixSemigroupElement", RMSElement);
DeclareSynonym( "ReesZeroMatrixSemigroupElement", RMSElement);

DeclareOperation("ELM_LIST", [IsReesMatrixSemigroupElement, IsPosInt]);
DeclareOperation("ELM_LIST", [IsReesZeroMatrixSemigroupElement, IsPosInt]);

DeclareProperty("IsOne", IsReesMatrixSemigroupElement);
DeclareProperty("IsOne", IsReesZeroMatrixSemigroupElement);

# for backwards compatibility...

DeclareOperation("RowOfReesMatrixSemigroupElement",
  [IsReesMatrixSemigroupElement]);
DeclareOperation("RowOfReesZeroMatrixSemigroupElement",
  [IsReesZeroMatrixSemigroupElement]);

DeclareOperation("ColumnOfReesMatrixSemigroupElement",
  [IsReesMatrixSemigroupElement]);
DeclareOperation("ColumnOfReesZeroMatrixSemigroupElement",
  [IsReesZeroMatrixSemigroupElement]);

DeclareOperation("UnderlyingElementOfReesMatrixSemigroupElement",
  [IsReesMatrixSemigroupElement]);
DeclareOperation("UnderlyingElementOfReesZeroMatrixSemigroupElement",
  [IsReesZeroMatrixSemigroupElement]);

# Semigroups...

DeclareSynonymAttr("IsReesMatrixSubsemigroup",
  IsSemigroup and IsReesMatrixSemigroupElementCollection);
DeclareSynonymAttr("IsReesZeroMatrixSubsemigroup",
  IsSemigroup and IsReesZeroMatrixSemigroupElementCollection);

DeclareProperty("IsReesMatrixSemigroup", IsSemigroup);
InstallTrueMethod( IsSemigroup, IsReesMatrixSemigroup );
DeclareProperty("IsReesZeroMatrixSemigroup", IsSemigroup);
InstallTrueMethod( IsSemigroup, IsReesZeroMatrixSemigroup );

InstallTrueMethod(IsReesMatrixSemigroup,
  IsReesMatrixSubsemigroup and IsWholeFamily);
InstallTrueMethod(IsReesZeroMatrixSemigroup,
  IsReesZeroMatrixSubsemigroup and IsWholeFamily);

DeclareOperation("ReesMatrixSemigroup", [IsSemigroup, IsRectangularTable]);
DeclareOperation("ReesZeroMatrixSemigroup", [IsSemigroup, IsDenseList]);

DeclareOperation( "GeneratorsOfReesMatrixSemigroup",
  [IsReesMatrixSubsemigroup, IsList, IsSemigroup, IsList]);
DeclareGlobalFunction( "GeneratorsOfReesMatrixSemigroupNC");

DeclareOperation( "ReesMatrixSubsemigroup",
  [IsReesMatrixSubsemigroup, IsList, IsSemigroup, IsList]);
DeclareGlobalFunction("ReesMatrixSubsemigroupNC");

DeclareOperation( "GeneratorsOfReesZeroMatrixSemigroup",
  [IsReesZeroMatrixSubsemigroup, IsList, IsSemigroup, IsList]);
DeclareGlobalFunction( "GeneratorsOfReesZeroMatrixSemigroupNC");

DeclareOperation( "ReesZeroMatrixSubsemigroup",
  [IsReesZeroMatrixSubsemigroup, IsList, IsSemigroup, IsList]);
DeclareGlobalFunction("ReesZeroMatrixSubsemigroupNC");

DeclareAttribute("MatrixOfReesMatrixSemigroup", IsReesMatrixSubsemigroup);
DeclareAttribute("MatrixOfReesZeroMatrixSemigroup", IsReesZeroMatrixSubsemigroup);

DeclareAttribute("Rows", IsReesMatrixSubsemigroup);
DeclareAttribute("Rows", IsReesZeroMatrixSubsemigroup);
DeclareSynonymAttr("RowsOfReesMatrixSemigroup", Rows);
DeclareSynonymAttr("RowsOfReesZeroMatrixSemigroup", Rows);

DeclareAttribute("Columns", IsReesMatrixSubsemigroup);
DeclareAttribute("Columns", IsReesZeroMatrixSubsemigroup);
DeclareSynonymAttr("ColumnsOfReesMatrixSemigroup", Columns);
DeclareSynonymAttr("ColumnsOfReesZeroMatrixSemigroup", Columns);

DeclareAttribute("UnderlyingSemigroup", IsReesMatrixSubsemigroup);
DeclareAttribute("UnderlyingSemigroup", IsReesZeroMatrixSubsemigroup);
DeclareSynonym("UnderlyingSemigroupOfReesMatrixSemigroup",
  UnderlyingSemigroup);
DeclareSynonym("UnderlyingSemigroupOfReesZeroMatrixSemigroup",
  UnderlyingSemigroup);

# Other

DeclareAttribute("AssociatedReesMatrixSemigroupOfDClass", IsGreensDClass);
DeclareAttribute("IsomorphismReesMatrixSemigroup", IsSemigroup);
DeclareAttribute("IsomorphismReesMatrixSemigroup", IsGreensDClass);
DeclareAttribute("IsomorphismReesZeroMatrixSemigroup", IsSemigroup);

# undocumented

DeclareAttribute("ReesMatrixSemigroupOfFamily", IsFamily);
DeclareAttribute("TypeReesMatrixSemigroupElements",
  IsReesMatrixSubsemigroup);
DeclareAttribute("TypeReesMatrixSemigroupElements",
  IsReesZeroMatrixSubsemigroup);

DeclareOperation("ZeroOp", [IsReesMatrixSemigroupElement]);
DeclareOperation("ZeroOp", [IsReesZeroMatrixSemigroupElement]);
DeclareOperation("MultiplicativeZeroOp", [IsReesMatrixSemigroup]);

