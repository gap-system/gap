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
##  This file contains the declaration of operations to calculate
##  automorphisms of matrices,
#T better in `matrix.gd'?
##  e.g., the character matrices of character tables,
##  and functions to calculate permutations transforming the rows of a matrix
##  to the rows of another matrix.
##


#############################################################################
##
#F  FamiliesOfRows( <mat>, <maps> )
##
##  <#GAPDoc Label="FamiliesOfRows">
##  <ManSection>
##  <Func Name="FamiliesOfRows" Arg='mat, maps'/>
##
##  <Description>
##  distributes the rows of the matrix <A>mat</A> into families, as follows.
##  Two rows of <A>mat</A> belong to the same family if there is
##  a permutation of columns that maps one row to the other row.
##  Each entry in the list <A>maps</A> is regarded to form a family
##  of length 1.
##  <P/>
##  <Ref Func="FamiliesOfRows"/> returns a record with the components
##  <List>
##  <Mark><C>famreps</C></Mark>
##  <Item>
##     the list of representatives for each family,
##  </Item>
##  <Mark><C>permutations</C></Mark>
##  <Item>
##     the list that contains at position <M>i</M> a list of permutations
##     that map the members of the family with representative
##     <C>famreps</C><M>[i]</M> to that representative,
##  </Item>
##  <Mark><C>families</C></Mark>
##  <Item>
##     the list that contains at position <M>i</M> the list of positions
##     of members of the family of representative <C>famreps</C><M>[i]</M>;
##     (for the element <A>maps</A><M>[i]</M> the only member of the family
##     will get the number <C>Length( <A>mat</A> ) + </C><M>i</M>).
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FamiliesOfRows" );


#############################################################################
##
#O  MatrixAutomorphisms( <mat>[, <maps>, <subgroup>] )
##
##  <#GAPDoc Label="MatrixAutomorphisms">
##  <ManSection>
##  <Oper Name="MatrixAutomorphisms" Arg='mat[, maps, subgroup]'/>
##
##  <Description>
##  For a matrix <A>mat</A>,
##  <Ref Oper="MatrixAutomorphisms"/> returns the group of those
##  permutations of the columns of <A>mat</A> that leave the set of rows of
##  <A>mat</A> invariant.
##  <P/>
##  If the arguments <A>maps</A> and <A>subgroup</A> are given,
##  only the group of those permutations is constructed that additionally
##  fix each list in the list <A>maps</A> under pointwise action
##  <Ref Func="OnTuples"/>,
##  and <A>subgroup</A> is a permutation group that is known to be a subgroup
##  of this group of automorphisms.
##  <P/>
##  Each entry in <A>maps</A> must be a list of same length as the rows of
##  <A>mat</A>.
##  For example, if <A>mat</A> is a list of irreducible characters of a group
##  then the list of element orders of the conjugacy classes
##  (see&nbsp;<Ref Attr="OrdersClassRepresentatives"/>) may be an entry in
##  <A>maps</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MatrixAutomorphisms", [ IsMatrix ] );
DeclareOperation( "MatrixAutomorphisms", [ IsMatrix, IsList, IsPermGroup ] );


#############################################################################
##
#O  TableAutomorphisms( <tbl>, <characters>[, <info>] )
##
##  <#GAPDoc Label="TableAutomorphisms">
##  <ManSection>
##  <Oper Name="TableAutomorphisms" Arg='tbl, characters[, info]'/>
##
##  <Description>
##  <Ref Oper="TableAutomorphisms"/> returns the permutation group of those
##  matrix automorphisms (see&nbsp;<Ref Oper="MatrixAutomorphisms"/>) of the
##  list <A>characters</A> that leave the element orders
##  (see&nbsp;<Ref Attr="OrdersClassRepresentatives"/>)
##  and all stored power maps (see&nbsp;<Ref Attr="ComputedPowerMaps"/>)
##  of the character table <A>tbl</A> invariant.
##  <P/>
##  If <A>characters</A> is closed under Galois conjugacy
##  &ndash;this is always fulfilled for the list of all irreducible
##  characters of ordinary character tables&ndash; the string <C>"closed"</C>
##  may be entered as the third argument <A>info</A>.
##  Alternatively, a known subgroup of the table automorphisms
##  can be entered as the third argument <A>info</A>.
##  <P/>
##  The attribute <Ref Attr="AutomorphismsOfTable"/>
##  can be used to compute and store the table automorphisms for the case
##  that <A>characters</A> equals the
##  <Ref Attr="Irr" Label="for a character table"/> value of <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbld8:= CharacterTable( "Dihedral", 8 );;
##  gap> irrd8:= Irr( tbld8 );
##  [ Character( CharacterTable( "Dihedral(8)" ), [ 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( "Dihedral(8)" ), [ 1, 1, 1, -1, -1 ] ),
##    Character( CharacterTable( "Dihedral(8)" ), [ 1, -1, 1, 1, -1 ] ),
##    Character( CharacterTable( "Dihedral(8)" ), [ 1, -1, 1, -1, 1 ] ),
##    Character( CharacterTable( "Dihedral(8)" ), [ 2, 0, -2, 0, 0 ] ) ]
##  gap> orders:= OrdersClassRepresentatives( tbld8 );
##  [ 1, 4, 2, 2, 2 ]
##  gap> MatrixAutomorphisms( irrd8 );
##  Group([ (4,5), (2,4) ])
##  gap> MatrixAutomorphisms( irrd8, [ orders ], Group( () ) );
##  Group([ (4,5) ])
##  gap> TableAutomorphisms( tbld8, irrd8 );
##  Group([ (4,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TableAutomorphisms",
    [ IsNearlyCharacterTable, IsList ] );
