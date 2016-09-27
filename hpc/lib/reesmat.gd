#############################################################################
##
#W  reesmat.gd                  GAP library                    J. D. Mitchell
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
DeclareProperty("IsReesZeroMatrixSemigroup", IsSemigroup);

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

DeclareAttribute("Matrix", IsReesMatrixSubsemigroup);
DeclareAttribute("Matrix", IsReesZeroMatrixSubsemigroup);
DeclareSynonymAttr("MatrixOfReesMatrixSemigroup", Matrix);
DeclareSynonymAttr("MatrixOfReesZeroMatrixSemigroup", Matrix);

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

