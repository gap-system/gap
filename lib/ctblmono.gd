#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Erzsébet Horváth.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations of the functions dealing with
##  monomiality questions for finite (solvable) groups.
##
##  1. Character Degrees and Derived Length
##  2. Primitivity of Characters
##  3. Testing Monomiality
##  4. Minimal Nonmonomial Groups
##


#############################################################################
##
##  <#GAPDoc Label="[1]{ctblmono}">
##  All these functions assume <E>characters</E> to be class function objects
##  as described in Chapter&nbsp;<Ref Chap="Class Functions"/>,
##  lists of character <E>values</E> are not allowed.
##  <P/>
##  The usual <E>property tests</E> of &GAP; that return either <K>true</K>
##  or <K>false</K> are not sufficient for us.
##  When we ask whether a group character <M>\chi</M> has a certain property,
##  such as quasiprimitivity,
##  we usually want more information than just yes or no.
##  Often we are interested in the reason <E>why</E> a group character
##  <M>\chi</M> was proved to have a certain property,
##  e.g., whether monomiality of <M>\chi</M> was proved by the observation
##  that the underlying group is nilpotent,
##  or whether it was necessary to construct a linear character of a subgroup
##  from which <M>\chi</M> can be induced.
##  In the latter case we also may be interested in this linear character.
##  Therefore we need test functions that return a record containing such
##  useful information.
##  For example, the record returned by the function
##  <Ref Attr="TestQuasiPrimitive"/> contains the component
##  <C>isQuasiPrimitive</C> (which is the known boolean property flag),
##  and additionally the component <C>comment</C>,
##  a string telling the reason for the value of the <C>isQuasiPrimitive</C>
##  component,
##  and in the case that the argument <M>\chi</M> was <E>not</E>
##  quasiprimitive also the component <C>character</C>,
##  which is an irreducible constituent of a nonhomogeneous restriction
##  of <M>\chi</M> to a normal subgroup.
##  Besides these test functions there are also the known properties,
##  e.g., the property <Ref Prop="IsQuasiPrimitive"/>
##  which will call the attribute <Ref Attr="TestQuasiPrimitive"/>,
##  and return the value of the <C>isQuasiPrimitive</C> component of the
##  result.
##  <P/>
##  A few words about how to use the monomiality functions seem to be
##  necessary.
##  Monomiality questions usually involve computations in many subgroups
##  and factor groups of a given group,
##  and for these groups often expensive calculations such as that of
##  the character table are necessary.
##  So one should be careful not to construct the same group over and over
##  again, instead the same group object should be reused,
##  such that its character table need to be computed only once.
##  For example,
##  suppose you want to restrict a character to a normal subgroup
##  <M>N</M> that was constructed as a normal closure of some group elements,
##  and suppose that you have already computed with normal subgroups
##  (by calls to <Ref Attr="NormalSubgroups"/> or
##  <Ref Attr="MaximalNormalSubgroups"/>)
##  and their character tables.
##  Then you should look in the lists of known normal subgroups
##  whether <M>N</M> is contained,
##  and if so you can use the known character table.
##  A mechanism that supports this for normal subgroups is described in
##  <Ref Sect="Storing Normal Subgroup Information"/>.
##  <P/>
##  Also the following hint may be useful in this context.
##  If you know that sooner or later you will compute the character table of
##  a group <M>G</M> then it may be advisable to compute it as soon as
##  possible.
##  For example, if you need the normal subgroups of <M>G</M> then they can
##  be computed more efficiently if the character table of <M>G</M> is known,
##  and they can be stored compatibly to the contained <M>G</M>-conjugacy
##  classes.
##  This correspondence of classes list and normal subgroup can be used very
##  often.
##  <#/GAPDoc>
##


#############################################################################
##
#V  InfoMonomial
##
##  <#GAPDoc Label="InfoMonomial">
##  <ManSection>
##  <InfoClass Name="InfoMonomial"/>
##
##  <Description>
##  Most of the functions described in this chapter print some
##  (hopefully useful) <E>information</E> if the info level of the info class
##  <Ref InfoClass="InfoMonomial"/> is at least <M>1</M>,
##  see&nbsp;<Ref Sect="Info Functions"/> for details.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoMonomial" );


#############################################################################
##
##  1. Character Degrees and Derived Length
##


