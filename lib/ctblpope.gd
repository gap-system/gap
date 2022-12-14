#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Götz Pfeiffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of those functions that are needed to
##  compute and test possible permutation characters.
##
#T  TODO:
#T  - small improvement:
#T    if a prescribed value is equal to the degree then restrict the
#T    constituents to those having this class in the kernel
#T  - use roots in `PermCandidates' (cf. `PermCandidatesFaithful'),
#T    in order to guarantee property (d) already in the construction!
#T  - check and document `PermCandidatesFaithful'
#T  - `IsPermChar( <tbl>, <pc> )'
#T    (check whether <pc> can be a permutation character of <tbl>;
#T     use also the kernel of <pc>, i.e., check whether the kernel factor
#T     of <pc> can be a permutation character of the factor of <tbl> by the
#T     kernel; one example where this helps is the sum of characters of S3
#T     in O8+(2).3.2)
#T  - `Constituent' und `Maxdeg' - Optionen in `PermComb'


#############################################################################
##
##  <#GAPDoc Label="[1]{ctblpope}">
##  <Index Subkey="permutation">characters</Index>
##  <Index Subkey="for permutation characters">candidates</Index>
##  <Index>possible permutation characters</Index>
##  <Index Subkey="possible">permutation characters</Index>
##  For groups <M>H</M> and <M>G</M> with <M>H \leq G</M>,
##  the induced character <M>(1_G)^H</M> is called the
##  <E>permutation character</E> of the operation of <M>G</M>
##  on the right cosets of <M>H</M>.
##  If only the character table of <M>G</M> is available and not the group
##  <M>G</M> itself,
##  one can try to get information about possible subgroups of <M>G</M>
##  by inspection of those <M>G</M>-class functions that might be
##  permutation characters,
##  using that such a class function <M>\pi</M> must have at least the
##  following properties.
##  (For details, see&nbsp;<Cite Key="Isa76" Where="Theorem 5.18."/>),
##
##  <List>
##  <Mark>(a)</Mark>
##  <Item>
##      <M>\pi</M> is a character of <M>G</M>,
##  </Item>
##  <Mark>(b)</Mark>
##  <Item>
##      <M>\pi(g)</M> is a nonnegative integer for all <M>g \in G</M>,
##  </Item>
##  <Mark>(c)</Mark>
##  <Item>
##      <M>\pi(1)</M> divides <M>|G|</M>,
##  </Item>
##  <Mark>(d)</Mark>
##  <Item>
##      <M>\pi(g^n) \geq \pi(g)</M> for <M>g \in G</M> and integers <M>n</M>,
##  </Item>
##  <Mark>(e)</Mark>
##  <Item>
##      <M>[\pi, 1_G] = 1</M>,
##  </Item>
##  <Mark>(f)</Mark>
##  <Item>
##      the multiplicity of any rational irreducible <M>G</M>-character
##      <M>\psi</M> as a constituent of <M>\pi</M> is at most
##      <M>\psi(1)/[\psi, \psi]</M>,
##  </Item>
##  <Mark>(g)</Mark>
##  <Item>
##      <M>\pi(g) = 0</M> if the order of <M>g</M> does not divide
##      <M>|G|/\pi(1)</M>,
##  </Item>
##  <Mark>(h)</Mark>
##  <Item>
##      <M>\pi(1) |N_G(g)|</M> divides <M>\pi(g) |G|</M>
##      for all <M>g \in G</M>,
##  </Item>
##  <Mark>(i)</Mark>
##  <Item>
##      <M>\pi(g) \leq (|G| - \pi(1)) / (|g^G| |Gal_G(g)|)</M>
##      for all nonidentity <M>g \in G</M>,
##      where <M>|Gal_G(g)|</M> denotes the number of conjugacy classes
##      of <M>G</M> that contain generators of the group
##      <M>\langle g \rangle</M>,
##  </Item>
##  <Mark>(j)</Mark>
##  <Item>
##      if <M>p</M> is a prime that divides <M>|G|/\pi(1)</M> only once then
##      <M>s/(p-1)</M> divides <M>|G|/\pi(1)</M> and is congruent to <M>1</M>
##      modulo <M>p</M>,
##      where <M>s</M> is the number of elements of order <M>p</M> in the
##      (hypothetical) subgroup <M>H</M> for which <M>\pi = (1_H)^G</M>
##      holds.
##      (Note that <M>s/(p-1)</M> equals the number of Sylow <M>p</M>
##      subgroups in <M>H</M>.)
##  </Item>
##  </List>
##
##  Any <M>G</M>-class function with these properties is called a
##  <E>possible permutation character</E> in &GAP;.
##  <P/>
##  (Condition (d) is checked only for those power maps that are stored in
##  the character table of <M>G</M>;
##  clearly (d) holds for all integers if it holds for all prime divisors of
##  the group order <M>|G|</M>.)
##  <P/>
##  &GAP; provides some algorithms to compute
##  possible permutation characters (see&nbsp;<Ref Func="PermChars"/>),
##  and also provides functions to check a few more criteria whether a
##  given character can be a transitive permutation character
##  (see&nbsp;<Ref Func="TestPerm1"/>).
##  <P/>
##  Some information about the subgroup <M>U</M> can be computed from the
##  permutation character <M>(1_U)^G</M> using <Ref Func="PermCharInfo"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#F  PermCharInfo( <tbl>, <permchars>[, <format> ] )
##
##  <#GAPDoc Label="PermCharInfo">
##  <Index Subkey="for permutation characters">LaTeX</Index>
##  <ManSection>
##  <Func Name="PermCharInfo" Arg='tbl, permchars[, format ]'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of the group <M>G</M>,
##  and <A>permchars</A> either the permutation character <M>(1_U)^G</M>,
##  for a subgroup <M>U</M> of <M>G</M>, or a list of such permutation
##  characters.
##  <Ref Func="PermCharInfo"/> returns a record with the following components.
##  <List>
##  <Mark><C>contained</C>:</Mark>
##  <Item>
##    a list containing, for each character <M>\psi = (1_U)^G</M> in
##    <A>permchars</A>, a list containing at position <M>i</M> the number
##    <M>\psi[i] |U| /</M> <C>SizesCentralizers( </C><A>tbl</A><C> )</C><M>[i]</M>,
##    which equals the number of those elements of <M>U</M>
##    that are contained in class <M>i</M> of <A>tbl</A>,
##  </Item>
##  <Mark><C>bound</C>:</Mark>
##  <Item>
##    a list containing,
##    for each character <M>\psi = (1_U)^G</M> in <A>permchars</A>,
##    a list containing at position <M>i</M> the number
##    <M>|U| / \gcd( |U|,</M> <C>SizesCentralizers( <A>tbl</A> )</C><M>[i] )</M>,
##    which divides the class length in <M>U</M> of an element in class <M>i</M>
##    of <A>tbl</A>,
##  </Item>
##  <Mark><C>display</C>:</Mark>
##  <Item>
##    a record that can be used as second argument of <Ref Oper="Display"/>
##    to display each permutation character in <A>permchars</A> and the
##    corresponding components <C>contained</C> and <C>bound</C>,
##    for those classes where at least one character of <A>permchars</A> is
##    nonzero,
##  </Item>
##  <Mark><C>ATLAS</C>:</Mark>
##  <Item>
##    a list of strings describing the decomposition of the permutation
##    characters in <A>permchars</A> into the irreducible characters of
##    <A>tbl</A>, given in an &ATLAS;-like notation.
##    This means that the irreducible constituents are indicated by their
##    degrees followed by lower case letters <C>a</C>, <C>b</C>, <C>c</C>,
##    <M>\ldots</M>,
##    which indicate the successive irreducible characters of <A>tbl</A>
##    of that degree,
##    in the order in which they appear in <C>Irr( </C><A>tbl</A><C> )</C>.
##    A sequence of small letters (not necessarily distinct) after a single
##    number indicates a sum of irreducible constituents all of the same
##    degree, an exponent <A>n</A> for the letter <A>lett</A> means that
##    <A>lett</A> is repeated <A>n</A> times.
##    The default notation for exponentiation is
##    <C><A>lett</A>^{<A>n</A>}</C>,
##    this is also chosen if the optional third argument <A>format</A> is
##    the string <C>"LaTeX"</C>;
##    if the third argument is the string <C>"HTML"</C> then exponentiation
##    is denoted by <C><A>lett</A>&lt;sup><A>n</A>&lt;/sup></C>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( "A6" );;
##  gap> psi:= Sum( Irr( t ){ [ 1, 3, 6 ] } );
##  Character( CharacterTable( "A6" ), [ 15, 3, 0, 3, 1, 0, 0 ] )
##  gap> info:= PermCharInfo( t, psi );
##  rec( ATLAS := [ "1a+5b+9a" ], bound := [ [ 1, 3, 8, 8, 6, 24, 24 ] ],
##    contained := [ [ 1, 9, 0, 8, 6, 0, 0 ] ],
##    display :=
##      rec(
##        chars := [ [ 15, 3, 0, 3, 1, 0, 0 ], [ 1, 9, 0, 8, 6, 0, 0 ],
##            [ 1, 3, 8, 8, 6, 24, 24 ] ], classes := [ 1, 2, 4, 5 ],
##        letter := "I" ) )
##  gap> Display( t, info.display );
##  A6
##
##       2  3  3  .  2
##       3  2  .  2  .
##       5  1  .  .  .
##
##         1a 2a 3b 4a
##      2P 1a 1a 3b 2a
##      3P 1a 2a 1a 4a
##      5P 1a 2a 3b 4a
##
##  I.1    15  3  3  1
##  I.2     1  9  8  6
##  I.3     1  3  8  6
##  gap> j1:= CharacterTable( "J1" );;
##  gap> psi:= TrivialCharacter( CharacterTable( "7:6" ) )^j1;
##  Character( CharacterTable( "J1" ), [ 4180, 20, 10, 0, 0, 2, 1, 0, 0,
##    0, 0, 0, 0, 0, 0 ] )
##  gap> PermCharInfo( j1, psi ).ATLAS;
##  [ "1a+56aabb+76aaab+77aabbcc+120aaabbbccc+133a^{4}bbcc+209a^{5}" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermCharInfo" );


