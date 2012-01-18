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



##  <#GAPDoc Label="[1]{reesmat}">
##  In this section we describe &GAP; functions for Rees matrix semigroups
##  and Rees 0-matrix semigroups.
##  The importance of this construction is that 
##  Rees Matrix semigroups over groups 
##  are exactly the completely simple semigroups, and Rees 0-matrix
##  semigroups over groups are the completely 0-simple semigroups 
##  <P/>
##  Recall that a Rees Matrix semigroup is constructed from a semigroup (the
##  underlying semigroup), and a matrix.
##  A Rees Matrix semigroup element is a triple
##  <M>(s, i, \lambda)</M>
##  where <M>s</M> is an element of the underlying semigroup <M>S</M> and
##  <M>i</M>, <M>\lambda</M> are indices.
##  This can be thought of as a matrix with zero everywhere
##  except for an occurrence of <M>s</M> at row <M>i</M> and column
##  <M>\lambda</M>.
##  The multiplication is defined by 
##  <M>(i, s, \lambda)*(j, t, \mu) = (i, s P_{{\lambda j}} t, \mu)</M> where
##  <M>P</M> is the defining matrix of the semigroup.
##  In the case that the underlying semigroup has a zero we can create the
##  <Ref Func="ReesZeroMatrixSemigroup"/> value,
##  wherein all elements whose <M>s</M> entry is the
##  zero of the underlying semigroup are identified to the unique zero of
##  the Rees 0-matrix semigroup.
##  <#/GAPDoc>
##

#############################################################################
##
#F  ReesMatrixSemigroup( <S>, <matrix> )
##
##  <#GAPDoc Label="ReesMatrixSemigroup">
##  <ManSection>
##  <Func Name="ReesMatrixSemigroup" Arg='S, matrix'/>
##
##  <Description>
##  for a semigroup <A>S</A> and <A>matrix</A> whose entries are in <A>S</A>.
##  Returns the Rees Matrix semigroup with multiplication defined by
##  <A>matrix</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReesMatrixSemigroup" );

#############################################################################
##
#F  ReesZeroMatrixSemigroup( <S>, <matrix>  )
##
##  <#GAPDoc Label="ReesZeroMatrixSemigroup">
##  <ManSection>
##  <Func Name="ReesZeroMatrixSemigroup" Arg='S, matrix'/>
##
##  <Description>
##  for a semigroup <A>S</A> with zero, and  <A>matrix</A> over  <A>S</A> 
##  returns the Rees 0-Matrix semigroup such that all elements
##  <M>(i, 0, \lambda)</M> are identified to zero.
##  <P/>
##  The zero in <A>S</A> is found automatically.   If
##  one cannot be found, an error is signalled.   
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReesZeroMatrixSemigroup" );

#############################################################################
##
#A  IsomorphismReesMatrixSemigroup( <obj> )
##
##  <#GAPDoc Label="IsomorphismReesMatrixSemigroup">
##  <ManSection>
##  <Attr Name="IsomorphismReesMatrixSemigroup" Arg='obj'/>
##
##  <Description>
##  If <A>S</A> is a completely simple (resp. zero simple) semigroup, returns 
##  an isomorphism  to a Rees matrix semigroup over a group (resp. zero
##  group).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("IsomorphismReesMatrixSemigroup",IsSemigroup);

#############################################################################
##
#C  IsReesMatrixSemigroupElement(<e>)
#C  IsReesZeroMatrixSemigroupElement(<e>)
##
##  <#GAPDoc Label="IsReesMatrixSemigroupElement">
##  <ManSection>
##  <Filt Name="IsReesMatrixSemigroupElement" Arg='e' Type='Category'/>
##  <Filt Name="IsReesZeroMatrixSemigroupElement" Arg='e' Type='Category'/>
##
##  <Description>
##  is the category of elements of a Rees (0-) matrix  semigroup.
##  Returns true if <A>e</A> is an element of a Rees Matrix semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsReesMatrixSemigroupElement", IsAssociativeElement );
DeclareCategory( "IsReesZeroMatrixSemigroupElement", IsMultiplicativeElement );

