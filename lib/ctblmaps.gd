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
##  This file contains the declaration of those functions that are used
##  to construct maps (mostly fusion maps and power maps).
##
##  1. Maps Concerning Character Tables
##  2. Power Maps
##  3. Class Fusions between Character Tables
##  4. Utilities for Parametrized Maps
##  5. Subroutines for the Construction of Power Maps
##  6. Subroutines for the Construction of Class Fusions
##


#############################################################################
##
##  1. Maps Concerning Character Tables
##
##  <#GAPDoc Label="[1]{ctblmaps}">
##  Besides the characters, <E>power maps</E> are an important part of a
##  character table, see Section&nbsp;<Ref Sect="Power Maps"/>.
##  Often their computation is not easy, and if the table has no access to
##  the underlying group then in general they cannot be obtained from the
##  matrix of irreducible characters;
##  so it is useful to store them on the table.
##  <P/>
##  If not only a single table is considered but different tables of a group
##  and a subgroup or of a group and a factor group are used,
##  also <E>class fusion maps</E>
##  (see Section&nbsp;<Ref Sect="Class Fusions between Character Tables"/>)
##  must be known to get information about the embedding or simply to induce
##  or restrict characters,
##  see Section&nbsp;<Ref Sect="Restricted and Induced Class Functions"/>).
##  <P/>
##  These are examples of functions from conjugacy classes which will be
##  called <E>maps</E> in the following.
##  (This should not be confused with the term mapping,
##  cf. Chapter&nbsp;<Ref Chap="Mappings"/>.)
##  In &GAP;, maps are represented by lists.
##  Also each character, each list of element orders, of centralizer orders,
##  or of class lengths are maps,
##  and the list returned by <Ref Func="ListPerm"/>,
##  when this function is called with a permutation of classes, is a map.
##  <P/>
##  When maps are constructed without access to a group, often one only knows
##  that the image of a given class is contained in a set of possible images,
##  e. g., that the image of a class under a subgroup fusion is in the set of
##  all classes with the same element order.
##  Using further information, such as centralizer orders, power maps and the
##  restriction of characters, the sets of possible images can be restricted
##  further.
##  In many cases, at the end the images are uniquely determined.
##  <P/>
##  Because of this approach, many functions in this chapter work not only
##  with maps but with <E>parametrized maps</E>
##  (or <E>paramaps</E> for short).
##  More about parametrized maps can be found
##  in Section&nbsp;<Ref Sect="Parametrized Maps"/>.
##  <P/>
##  The implementation follows&nbsp;<Cite Key="Bre91"/>,
##  a description of the main ideas together with several examples
##  can be found in&nbsp;<Cite Key="Bre99"/>.
##  <#/GAPDoc>
##


#############################################################################
##
##  2. Power Maps
##
##  <#GAPDoc Label="[2]{ctblmaps}">
##  The <M>n</M>-th power map of a character table is represented by a list
##  that stores at position <M>i</M> the position of the class containing
##  the <M>n</M>-th powers of the elements in the <M>i</M>-th class.
##  The <M>n</M>-th power map can be composed from the power maps of the
##  prime divisors of <M>n</M>,
##  so usually only power maps for primes are actually stored in the
##  character table.
##  <P/>
##  For an ordinary character table <A>tbl</A> with access to its underlying
##  group <M>G</M>,
##  the <M>p</M>-th power map of <A>tbl</A> can be computed using the
##  identification of the conjugacy classes of <M>G</M> with the classes of
##  <A>tbl</A>.
##  For an ordinary character table without access to a group,
##  in general the <M>p</M>-th power maps (and hence also the element orders)
##  for prime divisors <M>p</M> of the group order are not uniquely
##  determined by the matrix of irreducible characters.
##  So only necessary conditions can be checked in this case,
##  which in general yields only a list of several possibilities for the
##  desired power map.
##  Character tables of the &GAP; character table library store all
##  <M>p</M>-th power maps for prime divisors <M>p</M> of the group order.
##  <P/>
##  Power maps of Brauer tables can be derived from the power maps of the
##  underlying ordinary tables.
##  <P/>
##  For (computing and) accessing the <M>n</M>-th power map of a character
##  table, <Ref Oper="PowerMap"/> can be used;
##  if the <M>n</M>-th power map cannot be uniquely determined then
##  <Ref Oper="PowerMap"/> returns <K>fail</K>.
##  <P/>
##  The list of all possible <M>p</M>-th power maps of a table in the sense
##  that certain necessary conditions are satisfied can be computed with
##  <Ref Oper="PossiblePowerMaps"/>.
##  This provides a default strategy, the subroutines are listed in
##  Section&nbsp;<Ref Sect="Subroutines for the Construction of Power Maps"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#O  PowerMap( <tbl>, <n>[, <class>] )
#O  PowerMapOp( <tbl>, <n>[, <class>] )
#A  ComputedPowerMaps( <tbl> )
##
##  <#GAPDoc Label="PowerMap">
##  <ManSection>
##  <Oper Name="PowerMap" Arg='tbl, n[, class]'/>
##  <Oper Name="PowerMapOp" Arg='tbl, n[, class]'/>
##  <Attr Name="ComputedPowerMaps" Arg='tbl'/>
##
##  <Description>
##  Called with first argument a character table <A>tbl</A>
##  and second argument an integer <A>n</A>,
##  <Ref Oper="PowerMap"/> returns the <A>n</A>-th power map of <A>tbl</A>.
##  This is a list containing at position <M>i</M> the position of the class
##  of <A>n</A>-th powers of the elements in the <M>i</M>-th class of
##  <A>tbl</A>.
##  <P/>
##  If the additional third argument <A>class</A> is present then the
##  position of <A>n</A>-th powers of the <A>class</A>-th class is returned.
##  <P/>
##  If the <A>n</A>-th power map is not uniquely determined by <A>tbl</A>
##  then <K>fail</K> is returned.
##  This can happen only if <A>tbl</A> has no access to its underlying group.
##  <P/>
##  The power maps of <A>tbl</A> that were computed already by
##  <Ref Oper="PowerMap"/> are stored in <A>tbl</A> as value of the attribute
##  <Ref Attr="ComputedPowerMaps"/>,
##  the <M>n</M>-th power map at position <M>n</M>.
##  <Ref Oper="PowerMap"/> checks whether the desired power map is already
##  stored, computes it using the operation <Ref Oper="PowerMapOp"/> if it is
##  not yet known, and stores it.
##  So methods for the computation of power maps can be installed for
##  the operation <Ref Oper="PowerMapOp"/>.
##  <!-- % For power maps of groups, see&nbsp;<Ref Attr="PowerMapOfGroup"/>. -->
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "L3(2)" );;
##  gap> ComputedPowerMaps( tbl );
##  [ , [ 1, 1, 3, 2, 5, 6 ], [ 1, 2, 1, 4, 6, 5 ],,,,
##    [ 1, 2, 3, 4, 1, 1 ] ]
##  gap> PowerMap( tbl, 5 );
##  [ 1, 2, 3, 4, 6, 5 ]
##  gap> ComputedPowerMaps( tbl );
##  [ , [ 1, 1, 3, 2, 5, 6 ], [ 1, 2, 1, 4, 6, 5 ],, [ 1, 2, 3, 4, 6, 5 ],
##    , [ 1, 2, 3, 4, 1, 1 ] ]
##  gap> PowerMap( tbl, 137, 2 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PowerMap", [ IsNearlyCharacterTable, IsInt ] );
DeclareOperation( "PowerMap", [ IsNearlyCharacterTable, IsInt, IsInt ] );

DeclareOperation( "PowerMapOp", [ IsNearlyCharacterTable, IsInt ] );
DeclareOperation( "PowerMapOp", [ IsNearlyCharacterTable, IsInt, IsInt ] );

DeclareAttributeSuppCT( "ComputedPowerMaps",
    IsNearlyCharacterTable, "mutable", [ "class" ] );


#############################################################################
##
#O  PossiblePowerMaps( <tbl>, <p>[, <options>] )
##
##  <#GAPDoc Label="PossiblePowerMaps">
##  <ManSection>
##  <Oper Name="PossiblePowerMaps" Arg='tbl, p[, options]'/>
##
##  <Description>
##  For the ordinary character table <A>tbl</A> of a group <M>G</M>
##  and a prime integer <A>p</A>,
##  <Ref Oper="PossiblePowerMaps"/> returns the list of all maps that have
##  the following properties of the <M>p</M>-th power map of <A>tbl</A>.
##  (Representative orders are used only if the
##  <Ref Attr="OrdersClassRepresentatives"/> value of <A>tbl</A> is known.
##
##  <Enum>
##  <Item>
##    For class <M>i</M>, the centralizer order of the image is a multiple of
##    the <M>i</M>-th centralizer order;
##    if the elements in the <M>i</M>-th class have order coprime to <M>p</M>
##    then the centralizer orders of class <M>i</M> and its image are equal.
##  </Item>
##  <Item>
##    Let <M>n</M> be the order of elements in class <M>i</M>.
##    If <A>prime</A> divides <M>n</M> then the images have order <M>n/p</M>;
##    otherwise the images have order <M>n</M>.
##    These criteria are checked in <Ref Func="InitPowerMap"/>.
##  </Item>
##  <Item>
##    For each character <M>\chi</M> of <M>G</M> and each element <M>g</M>
##    in <M>G</M>, the values <M>\chi(g^p)</M> and
##    <C>GaloisCyc</C><M>( \chi(g), p )</M> are
##    algebraic integers that are congruent modulo <M>p</M>;
##    if <M>p</M> does not divide the element order of <M>g</M>
##    then the two values are equal.
##    This congruence is checked for the characters specified below in
##    the discussion of the <A>options</A> argument;
##    For linear characters <M>\lambda</M> among these characters,
##    the condition <M>\chi(g)^p = \chi(g^p)</M> is checked.
##    The corresponding function is
##    <Ref Func="Congruences" Label="for character tables"/>.
##  </Item>
##  <Item>
##    For each character <M>\chi</M> of <M>G</M>, the kernel is a normal
##    subgroup <M>N</M>, and <M>g^p \in N</M> for all <M>g \in N</M>;
##    moreover, if <M>N</M> has index <M>p</M> in <M>G</M> then
##    <M>g^p \in N</M> for all <M>g \in G</M>,
##    and if the index of <M>N</M> in <M>G</M> is coprime to <M>p</M> then
##    <M>g^p \not \in N</M> for each <M>g \not \in N</M>.
##    These conditions are checked for the kernels of all characters
##    <M>\chi</M> specified below,
##    the corresponding function is <Ref Func="ConsiderKernels"/>.
##  </Item>
##  <Item>
##    If <M>p</M> is larger than the order <M>m</M> of an element
##    <M>g \in G</M> then the class of <M>g^p</M> is determined by the power
##    maps for primes dividing the residue of <M>p</M> modulo <M>m</M>.
##    If these power maps are stored in the <Ref Attr="ComputedPowerMaps"/>
##    value of <A>tbl</A> then this information is used.
##    This criterion is checked in <Ref Func="ConsiderSmallerPowerMaps"/>.
##  </Item>
##  <Item>
##    For each character <M>\chi</M> of <M>G</M>,
##    the symmetrization <M>\psi</M> defined by
##    <M>\psi(g) = (\chi(g)^p - \chi(g^p))/p</M> is a character.
##    This condition is checked for the kernels of all characters
##    <M>\chi</M> specified below,
##    the corresponding function is
##    <Ref Func="PowerMapsAllowedBySymmetrizations"/>.
##  </Item>
##  </Enum>
##  <P/>
##  If <A>tbl</A> is a Brauer table, the possibilities are computed
##  from those for the underlying ordinary table.
##  <P/>
##  The optional argument <A>options</A>, if given, must be a record that may
##  have the following components:
##  <List>
##  <Mark><C>chars</C>:</Mark>
##  <Item>
##    a list of characters which are used for the check of the criteria
##    3., 4., and 6.;
##    the default is <C>Irr( <A>tbl</A> )</C>,
##  </Item>
##  <Mark><C>powermap</C>:</Mark>
##  <Item>
##    a parametrized map which is an approximation of the desired map
##  </Item>
##  <Mark><C>decompose</C>:</Mark>
##  <Item>
##    a Boolean;
##    a <K>true</K> value indicates that all constituents of the
##    symmetrizations of <C>chars</C> computed for criterion 6. lie in
##    <C>chars</C>,
##    so the symmetrizations can be decomposed into elements of <C>chars</C>;
##    the default value of <C>decompose</C> is <K>true</K> if <C>chars</C>
##    is not bound and <C>Irr( <A>tbl</A> )</C> is known,
##    otherwise <K>false</K>,
##  </Item>
##  <Mark><C>quick</C>:</Mark>
##  <Item>
##    a Boolean;
##    if <K>true</K> then the subroutines are called with value <K>true</K>
##    for the argument <A>quick</A>;
##    especially, as soon as only one candidate remains
##    this candidate is returned immediately;
##    the default value is <K>false</K>,
##  </Item>
##  <Mark><C>parameters</C>:</Mark>
##  <Item>
##    a record with components <C>maxamb</C>, <C>minamb</C> and <C>maxlen</C>
##    which control the subroutine
##    <Ref Func="PowerMapsAllowedBySymmetrizations"/>;
##    it only uses characters with current indeterminateness up to
##    <C>maxamb</C>,
##    tests decomposability only for characters with current
##    indeterminateness at least <C>minamb</C>,
##    and admits a branch according to a character only if there is one
##    with at most <C>maxlen</C> possible symmetrizations.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "U4(3).4" );;
##  gap> PossiblePowerMaps( tbl, 2 );
##  [ [ 1, 1, 3, 4, 5, 2, 2, 8, 3, 4, 11, 12, 6, 14, 9, 1, 1, 2, 2, 3, 4,
##        5, 6, 8, 9, 9, 10, 11, 12, 16, 16, 16, 16, 17, 17, 18, 18, 18,
##        18, 20, 20, 20, 20, 22, 22, 24, 24, 25, 26, 28, 28, 29, 29 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PossiblePowerMaps", [ IsCharacterTable, IsInt ] );
DeclareOperation( "PossiblePowerMaps", [ IsCharacterTable, IsInt,
    IsRecord ] );


