#############################################################################
##
#W  zlattice.gd                 GAP library                     Thomas Breuer
##
#A  @(#)$Id$
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
DeclareOperation( "ScalarProduct", [ IsVector, IsVector ] );


#############################################################################
##
#F  PadicCoefficients( <A>, <Amodpinv>, <b>, <prime>, <depth> )
##
DeclareGlobalFunction( "PadicCoefficients" );


#############################################################################
##
#F  LinearIndependentColumns( <mat> )
##
##  is a maximal list of positions of linear independent columns in the
##  matrix <mat>.
##
DeclareGlobalFunction( "LinearIndependentColumns" );


#############################################################################
##
#F  DecompositionInt( <A>, <B>, <depth> )  . . . . . . . . integral solutions
##
##  returns the decomposition matrix <X> with `<X> \* <A> = <B>', for <A> and
##  <B> integral matrices.
##
##  For an odd prime $p$, each integer $x$ has a unique representation
##  $x = \sum_{i=0}^{n} x_i p^i$ where  $|x_i| \leq \frac{p-1}{2}$ .
##  Let $x$ be a solution of the equation $xA = b$ where $A$ is a square
##  integral matrix and $b$ an integral vector, $\overline{A} = A \bmod p$
##  and $\overline{b} = b \bmod p$;
##  then $\overline{x} \overline{A} \equiv \overline{b} \bmod p$ for
##  $\overline{x} = x \bmod p$.
##  Assume $\overline{A}$ is regular over the field with $p$ elements; then
##  $\overline{x}$ is uniquely determined mod $p$.
##  Define $x^{\prime} = \frac{x - \overline{x}}{p}$ and
##         $b^{\prime} = \frac{b - \overline{x} A }{p}$.
##  If $y$ is a solution of the equation $x^{\prime} A = b^{\prime}$ we
##  have $( \overline{x} + p y ) A = b$ and thus $x = \overline{x} + p y$
##  is the solution of our problem.
##  Note that the process must terminate if an integral solution $x$ exists,
##  since the $p$--adic series for $y$ has one term less than that for $x$.
##
##  If $A$ is not square, it must have full rank,
##  and $'Length( <A> )' \leq `Length( <A>[1] )'$.
##
DeclareGlobalFunction( "DecompositionInt" );


#############################################################################
##
#F  IntegralizedMat( <A> )
#F  IntegralizedMat( <A>, <inforec> )
##
DeclareGlobalFunction( "IntegralizedMat" );


#############################################################################
##
#F  Decomposition( <A>, <B>, <depth> ) . . . . . . . . . . integral solutions
#F  Decomposition( <A>, <B>, \"nonnegative\" ) . . . . . . integral solutions
##
##  For a matrix <A> of cyclotomics and a list <B> of cyclotomic vectors,
##  `Decomposition' tries to find integral solutions of the linear equation
##  systems `<x> \* <A> = <B>[i]'.
##
##  <A> must have full rank, i.e., there must be a linear independent set of
##  columns of same length as <A>.
##
##  `Decomposition( <A>, <B>, <depth> )', where <depth> is a nonnegative
##  integer, computes for every `<B>[i]' the initial part
##  $\sum_{k=0}^{<depth>} x_k p^k$ (all $x_k$ integer vectors with entries
##  bounded by $\pm\frac{p-1}{2}$) of the $p$-adic series of a hypothetical
##  solution. The prime $p$ is 83 first; if the reduction of <A>
##  modulo $p$ is singular, the next prime is chosen automatically.
##
##  A list <X> is returned. If the computed initial part for
##  `<x> \* <A> = <B>[i]' *is* a solution, we have `<X>[i] = <x>', otherwise
##  `<X>[i] = false'.
##
##  `Decomposition( <A>, <B>, \"nonnegative\" )' assumes that the solutions
##  have only nonnegative entries.
##  This is e.g.\ satisfied for the decomposition of ordinary characters into
##  Brauer characters.
##  If the first column of <A> consists of positive integers,
##  the necessary number <depth> of iterations can be computed. In that case
##  the `i'-th entry of the returned list is `false' if there *exists* no
##  nonnegative integral solution of the system `<x> \* <A> = <B>[i]', and it
##  is the solution otherwise.
##
##  *Note* that the result is a list of `false' if <A> has not full rank,
##  even if there might be a unique integral solution for some equation
##  system.
##
DeclareGlobalFunction( "Decomposition" );