#############################################################################
##
#F  PermCharInfoRelative( <tbl>, <tbl2>, <permchars> )
##
##  <#GAPDoc Label="PermCharInfoRelative">
##  <ManSection>
##  <Func Name="PermCharInfoRelative" Arg='tbl, tbl2, permchars'/>
##
##  <Description>
##  Let <A>tbl</A> and <A>tbl2</A> be the ordinary character tables of two
##  groups <M>H</M> and <M>G</M>, respectively,
##  where <M>H</M> is of index two in <M>G</M>,
##  and <A>permchars</A> either the permutation character <M>(1_U)^G</M>,
##  for a subgroup <M>U</M> of <M>G</M>,
##  or a list of such permutation characters.
##  <Ref Func="PermCharInfoRelative"/> returns a record with the same
##  components as <Ref Func="PermCharInfo"/>, the only exception is that the
##  entries of the <C>ATLAS</C> component are names relative to <A>tbl</A>.
##  <P/>
##  More precisely, the <M>i</M>-th entry of the <C>ATLAS</C> component is a
##  string describing the decomposition of the <M>i</M>-th entry in
##  <A>permchars</A>.
##  The degrees and distinguishing letters of the constituents refer to
##  the irreducibles of <A>tbl</A>, as follows.
##  The two irreducible characters of <A>tbl2</A> of degree <M>N</M>
##  that extend the irreducible character <M>N</M> <C>a</C> of <A>tbl</A>
##  are denoted by <M>N</M> <C>a</C><M>^+</M> and <M>N </M><C>a</C><M>^-</M>.
##  The irreducible character of <A>tbl2</A> of degree <M>2N</M> whose
##  restriction to <A>tbl</A> is the sum of the irreducible characters
##  <M>N</M> <C>a</C> and <M>N</M> <C>b</C> is denoted as <M>N</M> <C>ab</C>.
##  Multiplicities larger than <M>1</M> of constituents are denoted by
##  exponents.
##  <P/>
##  (This format is useful mainly for multiplicity free permutation
##  characters.)
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( "A5" );;
##  gap> t2:= CharacterTable( "A5.2" );;
##  gap> List( Irr( t2 ), x -> x[1] );
##  [ 1, 1, 6, 4, 4, 5, 5 ]
##  gap> List( Irr( t ), x -> x[1] );
##  [ 1, 3, 3, 4, 5 ]
##  gap> permchars:= List( [ [1], [1,2], [1,7], [1,3,4,4,6,6,7] ],
##  >                      l -> Sum( Irr( t2 ){ l } ) );
##  [ Character( CharacterTable( "A5.2" ), [ 1, 1, 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( "A5.2" ), [ 2, 2, 2, 2, 0, 0, 0 ] ),
##    Character( CharacterTable( "A5.2" ), [ 6, 2, 0, 1, 0, 2, 0 ] ),
##    Character( CharacterTable( "A5.2" ), [ 30, 2, 0, 0, 6, 0, 0 ] ) ]
##  gap> info:= PermCharInfoRelative( t, t2, permchars );;
##  gap> info.ATLAS;
##  [ "1a^+", "1a^{\\pm}", "1a^++5a^-",
##    "1a^++3ab+4(a^+)^{2}+5a^+a^{\\pm}" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermCharInfoRelative" );