#############################################################################
##
#F  ElementOrdersPowerMap( <powermap> )
##
##  <#GAPDoc Label="ElementOrdersPowerMap">
##  <ManSection>
##  <Func Name="ElementOrdersPowerMap" Arg='powermap'/>
##
##  <Description>
##  Let <A>powermap</A> be a nonempty list containing at position <M>p</M>,
##  if bound, the <M>p</M>-th power map of a character table or group.
##  <Ref Func="ElementOrdersPowerMap"/> returns a list of the same length as
##  each entry in <A>powermap</A>, with entry at position <M>i</M> equal to
##  the order of elements in class <M>i</M> if this order is uniquely
##  determined by <A>powermap</A>,
##  and equal to an unknown (see Chapter&nbsp;<Ref Chap="Unknowns"/>)
##  otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "U4(3).4" );;
##  gap> known:= ComputedPowerMaps( tbl );;
##  gap> Length( known );
##  7
##  gap> sub:= ShallowCopy( known );;  Unbind( sub[7] );
##  gap> ElementOrdersPowerMap( sub );
##  [ 1, 2, 3, 3, 3, 4, 4, 5, 6, 6, Unknown(1), Unknown(2), 8, 9, 12, 2,
##    2, 4, 4, 6, 6, 6, 8, 10, 12, 12, 12, Unknown(3), Unknown(4), 4, 4,
##    4, 4, 4, 4, 8, 8, 8, 8, 12, 12, 12, 12, 12, 12, 20, 20, 24, 24,
##    Unknown(5), Unknown(6), Unknown(7), Unknown(8) ]
##  gap> ord:= ElementOrdersPowerMap( known );
##  [ 1, 2, 3, 3, 3, 4, 4, 5, 6, 6, 7, 7, 8, 9, 12, 2, 2, 4, 4, 6, 6, 6,
##    8, 10, 12, 12, 12, 14, 14, 4, 4, 4, 4, 4, 4, 8, 8, 8, 8, 12, 12,
##    12, 12, 12, 12, 20, 20, 24, 24, 28, 28, 28, 28 ]
##  gap> ord = OrdersClassRepresentatives( tbl );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ElementOrdersPowerMap" );


#############################################################################
##
#F  PowerMapByComposition( <tbl>, <n> ) . .  for char. table and pos. integer
##
##  <#GAPDoc Label="PowerMapByComposition">
##  <ManSection>
##  <Func Name="PowerMapByComposition" Arg='tbl, n'/>
##
##  <Description>
##  <A>tbl</A> must be a nearly character table,
##  and <A>n</A> a positive integer.
##  If the power maps for all prime divisors of <A>n</A> are stored in the
##  <Ref Attr="ComputedPowerMaps"/> list of <A>tbl</A> then
##  <Ref Func="PowerMapByComposition"/> returns
##  the <A>n</A>-th power map of <A>tbl</A>.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "U4(3).4" );;  exp:= Exponent( tbl );
##  2520
##  gap> PowerMapByComposition( tbl, exp );
##  [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
##    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
##    1, 1, 1, 1, 1, 1, 1, 1, 1 ]
##  gap> Length( ComputedPowerMaps( tbl ) );
##  7
##  gap> PowerMapByComposition( tbl, 11 );
##  fail
##  gap> PowerMap( tbl, 11 );;
##  gap> PowerMapByComposition( tbl, 11 );
##  [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
##    20, 21, 22, 23, 24, 26, 25, 27, 28, 29, 31, 30, 33, 32, 35, 34, 37,
##    36, 39, 38, 41, 40, 43, 42, 45, 44, 47, 46, 49, 48, 51, 50, 53, 52 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PowerMapByComposition" );


#############################################################################
##
##  <#GAPDoc Label="[3]{ctblmaps}">
##  The permutation group of matrix automorphisms
##  (see&nbsp;<Ref Oper="MatrixAutomorphisms"/>)
##  acts on the possible power maps returned by
##  <Ref Oper="PossiblePowerMaps"/>
##  by permuting a list via <Ref Oper="Permuted"/>
##  and then mapping the images via <Ref Func="OnPoints"/>.
##  Note that by definition, the group of <E>table</E> automorphisms
##  acts trivially.
##  <#/GAPDoc>
##


#############################################################################
##
#F  OrbitPowerMaps( <map>, <permgrp> )
##
##  <#GAPDoc Label="OrbitPowerMaps">
##  <ManSection>
##  <Func Name="OrbitPowerMaps" Arg='map, permgrp'/>
##
##  <Description>
##  returns the orbit of the power map <A>map</A> under the action of the
##  permutation group <A>permgrp</A>
##  via a combination of <Ref Oper="Permuted"/> and <Ref Func="OnPoints"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OrbitPowerMaps" );


#############################################################################
##
#F  RepresentativesPowerMaps( <listofmaps>, <permgrp> )
##
##  <#GAPDoc Label="RepresentativesPowerMaps">
##  <ManSection>
##  <Func Name="RepresentativesPowerMaps" Arg='listofmaps, permgrp'/>
##
##  <Description>
##  <Index>matrix automorphisms</Index>
##  returns a list of orbit representatives of the power maps in the list
##  <A>listofmaps</A> under the action of the permutation group
##  <A>permgrp</A>
##  via a combination of <Ref Oper="Permuted"/> and <Ref Func="OnPoints"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "3.McL" );;
##  gap> grp:= MatrixAutomorphisms( Irr( tbl ) );  Size( grp );
##  <permutation group with 5 generators>
##  32
##  gap> poss:= PossiblePowerMaps( CharacterTable( "3.McL" ), 3 );
##  [ [ 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 11, 11, 11, 14, 14, 14, 17, 17, 17,
##        4, 4, 4, 4, 4, 4, 29, 29, 29, 26, 26, 26, 32, 32, 32, 9, 8, 37,
##        37, 37, 40, 40, 40, 43, 43, 43, 11, 11, 11, 52, 52, 52, 49, 49,
##        49, 14, 14, 14, 14, 14, 14, 37, 37, 37, 37, 37, 37 ],
##    [ 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 11, 11, 11, 14, 14, 14, 17, 17, 17,
##        4, 4, 4, 4, 4, 4, 29, 29, 29, 26, 26, 26, 32, 32, 32, 8, 9, 37,
##        37, 37, 40, 40, 40, 43, 43, 43, 11, 11, 11, 52, 52, 52, 49, 49,
##        49, 14, 14, 14, 14, 14, 14, 37, 37, 37, 37, 37, 37 ] ]
##  gap> reps:= RepresentativesPowerMaps( poss, grp );
##  [ [ 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 11, 11, 11, 14, 14, 14, 17, 17, 17,
##        4, 4, 4, 4, 4, 4, 29, 29, 29, 26, 26, 26, 32, 32, 32, 8, 9, 37,
##        37, 37, 40, 40, 40, 43, 43, 43, 11, 11, 11, 52, 52, 52, 49, 49,
##        49, 14, 14, 14, 14, 14, 14, 37, 37, 37, 37, 37, 37 ] ]
##  gap> orb:= OrbitPowerMaps( reps[1], grp );
##  [ [ 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 11, 11, 11, 14, 14, 14, 17, 17, 17,
##        4, 4, 4, 4, 4, 4, 29, 29, 29, 26, 26, 26, 32, 32, 32, 8, 9, 37,
##        37, 37, 40, 40, 40, 43, 43, 43, 11, 11, 11, 52, 52, 52, 49, 49,
##        49, 14, 14, 14, 14, 14, 14, 37, 37, 37, 37, 37, 37 ],
##    [ 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 11, 11, 11, 14, 14, 14, 17, 17, 17,
##        4, 4, 4, 4, 4, 4, 29, 29, 29, 26, 26, 26, 32, 32, 32, 9, 8, 37,
##        37, 37, 40, 40, 40, 43, 43, 43, 11, 11, 11, 52, 52, 52, 49, 49,
##        49, 14, 14, 14, 14, 14, 14, 37, 37, 37, 37, 37, 37 ] ]
##  gap> Parametrized( orb );
##  [ 1, 1, 1, 4, 4, 4, 1, 1, 1, 1, 11, 11, 11, 14, 14, 14, 17, 17, 17,
##    4, 4, 4, 4, 4, 4, 29, 29, 29, 26, 26, 26, 32, 32, 32, [ 8, 9 ],
##    [ 8, 9 ], 37, 37, 37, 40, 40, 40, 43, 43, 43, 11, 11, 11, 52, 52,
##    52, 49, 49, 49, 14, 14, 14, 14, 14, 14, 37, 37, 37, 37, 37, 37 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RepresentativesPowerMaps" );


#############################################################################
##
##  3. Class Fusions between Character Tables
##
##  <#GAPDoc Label="[4]{ctblmaps}">
##  <Index>fusions</Index><Index>subgroup fusions</Index>
##  For a group <M>G</M> and a subgroup <M>H</M> of <M>G</M>,
##  the fusion map between the character table of <M>H</M> and the character
##  table of <M>G</M> is represented by a list that stores at position
##  <M>i</M> the position of the <M>i</M>-th class of the table of <M>H</M>
##  in the classes list of the table of <M>G</M>.
##  <P/>
##  For ordinary character tables <A>tbl1</A> and <A>tbl2</A> of <M>H</M> and
##  <M>G</M>, with access to the groups <M>H</M> and <M>G</M>,
##  the class fusion between <A>tbl1</A> and <A>tbl2</A> can be computed
##  using the identifications of the conjugacy classes of <M>H</M> with the
##  classes of <A>tbl1</A> and the conjugacy classes of <M>G</M> with the
##  classes of <A>tbl2</A>.
##  For two ordinary character tables without access to an underlying group,
##  or in the situation that the group stored in <A>tbl1</A> is not
##  physically a subgroup of the group stored in <A>tbl2</A> but an
##  isomorphic copy, in general the class fusion is not uniquely determined
##  by the information stored on the tables such as irreducible characters
##  and power maps.
##  So only necessary conditions can be checked in this case,
##  which in general yields only a list of several possibilities for the
##  desired class fusion.
##  Character tables of the &GAP; character table library store various
##  class fusions that are regarded as important,
##  for example fusions from maximal subgroups
##  (see&nbsp;<Ref Attr="ComputedClassFusions"/>
##  and <Ref Attr="Maxes" BookName="ctbllib"/> in the manual for the &GAP;
##  Character Table Library).
##  <P/>
##  Class fusions between Brauer tables can be derived from the class fusions
##  between the underlying ordinary tables.
##  The class fusion from a Brauer table to the underlying ordinary table is
##  stored when the Brauer table is constructed from the ordinary table,
##  so no method is needed to compute such a fusion.
##  <P/>
##  For (computing and) accessing the class fusion between two character
##  tables,
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/>
##  can be used;
##  if the class fusion cannot be uniquely determined then
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/>
##  returns <K>fail</K>.
##  <P/>
##  The list of all possible class fusion between two tables in the sense
##  that certain necessary conditions are satisfied can be computed with
##  <Ref Oper="PossibleClassFusions"/>.
##  This provides a default strategy, the subroutines are listed in
##  Section <Ref Sect="Subroutines for the Construction of Class Fusions"/>.
##  <P/>
##  It should be noted that all the following functions except
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/>
##  deal only with the situation of class fusions from subgroups.
##  The computation of <E>factor fusions</E> from a character table to the
##  table of a factor group is not dealt with here.
##  Since the ordinary character table of a group <M>G</M> determines the
##  character tables of all factor groups of <M>G</M>, the factor fusion to a
##  given character table of a factor group of <M>G</M> is determined up to
##  table automorphisms (see&nbsp;<Ref Attr="AutomorphismsOfTable"/>) once
##  the class positions of the kernel of the natural epimorphism have been
##  fixed.
##  <#/GAPDoc>
##


#############################################################################
##
#O  FusionConjugacyClasses( <tbl1>, <tbl2> )
#O  FusionConjugacyClasses( <H>, <G> )
#O  FusionConjugacyClasses( <hom>[, <tbl1>, <tbl2>] )
#O  FusionConjugacyClassesOp( <tbl1>, <tbl2> )
#A  FusionConjugacyClassesOp( <hom> )
##
##  <#GAPDoc Label="FusionConjugacyClasses">
##  <ManSection>
##  <Heading>FusionConjugacyClasses</Heading>
##  <Oper Name="FusionConjugacyClasses" Arg='tbl1, tbl2'
##   Label="for two character tables"/>
##  <Oper Name="FusionConjugacyClasses" Arg='H, G'
##   Label="for two groups"/>
##  <Oper Name="FusionConjugacyClasses" Arg='hom[, tbl1, tbl2]'
##   Label="for a homomorphism"/>
##  <Oper Name="FusionConjugacyClassesOp" Arg='tbl1, tbl2'
##   Label="for two character tables"/>
##  <Attr Name="FusionConjugacyClassesOp" Arg='hom'
##   Label="for a homomorphism"/>
##
##  <Description>
##  Called with two character tables <A>tbl1</A> and <A>tbl2</A>,
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/>
##  returns the fusion of conjugacy classes between <A>tbl1</A> and
##  <A>tbl2</A>.
##  (If one of the tables is a Brauer table,
##  it will delegate this task to the underlying ordinary table.)
##  <P/>
##  Called with two groups <A>H</A> and <A>G</A> where <A>H</A> is a subgroup
##  of <A>G</A>,
##  <Ref Oper="FusionConjugacyClasses" Label="for two groups"/> returns
##  the fusion of conjugacy classes between <A>H</A> and <A>G</A>.
##  This is done by delegating to the ordinary character tables of <A>H</A>
##  and <A>G</A>,
##  since class fusions are stored only for character tables and not for
##  groups.
##  <P/>
##  Note that the returned class fusion refers to the ordering of conjugacy
##  classes in the character tables if the arguments are character tables
##  and to the ordering of conjugacy classes in the groups if the arguments
##  are groups
##  (see&nbsp;<Ref Attr="ConjugacyClasses" Label="for character tables"/>).
##  <P/>
##  Called with a group homomorphism <A>hom</A>,
##  <Ref Oper="FusionConjugacyClasses" Label="for a homomorphism"/> returns
##  the fusion of conjugacy classes between the preimage and the image of
##  <A>hom</A>;
##  contrary to the two cases above,
##  also factor fusions can be handled by this variant.
##  If <A>hom</A> is the only argument then the class fusion refers to the
##  ordering of conjugacy classes in the groups.
##  If the character tables of preimage and image are given as <A>tbl1</A>
##  and <A>tbl2</A>, respectively (each table with its group stored),
##  then the fusion refers to the ordering of classes in these tables.
##  <P/>
##  If no class fusion exists or if the class fusion is not uniquely
##  determined, <K>fail</K> is returned; this may happen when
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/> is
##  called with two character tables that do not know compatible underlying
##  groups.
##  <P/>
##  Methods for the computation of class fusions can be installed for
##  the operation
##  <Ref Oper="FusionConjugacyClassesOp" Label="for two character tables"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= SymmetricGroup( 4 );
##  Sym( [ 1 .. 4 ] )
##  gap> tbls4:= CharacterTable( s4 );;
##  gap> d8:= SylowSubgroup( s4, 2 );
##  Group([ (1,2), (3,4), (1,3)(2,4) ])
##  gap> FusionConjugacyClasses( d8, s4 );
##  [ 1, 2, 3, 3, 5 ]
##  gap> tbls5:= CharacterTable( "S5" );;
##  gap> FusionConjugacyClasses( CharacterTable( "A5" ), tbls5 );
##  [ 1, 2, 3, 4, 4 ]
##  gap> FusionConjugacyClasses(CharacterTable("A5"), CharacterTable("J1"));
##  fail
##  gap> PossibleClassFusions(CharacterTable("A5"), CharacterTable("J1"));
##  [ [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 5, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FusionConjugacyClasses",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "FusionConjugacyClasses", [ IsGroup, IsGroup ] );
DeclareOperation( "FusionConjugacyClasses", [ IsGeneralMapping ] );
DeclareOperation( "FusionConjugacyClasses",
    [ IsGeneralMapping, IsNearlyCharacterTable, IsNearlyCharacterTable ] );

