#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Ansgar Kaup.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of functions that mainly deal with
##  lattices in the context of character tables.
##


#############################################################################
##
#F  LLL( <tbl>, <characters>[, <y>][, "sort"][, "linearcomb"] )
##
##  <#GAPDoc Label="LLL">
##  <ManSection>
##  <Func Name="LLL" Arg='tbl, characters[, y][, "sort"][, "linearcomb"]'/>
##
##  <Description>
##  <Index Subkey="for virtual characters">LLL algorithm</Index>
##  <Index>short vectors spanning a lattice</Index>
##  <Index Subkey="for virtual characters">lattice basis reduction</Index>
##  <Ref Func="LLL"/> calls the LLL algorithm
##  (see&nbsp;<Ref Func="LLLReducedBasis"/>) in the case of
##  lattices spanned by the virtual characters <A>characters</A>
##  of the ordinary character table <A>tbl</A>
##  (see&nbsp;<Ref Oper="ScalarProduct" Label="for characters"/>).
##  By finding shorter vectors in the lattice spanned by <A>characters</A>,
##  i.e., virtual characters of smaller norm,
##  in some cases <Ref Func="LLL"/> is able to find irreducible characters.
##  <P/>
##  <Ref Func="LLL"/> returns a record with at least components
##  <C>irreducibles</C> (the list of found irreducible characters),
##  <C>remainders</C> (a list of reducible virtual characters),
##  and <C>norms</C> (the list of norms of the vectors in <C>remainders</C>).
##  <C>irreducibles</C> together with <C>remainders</C> form a basis of the
##  <M>&ZZ;</M>-lattice spanned by <A>characters</A>.
##  <P/>
##  Note that the vectors in the <C>remainders</C> list are in general
##  <E>not</E> orthogonal (see&nbsp;<Ref Oper="ReducedClassFunctions"/>)
##  to the irreducible characters in <C>irreducibles</C>.
##  <P/>
##  Optional arguments of <Ref Func="LLL"/> are
##  <P/>
##  <List>
##  <Mark><A>y</A></Mark>
##  <Item>
##      controls the sensitivity of the algorithm,
##      see&nbsp;<Ref Func="LLLReducedBasis"/>,
##  </Item>
##  <Mark><A>"sort"</A></Mark>
##  <Item>
##      <Ref Func="LLL"/> sorts <A>characters</A> and the <C>remainders</C>
##      component of the result according to the degrees,
##  </Item>
##  <Mark><A>"linearcomb"</A></Mark>
##  <Item>
##      the returned record contains components <C>irreddecomp</C>
##      and <C>reddecomp</C>, which are decomposition matrices of
##      <C>irreducibles</C> and <C>remainders</C>,
##      with respect to <A>characters</A>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> chars:= [ [ 8, 0, 0, -1, 0 ], [ 6, 0, 2, 0, 2 ],
##  >     [ 12, 0, -4, 0, 0 ], [ 6, 0, -2, 0, 0 ], [ 24, 0, 0, 0, 0 ],
##  >     [ 12, 0, 4, 0, 0 ], [ 6, 0, 2, 0, -2 ], [ 12, -2, 0, 0, 0 ],
##  >     [ 8, 0, 0, 2, 0 ], [ 12, 2, 0, 0, 0 ], [ 1, 1, 1, 1, 1 ] ];;
##  gap> LLL( s4, chars );
##  rec(
##    irreducibles :=
##      [ Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, -1, 0 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, 1, 1, 1, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, 1, -1, 0, -1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, -1, -1, 0, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, -1, 1, 1, -1 ] ) ],
##    norms := [  ], remainders := [  ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LLL" );


