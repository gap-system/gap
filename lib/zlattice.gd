#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of functions and operations dealing
##  with lattices.
##


#############################################################################
##
#V  InfoZLattice
##
##  <ManSection>
##  <InfoClass Name="InfoZLattice"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareInfoClass( "InfoZLattice" );


#############################################################################
##
#O  ScalarProduct( [<L>, ]<v>, <w> )
##
##  <ManSection>
##  <Oper Name="ScalarProduct" Arg='[L, ]v, w'/>
##
##  <Description>
##  Called with two row vectors <A>v</A>, <A>w</A> of the same length,
##  <Ref Func="ScalarProduct"/> returns the standard scalar product of these
##  vectors; this can also be computed as <C><A>v</A> * <A>w</A></C>.
##  <P/>
##  Called with a lattice <A>L</A> and two elements <A>v</A>, <A>w</A> of
##  <A>L</A>,
##  <Ref Func="ScalarProduct"/> returns the scalar product of these elements
##  w.r.t.&nbsp;the scalar product associated to <A>L</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ScalarProduct", [ IsVector, IsVector ] );
DeclareOperation( "ScalarProduct",
    [ IsFreeLeftModule, IsVector, IsVector ] );


#############################################################################
##
#F  StandardScalarProduct( <L>, <x>, <y> )
##
##  <ManSection>
##  <Func Name="StandardScalarProduct" Arg='L, x, y'/>
##
##  <Description>
##  returns <C><A>x</A> * <A>y</A></C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "StandardScalarProduct" );


#############################################################################
##
##  Decompositions
##
##  <#GAPDoc Label="[1]{zlattice}">
##  <Index>decomposition matrix</Index>
##  <Index>DEC</Index>
##  For computing the decomposition of a vector of integers into the rows of
##  a matrix of integers, with integral coefficients,
##  one can use <M>p</M>-adic approximations, as follows.
##  <P/>
##  Let <M>A</M> be a square integral matrix, and <M>p</M> an odd prime.
##  The reduction of <M>A</M> modulo <M>p</M> is <M>\overline{A}</M>,
##  its entries are  chosen in the interval
##  <M>[ -(p-1)/2, (p-1)/2 ]</M>.
##  If <M>\overline{A}</M> is regular over the field with <M>p</M> elements,
##  we can form <M>A' = \overline{A}^{{-1}}</M>.
##  Now we consider the integral linear equation system <M>x A = b</M>,
##  i.e., we look for an integral solution <M>x</M>.
##  Define <M>b_0 = b</M>, and then iteratively compute
##  <Display Mode="M">
##  x_i = (b_i A') \bmod p,  b_{{i+1}} = (b_i - x_i A) / p,
##    i = 0, 1, 2, \ldots .
##  </Display>
##  By induction, we get
##  <Display Mode="M">
##  p^{{i+1}} b_{{i+1}} + \left( \sum_{{j = 0}}^i p^j x_j \right) A = b.
##  </Display>
##  If there is an integral solution <M>x</M> then it is unique,
##  and there is an index <M>l</M> such that <M>b_{{l+1}}</M> is zero
##  and <M>x = \sum_{{j = 0}}^l p^j x_j</M>.
##  <P/>
##  There are two useful generalizations of this idea.
##  First, <M>A</M> need not be square; it is only necessary that there is
##  a square regular matrix formed by a subset of columns of <M>A</M>.
##  Second, <M>A</M> does not need to be integral;
##  the entries may be cyclotomic integers as well,
##  in this case one can replace each column of <M>A</M> by the columns
##  formed by the coefficients w.r.t.&nbsp;an integral basis (which are
##  integers).
##  Note that this preprocessing must be performed compatibly for
##  <M>A</M> and <M>b</M>.
##  <P/>
##  &GAP; provides the following functions for this purpose
##  (see also&nbsp;<Ref Oper="InverseMatMod"/>).
##  <#/GAPDoc>
##