#############################################################################
##
#A  Alpha( <G> )
##
##  <#GAPDoc Label="Alpha">
##  <ManSection>
##  <Attr Name="Alpha" Arg='G'/>
##
##  <Description>
##  For a group <A>G</A>, <Ref Attr="Alpha"/> returns a list
##  whose <M>i</M>-th entry is the maximal derived length of groups
##  <M><A>G</A> / \ker(\chi)</M> for <M>\chi \in Irr(<A>G</A>)</M> with
##  <M>\chi(1)</M> at most the <M>i</M>-th irreducible degree of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Alpha", IsGroup );


#############################################################################
##
#A  Delta( <G> )
##
##  <#GAPDoc Label="Delta">
##  <ManSection>
##  <Attr Name="Delta" Arg='G'/>
##
##  <Description>
##  For a group <A>G</A>, <Ref Attr="Delta"/> returns the list
##  <M>[ 1, alp[2] - alp[1], \ldots, alp[<A>n</A>] - alp[<A>n</A>-1] ]</M>,
##  where <M>alp = </M><C>Alpha( <A>G</A> )</C>
##  (see&nbsp;<Ref Attr="Alpha"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Delta", IsGroup );


#############################################################################
##
#P  IsBergerCondition( <G> )
#P  IsBergerCondition( <chi> )
##
##  <#GAPDoc Label="IsBergerCondition">
##  <ManSection>
##  <Heading>IsBergerCondition</Heading>
##  <Prop Name="IsBergerCondition" Arg='G' Label="for a group"/>
##  <Prop Name="IsBergerCondition" Arg='chi' Label="for a character"/>
##
##  <Description>
##  Called with an irreducible character <A>chi</A> of a group <M>G</M>,
##  <Ref Prop="IsBergerCondition" Label="for a group"/> returns <K>true</K>
##  if <A>chi</A> satisfies <M>M' \leq \ker(\chi)</M> for every normal
##  subgroup <M>M</M> of <M>G</M> with the property that
##  <M>M \leq \ker(\psi)</M> holds for all <M>\psi \in Irr(G)</M> with
##  <M>\psi(1) &lt; \chi(1)</M>, and <K>false</K> otherwise.
##  <P/>
##  Called with a group <A>G</A>,
##  <Ref Prop="IsBergerCondition" Label="for a character"/> returns
##  <K>true</K> if all irreducible characters of <A>G</A> satisfy the
##  inequality above, and <K>false</K> otherwise.
##  <P/>
##  For groups of odd order the result is always <K>true</K> by a theorem of
##  T.&nbsp;R.&nbsp;Berger (see&nbsp;<Cite Key="Ber76" Where="Thm. 2.2"/>).
##  <P/>
##  In the case that <K>false</K> is returned,
##  <Ref InfoClass="InfoMonomial"/> tells about
##  a degree for which the inequality is violated.
##  <P/>
##  <Example><![CDATA[
##  gap> Alpha( Sl23 );
##  [ 1, 3, 3 ]
##  gap> Alpha( S4 );
##  [ 1, 2, 3 ]
##  gap> Delta( Sl23 );
##  [ 1, 2, 0 ]
##  gap> Delta( S4 );
##  [ 1, 1, 1 ]
##  gap> IsBergerCondition( S4 );
##  true
##  gap> IsBergerCondition( Sl23 );
##  false
##  gap> List( Irr( Sl23 ), IsBergerCondition );
##  [ true, true, true, false, false, false, true ]
##  gap> List( Irr( Sl23 ), Degree );
##  [ 1, 1, 1, 2, 2, 2, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsBergerCondition", IsGroup );
DeclareProperty( "IsBergerCondition", IsClassFunction );


#############################################################################
##
##  2. Primitivity of Characters
##