DeclareAttribute( "FusionConjugacyClassesOp", IsGeneralMapping );

DeclareOperation( "FusionConjugacyClassesOp",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "FusionConjugacyClassesOp",
    [ IsGeneralMapping, IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#A  ComputedClassFusions( <tbl> )
##
##  <#GAPDoc Label="ComputedClassFusions">
##  <ManSection>
##  <Attr Name="ComputedClassFusions" Arg='tbl'/>
##
##  <Description>
##  The class fusions from the character table <A>tbl</A> that have been
##  computed already by
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/> or
##  explicitly stored by <Ref Func="StoreFusion"/>
##  are stored in the <Ref Attr="ComputedClassFusions"/> list of <A>tbl1</A>.
##  Each entry of this list is a record with the following components.
##
##  <List>
##  <Mark><C>name</C></Mark>
##  <Item>
##    the <Ref Attr="Identifier" Label="for character tables"/> value
##    of the character table to which the fusion maps,
##  </Item>
##  <Mark><C>map</C></Mark>
##  <Item>
##    the list of positions of image classes,
##  </Item>
##  <Mark><C>text</C> (optional)</Mark>
##  <Item>
##    a string giving additional information about the fusion map,
##    for example whether the map is uniquely determined by the character
##    tables,
##  </Item>
##  <Mark><C>specification</C> (optional, rarely used)</Mark>
##  <Item>
##    a value that distinguishes different fusions between the same tables.
##  </Item>
##  </List>
##  <P/>
##  Note that stored fusion maps may differ from the maps returned by
##  <Ref Func="GetFusionMap"/> and the maps entered by
##  <Ref Func="StoreFusion"/> if the table <A>destination</A> has a
##  nonidentity <Ref Attr="ClassPermutation"/> value.
##  So if one fetches a fusion map from a table <A>tbl1</A> to a table
##  <A>tbl2</A> via access to the data in the
##  <Ref Attr="ComputedClassFusions"/> list of <A>tbl1</A> then the stored
##  value must be composed with the <Ref Attr="ClassPermutation"/> value of
##  <A>tbl2</A> in order to obtain the correct class fusion.
##  (If one handles fusions only via <Ref Func="GetFusionMap"/> and
##  <Ref Func="StoreFusion"/> then this adjustment is made automatically.)
##  <P/>
##  Fusions are identified via the
##  <Ref Attr="Identifier" Label="for character tables"/> value of the
##  destination table and not by this table itself because many fusions
##  between character tables in the &GAP; character table library are stored
##  on library tables,
##  and it is not desirable to load together with a library table also all
##  those character tables that occur as destinations of fusions from this
##  table.
##  <P/>
##  For storing fusions and accessing stored fusions,
##  see also&nbsp;<Ref Func="GetFusionMap"/>, <Ref Func="StoreFusion"/>.
##  For accessing the identifiers of tables that store a fusion into a
##  given character table, see&nbsp;<Ref Attr="NamesOfFusionSources"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "ComputedClassFusions",
    IsNearlyCharacterTable, "mutable", [ "class" ] );


#############################################################################
##
#F  GetFusionMap( <source>, <destination>[, <specification>] )
##
##  <#GAPDoc Label="GetFusionMap">
##  <ManSection>
##  <Func Name="GetFusionMap" Arg='source, destination[, specification]'/>
##
##  <Description>
##  For two ordinary character tables <A>source</A> and <A>destination</A>,
##  <Ref Func="GetFusionMap"/> checks whether the
##  <Ref Attr="ComputedClassFusions"/> list of <A>source</A>
##  contains a record with <C>name</C> component
##  <C>Identifier( <A>destination</A> )</C>,
##  and returns the <C>map</C> component of the first such record.
##  <C>GetFusionMap( <A>source</A>, <A>destination</A>,
##  <A>specification</A> )</C> fetches
##  that fusion map for which the record additionally has the
##  <C>specification</C> component <A>specification</A>.
##  <P/>
##  If both <A>source</A> and <A>destination</A> are Brauer tables,
##  first the same is done, and if no fusion map was found then
##  <Ref Func="GetFusionMap"/> looks whether a fusion map between the
##  ordinary tables is stored;
##  if so then the fusion map between <A>source</A> and <A>destination</A>
##  is stored on <A>source</A>, and then returned.
##  <P/>
##  If no appropriate fusion is found, <Ref Func="GetFusionMap"/> returns
##  <K>fail</K>.
##  For the computation of class fusions, see
##  <Ref Oper="FusionConjugacyClasses" Label="for two character tables"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GetFusionMap" );


#############################################################################
##
#F  StoreFusion( <source>, <fusion>, <destination> )
##
##  <#GAPDoc Label="StoreFusion">
##  <ManSection>
##  <Func Name="StoreFusion" Arg='source, fusion, destination'/>
##
##  <Description>
##  For two character tables <A>source</A> and <A>destination</A>,
##  <Ref Func="StoreFusion"/> stores the fusion <A>fusion</A> from
##  <A>source</A> to <A>destination</A> in the
##  <Ref Attr="ComputedClassFusions"/> list of <A>source</A>,
##  and adds the <Ref Attr="Identifier" Label="for character tables"/> string
##  of <A>destination</A> to the <Ref Attr="NamesOfFusionSources"/> list of
##  <A>destination</A>.
##  <P/>
##  <A>fusion</A> can either be a fusion map (that is, the list of positions
##  of the image classes) or a record as described
##  in&nbsp;<Ref Attr="ComputedClassFusions"/>.
##  <P/>
##  If fusions to <A>destination</A> are already stored on <A>source</A> then
##  another fusion can be stored only if it has a record component
##  <C>specification</C> that distinguishes it from the stored fusions.
##  In the case of such an ambiguity, <Ref Func="StoreFusion"/> raises an
##  error.
##  <P/>
##  <Example><![CDATA[
##  gap> tbld8:= CharacterTable( d8 );;
##  gap> ComputedClassFusions( tbld8 );
##  [ rec( map := [ 1, 2, 3, 3, 5 ], name := "CT1" ) ]
##  gap> Identifier( tbls4 );
##  "CT1"
##  gap> GetFusionMap( tbld8, tbls4 );
##  [ 1, 2, 3, 3, 5 ]
##  gap> GetFusionMap( tbls4, tbls5 );
##  fail
##  gap> poss:= PossibleClassFusions( tbls4, tbls5 );
##  [ [ 1, 5, 2, 3, 6 ] ]
##  gap> StoreFusion( tbls4, poss[1], tbls5 );
##  gap> GetFusionMap( tbls4, tbls5 );
##  [ 1, 5, 2, 3, 6 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StoreFusion" );


#############################################################################
##
#A  NamesOfFusionSources( <tbl> )
##
##  <#GAPDoc Label="NamesOfFusionSources">
##  <ManSection>
##  <Attr Name="NamesOfFusionSources" Arg='tbl'/>
##
##  <Description>
##  For a character table <A>tbl</A>,
##  <Ref Attr="NamesOfFusionSources"/> returns the list of identifiers of all
##  those character tables that are known to have fusions to <A>tbl</A>
##  stored.
##  The <Ref Attr="NamesOfFusionSources"/> value is updated whenever a fusion
##  to <A>tbl</A> is stored using <Ref Func="StoreFusion"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> NamesOfFusionSources( tbls4 );
##  [ "CT2" ]
##  gap> Identifier( CharacterTable( d8 ) );
##  "CT2"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "NamesOfFusionSources",
    IsNearlyCharacterTable, "mutable", [] );


#############################################################################
##
#O  PossibleClassFusions( <subtbl>, <tbl>[, <options>] )
##
##  <#GAPDoc Label="PossibleClassFusions">
##  <ManSection>
##  <Oper Name="PossibleClassFusions" Arg='subtbl, tbl[, options]'/>
##
##  <Description>
##  For two ordinary character tables <A>subtbl</A> and <A>tbl</A> of the
##  groups <M>H</M> and <M>G</M>,
##  <Ref Oper="PossibleClassFusions"/> returns the list of all maps that have
##  the following properties of class fusions from <A>subtbl</A> to
##  <A>tbl</A>.
##
##  <Enum>
##  <Item>
##    For class <M>i</M>, the centralizer order of the image in <M>G</M> is a
##    multiple of the <M>i</M>-th centralizer order in <M>H</M>,
##    and the element orders in the <M>i</M>-th class and its image are
##    equal.
##    These criteria are checked in <Ref Func="InitFusion"/>.
##  </Item>
##  <Item>
##    The class fusion commutes with power maps.
##    This is checked using <Ref Func="TestConsistencyMaps"/>.
##  </Item>
##  <Item>
##    If the permutation character of <M>G</M> corresponding to the action of
##    <M>G</M> on the cosets of <M>H</M> is specified (see the discussion of
##    the <A>options</A> argument below)
##    then it prescribes for each class <M>C</M> of
##    <M>G</M> the number of elements of <M>H</M> fusing into <M>C</M>.
##    The corresponding function is <Ref Func="CheckPermChar"/>.
##  </Item>
##  <Item>
##    The table automorphisms of <A>tbl</A>
##    (see&nbsp;<Ref Attr="AutomorphismsOfTable"/>) are
##    used in order to compute only orbit representatives.
##    (But note that the list returned by <Ref Oper="PossibleClassFusions"/>
##    contains the full orbits.)
##  </Item>
##  <Item>
##    For each character <M>\chi</M> of <M>G</M>, the restriction to <M>H</M>
##    via the class fusion is a character of <M>H</M>.
##    This condition is checked for all characters specified below,
##    the corresponding function is
##    <Ref Func="FusionsAllowedByRestrictions"/>.
##  </Item>
##  <Item>
##    The class multiplication coefficients in <A>subtbl</A> do not exceed
##    the corresponding coefficients in <A>tbl</A>.
##    This is checked in <Ref Func="ConsiderStructureConstants"/>,
##    see also the comment on the parameter <C>verify</C> below.
##  </Item>
##  </Enum>
##  <P/>
##  If <A>subtbl</A> and <A>tbl</A> are Brauer tables then the possibilities
##  are computed from those for the underlying ordinary tables.
##  <P/>
##  The optional argument <A>options</A> must be a record that may have the
##  following components:
##
##  <List>
##  <Mark><C>chars</C></Mark>
##  <Item>
##    a list of characters of <A>tbl</A> which are used for the check
##    of&nbsp;5.; the default is <C>Irr( <A>tbl</A> )</C>,
##  </Item>
##  <Mark><C>subchars</C></Mark>
##  <Item>
##    a list of characters of <A>subtbl</A> which are constituents of the
##    restrictions of <C>chars</C>,
##    the default is <C>Irr( <A>subtbl</A> )</C>,
##  </Item>
##  <Mark><C>fusionmap</C></Mark>
##  <Item>
##    a parametrized map which is an approximation of the desired map,
##  </Item>
##  <Mark><C>decompose</C></Mark>
##  <Item>
##    a Boolean;
##    a <K>true</K> value indicates that all constituents of the restrictions
##    of <C>chars</C> computed for criterion 5. lie in <C>subchars</C>,
##    so the restrictions can be decomposed into elements of <C>subchars</C>;
##    the default value of <C>decompose</C> is <K>true</K> if <C>subchars</C>
##    is not bound and <C>Irr( <A>subtbl</A> )</C> is known,
##    otherwise <K>false</K>,
##  </Item>
##  <Mark><C>permchar</C></Mark>
##  <Item>
##    (a values list of) a permutation character; only those fusions
##    affording that permutation character are computed,
##  </Item>
##  <Mark><C>quick</C></Mark>
##  <Item>
##    a Boolean;
##    if <K>true</K> then the subroutines are called with value <K>true</K>
##    for the argument <A>quick</A>;
##    especially, as soon as only one possibility remains
##    then this possibility is returned immediately;
##    the default value is <K>false</K>
##    (note that in situations where the group of <A>tbl</A> has no subgroups
##    with character table <A>subtbl</A>, it may happen that setting
##    <C>quick</C> to <K>true</K> causes <Ref Oper="PossibleClassFusions"/>
##    to return solutions,
##    whereas the value <K>false</K> yields an empty list),
##  </Item>
##  <Mark><C>verify</C></Mark>
##  <Item>
##    a Boolean;
##    if <K>false</K> then <Ref Func="ConsiderStructureConstants"/> is called
##    only if more than one orbit of possible class fusions exists,
##    under the action of the groups of table automorphisms;
##    the default value is <K>false</K> (because the computation of the
##    structure constants is usually very time consuming, compared with
##    checking the other criteria),
##  </Item>
##  <Mark><C>parameters</C></Mark>
##  <Item>
##    a record with components <C>maxamb</C>, <C>minamb</C> and <C>maxlen</C>
##    (and perhaps some optional components) which control the subroutine
##    <Ref Func="FusionsAllowedByRestrictions"/>;
##    it only uses characters with current indeterminateness up to
##    <C>maxamb</C>,
##    tests decomposability only for characters with current
##    indeterminateness at least <C>minamb</C>,
##    and admits a branch according to a character only if there is one
##    with at most <C>maxlen</C> possible restrictions.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "U3(3)" );;  tbl:= CharacterTable( "J4" );;
##  gap> PossibleClassFusions( subtbl, tbl );
##  [ [ 1, 2, 4, 4, 5, 5, 6, 10, 12, 13, 14, 14, 21, 21 ],
##    [ 1, 2, 4, 4, 5, 5, 6, 10, 13, 12, 14, 14, 21, 21 ],
##    [ 1, 2, 4, 4, 6, 6, 6, 10, 12, 13, 15, 15, 22, 22 ],
##    [ 1, 2, 4, 4, 6, 6, 6, 10, 12, 13, 16, 16, 22, 22 ],
##    [ 1, 2, 4, 4, 6, 6, 6, 10, 13, 12, 15, 15, 22, 22 ],
##    [ 1, 2, 4, 4, 6, 6, 6, 10, 13, 12, 16, 16, 22, 22 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PossibleClassFusions",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "PossibleClassFusions",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsRecord ] );