#############################################################################
##
#F  TestPerm1( <tbl>, <char> ) . . . . . . . . . . . . . . . .  test permchar
#F  TestPerm2( <tbl>, <char> ) . . . . . . . . . . . . . . . .  test permchar
#F  TestPerm3( <tbl>, <chars> )  . . . . . . . . . . . . . . . test permchars
#F  TestPerm4( <tbl>, <chars> )  . . . . . . . . . . . . . . . test permchars
#F  TestPerm5( <tbl>, <chars>, <modtbl> ) . . . . . . . . . .  test permchars
##
##  <#GAPDoc Label="TestPerm1">
##  <ManSection>
##  <Heading>TestPerm1, ..., TestPerm5</Heading>
##  <Func Name="TestPerm1" Arg='tbl, char'/>
##  <Func Name="TestPerm2" Arg='tbl, char'/>
##  <Func Name="TestPerm3" Arg='tbl, chars'/>
##  <Func Name="TestPerm4" Arg='tbl, chars'/>
##  <Func Name="TestPerm5" Arg='tbl, chars, modtbl'/>
##
##  <Description>
##  The first three of these functions implement tests of the properties of
##  possible permutation characters listed in
##  Section&nbsp;<Ref Sect="Possible Permutation Characters"/>,
##  The other two implement test of additional properties.
##  Let <A>tbl</A> be the ordinary character table of a group <M>G</M>,
##  <A>char</A> a rational character of <A>tbl</A>,
##  and <A>chars</A> a list of rational characters of <A>tbl</A>.
##  For applying <Ref Func="TestPerm5"/>, the knowledge of a <M>p</M>-modular
##  Brauer table <A>modtbl</A> of <M>G</M> is required.
##  <Ref Func="TestPerm4"/> and <Ref Func="TestPerm5"/> expect the characters
##  in <A>chars</A> to satisfy the conditions checked by
##  <Ref Func="TestPerm1"/> and <Ref Func="TestPerm2"/> (see below).
##  <P/>
##  The return values of the functions were chosen parallel to the tests
##  listed in&nbsp;<Cite Key="NPP84"/>.
##  <P/>
##  <Ref Func="TestPerm1"/> return <C>1</C> or <C>2</C> if <A>char</A> fails
##  because of (T1) or (T2), respectively;
##  this corresponds to the criteria (b) and (d).
##  Note that only those power maps are considered that are stored on
##  <A>tbl</A>.
##  If <A>char</A> satisfies the conditions, <C>0</C> is returned.
##  <P/>
##  <Ref Func="TestPerm2"/> returns <C>1</C> if <A>char</A> fails because of
##  the criterion (c),
##  it returns <C>3</C>, <C>4</C>, or <C>5</C> if <A>char</A> fails because
##  of (T3), (T4), or (T5), respectively;
##  these tests correspond to (g), a weaker form of (h), and (j).
##  If <A>char</A> satisfies the conditions, <C>0</C> is returned.
##  <P/>
##  <Ref Func="TestPerm3"/> returns the list of all those class functions in
##  the list <A>chars</A> that satisfy criterion (h);
##  this is a stronger version of (T6).
##  <P/>
##  <Ref Func="TestPerm4"/> returns the list of all those class functions in
##  the list <A>chars</A> that satisfy (T8) and (T9) for each prime divisor
##  <M>p</M> of the order of <M>G</M>;
##  these tests use modular representation theory but do not require the
##  knowledge of decomposition matrices
##  (cf.&nbsp;<Ref Func="TestPerm5"/> below).
##  <P/>
##  (T8) implements the test of the fact that in the case that <M>p</M>
##  divides <M>|G|</M> and the degree of a transitive permutation character
##  <M>\pi</M> exactly once,
##  the projective cover of the trivial character is a summand of <M>\pi</M>.
##  (This test is omitted if the projective cover cannot be identified.)
##  <P/>
##  Given a permutation character <M>\pi</M> of a group <M>G</M> and a prime
##  integer <M>p</M>,
##  the restriction <M>\pi_B</M> to a <M>p</M>-block <M>B</M> of <M>G</M> has
##  the following property, which is checked by (T9).
##  For each <M>g \in G</M> such that <M>g^n</M> is a <M>p</M>-element of
##  <M>G</M>, <M>\pi_B(g^n)</M> is a nonnegative integer that satisfies
##  <M>|\pi_B(g)| \leq \pi_B(g^n) \leq \pi(g^n)</M>.
##  (This is <Cite Key="Sco73" Where="Corollary A on p. 113"/>.)
##  <P/>
##  <Ref Func="TestPerm5"/> requires the <M>p</M>-modular Brauer table
##  <A>modtbl</A> of <M>G</M>, for some prime <M>p</M> dividing the order of
##  <M>G</M>,
##  and checks whether those characters in the list <A>chars</A> whose degree
##  is divisible by the <M>p</M>-part of the order of <M>G</M> can be
##  decomposed into projective indecomposable characters;
##  <Ref Func="TestPerm5"/> returns the sublist of all those characters in
##  <A>chars</A> that either satisfy this condition or to which the test does
##  not apply.
##  <P/>
##  <!-- Say a word about (T7)?-->
##  <!-- This is the check whether the cycle structure of elements is well-defined;-->
##  <!-- the check is superfluous (at least) for elements of prime power order-->
##  <!-- or order equal to the product of two primes (see&nbsp;<Cite Key="NPP84"/>);-->
##  <!-- note that by construction, the numbers of <Q>cycles</Q> are always integral,-->
##  <!-- the only thing to test is whether they are nonnegative.-->
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> rat:= RationalizedMat( Irr( tbl ) );
##  [ Character( CharacterTable( "A5" ), [ 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( "A5" ), [ 6, -2, 0, 1, 1 ] ),
##    Character( CharacterTable( "A5" ), [ 4, 0, 1, -1, -1 ] ),
##    Character( CharacterTable( "A5" ), [ 5, 1, -1, 0, 0 ] ) ]
##  gap> tup:= Filtered( Tuples( [ 0, 1 ], 4 ), x -> not IsZero( x ) );
##  [ [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ], [ 0, 0, 1, 1 ], [ 0, 1, 0, 0 ],
##    [ 0, 1, 0, 1 ], [ 0, 1, 1, 0 ], [ 0, 1, 1, 1 ], [ 1, 0, 0, 0 ],
##    [ 1, 0, 0, 1 ], [ 1, 0, 1, 0 ], [ 1, 0, 1, 1 ], [ 1, 1, 0, 0 ],
##    [ 1, 1, 0, 1 ], [ 1, 1, 1, 0 ], [ 1, 1, 1, 1 ] ]
##  gap> lincomb:= List( tup, coeff -> coeff * rat );;
##  gap> List( lincomb, psi -> TestPerm1( tbl, psi ) );
##  [ 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0 ]
##  gap> List( lincomb, psi -> TestPerm2( tbl, psi ) );
##  [ 0, 5, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1 ]
##  gap> Set( TestPerm3(tbl, lincomb), x -> Position(lincomb, x) );
##  [ 1, 4, 6, 7, 8, 9, 10, 11, 13 ]
##  gap> tbl:= CharacterTable( "A7" );
##  CharacterTable( "A7" )
##  gap> perms:= PermChars( tbl, rec( degree:= 315 ) );
##  [ Character( CharacterTable( "A7" ), [ 315, 3, 0, 0, 3, 0, 0, 0, 0 ] )
##      , Character( CharacterTable( "A7" ),
##      [ 315, 15, 0, 0, 1, 0, 0, 0, 0 ] ) ]
##  gap> TestPerm4( tbl, perms );
##  [ Character( CharacterTable( "A7" ), [ 315, 15, 0, 0, 1, 0, 0, 0, 0
##       ] ) ]
##  gap> perms:= PermChars( tbl, rec( degree:= 15 ) );
##  [ Character( CharacterTable( "A7" ), [ 15, 3, 0, 3, 1, 0, 0, 1, 1 ] ),
##    Character( CharacterTable( "A7" ), [ 15, 3, 3, 0, 1, 0, 3, 1, 1 ] )
##   ]
##  gap> TestPerm5( tbl, perms, tbl mod 5 );
##  [ Character( CharacterTable( "A7" ), [ 15, 3, 0, 3, 1, 0, 0, 1, 1 ] )
##   ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestPerm1" );
DeclareGlobalFunction( "TestPerm2" );
DeclareGlobalFunction( "TestPerm3" );
DeclareGlobalFunction( "TestPerm4" );
DeclareGlobalFunction( "TestPerm5" );


