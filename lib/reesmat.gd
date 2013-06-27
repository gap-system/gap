#############################################################################
##
#W  reesmat.gd                  GAP library                    Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for Rees Matrix semigroups


DeclareGlobalFunction( "ReesMatrixSemigroup" );
DeclareGlobalFunction( "ReesZeroMatrixSemigroup" );

DeclareAttribute("IsomorphismReesMatrixSemigroup",IsSemigroup);

DeclareCategory( "IsReesMatrixSemigroupElement", IsAssociativeElement );
DeclareCategory( "IsReesZeroMatrixSemigroupElement", IsMultiplicativeElement );

DeclareCategoryCollections( "IsReesMatrixSemigroupElement");
DeclareCategoryCollections( "IsReesZeroMatrixSemigroupElement");

DeclareGlobalFunction("RMSElementNC");
DeclareGlobalFunction( "RMSElement" );
DeclareSynonym( "ReesMatrixSemigroupElement", RMSElement);
DeclareSynonym( "ReesZeroMatrixSemigroupElement", RMSElement);

DeclareSynonymAttr( "IsSubsemigroupReesMatrixSemigroup", 
	IsSemigroup and IsReesMatrixSemigroupElementCollection);
DeclareSynonymAttr( "IsSubsemigroupReesZeroMatrixSemigroup", 
	IsSemigroup and IsReesZeroMatrixSemigroupElementCollection);
DeclareSynonymAttr( "IsReesMatrixSemigroup", 
	IsSubsemigroupReesMatrixSemigroup and IsWholeFamily);
DeclareSynonymAttr( "IsReesZeroMatrixSemigroup", 
	IsSubsemigroupReesZeroMatrixSemigroup and IsWholeFamily);

DeclareAttribute("MatrixOfRMS", IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("MatrixOfRMS", IsSubsemigroupReesZeroMatrixSemigroup);
DeclareSynonymAttr("MatrixOfReesMatrixSemigroup", MatrixOfRMS);
DeclareSynonymAttr("MatrixOfReesZeroMatrixSemigroup", MatrixOfRMS);

DeclareAttribute("RowsOfRMS", IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("RowsOfRMS", IsSubsemigroupReesZeroMatrixSemigroup);
DeclareSynonymAttr("RowsOfReesMatrixSemigroup", RowsOfRMS);
DeclareSynonymAttr("RowsOfReesZeroMatrixSemigroup", RowsOfRMS);

DeclareAttribute("ColumnsOfRMS", IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("ColumnsOfRMS", IsSubsemigroupReesZeroMatrixSemigroup);
DeclareSynonymAttr("ColumnsOfReesMatrixSemigroup", ColumnsOfRMS);
DeclareSynonymAttr("ColumnsOfReesZeroMatrixSemigroup", ColumnsOfRMS);

DeclareAttribute("UnderlyingSemigroup", IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("UnderlyingSemigroup", IsSubsemigroupReesZeroMatrixSemigroup);
DeclareSynonymAttr("UnderlyingSemigroupOfReesMatrixSemigroup",
UnderlyingSemigroup);
DeclareSynonymAttr("UnderlyingSemigroupOfReesZeroMatrixSemigroup",  UnderlyingSemigroup);

DeclareAttribute("RowOfRMSElement", IsReesMatrixSemigroupElement);
DeclareAttribute("RowOfRMSElement", IsReesZeroMatrixSemigroupElement);
DeclareSynonymAttr("RowOfReesMatrixSemigroupElement", RowOfRMSElement);
DeclareSynonymAttr("RowOfReesZeroMatrixSemigroupElement", RowOfRMSElement);

DeclareAttribute("ColumnOfRMSElement", IsReesMatrixSemigroupElement);
DeclareAttribute("ColumnOfRMSElement", IsReesZeroMatrixSemigroupElement);
DeclareSynonymAttr("ColumnOfReesMatrixSemigroupElement", ColumnOfRMSElement);
DeclareSynonymAttr("ColumnOfReesZeroMatrixSemigroupElement",
ColumnOfRMSElement);

DeclareAttribute("UnderlyingElementOfRMSElement", IsReesMatrixSemigroupElement);
DeclareAttribute("UnderlyingElementOfRMSElement",
IsReesZeroMatrixSemigroupElement);
DeclareSynonymAttr("UnderlyingElementOfReesMatrixSemigroupElement",
UnderlyingElementOfRMSElement);
DeclareSynonymAttr("UnderlyingElementOfReesZeroMatrixSemigroupElement",
UnderlyingElementOfRMSElement);

DeclareAttribute("AssociatedReesMatrixSemigroupOfDClass", IsGreensDClass);

