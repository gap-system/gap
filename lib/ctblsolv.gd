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
##  This file contains the declaration of operations for computing
##  characters of solvable groups.
##


#############################################################################
##
#V  BaumClausenInfoDebug  . . . . . . . . . . . . . . testing BaumClausenInfo
##
##  <ManSection>
##  <Var Name="BaumClausenInfoDebug"/>
##
##  <Description>
##  This global record contains functions used for testing intermediate
##  results in <C>BaumClausenInfo</C> computations;
##  they are called only inside <C>Assert</C> statements.
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "BaumClausenInfoDebug" );


#############################################################################
##
#A  BaumClausenInfo( <G> )  . . . . .  info about irreducible representations
##
##  <ManSection>
##  <Attr Name="BaumClausenInfo" Arg='G'/>
##
##  <Description>
##  Called with a group <A>G</A>, <Ref Func="BaumClausenInfo"/> returns
##  a record with the following components.
##  <P/>
##  <List>
##  <Mark><C>pcgs</C></Mark>
##  <Item>
##       each representation is encoded as a list, the entries encode images
##       of the elements in <C>pcgs</C>,
##  </Item>
##  <Mark><C>kernel</C></Mark>
##  <Item>
##       the normal subgroup such that the result describes the irreducible
##       representations of the corresponding factor group only
##       (so <E>all</E> irreducible nonlinear representations are described
##       if and only if this subgroup is trivial),
##  </Item>
##  <Mark><C>exponent</C></Mark>
##  <Item>
##       the roots of unity in the representations are encoded as exponents
##       of a primitive <C>exponent</C>-th root,
##  </Item>
##  <Mark><C>lin</C></Mark>
##  <Item>
##       the list that encodes all linear representations of <A>G</A>,
##       each representation is encoded as a list of exponents,
##  </Item>
##  <Mark><C>nonlin</C></Mark>
##  <Item>
##       a list of nonlinear irreducible representations,
##       each a list of monomial matrices.
##  </Item>
##  </List>
##  <P/>
##  Monomial matrices are encoded as records with components
##  <C>perm</C> (the permutation part) and <C>diag</C> (the nonzero entries).
##  E. g., the matrix <C>rec( perm := [ 3, 1, 2 ], diag := [ 1, 2, 3 ] )</C>
##  stands for
##  [ .  .  1 ]     [ e^1   .    .  ]   [  .    .   e^3 ]
##  [ 1  .  . ]  *  [  .   e^2   .  ] = [ e^1   .    .  ] ,
##  [ .  1  . ]     [  .    .   e^3 ]   [  .   e^2   .  ]
##  where <C>e</C> is the value of <C>exponent</C> in the result record.
##  <P/>
##  The algorithm of Baum and Clausen guarantees to compute all
##  irreducible representations for abelian by supersolvable groups;
##  if the supersolvable residuum of <A>G</A> is not abelian then this
##  implementation computes the irreducible representations of the factor
##  group of <A>G</A> by the derived subgroup of the supersolvable residuum.
##  <P/>
##  For this purpose, a composition series
##  <M>\langle \rangle &lt; G_{lg} &lt; G_{lg-1} &lt; \ldots &lt; G_1 = <A>G</A></M>
##  of <A>G</A> is used,
##  where the maximal abelian and all nonabelian composition subgroups are
##  normal in <A>G</A>.
##  Iteratively the representations of <M>G_i</M> are constructed from those of
##  <M>G_{{i+1}}</M>.
##  <P/>
##  Let <M>[ g_1, g_2, \ldots, g_{lg} ]</M> be a pcgs of <A>G</A>, and
##  <M>G_i = \langle G_{i+1}, g_i \rangle</M>.
##  The list <C>indices</C> holds the sizes of the composition factors,
##  i.e., <C>indices[i]</C><M> = [ G_i \colon G_{i+1} ]</M>.
##  <P/>
##  The iteration is an application of the theorem of Clifford.
##  An irreducible representation of <M>G_{i+1}</M> has either
##  <M>p = [ G_i \colon G_{i+1} ]</M> extensions to <M>G_i</M>,
##  or the induced representation is irreducible in <M>G_i</M>.
##  <P/>
##  In the case of extensions, a representing matrix for the canonical
##  generator <M>g_i</M> is constructed.
##  The induction can be performed directly, afterwards the induced
##  representation is modified such that the restriction to <M>G_{i+1}</M>
##  decomposes into the direct sum of its constituents as block diagonal
##  decomposition, and the matrix for <M>g_i</M> is constructed.
##  <P/>
##  So the construction guarantees that the restriction of a
##  representation of <M>G_i</M> to <M>G_{i+1}</M> decomposes (physically)
##  into a direct sum of irreducible representations of <M>G_{i+1}</M>.
##  Moreover, two constituents are equivalent if and only if they are equal.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "BaumClausenInfo", IsGroup );