#############################################################################
##  \Section{LLLReducedBasis}%
##  \index{LLL algorithm!for vectors}%
##  \index{short vectors spanning a lattice}%
##  \index{lattice base reduction}
##
#F  LLLReducedBasis( <vectors> )
#F  LLLReducedBasis( <vectors>, <y> )
#F  LLLReducedBasis( <vectors>, \"linearcomb\" )
#F  LLLReducedBasis( <vectors>, <y>, \"linearcomb\" )
#F  LLLReducedBasis( <L>, <vectors> )
#F  LLLReducedBasis( <L>, <vectors>, <y> )
#F  LLLReducedBasis( <L>, <vectors>, \"linearcomb\" )
#F  LLLReducedBasis( <L>, <vectors>, <y>, \"linearcomb\" )
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
##  (The function "LLLReducedGramMat" computes an LLL reduced Gram matrix.)
##
DeclareGlobalFunction( "LLLReducedBasis" );


#############################################################################
##  \Section{LLLReducedGramMat}%
##  \index{LLL algorithm!for Gram matrices}%
##  \index{lattice base reduction}
##
#F  LLLReducedGramMat( <G> ) . . . . . . . . . . . .  LLL reduced Gram matrix
#F  LLLReducedGramMat( <G>, <y> )
##
##  `LLLReducedGramMat' provides an implementation of the LLL algorithm by
##  Lenstra, Lenstra and Lov{\accent19 a}sz (see~\cite{LLL82}, \cite{Poh87}).
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
##  If <G> was a lower triangular matrix then also the `remainder' component
##  is a lower triangular matrix.
##
##  The result record contains also the components `relations' and
##  `transformation', which have the following meaning.
##
##  `relations' is a basis of the space of vectors $(x_1,x_2,\ldots,x_n)$
##  such that $\sum_{i=1}^n x_i b_i$ is zero,
##  and `transformation' gives the expression of the new lattice basis in
##  terms of the old, i.e., `transformation' is the matrix $T$ such that
##  $T \cdot <G> \cdot T^{tr}$ is the `remainder' component of the result.
##
##  The optional argument <y> denotes the ``sensitivity'' of the algorithm,
##  it must be a rational number between $\frac{1}{4}$ and $1$; the default
##  value is $<y> = \frac{3}{4}$.
##
##  (The function "LLLReducedBasis" computes an LLL reduced basis.)
##
##  \beginexample
##      gap> g:= [ [ 4, 6, 5, 2, 2 ], [ 6, 13, 7, 4, 4 ],
##      >    [ 5, 7, 11, 2, 0 ], [ 2, 4, 2, 8, 4 ], [ 2, 4, 0, 4, 8 ] ];;
##      gap> LLLReducedGramMat( g );
##      rec(
##        remainder :=
##         [ [ 4, 2, 1, 2, 2 ], [ 2, 5, 0, 2, 2 ], [ 1, 0, 5, 0, -2 ],
##            [ 2, 2, 0, 8, 4 ], [ 2, 2, -2, 4, 8 ] ],
##        transformation :=
##         [ [ 1, 0, 0, 0, 0 ], [ -1, 1, 0, 0, 0 ], [ -1, 0, 1, 0, 0 ],
##            [ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ] ],
##        scalarproducts :=
##         [ [ 1, 0, 0, 0, 0 ], [ 1/2, 1, 0, 0, 0 ], [ 1/4, -1/8, 1, 0, 0 ],
##            [ 1/2, 1/4, -2/25, 1, 0 ], [ 1/2, 1/4, -38/75, 8/21, 1 ] ],
##        bsnorms := [ 4, 4, 75/16, 168/25, 32/7 ] )
##  \endexample
##
DeclareGlobalFunction( "LLLReducedGramMat" );


#############################################################################
##
#F  ShortestVectors( <mat>, <bound> [, \"positive\" ] )
##
##  ...
##
DeclareGlobalFunction( "ShortestVectors" );


#############################################################################
##
#F  OrthogonalEmbeddings( <grammat> [, \"positive\" ] [, <integer> ] )
##
DeclareGlobalFunction( "OrthogonalEmbeddings" );


#############################################################################
##
#F  LLLint(<lat>) . . . . . . . . . . . . . . . . . . . .. . integer only LLL
##
DeclareGlobalFunction( "LLLint" );
#T The code was converted from Maple to GAP by Alexander.


#############################################################################
##
#E  zlattice.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