#############################################################################
##
#F  TestHomogeneous( <chi>, <N> )
##
##  <#GAPDoc Label="TestHomogeneous">
##  <ManSection>
##  <Func Name="TestHomogeneous" Arg='chi, N'/>
##
##  <Description>
##  For a group character <A>chi</A> of a group <M>G</M>
##  and a normal subgroup <A>N</A> of <M>G</M>,
##  <Ref Func="TestHomogeneous"/> returns a record with information whether
##  the restriction of <A>chi</A> to <A>N</A> is homogeneous,
##  i.e., is a multiple of an irreducible character.
##  <P/>
##  <A>N</A> may be given also as list of conjugacy class positions
##  w.r.t.&nbsp;the character table of <M>G</M>.
##  <P/>
##  The components of the result are
##  <P/>
##  <List>
##  <Mark><C>isHomogeneous</C></Mark>
##  <Item>
##     <K>true</K> or <K>false</K>,
##  </Item>
##  <Mark><C>comment</C></Mark>
##  <Item>
##     a string telling a reason for the value of the
##     <C>isHomogeneous</C> component,
##  </Item>
##  <Mark><C>character</C></Mark>
##  <Item>
##     irreducible constituent of the restriction,
##     only bound if the restriction had to be checked,
##  </Item>
##  <Mark><C>multiplicity</C></Mark>
##  <Item>
##     multiplicity of the <C>character</C> component in the
##     restriction of <A>chi</A>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> n:= DerivedSubgroup( Sl23 );;
##  gap> chi:= Irr( Sl23 )[7];
##  Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] )
##  gap> TestHomogeneous( chi, n );
##  rec( character := Character( CharacterTable( Group(
##      [ [ [ 0*Z(3), Z(3) ], [ Z(3)^0, 0*Z(3) ] ],
##        [ [ Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ],
##        [ [ Z(3)^0, Z(3) ], [ Z(3), Z(3) ] ] ]) ),
##    [ 1, -1, 1, -1, 1 ] ), comment := "restriction checked",
##    isHomogeneous := false, multiplicity := 1 )
##  gap> chi:= Irr( Sl23 )[4];
##  Character( CharacterTable( SL(2,3) ), [ 2, 1, 1, -2, -1, -1, 0 ] )
##  gap> cln:= ClassPositionsOfNormalSubgroup( CharacterTable( Sl23 ), n );
##  [ 1, 4, 7 ]
##  gap> TestHomogeneous( chi, cln );
##  rec( comment := "restricts irreducibly", isHomogeneous := true )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestHomogeneous" );


#############################################################################
##
#P  IsPrimitiveCharacter( <chi> )
##
##  <#GAPDoc Label="IsPrimitiveCharacter">
##  <ManSection>
##  <Prop Name="IsPrimitiveCharacter" Arg='chi'/>
##
##  <Description>
##  For a character <A>chi</A> of a group <M>G</M>,
##  <Ref Prop="IsPrimitiveCharacter"/> returns <K>true</K> if <A>chi</A> is
##  not induced from any proper subgroup, and <K>false</K> otherwise. This
##  currently only works for characters of soluble groups.
##  <P/>
##  <Example><![CDATA[
##  gap> IsPrimitiveCharacter( Irr( Sl23 )[4] );
##  true
##  gap> IsPrimitiveCharacter( Irr( Sl23 )[7] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPrimitiveCharacter", IsClassFunction );


#############################################################################
##
#A  TestQuasiPrimitive( <chi> )
#P  IsQuasiPrimitive( <chi> )
##
##  <#GAPDoc Label="TestQuasiPrimitive">
##  <ManSection>
##  <Attr Name="TestQuasiPrimitive" Arg='chi'/>
##  <Prop Name="IsQuasiPrimitive" Arg='chi'/>
##
##  <Description>
##  <Ref Attr="TestQuasiPrimitive"/> returns a record with information about
##  quasiprimitivity of the group character <A>chi</A>,
##  i.e., whether <A>chi</A> restricts homogeneously to every normal subgroup
##  of its group.
##  The result record contains at least the components
##  <C>isQuasiPrimitive</C> (with value either <K>true</K> or <K>false</K>)
##  and <C>comment</C> (a string telling a reason for the value of the
##  component <C>isQuasiPrimitive</C>).
##  If <A>chi</A> is not quasiprimitive then there is additionally a
##  component <C>character</C>, with value an irreducible constituent of a
##  nonhomogeneous restriction of <A>chi</A>.
##  <P/>
##  <Ref Prop="IsQuasiPrimitive"/> returns <K>true</K> or <K>false</K>,
##  depending on whether the character <A>chi</A> is quasiprimitive.
##  <P/>
##  Note that for solvable groups, quasiprimitivity is the same as
##  primitivity (see&nbsp;<Ref Prop="IsPrimitiveCharacter"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> chi:= Irr( Sl23 )[4];
##  Character( CharacterTable( SL(2,3) ), [ 2, 1, 1, -2, -1, -1, 0 ] )
##  gap> TestQuasiPrimitive( chi );
##  rec( comment := "all restrictions checked", isQuasiPrimitive := true )
##  gap> chi:= Irr( Sl23 )[7];
##  Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] )
##  gap> TestQuasiPrimitive( chi );
##  rec( character := Character( CharacterTable( Group(
##      [ [ [ 0*Z(3), Z(3) ], [ Z(3)^0, 0*Z(3) ] ],
##        [ [ Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ],
##        [ [ Z(3)^0, Z(3) ], [ Z(3), Z(3) ] ] ]) ),
##    [ 1, -1, 1, -1, 1 ] ), comment := "restriction checked",
##    isQuasiPrimitive := false )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TestQuasiPrimitive", IsClassFunction );

