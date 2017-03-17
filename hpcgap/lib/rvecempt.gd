#############################################################################
##
#W  rvecempt.gd                 GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation of immutable empty row vectors.
##  An empty row vector is an immutable empty list whose family is
##  a collections family.
##  Empty row vectors are different if their families are different,
##  especially the ordinary empty list `[]' is different from every empty
##  row vector.
##
##  The first case where empty row vectors turned out to be necessary was
##  in the representation of elements of a zero dimensional s.c. algebra.
##


#############################################################################
##
#A  EmptyRowVector( <F> )
##
##  is an empty row vector whose family is the collections family of <F>.
##
DeclareAttribute( "EmptyRowVector", IsFamily );


#############################################################################
##
#E