DeclareOperation( "TableAutomorphisms",
    [ IsNearlyCharacterTable, IsList, IsString ] );
DeclareOperation( "TableAutomorphisms",
    [ IsNearlyCharacterTable, IsList, IsPermGroup ] );
#T use `AutomorphismsOfTable' for that
#T (the distinction stems from the times where attributes were not allowed
#T to have non-unary methods!)


#############################################################################
##
#O  TransformingPermutations( <mat1>, <mat2> )
##
##  <#GAPDoc Label="TransformingPermutations">
##  <ManSection>
##  <Oper Name="TransformingPermutations" Arg='mat1, mat2'/>
##
##  <Description>
##  Let <A>mat1</A> and <A>mat2</A> be matrices.
##  <Ref Oper="TransformingPermutations"/> tries to construct
##  a permutation <M>\pi</M> that transforms the set of rows of the matrix
##  <A>mat1</A> to the set of rows of the matrix <A>mat2</A>
##  by permuting the columns.
##  <P/>
##  If such a permutation exists,
##  a record with the components <C>columns</C>, <C>rows</C>,
##  and <C>group</C> is returned, otherwise <K>fail</K>.
##  For <C>TransformingPermutations( <A>mat1</A>, <A>mat2</A> )
##  = <A>r</A></C> <M>\neq</M> <K>fail</K>,
##  we have <C><A>mat2</A> =
##   Permuted( List( <A>mat1</A>, x -&gt; Permuted( x, <A>r</A>.columns ) ),
##  <A>r</A>.rows )</C>.
##  <P/>
##  <A>r</A><C>.group</C> is the group of matrix automorphisms of <A>mat2</A>
##  (see&nbsp;<Ref Oper="MatrixAutomorphisms"/>).
##  This group stabilizes the transformation in the sense that applying any
##  of its elements to the columns of <A>mat2</A>
##  preserves the set of rows of <A>mat2</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TransformingPermutations", [ IsMatrix, IsMatrix ] );


#############################################################################
##
#O  TransformingPermutationsCharacterTables( <tbl1>, <tbl2> )
##
##  <#GAPDoc Label="TransformingPermutationsCharacterTables">
##  <ManSection>
##  <Oper Name="TransformingPermutationsCharacterTables" Arg='tbl1, tbl2'/>
##
##  <Description>
##  Let <A>tbl1</A> and <A>tbl2</A> be character tables.
##  <Ref Oper="TransformingPermutationsCharacterTables"/> tries to construct
##  a permutation <M>\pi</M> that transforms the set of rows of the matrix
##  <C>Irr( <A>tbl1</A> )</C> to the set of rows of the matrix
##  <C>Irr( <A>tbl2</A> )</C> by permuting the columns
##  (see&nbsp;<Ref Oper="TransformingPermutations"/>), such that
##  <M>\pi</M> transforms also the power maps and the element orders.
##  <P/>
##  If such a permutation <M>\pi</M> exists then a record with the components
##  <C>columns</C> (<M>\pi</M>),
##  <C>rows</C> (the permutation of <C>Irr( <A>tbl1</A> )</C> corresponding
##  to <M>\pi</M>), and <C>group</C> (the permutation group of table
##  automorphisms of <A>tbl2</A>,
##  see&nbsp;<Ref Attr="AutomorphismsOfTable"/>) is returned.
##  If no such permutation exists, <K>fail</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> tblq8:= CharacterTable( "Quaternionic", 8 );;
##  gap> irrq8:= Irr( tblq8 );
##  [ Character( CharacterTable( "Q8" ), [ 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( "Q8" ), [ 1, 1, 1, -1, -1 ] ),
##    Character( CharacterTable( "Q8" ), [ 1, -1, 1, 1, -1 ] ),
##    Character( CharacterTable( "Q8" ), [ 1, -1, 1, -1, 1 ] ),
##    Character( CharacterTable( "Q8" ), [ 2, 0, -2, 0, 0 ] ) ]
##  gap> OrdersClassRepresentatives( tblq8 );
##  [ 1, 4, 2, 4, 4 ]
##  gap> TransformingPermutations( irrd8, irrq8 );
##  rec( columns := (), group := Group([ (4,5), (2,4) ]), rows := () )
##  gap> TransformingPermutationsCharacterTables( tbld8, tblq8 );
##  fail
##  gap> tbld6:= CharacterTable( "Dihedral", 6 );;
##  gap> tbls3:= CharacterTable( "Symmetric", 3 );;
##  gap> TransformingPermutationsCharacterTables( tbld6, tbls3 );
##  rec( columns := (2,3), group := Group(()), rows := (1,3,2) )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TransformingPermutationsCharacterTables",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
