#############################################################################
##
#W  zlattice.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of functions and operations dealing
##  with lattices.
##
Revision.zlattice_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoZLattice
##
DeclareInfoClass( "InfoZLattice" );


#############################################################################
##
#O  ScalarProduct( <v>, <w> )
#O  ScalarProduct( <L>, <v>, <w> )
##
##  Called with two row vectors <v>, <w> of the same length, `ScalarProduct'
##  returns the standard scalar product of these vectors;
##  this can also be computed as `<v> \* <w>'.
##
##  Called with a lattice <L> and two elements <v>, <w> of <L>,
##  `ScalarProduct' returns the scalar product of these elements w.r.t.~the
##  scalar product associated to <L>.
##
DeclareOperation( "ScalarProduct", [ IsVector, IsVector ] );
DeclareOperation( "ScalarProduct",
    [ IsFreeLeftModule, IsVector, IsVector ] );


#############################################################################
##
#F  StandardScalarProduct( <L>, <x>, <y> )
##
##  returns `<x> \* <y>'.
##
DeclareGlobalFunction( "StandardScalarProduct" );


#############################################################################
##
##  Decompositions
#1
##  For computing the decomposition of a vector of integers into the rows of
##  a matrix of integers, with integral coefficients,
##  one can use $p$-adic approximations, as follows.
##
##  Let $A$ be a square integral matrix, and $p$ an odd prime.
##  The reduction of $A$ modulo $p$ is $\overline{A}$,
##  its entries are  chosen in the interval
##  $[-\frac{p-1}{2}, \frac{p-1}{2}]$.
##  If $\overline{A}$ is regular over the field with $p$ elements,
##  we can form $A^{\prime} = \overline{A}^{-1}$.
##  Now we consider the integral linear equation system $x A = b$,
##  i.e., we look for an integral solution $x$.
##  Define $b_0 = b$, and then iteratively compute
##  $$
##  x_i = (b_i A^{\prime}) \bmod p,\ \ b_{i+1} = \frac{1}{p} (b_i - x_i A),
##    i = 0, 1, 2, \ldots \.
##  $$
##  By induction, we get                                                     
##  $$
##  p^{i+1} b_{i+1} + \left( \sum_{j=0}^{i} p^j x_j \right) A = b\.
##  $$
##  If there is an integral solution $x$ then it is unique,
##  and there is an index $l$ such that $b_{l+1}$ is zero
##  and $x = \sum_{j=0}^{l} p^j x_j$.               
##
##  There are two useful generalizations of this idea.
##  First, $A$ need not be square; it is only necessary that there is
##  a square regular matrix formed by a subset of columns of $A$.
##  Second, $A$ does not need to be integral;
##  the entries may be cyclotomic integers as well,
##  in this case one can replace each column of <A> by the columns formed by
##  the coefficients w.r.t.~an integral basis (which are integers).
##  Note that this preprocessing must be performed compatibly for
##  <A> and <b>.
##
##  {\GAP} provides the following functions for this purpose
##  (see also~"InverseMatMod").
##


#############################################################################
##
#F  Decomposition( <A>, <B>, <depth> ) . . . . . . . . . . integral solutions
#F  Decomposition( <A>, <B>, \"nonnegative\" ) . . . . . . integral solutions
##
##  For a $m \times n$ matrix <A> of cyclotomics that has rank $m \leq n$,
##  and a list <B> of cyclotomic vectors, each of length $n$,
##  `Decomposition' tries to find integral solutions of the linear equation
##  systems `<x> * <A> = <B>[i]',
##  by computing the $p$-adic series of hypothetical solutions.
##
##  `Decomposition( <A>, <B>, <depth> )', where <depth> is a nonnegative
##  integer, computes for each vector `<B>[i]' the initial part
##  $\sum_{k=0}^{<depth>} x_k p^k$,
##  with all $x_k$ vectors of integers with entries bounded by
##  $\pm\frac{p-1}{2}$.
##  The prime $p$ is 83 first; if the reduction of <A>
##  modulo $p$ is singular, the next prime is chosen automatically.
##
##  A list <X> is returned.
##  If the computed initial part for `<x> * <A> = <B>[i]' *is* a solution,
##  we have `<X>[i] = <x>', otherwise `<X>[i] = fail'.
##
##  `Decomposition( <A>, <B>, \"nonnegative\" )' assumes that the solutions
##  have only nonnegative entries,
##  and that the first column of <A> consists of positive integers.
##  This is satisfied, e.g., for the decomposition of ordinary characters
##  into Brauer characters.
##  In this case the necessary number <depth> of iterations can be computed;
##  the `i'-th entry of the returned list is `fail' if there *exists* no
##  nonnegative integral solution of the system `<x> * <A> = <B>[i]', and it
##  is the solution otherwise.
##
##  *Note* that the result is a list of `fail' if <A> has not full rank,
##  even if there might be a unique integral solution for some equation
##  system.
##
DeclareGlobalFunction( "Decomposition" );