#############################################################################
##
##  <#GAPDoc Label="[5]{ctblmaps}">
##  The permutation groups of table automorphisms
##  (see&nbsp;<Ref Attr="AutomorphismsOfTable"/>)
##  of the subgroup table <A>subtbl</A> and the supergroup table <A>tbl</A>
##  act on the possible class fusions from <A>subtbl</A> to <A>tbl</A>
##  that are returned by <Ref Oper="PossibleClassFusions"/>,
##  the former by permuting a list via <Ref Oper="Permuted"/>,
##  the latter by mapping the images via <Ref Func="OnPoints"/>.
##  <P/>
##  If a set of possible fusions with certain properties was computed
##  that are not invariant under the full groups of table automorphisms
##  then only a smaller group acts on this set.
##  This may happen for example if a permutation character or if an explicit
##  approximation of the fusion map was prescribed in the call of
##  <Ref Oper="PossibleClassFusions"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#F  OrbitFusions( <subtblautomorphisms>, <fusionmap>, <tblautomorphisms> )
##
##  <#GAPDoc Label="OrbitFusions">
##  <ManSection>
##  <Func Name="OrbitFusions"
##   Arg='subtblautomorphisms, fusionmap, tblautomorphisms'/>
##
##  <Description>
##  returns the orbit of the class fusion map <A>fusionmap</A> under the
##  actions of the permutation groups <A>subtblautomorphisms</A> and
##  <A>tblautomorphisms</A> of automorphisms of the character table of the
##  subgroup and the supergroup, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OrbitFusions" );


#############################################################################
##
#F  RepresentativesFusions( <subtbl>, <listofmaps>, <tbl> )
##
##  <#GAPDoc Label="RepresentativesFusions">
##  <ManSection>
##  <Func Name="RepresentativesFusions" Arg='subtbl, listofmaps, tbl'/>
##
##  <Description>
##  <Index>table automorphisms</Index>
##  Let <A>listofmaps</A> be a list of class fusions from the character table
##  <A>subtbl</A> to the character table <A>tbl</A>.
##  <Ref Func="RepresentativesFusions"/> returns a list of orbit
##  representatives of the class fusions under the action of maximal
##  admissible subgroups of the table automorphism groups of these character
##  tables.
##  <P/>
##  Instead of the character tables <A>subtbl</A> and <A>tbl</A>,
##  also the permutation groups of their table automorphisms
##  (see <Ref Attr="AutomorphismsOfTable"/>) may be entered.
##  <P/>
##  <Example><![CDATA[
##  gap> fus:= GetFusionMap( subtbl, tbl );
##  [ 1, 2, 4, 4, 5, 5, 6, 10, 12, 13, 14, 14, 21, 21 ]
##  gap> orb:= OrbitFusions( AutomorphismsOfTable( subtbl ), fus,
##  >              AutomorphismsOfTable( tbl ) );
##  [ [ 1, 2, 4, 4, 5, 5, 6, 10, 12, 13, 14, 14, 21, 21 ],
##    [ 1, 2, 4, 4, 5, 5, 6, 10, 13, 12, 14, 14, 21, 21 ] ]
##  gap> rep:= RepresentativesFusions( subtbl, orb, tbl );
##  [ [ 1, 2, 4, 4, 5, 5, 6, 10, 12, 13, 14, 14, 21, 21 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RepresentativesFusions" );


#############################################################################
##
##  4. Utilities for Parametrized Maps
##
##  <#GAPDoc Label="[6]{ctblmaps}">
##  <Index Subkey="parametrized">map</Index>
##  <Index>class functions</Index>
##  A <E>parametrized map</E> is a list whose <M>i</M>-th entry is either
##  unbound (which means that nothing is known about the image(s) of the
##  <M>i</M>-th class) or the image of the <M>i</M>-th class
##  (i.e., an integer for fusion maps, power maps, element orders etc.,
##  and a cyclotomic for characters),
##  or a list of possible images of the <M>i</M>-th class.
##  In this sense, maps are special parametrized maps.
##  We often identify a parametrized map <A>paramap</A> with the set of all
##  maps <A>map</A> with the property that either
##  <C><A>map</A>[i] = <A>paramap</A>[i]</C> or
##  <C><A>map</A>[i]</C> is contained in the list <C><A>paramap</A>[i]</C>;
##  we say then that <A>map</A> is contained in <A>paramap</A>.
##  <P/>
##  This definition implies that parametrized maps cannot be used to describe
##  sets of maps where lists are possible images.
##  An exception are strings which naturally arise as images when class names
##  are considered.
##  So strings and lists of strings are allowed in parametrized maps,
##  and character constants
##  (see Chapter&nbsp;<Ref Chap="Strings and Characters"/>)
##  are not allowed in maps.
##  <#/GAPDoc>
##


#############################################################################
##
#F  CompositionMaps( <paramap2>, <paramap1>[, <class>] )
##
##  <#GAPDoc Label="CompositionMaps">
##  <ManSection>
##  <Func Name="CompositionMaps" Arg='paramap2, paramap1[, class]'/>
##
##  <Description>
##  The composition of two parametrized maps <A>paramap1</A>, <A>paramap2</A>
##  is defined as the parametrized map <A>comp</A> that contains
##  all compositions <M>f_2 \circ f_1</M> of elements <M>f_1</M> of
##  <A>paramap1</A> and <M>f_2</M> of <A>paramap2</A>.
##  For example, the composition of a character <M>\chi</M> of a group
##  <M>G</M> by a parametrized class fusion map from a subgroup <M>H</M> to
##  <M>G</M> is the parametrized map that contains all restrictions of
##  <M>\chi</M> by elements of the parametrized fusion map.
##  <P/>
##  <C>CompositionMaps(<A>paramap2</A>, <A>paramap1</A>)</C>
##  is a parametrized map with entry
##  <C>CompositionMaps(<A>paramap2</A>, <A>paramap1</A>, <A>class</A>)</C>
##  at position <A>class</A>.
##  If <C><A>paramap1</A>[<A>class</A>]</C> is an integer then
##  <C>CompositionMaps(<A>paramap2</A>, <A>paramap1</A>, <A>class</A>)</C>
##  is equal to <C><A>paramap2</A>[ <A>paramap1</A>[ <A>class</A> ] ]</C>.
##  Otherwise it is the union of <C><A>paramap2</A>[<A>i</A>]</C> for
##  <A>i</A> in <C><A>paramap1</A>[ <A>class</A> ]</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> map1:= [ 1, [ 2 .. 4 ], [ 4, 5 ], 1 ];;
##  gap> map2:= [ [ 1, 2 ], 2, 2, 3, 3 ];;
##  gap> CompositionMaps( map2, map1 );
##  [ [ 1, 2 ], [ 2, 3 ], 3, [ 1, 2 ] ]
##  gap> CompositionMaps( map1, map2 );
##  [ [ 1, 2, 3, 4 ], [ 2 .. 4 ], [ 2 .. 4 ], [ 4, 5 ], [ 4, 5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CompositionMaps" );


#############################################################################
##
#F  InverseMap( <paramap> ) . . . . . . . . . . inverse of a parametrized map
##
##  <#GAPDoc Label="InverseMap">
##  <ManSection>
##  <Func Name="InverseMap" Arg='paramap'/>
##
##  <Description>
##  For a parametrized map <A>paramap</A>,
##  <Ref Func="InverseMap"/> returns a mutable parametrized map whose
##  <M>i</M>-th entry is unbound if <M>i</M> is not in the image of
##  <A>paramap</A>, equal to <M>j</M> if <M>i</M> is (in) the image of
##  <C><A>paramap</A>[<A>j</A>]</C> exactly for <M>j</M>,
##  and equal to the set of all preimages of <M>i</M> under <A>paramap</A>
##  otherwise.
##  <P/>
##  We have
##  <C>CompositionMaps( <A>paramap</A>, InverseMap( <A>paramap</A> ) )</C>
##  the identity map.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "2.A5" );;  f:= CharacterTable( "A5" );;
##  gap> fus:= GetFusionMap( tbl, f );
##  [ 1, 1, 2, 3, 3, 4, 4, 5, 5 ]
##  gap> inv:= InverseMap( fus );
##  [ [ 1, 2 ], 3, [ 4, 5 ], [ 6, 7 ], [ 8, 9 ] ]
##  gap> CompositionMaps( fus, inv );
##  [ 1, 2, 3, 4, 5 ]
##  gap> # transfer a power map ``up'' to the factor group
##  gap> pow:= PowerMap( tbl, 2 );
##  [ 1, 1, 2, 4, 4, 8, 8, 6, 6 ]
##  gap> CompositionMaps( fus, CompositionMaps( pow, inv ) );
##  [ 1, 1, 3, 5, 4 ]
##  gap> last = PowerMap( f, 2 );
##  true
##  gap> # transfer a power map of the factor group ``down'' to the group
##  gap> CompositionMaps( inv, CompositionMaps( PowerMap( f, 2 ), fus ) );
##  [ [ 1, 2 ], [ 1, 2 ], [ 1, 2 ], [ 4, 5 ], [ 4, 5 ], [ 8, 9 ],
##    [ 8, 9 ], [ 6, 7 ], [ 6, 7 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InverseMap" );


#############################################################################
##
#F  ProjectionMap( <fusionmap> ) . . . .  projection corresp. to a fusion map
##
##  <#GAPDoc Label="ProjectionMap">
##  <ManSection>
##  <Func Name="ProjectionMap" Arg='fusionmap'/>
##
##  <Description>
##  For a map <A>fusionmap</A>,
##  <Ref Func="ProjectionMap"/> returns a parametrized map
##  whose <M>i</M>-th entry is unbound if <M>i</M> is not in the image of
##  <A>fusionmap</A>,
##  and equal to <M>j</M> if <M>j</M> is the smallest position such that
##  <M>i</M> is the image of <A>fusionmap</A><C>[</C><M>j</M><C>]</C>.
##  <P/>
##  We have
##  <C>CompositionMaps( <A>fusionmap</A>, ProjectionMap( <A>fusionmap</A> ) )</C>
##  the identity map, i.e., first projecting and then fusing yields the
##  identity.
##  Note that <A>fusionmap</A> must <E>not</E> be a parametrized map.
##  <P/>
##  <Example><![CDATA[
##  gap> ProjectionMap( [ 1, 1, 1, 2, 2, 2, 3, 4, 5, 5, 5, 6, 6, 6 ] );
##  [ 1, 4, 7, 8, 9, 12 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ProjectionMap" );


#############################################################################
##
#F  Indirected( <character>, <paramap> )
##
##  <#GAPDoc Label="Indirected">
##  <ManSection>
##  <Func Name="Indirected" Arg='character, paramap'/>
##
##  <Description>
##  For a map <A>character</A> and a parametrized map <A>paramap</A>,
##  <Ref Func="Indirected"/> returns a parametrized map whose entry at
##  position <M>i</M> is
##  <A>character</A><C>[ </C><A>paramap</A><C>[</C><M>i</M><C>] ]</C>
##  if <A>paramap</A><C>[</C><M>i</M><C>]</C> is an integer,
##  and an unknown (see Chapter&nbsp;<Ref Chap="Unknowns"/>) otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "M12" );;
##  gap> fus:= [ 1, 3, 4, [ 6, 7 ], 8, 10, [ 11, 12 ], [ 11, 12 ],
##  >            [ 14, 15 ], [ 14, 15 ] ];;
##  gap> List( Irr( tbl ){ [ 1 .. 6 ] }, x -> Indirected( x, fus ) );
##  [ [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
##    [ 11, 3, 2, Unknown(9), 1, 0, Unknown(10), Unknown(11), 0, 0 ],
##    [ 11, 3, 2, Unknown(12), 1, 0, Unknown(13), Unknown(14), 0, 0 ],
##    [ 16, 0, -2, 0, 1, 0, 0, 0, Unknown(15), Unknown(16) ],
##    [ 16, 0, -2, 0, 1, 0, 0, 0, Unknown(17), Unknown(18) ],
##    [ 45, -3, 0, 1, 0, 0, -1, -1, 1, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Indirected" );


