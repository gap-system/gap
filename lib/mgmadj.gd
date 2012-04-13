#############################################################################
##
#W  mgmadj.gd                    GAP library                  Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations for magmas with zero adjoined.
##

#############################################################################
##
#C  IsMultiplicativeElementWithZero( <elt>)
##
##  <#GAPDoc Label="IsMultiplicativeElementWithZero">
##  <ManSection>
##  <Filt Name="IsMultiplicativeElementWithZero" Arg='elt' Type='Category'/>
##
##  <Description>
##  Elements in a family which can be the operands of the 
##  <C>*</C> and the operation MultiplicativeZero.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsMultiplicativeElementWithZero",IsMultiplicativeElement);
DeclareCategoryCollections("IsMultiplicativeElementWithZero");


#############################################################################
##
#O  MultiplicativeZeroOp( <elt> ) 
##
##  <#GAPDoc Label="MultiplicativeZeroOp">
##  <ManSection>
##  <Oper Name="MultiplicativeZeroOp" Arg='elt'/>
##
##  <Description>
##  for an element <A>elt</A> in the category 
##  <Ref Func="IsMultiplicativeElementWithZero"/>,
##  returns the element <M>z</M> in the family <M>F</M> of <A>elt</A>
##  with the property that <M>z * m = z = m * z</M> holds for all
##  <M>m \in F</M>, if such an element is known.
##  <P/>
##  Families of elements in the category
##  <Ref Func="IsMultiplicativeElementWithZero"/>
##  often arise from adjoining a new zero to an existing magma. 
##  See&nbsp;<Ref Func="InjectionZeroMagma"/> for details.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MultiplicativeZeroOp", [IsMultiplicativeElementWithZero] );


#############################################################################
##
#A  MultiplicativeZero( <M> ) 
##
##  <#GAPDoc Label="MultiplicativeZero">
##  <ManSection>
##  <Attr Name="MultiplicativeZero" Arg='M'/>
##
##  <Description>
##  Returns the multiplicative zero of the magma which is the element
##  <A>z</A> such that for all <A>m</A> in <A>M</A>, <C><A>z</A> * <A>m</A> = <A>m</A> * <A>z</A> = <A>z</A></C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MultiplicativeZero", IsMultiplicativeElementWithZero );


#############################################################################
##
#O  IsMultiplicativeZero( <M>, <z> ) 
##
##  <#GAPDoc Label="IsMultiplicativeZero">
##  <ManSection>
##  <Oper Name="IsMultiplicativeZero" Arg='M, z'/>
##
##  <Description>
##  returns true iff <C><A>z</A> * <A>m</A> = <A>m</A> * <A>z</A> = <A>z</A></C> for all <A>m</A> in <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsMultiplicativeZero", [ IsMagma, IsMultiplicativeElement ] );


#############################################################################
##
#A  InjectionZeroMagma( <M> )
##
##  <#GAPDoc Label="InjectionZeroMagma">
##  <ManSection>
##  <Attr Name="InjectionZeroMagma" Arg='M'/>
##
##  <Description>
##  The canonical homomorphism <A>i</A> from the  magma
##  <A>M</A> into the magma formed from <A>M</A> with a single new element 
##  which is a multiplicative zero for the resulting magma.
##  <P/>
##  The elements of the new magma form a family of elements in the 
##  category IsMultiplicativeElementWithZero, and the
##  new magma is obtained as Range(<A>i</A>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InjectionZeroMagma", IsMagma );


#############################################################################
##
#E

