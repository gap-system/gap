#############################################################################
##
#W  reesmat.gd           GAP library                    Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for Rees Matrix semigroups

Revision.reesmat_gd :=
    "@(#)$Id$";

#1
##  In this section we describe {\GAP} funtions for Rees matrix semigroups
##  and Rees 0-matrix semigroups.
##  The importance of this construction is that 
##   Rees Matrix semigroups over groups 
##  are exactly the completely simple semigroups, and Rees 0-matrix
##  semigroups over groups are the completely 0-simple semigroups 
##  
##  Recall that a Rees Matrix semigroup is constructed from a semigroup (the
##  underlying semigroup), and a matrix.
##  A Rees Matrix semigroup element is a triple (<s>, <i>, <lambda>)
##  where <s> is an element of the underlying semigroup <S> and
##  <i>, <lambda> are indices.
##  This can be thought of as a matrix with zero everywhere
##  except for an occurrence of <s> at row <i> and column <lambda>.
##  The multiplication is defined by 
##  $(s, i, \lambda)*(t, j , \mu) =   (sP_{\lambda j}t, i, \mu)$ where
##  $P$ is the defining matrix of the semigroup.
##  In the case that the underlying semigroup has a zero we can make the
##  ReesZeroMatrixSemigroup, wherein all elements whose <s> entry is the
##  zero of the underlying semigroup are identified to the unique zero of
##  the Rees 0-matrix semigroup.
##

#############################################################################
##
#F  ReesMatrixSemigroup( <S>, <matrix> )
##
##	for a semigroup <S> and <matrix> whose entries are in <S>.
##  Returns the Rees Matrix semigroup with multiplication defined by
##  <matrix>. 
##
DeclareGlobalFunction( "ReesMatrixSemigroup" );

#############################################################################
##
#F  ReesZeroMatrixSemigroup( <S>, <matrix>  )
##
##  for a semigroup <S> with zero, and  <matrix> over  <S> 
##  returns the Rees 0-Matrix semigroup such that all elements
##  $(i, 0, \lambda)$ are identified to zero.
##
##  The zero in <S> is found automatically.   If
##  one cannot be found, an error is signalled.   
##
DeclareGlobalFunction( "ReesZeroMatrixSemigroup" );

#############################################################################
##
#A  IsomorphismReesMatrixSemigroup 
##  If <S> is a completely simple (resp. zero simple) semigroup, returns 
##  an isomorphism  to a Rees matrix semigroup over a group (resp. zero group)
##
DeclareAttribute("IsomorphismReesMatrixSemigroup",IsSemigroup);

#############################################################################
##
#C  IsReesMatrixSemigroupElement(<e>)
#C  IsReesZeroMatrixSemigroupElement(<e>)
##
##	is the category of elements of a Rees (0-) matrix  semigroup.
##	Returns true if <e> is an element of a Rees Matrix semigroup.
##
DeclareCategory( "IsReesMatrixSemigroupElement", IsAssociativeElement );
DeclareCategory( "IsReesZeroMatrixSemigroupElement", IsMultiplicativeElement );

#############################################################################
##
#C  IsReesMatrixSemigroupElementCollection
#C  IsReesZeroMatrixSemigroupElementCollection
##
##	Created now so that lists of things in the category 
##  IsSubsemigroupReesMatrixSemigroup	are given the category 
##	CategoryCollections(IsSubsemigroupReesMatrixSemigroup)
##  Otherwise these lists (and other collections) won't create the
##  collections category. See CollectionsCategory in the manual.
##	
DeclareCategoryCollections( "IsReesMatrixSemigroupElement");
DeclareCategoryCollections( "IsReesZeroMatrixSemigroupElement");

#############################################################################
##
#F  ReesMatrixSemigroupElement( <R>, <a>, <i>, <lambda> )
#F  ReesZeroMatrixSemigroupElement( <R>, <a>, <i>, <lambda> )
##
##	for a Rees matrix semigroup <R>, <a> in `UnderlyingSemigroup(<R>)', 
##	<i> and <lambda> in the row (resp. column) ranges of <R>,
##  returns the element of <R> corresponding to the
##  matrix with zero everywhere and <a> in row <i> and column <x>.
##
DeclareGlobalFunction( "ReesMatrixSemigroupElement" );
DeclareGlobalFunction( "ReesZeroMatrixSemigroupElement" );

#############################################################################
##
#C  IsSubsemigroupReesMatrixSemigroup( <T> )
#C  IsSubsemigroupReesZeroMatrixSemigroup( <T> )
##
##	is the category of rees matrix semigroups.
##	Returns true if <T> is a [subsemigroup of a] Rees (0-)matrix semigroup.
##
DeclareSynonymAttr( "IsSubsemigroupReesMatrixSemigroup", 
	IsSemigroup and IsReesMatrixSemigroupElementCollection);

DeclareSynonymAttr( "IsSubsemigroupReesZeroMatrixSemigroup", 
	IsSemigroup and IsReesZeroMatrixSemigroupElementCollection);

#############################################################################
##
#P  IsReesMatrixSemigroup( <T> )
##
##  returns true whenever we have a (whole) rees matrix semigroup.
##
DeclareSynonymAttr( "IsReesMatrixSemigroup", 
	IsSubsemigroupReesMatrixSemigroup and IsWholeFamily);