#############################################################################
##
#F  Parametrized( <list> )
##
##  <#GAPDoc Label="Parametrized">
##  <ManSection>
##  <Func Name="Parametrized" Arg='list'/>
##
##  <Description>
##  For a list <A>list</A> of (parametrized) maps of the same length,
##  <Ref Func="Parametrized"/> returns the smallest parametrized map
##  containing all elements of <A>list</A>.
##  <P/>
##  <Ref Func="Parametrized"/> is the inverse function to
##  <Ref Func="ContainedMaps"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> Parametrized( [ [ 1, 2, 3, 4, 5 ], [ 1, 3, 2, 4, 5 ],
##  >                    [ 1, 2, 3, 4, 6 ] ] );
##  [ 1, [ 2, 3 ], [ 2, 3 ], 4, [ 5, 6 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Parametrized" );


#############################################################################
##
#F  ContainedMaps( <paramap> )
##
##  <#GAPDoc Label="ContainedMaps">
##  <ManSection>
##  <Func Name="ContainedMaps" Arg='paramap'/>
##
##  <Description>
##  For a parametrized map <A>paramap</A>,
##  <Ref Func="ContainedMaps"/> returns the set of all
##  maps contained in <A>paramap</A>.
##  <P/>
##  <Ref Func="ContainedMaps"/> is the inverse function to
##  <Ref Func="Parametrized"/> in the sense that
##  <C>Parametrized( ContainedMaps( <A>paramap</A> ) )</C>
##  is equal to <A>paramap</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ContainedMaps( [ 1, [ 2, 3 ], [ 2, 3 ], 4, [ 5, 6 ] ] );
##  [ [ 1, 2, 2, 4, 5 ], [ 1, 2, 2, 4, 6 ], [ 1, 2, 3, 4, 5 ],
##    [ 1, 2, 3, 4, 6 ], [ 1, 3, 2, 4, 5 ], [ 1, 3, 2, 4, 6 ],
##    [ 1, 3, 3, 4, 5 ], [ 1, 3, 3, 4, 6 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ContainedMaps" );


#############################################################################
##
#F  UpdateMap( <character>, <paramap>, <indirected> )
##
##  <#GAPDoc Label="UpdateMap">
##  <ManSection>
##  <Func Name="UpdateMap" Arg='character, paramap, indirected'/>
##
##  <Description>
##  Let <A>character</A> be a map, <A>paramap</A> a parametrized map,
##  and <A>indirected</A> a parametrized map that is contained in
##  <C>CompositionMaps( <A>character</A>, <A>paramap</A> )</C>.
##  <P/>
##  Then <Ref Func="UpdateMap"/> changes <A>paramap</A> to the parametrized
##  map containing exactly the maps whose composition with <A>character</A>
##  is equal to <A>indirected</A>.
##  <P/>
##  If a contradiction is detected then <K>false</K> is returned immediately,
##  otherwise <K>true</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable("S4(4).2");; tbl:= CharacterTable("He");;
##  gap> fus:= InitFusion( subtbl, tbl );;
##  gap> fus;
##  [ 1, 2, 2, [ 2, 3 ], 4, 4, [ 7, 8 ], [ 7, 8 ], 9, 9, 9, [ 10, 11 ],
##    [ 10, 11 ], 18, 18, 25, 25, [ 26, 27 ], [ 26, 27 ], 2, [ 6, 7 ],
##    [ 6, 7 ], [ 6, 7, 8 ], 10, 10, 17, 17, 18, [ 19, 20 ], [ 19, 20 ] ]
##  gap> chi:= Irr( tbl )[2];
##  Character( CharacterTable( "He" ), [ 51, 11, 3, 6, 0, 3, 3, -1, 1, 2,
##    0, 3*E(7)+3*E(7)^2+3*E(7)^4, 3*E(7)^3+3*E(7)^5+3*E(7)^6, 2,
##    E(7)+E(7)^2+2*E(7)^3+E(7)^4+2*E(7)^5+2*E(7)^6,
##    2*E(7)+2*E(7)^2+E(7)^3+2*E(7)^4+E(7)^5+E(7)^6, 1, 1, 0, 0,
##    -E(7)-E(7)^2-E(7)^4, -E(7)^3-E(7)^5-E(7)^6, E(7)+E(7)^2+E(7)^4,
##    E(7)^3+E(7)^5+E(7)^6, 1, 0, 0, -1, -1, 0, 0, E(7)+E(7)^2+E(7)^4,
##    E(7)^3+E(7)^5+E(7)^6 ] )
##  gap> filt:= Filtered( Irr( subtbl ), x -> x[1] = 50 );
##  [ Character( CharacterTable( "S4(4).2" ),
##      [ 50, 10, 10, 2, 5, 5, -2, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, -1, -1,
##        10, 2, 2, 2, 1, 1, 0, 0, 0, -1, -1 ] ),
##    Character( CharacterTable( "S4(4).2" ),
##      [ 50, 10, 10, 2, 5, 5, -2, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, -1, -1,
##        -10, -2, -2, -2, -1, -1, 0, 0, 0, 1, 1 ] ) ]
##  gap> UpdateMap( chi, fus, filt[1] + TrivialCharacter( subtbl ) );
##  true
##  gap> fus;
##  [ 1, 2, 2, 3, 4, 4, 8, 7, 9, 9, 9, 10, 10, 18, 18, 25, 25,
##    [ 26, 27 ], [ 26, 27 ], 2, [ 6, 7 ], [ 6, 7 ], [ 6, 7 ], 10, 10,
##    17, 17, 18, [ 19, 20 ], [ 19, 20 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "UpdateMap" );


#############################################################################
##
#F  MeetMaps( <paramap1>, <paramap2> )
##
##  <#GAPDoc Label="MeetMaps">
##  <ManSection>
##  <Func Name="MeetMaps" Arg='paramap1, paramap2'/>
##
##  <Description>
##  For two parametrized maps <A>paramap1</A> and <A>paramap2</A>,
##  <Ref Func="MeetMaps"/> changes <A>paramap1</A> such that the image of
##  class <M>i</M> is the intersection of
##  <A>paramap1</A><C>[</C><M>i</M><C>]</C>
##  and <A>paramap2</A><C>[</C><M>i</M><C>]</C>.
##  <P/>
##  If this implies that no images remain for a class, the position of such a
##  class is returned.
##  If no such inconsistency occurs,
##  <Ref Func="MeetMaps"/> returns <K>true</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> map1:= [ [ 1, 2 ], [ 3, 4 ], 5, 6, [ 7, 8, 9 ] ];;
##  gap> map2:= [ [ 1, 3 ], [ 3, 4 ], [ 5, 6 ], 6, [ 8, 9, 10 ] ];;
##  gap> MeetMaps( map1, map2 );  map1;
##  true
##  [ 1, [ 3, 4 ], 5, 6, [ 8, 9 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MeetMaps" );


#############################################################################
##
#F  ImproveMaps( <map2>, <map1>, <composition>, <class> )
##
##  <ManSection>
##  <Func Name="ImproveMaps" Arg='map2, map1, composition, class'/>
##
##  <Description>
##  <Ref Func="ImproveMaps"/> is a utility for
##  <Ref Func="CommutativeDiagram"/> and <Ref Func="TestConsistencyMaps"/>.
##  <P/>
##  <A>composition</A> must be a set that is known to be an upper bound for
##  the composition <M>( <A>map2</A> \circ <A>map1</A> )[ <A>class</A> ]</M>.
##  If <C><A>map1</A>[ <A>class</A> ]</C><M> = x</M> is unique then
##  <M><A>map2</A>[ x ]</M> must be a set,
##  it will be replaced by its intersection with <A>composition</A>;
##  if <A>map1</A>[ <A>class</A> ] is a set then all elements <C>x</C> with
##  empty <C>Intersection( <A>map2</A>[ x ], <A>composition</A> )</C>
##  are excluded.
##  <P/>
##  <Ref Func="ImproveMaps"/> returns
##  <List>
##  <Mark>0</Mark>
##  <Item>
##    if no improvement was found,
##  </Item>
##  <Mark>-1</Mark>
##  <Item>
##    if <A>map1</A>[ <A>class</A> ] was improved,
##  </Item>
##  <Mark><A>x</A></Mark>
##  <Item>
##    if <A>map2</A>[ <A>x</A> ] was improved.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ImproveMaps" );


#############################################################################
##
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4>[,
#F                      <improvements>] )
##
##  <#GAPDoc Label="CommutativeDiagram">
##  <ManSection>
##  <Func Name="CommutativeDiagram"
##  Arg='paramap1, paramap2, paramap3, paramap4[, improvements]'/>
##
##  <Description>
##  Let <A>paramap1</A>, <A>paramap2</A>, <A>paramap3</A>, <A>paramap4</A> be
##  parametrized maps covering parametrized maps <M>f_1</M>, <M>f_2</M>,
##  <M>f_3</M>, <M>f_4</M> with the property
##  that <C>CompositionMaps</C><M>( f_2, f_1 )</M> is equal to
##  <C>CompositionMaps</C><M>( f_4, f_3 )</M>.
##  <P/>
##  <Ref Func="CommutativeDiagram"/> checks this consistency,
##  and changes the arguments such that all possible images are removed that
##  cannot occur in the parametrized maps <M>f_i</M>.
##  <P/>
##  The return value is <K>fail</K> if an inconsistency was found.
##  Otherwise a record with the components <C>imp1</C>, <C>imp2</C>,
##  <C>imp3</C>, <C>imp4</C> is returned, each bound to the list of positions
##  where the corresponding parametrized map was changed,
##  <P/>
##  The optional argument <A>improvements</A> must be a record with
##  components <C>imp1</C>, <C>imp2</C>, <C>imp3</C>, <C>imp4</C>.
##  If such a record is specified then only diagrams are considered where
##  entries of the <M>i</M>-th component occur as preimages of the
##  <M>i</M>-th parametrized map.
##  <P/>
##  When an inconsistency is detected,
##  <Ref Func="CommutativeDiagram"/> immediately returns <K>fail</K>.
##  Otherwise a record is returned that contains four lists <C>imp1</C>,
##  <M>\ldots</M>, <C>imp4</C>:
##  The <M>i</M>-th component is the list of classes where the <M>i</M>-th
##  argument was changed.
##  <P/>
##  <Example><![CDATA[
##  gap> map1:= [[ 1, 2, 3 ], [ 1, 3 ]];; map2:= [[ 1, 2 ], 1, [ 1, 3 ]];;
##  gap> map3:= [ [ 2, 3 ], 3 ];;  map4:= [ , 1, 2, [ 1, 2 ] ];;
##  gap> imp:= CommutativeDiagram( map1, map2, map3, map4 );
##  rec( imp1 := [ 2 ], imp2 := [ 1 ], imp3 := [  ], imp4 := [  ] )
##  gap> map1;  map2;  map3;  map4;
##  [ [ 1, 2, 3 ], 1 ]
##  [ 2, 1, [ 1, 3 ] ]
##  [ [ 2, 3 ], 3 ]
##  [ , 1, 2, [ 1, 2 ] ]
##  gap> imp2:= CommutativeDiagram( map1, map2, map3, map4, imp );
##  rec( imp1 := [  ], imp2 := [  ], imp3 := [  ], imp4 := [  ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CommutativeDiagram" );


#############################################################################
##
#F  CheckFixedPoints( <inside1>, <between>, <inside2> )
##
##  <#GAPDoc Label="CheckFixedPoints">
##  <ManSection>
##  <Func Name="CheckFixedPoints" Arg='inside1, between, inside2'/>
##
##  <Description>
##  Let <A>inside1</A>, <A>between</A>, <A>inside2</A> be parametrized maps,
##  where <A>between</A> is assumed to map each fixed point of <A>inside1</A>
##  (that is, <A>inside1</A><C>[</C><M>i</M><C>] = </C><A>i</A>)
##  to a fixed point of <A>inside2</A>
##  (that is, <A>between</A><C>[</C><M>i</M><C>]</C> is either an integer
##  that is fixed by <A>inside2</A> or a list that has nonempty intersection
##  with the union of its images under <A>inside2</A>).
##  <Ref Func="CheckFixedPoints"/> changes <A>between</A> and <A>inside2</A>
##  by removing all those entries violate this condition.
##  <P/>
##  When an inconsistency is detected,
##  <Ref Func="CheckFixedPoints"/> immediately returns <K>fail</K>.
##  Otherwise the list of positions is returned where changes occurred.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "L4(3).2_2" );;
##  gap> tbl:= CharacterTable( "O7(3)" );;
##  gap> fus:= InitFusion( subtbl, tbl );;  fus{ [ 48, 49 ] };
##  [ [ 54, 55, 56, 57 ], [ 54, 55, 56, 57 ] ]
##  gap> CheckFixedPoints( ComputedPowerMaps( subtbl )[5], fus,
##  >        ComputedPowerMaps( tbl )[5] );
##  [ 48, 49 ]
##  gap> fus{ [ 48, 49 ] };
##  [ [ 56, 57 ], [ 56, 57 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CheckFixedPoints" );


#############################################################################
##
#F  TransferDiagram( <inside1>, <between>, <inside2>[, <improvements>] )
##
##  <#GAPDoc Label="TransferDiagram">
##  <ManSection>
##  <Func Name="TransferDiagram"
##   Arg='inside1, between, inside2[, improvements]'/>
##
##  <Description>
##  Let <A>inside1</A>, <A>between</A>, <A>inside2</A> be parametrized maps
##  covering parametrized maps <M>m_1</M>, <M>f</M>, <M>m_2</M> with the
##  property that <C>CompositionMaps</C><M>( m_2, f )</M> is equal to
##  <C>CompositionMaps</C><M>( f, m_1 )</M>.
##  <P/>
##  <Ref Func="TransferDiagram"/> checks this consistency, and changes the
##  arguments such that all possible images are removed that cannot occur in
##  the parametrized maps <M>m_i</M> and <M>f</M>.
##  <P/>
##  So <Ref Func="TransferDiagram"/> is similar to
##  <Ref Func="CommutativeDiagram"/>,
##  but <A>between</A> occurs twice in each diagram checked.
##  <P/>
##  If a record <A>improvements</A> with fields <C>impinside1</C>,
##  <C>impbetween</C>, and <C>impinside2</C> is specified,
##  only those diagrams with elements of <C>impinside1</C> as preimages of
##  <A>inside1</A>, elements of <C>impbetween</C> as preimages of
##  <A>between</A> or elements of <C>impinside2</C> as preimages of
##  <A>inside2</A> are considered.
##  <P/>
##  When an inconsistency is detected,
##  <Ref Func="TransferDiagram"/> immediately returns <K>fail</K>.
##  Otherwise a record is returned that contains three lists
##  <C>impinside1</C>, <C>impbetween</C>, and <C>impinside2</C> of positions
##  where the arguments were changed.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "2F4(2)" );;  tbl:= CharacterTable( "Ru" );;
##  gap> fus:= InitFusion( subtbl, tbl );;
##  gap> permchar:= Sum( Irr( tbl ){ [ 1, 5, 6 ] } );;
##  gap> CheckPermChar( subtbl, tbl, fus, permchar );; fus;
##  [ 1, 2, 2, 4, 5, 7, 8, 9, 11, 14, 14, [ 13, 15 ], 16, [ 18, 19 ], 20,
##    [ 25, 26 ], [ 25, 26 ], 5, 5, 6, 8, 14, [ 13, 15 ], [ 18, 19 ],
##    [ 18, 19 ], [ 25, 26 ], [ 25, 26 ], 27, 27 ]
##  gap> tr:= TransferDiagram(PowerMap( subtbl, 2), fus, PowerMap(tbl, 2));
##  rec( impbetween := [ 12, 23 ], impinside1 := [  ], impinside2 := [  ]
##   )
##  gap> tr:= TransferDiagram(PowerMap(subtbl, 3), fus, PowerMap( tbl, 3 ));
##  rec( impbetween := [ 14, 24, 25 ], impinside1 := [  ],
##    impinside2 := [  ] )
##  gap> tr:= TransferDiagram( PowerMap(subtbl, 3), fus, PowerMap(tbl, 3),
##  >             tr );
##  rec( impbetween := [  ], impinside1 := [  ], impinside2 := [  ] )
##  gap> fus;
##  [ 1, 2, 2, 4, 5, 7, 8, 9, 11, 14, 14, 15, 16, 18, 20, [ 25, 26 ],
##    [ 25, 26 ], 5, 5, 6, 8, 14, 13, 19, 19, [ 25, 26 ], [ 25, 26 ], 27,
##    27 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TransferDiagram" );


#############################################################################
##
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2>[, <fusimp>] )
##
##  <#GAPDoc Label="TestConsistencyMaps">
##  <ManSection>
##  <Func Name="TestConsistencyMaps"
##   Arg='powermap1, fusionmap, powermap2[, fusimp]'/>
##
##  <Description>
##  Let <A>powermap1</A> and <A>powermap2</A> be lists of parametrized maps,
##  and <A>fusionmap</A> a parametrized map,
##  such that for each <M>i</M>, the <M>i</M>-th entry in <A>powermap1</A>,
##  <A>fusionmap</A>, and the <M>i</M>-th entry in <A>powermap2</A>
##  (if bound) are valid arguments for <Ref Func="TransferDiagram"/>.
##  So a typical situation for applying <Ref Func="TestConsistencyMaps"/> is
##  that <A>fusionmap</A> is an approximation of a class fusion,
##  and <A>powermap1</A>, <A>powermap2</A> are the lists of power maps of the
##  subgroup and the group.
##  <P/>
##  <Ref Func="TestConsistencyMaps"/> repeatedly applies
##  <Ref Func="TransferDiagram"/> to these arguments for all <M>i</M> until
##  no more changes occur.
##  <P/>
##  If a list <A>fusimp</A> is specified then only those diagrams with
##  elements of <A>fusimp</A> as preimages of <A>fusionmap</A> are
##  considered.
##  <P/>
##  When an inconsistency is detected,
##  <Ref Func="TestConsistencyMaps"/> immediately returns <K>false</K>.
##  Otherwise <K>true</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "2F4(2)" );;  tbl:= CharacterTable( "Ru" );;
##  gap> fus:= InitFusion( subtbl, tbl );;
##  gap> permchar:= Sum( Irr( tbl ){ [ 1, 5, 6 ] } );;
##  gap> CheckPermChar( subtbl, tbl, fus, permchar );; fus;
##  [ 1, 2, 2, 4, 5, 7, 8, 9, 11, 14, 14, [ 13, 15 ], 16, [ 18, 19 ], 20,
##    [ 25, 26 ], [ 25, 26 ], 5, 5, 6, 8, 14, [ 13, 15 ], [ 18, 19 ],
##    [ 18, 19 ], [ 25, 26 ], [ 25, 26 ], 27, 27 ]
##  gap> TestConsistencyMaps( ComputedPowerMaps( subtbl ), fus,
##  >        ComputedPowerMaps( tbl ) );
##  true
##  gap> fus;
##  [ 1, 2, 2, 4, 5, 7, 8, 9, 11, 14, 14, 15, 16, 18, 20, [ 25, 26 ],
##    [ 25, 26 ], 5, 5, 6, 8, 14, 13, 19, 19, [ 25, 26 ], [ 25, 26 ], 27,
##    27 ]
##  gap> Indeterminateness( fus );
##  16
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestConsistencyMaps" );