DeclareProperty( "IsQuasiPrimitive", IsClassFunction );


#############################################################################
##
#F  TestInducedFromNormalSubgroup( <chi>[, <N>] )
#P  IsInducedFromNormalSubgroup( <chi> )
##
##  <#GAPDoc Label="TestInducedFromNormalSubgroup">
##  <ManSection>
##  <Func Name="TestInducedFromNormalSubgroup" Arg='chi[, N]'/>
##  <Prop Name="IsInducedFromNormalSubgroup" Arg='chi'/>
##
##  <Description>
##  <Ref Func="TestInducedFromNormalSubgroup"/> returns a record with
##  information whether the irreducible character <A>chi</A> of the group
##  <M>G</M> is induced from a proper normal subgroup of <M>G</M>.
##  If the second argument <A>N</A> is present,
##  which must be a normal subgroup of <M>G</M>
##  or the list of class positions of a normal subgroup of <M>G</M>,
##  it is checked whether <A>chi</A> is induced from <A>N</A>.
##  <P/>
##  The result contains always the components
##  <C>isInduced</C> (either <K>true</K> or <K>false</K>) and
##  <C>comment</C> (a string telling a reason for the value of the component
##  <C>isInduced</C>).
##  In the <K>true</K> case there is a  component <C>character</C> which
##  contains a character of a maximal normal subgroup from which <A>chi</A>
##  is induced.
##  <P/>
##  <Ref Prop="IsInducedFromNormalSubgroup"/> returns <K>true</K> if
##  <A>chi</A> is induced from a proper normal subgroup of <M>G</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> List( Irr( Sl23 ), IsInducedFromNormalSubgroup );
##  [ false, false, false, false, false, false, true ]
##  gap> List( Irr( S4 ){ [ 1, 3, 4 ] },
##  >          TestInducedFromNormalSubgroup );
##  [ rec( comment := "linear character", isInduced := false ),
##    rec( character := Character( CharacterTable( Alt( [ 1 .. 4 ] ) ),
##          [ 1, 1, E(3)^2, E(3) ] ),
##        comment := "induced from component '.character'",
##        isInduced := true ),
##    rec( comment := "all maximal normal subgroups checked",
##        isInduced := false ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestInducedFromNormalSubgroup" );

DeclareProperty( "IsInducedFromNormalSubgroup", IsClassFunction );


#############################################################################
##
##  3. Testing Monomiality
##
##  <#GAPDoc Label="[2]{ctblmono}">
##  A character <M>\chi</M> of a finite group <M>G</M> is called
##  <E>monomial</E> if <M>\chi</M> is induced from a linear character of a
##  subgroup of <M>G</M>.
##  A finite group <M>G</M> is called <E>monomial</E>
##  (or <E><M>M</M>-group</E>) if each
##  ordinary irreducible character of <M>G</M> is monomial.
##  <P/>
##  <!--
##  There are &GAP; properties <Ref Prop="IsMonomialGroup"/>
##  and <C>IsMonomialCharacter</C>,
##  but one can use <Ref Func="IsMonomial" Label="for groups"> instead.
##  <Index Key="IsMonomial" Subkey="for groups"><C>IsMonomial</C></Index>
##  <Index Key="IsMonomial" Subkey="for characters"><C>IsMonomial</C></Index>
##  -->
##  <#/GAPDoc>
##


#############################################################################
##
#P  IsMonomialCharacter( <chi> )
##
##  <ManSection>
##  <Prop Name="IsMonomialCharacter" Arg='chi'/>
##
##  <Description>
##  is <K>true</K> if the character <A>chi</A> is induced from
##  a linear character of a subgroup, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsMonomialCharacter", IsClassFunction );