#############################################################################
##
#A  IrreducibleRepresentations( <G>[, <F>] )
##
##  <#GAPDoc Label="IrreducibleRepresentations">
##  <ManSection>
##  <Attr Name="IrreducibleRepresentations" Arg='G[, F]'/>
##
##  <Description>
##  Called with a finite group <A>G</A> and a field <A>F</A>,
##  <Ref Attr="IrreducibleRepresentations"/> returns a list of
##  representatives of the irreducible matrix representations of <A>G</A>
##  over <A>F</A>, up to equivalence.
##  <P/>
##  If <A>G</A> is the only argument then
##  <Ref Attr="IrreducibleRepresentations"/> returns a list of
##  representatives of the absolutely irreducible complex representations
##  of <A>G</A>, up to equivalence.
##  <P/>
##  At the moment, methods are available for the following cases:
##  If <A>G</A> is abelian by supersolvable the method
##  of&nbsp;<Cite Key="BC94"/> is used.
##  <P/>
##  Otherwise, if <A>F</A> and <A>G</A> are both finite,
##  the regular module of <A>G</A> is split by MeatAxe methods which can make
##  this an expensive operation.
##  <P/>
##  Finally, if <A>F</A> is not given (i.e. it defaults to the cyclotomic
##  numbers) and <A>G</A> is a finite group,
##  the method of <Cite Key="Dix93"/>
##  (see <Ref Func="IrreducibleRepresentationsDixon"/>) is used.
##  <P/>
##  For other cases no methods are implemented yet.
##  <P/>
##  The representations obtained are <E>not</E> guaranteed to be <Q>nice</Q>
##  (for example preserving a unitary form) in any way.
##  <P/>
##  See also <Ref Oper="IrreducibleModules"/>,
##  which provides efficient methods for solvable groups.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= AlternatingGroup( 4 );;
##  gap> repr:= IrreducibleRepresentations( g );
##  [ Pcgs([ (2,4,3), (1,3)(2,4), (1,2)(3,4) ]) ->
##      [ [ [ 1 ] ], [ [ 1 ] ], [ [ 1 ] ] ],
##    Pcgs([ (2,4,3), (1,3)(2,4), (1,2)(3,4) ]) ->
##      [ [ [ E(3) ] ], [ [ 1 ] ], [ [ 1 ] ] ],
##    Pcgs([ (2,4,3), (1,3)(2,4), (1,2)(3,4) ]) ->
##      [ [ [ E(3)^2 ] ], [ [ 1 ] ], [ [ 1 ] ] ],
##    Pcgs([ (2,4,3), (1,3)(2,4), (1,2)(3,4) ]) ->
##      [ [ [ 0, 0, 1 ], [ 1, 0, 0 ], [ 0, 1, 0 ] ],
##        [ [ -1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, -1 ] ],
##        [ [ 1, 0, 0 ], [ 0, -1, 0 ], [ 0, 0, -1 ] ] ] ]
##  gap> ForAll( repr, IsGroupHomomorphism );
##  true
##  gap> Length( repr );
##  4
##  gap> gens:= GeneratorsOfGroup( g );
##  [ (1,2,3), (2,3,4) ]
##  gap> List( gens, x -> x^repr[1] );
##  [ [ [ 1 ] ], [ [ 1 ] ] ]
##  gap>  List( gens, x -> x^repr[4] );
##  [ [ [ 0, 0, -1 ], [ 1, 0, 0 ], [ 0, -1, 0 ] ],
##    [ [ 0, 1, 0 ], [ 0, 0, 1 ], [ 1, 0, 0 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IrreducibleRepresentations", IsGroup and IsFinite );
DeclareOperation( "IrreducibleRepresentations",
    [ IsGroup and IsFinite, IsField ] );