#############################################################################
##
#F  Indeterminateness( <paramap> ) . . . . the indeterminateness of a paramap
##
##  <#GAPDoc Label="Indeterminateness">
##  <ManSection>
##  <Func Name="Indeterminateness" Arg='paramap'/>
##
##  <Description>
##  For a parametrized map <A>paramap</A>, <Ref Func="Indeterminateness"/>
##  returns the number of maps contained in <A>paramap</A>, that is,
##  the product of lengths of lists in <A>paramap</A> denoting lists of
##  several images.
##  <P/>
##  <Example><![CDATA[
##  gap> Indeterminateness([ 1, [ 2, 3 ], [ 4, 5 ], [ 6, 7, 8, 9, 10 ], 11 ]);
##  20
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Indeterminateness" );


#############################################################################
##
#F  IndeterminatenessInfo( <paramap> )
##
##  <ManSection>
##  <Func Name="IndeterminatenessInfo" Arg='paramap'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "IndeterminatenessInfo" );


#############################################################################
##
#F  PrintAmbiguity( <list>, <paramap> ) . . . .  ambiguity of characters with
#F                                                       respect to a paramap
##
##  <#GAPDoc Label="PrintAmbiguity">
##  <ManSection>
##  <Func Name="PrintAmbiguity" Arg='list, paramap'/>
##
##  <Description>
##  For each map in the list <A>list</A>, <Ref Func="PrintAmbiguity"/> prints
##  its position in <A>list</A>,
##  the indeterminateness (see&nbsp;<Ref Func="Indeterminateness"/>) of the
##  composition with the parametrized map <A>paramap</A>,
##  and the list of positions where a list of images occurs in this
##  composition.
##  <P/>
##  <Example><![CDATA[
##  gap> paramap:= [ 1, [ 2, 3 ], [ 3, 4 ], [ 2, 3, 4 ], 5 ];;
##  gap> list:= [ [ 1, 1, 1, 1, 1 ], [ 1, 1, 2, 2, 3 ], [ 1, 2, 3, 4, 5 ] ];;
##  gap> PrintAmbiguity( list, paramap );
##  1 1 [  ]
##  2 4 [ 2, 4 ]
##  3 12 [ 2, 3, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrintAmbiguity" );


#############################################################################
##
#F  ContainedSpecialVectors( <tbl>, <chars>, <paracharacter>, <func> )
#F  IntScalarProducts( <tbl>, <chars>, <candidate> )
#F  NonnegIntScalarProducts( <tbl>, <chars>, <candidate> )
#F  ContainedPossibleVirtualCharacters( <tbl>, <chars>, <paracharacter> )
#F  ContainedPossibleCharacters( <tbl>, <chars>, <paracharacter> )
##
##  <#GAPDoc Label="ContainedSpecialVectors">
##  <ManSection>
##  <Func Name="ContainedSpecialVectors"
##   Arg='tbl, chars, paracharacter, func'/>
##  <Func Name="IntScalarProducts" Arg='tbl, chars, candidate'/>
##  <Func Name="NonnegIntScalarProducts" Arg='tbl, chars, candidate'/>
##  <Func Name="ContainedPossibleVirtualCharacters"
##   Arg='tbl, chars, paracharacter'/>
##  <Func Name="ContainedPossibleCharacters"
##   Arg='tbl, chars, paracharacter'/>
##
##  <Description>
##  Let <A>tbl</A> be an ordinary character table,
##  <A>chars</A> a list of class functions (or values lists),
##  <A>paracharacter</A> a parametrized class function of <A>tbl</A>,
##  and <A>func</A> a function that expects the three arguments <A>tbl</A>,
##  <A>chars</A>, and a values list of a class function, and that returns
##  either <K>true</K> or <K>false</K>.
##  <P/>
##  <Ref Func="ContainedSpecialVectors"/> returns
##  the list of all those elements <A>vec</A> of <A>paracharacter</A> that
##  have integral norm,
##  have integral scalar product with the principal character of <A>tbl</A>,
##  and that satisfy
##  <A>func</A><C>( </C><A>tbl</A>, <A>chars</A>, <A>vec</A> <C>) = </C><K>true</K>.
##  <P/>
##  Two special cases of <A>func</A> are the check whether the scalar
##  products in <A>tbl</A> between the vector <A>vec</A> and all lists in
##  <A>chars</A> are integers or nonnegative integers, respectively.
##  These functions are accessible as global variables
##  <Ref Func="IntScalarProducts"/> and
##  <Ref Func="NonnegIntScalarProducts"/>,
##  and <Ref Func="ContainedPossibleVirtualCharacters"/> and
##  <Ref Func="ContainedPossibleCharacters"/> provide access to these special
##  cases of <Ref Func="ContainedSpecialVectors"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "HSM12" );;  tbl:= CharacterTable( "HS" );;
##  gap> fus:= InitFusion( subtbl, tbl );;
##  gap> rest:= CompositionMaps( Irr( tbl )[8], fus );
##  [ 231, [ -9, 7 ], [ -9, 7 ], [ -9, 7 ], 6, 15, 15, [ -1, 15 ],
##    [ -1, 15 ], 1, [ 1, 6 ], [ 1, 6 ], [ 1, 6 ], [ 1, 6 ], [ -2, 0 ],
##    [ 1, 2 ], [ 1, 2 ], [ 1, 2 ], 0, 0, 1, 0, 0, 0, 0 ]
##  gap> irr:= Irr( subtbl );;
##  gap> # no further condition
##  gap> cont1:= ContainedSpecialVectors( subtbl, irr, rest,
##  >                function( tbl, chars, vec ) return true; end );;
##  gap> Length( cont1 );
##  24
##  gap> # require scalar products to be integral
##  gap> cont2:= ContainedSpecialVectors( subtbl, irr, rest,
##  >                IntScalarProducts );
##  [ [ 231, 7, -9, -9, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, 7, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, -9, 6, 15, 15, 15, 15, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, 7, 6, 15, 15, 15, 15, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ] ]
##  gap> # additionally require scalar products to be nonnegative
##  gap> cont3:= ContainedSpecialVectors( subtbl, irr, rest,
##  >                NonnegIntScalarProducts );
##  [ [ 231, 7, -9, -9, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, 7, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ] ]
##  gap> cont2 = ContainedPossibleVirtualCharacters( subtbl, irr, rest );
##  true
##  gap> cont3 = ContainedPossibleCharacters( subtbl, irr, rest );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareGlobalFunction( "ContainedSpecialVectors" );
DeclareGlobalFunction( "IntScalarProducts" );
DeclareGlobalFunction( "NonnegIntScalarProducts" );
DeclareGlobalFunction( "ContainedPossibleVirtualCharacters" );
DeclareGlobalFunction( "ContainedPossibleCharacters" );


#############################################################################
##
#F  ContainedDecomposables( <constituents>, <moduls>, <parachar>, <func> )
#F  ContainedCharacters( <tbl>, <constituents>, <parachar> )
##
##  <#GAPDoc Label="ContainedDecomposables">
##  <ManSection>
##  <Func Name="ContainedDecomposables"
##   Arg='constituents, moduls, parachar, func'/>
##  <Func Name="ContainedCharacters" Arg='tbl, constituents, parachar'/>
##
##  <Description>
##  For these functions,
##  let <A>constituents</A> be a list of <E>rational</E> class functions,
##  <A>moduls</A> a list of positive integers,
##  <A>parachar</A> a parametrized rational class function,
##  <A>func</A> a function that returns either <K>true</K> or <K>false</K>
##  when called with (a values list of) a class function,
##  and <A>tbl</A> a character table.
##  <P/>
##  <Ref Func="ContainedDecomposables"/> returns the set of all elements
##  <M>\chi</M> of <A>parachar</A> that satisfy
##  <A>func</A><M>( \chi ) =</M> <K>true</K>
##  and that lie in the <M>&ZZ;</M>-lattice spanned by <A>constituents</A>,
##  modulo <A>moduls</A>.
##  The latter means they lie in the <M>&ZZ;</M>-lattice spanned by
##  <A>constituents</A> and the set
##  <M>\{ <A>moduls</A>[i] \cdot e_i; 1 \leq i \leq n \}</M>
##  where <M>n</M> is the length of <A>parachar</A> and  <M>e_i</M> is the
##  <M>i</M>-th standard basis vector.
##  <P/>
##  One application of <Ref Func="ContainedDecomposables"/> is the following.
##  <A>constituents</A> is a list of (values lists of) rational characters of
##  an ordinary character table <A>tbl</A>,
##  <A>moduls</A> is the list of centralizer orders of <A>tbl</A>
##  (see&nbsp;<Ref Attr="SizesCentralizers"/>),
##  and <A>func</A> checks whether a vector in the lattice mentioned above
##  has nonnegative integral scalar product in <A>tbl</A> with all entries of
##  <A>constituents</A>.
##  This situation is handled by <Ref Func="ContainedCharacters"/>.
##  Note that the entries of the result list are <E>not</E> necessary linear
##  combinations of <A>constituents</A>,
##  and they are <E>not</E> necessarily characters of <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "HSM12" );;  tbl:= CharacterTable( "HS" );;
##  gap> rat:= RationalizedMat( Irr( subtbl ) );;
##  gap> fus:= InitFusion( subtbl, tbl );;
##  gap> rest:= CompositionMaps( Irr( tbl )[8], fus );
##  [ 231, [ -9, 7 ], [ -9, 7 ], [ -9, 7 ], 6, 15, 15, [ -1, 15 ],
##    [ -1, 15 ], 1, [ 1, 6 ], [ 1, 6 ], [ 1, 6 ], [ 1, 6 ], [ -2, 0 ],
##    [ 1, 2 ], [ 1, 2 ], [ 1, 2 ], 0, 0, 1, 0, 0, 0, 0 ]
##  gap> # compute all vectors in the lattice
##  gap> ContainedDecomposables( rat, SizesCentralizers( subtbl ), rest,
##  >        ReturnTrue );
##  [ [ 231, 7, -9, -9, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, -9, 6, 15, 15, 15, 15, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, 7, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, 7, 6, 15, 15, 15, 15, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ] ]
##  gap> # compute only those vectors that are characters
##  gap> ContainedDecomposables( rat, SizesCentralizers( subtbl ), rest,
##  >        x -> NonnegIntScalarProducts( subtbl, Irr( subtbl ), x ) );
##  [ [ 231, 7, -9, -9, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ],
##    [ 231, 7, -9, 7, 6, 15, 15, -1, -1, 1, 6, 6, 1, 1, -2, 1, 2, 2, 0,
##        0, 1, 0, 0, 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ContainedDecomposables" );
DeclareGlobalFunction( "ContainedCharacters" );