#############################################################################
##
#F  PermChars( <tbl> )
#F  PermChars( <tbl>, <degree> )
#F  PermChars( <tbl>, <arec> )
##
##  <#GAPDoc Label="PermChars">
##  <ManSection>
##  <Func Name="PermChars" Arg='tbl[, cond]'/>
##
##  <Description>
##  &GAP; provides several algorithms to determine
##  possible permutation characters from a given character table.
##  They are described in detail in&nbsp;<Cite Key="BP98"/>.
##  The algorithm is selected from the choice of the optional argument
##  <A>cond</A>.
##  The user is encouraged to try different approaches,
##  especially if one choice fails to come to an end.
##  <P/>
##  Regardless of the algorithm used in a specific case,
##  <Ref Func="PermChars"/> returns a list of <E>all</E>
##  possible permutation characters with the properties described by
##  <A>cond</A>.
##  There is no guarantee that a character of this list is in fact
##  a permutation character.
##  But an empty list always means there is no permutation character
##  with these properties (e.g., of a certain degree).
##  <P/>
##  Called with only one argument, a character table <A>tbl</A>,
##  <Ref Func="PermChars"/> returns the list of all possible permutation
##  characters of the group with this character table.
##  This list might be rather long for big groups,
##  and its computation might take much time.
##  The algorithm is described in <Cite Key="BP98" Where="Section 3.2"/>;
##  it depends on a preprocessing step, where the inequalities
##  arising from the condition <M>\pi(g) \geq 0</M> are transformed into
##  a system of inequalities that guides the search
##  (see&nbsp;<Ref Oper="Inequalities"/>).
##  So the following commands compute the list of 39 possible permutation
##  characters of the Mathieu group <M>M_{11}</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> m11:= CharacterTable( "M11" );;
##  gap> SetName( m11, "m11" );
##  gap> perms:= PermChars( m11 );;
##  gap> Length( perms );
##  39
##  ]]></Example>
##  <P/>
##  There are two different search strategies for this algorithm.
##  The default strategy simply constructs all characters with nonnegative
##  values and then tests for each such character whether its degree
##  is a divisor of the order of the group.
##  The other strategy uses the inequalities to predict
##  whether a character of a certain degree can lie
##  in the currently searched part of the search tree.
##  To choose this strategy, enter a record as the second argument of
##  <Ref Func="PermChars"/>,
##  and set its component <C>degree</C> to the range of degrees
##  (which might also be a range containing all divisors of the group order)
##  you want to look for;
##  additionally, the record component <C>ineq</C> can take the inequalities
##  computed by <Ref Oper="Inequalities"/> if they are needed more than once.
##  <P/>
##  If a positive integer is given as the second argument <A>cond</A>,
##  <Ref Func="PermChars"/> returns the list of all
##  possible permutation characters of <A>tbl</A> that have degree
##  <A>cond</A>.
##  For that purpose, a preprocessing step is performed where
##  essentially the rational character table is inverted
##  in order to determine boundary points for the simplex
##  in which the possible permutation characters of the given degree
##  must lie (see&nbsp;<Ref Func="PermBounds"/>).
##  The algorithm is described at the end of
##  <Cite Key="BP98" Where="Section 3.2"/>.
##  Note that inverting big integer matrices needs a lot of time and space.
##  So this preprocessing is restricted to groups with less than 100 classes,
##  say.
##  <P/>
##  <Example><![CDATA[
##  gap> deg220:= PermChars( m11, 220 );
##  [ Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ),
##    Character( m11, [ 220, 12, 4, 4, 0, 0, 0, 0, 0, 0 ] ),
##    Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ) ]
##  ]]></Example>
##  <P/>
##  If a record is given as the second argument <A>cond</A>,
##  <Ref Func="PermChars"/> returns the list of all
##  possible permutation characters that have the properties described by
##  the components of this record.
##  One such situation has been mentioned above.
##  If <A>cond</A> contains a degree as value of the record component
##  <C>degree</C>
##  then <Ref Func="PermChars"/> will behave exactly as if this degree was
##  entered as <A>cond</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> deg220 = PermChars( m11, rec( degree:= 220 ) );
##  true
##  ]]></Example>
##  <P/>
##  For the meaning of additional components of <A>cond</A> besides
##  <C>degree</C>, see&nbsp;<Ref Func="PermComb"/>.
##  <P/>
##  Instead of <C>degree</C>, <A>cond</A> may have the component <C>torso</C>
##  bound to a list that contains some known values of the required
##  characters at the right positions;
##  at least the degree <A>cond</A><C>.torso[1]</C> must be an integer.
##  In this case, the algorithm described in
##  <Cite Key="BP98" Where="Section 3.3"/> is chosen.
##  The component <C>chars</C>, if present, holds a list of all those
##  <E>rational</E> irreducible characters of <A>tbl</A> that might be
##  constituents of the required characters.
##  <P/>
##  (<E>Note</E>: If <A>cond</A><C>.chars</C> is bound and does not contain
##  <E>all</E> rational irreducible characters of <A>tbl</A>,
##  &GAP; checks whether the scalar products of all class functions in the
##  result list with the omitted rational irreducible characters of
##  <A>tbl</A> are nonnegative;
##  so there should be nontrivial reasons for excluding a character
##  that is known to be not a constituent of the desired possible permutation
##  characters.)
##  <P/>
##  <Example><![CDATA[
##  gap> PermChars( m11, rec( torso:= [ 220 ] ) );
##  [ Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ),
##    Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ),
##    Character( m11, [ 220, 12, 4, 4, 0, 0, 0, 0, 0, 0 ] ) ]
##  gap> PermChars( m11, rec( torso:= [ 220,,,,, 2 ] ) );
##  [ Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ) ]
##  ]]></Example>
##  <P/>
##  An additional restriction on the possible permutation characters computed
##  can be forced if <A>con</A> contains, in addition to <C>torso</C>,
##  the components <C>normalsubgroup</C> and <C>nonfaithful</C>,
##  with values a list of class positions of a normal subgroup <M>N</M> of
##  the group <M>G</M> of <A>tbl</A> and a possible permutation character
##  <M>\pi</M> of <M>G</M>, respectively, such that <M>N</M> is contained in
##  the kernel of <M>\pi</M>.
##  In this case, <Ref Func="PermChars"/> returns the list of those possible
##  permutation characters <M>\psi</M> of <A>tbl</A> coinciding with
##  <C>torso</C> wherever its values are bound
##  and having the property that no irreducible constituent of
##  <M>\psi - \pi</M> has <M>N</M> in its kernel.
##  If the component <C>chars</C> is bound in <A>cond</A> then the above
##  statements apply.
##  An interpretation of the computed characters is the following.
##  Suppose there exists a subgroup <M>V</M> of <M>G</M> such that
##  <M>\pi = (1_V)^G</M>;
##  Then <M>N \leq V</M>, and if a computed character is of the form
##  <M>(1_U)^G</M>, for a subgroup <M>U</M> of <M>G</M>, then <M>V = UN</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> nsg:= ClassPositionsOfDerivedSubgroup( s4 );;
##  gap> pi:= TrivialCharacter( s4 );;
##  gap> PermChars( s4, rec( torso:= [ 12 ], normalsubgroup:= nsg,
##  >                        nonfaithful:= pi ) );
##  [ Character( CharacterTable( "Sym(4)" ), [ 12, 2, 0, 0, 0 ] ) ]
##  gap> pi:= Sum( Filtered( Irr( s4 ),
##  >              chi -> IsSubset( ClassPositionsOfKernel( chi ), nsg ) ) );
##  Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, 2, 0 ] )
##  gap> PermChars( s4, rec( torso:= [ 12 ], normalsubgroup:= nsg,
##  >                        nonfaithful:= pi ) );
##  [ Character( CharacterTable( "Sym(4)" ), [ 12, 0, 4, 0, 0 ] ) ]
##  ]]></Example>
##  <P/>
##  The class functions returned by <Ref Func="PermChars"/> have the
##  properties tested by <Ref Func="TestPerm1"/>, <Ref Func="TestPerm2"/>,
##  and <Ref Func="TestPerm3"/>.
##  So they are possible permutation characters.
##  See&nbsp;<Ref Func="TestPerm1"/> for criteria whether a
##  possible permutation character can in fact be a permutation character.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermChars" );