#############################################################################
##
#F  LinearIndependentColumns( <mat> )
##
##  Called with a matrix <mat>, `LinearIndependentColumns' returns a maximal
##  list of column positions such that the restriction of <mat> to these
##  columns has the same rank as <mat>.
##
DeclareGlobalFunction( "LinearIndependentColumns" );


#############################################################################
##
#F  PadicCoefficients( <A>, <Amodpinv>, <b>, <prime>, <depth> )
##
##  Let <A> be an integral matrix,
##  <prime> a prime integer,
##  <Amodpinv> an inverse of <A> modulo <prime>,
##  <b> an integral vector,
##  and <depth> a nonnegative integer.
##  `PadicCoefficients' returns the list $[ x_0, x_1, \ldots, x_l, b_{l+1} ]$
##  describing the <prime>-adic approximation of <b> (see above),
##  where $l = <depth>$
##  or $l$ is minimal with the property that $b_{l+1} = 0$.
##
DeclareGlobalFunction( "PadicCoefficients" );


#############################################################################
##
#F  IntegralizedMat( <A> )
#F  IntegralizedMat( <A>, <inforec> )
##
##  `IntegralizedMat' returns for a matrix <A> of cyclotomics
##  a record <intmat> with components `mat' and `inforec'.
##  Each family of algebraic conjugate columns of <A> is encoded in a set of
##  columns of the rational matrix `<intmat>.mat' by replacing cyclotomics
##  in <A> by their coefficients w.r.t.~an integral basis.
##  `<intmat>.inforec' is a record containing the information how to encode
##  the columns.
##
##  If the only argument is <A>, the value of the component `inforec' is
##  computed that can be entered as second argument <inforec> in a later call
##  of `IntegralizedMat' with a matrix <B> that shall be encoded compatibly
##  with <A>.
##
DeclareGlobalFunction( "IntegralizedMat" );


#############################################################################
##
#F  DecompositionInt( <A>, <B>, <depth> )  . . . . . . . . integral solutions
##
##  `DecompositionInt' does the same as `Decomposition'
##  (see~"Decomposition"),
##  except that <A> and <B> must be integral matrices, and <depth> must be
##  a nonnegative integer.
##
DeclareGlobalFunction( "DecompositionInt" );


#############################################################################
##
#F  LLLReducedBasis( [<L>, ]<vectors>[, <y>][, \"linearcomb\"][, <lllout>] )
##
##  `LLLReducedBasis' provides an implementation of the LLL algorithm by
##  Lenstra, Lenstra and Lov{\accent19 a}sz (see~\cite{LLL82}, \cite{Poh87}).
##  The implementation follows the description on pages 94f. in~\cite{Coh93}.
##
##  `LLLReducedBasis' returns a record whose component `basis' is a list of
##  LLL reduced linearly independent vectors spanning the same lattice as
##  the list <vectors>.
##  <L> must be a lattice, with scalar product of the vectors <v> and <w>
##  given by `ScalarProduct( <L>, <v>, <w> )'.
##  If no lattice is specified then the scalar product of vectors given by
##  `ScalarProduct( <v>, <w> )' is used.
##
##  In the case of the option `\"linearcomb\"', the result record contains
##  also the components `relations' and `transformation', with the following
##  meaning.
##  `relations' is a basis of the relation space of <vectors>, i.e., of
##  vectors <x> such that `<x> \* <vectors>' is zero.
##  `transformation' gives the expression of the new lattice basis in
##  terms of the old, i.e.,
##  `transformation \* <vectors>' equals the `basis' component of the result.
##
##  Another optional argument is <y>, the ``sensitivity'' of the algorithm,
##  a rational number between $\frac{1}{4}$ and $1$ (the default value is
##  $\frac{3}{4}$).
##
##  The optional argument <lllout> is a record with the components `mue'
##  and `B', both lists of length $k$, with the meaning that
##  if <lllout> is present then the first $k$ vectors in <vectors> form
##  an LLL reduced basis of the lattice they generate,
##  and `<lllout>.mue' and `<lllout>.B' contain their scalar products and
##  norms used internally in the algorithm, which are also present in the
##  output of `LLLReducedBasis'.
##  So <lllout> can be used for ``incremental'' calls of `LLLReducedBasis'.
##
##  The function `LLLReducedGramMat' (see~"LLLReducedGramMat")
##  computes an LLL reduced Gram matrix.
##  
##  \beginexample
##  gap> vectors:= [ [ 9, 1, 0, -1, -1 ], [ 15, -1, 0, 0, 0 ],
##  >                [ 16, 0, 1, 1, 1 ], [ 20, 0, -1, 0, 0 ],
##  >                [ 25, 1, 1, 0, 0 ] ];;
##  gap> LLLReducedBasis( vectors, "linearcomb" );
##  rec(
##    basis :=
##     [ [ 1, 1, 1, 1, 1 ], [ 1, 1, -2, 1, 1 ], [ -1, 3, -1, -1, -1 ], 
##       [ -3, 1, 0, 2, 2 ] ],
##    relations := [ [ -1, 0, -1, 0, 1 ] ], 
##    transformation := [ [ 0, -1, 1, 0, 0 ], [ -1, -2, 0, 2, 0 ], 
##        [ 1, -2, 0, 1, 0 ], [ -1, -2, 1, 1, 0 ] ], 
##    mue := [ [  ], [ 2/5 ], [ -1/5, 1/3 ], [ 2/5, 1/6, 1/6 ] ], 
##    B := [ 5, 36/5, 12, 50/3 ] )
##  \endexample
##
DeclareGlobalFunction( "LLLReducedBasis" );