#############################################################################
##
#F  Extract( <tbl>, <reducibles>, <grammat>[, <missing> ] )
##
##  <#GAPDoc Label="Extract">
##  <ManSection>
##  <Func Name="Extract" Arg='tbl, reducibles, grammat[, missing ]'/>
##
##  <Description>
##  Let <A>tbl</A> be an ordinary character table,
##  <A>reducibles</A> a list of characters of <A>tbl</A>,
##  and <A>grammat</A> the matrix of scalar products of <A>reducibles</A>
##  (see&nbsp;<Ref Oper="MatScalarProducts"/>).
##  <Ref Func="Extract"/> tries to find irreducible characters by drawing
##  conclusions out of the scalar products,
##  using combinatorial and backtrack means.
##  <P/>
##  The optional argument <A>missing</A> is the maximal number of irreducible
##  characters that occur as constituents of <A>reducibles</A>.
##  Specification of <A>missing</A> may accelerate <Ref Func="Extract"/>.
##  <P/>
##  <Ref Func="Extract"/> returns a record <A>ext</A> with the components
##  <C>solution</C> and <C>choice</C>,
##  where the value of <C>solution</C> is a list <M>[ M_1, \ldots, M_n ]</M>
##  of decomposition matrices <M>M_i</M> (up to permutations of rows)
##  with the property that <M>M_i^{tr} \cdot X</M> is equal to
##  the sublist at the positions <A>ext</A><C>.choice[i]</C> of
##  <A>reducibles</A>,
##  for a matrix <M>X</M> of irreducible characters;
##  the value of <C>choice</C> is a list of length <M>n</M> whose entries are
##  lists of indices.
##  <P/>
##  So the <M>j</M>-th column in each matrix <M>M_i</M> corresponds to
##  <M><A>reducibles</A>[j]</M>, and each row in <M>M_i</M> corresponds to an
##  irreducible character.
##  <Ref Func="Decreased"/> can be used to examine the solution for
##  computable irreducibles.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> red:= [ [ 5, 1, 5, 2, 1 ], [ 2, 0, 2, 2, 0 ], [ 3, -1, 3, 0, -1 ],
##  >            [ 6, 0, -2, 0, 0 ], [ 4, 0, 0, 1, 2 ] ];;
##  gap> gram:= MatScalarProducts( s4, red, red );
##  [ [ 6, 3, 2, 0, 2 ], [ 3, 2, 1, 0, 1 ], [ 2, 1, 2, 0, 0 ],
##    [ 0, 0, 0, 2, 1 ], [ 2, 1, 0, 1, 2 ] ]
##  gap> ext:= Extract( s4, red, gram, 5 );
##  rec( choice := [ [ 2, 5, 3, 4, 1 ] ],
##    solution :=
##      [
##        [ [ 1, 1, 0, 0, 2 ], [ 1, 0, 1, 0, 1 ], [ 0, 1, 0, 1, 0 ],
##            [ 0, 0, 1, 0, 1 ], [ 0, 0, 0, 1, 0 ] ] ] )
##  gap> dec:= Decreased( s4, red, ext.solution[1], ext.choice[1] );
##  rec(
##    irreducibles :=
##      [ Character( CharacterTable( "Sym(4)" ), [ 1, 1, 1, 1, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, -1, -1, 0, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, -1, 1, 1, -1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, 1, -1, 0, -1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, -1, 0 ] ) ],
##    matrix := [  ], remainders := [  ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Extract" );


