#############################################################################
##
#W  ctbllatt.gd                 GAP library                     Thomas Breuer
#W                                                                Ansgar Kaup
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of functions that mainly deal with
##  lattices in the context of character tables.
##
Revision.ctbllatt_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  LLL( <tbl>, <characters>[, <y>][, \"sort\"][, \"linearcomb\"] )
##
##  \index{LLL algorithm!for virtual characters}%
##  \index{short vectors spanning a lattice}%
##  \index{lattice basis reduction!for virtual characters}
##
##  `LLL' calls the LLL algorithm (see~"LLLReducedBasis") in the case of
##  lattices spanned by the virtual characters <characters>
##  of the ordinary character table <tbl> (see~"ScalarProduct.ctblfuns").
##  By finding shorter vectors in the lattice spanned by <characters>,
##  i.e., virtual characters of smaller norm,
##  in some cases `LLL' is able to find irreducible characters.
##
##  `LLL' returns a record with at least components `irreducibles'
##  (the list of found irreducible characters),
##  `remainders' (a list of reducible virtual characters),
##  and `norms' (the list of norms of the vectors in `remainders').
##  `irreducibles' together with `remainders' form a basis of the
##  $\Z$-lattice spanned by <characters>.
##
##  Note that the vectors in the `remainders' list are in general *not*
##  orthogonal (see~"ReducedClassFunctions") to the irreducible characters in
##  `irreducibles'.
##
##  Optional arguments of `LLL' are
##  \beginitems
##  <y> &
##      controls the sensitivity of the algorithm,
##      see~"LLLReducedBasis",
##
##  `\"sort\"' &
##      `LLL' sorts <characters> and the `remainders' component of the
##      result according to the degrees,
##
##  `\"linearcomb\"' &
##      the returned record contains components `irreddecomp'
##      and `reddecomp', which are decomposition matrices of `irreducibles'
##      and `remainders', with respect to <characters>.
##  \enditems
##
DeclareGlobalFunction( "LLL" );


#############################################################################
##
#F  Extract( <tbl>, <reducibles>, <grammat>[, <missing> ] )
##
##  Let <tbl> be an ordinary character table,
##  <reducibles> a list of characters of <tbl>,
##  and <grammat> the matrix of scalar products of <reducibles>
##  (see~"MatScalarProducts").
##  `Extract' tries to find irreducible characters by drawing conclusions out
##  of the scalar products, using combinatorial and backtrack means.
##
##  The optional argument <missing> is the maximal number of irreducible
##  characters that occur as constituents of <reducibles>.
##  Specification of <missing> may accelerate `Extract'.
##
##  `Extract' returns a record <ext> with components `solution' and `choice',
##  where the value of `solution' is a list $[ M_1, \ldots, M_n ]$ of
##  decomposition matrices $M_i$ (up to permutations of rows)
##  with the property that $M_i^{tr} \cdot X$ is equal to
##  the sublist at the positions `<ext>.choice[i]' of <reducibles>,
##  for a matrix $X$ of irreducible characters;
##  the value of `choice' is a list of length $n$ whose entries are lists
##  of indices.
##
##  So the $j$-th column in each matrix $M_i$ corresponds to
##  $<reducibles>[j]$, and each row in $M_i$ corresponds to an irreducible
##  character.
##  `Decreased' (see~"Decreased") can be used to examine the solution for
##  computable irreducibles.
##
DeclareGlobalFunction( "Extract" );


#############################################################################
##
#F  OrthogonalEmbeddingsSpecialDimension( <tbl>, <reducibles>, <grammat>,
#F                                                   [\"positive\", ] <dim> )
##
##  `OrthogonalEmbeddingsSpecialDimension' is a variant of
##  `OrthogonalEmbeddings' (see~"OrthogonalEmbeddings") for the situation
##  that <tbl> is an ordinary character table, <reducibles> is a list of
##  virtual characters of <tbl>, <grammat> is the matrix of scalar products
##  (see~"MatScalarProducts"), and <dim> is an upper bound for the number of
##  irreducible characters of <tbl> that occur as constituents of
##  <reducibles>;
##  if the vectors in <reducibles> are known to be proper characters then
##  the string `\"positive\"' may be entered as fourth argument.
##  (See~"OrthogonalEmbeddings" for information why this may help.)
##
##  `OrthogonalEmbeddingsSpecialDimension' first uses `OrthogonalEmbeddings'
##  (see~"OrthogonalEmbeddings") to compute all orthogonal embeddings of
##  <grammat> into a standard lattice of dimension up to <dim>,
##  and then calls `Decreased' (see~"Decreased") in order to find irreducible
##  characters of <tbl>.
##
##  `OrthogonalEmbeddingsSpecialDimension' returns a record with components
##
##  \beginitems
##  `irreducibles' &
##      a list of found irreducibles, the intersection of all lists of
##      irreducibles found by `Decreased', for all possible embeddings, and
##
##  `remainders' &
##      a list of remaining reducible virtual characters.
##  \enditems
##
DeclareGlobalFunction( "OrthogonalEmbeddingsSpecialDimension" );


#############################################################################
##
#F  Decreased( <tbl>, <chars>, <decompmat>[, <choice>] )
##
##  Let <tbl> be an ordinary character table,
##  <chars> a list of virtual characters of <tbl>,
##  and <decompmat> a decomposition matrix, that is,
##  a matrix $M$ with the property that $M^{tr} \cdot X = <chars>$ holds,
##  where $X$ is a list of irreducible characters of <tbl>.
##  `Decreased' tries to compute the irreducibles in $X$ or at least some of
##  them.
##
##  Usually `Decreased' is applied to the output of `Extract' (see~"Extract")
##  or `OrthogonalEmbeddings'
##  (see~"OrthogonalEmbeddings", "OrthogonalEmbeddingsSpecialDimension");
##  in the case of `Extract', the choice component corresponding to the
##  decomposition matrix must be entered as argument <choice> of `Decreased'.
##
##  `Decreased' returns `fail' if it can prove that no list $X$ of
##  irreducible characters corresponding to the arguments exists;
##  otherwise `Decreased' returns a record with components
##  \beginitems
##  `irreducibles' &
##      the list of found irreducible characters,
##
##  `remainders' &
##      the remaining reducible characters, and
##
##  `matrix' &
##      the decomposition matrix of the characters in the `remainders'
##      component.
##  \enditems
##
DeclareGlobalFunction( "Decreased" );


#############################################################################
##
#F  DnLattice( <tbl>, <grammat>, <reducibles> )
##
##  Let <tbl> be an ordinary character table,
##  and <reducibles> a list of virtual characters of <tbl>.
##
##  `DnLattice' searches for sublattices isomorphic to root lattices of type
##  $D_n$, for $n \geq 4$, in the lattice that is generated by <reducibles>;
##  each vector in <reducibles> must have norm $2$, and the matrix of scalar
##  products (see~"MatScalarProducts") of <reducibles> must be entered as
##  argument <grammat>.
##
##  `DnLattice' is able to find irreducible characters if there is a lattice
##  of type $D_n$ with $n > 4$.
##  In the case $n = 4$, `DnLattice' may fail to determine irreducibles.
##
##  `DnLattice' returns a record with components
##  \beginitems
##  `irreducibles' &
##      the list of found irreducible characters,
##
##  `remainders' &
##      the list of remaining reducible virtual characters, and
##
##  `gram' &
##      the Gram matrix of the vectors in `remainders'.
##  \enditems
##
##  The `remainders' list is transformed in such a way that the `gram'
##  matrix is a block diagonal matrix that exhibits the structure of the
##  lattice generated by the vectors in `remainders'.
##  So `DnLattice' might be useful even if it fails to find irreducible
##  characters.
##
DeclareGlobalFunction( "DnLattice" );


#############################################################################
##
#F  DnLatticeIterative( <tbl>, <reducibles> )
##
##  Let <tbl> be an ordinary character table,
##  and <reducibles> either a list of virtual characters of <tbl>
##  or a record with components `remainders' and `norms',
##  for example a record returned by `LLL' (see~"LLL").
##
##  `DnLatticeIterative' was designed for iterative use of `DnLattice'
##  (see~"DnLattice").
##  `DnLatticeIterative' selects the vectors of norm $2$ among the given
##  virtual character, calls `DnLattice' for them,
##  reduces the virtual characters with found irreducibles,
##  calls `DnLattice' again for the remaining virtual characters,
##  and so on, until no new irreducibles are found.
##
##  `DnLatticeIterative' returns a record with the same components and
##  meaning of components as `LLL' (see~"LLL").
##
DeclareGlobalFunction( "DnLatticeIterative" );


#############################################################################
##
#E