#############################################################################
##
#F  Decomposition( <A>, <B>, <depth> ) . . . . . . . . . . integral solutions
##
##  <#GAPDoc Label="Decomposition">
##  <ManSection>
##  <Oper Name="Decomposition" Arg='A, B, depth'/>
##
##  <Description>
##  For a <M>m \times n</M> matrix <A>A</A> of cyclotomics that has rank
##  <M>m \leq n</M>, and a list <A>B</A> of cyclotomic vectors,
##  each of length <M>n</M>,
##  <Ref Oper="Decomposition"/> tries to find integral solutions
##  of the linear equation systems <C><A>x</A> * <A>A</A> = <A>B</A>[i]</C>,
##  by computing the <M>p</M>-adic series of hypothetical solutions.
##  <P/>
##  <C>Decomposition( <A>A</A>, <A>B</A>, <A>depth</A> )</C>,
##  where <A>depth</A> is a nonnegative integer, computes for each vector
##  <C><A>B</A>[i]</C> the initial part
##  <M>\sum_{{k = 0}}^{<A>depth</A>} x_k p^k</M>,
##  with all <M>x_k</M> vectors of integers with entries bounded by
##  <M>\pm (p-1)/2</M>.
##  The prime <M>p</M> is set to 83 first; if the reduction of <A>A</A>
##  modulo <M>p</M> is singular, the next prime is chosen automatically.
##  <P/>
##  A list <A>X</A> is returned.
##  If the computed initial part for <C><A>x</A> * <A>A</A> = <A>B</A>[i]</C>
##  <E>is</E> a solution,
##  we have <C><A>X</A>[i] = <A>x</A></C>,
##  otherwise <C><A>X</A>[i] = fail</C>.
##  <P/>
##  If <A>depth</A> is not an integer then it must be the string
##  <C>"nonnegative"</C>.
##  <C>Decomposition( <A>A</A>, <A>B</A>, "nonnegative" )</C> assumes that
##  the solutions have only nonnegative entries,
##  and that the first column of <A>A</A> consists of positive integers.
##  This is satisfied, e.g., for the decomposition of ordinary characters
##  into Brauer characters.
##  In this case the necessary number <A>depth</A> of iterations can be
##  computed; the <C>i</C>-th entry of the returned list is <K>fail</K> if
##  there <E>exists</E> no nonnegative integral solution of the system
##  <C><A>x</A> * <A>A</A> = <A>B</A>[i]</C>, and it is the solution
##  otherwise.
##  <P/>
##  <E>Note</E> that the result is a list of <K>fail</K> if <A>A</A> has not
##  full rank,
##  even if there might be a unique integral solution for some equation
##  system.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Decomposition", [ IsMatrix, IsList, IsObject ] );


#############################################################################
##
#F  LinearIndependentColumns( <mat> )
##
##  <#GAPDoc Label="LinearIndependentColumns">
##  <ManSection>
##  <Func Name="LinearIndependentColumns" Arg='mat'/>
##
##  <Description>
##  Called with a matrix <A>mat</A>, <C>LinearIndependentColumns</C> returns a maximal
##  list of column positions such that the restriction of <A>mat</A> to these
##  columns has the same rank as <A>mat</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LinearIndependentColumns" );


#############################################################################
##
#F  PadicCoefficients( <A>, <Amodpinv>, <b>, <prime>, <depth> )
##
##  <#GAPDoc Label="PadicCoefficients">
##  <ManSection>
##  <Func Name="PadicCoefficients" Arg='A, Amodpinv, b, prime, depth'/>
##
##  <Description>
##  Let <A>A</A> be an integral matrix,
##  <A>prime</A> a prime integer,
##  <A>Amodpinv</A> an inverse of <A>A</A> modulo <A>prime</A>,
##  <A>b</A> an integral vector,
##  and <A>depth</A> a nonnegative integer.
##  <Ref Func="PadicCoefficients"/> returns the list
##  <M>[ x_0, x_1, \ldots, x_l, b_{{l+1}} ]</M>
##  describing the <A>prime</A>-adic approximation of <A>b</A> (see above),
##  where <M>l = <A>depth</A></M>
##  or <M>l</M> is minimal with the property that <M>b_{{l+1}} = 0</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PadicCoefficients" );


