#############################################################################
##
#W  ctblauto.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of functions to calculate
##  automorphisms of matrices,
#T other file (matrix.gd?) ?
##  e.g., the character matrices of character tables, and functions to
##  calculate permutations transforming the rows of a matrix to the rows of
##  another matrix.
##
Revision.ctblauto_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  FamiliesOfRows( <mat>, <maps> )
##
##  distributes the rows of the matrix <mat> to families as follows.
##  Two rows of <mat> belong to the same family if there is a permutation
##  of columns that maps one row to the other row.
##  Each entry in the list <maps> is regarded to form a family of length 1.
##
##  `FamiliesOfRows( <mat>, <maps> )' returns a record with components
##
##  `famreps'
##       list of representatives for each family,
##
##  `permutations'
##       list that contains at position `i' a list of permutations that
##       map the members of the family with representative `famreps[i]'
##       to that representative,
##
##  `families'
##       list that contains at position <i> the list of positions
##       of members of the family of representative `famreps[<i>]';
##       (for the element `<maps>[i]' the only member of the family
##       will get the number `Length( <mat> ) + i'.
##
DeclareGlobalFunction( "FamiliesOfRows" );


#############################################################################
##
#F  MatAutomorphisms( <mat>, <maps>, <subgroup> )
##
##  `MatAutomorphisms' returns the permutation group representing the matrix
##  automorphisms of the matrix <mat> that respect all lists in the list
##  <maps>.
##
##  <subgroup> is a permutation group that is known to be a subgroup of
##  this group.
##
DeclareGlobalFunction( "MatAutomorphisms" );


#############################################################################
##
#F  TableAutomorphisms( <tbl>, <characters> )
#F  TableAutomorphisms( <tbl>, <characters>, \"closed\" )
##
##  returns a permutation group for the group of those matrix automorphisms
##  (see "MatAutomorphisms") of the list <characters> which are
##  compatible with (i.e. which fix) the element orders and all computed
##  and unique (i.e.~not parametrized) power maps of the character table
##  <tbl>.
##
##  If <characters> is closed under Galois conjugacy --this is always
##  fulfilled for ordinary character tables-- the string `"closed"'
##  may be entered as third argument.
##
DeclareGlobalFunction( "TableAutomorphisms" );


#############################################################################
##
#F  TransformingPermutations( <mat1>, <mat2> )
##
##  constructs a permutation $\pi$ that transforms the set of rows of the
##  matrix <mat1> to the set of rows of the matrix <mat2> by permutation
##  of columns.
##  If such a permutation exists, a record with components `columns', `rows'
##  and `group' is returned, otherwise `false'.
##  If $`TransformingPermutations( <mat1>, <mat2> ) = <r>' \not= `false'$
##  then we have `<mat2> =
##   Permuted( List( <mat1>, x->Permuted( x, <r>.columns ) ),<r>.rows )'.
##
##  `<r>.group' is the group of matrix automorphisms of <mat2>;
##  this group stabilizes the transformation in the sense that applying any
##  of its elements to the columns of <mat2> preserve the set of rows of
##  <mat2>.
##
DeclareGlobalFunction( "TransformingPermutations" );


#############################################################################
##
#F  TransformingPermutationsCharacterTables( <tbl1>, <tbl2> )
##
##  constructs a permutation $\pi$ that transforms the set of rows of the
##  matrix `Irr( <tbl1> )' to the set of rows of the matrix
##  `Irr( <tbl2> )' by permutation of columns.
##
DeclareGlobalFunction(
    "TransformingPermutationsCharacterTables" );


#############################################################################
##
#E  ctblauto.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