#############################################################################
##
#F  OrthogonalEmbeddingsSpecialDimension( <tbl>, <reducibles>, <grammat>,
#F                                                   ["positive",] <dim> )
##
##  <#GAPDoc Label="OrthogonalEmbeddingsSpecialDimension">
##  <ManSection>
##  <Func Name="OrthogonalEmbeddingsSpecialDimension"
##  Arg='tbl, reducibles, grammat[, "positive"], dim'/>
##
##  <Description>
##  <Ref Func="OrthogonalEmbeddingsSpecialDimension"/> is a variant of
##  <Ref Func="OrthogonalEmbeddings"/> for the situation
##  that <A>tbl</A> is an ordinary character table,
##  <A>reducibles</A> is a list of virtual characters of <A>tbl</A>,
##  <A>grammat</A> is the matrix of scalar products
##  (see&nbsp;<Ref Oper="MatScalarProducts"/>),
##  and <A>dim</A> is an upper bound for the number of irreducible characters
##  of <A>tbl</A> that occur as constituents of <A>reducibles</A>;
##  if the vectors in <A>reducibles</A> are known to be proper characters then
##  the string <C>"positive"</C> may be entered as fourth argument.
##  (See&nbsp;<Ref Func="OrthogonalEmbeddings"/> for information why this may
##  help.)
##  <P/>
##  <Ref Func="OrthogonalEmbeddingsSpecialDimension"/> first uses
##  <Ref Func="OrthogonalEmbeddings"/> to compute all orthogonal embeddings
##  of <A>grammat</A> into a standard lattice of dimension up to <A>dim</A>,
##  and then calls <Ref Func="Decreased"/> in order to find irreducible
##  characters of <A>tbl</A>.
##  <P/>
##  <Ref Func="OrthogonalEmbeddingsSpecialDimension"/> returns a record with
##  the following components.
##  <P/>
##  <List>
##  <Mark><C>irreducibles</C></Mark>
##  <Item>
##    a list of found irreducibles, the intersection of all lists of
##    irreducibles found by <Ref Func="Decreased"/>,
##    for all possible embeddings, and
##  </Item>
##  <Mark><C>remainders</C></Mark>
##  <Item>
##    a list of remaining reducible virtual characters.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> s6:= CharacterTable( "S6" );;
##  gap> red:= InducedCyclic( s6, "all" );;
##  gap> Add( red, TrivialCharacter( s6 ) );
##  gap> lll:= LLL( s6, red );;
##  gap> irred:= lll.irreducibles;
##  [ Character( CharacterTable( "A6.2_1" ),
##      [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( "A6.2_1" ),
##      [ 9, 1, 0, 0, 1, -1, -3, -3, 1, 0, 0 ] ),
##    Character( CharacterTable( "A6.2_1" ),
##      [ 16, 0, -2, -2, 0, 1, 0, 0, 0, 0, 0 ] ) ]
##  gap> Set( Flat( MatScalarProducts( s6, irred, lll.remainders ) ) );
##  [ 0 ]
##  gap> dim:= NrConjugacyClasses( s6 ) - Length( lll.irreducibles );
##  8
##  gap> rem:= lll.remainders;;  Length( rem );
##  8
##  gap> gram:= MatScalarProducts( s6, rem, rem );;  RankMat( gram );
##  8
##  gap> emb1:= OrthogonalEmbeddings( gram, 8 );
##  rec( norms := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
##    solutions := [ [ 1, 2, 3, 7, 11, 12, 13, 15 ],
##        [ 1, 2, 4, 8, 10, 12, 13, 14 ], [ 1, 2, 5, 6, 9, 12, 13, 16 ] ],
##    vectors :=
##      [ [ -1, 0, 1, 0, 1, 0, 1, 0 ], [ 1, 0, 0, 1, 0, 1, 0, 0 ],
##        [ 0, 1, 1, 0, 0, 0, 1, 1 ], [ 0, 1, 1, 0, 0, 0, 1, 0 ],
##        [ 0, 1, 1, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 1, 0 ],
##        [ 0, -1, 0, 0, 0, 0, 0, 1 ], [ 0, 1, 0, 0, 0, 0, 0, 0 ],
##        [ 0, 0, 1, 0, 0, 0, 1, 1 ], [ 0, 0, 1, 0, 0, 0, 0, 1 ],
##        [ 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, -1, 1, 0, 0, 0 ],
##        [ 0, 0, 0, 0, 0, 1, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1, 1 ],
##        [ 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 1 ] ] )
##  gap> emb2:= OrthogonalEmbeddingsSpecialDimension( s6, rem, gram, 8 );
##  rec(
##    irreducibles :=
##      [ Character( CharacterTable( "A6.2_1" ),
##          [ 5, 1, -1, 2, -1, 0, 1, -3, -1, 1, 0 ] ),
##        Character( CharacterTable( "A6.2_1" ),
##          [ 5, 1, 2, -1, -1, 0, -3, 1, -1, 0, 1 ] ),
##        Character( CharacterTable( "A6.2_1" ),
##          [ 10, -2, 1, 1, 0, 0, -2, 2, 0, 1, -1 ] ),
##        Character( CharacterTable( "A6.2_1" ),
##          [ 10, -2, 1, 1, 0, 0, 2, -2, 0, -1, 1 ] ) ],
##    remainders :=
##      [ VirtualCharacter( CharacterTable( "A6.2_1" ),
##          [ 0, 0, 3, -3, 0, 0, 4, -4, 0, 1, -1 ] ),
##        VirtualCharacter( CharacterTable( "A6.2_1" ),
##          [ 6, 2, 3, 0, 0, 1, 2, -2, 0, -1, -2 ] ),
##        VirtualCharacter( CharacterTable( "A6.2_1" ),
##          [ 10, 2, 1, 1, 2, 0, 2, 2, -2, -1, -1 ] ),
##        VirtualCharacter( CharacterTable( "A6.2_1" ),
##          [ 14, 2, 2, -1, 0, -1, 6, 2, 0, 0, -1 ] ) ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OrthogonalEmbeddingsSpecialDimension" );


