#############################################################################
##
#W  ctblauto.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of operations to calculate
##  automorphisms of matrices,
#T better in `matrix.gd'?
##  e.g., the character matrices of character tables,
##  and functions to calculate permutations transforming the rows of a matrix
##  to the rows of another matrix.
##
Revision.ctblauto_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  FamiliesOfRows( <mat>, <maps> )
##
##  distributes the rows of the matrix <mat> into families as follows.
##  Two rows of <mat> belong to the same family if there is a permutation
##  of columns that maps one row to the other row.
##  Each entry in the list <maps> is regarded to form a family of length 1.
##
##  `FamiliesOfRows( <mat>, <maps> )' returns a record with components
##  \beginitems
##  `famreps' &
##       the list of representatives for each family,
##
##  `permutations' &
##       the list that contains at position `i' a list of permutations
##       that map the members of the family with representative `famreps[i]'
##       to that representative,
##
##  `families' &
##       the list that contains at position <i> the list of positions
##       of members of the family of representative `famreps[<i>]';
##       (for the element `<maps>[i]' the only member of the family
##       will get the number `Length( <mat> ) + i').
##  \enditems
##
DeclareGlobalFunction( "FamiliesOfRows" );


#############################################################################
##
#O  MatrixAutomorphisms( <mat>[, <maps>, <subgroup>] )
##
##  For a matrix <mat>, `MatrixAutomorphisms' returns the group of those
##  permutations of the columns of <mat> that leave the set of rows of <mat>
##  invariant.
##  
##  If the arguments <maps> and <subgroup> are given,
##  only the group of those permutations is constructed that additionally
##  fix each list in the list <maps> under pointwise action `OnTuples',
##  and <subgroup> is a permutation group that is known to be a subgroup of
##  this group of automorphisms.
##
##  Each entry in <maps> must be a list of same length as the rows of <mat>.
##  For example, if <mat> is a list of irreducible characters of a group
##  then the list of element orders of the conjugacy classes
##  (see~"OrdersClassRepresentatives") may be an entry in <maps>.
##
DeclareOperation( "MatrixAutomorphisms", [ IsMatrix ] );
DeclareOperation( "MatrixAutomorphisms", [ IsMatrix, IsList, IsPermGroup ] );


#############################################################################
##
#O  TableAutomorphisms( <tbl>, <characters>[, \"closed\"] )
##
##  `TableAutomorphisms' returns the permutation group of those matrix
##  automorphisms (see~"MatrixAutomorphisms") of the list <characters>
##  that leave the element orders (see~"OrdersClassRepresentatives")
##  and all stored power maps (see~"ComputedPowerMaps") of the character
##  table <tbl>.
##
##  If <characters> is closed under Galois conjugacy --this is always
##  fulfilled for ordinary character tables--
##  the string `\"closed\"' may be entered as third argument.
##
##  The attribute `AutomorphismsOfTable' (see~"AutomorphismsOfTable")
##  can be used to compute and store the table automorphisms for the case
##  that <characters> equals `Irr( <tbl> )'.
##
DeclareOperation( "TableAutomorphisms",
    [ IsNearlyCharacterTable, IsList ] );
DeclareOperation( "TableAutomorphisms",
    [ IsNearlyCharacterTable, IsList, IsString ] );


#############################################################################
##
#O  TransformingPermutations( <mat1>, <mat2> )
##
##  Let <mat1> and <mat2> be matrices.
##  `TransformingPermutations' tries to construct
##  a permutation $\pi$ that transforms the set of rows of the matrix
##  <mat1> to the set of rows of the matrix <mat2>
##  by permuting the columns.
##
##  If such a permutation exists,
##  a record with components `columns', `rows', and `group' is returned,
##  otherwise `fail'.
##  For $`TransformingPermutations( <mat1>, <mat2> ) = <r>' \not= `fail'$,
##  we have `<mat2> =
##   Permuted( List( <mat1>, x -> Permuted( x, <r>.columns ) ),<r>.rows )'.
##
##  `<r>.group' is the group of matrix automorphisms of <mat2>
##  (see~"MatrixAutomorphisms").
##  This group stabilizes the transformation in the sense that applying any
##  of its elements to the columns of <mat2>
##  preserves the set of rows of <mat2>.
##
DeclareOperation( "TransformingPermutations", [ IsMatrix, IsMatrix ] );


#############################################################################
##
#O  TransformingPermutationsCharacterTables( <tbl1>, <tbl2> )
##
##  Let <tbl1> and <tbl2> be character tables.
##  `TransformingPermutationsCharacterTables' tries to construct
##  a permutation $\pi$ that transforms the set of rows of the matrix
##  `Irr( <tbl1> )' to the set of rows of the matrix `Irr( <tbl2> )'
##  by permuting the columns (see~"TransformingPermutations"),
##  such that $\pi$ transforms also the power maps and the element orders.
##
##  If such a permutation $\pi$ exists then a record with the components
##  `columns' ($\pi$),
##  `rows' (the permutation of `Irr( <tbl1> )' corresponding to $\pi$), and
##  `group' (the permutation group of table automorphisms of <tbl2>,
##  see~"AutomorphismsOfTable") is returned.
##  If no such permutation exists, `fail' is returned.
##
DeclareOperation( "TransformingPermutationsCharacterTables",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#E

