#############################################################################
##
#W  grptbl.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
IsMagmaByMultiplicationTable := NewCategory(
    "IsMagmaByMultiplicationTable", IsMagma );


#############################################################################
##
#C  IsMagmaByMultiplicationTableObj( <obj> )
##
IsMagmaByMultiplicationTableObj := NewRepresentation(
    "IsMagmaByMultiplicationTableObj",
    IsMultiplicativeElement,
    [] );


#############################################################################
##
#C  IsMagmaByMultiplicationTableObjFamily( <F> )
##
IsMagmaByMultiplicationTableObjFamily := CategoryFamily(
    IsMagmaByMultiplicationTableObj );


#############################################################################
##
#F  MagmaElement( <M>, <i> ) . . . . . . . . . .  <i>-th element of magma <M>
##
MagmaElement := NewOperationArgs( "MagmaElement" );


#############################################################################
##
#F  MagmaByMultiplicationTable( <A> )
##
MagmaByMultiplicationTable := NewOperationArgs(
    "MagmaByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithOneByMultiplicationTable( <A> )
##
MagmaWithOneByMultiplicationTable := NewOperationArgs(
    "MagmaWithOneByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithInversesByMultiplicationTable( <A> )
##
MagmaWithInversesByMultiplicationTable := NewOperationArgs(
    "MagmaWithInversesByMultiplicationTable" );


#############################################################################
##
#F  SemigroupByMultiplicationTable( <A> )
##
SemigroupByMultiplicationTable := NewOperationArgs(
    "SemigroupByMultiplicationTable" );


#############################################################################
##
#F  MonoidByMultiplicationTable( <A> )
##
MonoidByMultiplicationTable := NewOperationArgs(
    "MonoidByMultiplicationTable" );


#############################################################################
##
#F  GroupByMultiplicationTable( <A> )
##
GroupByMultiplicationTable := NewOperationArgs(
    "GroupByMultiplicationTable" );


#############################################################################
##
#F  MultiplicationTable( <elmlist> )
##
MultiplicationTable := NewOperationArgs( "MultiplicationTable" );


#############################################################################
##
#E  grptbl.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