#############################################################################
##
#F  Decreased( <tbl>, <chars>, <decompmat>[, <choice>] )
##
##  <#GAPDoc Label="Decreased">
##  <ManSection>
##  <Func Name="Decreased" Arg='tbl, chars, decompmat[, choice]'/>
##
##  <Description>
##  Let <A>tbl</A> be an ordinary character table,
##  <A>chars</A> a list of virtual characters of <A>tbl</A>,
##  and <A>decompmat</A> a decomposition matrix, that is,
##  a matrix <M>M</M> with the property that
##  <M>M^{tr} \cdot X = <A>chars</A></M> holds,
##  where <M>X</M> is a list of irreducible characters of <A>tbl</A>.
##  <Ref Func="Decreased"/> tries to compute the irreducibles in <M>X</M> or
##  at least some of them.
##  <P/>
##  Usually <Ref Func="Decreased"/> is applied to the output of
##  <Ref Func="Extract"/> or <Ref Func="OrthogonalEmbeddings"/> or
##  <Ref Func="OrthogonalEmbeddingsSpecialDimension"/>.
##  In the case of <Ref Func="Extract"/>,
##  the choice component corresponding to the decomposition matrix must be
##  entered as argument <A>choice</A> of <Ref Func="Decreased"/>.
##  <P/>
##  <Ref Func="Decreased"/> returns <K>fail</K> if it can prove that no list
##  <M>X</M> of irreducible characters corresponding to the arguments exists;
##  otherwise <Ref Func="Decreased"/> returns a record with the following
##  components.
##  <P/>
##  <List>
##  <Mark><C>irreducibles</C></Mark>
##  <Item>
##      the list of found irreducible characters,
##  </Item>
##  <Mark><C>remainders</C></Mark>
##  <Item>
##      the remaining reducible characters, and
##  </Item>
##  <Mark><C>matrix</C></Mark>
##  <Item>
##      the decomposition matrix of the characters in the <C>remainders</C>
##      component.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> x:= Irr( s4 );;
##  gap> red:= [ x[1]+x[2], -x[1]-x[3], -x[1]+x[3], -x[2]-x[4] ];;
##  gap> mat:= MatScalarProducts( s4, red, red );
##  [ [ 2, -1, -1, -1 ], [ -1, 2, 0, 0 ], [ -1, 0, 2, 0 ],
##    [ -1, 0, 0, 2 ] ]
##  gap> emb:= OrthogonalEmbeddings( mat );
##  rec( norms := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
##    solutions := [ [ 1, 6, 7, 12 ], [ 2, 5, 8, 11 ], [ 3, 4, 9, 10 ] ],
##    vectors := [ [ -1, 1, 1, 0 ], [ -1, 1, 0, 1 ], [ 1, -1, 0, 0 ],
##        [ -1, 0, 1, 1 ], [ -1, 0, 1, 0 ], [ -1, 0, 0, 1 ],
##        [ 0, -1, 1, 0 ], [ 0, -1, 0, 1 ], [ 0, 1, 0, 0 ],
##        [ 0, 0, -1, 1 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ] )
##  gap> dec:= Decreased( s4, red, emb.vectors{ emb.solutions[1] } );
##  rec(
##    irreducibles :=
##      [ Character( CharacterTable( "Sym(4)" ), [ 3, -1, -1, 0, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, -1, 1, 1, -1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, -1, 0 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, 1, -1, 0, -1 ] ) ],
##    matrix := [  ], remainders := [  ] )
##  gap> Decreased( s4, red, emb.vectors{ emb.solutions[2] } );
##  fail
##  gap> Decreased( s4, red, emb.vectors{ emb.solutions[3] } );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Decreased" );