#############################################################################
##
#F  LLLReducedGramMat( <G> ) . . . . . . . . . . . .  LLL reduced Gram matrix
#F  LLLReducedGramMat( <G>, <y> )
##
##  `LLLReducedGramMat' provides an implementation of the LLL algorithm by
##  Lenstra, Lenstra and Lov{\accent19 a}sz (see~\cite{LLL82},~\cite{Poh87}).
##  The implementation follows the description on pages 94f. in~\cite{Coh93}.
##
##  Let <G> the Gram matrix of the vectors $(b_1, b_2, \ldots, b_n)$;
##  this means <G> is either a square symmetric matrix or lower triangular
##  matrix (only the entries in the lower triangular half are used by the
##  program).
##
##  `LLLReducedGramMat' returns a record whose component `remainder' is the
##  Gram matrix of the LLL reduced basis corresponding to $(b_1, b_2, \ldots,
##  b_n)$.
##  If <G> is a lower triangular matrix then also the `remainder' component
##  of the result record is a lower triangular matrix.
##
##  The result record contains also the components `relations' and
##  `transformation', which have the following meaning.
##
##  `relations' is a basis of the space of vectors $(x_1,x_2,\ldots,x_n)$
##  such that $\sum_{i=1}^n x_i b_i$ is zero,
##  and `transformation' gives the expression of the new lattice basis in
##  terms of the old, i.e., `transformation' is the matrix $T$ such that
##  $T . <G> . T^{tr}$ is the `remainder' component of the result.
##
##  The optional argument <y> denotes the ``sensitivity'' of the algorithm,
##  it must be a rational number between $\frac{1}{4}$ and $1$; the default
##  value is $<y> = \frac{3}{4}$.
##
##  The function `LLLReducedBasis' (see~"LLLReducedBasis")
##  computes an LLL reduced basis.
##
##  \beginexample
##  gap> g:= [ [ 4, 6, 5, 2, 2 ], [ 6, 13, 7, 4, 4 ],
##  >    [ 5, 7, 11, 2, 0 ], [ 2, 4, 2, 8, 4 ], [ 2, 4, 0, 4, 8 ] ];;
##  gap> LLLReducedGramMat( g );
##  rec(
##    remainder := [ [ 4, 2, 1, 2, -1 ], [ 2, 5, 0, 2, 0 ], [ 1, 0, 5, 0, 2 ], 
##        [ 2, 2, 0, 8, 2 ], [ -1, 0, 2, 2, 7 ] ],
##    relations := [  ],
##    transformation := 
##     [ [ 1, 0, 0, 0, 0 ], [ -1, 1, 0, 0, 0 ], [ -1, 0, 1, 0, 0 ], 
##        [ 0, 0, 0, 1, 0 ], [ -2, 0, 1, 0, 1 ] ],
##    mue := [ [], [ 1/2 ], [ 1/4, -1/8 ], [ 1/2, 1/4, -2/25 ], 
##        [ -1/4, 1/8, 37/75, 8/21 ] ],
##    B := [ 4, 4, 75/16, 168/25, 32/7 ] )
##  \endexample
##
DeclareGlobalFunction( "LLLReducedGramMat" );