#############################################################################
##
#P  IsMonomialNumber( <n> )
##
##  <#GAPDoc Label="IsMonomialNumber">
##  <ManSection>
##  <Prop Name="IsMonomialNumber" Arg='n'/>
##
##  <Description>
##  For a positive integer <A>n</A>,
##  <Ref Prop="IsMonomialNumber"/> returns <K>true</K> if every solvable
##  group of order <A>n</A> is monomial, and <K>false</K> otherwise.
##  One can also use <C>IsMonomial</C> instead.
##  <Index Key="IsMonomial" Subkey="for positive integers">
##  <C>IsMonomial</C></Index>
##  <P/>
##  Let <M>\nu_p(n)</M> denote the multiplicity of the prime <M>p</M> as
##  factor of <M>n</M>, and <M>ord(p,q)</M> the multiplicative order of
##  <M>p \pmod{q}</M>.
##  <P/>
##  Then there exists a solvable nonmonomial group of order <M>n</M>
##  if and only if one of the following conditions is satisfied.
##  <P/>
##  <List>
##  <Mark>1.</Mark>
##  <Item>
##    <M>\nu_2(n) \geq 2</M> and there is a <M>p</M> such that
##    <M>\nu_p(n) \geq 3</M> and <M>p \equiv -1 \pmod{4}</M>,
##  </Item>
##  <Mark>2.</Mark>
##  <Item>
##    <M>\nu_2(n) \geq 3</M> and there is a <M>p</M> such that
##    <M>\nu_p(n) \geq 3</M> and <M>p \equiv  1 \pmod{4}</M>,
##  </Item>
##  <Mark>3.</Mark>
##  <Item>
##    there are odd prime divisors <M>p</M> and <M>q</M> of <M>n</M>
##    such that <M>ord(p,q)</M> is even and <M>ord(p,q) &lt; \nu_p(n)</M>
##    (especially <M>\nu_p(n) \geq 3</M>),
##  </Item>
##  <Mark>4.</Mark>
##  <Item>
##    there is a prime divisor <M>q</M> of <M>n</M> such that
##    <M>\nu_2(n) \geq 2 ord(2,q) + 2</M>
##    (especially <M>\nu_2(n) \geq 4</M>),
##  </Item>
##  <Mark>5.</Mark>
##  <Item>
##    <M>\nu_2(n) \geq 2</M> and there is a <M>p</M> such that
##    <M>p \equiv  1 \pmod{4}</M>, <M>ord(p,q)</M> is odd,
##    and <M>2 ord(p,q) &lt; \nu_p(n)</M>
##    (especially <M>\nu_p(n) \geq 3</M>).
##  </Item>
##  </List>
##  <P/>
##  These five possibilities correspond to the five types of solvable minimal
##  nonmonomial groups (see&nbsp;<Ref Func="MinimalNonmonomialGroup"/>)
##  that can occur as subgroups and factor groups of groups of order
##  <A>n</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> Filtered( [ 1 .. 111 ], x -> not IsMonomial( x ) );
##  [ 24, 48, 72, 96, 108 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsMonomialNumber", IsPosInt );


#############################################################################
##
#A  TestMonomialQuick( <chi> )
#A  TestMonomialQuick( <G> )
##
##  <#GAPDoc Label="TestMonomialQuick">
##  <ManSection>
##  <Heading>TestMonomialQuick</Heading>
##  <Attr Name="TestMonomialQuick" Arg='chi' Label="for a character"/>
##  <Attr Name="TestMonomialQuick" Arg='G' Label="for a group"/>
##
##  <Description>
##  <Ref Attr="TestMonomialQuick" Label="for a group"/> does some cheap tests
##  whether the irreducible character <A>chi</A> or the group <A>G</A>,
##  respectively, is monomial.
##  Here <Q>cheap</Q> means in particular that no computations of character
##  tables are involved,
##  and it is <E>not</E> checked whether <A>chi</A> is a character and
##  irreducible.
##  The return value is a record with components
##  <List>
##  <Mark><C>isMonomial</C></Mark>
##  <Item>
##     either <K>true</K> or <K>false</K> or the string <C>"?"</C>,
##     depending on whether (non)monomiality could be proved, and
##  </Item>
##  <Mark><C>comment</C></Mark>
##  <Item>
##     a string telling the reason for the value of the
##     <C>isMonomial</C> component.
##  </Item>
##  </List>
##  <P/>
##  A group <A>G</A> is proved to be monomial by
##  <Ref Attr="TestMonomialQuick" Label="for a group"/> if
##  <A>G</A> is nilpotent or Sylow abelian by supersolvable,
##  or if <A>G</A> is solvable and its order is not divisible by the third
##  power of a prime,
##  Nonsolvable groups are proved to be nonmonomial by
##  <Ref Attr="TestMonomialQuick" Label="for a group"/>.
##  <P/>
##  An irreducible character <A>chi</A> is proved to be monomial if
##  it is linear, or if its codegree is a prime power,
##  or if its group knows to be monomial,
##  or if the factor group modulo the kernel can be proved to be monomial by
##  <Ref Attr="TestMonomialQuick" Label="for a group"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> TestMonomialQuick( Irr( S4 )[3] );
##  rec( comment := "whole group is monomial", isMonomial := true )
##  gap> TestMonomialQuick( S4 );
##  rec( comment := "abelian by supersolvable group", isMonomial := true )
##  gap> TestMonomialQuick( Sl23 );
##  rec( comment := "no decision by cheap tests", isMonomial := "?" )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TestMonomialQuick", IsClassFunction );
DeclareAttribute( "TestMonomialQuick", IsGroup );