#############################################################################
##
#F  IntegralizedMat( <A>[, <inforec>] )
##
##  <#GAPDoc Label="IntegralizedMat">
##  <ManSection>
##  <Func Name="IntegralizedMat" Arg='A[, inforec]'/>
##
##  <Description>
##  <Ref Func="IntegralizedMat"/> returns, for a matrix <A>A</A> of
##  cyclotomics, a record <C>intmat</C> with components <C>mat</C> and
##  <C>inforec</C>.
##  Each family of algebraic conjugate columns of <A>A</A> is encoded in a
##  set of columns of the rational matrix <C>intmat.mat</C> by replacing
##  cyclotomics in <A>A</A> by their coefficients w.r.t.&nbsp;an integral
##  basis.
##  <C>intmat.inforec</C> is a record containing the information how to
##  encode the columns.
##  <P/>
##  If the only argument is <A>A</A>, the value of the component
##  <C>inforec</C> is computed that can be entered as second argument
##  <A>inforec</A> in a later call of <Ref Func="IntegralizedMat"/> with a
##  matrix <A>B</A> that shall be encoded compatibly with <A>A</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntegralizedMat" );


#############################################################################
##
#F  DecompositionInt( <A>, <B>, <depth> )  . . . . . . . . integral solutions
##
##  <#GAPDoc Label="DecompositionInt">
##  <ManSection>
##  <Func Name="DecompositionInt" Arg='A, B, depth'/>
##
##  <Description>
##  <Ref Func="DecompositionInt"/> does the same as
##  <Ref Oper="Decomposition"/>,
##  except that <A>A</A> and <A>B</A> must be integral matrices,
##  and <A>depth</A> must be a nonnegative integer.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DecompositionInt" );