#############################################################################
##
#A  IrrBaumClausen( <G> ) . . . .  irred. characters of a supersolvable group
##
##  <#GAPDoc Label="IrrBaumClausen">
##  <ManSection>
##  <Attr Name="IrrBaumClausen" Arg='G'/>
##
##  <Description>
##  <Ref Attr="IrrBaumClausen"/> returns the absolutely irreducible ordinary
##  characters of the factor group of the finite solvable group <A>G</A>
##  by the derived subgroup of its supersolvable residuum.
##  <P/>
##  The characters are computed using the algorithm by Baum and Clausen
##  (see&nbsp;<Cite Key="BC94"/>).
##  An error is signalled if <A>G</A> is not solvable.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SL(2,3);;
##  gap> irr1:= IrrDixonSchneider( g );
##  [ Character( CharacterTable( SL(2,3) ), [ 1, 1, 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 1, E(3)^2, E(3), 1, E(3), E(3)^2, 1 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 1, E(3), E(3)^2, 1, E(3)^2, E(3), 1 ] ),
##    Character( CharacterTable( SL(2,3) ), [ 2, 1, 1, -2, -1, -1, 0 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 2, E(3)^2, E(3), -2, -E(3), -E(3)^2, 0 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 2, E(3), E(3)^2, -2, -E(3)^2, -E(3), 0 ] ),
##    Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] ) ]
##  gap> irr2:= IrrConlon( g );
##  [ Character( CharacterTable( SL(2,3) ), [ 1, 1, 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 1, E(3), E(3)^2, 1, E(3)^2, E(3), 1 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 1, E(3)^2, E(3), 1, E(3), E(3)^2, 1 ] ),
##    Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] ) ]
##  gap> irr3:= IrrBaumClausen( g );
##  [ Character( CharacterTable( SL(2,3) ), [ 1, 1, 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 1, E(3), E(3)^2, 1, E(3)^2, E(3), 1 ] ),
##    Character( CharacterTable( SL(2,3) ),
##      [ 1, E(3)^2, E(3), 1, E(3), E(3)^2, 1 ] ),
##    Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] ) ]
##  gap> chi:= irr2[4];;  HasTestMonomial( chi );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IrrBaumClausen", IsGroup );


#############################################################################
##
#F  InducedRepresentationImagesRepresentative( <rep>, <H>, <R>, <g> )
##
##  <ManSection>
##  <Func Name="InducedRepresentationImagesRepresentative"
##   Arg='rep, H, R, g'/>
##
##  <Description>
##  Let <A>rep</A><M>_H</M> denote the restriction of the group homomorphism
##  <A>rep</A> to the group <A>H</A>,
##  and <M>\phi</M> denote the induced representation of <A>rep</A><M>_H</M>
##  to <M>G</M>,
##  where <A>R</A> is a transversal of <A>H</A> in <M>G</M>.
##  <Ref Func="InducedRepresentationImagesRepresentative"/> returns the image
##  of the element <A>g</A> of <M>G</M> under <M>\phi</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InducedRepresentationImagesRepresentative" );