#############################################################################
##
#F  ShortestVectors( <G>, <m>[, \"positive\"] )
##
##  Let <G> be a regular matrix of a symmetric bilinear form,
##  and <m> a nonnegative integer.
##  `ShortestVectors' computes the vectors $x$ that satisfy
##  $x . <G> . x^{tr} \leq <m>$,
##  and returns a record describing these vectors.
##  The result record has the components
##  \beginitems
##  `vectors' &
##       list of the nonzero vectors $x$, but only one of each pair $(x,-x)$,
##
##  `norms' &
##       list of norms of the vectors according to the Gram matrix <G>.
##  \enditems
##  If the optional argument `\"positive\"' is entered,
##  only those vectors $x$ with nonnegative entries are computed.
##  \beginexample
##  gap> g:= [ [ 2, 1, 1 ], [ 1, 2, 1 ], [ 1, 1, 2 ] ];;  
##  gap> ShortestVectors(g,4);
##  rec(                                                                 
##    vectors := [ [ -1, 1, 1 ], [ 0, 0, 1 ], [ -1, 0, 1 ], [ 1, -1, 1 ],
##        [ 0, -1, 1 ], [ -1, -1, 1 ], [ 0, 1, 0 ], [ -1, 1, 0 ], 
##        [ 1, 0, 0 ] ],
##    norms := [ 4, 2, 2, 4, 2, 4, 2, 2, 2 ] )
##  \endexample
##
DeclareGlobalFunction( "ShortestVectors" );


#############################################################################
##
#F  OrthogonalEmbeddings( <gram>[, \"positive\"][, <maxdim>] )
##
##  computes all possible orthogonal embeddings of a lattice given by its
##  Gram matrix <gram>, which must be a regular matrix.
##  In other words, all solutions $X$ of the problem
##  $$
##  X^{tr} . X = <gram>
##  $$
##  are calculated (see~\cite{Ple90}).
##  Usually there are many solutions $X$
##  but all their rows are chosen from a small set of vectors,
##  so `OrthogonalEmbeddings' returns the solutions in an encoded form,
##  namely as a record with components
##  \beginitems
##  `vectors' &
##       the list $L = [ x_1, x_2, \ldots, x_n ]$ of vectors
##       that may be rows of a solution;
##       these are exactly those vectors that fulfill the condition
##       $x_i . <gram>^{-1} . x_i^{tr} \leq 1$
##       (see~"ShortestVectors"),
##       and we have $<gram> = \sum^n_{i=1} x_i^{tr} . x_i$,
##
##  `norms' &
##       the list of values $x_i . <gram>^{-1} . x_i^{tr}$, and
##
##  `solutions' &
##       a list <S> of lists; the <i>-th solution matrix is
##       `<L>{ <S>[<i>] }',
##       so the dimension of the <i>-th solution is the length of
##       `<S>[<i>]'.
##  \enditems
##
##  The optional argument `\"positive\"' will cause `OrthogonalEmbeddings'
##  to compute only vectors $x_i$ with nonnegative entries.
##  In the context of characters this is allowed (and useful)
##  if <gram> is the matrix of scalar products of ordinary characters.
##
##  When `OrthogonalEmbeddings' is called with the optional argument
##  <maxdim> (a positive integer),
##  only solutions up to dimension <maxdim> are computed;
##  this will accelerate the algorithm in some cases.
##  \beginexample
##  gap> b:= [ [ 3, -1, -1 ], [ -1, 3, -1 ], [ -1, -1, 3 ] ];;
##  gap> c:=OrthogonalEmbeddings( b );
##  rec(
##    vectors :=
##     [ [ -1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ], [ -1, 1, 0 ],
##        [ -1, 0, 1 ], [ 1, 0, 0 ], [ 0, -1, 1 ], [ 0, 1, 0 ],
##        [ 0, 0, 1 ] ],
##    norms := [ 1, 1, 1, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2 ],
##    solutions := [ [ 1, 2, 3 ], [ 1, 6, 6, 7, 7 ], [ 2, 5, 5, 8, 8 ],
##        [ 3, 4, 4, 9, 9 ], [ 4, 5, 6, 7, 8, 9 ] ] )
##  gap> c.vectors{ c.solutions[1] };
##  [ [ -1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ] ]
##  \endexample
##
##  <gram> may be the matrix of scalar products of some virtual characters.
##  From the characters and the embedding given by the matrix $X$,
##  `Decreased' (see~"Decreased") may be able to compute irreducibles,
##  see~"Reducing Virtual Characters".
##
DeclareGlobalFunction( "OrthogonalEmbeddings" );


#############################################################################
##
#F  LLLint( <lat> ) . . . . . . . . . . . . . . . . . . . .  integer only LLL
##
DeclareGlobalFunction( "LLLint" );
#T The code was converted from Maple to GAP by Alexander.


#############################################################################
##
#E