#############################################################################
##
#A  SandwichMatrixOfReesMatrixSemigroup( <R> )
#A  SandwichMatrixOfReesZeroMatrixSemigroup( <R> )
##
##  the defining matrix of the Rees (0-) matrix semigroup.
##
DeclareAttribute("SandwichMatrixOfReesMatrixSemigroup", IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("SandwichMatrixOfReesZeroMatrixSemigroup", IsSubsemigroupReesZeroMatrixSemigroup);


#############################################################################
##
#A  RowsOfReesMatrixSemigroup( <R> )
#A  RowsOfReesZeroMatrixSemigroup( <R> )
## 
##  the number of rows in the defining matrix of <R>
##
DeclareAttribute("RowsOfReesMatrixSemigroup",IsSubsemigroupReesMatrixSemigroup );
DeclareAttribute("RowsOfReesZeroMatrixSemigroup",IsSubsemigroupReesZeroMatrixSemigroup );

#############################################################################
##
#A  ColumnsOfReesMatrixSemigroup( <R> )
#A  ColumnsOfReesZeroMatrixSemigroup( <R> )
##
##  number of columns in the defining matrix of <R>.
##
DeclareAttribute("ColumnsOfReesMatrixSemigroup",IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("ColumnsOfReesZeroMatrixSemigroup",IsSubsemigroupReesZeroMatrixSemigroup);

#############################################################################
##
#A  UnderlyingSemigroupOfReesMatrixSemigroup( <R> )
#A  UnderlyingSemigroupOfReesZeroMatrixSemigroup( <R> )
##
##	underlying semigroup containing the entries in the defining matrix of <R>.
##
DeclareAttribute("UnderlyingSemigroupOfReesMatrixSemigroup",
	IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("UnderlyingSemigroupOfReesZeroMatrixSemigroup",
	IsSubsemigroupReesZeroMatrixSemigroup);

#############################################################################
##
#A  RowIndexOfReesMatrixSemigroupElement( <x> )
#A  RowIndexOfReesZeroMatrixSemigroupElement( <x> )
#A  ColumnIndexOfReesMatrixSemigroupElement( <x> )
#A  ColumnIndexOfReesZeroMatrixSemigroupElement( <x> )
#A  UnderlyingElementOfReesMatrixSemigroupElement( <x> )
#A  UnderlyingElementOfReesZeroMatrixSemigroupElement( <x> )
##
##  for an element <x> of a Rees Matrix semigroup, of the form
##	(<s>,<i>,<lambda>),
##	the row index is <i>, the column index is <lambda> and the 
##  underlying element is <s>.
##	If we think of an element as a matrix then this corresponds to
##	the row where the non-zero entry is, the column where the
##	non-zero entry is and the entry at that position, respectively. 
##
DeclareAttribute("RowIndexOfReesMatrixSemigroupElement",
  IsReesMatrixSemigroupElement);
DeclareAttribute("RowIndexOfReesZeroMatrixSemigroupElement",
  IsReesZeroMatrixSemigroupElement);
DeclareAttribute("ColumnIndexOfReesMatrixSemigroupElement",
  IsReesMatrixSemigroupElement);
DeclareAttribute("ColumnIndexOfReesZeroMatrixSemigroupElement",
  IsReesZeroMatrixSemigroupElement);
DeclareAttribute("UnderlyingElementOfReesMatrixSemigroupElement",
  IsReesMatrixSemigroupElement);
DeclareAttribute("UnderlyingElementOfReesZeroMatrixSemigroupElement",
  IsReesZeroMatrixSemigroupElement);

#############################################################################
##
#P  IsReesZeroMatrixSemigroup( <T> )
##
##  returns true whenever we have a (whole) rees 0-matrix semigroup.
##
DeclareSynonymAttr( "IsReesZeroMatrixSemigroup", 
	IsSubsemigroupReesZeroMatrixSemigroup and IsWholeFamily);

############################################################################
##
#P  ReesZeroMatrixSemigroupElementIsZero( <x> )
##
##	returns true if <x> is the zero of the Rees 0-matrix semigroup.
##
DeclareProperty("ReesZeroMatrixSemigroupElementIsZero", 
	IsReesZeroMatrixSemigroupElement);

############################################################################
##
#A  AssociatedReesMatrixSemigroupOfDClass( <D> )
##
##  Given a regular D class of a finite semigroup, it can be viewed as a
##  rees matrix semigroup by identifying products which do not lie in the
##  D class with zero.
##
##  Formally, let $I_1$ be the ideal of all J classes less than or equal to
##  <D>, $I_2$ the ideal of all J classes *strictly* less than <D>,
##  and $\rho$ the rees congurence associated with $I_2$.   Then $I/\rho$
##  is zero-simple.   Then `AssociatedReesMatrixSemigroupOfDClass( <D> )'
##  returns this zero-simple semigroup as a Rees matrix semigroup.
##
DeclareAttribute("AssociatedReesMatrixSemigroupOfDClass", IsGreensDClass);

#############################################################################
##
#E