#############################################################################
##
#O  Inequalities( <tbl>, <chars>[, <option>] )
##
##  <#GAPDoc Label="Inequalities">
##  <ManSection>
##  <Oper Name="Inequalities" Arg='tbl, chars[, option]'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of a group <M>G</M>.
##  The condition <M>\pi(g) \geq 0</M> for every possible permutation
##  character <M>\pi</M> of <M>G</M> places restrictions on the
##  multiplicities <M>a_i</M> of the irreducible constituents <M>\chi_i</M>
##  of <M>\pi = \sum_{{i = 1}}^r a_i \chi_i</M>.
##  For every element <M>g \in G</M>,
##  we have <M>\sum_{{i = 1}}^r a_i \chi_i(g) \geq 0</M>.
##  The power maps provide even stronger conditions.
##  <P/>
##  This system of inequalities is kind of diagonalized,
##  resulting in a system of inequalities restricting <M>a_i</M>
##  in terms of <M>a_j</M>, <M>j &lt; i</M>.
##  These inequalities are used to construct characters with nonnegative
##  values (see&nbsp;<Ref Func="PermChars"/>).
##  <Ref Func="PermChars"/> either calls <Ref Oper="Inequalities"/> or takes
##  this information from the <C>ineq</C> component of its argument record.
##  <P/>
##  The number of inequalities arising in the process of diagonalization may
##  grow very strongly.
##  <P/>
##  There are two ways to organize the projection.
##  The first, which is chosen if no <A>option</A> argument is present,
##  is the straight approach which takes the rational irreducible
##  characters in their original order and by this guarantees the character
##  with the smallest degree to be considered first.
##  The other way, which is chosen if the string <C>"small"</C> is entered as
##  third argument <A>option</A>, tries to keep the number of intermediate
##  inequalities small by eventually changing the order of characters.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "M11" );;
##  gap> PermComb( tbl, rec( degree:= 110 ) );
##  [ Character( CharacterTable( "M11" ),
##      [ 110, 6, 2, 2, 0, 0, 2, 2, 0, 0 ] ),
##    Character( CharacterTable( "M11" ),
##      [ 110, 6, 2, 6, 0, 0, 0, 0, 0, 0 ] ),
##    Character( CharacterTable( "M11" ), [ 110, 14, 2, 2, 0, 2, 0, 0, 0,
##        0 ] ) ]
##  gap> # Now compute only multiplicity free permutation characters.
##  gap> bounds:= List( RationalizedMat( Irr( tbl ) ), x -> 1 );;
##  gap> PermComb( tbl, rec( degree:= 110, maxmult:= bounds ) );
##  [ Character( CharacterTable( "M11" ),
##      [ 110, 6, 2, 2, 0, 0, 2, 2, 0, 0 ] ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Inequalities", [ IsOrdinaryTable, IsList ] );
DeclareOperation( "Inequalities", [ IsOrdinaryTable, IsList, IsObject ] );