#############################################################################
##
#C  IsReesMatrixSemigroupElementCollection
#C  IsReesZeroMatrixSemigroupElementCollection
##
##  <ManSection>
##  <Filt Name="IsReesMatrixSemigroupElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsReesZeroMatrixSemigroupElementCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  Created now so that lists of things in the category 
##  IsSubsemigroupReesMatrixSemigroup	are given the category 
##  CategoryCollections(IsSubsemigroupReesMatrixSemigroup).
##  Otherwise these lists (and other collections) won't create the
##  collections category. See CollectionsCategory in the manual.
##  </Description>
##  </ManSection>
##
DeclareCategoryCollections( "IsReesMatrixSemigroupElement");
DeclareCategoryCollections( "IsReesZeroMatrixSemigroupElement");

#############################################################################
##
#F  ReesMatrixSemigroupElement( <R>, <i>, <a>, <lambda> )
#F  ReesZeroMatrixSemigroupElement( <R>, <i>, <a>, <lambda> )
##
##  <#GAPDoc Label="ReesMatrixSemigroupElement">
##  <ManSection>
##  <Func Name="ReesMatrixSemigroupElement" Arg='R, i, a, lambda'/>
##  <Func Name="ReesZeroMatrixSemigroupElement" Arg='R, i, a, lambda'/>
##
##  <Description>
##  for a Rees matrix semigroup <A>R</A>, <A>a</A> in <C>UnderlyingSemigroup(<A>R</A>)</C>, 
##  <A>i</A> and <A>lambda</A> in the row (resp. column) ranges of <A>R</A>,
##  returns the element of <A>R</A> corresponding to the
##  matrix with zero everywhere and <A>a</A> in row <A>i</A> and column <A>x</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReesMatrixSemigroupElement" );
DeclareGlobalFunction( "ReesZeroMatrixSemigroupElement" );

#############################################################################
##
#C  IsSubsemigroupReesMatrixSemigroup( <T> )
#C  IsSubsemigroupReesZeroMatrixSemigroup( <T> )
##
##  <ManSection>
##  <Filt Name="IsSubsemigroupReesMatrixSemigroup" Arg='T' Type='Category'/>
##  <Filt Name="IsSubsemigroupReesZeroMatrixSemigroup" Arg='T' Type='Category'/>
##
##  <Description>
##  is the category of Rees matrix semigroups.
##  The functions return <K>true</K> if <A>T</A> is a (subsemigroup of a) 
##  Rees (0-)matrix semigroup.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsSubsemigroupReesMatrixSemigroup", 
	IsSemigroup and IsReesMatrixSemigroupElementCollection);

DeclareSynonymAttr( "IsSubsemigroupReesZeroMatrixSemigroup", 
	IsSemigroup and IsReesZeroMatrixSemigroupElementCollection);

#############################################################################
##
#P  IsReesMatrixSemigroup( <T> )
##
##  <#GAPDoc Label="IsReesMatrixSemigroup">
##  <ManSection>
##  <Prop Name="IsReesMatrixSemigroup" Arg='T'/>
##
##  <Description>
##  returns <K>true</K> if the object <A>T</A> is a (whole) Rees matrix semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsReesMatrixSemigroup", 
	IsSubsemigroupReesMatrixSemigroup and IsWholeFamily);

#############################################################################
##
#A  SandwichMatrixOfReesMatrixSemigroup( <R> )
#A  SandwichMatrixOfReesZeroMatrixSemigroup( <R> )
##
##  <#GAPDoc Label="SandwichMatrixOfReesMatrixSemigroup">
##  <ManSection>
##  <Attr Name="SandwichMatrixOfReesMatrixSemigroup" Arg='R'/>
##  <Attr Name="SandwichMatrixOfReesZeroMatrixSemigroup" Arg='R'/>
##
##  <Description>
##  each return the defining matrix of the Rees (0-) matrix semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("SandwichMatrixOfReesMatrixSemigroup", IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("SandwichMatrixOfReesZeroMatrixSemigroup", IsSubsemigroupReesZeroMatrixSemigroup);


#############################################################################
##
#A  RowsOfReesMatrixSemigroup( <R> )
#A  RowsOfReesZeroMatrixSemigroup( <R> )
##
##  <ManSection>
##  <Attr Name="RowsOfReesMatrixSemigroup" Arg='R'/>
##  <Attr Name="RowsOfReesZeroMatrixSemigroup" Arg='R'/>
##
##  <Description>
##  return the number of rows in the defining matrix of <A>R</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("RowsOfReesMatrixSemigroup",IsSubsemigroupReesMatrixSemigroup );
DeclareAttribute("RowsOfReesZeroMatrixSemigroup",IsSubsemigroupReesZeroMatrixSemigroup );