#############################################################################
##
#A  TestMonomial( <chi> )
#A  TestMonomial( <G> )
#O  TestMonomial( <chi>, <uselattice> )
#O  TestMonomial( <G>, <uselattice> )
##
##  <#GAPDoc Label="TestMonomial">
##  <ManSection>
##  <Heading>TestMonomial</Heading>
##  <Attr Name="TestMonomial" Arg='chi' Label="for a character"/>
##  <Attr Name="TestMonomial" Arg='G' Label="for a group"/>
##  <Oper Name="TestMonomial" Arg='chi, uselattice'
##        Label="for a character and a Boolean"/>
##  <Oper Name="TestMonomial" Arg='G, uselattice'
##        Label="for a group and a Boolean"/>
##
##  <Description>
##  Called with a group character <A>chi</A> of a group <A>G</A>,
##  <Ref Attr="TestMonomial" Label="for a character"/>
##  returns a record containing information about monomiality of the group
##  <A>G</A> or the group character <A>chi</A>, respectively.
##  <P/>
##  If <Ref Attr="TestMonomial" Label="for a character"/> proves
##  the character <A>chi</A> to be monomial then the result contains
##  components <C>isMonomial</C> (with value <K>true</K>),
##  <C>comment</C> (a string telling a reason for monomiality),
##  and if it was necessary to compute a linear character from which
##  <A>chi</A> is induced, also a component <C>character</C>.
##  <P/>
##  If <Ref Attr="TestMonomial" Label="for a character"/> proves <A>chi</A>
##  or <A>G</A> to be nonmonomial
##  then the value of the component <C>isMonomial</C> is <K>false</K>,
##  and in the case of <A>G</A> a nonmonomial character is the value
##  of the component <C>character</C> if it had been necessary to compute it.
##  <P/>
##  A Boolean can be entered as the second argument <A>uselattice</A>;
##  if the value is <K>true</K> then the subgroup lattice of the underlying
##  group is used if necessary,
##  if the value is <K>false</K> then the subgroup lattice is used only for
##  groups of order at most <Ref Var="TestMonomialUseLattice"/>.
##  The default value of <A>uselattice</A> is <K>false</K>.
##  <P/>
##  For a group whose lattice must not be used, it may happen that
##  <Ref Attr="TestMonomial" Label="for a group"/> cannot prove or disprove
##  monomiality; then the result
##  record contains the component <C>isMonomial</C> with value <C>"?"</C>.
##  This case occurs in the call for a character <A>chi</A> if and only if
##  <A>chi</A> is not induced from the inertia subgroup of a component of any
##  reducible restriction to a normal subgroup.
##  It can happen that <A>chi</A> is monomial in this situation.
##  For a group, this case occurs if no irreducible character can be proved
##  to be nonmonomial, and if no decision is possible for at least one
##  irreducible character.
##  <P/>
##  <Example><![CDATA[
##  gap> TestMonomial( S4 );
##  rec( comment := "abelian by supersolvable group", isMonomial := true )
##  gap> TestMonomial( Sl23 );
##  rec( comment := "list Delta( G ) contains entry > 1",
##    isMonomial := false )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TestMonomial", IsClassFunction );
DeclareAttribute( "TestMonomial", IsGroup );
DeclareOperation( "TestMonomial", [ IsClassFunction, IsBool ] );
DeclareOperation( "TestMonomial", [ IsGroup, IsBool ] );


#############################################################################
##
#V  TestMonomialUseLattice
##
##  <#GAPDoc Label="TestMonomialUseLattice">
##  <ManSection>
##  <Var Name="TestMonomialUseLattice"/>
##
##  <Description>
##  This global variable controls for which groups the operation
##  <Ref Oper="TestMonomial" Label="for a group and a Boolean"/> may compute
##  the subgroup lattice.
##  The value can be set to a positive integer or <Ref Var="infinity"/>,
##  the default is <M>1000</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
TestMonomialUseLattice := 1000;