#############################################################################
##
#F  Permut( <tbl>, <arec> )
##
##  <ManSection>
##  <Func Name="Permut" Arg='tbl, arec'/>
##
##  <Description>
##  <C>Permut</C> computes possible permutation characters of the character table
##  <A>tbl</A> by the algorithm that solves a system of inequalities.
##  This is described in <Cite Key="BP98" Where="Section 3.2"/>.
##  <P/>
##  <A>arec</A> must be a record.
##  Only the following components are used in the function.
##  <List>
##  <Mark><C>ineq</C> </Mark>
##  <Item>
##      the result of <Ref Func="Inequalities"/>,
##      will be computed if it is not present,
##  <C>degree</C> &
##      the list of degrees for which the possible permutation characters
##      shall be computed,
##      this will lead to a speedup only if the range of degrees is
##      restricted.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "Permut" );


#############################################################################
##
#F  PermBounds( <tbl>, <d> ) . . . . . . . . . .  boundary points for simplex
##
##  <#GAPDoc Label="PermBounds">
##  <ManSection>
##  <Func Name="PermBounds" Arg='tbl, d'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of the group <M>G</M>.
##  All <M>G</M>-characters <M>\pi</M> satisfying <M>\pi(g) > 0</M> and
##  <M>\pi(1) = <A>d</A></M>,
##  for a given degree <A>d</A>, lie in a simplex described by these
##  conditions.
##  <Ref Func="PermBounds"/> computes the boundary points of this simplex for
##  <M>d = 0</M>,
##  from which the boundary points for any other <A>d</A> are easily derived.
##  (Some conditions from the power maps of <A>tbl</A> are also involved.)
##  For this purpose, a matrix similar to the rational character table of
##  <M>G</M> has to be inverted.
##  These boundary points are used by <Ref Func="PermChars"/>
##  to construct all possible permutation characters
##  (see&nbsp;<Ref Sect="Possible Permutation Characters"/>) of a given
##  degree.
##  <Ref Func="PermChars"/> either calls <Ref Func="PermBounds"/> or takes
##  this information from the <C>bounds</C> component of its argument record.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermBounds" );