#############################################################################
##
#F  LLLReducedBasis( [<L>, ]<vectors>[, <y>][, "linearcomb"][, <lllout>] )
##
##  <#GAPDoc Label="LLLReducedBasis">
##  <ManSection>
##  <Func Name="LLLReducedBasis"
##   Arg='[L, ]vectors[, y][, "linearcomb"][, lllout]'/>
##
##  <Description>
##  <Index Subkey="for vectors">LLL algorithm</Index>
##  <Index>short vectors spanning a lattice</Index>
##  <Index>lattice base reduction</Index>
##  provides an implementation of the <E>LLL algorithm</E> by
##  Lenstra, Lenstra and Lovász (see&nbsp;<Cite Key="LLL82"/>,
##  <Cite Key="Poh87"/>).
##  The implementation follows the description
##  in&nbsp;<Cite Key="Coh93" Where="p. 94f."/>.
##  <P/>
##  <Ref Func="LLLReducedBasis"/> returns a record whose component
##  <C>basis</C> is a list of LLL reduced linearly independent vectors
##  spanning the same lattice as the list <A>vectors</A>.
##  <A>L</A> must be a lattice, with scalar product of the vectors <A>v</A>
##  and <A>w</A> given by
##  <C>ScalarProduct( <A>L</A>, <A>v</A>, <A>w</A> )</C>.
##  If no lattice is specified then the scalar product of vectors given by
##  <C>ScalarProduct( <A>v</A>, <A>w</A> )</C> is used.
##  <P/>
##  In the case of the option <C>"linearcomb"</C>, the result record contains
##  also the components <C>relations</C> and <C>transformation</C>,
##  with the following meaning.
##  <C>relations</C> is a basis of the relation space of <A>vectors</A>,
##  i.e., of vectors <A>x</A> such that <C><A>x</A> * <A>vectors</A></C> is
##  zero.
##  <C>transformation</C> gives the expression of the new lattice basis in
##  terms of the old, i.e.,
##  <C>transformation * <A>vectors</A></C> equals the <C>basis</C> component
##  of the result.
##  <P/>
##  Another optional argument is <A>y</A>, the <Q>sensitivity</Q> of the
##  algorithm, a rational number between <M>1/4</M> and <M>1</M>
##  (the default value is <M>3/4</M>).
##  <P/>
##  The optional argument <A>lllout</A> is a record with the components
##  <C>mue</C> and <C>B</C>, both lists of length <M>k</M>,
##  with the meaning that if <A>lllout</A> is present then the first <M>k</M>
##  vectors in <A>vectors</A> form an LLL reduced basis of the lattice they
##  generate,
##  and <C><A>lllout</A>.mue</C> and <C><A>lllout</A>.B</C> contain their
##  scalar products and norms used internally in the algorithm,
##  which are also present in the output of <Ref Func="LLLReducedBasis"/>.
##  So <A>lllout</A> can be used for <Q>incremental</Q> calls of
##  <Ref Func="LLLReducedBasis"/>.
##  <P/>
##  The function <Ref Func="LLLReducedGramMat"/>
##  computes an LLL reduced Gram matrix.
##  <P/>
##  <Example><![CDATA[
##  gap> vectors:= [ [ 9, 1, 0, -1, -1 ], [ 15, -1, 0, 0, 0 ],
##  >                [ 16, 0, 1, 1, 1 ], [ 20, 0, -1, 0, 0 ],
##  >                [ 25, 1, 1, 0, 0 ] ];;
##  gap> LLLReducedBasis( vectors, "linearcomb" );
##  rec( B := [ 5, 36/5, 12, 50/3 ],
##    basis := [ [ 1, 1, 1, 1, 1 ], [ 1, 1, -2, 1, 1 ],
##        [ -1, 3, -1, -1, -1 ], [ -3, 1, 0, 2, 2 ] ],
##    mue := [ [  ], [ 2/5 ], [ -1/5, 1/3 ], [ 2/5, 1/6, 1/6 ] ],
##    relations := [ [ -1, 0, -1, 0, 1 ] ],
##    transformation := [ [ 0, -1, 1, 0, 0 ], [ -1, -2, 0, 2, 0 ],
##        [ 1, -2, 0, 1, 0 ], [ -1, -2, 1, 1, 0 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LLLReducedBasis" );


#############################################################################
##
#F  LLLReducedGramMat( <G>[, <y>] )  . . . . . . . .  LLL reduced Gram matrix
##
##  <#GAPDoc Label="LLLReducedGramMat">
##  <ManSection>
##  <Func Name="LLLReducedGramMat" Arg='G[, y]'/>
##
##  <Description>
##  <Index Subkey="for Gram matrices">LLL algorithm</Index>
##  <Index>lattice base reduction</Index>
##  <Ref Func="LLLReducedGramMat"/> provides an implementation of the
##  <E>LLL algorithm</E> by Lenstra, Lenstra and Lovász
##  (see&nbsp;<Cite Key="LLL82"/>,&nbsp;<Cite Key="Poh87"/>).
##  The implementation follows the description in
##  <Cite Key="Coh93" Where="p. 94f."/>.
##  <P/>
##  Let <A>G</A> the Gram matrix of the vectors
##  <M>(b_1, b_2, \ldots, b_n)</M>;
##  this means <A>G</A> is either a square symmetric matrix or lower
##  triangular matrix (only the entries in the lower triangular half are used
##  by the program).
##  <P/>
##  <Ref Func="LLLReducedGramMat"/> returns a record whose component
##  <C>remainder</C> is the Gram matrix of the LLL reduced basis
##  corresponding to <M>(b_1, b_2, \ldots, b_n)</M>.
##  If <A>G</A> is a lower triangular matrix then also the <C>remainder</C>
##  component of the result record is a lower triangular matrix.
##  <P/>
##  The result record contains also the components <C>relations</C> and
##  <C>transformation</C>, which have the following meaning.
##  <P/>
##  <C>relations</C> is a basis of the space of vectors
##  <M>(x_1, x_2, \ldots, x_n)</M>
##  such that <M>\sum_{{i = 1}}^n x_i b_i</M> is zero,
##  and <C>transformation</C> gives the expression of the new lattice basis
##  in terms of the old, i.e., <C>transformation</C> is the matrix <M>T</M>
##  such that <M>T \cdot <A>G</A> \cdot T^{tr}</M> is the <C>remainder</C>
##  component of the result.
##  <P/>
##  The optional argument <A>y</A> denotes the <Q>sensitivity</Q> of the
##  algorithm, it must be a rational number between <M>1/4</M> and <M>1</M>;
##  the default value is <M><A>y</A> = 3/4</M>.
##  <P/>
##  The function <Ref Func="LLLReducedBasis"/> computes an LLL reduced basis.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= [ [ 4, 6, 5, 2, 2 ], [ 6, 13, 7, 4, 4 ],
##  >    [ 5, 7, 11, 2, 0 ], [ 2, 4, 2, 8, 4 ], [ 2, 4, 0, 4, 8 ] ];;
##  gap> LLLReducedGramMat( g );
##  rec( B := [ 4, 4, 75/16, 168/25, 32/7 ],
##    mue := [ [  ], [ 1/2 ], [ 1/4, -1/8 ], [ 1/2, 1/4, -2/25 ],
##        [ -1/4, 1/8, 37/75, 8/21 ] ], relations := [  ],
##    remainder := [ [ 4, 2, 1, 2, -1 ], [ 2, 5, 0, 2, 0 ],
##        [ 1, 0, 5, 0, 2 ], [ 2, 2, 0, 8, 2 ], [ -1, 0, 2, 2, 7 ] ],
##    transformation := [ [ 1, 0, 0, 0, 0 ], [ -1, 1, 0, 0, 0 ],
##        [ -1, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ], [ -2, 0, 1, 0, 1 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LLLReducedGramMat" );