#############################################################################
##
#F  InducedRepresentation( <rep>, <G>[, <R>[, <H>]] )    induced matrix repr.
##
##  <ManSection>
##  <Func Name="InducedRepresentation" Arg='rep, G[, R[, H]]'/>
##
##  <Description>
##  Let <A>rep</A> be a matrix representation of the group <M>H</M>,
##  which is a subgroup of the group <A>G</A>.
##  <Ref Func="InducedRepresentation"/> returns the induced matrix
##  representation of <A>G</A>.
##  <P/>
##  The optional third argument <A>R</A> is a right transversal of <M>H</M>
##  in <A>G</A>.
##  If the fourth optional argument <A>H</A> is given then it must be a
##  subgroup of the source of <A>rep</A>,
##  and the induced representation of the restriction of <A>rep</A>
##  to <A>H</A> is computed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InducedRepresentation" );
#T Currently the returned homomorphism has `Image' etc. methods which
#T return plain lists not block matrices.
#T Before the function can be documented, this behaviour should be changed.


#############################################################################
##
#F  ProjectiveCharDeg( <G> ,<z> ,<q> )
##
##  <ManSection>
##  <Func Name="ProjectiveCharDeg" Arg='G ,z ,q'/>
##
##  <Description>
##  is a collected list of the degrees of those faithful and absolutely
##  irreducible characters of the group <A>G</A> in characteristic <A>q</A>
##  that restrict homogeneously to the group generated by <A>z</A>,
##  which must be central in <A>G</A>.
##  Only those characters are counted that have value a multiple of
##  <C>E( Order(<A>z</A>) )</C> on <A>z</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ProjectiveCharDeg" );


#############################################################################
##
#F  CoveringTriplesCharacters( <G>, <z> ) . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Func Name="CoveringTriplesCharacters" Arg='G, z'/>
##
##  <Description>
##  <A>G</A> must be a supersolvable group,
##  and <A>z</A> a central element in <A>G</A>.
##  <Ref Func="CoveringTriplesCharacters"/> returns a list of triples
##  <M>[ T, K, e ]</M>
##  such that every irreducible character <M>\chi</M> of <A>G</A> with the
##  property that <M>\chi(<A>z</A>)</M> is a multiple of
##  <C>E( Order(<A>z</A>) )</C> is induced from a linear character of some
##  <M>T</M>, with kernel <M>K</M>.
##  The element <M>e \in T</M> is chosen such that
##  <M>\langle e K \rangle = T/K</M>.
##  <P/>
##  The algorithm is in principle the same as that used in
##  <Ref Func="ProjectiveCharDeg"/>,
##  but the recursion stops if <M><A>G</A> = <A>z</A></M>.
##  The structure and the names of the variables are the same.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CoveringTriplesCharacters" );


#############################################################################
##
#A  IrrConlon( <G> )
##
##  <#GAPDoc Label="IrrConlon">
##  <ManSection>
##  <Attr Name="IrrConlon" Arg='G'/>
##
##  <Description>
##  For a finite solvable group <A>G</A>,
##  <Ref Attr="IrrConlon"/> returns a list of monomial irreducible characters
##  of <A>G</A>, among those all irreducibles that have the
##  supersolvable residuum of <A>G</A> in their kernels;
##  so if <A>G</A> is supersolvable,
##  all irreducible characters of <A>G</A> are returned.
##  An error is signalled if <A>G</A> is not solvable.
##  <P/>
##  The characters are computed using Conlon's algorithm
##  (see&nbsp;<Cite Key="Con90a"/> and&nbsp;<Cite Key="Con90b"/>).
##  For each irreducible character in the returned list,
##  the monomiality information
##  (see&nbsp;<Ref Attr="TestMonomial" Label="for a group"/>) is stored.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IrrConlon", IsGroup );