#############################################################################
##
#A  TestSubnormallyMonomial( <G> )
#A  TestSubnormallyMonomial( <chi> )
#P  IsSubnormallyMonomial( <G> )
#P  IsSubnormallyMonomial( <chi> )
##
##  <#GAPDoc Label="TestSubnormallyMonomial">
##  <ManSection>
##  <Heading>TestSubnormallyMonomial</Heading>
##  <Attr Name="TestSubnormallyMonomial" Arg='G' Label="for a group"/>
##  <Attr Name="TestSubnormallyMonomial" Arg='chi' Label="for a character"/>
##  <Prop Name="IsSubnormallyMonomial" Arg='G' Label="for a group"/>
##  <Prop Name="IsSubnormallyMonomial" Arg='chi' Label="for a character"/>
##
##  <Description>
##  An irreducible character of the group <M>G</M> is called
##  <E>subnormally monomial</E> (<E>SM</E> for short) if it is induced
##  from a linear character of a subnormal subgroup of <M>G</M>.
##  A group <M>G</M> is called SM if all its irreducible characters are SM.
##  <P/>
##  <Ref Attr="TestSubnormallyMonomial" Label="for a group"/> returns
##  a record with information whether the group <A>G</A> or the irreducible
##  character <A>chi</A> of <A>G</A> is SM.
##  <P/>
##  The result has the components
##  <C>isSubnormallyMonomial</C> (either <K>true</K> or <K>false</K>) and
##  <C>comment</C> (a string telling a reason for the value of the component
##  <C>isSubnormallyMonomial</C>);
##  in the case that the <C>isSubnormallyMonomial</C> component has value
##  <K>false</K> there is also a component <C>character</C>,
##  with value an irreducible character of <M>G</M> that is not SM.
##  <P/>
##  <Ref Prop="IsSubnormallyMonomial" Label="for a group"/> returns
##  <K>true</K> if the group <A>G</A> or the group character <A>chi</A>
##  is subnormally monomial, and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> TestSubnormallyMonomial( S4 );
##  rec( character := Character( CharacterTable( S4 ), [ 3, -1, -1, 0, 1
##       ] ), comment := "found non-SM character",
##    isSubnormallyMonomial := false )
##  gap> TestSubnormallyMonomial( Irr( S4 )[4] );
##  rec( comment := "all subnormal subgroups checked",
##    isSubnormallyMonomial := false )
##  gap> TestSubnormallyMonomial( DerivedSubgroup( S4 ) );
##  rec( comment := "all irreducibles checked",
##    isSubnormallyMonomial := true )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TestSubnormallyMonomial", IsGroup );
DeclareAttribute( "TestSubnormallyMonomial", IsClassFunction );

DeclareProperty( "IsSubnormallyMonomial", IsGroup );
DeclareProperty( "IsSubnormallyMonomial", IsClassFunction );


#############################################################################
##
#A  TestRelativelySM( <G> )
#A  TestRelativelySM( <chi> )
#O  TestRelativelySM( <G>, <N> )
#O  TestRelativelySM( <chi>, <N> )
#P  IsRelativelySM( <G> )
#P  IsRelativelySM( <chi> )
##
##  <#GAPDoc Label="TestRelativelySM">
##  <ManSection>
##  <Heading>TestRelativelySM</Heading>
##  <Attr Name="TestRelativelySM" Arg='G' Label="for a group"/>
##  <Attr Name="TestRelativelySM" Arg='chi' Label="for a character"/>
##  <Oper Name="TestRelativelySM" Arg='G, N'
##        Label="for a group and a normal subgroup"/>
##  <Oper Name="TestRelativelySM" Arg='chi, N'
##        Label="for a character and a normal subgroup"/>
##  <Prop Name="IsRelativelySM" Arg='G' Label="for a group"/>
##  <Prop Name="IsRelativelySM" Arg='chi' Label="for a character"/>
##
##  <Description>
##  In the first two cases,
##  <Ref Attr="TestRelativelySM" Label="for a group"/> returns a record with
##  information whether the argument, which must be a SM group <A>G</A> or
##  an irreducible character <A>chi</A> of a SM group <M>G</M>,
##  is relatively SM with respect to every normal subgroup of <A>G</A>.
##  <P/>
##  In the second two cases, a normal subgroup <A>N</A> of <A>G</A> is the
##  second argument.
##  Here
##  <Ref Oper="TestRelativelySM" Label="for a group and a normal subgroup"/>
##  returns a record with information whether
##  the first argument is relatively SM with respect to <A>N</A>,
##  i.e, whether there is a subnormal subgroup <M>H</M> of <M>G</M> that
##  contains <A>N</A> such that the character <A>chi</A>
##  resp.&nbsp;every irreducible character of <M>G</M> is induced from a
##  character <M>\psi</M> of <M>H</M> such that the restriction of
##  <M>\psi</M> to <A>N</A> is irreducible.
##  <P/>
##  The result record has the components
##  <C>isRelativelySM</C> (with value either <K>true</K> or <K>false</K>) and
##  <C>comment</C> (a string that describes a reason).
##  If the argument is a group <A>G</A> that is not relatively SM
##  with respect to a normal subgroup then additionally the component
##  <C>character</C> is bound,
##  with value a not relatively SM character of such a normal subgroup.
##  <P/>
##  <Ref Prop="IsRelativelySM" Label="for a group"/> returns <K>true</K>
##  if the SM group <A>G</A> or the irreducible character <A>chi</A>
##  of the SM group <A>G</A> is relatively SM with respect to every
##  normal subgroup of <A>G</A>,
##  and <K>false</K> otherwise.
##  <P/>
##  <E>Note</E> that it is <E>not</E> checked whether <A>G</A> is SM.
##  <P/>
##  <Example><![CDATA[
##  gap> IsSubnormallyMonomial( DerivedSubgroup( S4 ) );
##  true
##  gap> TestRelativelySM( DerivedSubgroup( S4 ) );
##  rec(
##    comment := "normal subgroups are abelian or have nilpotent factor gr\
##  oup", isRelativelySM := true )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TestRelativelySM", IsGroup );
DeclareAttribute( "TestRelativelySM", IsClassFunction );