#############################################################################
##
#F  ShortestVectors( <G>, <m>[, "positive"] )
##
##  <#GAPDoc Label="ShortestVectors">
##  <ManSection>
##  <Func Name="ShortestVectors" Arg='G, m[, "positive"]'/>
##
##  <Description>
##  Let <A>G</A> be a regular matrix of a symmetric bilinear form,
##  and <A>m</A> a nonnegative integer.
##  <Ref Func="ShortestVectors"/> computes the vectors <M>x</M> that satisfy
##  <M>x \cdot <A>G</A> \cdot x^{tr} \leq <A>m</A></M>,
##  and returns a record describing these vectors.
##  The result record has the components
##  <List>
##  <Mark><C>vectors</C></Mark>
##  <Item>
##     list of the nonzero vectors <M>x</M>, but only one of each pair
##     <M>(x,-x)</M>,
##  </Item>
##  <Mark><C>norms</C></Mark>
##  <Item>
##     list of norms of the vectors according to the Gram matrix <A>G</A>.
##  </Item>
##  </List>
##  If the optional argument <C>"positive"</C> is entered,
##  only those vectors <M>x</M> with nonnegative entries are computed.
##  <Example><![CDATA[
##  gap> g:= [ [ 2, 1, 1 ], [ 1, 2, 1 ], [ 1, 1, 2 ] ];;
##  gap> ShortestVectors(g,4);
##  rec( norms := [ 4, 2, 2, 4, 2, 4, 2, 2, 2 ],
##    vectors := [ [ -1, 1, 1 ], [ 0, 0, 1 ], [ -1, 0, 1 ], [ 1, -1, 1 ],
##        [ 0, -1, 1 ], [ -1, -1, 1 ], [ 0, 1, 0 ], [ -1, 1, 0 ],
##        [ 1, 0, 0 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ShortestVectors" );