#############################################################################
##
#F  DnLattice( <tbl>, <grammat>, <reducibles> )
##
##  <#GAPDoc Label="DnLattice">
##  <ManSection>
##  <Func Name="DnLattice" Arg='tbl, grammat, reducibles'/>
##
##  <Description>
##  Let <A>tbl</A> be an ordinary character table,
##  and <A>reducibles</A> a list of virtual characters of <A>tbl</A>.
##  <P/>
##  <Ref Func="DnLattice"/> searches for sublattices isomorphic to root
##  lattices of type <M>D_n</M>, for <M>n \geq 4</M>,
##  in the lattice that is generated by <A>reducibles</A>;
##  each vector in <A>reducibles</A> must have norm <M>2</M>, and the matrix
##  of scalar products (see&nbsp;<Ref Oper="MatScalarProducts"/>) of
##  <A>reducibles</A> must be entered as argument <A>grammat</A>.
##  <P/>
##  <Ref Func="DnLattice"/> is able to find irreducible characters if there
##  is a lattice of type <M>D_n</M> with <M>n > 4</M>.
##  In the case <M>n = 4</M>, <Ref Func="DnLattice"/> may fail to determine
##  irreducibles.
##  <P/>
##  <Ref Func="DnLattice"/> returns a record with components
##  <List>
##  <Mark><C>irreducibles</C></Mark>
##  <Item>
##      the list of found irreducible characters,
##  </Item>
##  <Mark><C>remainders</C></Mark>
##  <Item>
##      the list of remaining reducible virtual characters, and
##  </Item>
##  <Mark><C>gram</C></Mark>
##  <Item>
##      the Gram matrix of the vectors in <C>remainders</C>.
##  </Item>
##  </List>
##  <P/>
##  The <C>remainders</C> list is transformed in such a way that the
##  <C>gram</C> matrix is a block diagonal matrix that exhibits the structure
##  of the lattice generated by the vectors in <C>remainders</C>.
##  So <Ref Func="DnLattice"/> might be useful even if it fails to find
##  irreducible characters.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> red:= [ [ 2, 0, 2, 2, 0 ], [ 4, 0, 0, 1, 2 ],
##  >            [ 5, -1, 1, -1, 1 ], [ -1, 1, 3, -1, -1 ] ];;
##  gap> gram:= MatScalarProducts( s4, red, red );
##  [ [ 2, 1, 0, 0 ], [ 1, 2, 1, -1 ], [ 0, 1, 2, 0 ], [ 0, -1, 0, 2 ] ]
##  gap> dn:= DnLattice( s4, gram, red );
##  rec( gram := [  ],
##    irreducibles :=
##      [ Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, -1, 0 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, -1, 1, 1, -1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, 1, 1, 1, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, -1, -1, 0, 1 ] ) ],
##    remainders := [  ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DnLattice" );


#############################################################################
##
#F  DnLatticeIterative( <tbl>, <reducibles> )
##
##  <#GAPDoc Label="DnLatticeIterative">
##  <ManSection>
##  <Func Name="DnLatticeIterative" Arg='tbl, reducibles'/>
##
##  <Description>
##  Let <A>tbl</A> be an ordinary character table,
##  and <A>reducibles</A> either a list of virtual characters of <A>tbl</A>
##  or a record with components <C>remainders</C> and <C>norms</C>,
##  for example a record returned by <Ref Func="LLL"/>.
##  <P/>
##  <Ref Func="DnLatticeIterative"/> was designed for iterative use of
##  <Ref Func="DnLattice"/>.
##  <Ref Func="DnLatticeIterative"/> selects the vectors of norm <M>2</M>
##  among the given virtual character, calls <Ref Func="DnLattice"/> for
##  them, reduces the virtual characters with found irreducibles,
##  calls <Ref Func="DnLattice"/> again for the remaining virtual characters,
##  and so on, until no new irreducibles are found.
##  <P/>
##  <Ref Func="DnLatticeIterative"/> returns a record with the same
##  components and meaning of components as <Ref Func="LLL"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> red:= [ [ 2, 0, 2, 2, 0 ], [ 4, 0, 0, 1, 2 ],
##  >            [ 5, -1, 1, -1, 1 ], [ -1, 1, 3, -1, -1 ] ];;
##  gap> dn:= DnLatticeIterative( s4, red );
##  rec(
##    irreducibles :=
##      [ Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, -1, 0 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, -1, 1, 1, -1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 1, 1, 1, 1, 1 ] ),
##        Character( CharacterTable( "Sym(4)" ), [ 3, -1, -1, 0, 1 ] ) ],
##    norms := [  ], remainders := [  ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DnLatticeIterative" );