#############################################################################
##
##  5. Subroutines for the Construction of Power Maps
##


#############################################################################
##
#F  InitPowerMap( <tbl>, <prime> )
##
##  <#GAPDoc Label="InitPowerMap">
##  <ManSection>
##  <Func Name="InitPowerMap" Arg='tbl, prime'/>
##
##  <Description>
##  For an ordinary character table <A>tbl</A> and a prime <A>prime</A>,
##  <Ref Func="InitPowerMap"/> returns a parametrized map that is a first
##  approximation of the <A>prime</A>-th powermap of <A>tbl</A>,
##  using the conditions 1.&nbsp;and 2.&nbsp;listed in the description of
##  <Ref Oper="PossiblePowerMaps"/>.
##  <P/>
##  If there are classes for which no images are possible, according to these
##  criteria, then <K>fail</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( "U4(3).4" );;
##  gap> pow:= InitPowerMap( t, 2 );
##  [ 1, 1, 3, 4, 5, [ 2, 16 ], [ 2, 16, 17 ], 8, 3, [ 3, 4 ],
##    [ 11, 12 ], [ 11, 12 ], [ 6, 7, 18, 19, 30, 31, 32, 33 ], 14,
##    [ 9, 20 ], 1, 1, 2, 2, 3, [ 3, 4, 5 ], [ 3, 4, 5 ],
##    [ 6, 7, 18, 19, 30, 31, 32, 33 ], 8, 9, 9, [ 9, 10, 20, 21, 22 ],
##    [ 11, 12 ], [ 11, 12 ], 16, 16, [ 2, 16 ], [ 2, 16 ], 17, 17,
##    [ 6, 18, 30, 31, 32, 33 ], [ 6, 18, 30, 31, 32, 33 ],
##    [ 6, 7, 18, 19, 30, 31, 32, 33 ], [ 6, 7, 18, 19, 30, 31, 32, 33 ],
##    20, 20, [ 9, 20 ], [ 9, 20 ], [ 9, 10, 20, 21, 22 ],
##    [ 9, 10, 20, 21, 22 ], 24, 24, [ 15, 25, 26, 40, 41, 42, 43 ],
##    [ 15, 25, 26, 40, 41, 42, 43 ], [ 28, 29 ], [ 28, 29 ], [ 28, 29 ],
##    [ 28, 29 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InitPowerMap" );


#############################################################################
##
##  <#GAPDoc Label="[7]{ctblmaps}">
##  In the argument lists of the functions
##  <Ref Func="Congruences" Label="for character tables"/>,
##  <Ref Func="ConsiderKernels"/>,
##  and <Ref Func="ConsiderSmallerPowerMaps"/>,
##  <A>tbl</A> is an ordinary character table,
##  <A>chars</A> a list of (values lists of) characters of <A>tbl</A>,
##  <A>prime</A> a prime integer,
##  <A>approxmap</A> a parametrized map that is an approximation for the
##  <A>prime</A>-th power map of <A>tbl</A>
##  (e.g., a list returned by <Ref Func="InitPowerMap"/>,
##  and <A>quick</A> a Boolean.
##  <P/>
##  The <A>quick</A> value <K>true</K> means that only those classes are
##  considered for which <A>approxmap</A> lists more than one possible image.
##  <#/GAPDoc>
##


#############################################################################
##
#F  Congruences( <tbl>, <chars>, <approxmap>, <prime>, <quick> )
##
##  <#GAPDoc Label="Congruences">
##  <ManSection>
##  <Func Name="Congruences" Arg='tbl, chars, approxmap, prime, quick'
##  Label="for character tables"/>
##
##  <Description>
##  <Ref Func="Congruences" Label="for character tables"/>
##  replaces the entries of <A>approxmap</A> by improved values,
##  according to condition 3.&nbsp;listed in the description
##  of <Ref Oper="PossiblePowerMaps"/>.
##  <P/>
##  For each class for which no images are possible according to the tests,
##  the new value of <A>approxmap</A> is an empty list.
##  <Ref Func="Congruences" Label="for character tables"/>
##  returns <K>true</K> if no such inconsistencies occur,
##  and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> Congruences( t, Irr( t ), pow, 2, false );  pow;
##  true
##  [ 1, 1, 3, 4, 5, 2, 2, 8, 3, 4, 11, 12, [ 6, 7 ], 14, 9, 1, 1, 2, 2,
##    3, 4, 5, [ 6, 7 ], 8, 9, 9, 10, 11, 12, 16, 16, 16, 16, 17, 17, 18,
##    18, [ 18, 19 ], [ 18, 19 ], 20, 20, 20, 20, 22, 22, 24, 24,
##    [ 25, 26 ], [ 25, 26 ], 28, 28, 29, 29 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Congruences" );


#############################################################################
##
#F  ConsiderKernels( <tbl>, <chars>, <approxmap>, <prime>, <quick> )
##
##  <#GAPDoc Label="ConsiderKernels">
##  <ManSection>
##  <Func Name="ConsiderKernels" Arg='tbl, chars, approxmap, prime, quick'/>
##
##  <Description>
##  <Ref Func="ConsiderKernels"/> replaces the entries of <A>approxmap</A> by
##  improved values, according to condition 4.&nbsp;listed in the description
##  of <Ref Oper="PossiblePowerMaps"/>.
##  <P/>
##  <Ref Func="Congruences" Label="for character tables"/>
##  returns <K>true</K> if the orders of the
##  kernels of all characters in <A>chars</A> divide the order of the group
##  of <A>tbl</A>, and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( "A7.2" );;  init:= InitPowerMap( t, 2 );
##  [ 1, 1, 3, 4, [ 2, 9, 10 ], 6, 3, 8, 1, 1, [ 2, 9, 10 ], 3, [ 3, 4 ],
##    6, [ 7, 12 ] ]
##  gap> ConsiderKernels( t, Irr( t ), init, 2, false );
##  true
##  gap> init;
##  [ 1, 1, 3, 4, 2, 6, 3, 8, 1, 1, 2, 3, [ 3, 4 ], 6, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConsiderKernels" );


#############################################################################
##
#F  ConsiderSmallerPowerMaps( <tbl>, <approxmap>, <prime>, <quick> )
##
##  <#GAPDoc Label="ConsiderSmallerPowerMaps">
##  <ManSection>
##  <Func Name="ConsiderSmallerPowerMaps"
##   Arg='tbl, approxmap, prime, quick'/>
##
##  <Description>
##  <Ref Func="ConsiderSmallerPowerMaps"/> replaces the entries of
##  <A>approxmap</A> by improved values,
##  according to condition 5.&nbsp;listed in the description of
##  <Ref Oper="PossiblePowerMaps"/>.
##  <P/>
##  <Ref Func="ConsiderSmallerPowerMaps"/> returns <K>true</K> if each class
##  admits at least one image after the checks, otherwise <K>false</K> is
##  returned.
##  If no element orders of <A>tbl</A> are stored
##  (see&nbsp;<Ref Attr="OrdersClassRepresentatives"/>) then <K>true</K> is
##  returned without any tests.
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( "3.A6" );;  init:= InitPowerMap( t, 5 );
##  [ 1, [ 2, 3 ], [ 2, 3 ], 4, [ 5, 6 ], [ 5, 6 ], [ 7, 8 ], [ 7, 8 ],
##    9, [ 10, 11 ], [ 10, 11 ], 1, [ 2, 3 ], [ 2, 3 ], 1, [ 2, 3 ],
##    [ 2, 3 ] ]
##  gap> Indeterminateness( init );
##  4096
##  gap> ConsiderSmallerPowerMaps( t, init, 5, false );
##  true
##  gap> Indeterminateness( init );
##  256
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConsiderSmallerPowerMaps" );


#############################################################################
##
#F  MinusCharacter( <character>, <primepowermap>, <prime> )
##
##  <#GAPDoc Label="MinusCharacter">
##  <ManSection>
##  <Func Name="MinusCharacter" Arg='character, primepowermap, prime'/>
##
##  <Description>
##  Let <A>character</A> be (the list of values of) a class function
##  <M>\chi</M>, <A>prime</A> a prime integer <M>p</M>, and
##  <A>primepowermap</A> a parametrized map that is an approximation of the
##  <M>p</M>-th power map for the character table of <M>\chi</M>.
##  <Ref Func="MinusCharacter"/> returns the parametrized map of values of
##  <M>\chi^{{p-}}</M>,
##  which is defined by
##  <M>\chi^{{p-}}(g) = ( \chi(g)^p - \chi(g^p) ) / p</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "S7" );;  pow:= InitPowerMap( tbl, 2 );;
##  gap> pow;
##  [ 1, 1, 3, 4, [ 2, 9, 10 ], 6, 3, 8, 1, 1, [ 2, 9, 10 ], 3, [ 3, 4 ],
##    6, [ 7, 12 ] ]
##  gap> chars:= Irr( tbl ){ [ 2 .. 5 ] };;
##  gap> List( chars, x -> MinusCharacter( x, pow, 2 ) );
##  [ [ 0, 0, 0, 0, [ 0, 1 ], 0, 0, 0, 0, 0, [ 0, 1 ], 0, 0, 0, [ 0, 1 ] ]
##      ,
##    [ 15, -1, 3, 0, [ -2, -1, 0 ], 0, -1, 1, 5, -3, [ 0, 1, 2 ], -1, 0,
##        0, [ 0, 1 ] ],
##    [ 15, -1, 3, 0, [ -1, 0, 2 ], 0, -1, 1, 5, -3, [ 1, 2, 4 ], -1, 0,
##        0, 1 ],
##    [ 190, -2, 1, 1, [ 0, 2 ], 0, 1, 1, -10, -10, [ 0, 2 ], -1, -1, 0,
##        [ -1, 0 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MinusCharacter" );


#############################################################################
##
#F  PowerMapsAllowedBySymmetrizations( <tbl>, <subchars>, <chars>,
#F                                     <approxmap>, <prime>, <parameters> )
##
##  <#GAPDoc Label="PowerMapsAllowedBySymmetrizations">
##  <ManSection>
##  <Func Name="PowerMapsAllowedBySymmetrizations"
##   Arg='tbl, subchars, chars, approxmap, prime, parameters'/>
##
##  <Description>
##  Let <A>tbl</A> be an ordinary character table,
##  <A>prime</A> a prime integer,
##  <A>approxmap</A> a parametrized map that is an approximation of the
##  <A>prime</A>-th power map of <A>tbl</A>
##  (e.g., a list returned by <Ref Func="InitPowerMap"/>,
##  <A>chars</A> and <A>subchars</A> two lists of (values lists of)
##  characters of <A>tbl</A>,
##  and <A>parameters</A> a record with components
##  <C>maxlen</C>, <C>minamb</C>, <C>maxamb</C> (three integers),
##  <C>quick</C> (a Boolean),
##  and <C>contained</C> (a function).
##  Usual values of <C>contained</C> are <Ref Func="ContainedCharacters"/> or
##  <Ref Func="ContainedPossibleCharacters"/>.
##  <P/>
##  <Ref Func="PowerMapsAllowedBySymmetrizations"/> replaces the entries of
##  <A>approxmap</A> by improved values,
##  according to condition 6.&nbsp;listed in the description of
##  <Ref Oper="PossiblePowerMaps"/>.
##  <P/>
##  More precisely, the strategy used is as follows.
##  <P/>
##  First, for each <M>\chi \in <A>chars</A></M>,
##  let <C>minus:= MinusCharacter(</C><M>\chi</M><C>, <A>approxmap</A>,
##  <A>prime</A>)</C>.
##  <List>
##  <Item>
##    If <C>Indeterminateness( minus )</C><M> = 1</M> and
##    <C><A>parameters</A>.quick = false</C> then the scalar products of
##    <C>minus</C> with <A>subchars</A> are checked;
##    if not all scalar products are nonnegative integers then
##    an empty list is returned,
##    otherwise <M>\chi</M> is deleted from the list of characters to
##    inspect.
##  </Item>
##  <Item>
##    Otherwise if <C>Indeterminateness( minus )</C> is smaller than
##    <C><A>parameters</A>.minamb</C> then <M>\chi</M> is deleted from the
##    list of characters.
##  </Item>
##  <Item>
##    If <C><A>parameters</A>.minamb</C> <M>\leq</M>
##    <C>Indeterminateness( minus )</C> <M>\leq</M>
##    <C><A>parameters</A>.maxamb</C> then
##    construct the list of contained class functions
##    <C>poss:= <A>parameters</A>.contained(<A>tbl</A>, <A>subchars</A>,
##    minus)</C> and <C>Parametrized( poss )</C>,
##    and improve the approximation of the power map using
##    <Ref Func="UpdateMap"/>.
##  </Item>
##  </List>
##  <P/>
##  If this yields no further immediate improvements then we branch.
##  If there is a character from <A>chars</A> left with less or equal
##  <C><A>parameters</A>.maxlen</C> possible symmetrizations,
##  compute the union of power maps allowed by these possibilities.
##  Otherwise we choose a class <M>C</M> such that the possible
##  symmetrizations of a character in <A>chars</A> differ at <M>C</M>,
##  and compute recursively the union of all allowed power maps with image
##  at <M>C</M> fixed in the set given by the current approximation of the
##  power map.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "U4(3).4" );;
##  gap> pow:= InitPowerMap( tbl, 2 );;
##  gap> Congruences( tbl, Irr( tbl ), pow, 2 );;  pow;
##  [ 1, 1, 3, 4, 5, 2, 2, 8, 3, 4, 11, 12, [ 6, 7 ], 14, 9, 1, 1, 2, 2,
##    3, 4, 5, [ 6, 7 ], 8, 9, 9, 10, 11, 12, 16, 16, 16, 16, 17, 17, 18,
##    18, [ 18, 19 ], [ 18, 19 ], 20, 20, 20, 20, 22, 22, 24, 24,
##    [ 25, 26 ], [ 25, 26 ], 28, 28, 29, 29 ]
##  gap> PowerMapsAllowedBySymmetrizations( tbl, Irr( tbl ), Irr( tbl ),
##  >       pow, 2, rec( maxlen:= 10, contained:= ContainedPossibleCharacters,
##  >       minamb:= 2, maxamb:= infinity, quick:= false ) );
##  [ [ 1, 1, 3, 4, 5, 2, 2, 8, 3, 4, 11, 12, 6, 14, 9, 1, 1, 2, 2, 3, 4,
##        5, 6, 8, 9, 9, 10, 11, 12, 16, 16, 16, 16, 17, 17, 18, 18, 18,
##        18, 20, 20, 20, 20, 22, 22, 24, 24, 25, 26, 28, 28, 29, 29 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PowerMapsAllowedBySymmetrizations" );