#############################################################################
##
#F  OrthogonalEmbeddings( <gram>[, "positive"][, <maxdim>] )
##
##  <#GAPDoc Label="OrthogonalEmbeddings">
##  <ManSection>
##  <Func Name="OrthogonalEmbeddings" Arg='gram[, "positive"][, maxdim]'/>
##
##  <Description>
##  computes all possible orthogonal embeddings of a lattice given by its
##  Gram matrix <A>gram</A>, which must be a regular symmetric matrix of
##  integers.
##  In other words, all integral solutions <M>X</M> of the equation
##  <M>X^{tr} \cdot X = </M><A>gram</A>
##  are calculated.
##  The implementation follows the description in&nbsp;<Cite Key="Ple90"/>.
##  <P/>
##  Usually there are many solutions <M>X</M>
##  but all their rows belong to a small set of vectors,
##  so <Ref Func="OrthogonalEmbeddings"/> returns the solutions
##  encoded by a record with the following components.
##  <P/>
##  <List>
##  <Mark><C>vectors</C></Mark>
##  <Item>
##     the list <M>L = [ x_1, x_2, \ldots, x_n ]</M> of vectors
##     that may be rows of a solution, up to sign;
##     these are exactly the vectors with the property
##     <M>x_i \cdot </M><A>gram</A><M>^{{-1}} \cdot x_i^{tr} \leq 1</M>,
##     see&nbsp;<Ref Func="ShortestVectors"/>,
##  </Item>
##  <Mark><C>norms</C></Mark>
##  <Item>
##     the list of values
##     <M>x_i \cdot </M><A>gram</A><M>^{{-1}} \cdot x_i^{tr}</M>,
##     and
##  </Item>
##  <Mark><C>solutions</C></Mark>
##  <Item>
##     a list <M>S</M> of index lists; the <M>i</M>-th solution matrix is
##     <M>L</M><C>{ </C><M>S[i]</M><C> }</C>,
##     so the dimension of the <A>i</A>-th solution is the length of
##     <M>S[i]</M>, and we have
##     <A>gram</A><M> = \sum_{{j \in S[i]}} x_j^{tr} \cdot x_j</M>,
##  </Item>
##  </List>
##  <P/>
##  The optional argument <C>"positive"</C> will cause
##  <Ref Func="OrthogonalEmbeddings"/>
##  to compute only vectors <M>x_i</M> with nonnegative entries.
##  In the context of characters this is allowed (and useful)
##  if <A>gram</A> is the matrix of scalar products of ordinary characters.
##  <P/>
##  When <Ref Func="OrthogonalEmbeddings"/> is called with the optional
##  argument <A>maxdim</A> (a positive integer),
##  only solutions up to dimension <A>maxdim</A> are computed;
##  this may accelerate the algorithm.
##  <P/>
##  <Example><![CDATA[
##  gap> b:= [ [ 3, -1, -1 ], [ -1, 3, -1 ], [ -1, -1, 3 ] ];;
##  gap> c:=OrthogonalEmbeddings( b );
##  rec( norms := [ 1, 1, 1, 1/2, 1/2, 1/2, 1/2, 1/2, 1/2 ],
##    solutions := [ [ 1, 2, 3 ], [ 1, 6, 6, 7, 7 ], [ 2, 5, 5, 8, 8 ],
##        [ 3, 4, 4, 9, 9 ], [ 4, 5, 6, 7, 8, 9 ] ],
##    vectors := [ [ -1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ],
##        [ -1, 1, 0 ], [ -1, 0, 1 ], [ 1, 0, 0 ], [ 0, -1, 1 ],
##        [ 0, 1, 0 ], [ 0, 0, 1 ] ] )
##  gap> c.vectors{ c.solutions[1] };
##  [ [ -1, 1, 1 ], [ 1, -1, 1 ], [ -1, -1, 1 ] ]
##  ]]></Example>
##  <P/>
##  <A>gram</A> may be the matrix of scalar products of some virtual
##  characters.
##  From the characters and the embedding given by the matrix <M>X</M>,
##  <Ref Func="Decreased"/> may be able to compute irreducibles.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalEmbeddings" );


#############################################################################
##
#F  LLLint( <lat> ) . . . . . . . . . . . . . . . . . . . .  integer only LLL
##
##  <ManSection>
##  <Func Name="LLLint" Arg='lat'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LLLint" );
#T The code was converted from Maple to GAP by Alexander.
