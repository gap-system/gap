#############################################################################
##
#W  mgmadj.gd                    GAP library                  Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations for magmas with zero adjoined.
##
Revision.mgmadj_gd:=
    "@(#)$Id$";

#############################################################################
##
#C  IsMultiplicativeElementWithZero( <elt>)
##
##  Elements in a family which can be the operands of the 
##  `\*' and the operation MultiplicativeZero.
##
DeclareCategory("IsMultiplicativeElementWithZero",IsMultiplicativeElement);
DeclareCategoryCollections("IsMultiplicativeElementWithZero");


#############################################################################
##
#O  MultiplicativeZeroOp( <elt> ) 
##
##  returns the element $z$ in the family <F> of <elt> with the 
##  property that $z * m = z = m * z$ holds for all $m \in F$,
##  if such an element is known.
##
##  Families of elements in the category IsMultiplicativeElementWithZero
##  often arise from adjoining a new zero to an existing magma. 
##  See~"InjectionZeroMagma" for details.
##  
##
DeclareOperation( "MultiplicativeZeroOp", [IsMultiplicativeElementWithZero] );


#############################################################################
##
#A  MultiplicativeZero( <M> ) 
##
##  Returns the multiplicative zero of the magma which is the element
##  <z> such that for all <m> in <M>, `<z> \* <m> = <m> \* <z> = <z>'.
##
##
DeclareAttribute( "MultiplicativeZero", IsMultiplicativeElementWithZero );


#############################################################################
##
#O  IsMultiplicativeZero( <M>, <z> ) 
##
##  returns true iff `<z> \* <m> = <m> \* <z> = <z>' for all <m> in <M>.
##
DeclareOperation( "IsMultiplicativeZero", [ IsMagma, IsMultiplicativeElement ] );


#############################################################################
##
#A  InjectionZeroMagma( <M> )
##
##  The canonical homomorphism <i> from the  magma
##  <M> into the magma formed from <M> with a single new element 
##  which is a multiplicative zero for the resulting magma.
##
##  The elements of the new magma form a family of elements in the 
##  category IsMultiplicativeElementWithZero, and the
##  new magma is obtained as Range(<i>).
##
DeclareAttribute( "InjectionZeroMagma", IsMagma );


#############################################################################
##
#E