#############################################################################
##
#F  PermComb( <tbl>, <arec> ) . . . . . . . . . . . .  permutation characters
##
##  <#GAPDoc Label="PermComb">
##  <ManSection>
##  <Func Name="PermComb" Arg='tbl, arec'/>
##
##  <Description>
##  <Ref Func="PermComb"/> computes possible permutation characters of the
##  character table <A>tbl</A> by the improved combinatorial approach
##  described at the end of <Cite Key="BP98" Where="Section 3.2"/>.
##  <P/>
##  For computing the possible linear combinations <E>without</E> prescribing
##  better bounds (i.e., when the computation of bounds shall be suppressed),
##  enter
##  <P/>
##  <C><A>arec</A>:= rec( degree := <A>degree</A>, bounds := false )</C>,
##  <P/>
##  where <A>degree</A> is the character degree;
##  this is useful if the multiplicities are expected to be small,
##  and if this is forced by high irreducible degrees.
##  <P/>
##  A list of upper bounds on the multiplicities of the rational irreducibles
##  characters can be explicitly prescribed as a <C>maxmult</C> component in
##  <A>arec</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermComb" );


#############################################################################
##
#F  PermCandidates( <tbl>, <characters>, <torso> )
##
##  <ManSection>
##  <Func Name="PermCandidates" Arg='tbl, characters, torso'/>
##
##  <Description>
##  <C>PermCandidates</C> computes possible permutation characters of the
##  character table <A>tbl</A> with the strategy using Gaussian elimination,
##  which is described in <Cite Key="BP98" Where="Section 3.3"/>.
##  <P/>
##  The class functions in the result have the additional properties that
##  only the (necessarily rational) characters <A>characters</A> occur as
##  constituents, and that they are all completions of <A>torso</A>.
##  (Note that scalar products with rational irreducible characters of
##  <A>tbl</A> that are omitted in <A>characters</A> may be negative,
##  so not all class functions in the result list are necessarily characters
##  if <A>characters</A> does not contain all rational irreducible characters
##  of <A>tbl</A>.)
##  <P/>
##  Known values of the candidates must be nonnegative integers in
##  <A>torso</A>, the other positions of <A>torso</A> are unbound;
##  at least the degree <C><A>torso</A>[1]</C> must be an integer.
##  <!-- what about choice lists ??-->
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PermCandidates" );