DeclareOperation( "TestRelativelySM", [ IsClassFunction, IsGroup ] );
DeclareOperation( "TestRelativelySM", [ IsGroup, IsGroup ] );

DeclareProperty( "IsRelativelySM", IsClassFunction );
DeclareProperty( "IsRelativelySM", IsGroup );


#############################################################################
##
##  4. Minimal Nonmonomial Groups
##


#############################################################################
##
#P  IsMinimalNonmonomial( <G> )
##
##  <#GAPDoc Label="IsMinimalNonmonomial">
##  <ManSection>
##  <Prop Name="IsMinimalNonmonomial" Arg='G'/>
##
##  <Description>
##  A group <A>G</A> is called <E>minimal nonmonomial</E> if it is
##  nonmonomial, and all proper subgroups and factor groups are monomial.
##  <P/>
##  <Example><![CDATA[
##  gap> IsMinimalNonmonomial( Sl23 );  IsMinimalNonmonomial( S4 );
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsMinimalNonmonomial", IsGroup );


#############################################################################
##
#F  MinimalNonmonomialGroup( <p>, <factsize> )
##
##  <#GAPDoc Label="MinimalNonmonomialGroup">
##  <ManSection>
##  <Func Name="MinimalNonmonomialGroup" Arg='p, factsize'/>
##
##  <Description>
##  is a solvable minimal nonmonomial group described by the parameters
##  <A>factsize</A> and <A>p</A> if such a group exists,
##  and <K>false</K> otherwise.
##  <P/>
##  Suppose that the required group <M>K</M> exists.
##  Then <A>factsize</A> is the size of the Fitting factor <M>K / F(K)</M>,
##  and this value is 4, 8, an odd prime, twice an odd prime,
##  or four times an odd prime.
##  In the case that <A>factsize</A> is twice an odd prime,
##  the centre <M>Z(K)</M> is cyclic of order <M>2^{{<A>p</A>+1}}</M>.
##  In all other cases <A>p</A> is the (unique) prime that divides
##  the order of <M>F(K)</M>.
##  <P/>
##  The solvable minimal nonmonomial groups were classified by van der Waall,
##  see&nbsp;<Cite Key="vdW76"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> MinimalNonmonomialGroup(  2,  3 ); # the group SL(2,3)
##  2^(1+2):3
##  gap> MinimalNonmonomialGroup(  3,  4 );
##  3^(1+2):4
##  gap> MinimalNonmonomialGroup(  5,  8 );
##  5^(1+2):Q8
##  gap> MinimalNonmonomialGroup( 13, 12 );
##  13^(1+2):2.D6
##  gap> MinimalNonmonomialGroup(  1, 14 );
##  2^(1+6):D14
##  gap> MinimalNonmonomialGroup(  2, 14 );
##  (2^(1+6)Y4):D14
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MinimalNonmonomialGroup" );