DeclareSynonym( "PowerMapsAllowedBySymmetrisations",
    PowerMapsAllowedBySymmetrizations );


#############################################################################
##
##  6. Subroutines for the Construction of Class Fusions
##


#############################################################################
##
#F  InitFusion( <subtbl>, <tbl> )
##
##  <#GAPDoc Label="InitFusion">
##  <ManSection>
##  <Func Name="InitFusion" Arg='subtbl, tbl'/>
##
##  <Description>
##  For two ordinary character tables <A>subtbl</A> and <A>tbl</A>,
##  <Ref Func="InitFusion"/> returns a parametrized map that is a first
##  approximation of the class fusion from <A>subtbl</A> to <A>tbl</A>,
##  using condition&nbsp;1.&nbsp;listed in the description of
##  <Ref Oper="PossibleClassFusions"/>.
##  <P/>
##  If there are classes for which no images are possible, according to this
##  criterion, then <K>fail</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "2F4(2)" );;  tbl:= CharacterTable( "Ru" );;
##  gap> fus:= InitFusion( subtbl, tbl );
##  [ 1, 2, 2, 4, [ 5, 6 ], [ 5, 6, 7, 8 ], [ 5, 6, 7, 8 ], [ 9, 10 ],
##    11, 14, 14, [ 13, 14, 15 ], [ 16, 17 ], [ 18, 19 ], 20, [ 25, 26 ],
##    [ 25, 26 ], [ 5, 6 ], [ 5, 6 ], [ 5, 6 ], [ 5, 6, 7, 8 ],
##    [ 13, 14, 15 ], [ 13, 14, 15 ], [ 18, 19 ], [ 18, 19 ], [ 25, 26 ],
##    [ 25, 26 ], [ 27, 28, 29 ], [ 27, 28, 29 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InitFusion" );


#############################################################################
##
#F  CheckPermChar( <subtbl>, <tbl>, <approxmap>, <permchar> )
##
##  <#GAPDoc Label="CheckPermChar">
##  <ManSection>
##  <Func Name="CheckPermChar" Arg='subtbl, tbl, approxmap, permchar'/>
##
##  <Description>
##  <Index>permutation character</Index>
##  <Ref Func="CheckPermChar"/> replaces the entries of the parametrized map
##  <A>approxmap</A> by improved values,
##  according to condition&nbsp;3.&nbsp;listed in the description of
##  <Ref Oper="PossibleClassFusions"/>.
##  <P/>
##  <Ref Func="CheckPermChar"/> returns <K>true</K> if no inconsistency
##  occurred, and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> permchar:= Sum( Irr( tbl ){ [ 1, 5, 6 ] } );;
##  gap> CheckPermChar( subtbl, tbl, fus, permchar ); fus;
##  true
##  [ 1, 2, 2, 4, 5, 7, 8, 9, 11, 14, 14, [ 13, 15 ], 16, [ 18, 19 ], 20,
##    [ 25, 26 ], [ 25, 26 ], 5, 5, 6, 8, 14, [ 13, 15 ], [ 18, 19 ],
##    [ 18, 19 ], [ 25, 26 ], [ 25, 26 ], 27, 27 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CheckPermChar" );


#############################################################################
##
#F  ConsiderTableAutomorphisms( <approxmap>, <grp> )
##
##  <#GAPDoc Label="ConsiderTableAutomorphisms">
##  <ManSection>
##  <Func Name="ConsiderTableAutomorphisms" Arg='approxmap, grp'/>
##
##  <Description>
##  <Index>table automorphisms</Index>
##  <Ref Func="ConsiderTableAutomorphisms"/> replaces the entries of the
##  parametrized map <A>approxmap</A> by improved values, according to
##  condition&nbsp;4.&nbsp;listed in the description of
##  <Ref Oper="PossibleClassFusions"/>.
##  <P/>
##  Afterwards exactly one representative of fusion maps (contained in
##  <A>approxmap</A>) in each orbit under the action of the permutation group
##  <A>grp</A> is contained in the modified parametrized map.
##  <P/>
##  <Ref Func="ConsiderTableAutomorphisms"/> returns the list of positions
##  where <A>approxmap</A> was changed.
##  <P/>
##  <Example><![CDATA[
##  gap> ConsiderTableAutomorphisms( fus, AutomorphismsOfTable( tbl ) );
##  [ 16 ]
##  gap> fus;
##  [ 1, 2, 2, 4, 5, 7, 8, 9, 11, 14, 14, [ 13, 15 ], 16, [ 18, 19 ], 20,
##    25, [ 25, 26 ], 5, 5, 6, 8, 14, [ 13, 15 ], [ 18, 19 ], [ 18, 19 ],
##    [ 25, 26 ], [ 25, 26 ], 27, 27 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConsiderTableAutomorphisms" );


#############################################################################
##
#F  FusionsAllowedByRestrictions( <subtbl>, <tbl>, <subchars>, <chars>,
#F                                <approxmap>, <parameters> )
##
##  <#GAPDoc Label="FusionsAllowedByRestrictions">
##  <ManSection>
##  <Func Name="FusionsAllowedByRestrictions"
##   Arg='subtbl, tbl, subchars, chars, approxmap, parameters'/>
##
##  <Description>
##  Let <A>subtbl</A> and <A>tbl</A> be ordinary character tables,
##  <A>subchars</A> and <A>chars</A> two lists of (values lists of)
##  characters of <A>subtbl</A> and <A>tbl</A>, respectively,
##  <A>approxmap</A> a parametrized map that is an approximation of the class
##  fusion of <A>subtbl</A> in <A>tbl</A>,
##  and <A>parameters</A> a record with the mandatory components
##  <C>maxlen</C>, <C>minamb</C>, <C>maxamb</C> (three integers),
##  <C>quick</C> (a Boolean),
##  and <C>contained</C> (a function, usual values are
##  <Ref Func="ContainedCharacters"/> or
##  <Ref Func="ContainedPossibleCharacters"/>);
##  optional components of the <A>parameters</A> record are
##  <C>testdec</C> (the function that tests the decomposability,
##  the default is <Ref Func="NonnegIntScalarProducts"/>),
##  <C>powermaps</C> (the power paps of <A>subtbl</A> that shall be used for
##  compatibility checks, the default is the <Ref Attr="ComputedPowerMaps"/>
##  value),
##  <C>subpowermaps</C> (the power paps of <A>tbl</A> that shall be used for
##  compatibility checks, the default is the <Ref Attr="ComputedPowerMaps"/>
##  value).
##  <P/>
##  <Ref Func="FusionsAllowedByRestrictions"/> replaces the entries of
##  <A>approxmap</A> by improved values,
##  according to condition 5.&nbsp;listed in the description of
##  <Ref Oper="PossibleClassFusions"/>.
##  <P/>
##  More precisely, the strategy used is as follows.
##  <P/>
##  First, for each <M>\chi \in <A>chars</A></M>,
##  let <C>restricted:= CompositionMaps( </C><M>\chi</M><C>,
##  <A>approxmap</A> )</C>.
##  <List>
##  <Item>
##    If <C>Indeterminateness( restricted )</C><M> = 1</M> and
##    <C><A>parameters</A>.quick = false</C> then the scalar products of
##    <C>restricted</C> with <A>subchars</A> are checked;
##    if not all scalar products are nonnegative integers then
##    an empty list is returned,
##    otherwise <M>\chi</M> is deleted from the list of characters to
##    inspect.
##  </Item>
##  <Item>
##    Otherwise if <C>Indeterminateness( minus )</C> is smaller than
##    <C><A>parameters</A>.minamb</C> then <M>\chi</M> is deleted from the
##    list of characters.
##  </Item>
##  <Item>
##    If <C><A>parameters</A>.minamb</C> <M>\leq</M>
##    <C>Indeterminateness( restricted )</C>
##    <M>\leq</M> <C><A>parameters</A>.maxamb</C> then construct
##    <C>poss:= <A>parameters</A>.contained( <A>subtbl</A>, <A>subchars</A>,
##    restricted )</C>
##    and <C>Parametrized( poss )</C>,
##    and improve the approximation of the fusion map using
##    <Ref Func="UpdateMap"/>.
##  </Item>
##  </List>
##  <!-- #T Would it help to exploit that the restriction of a <E>linear</E> character-->
##  <!-- #T is again a linear character (not only a linear combination of linear-->
##  <!-- #T characters?-->
##  <!-- #T Branching in these cases would yield a short list of possibilities,-->
##  <!-- #T so it should be recommended ...-->
##  <P/>
##  If this yields no further immediate improvements then we branch.
##  If there is a character from <A>chars</A> left with less or equal
##  <A>parameters</A><C>.maxlen</C> possible restrictions,
##  compute the union of fusion maps allowed by these possibilities.
##  Otherwise we choose a class <M>C</M> such that the possible restrictions
##  of a character in <A>chars</A> differ at <M>C</M>,
##  and compute recursively the union of all allowed fusion maps with image
##  at <M>C</M> fixed in the set given by the current approximation of the
##  fusion map.
##  <P/>
##  <Example><![CDATA[
##  gap> subtbl:= CharacterTable( "U3(3)" );;  tbl:= CharacterTable( "J4" );;
##  gap> fus:= InitFusion( subtbl, tbl );;
##  gap> TestConsistencyMaps( ComputedPowerMaps( subtbl ), fus,
##  >        ComputedPowerMaps( tbl ) );
##  true
##  gap> fus;
##  [ 1, 2, 4, 4, [ 5, 6 ], [ 5, 6 ], [ 5, 6 ], 10, [ 12, 13 ],
##    [ 12, 13 ], [ 14, 15, 16 ], [ 14, 15, 16 ], [ 21, 22 ], [ 21, 22 ] ]
##  gap> ConsiderTableAutomorphisms( fus, AutomorphismsOfTable( tbl ) );
##  [ 9 ]
##  gap> fus;
##  [ 1, 2, 4, 4, [ 5, 6 ], [ 5, 6 ], [ 5, 6 ], 10, 12, [ 12, 13 ],
##    [ 14, 15, 16 ], [ 14, 15, 16 ], [ 21, 22 ], [ 21, 22 ] ]
##  gap> FusionsAllowedByRestrictions( subtbl, tbl, Irr( subtbl ),
##  >        Irr( tbl ), fus, rec( maxlen:= 10,
##  >        contained:= ContainedPossibleCharacters, minamb:= 2,
##  >        maxamb:= infinity, quick:= false ) );
##  [ [ 1, 2, 4, 4, 5, 5, 6, 10, 12, 13, 14, 14, 21, 21 ],
##    [ 1, 2, 4, 4, 6, 6, 6, 10, 12, 13, 15, 15, 22, 22 ],
##    [ 1, 2, 4, 4, 6, 6, 6, 10, 12, 13, 16, 16, 22, 22 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FusionsAllowedByRestrictions" );


#############################################################################
##
#F  ConsiderStructureConstants( <subtbl>, <tbl>, <fusions>, <quick> )
##
##  <#GAPDoc Label="ConsiderStructureConstants">
##  <ManSection>
##  <Func Name="ConsiderStructureConstants"
##   Arg='subtbl, tbl, fusions, quick'/>
##
##  <Description>
##  Let <A>subtbl</A> and <A>tbl</A> be ordinary character tables and
##  <A>fusions</A> be a list of possible class fusions from <A>subtbl</A> to
##  <A>tbl</A>.
##  <Ref Func="ConsiderStructureConstants"/> returns the list of those maps
##  <M>\sigma</M> in <A>fusions</A> with the property that for all triples
##  <M>(i,j,k)</M> of class positions,
##  <C>ClassMultiplicationCoefficient</C><M>( <A>subtbl</A>, i, j, k )</M>
##  is not bigger than
##  <C>ClassMultiplicationCoefficient</C><M>( <A>tbl</A>, \sigma[i],
##  \sigma[j], \sigma[k] )</M>;
##  see&nbsp;<Ref Oper="ClassMultiplicationCoefficient"
##  Label="for character tables"/>
##  for the definition of class multiplication coefficients/structure
##  constants.
##  <P/>
##  The argument <A>quick</A> must be a Boolean; if it is <K>true</K> then
##  only those triples are checked for which at least two entries
##  in <A>fusions</A> have different images.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConsiderStructureConstants" );