#############################################################################
##
#F  PermCandidatesFaithful( <tbl>, <chars>, <norm_subgrp>, <nonfaithful>,
#F                          <lower>, <upper>, <torso> )
##
##  <ManSection>
##  <Func Name="PermCandidatesFaithful"
##  Arg='tbl, chars, norm_subgrp, nonfaithful, lower, upper, torso'/>
##
##  <Description>
##  computes certain possible permutation characters of the character table
##  <A>tbl</A> with a generalization of the strategy
##  using Gaussian elimination (see&nbsp;<Ref Func="PermCandidates"/>).
##  These characters are all with the following properties.
##  <P/>
##  <Enum>
##  <Item>
##     Only the (necessarily rational) characters <A>chars</A> occur as
##     constituents,
##  </Item>
##  <Item>
##     they are completions of <A>torso</A>, and
##  </Item>
##  <Item>
##     have the character <A>nonfaithful</A> as maximal constituent with kernel
##     <A>norm_subgrp</A>.
##  </Item>
##  </Enum>
##  <P/>
##  Known values of the candidates must be nonnegative integers in
##  <A>torso</A>, the other positions of <A>torso</A> are unbound;
##  at least the degree <C><A>torso</A>[1]</C> must be an integer.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PermCandidatesFaithful" );
