#############################################################################
##
#W  grptbl.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation of magmas, monoids, and groups via
##  the multiplication table.
##
##  Given a square matrix $A$ with $n$ rows such that all entries are in the
##  range '[ 1 .. n ]' then $A$ defines a multiplication of the set
##  $\{ m_1, m_2, \ldots, m_n \}$ as $m_i \* m_j = m_{A[i][j]}$.
##
##  The <i>-th element of such a magma <M> can be constructed via
##  'MagmaElement( <M>, <i> )'.
##
Revision.grptbl_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsMagmaByMultiplicationTable( <M> )
##
DeclareCategory( "IsMagmaByMultiplicationTable", IsMagma );


#############################################################################
##
#C  IsMagmaByMultiplicationTableObj( <obj> )
##
DeclareRepresentation( "IsMagmaByMultiplicationTableObj",
    IsMultiplicativeElement,
    [] );


#############################################################################
##
#C  IsMagmaByMultiplicationTableObjFamily( <F> )
##
DeclareCategoryFamily( "IsMagmaByMultiplicationTableObj" );


#############################################################################
##
#F  MagmaElement( <M>, <i> ) . . . . . . . . . .  <i>-th element of magma <M>
##
DeclareGlobalFunction( "MagmaElement" );


#############################################################################
##
#F  MagmaByMultiplicationTable( <A> )
##
DeclareGlobalFunction( "MagmaByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithOneByMultiplicationTable( <A> )
##
DeclareGlobalFunction( "MagmaWithOneByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithInversesByMultiplicationTable( <A> )
##
DeclareGlobalFunction( "MagmaWithInversesByMultiplicationTable" );


#############################################################################
##
#F  SemigroupByMultiplicationTable( <A> )
##
DeclareGlobalFunction( "SemigroupByMultiplicationTable" );


#############################################################################
##
#F  MonoidByMultiplicationTable( <A> )
##
DeclareGlobalFunction( "MonoidByMultiplicationTable" );


#############################################################################
##
#F  GroupByMultiplicationTable( <A> )
##
DeclareGlobalFunction( "GroupByMultiplicationTable" );


#############################################################################
##
#F  MultiplicationTable( <elmlist> )
##
DeclareGlobalFunction( "MultiplicationTable" );


#############################################################################
##
#E  grptbl.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