#############################################################################
##
#A  ColumnsOfReesMatrixSemigroup( <R> )
#A  ColumnsOfReesZeroMatrixSemigroup( <R> )
##
##  <ManSection>
##  <Attr Name="ColumnsOfReesMatrixSemigroup" Arg='R'/>
##  <Attr Name="ColumnsOfReesZeroMatrixSemigroup" Arg='R'/>
##
##  <Description>
##  return the number of columns in the defining matrix of <A>R</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("ColumnsOfReesMatrixSemigroup",IsSubsemigroupReesMatrixSemigroup);
DeclareAttribute("ColumnsOfReesZeroMatrixSemigroup",IsSubsemigroupReesZeroMatrixSemigroup);

#############################################################################
##
#A  UnderlyingSemigroupOfReesMatrixSemigroup( <R> )
#A  UnderlyingSemigroupOfReesZeroMatrixSemigroup( <R> )
##
##  <ManSection>
##  <Attr Name="UnderlyingSemigroupOfReesMatrixSemigroup" Arg='R'/>
##  <Attr Name="UnderlyingSemigroupOfReesZeroMatrixSemigroup" Arg='R'/>
##
##  <Description>
##  return the underlying semigroup containing the entries in the defining
##  matrix of <A>R</A>.
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="RowIndexOfReesMatrixSemigroupElement">
##  <ManSection>
##  <Attr Name="RowIndexOfReesMatrixSemigroupElement" Arg='x'/>
##  <Attr Name="RowIndexOfReesZeroMatrixSemigroupElement" Arg='x'/>
##  <Attr Name="ColumnIndexOfReesMatrixSemigroupElement" Arg='x'/>
##  <Attr Name="ColumnIndexOfReesZeroMatrixSemigroupElement" Arg='x'/>
##  <Attr Name="UnderlyingElementOfReesMatrixSemigroupElement" Arg='x'/>
##  <Attr Name="UnderlyingElementOfReesZeroMatrixSemigroupElement" Arg='x'/>
##
##  <Description>
##  For an element <A>x</A> of a Rees Matrix semigroup, of the form
##  <M>(i, s, \lambda)</M>,
##  the row index is <M>i</M>, the column index is <M>\lambda</M> and the 
##  underlying element is <M>s</M>.
##  If we think of an element as a matrix then this corresponds to
##  the row where the non-zero entry is, the column where the
##  non-zero entry is and the entry at that position, respectively. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsReesZeroMatrixSemigroup">
##  <ManSection>
##  <Prop Name="IsReesZeroMatrixSemigroup" Arg='T'/>
##
##  <Description>
##  returns <K>true</K> if the object <A>T</A> is a (whole) Rees 0-matrix
##  semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsReesZeroMatrixSemigroup", 
	IsSubsemigroupReesZeroMatrixSemigroup and IsWholeFamily);

############################################################################
##
#P  ReesZeroMatrixSemigroupElementIsZero( <x> )
##
##  <#GAPDoc Label="ReesZeroMatrixSemigroupElementIsZero">
##  <ManSection>
##  <Prop Name="ReesZeroMatrixSemigroupElementIsZero" Arg='x'/>
##
##  <Description>
##  returns <K>true</K> if <A>x</A> is the zero of the Rees 0-matrix semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("ReesZeroMatrixSemigroupElementIsZero", 
	IsReesZeroMatrixSemigroupElement);

############################################################################
##
#A  AssociatedReesMatrixSemigroupOfDClass( <D> )
##
##  <#GAPDoc Label="AssociatedReesMatrixSemigroupOfDClass">
##  <ManSection>
##  <Attr Name="AssociatedReesMatrixSemigroupOfDClass" Arg='D'/>
##
##  <Description>
##  Given a regular <A>D</A> class of a finite semigroup, it can be viewed as a
##  Rees matrix semigroup by identifying products which do not lie in the
##  <A>D</A> class with zero, and this is what it is returned.
##  <P/>
##  Formally, let <M>I_1</M> be the ideal of all J classes less than or equal to
##  <A>D</A>, <M>I_2</M> the ideal of all J classes <E>strictly</E> less than <A>D</A>,
##  and <M>\rho</M> the Rees congruence associated with <M>I_2</M>.  Then <M>I/\rho</M>
##  is zero-simple.  Then <C>AssociatedReesMatrixSemigroupOfDClass( <A>D</A> )</C>
##  returns this zero-simple semigroup as a Rees matrix semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("AssociatedReesMatrixSemigroupOfDClass", IsGreensDClass);


#############################################################################
##
#E

