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
Revision.grptbl_gd :=
    "@(#)$Id$";


#############################################################################
##
#R  IsMagmaByMultiplicationTableObj( <obj> )
##
##  At position 1 of the element $m_i$, the number $i$ is stored.
##
DeclareRepresentation( "IsMagmaByMultiplicationTableObj",
    IsPositionalObjectRep and IsMultiplicativeElementWithInverse,
    [ 1 ] );


#############################################################################
##
#F  MagmaByMultiplicationTable( <A> )
##
##  For a square matrix <A> with $n$ rows such that all entries of <A> are
##  in the range $[ 1 \.\. n ]$, `MagmaByMultiplicationTable' returns a magma
##  $M$ with multiplication `\*' defined by $A$.
##  That is, $M$ consists of the elements $m_1, m_2, \ldots, m_n$,
##  and $m_i \* m_j = m_{A[i][j]}$.
##
##  The ordering of elements is defined by $m_1 \< m_2 \< \cdots \< m_n$,
##  so $m_i$ can be accessed as `MagmaElement( <M>, <i> )',
##  see~"MagmaElement".
##
DeclareGlobalFunction( "MagmaByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithOneByMultiplicationTable( <A> )
##
##  The only differences between `MagmaByMultiplicationTable' and
##  `MagmaWithOneByMultiplicationTable' are that the latter returns a
##  magma-with-one (see~"MagmaWithOne") if the magma described by the matrix
##  <A> has an identity,
##  and returns `fail' if not.
##
DeclareGlobalFunction( "MagmaWithOneByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithInversesByMultiplicationTable( <A> )
##
##  The only differences between `MagmaByMultiplicationTable' and
##  `MagmaWithInversesByMultiplicationTable' are that the latter returns a
##  magma-with-inverses (see~"MagmaWithInverses") if each element in the
##  magma described by the matrix <A> has an inverse,
##  and returns `fail' if not.
##
DeclareGlobalFunction( "MagmaWithInversesByMultiplicationTable" );


#############################################################################
##
#F  MagmaElement( <M>, <i> ) . . . . . . . . . .  <i>-th element of magma <M>
##
##  For a magma <M> and a positive integer <i>, `MagmaElement' returns the
##  <i>-th element of <M>, w.r.t.~the ordering `\<'.
##  If <M> has less than <i> elements then `fail' is returned.
##
DeclareGlobalFunction( "MagmaElement" );


#############################################################################
##
#F  SemigroupByMultiplicationTable( <A> )
##
##  returns the semigroup whose multiplication is defined by the square
##  matrix <A> (see~"MagmaByMultiplicationTable") if such a semigroup exists.
##  Otherwise `fail' is returned.
##
DeclareGlobalFunction( "SemigroupByMultiplicationTable" );


#############################################################################
##
#F  MonoidByMultiplicationTable( <A> )
##
##  returns the monoid whose multiplication is defined by the square
##  matrix <A> (see~"MagmaByMultiplicationTable") if such a monoid exists.
##  Otherwise `fail' is returned.
##
DeclareGlobalFunction( "MonoidByMultiplicationTable" );


#############################################################################
##
#F  GroupByMultiplicationTable( <A> )
##
##  returns the group whose multiplication is defined by the square
##  matrix <A> (see~"MagmaByMultiplicationTable") if such a group exists.
##  Otherwise `fail' is returned.
##
DeclareGlobalFunction( "GroupByMultiplicationTable" );


#############################################################################
##
#F  MultiplicationTable( <elms> )
##
##  For a list <elms> of elements that form a magma $M$,
##  `MultiplicationTable' returns a square matrix $A$ of positive integers
##  such that $A[i][j] = k$ holds if and only if
##  `<elms>[i] \* <elms>[j] = <elms>[k]'.
##  This matrix can be used to construct a magma isomorphic to $M$,
##  using `MagmaByMultiplicationTable'.
##
DeclareGlobalFunction( "MultiplicationTable" );


#############################################################################
##
#E

