#############################################################################
##
#W  interfac.gd          GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: interfac.gd,v 1.45 2009/03/31 16:49:16 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration part of the ``high level'' &GAP;
##  interface to the &ATLAS; of Group Representations.
##
Revision.( "atlasrep/gap/interfac_gd" ) :=
    "@(#)$Id: interfac.gd,v 1.45 2009/03/31 16:49:16 gap Exp $";


#############################################################################
##  
#F  DisplayAtlasInfoOverview( <gapnames>, <tocs>, <conditions> )
##  
DeclareGlobalFunction( "DisplayAtlasInfoOverview" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsInfoPRG( <gapname>, <tocs>, <name>, <std> )
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsInfoPRG" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsInfoGroup( <tocs>, <conditions> )
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsInfoGroup" );


#############################################################################
##
#F  DisplayAtlasInfo( [<listofnames>][, ]["contents", <sources>]
#F                    [, IsPermGroup[, true]] 
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>] 
#F                    [, Position, <n>]
#F                    [, Identifier, <id>] )
#F  DisplayAtlasInfo( <gapname>[, <std>][, "contents", <sources>]
#F                    [, IsPermGroup[, true]] 
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>] 
#F                    [, Position, <n>]
#F                    [, Identifier, <id>]
#F                    [, IsStraightLineProgram[, true]] )
##
##  <#GAPDoc Label="DisplayAtlasInfo">
##  <ManSection>
##  <Func Name="DisplayAtlasInfo"
##  Arg='[listofnames][, ]["contents", sources][, ...]'/>
##  <Func Name="DisplayAtlasInfo" Arg='gapname[, std][, ...]'
##  Label="for a group name, and optionally further restrictions"/>
##
##  <Description>
##  This function lists the information available via the
##  <Package>AtlasRep</Package> package, for the given input.
##  Depending on whether remote access to data is enabled
##  (see Section <Ref Subsect="subsect:Local or remote access"/>),
##  all the data provided by the &ATLAS; of Group Representations
##  or only those in the local installation are considered.
##  <P/>
##  (An interactive alternative to <Ref Func="DisplayAtlasInfo"/> is the
##  function <Ref Func="BrowseAtlasInfo" BookName="Browse"/>,
##  see <Cite Key="Browse1.2"/>; this function provides also
##  the functionality of <Ref Func="AtlasGenerators"/>.)
##  <P/>
##  Called without arguments, <Ref Func="DisplayAtlasInfo"/> prints an
##  overview what information the &ATLAS; of Group Representations provides.
##  One line is printed for each group <M>G</M>, with the following columns.
##  <P/>
##  <List>
##  <Mark><C>group</C></Mark>
##  <Item>
##    the &GAP; name of <M>G</M>
##    (see Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>),
##  </Item>
##  <Mark><C>#</C></Mark>
##  <Item>
##    the number of representations stored for <M>G</M>
##    that satisfy the additional conditions given (see below),
##  </Item>
##  <Mark><C>maxes</C></Mark>
##  <Item>
##    the available straight line programs
##    <Index>straight line program</Index>
##    for computing generators of maximal subgroups of <M>G</M>,
##  </Item>
##  <Mark><C>cl</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program for computing representatives
##    of conjugacy classes of elements of <M>G</M> is stored,
##    and a <C>-</C> sign otherwise,
##  </Item>
##  <Mark><C>cyc</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program for computing representatives
##    of classes of maximally cyclic subgroups of <M>G</M> is stored,
##    and a <C>-</C> sign otherwise,
##  </Item>
##  <Mark><C>out</C></Mark>
##  <Item>
##    descriptions of outer automorphisms of <M>G</M> for which at least
##    one program is stored,
##  </Item>
##  <Mark><C>check</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program is available for checking
##    whether a set of generators is a set of standard generators,
##    and a <C>-</C> sign otherwise,
##  </Item>
##  <Mark><C>pres</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program is available that encodes a
##    presentation,
##    and a <C>-</C> sign otherwise,
##  </Item>
##  <Mark><C>find</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program is available for finding
##    standard generators,
##    and a <C>-</C> sign otherwise,
##  </Item>
##  </List>
##  <P/>
##  (The list can be printed to the screen or be fed into a pager,
##  see Section <Ref Subsect="subsect:Customizing DisplayAtlasInfo"/>.)
##  <P/>
##  Called with a list <A>listofnames</A> of strings that are &GAP; names for
##  a group from the &ATLAS; of Group Representations,
##  <Ref Func="DisplayAtlasInfo"/> prints the overview described above
##  but restricted to the groups in this list.
##  <P/>
##  In addition to or instead of <A>listofnames</A>,
##  the string <C>"contents"</C> and a description <A>sources</A> of the
##  data may be given about which the overview is formed.
##  See below for admissible values of <A>sources</A>.
##  <P/>
##  Called with a string <A>gapname</A> that is a &GAP; name for a group from
##  the &ATLAS; of Group Representations,
##  <Ref Func="DisplayAtlasInfo"/> prints an overview of the information
##  that is available for this group.
##  One line is printed for each representation, showing the number of this
##  representation
##  (which can be used in calls of <Ref Func="AtlasGenerators"/>),
##  and a string of one of the following forms;
##  in both cases, <A>id</A> is a (possibly empty) string.
##  <P/>
##  <List>
##  <Mark><C>G &lt;= Sym(<A>n</A><A>id</A>)</C></Mark>
##  <Item>
##      denotes a permutation representation of degree <A>n</A>,
##      for example <C>G &lt;= Sym(40a)</C> and <C>G &lt;= Sym(40b)</C>
##      denote two (nonequivalent) representations of degree <M>40</M>.
##  </Item>
##  <Mark><C>G &lt;= GL(<A>n</A><A>id</A>,<A>descr</A>)</C></Mark>
##  <Item>
##      denotes a matrix representation of dimension <A>n</A> over a
##      coefficient ring described by <A>descr</A>,
##      which can be a prime power,
##      <C>Z</C> (denoting the ring of integers),
##      a description of an algebraic extension field,
##      <C>C</C> (denoting an unspecified algebraic extension field), or
##      <C>Z/<A>m</A>Z</C> for an integer <A>m</A>
##      (denoting the ring of residues mod <A>m</A>);
##      for example, <C>G &lt;= GL(2a,4)</C> and <C>G &lt;= GL(2b,4)</C>
##      denote two (nonequivalent) representations of dimension <M>2</M> over
##      the field with four elements.
##  </Item>
##  </List>
##  <P/>
##  After the representations,
##  the programs available for <A>gapname</A> are listed.
##  <P/>
##  The following optional arguments can be used to restrict the overviews.
##  <P/>
##  <List>
##  <Mark><A>std</A></Mark>
##  <Item>
##    must be a positive integer or a list of positive integers;
##    if it is given then only those representations are considered
##    that refer to the <A>std</A>-th set of standard generators or the
##    <M>i</M>-th set of standard generators, for <M>i</M> in <A>std</A>
##    (see
##    Section&nbsp;<Ref Sect="sect:Standard Generators Used in AtlasRep"/>),
##  </Item>
##  <Mark><C>"contents"</C> and <A>sources</A></Mark>
##  <Item>
##    for a string or a list of strings <A>sources</A>,
##    restrict the data about which the overview is formed;
##    if <A>sources</A> is the string <C>"public"</C> then only non-private
##    data
##    (see Chapter <Ref Chap="chap:Private Extensions"/>)
##    are considered,
##    if <A>sources</A> is a string that denotes a private extension in the
##    sense of a <A>dirid</A> argument of
##    <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/> then
##    only the data that belong to this private extension are considered;
##    also a list of such strings may be given, then the union of these
##    data is considered,
##  </Item>
##  <Mark><C>Identifier</C> and <A>id</A></Mark>
##  <Item>
##    restrict to representations with <C>id</C> component equal to
##    <A>id</A>, or in the list <A>id</A>,
##    or satisfying the function <A>id</A>,
##  </Item>
##  <Mark><C>IsPermGroup</C> and <K>true</K></Mark>
##  <Item>
##    restrict to permutation representations,
##  </Item>
##  <Mark><C>NrMovedPoints</C> and <A>n</A></Mark>
##  <Item>
##    for a positive integer, a list of positive integers,
##    or a property <A>n</A>,
##    restrict to permutation representations of degree equal to <A>n</A>,
##    or in the list <A>n</A>, or satisfying the function <A>n</A>,
##  </Item>
##  <Mark><C>NrMovedPoints</C> and the string <C>"minimal"</C></Mark>
##  <Item>
##    restrict to faithful permutation representations of minimal degree
##    (if this information is available),
##  </Item>
##  <Mark><C>IsTransitive</C> and <K>true</K> or <K>false</K></Mark>
##  <Item>
##    restrict to transitive or intransitive permutation representations
##    (if this information is available),
##  </Item>
##  <Mark><C>IsPrimitive</C> and <K>true</K> or <K>false</K></Mark>
##  <Item>
##    restrict to primitive or imprimitive permutation representations
##    (if this information is available),
##  </Item>
##  <Mark><C>Transitivity</C> and <A>n</A></Mark>
##  <Item>
##    for a nonnegative integer, a list of nonnegative integers,
##    or a property <A>n</A>,
##    restrict to permutation representations of transitivity equal to
##    <A>n</A>, or in the list <A>n</A>, or satisfying the function <A>n</A>
##    (if this information is available),
##  </Item>
##  <Mark><C>RankAction</C> and <A>n</A></Mark>
##  <Item>
##    for a nonnegative integer, a list of nonnegative integers,
##    or a property <A>n</A>,
##    restrict to permutation representations of rank equal to
##    <A>n</A>, or in the list <A>n</A>, or satisfying the function <A>n</A>
##    (if this information is available),
##  </Item>
##  <Mark><C>IsMatrixGroup</C> and <K>true</K></Mark>
##  <Item>
##    restrict to matrix representations,
##  </Item>
##  <Mark><C>Characteristic</C> and <A>p</A></Mark>
##  <Item>
##    for a prime integer, a list of prime integers, or a property <A>p</A>,
##    restrict to matrix representations over fields of characteristic equal
##    to <A>p</A>, or in the list <A>p</A>,
##    or satisfying the function <A>p</A>
##    (representations over residue class rings that are not fields can be
##    addressed by entering <K>fail</K> as the value of <A>p</A>),
##  </Item>
##  <Mark><C>Dimension</C> and <A>n</A></Mark>
##  <Item>
##    for a positive integer, a list of positive integers,
##    or a property <A>n</A>,
##    restrict to matrix representations of dimension equal to <A>n</A>,
##    or in the list <A>n</A>, or satisfying the function <A>n</A>,
##  </Item>
##  <Mark><C>Characteristic</C>, <A>p</A>, <C>Dimension</C>,
##        and the string <C>"minimal"</C></Mark>
##  <Item>
##    for a prime integer <A>p</A>,
##    restrict to faithful matrix representations over fields
##    of characteristic <A>p</A> that have minimal dimension
##    (if this information is available),
##  </Item>
##  <Mark><C>Ring</C> and <A>R</A></Mark>
##  <Item>
##    for a ring or a property <A>R</A>,
##    restrict to matrix representations over this ring
##    or satisfying this function
##    (note that the representation might be defined over a proper subring
##    of <A>R</A>),
##    and
##  </Item>
##  <Mark><C>Ring</C>, <A>R</A>, <C>Dimension</C>,
##        and the string <C>"minimal"</C></Mark>
##  <Item>
##    for a ring <A>R</A>, restrict to faithful matrix representations
##    over this ring that have minimal dimension
##    (if this information is available),
##  </Item>
##  <Mark><C>IsStraightLineProgram</C></Mark>
##  <Item>
##    restricts to straight line programs,
##    straight line decisions
##    (see Section&nbsp;<Ref Sect="sect:Straight Line Decisions"/>),
##    and black box programs
##    (see Section&nbsp;<Ref Sect="sect:Black Box Programs"/>).
##  </Item>
##  </List>
##  <P/>
##  Note that the above conditions refer only to the information that is
##  available without accessing the representations.
##  For example, if it is not stored in the table of contents whether a
##  permutation representation is primitive then this representation does not
##  match an <C>IsPrimitive</C> condition in <Ref Func="DisplayAtlasInfo"/>.
##  <P/>
##  If <Q>minimality</Q> information is requested and no available
##  representation matches this condition then either no minimal
##  representation is available or the information about the minimality
##  is missing.
##  See <Ref Func="MinimalRepresentationInfo"/> for checking whether the
##  minimality information is available for the group in question.
##  Note that in the cases where the string <C>"minimal"</C> occurs as an
##  argument, <Ref Func="MinimalRepresentationInfo"/> is called with third
##  argument <C>"lookup"</C>;
##  this is because the stored information was computed just for the groups
##  in the &ATLAS; of Group Representations,
##  so trying to compute non-stored minimality information (using other
##  available databases) will hardly be successful.
##  <P/>
##  The representations are ordered as follows.
##  Permutation representations come first (ordered according to their
##  degrees),
##  followed by matrix representations over finite fields
##  (ordered first according to the field size and second according to
##  the dimension), matrix representations over the integers,
##  and then matrix representations over algebraic extension fields
##  (both kinds ordered according to the dimension),
##  the last representations are matrix representations over residue class
##  rings (ordered first according to the modulus and second according to the
##  dimension).
##  <P/>
##  The maximal subgroups are ordered according to decreasing group order.
##  For an extension <M>G.p</M> of a simple group <M>G</M> by an outer
##  automorphism of prime order <M>p</M>,
##  this means that <M>G</M> is the first maximal subgroup
##  and then come the extensions of the maximal subgroups of <M>G</M> and the
##  novelties;
##  so the <M>n</M>-th maximal subgroup of <M>G</M> and the <M>n</M>-th
##  maximal subgroup of <M>G.p</M> are in general not related.
##  (This coincides with the numbering used for the
##  <Ref Func="Maxes" BookName="ctbllib"/> attribute for character tables.)
##  <P/>
##  <Example><![CDATA[
##  gap> DisplayAtlasInfo( [ "M11", "A5" ] );
##  group     #  maxes  cl  cyc  out  find  check  pres
##  ---------------------------------------------------
##  M11      42      5   +    +          +      +     +
##  A5       18      3   -    -          -      +     +
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DisplayAtlasInfo" );


#############################################################################
##
#F  AtlasGenerators( <gapname>, <repnr>[, <maxnr>] )
#F  AtlasGenerators( <identifier> )
##
##  <#GAPDoc Label="AtlasGenerators">
##  <ManSection>
##  <Func Name="AtlasGenerators" Arg='gapname, repnr[, maxnr]'/>
##  <Func Name="AtlasGenerators" Arg='identifier' Label="for an identifier"/>
##
##  <Returns>
##  a record containing generators for a representation, or <K>fail</K>.
##  </Returns>
##  <Description>
##  In the first form, <A>gapname</A> must be a string denoting a &GAP; name
##  (see
##  Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>)
##  of a group, and <A>repnr</A> a positive integer.
##  If the &ATLAS; of Group Representations contains at least <A>repnr</A>
##  representations for the group with &GAP; name <A>gapname</A> then
##  <Ref Func="AtlasGenerators"/>,
##  when called with <A>gapname</A> and <A>repnr</A>,
##  returns an immutable record describing the <A>repnr</A>-th
##  representation;
##  otherwise <K>fail</K> is returned.
##  If a third argument <A>maxnr</A>, a positive integer,
##  is given then an immutable record describing the restriction of the
##  <A>repnr</A>-th representation to the <A>maxnr</A>-th maximal subgroup is
##  returned.
##  <P/>
##  The result record has the following components.
##  <P/>
##  <List>
##  <Mark><C>groupname</C></Mark>
##  <Item>
##    the &GAP; name of the group (see
##    Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>),
##  </Item>
##  <Mark><C>generators</C></Mark>
##  <Item>
##    a list of generators for the group,
##  </Item>
##  <Mark><C>standardization</C></Mark>
##  <Item>
##    the positive integer denoting the underlying standard generators,
##  </Item>
##  <Mark><C>size</C> (only if known)</Mark>
##  <Item>
##    the order of the group,
##  </Item>
##  <Mark><C>identifier</C></Mark>
##  <Item>
##    a &GAP; object (a list of filenames plus additional information)
##    that uniquely determines the representation;
##    the value can be used as <A>identifier</A> argument of
##    <Ref Func="AtlasGenerators"/>.
##  </Item>
##  <Mark><C>repnr</C></Mark>
##  <Item>
##    the number of the representation in the current session,
##    equal to the argument <A>repnr</A> if this is given.
##  </Item>
##  </List>
##  <P/>
##  Additionally, there are describing components dependent on the data type
##  of the representation:
##  For permutation representations, these are <C>p</C> for the number of
##  moved points and <C>id</C> for the distinguishing string as described for
##  <Ref Func="DisplayAtlasInfo"/>;
##  for matrix representations, these are <C>dim</C> for the dimension of the
##  matrices, <C>ring</C> (if known) for the ring generated by the matrix
##  entries, and <C>id</C> for the distinguishing string.
##  <P/>
##  It should be noted that the number <A>repnr</A> refers to the number
##  shown by <Ref Func="DisplayAtlasInfo"/> <E>in the current session</E>;
##  it may be that after the addition of new representations,
##  <A>repnr</A> refers to another representation.
##  <P/>
##  The alternative form of <Ref Func="AtlasGenerators"/>,
##  with only argument <A>identifier</A>,
##  can be used to fetch the result record with <C>identifier</C> value equal
##  to <A>identifier</A>.
##  The purpose of this variant is to access the <E>same</E> representation
##  also in <E>different</E> &GAP; sessions.
##  <Example><![CDATA[
##  gap> gens1:= AtlasGenerators( "A5", 1 );
##  rec( generators := [ (1,2)(3,4), (1,3,5) ], groupname := "A5",
##    standardization := 1, repnr := 1, 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], p := 5, 
##    id := "", stabilizer := "A4", size := 60 )
##  gap> gens8:= AtlasGenerators( "A5", 8 );
##  rec( 
##    generators := [ [ [ Z(2)^0, 0*Z(2) ], [ Z(2^2), Z(2)^0 ] ], [ [ 0*Z(2), Z(2
##                   )^0 ], [ Z(2)^0, Z(2)^0 ] ] ], groupname := "A5",
##    standardization := 1, repnr := 8, 
##    identifier := [ "A5", [ "A5G1-f4r2aB0.m1", "A5G1-f4r2aB0.m2" ], 1, 4 ], 
##    dim := 2, id := "a", ring := GF(2^2), size := 60 )
##  gap> gens17:= AtlasGenerators( "A5", 17 );
##  rec( 
##    generators := [ [ [ -1, 0, 0 ], [ 0, -1, 0 ], [ -E(5)-E(5)^4, -E(5)-E(5)^4, 
##                1 ] ], [ [ 0, 1, 0 ], [ 0, 0, 1 ], [ 1, 0, 0 ] ] ], 
##    groupname := "A5", standardization := 1, repnr := 17, 
##    identifier := [ "A5", "A5G1-Ar3aB0.g", 1, 3 ], dim := 3, id := "a", 
##    ring := NF(5,[ 1, 4 ]), size := 60 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasGenerators" );


#############################################################################
##
#F  AtlasProgram( <gapname>[, <std>][, "maxes"], <maxnr> )
#F  AtlasProgram( <gapname>[, <std>], "classes" )
#F  AtlasProgram( <gapname>[, <std>], "cyclic" )
#F  AtlasProgram( <gapname>[, <std>], "automorphism", <autname> )
#F  AtlasProgram( <gapname>[, <std>], "check" )
#F  AtlasProgram( <gapname>[, <std>], "presentation" )
#F  AtlasProgram( <gapname>[, <std>], "find" )
#F  AtlasProgram( <gapname>, <std>, "restandardize", <std2> )
#F  AtlasProgram( <gapname>[, <std>], "other", <descr> )
#F  AtlasProgram( <identifier> )
##
##  <#GAPDoc Label="AtlasProgram">
##  <ManSection>
##  <Func Name="AtlasProgram" Arg='gapname[, std], ...'/>
##  <Func Name="AtlasProgram" Arg='identifier' Label="for an identifier"/>
##
##  <Returns>
##  a record containing a program, or <K>fail</K>.
##  </Returns>
##  <Description>
##  In the first form, <A>gapname</A> must be a string denoting a &GAP; name
##  (see Section
##  &nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>)
##  of a group <M>G</M>, say.
##  If the &ATLAS; of Group Representations contains a straight line program
##  (see Section&nbsp;<Ref Sect="Straight Line Programs" BookName="ref"/>)
##  or straight line decision
##  (see Section&nbsp;<Ref Sect="sect:Straight Line Decisions"/>)
##  or black box program
##  (see Section&nbsp;<Ref Sect="sect:Black Box Programs"/>)
##  as described by the remaining arguments (see below) then
##  <Ref Func="AtlasProgram"/> returns an immutable record
##  containing this program.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  If the optional argument <A>std</A> is given, only those straight line
##  programs/decisions are considered
##  that take generators from the <A>std</A>-th set
##  of standard generators of <M>G</M> as input,
##  see Section&nbsp;<Ref Sect="sect:Standard Generators Used in AtlasRep"/>.
##  <P/>
##  The result record has the following components.
##  <P/>
##  <List>
##  <Mark><C>program</C></Mark>
##  <Item>
##      the required straight line program/decision, or black box program,
##  </Item>
##  <Mark><C>standardization</C></Mark>
##  <Item>
##      the positive integer denoting the underlying standard generators of
##      <M>G</M>,
##  </Item>
##  <Mark><C>identifier</C></Mark>
##  <Item>
##      a &GAP; object (a list of filenames plus additional information)
##      that uniquely determines the program;
##      the value can be used as <A>identifier</A> argument of
##      <Ref Func="AtlasProgram"/> (see below).
##  </Item>
##  </List>
##  <P/>
##  In the first form, the last arguments must be as follows.
##  <P/>
##  <List>
##  <Mark>(the string <C>"maxes"</C> and) a positive integer <A>maxnr</A>
##  </Mark>
##  <Item>
##    the required program computes generators of the <A>maxnr</A>-th
##    maximal subgroup of the group with &GAP; name <A>gapname</A>.
##    <Index Subkey="for maximal subgroups">straight line program</Index>
##    <Index>maximal subgroups</Index>
##    <P/>
##    In this case, the result record of <Ref Func="AtlasProgram"/> also
##    may contain a component <C>size</C>,
##    whose value is the order of the maximal subgroup in question.
##  </Item>
##  <Mark>one of the strings <C>"classes"</C> or <C>"cyclic"</C></Mark>
##  <Item>
##    the required program computes representatives of conjugacy classes
##    of elements or representatives of generators of maximally cyclic
##    subgroups of <M>G</M>, respectively.
##    <Index Subkey="for class representatives">straight line program</Index>
##    <Index>class representatives</Index>
##    <Index Subkey="for representatives of cyclic subgroups">
##    straight line program</Index>
##    <Index>cyclic subgroups</Index>
##    <Index>maximally cyclic subgroups</Index>
##    <P/>
##    See&nbsp;<Cite Key="BSW01"/> and&nbsp;<Cite Key="SWW00"/>
##    for the background concerning these straight line programs.
##    In these cases, the result record of <Ref Func="AtlasProgram"/>
##    also contains a component <C>outputs</C>,
##    whose value is a list of class names of the outputs,
##    as described in
##    Section&nbsp;<Ref Sect="sect:Class Names Used in the AtlasRep Package"/>.
##  </Item>
##  <Mark>the strings <C>"automorphism"</C> and <A>autname</A></Mark>
##  <Item>
##    the required program computes images of standard generators under
##    the outer automorphism of <M>G</M> that is given by this string.
##    <Index Subkey="for outer automorphisms">straight line program</Index>
##    <Index>automorphisms</Index>
##  </Item>
##  <Mark>the string <C>"check"</C></Mark>
##  <Item>
##    the required result is a straight line decision that
##    takes a list of generators for <M>G</M>
##    and returns <K>true</K> if these generators are standard generators
##    w.r.t.&nbsp;the standardization <A>std</A>, and <K>false</K> otherwise.
##    <Index Subkey="for checking standard generators">straight line decision
##    </Index>
##  </Item>
##  <Mark>the string <C>"presentation"</C></Mark>
##  <Item>
##    the required result is a straight line decision that
##    takes a list of group elements
##    and returns <K>true</K> if these elements are standard generators of
##    <M>G</M> w.r.t.&nbsp;the standardization <A>std</A>,
##    and <K>false</K> otherwise.
##    <Index Subkey="encoding a presentation">straight line decision
##    </Index>
##  </Item>
##  <Mark>the string <C>"find"</C></Mark>
##  <Item>
##    the required result is a black box program that takes <M>G</M>
##    and returns a list of standard generators of <M>G</M>,
##    w.r.t.&nbsp;the standardization <A>std</A>.
##    <Index Subkey="for finding standard generators">black box program
##    </Index>
##  </Item>
##  <Mark>the string <C>"restandardize"</C> and an integer <A>std2</A></Mark>
##  <Item>
##    the required result is a straight line program that computes
##    standard generators of <M>G</M> w.r.t. the <A>std2</A>-th set
##    of standard generators of <M>G</M>;
##    in this case, the argument <A>std</A> must be given.
##    <Index Subkey="for restandardizing">straight line program</Index>
##  </Item>
##  <Mark>the strings <C>"other"</C> and <A>descr</A></Mark>
##  <Item>
##    the required program is described by <A>descr</A>.
##    <Index Subkey="free format">straight line program</Index>
##  </Item>
##  </List>
##  <P/>
##  The second form of <Ref Func="AtlasProgram"/>,
##  with only argument the list <A>identifier</A>,
##  can be used to fetch the result record with <C>identifier</C> value equal
##  to <A>identifier</A>.
##  <Example><![CDATA[
##  gap> prog:= AtlasProgram( "A5", 2 );
##  rec( program := <straight line program>, standardization := 1, 
##    identifier := [ "A5", "A5G1-max2W1", 1 ], size := 10, groupname := "A5" )
##  gap> StringOfResultOfStraightLineProgram( prog.program, [ "a", "b" ] );
##  "[ a, bbab ]"
##  gap> gens1:= AtlasGenerators( "A5", 1 );
##  rec( generators := [ (1,2)(3,4), (1,3,5) ], groupname := "A5",
##    standardization := 1, repnr := 1, 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], p := 5, 
##    id := "", stabilizer := "A4", size := 60 )
##  gap> maxgens:= ResultOfStraightLineProgram( prog.program, gens1.generators );
##  [ (1,2)(3,4), (2,3)(4,5) ]
##  gap> maxgens = gens1max2.generators;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasProgram" );


#############################################################################
##
#F  AtlasStraightLineProgram( ... )
##
##  This was the documented name before version 1.3 of the package,
##  when no straight line decisions and black box programs were available.
##  We keep it for backwards compatibility reasons,
##  but leave it undocumented.
##
DeclareSynonym( "AtlasStraightLineProgram", AtlasProgram );


#############################################################################
##
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, "one" )
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, "all" )
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, "disp" )
##
##  This function does the work for `OneAtlasGeneratingSetInfo',
##  `AllAtlasGeneratingSetInfos', and `AtlasOfGroupRepresentationsInfoGroup'.
##  The first entry in <conditions> can be a group name
##  or a list of group names.
##
DeclareGlobalFunction( "AtlasGeneratingSetInfo" );


#############################################################################
##
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>], IsPermGroup[, true] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>], NrMovedPoints, <n> )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>], IsMatrixGroup[, true] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>][, Characteristic, <p>]
#F                                                 [, Dimension, <m>] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>][, Ring, <R>]
#F                                                 [, Dimension, <m>] )
#F  OneAtlasGeneratingSetInfo( [<gapname>,][ <std>,] Position, <n> )
##
##  <#GAPDoc Label="OneAtlasGeneratingSetInfo">
##  <ManSection>
##  <Func Name="OneAtlasGeneratingSetInfo" Arg='[gapname][, std][, ...]'/>
##
##  <Returns>
##  a record describing a representation that satisfies the conditions,
##  or <K>fail</K>.
##  </Returns>
##  <Description>
##  Let <A>gapname</A> be a string denoting a &GAP; name (see Section
##  &nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>)
##  of a group <M>G</M>, say.
##  If the &ATLAS; of Group Representations contains at least one
##  representation for <M>G</M> with the required properties
##  then <Ref Func="OneAtlasGeneratingSetInfo"/> returns a record <A>r</A>
##  whose components are the same as those of the records returned by
##  <Ref Func="AtlasGenerators"/>,
##  except that the component <C>generators</C> is not contained;
##  the component <C>identifier</C> of <A>r</A> can be used as input for
##  <Ref Func="AtlasGenerators"/> in order to fetch the generators.
##  If no representation satisfying the given conditions ia available
##  then <K>fail</K> is returned.
##  <P/>
##  If the argument <A>std</A> is given then it must be a positive integer
##  or a list of positive integers, denoting the sets of standard generators
##  w.r.t.&nbsp;which the representation shall be given (see
##  Section&nbsp;<Ref Sect="sect:Standard Generators Used in AtlasRep"/>).
##  <P/>
##  The argument <A>gapname</A> can be missing (then all available groups are
##  considered), or a list of group names can be given instead.
##  <P/>
##  Further restrictions can be entered as arguments, with the same meaning
##  as described for <Ref Func="DisplayAtlasInfo"/>.
##  The result of <Ref Func="OneAtlasGeneratingSetInfo"/> describes the first
##  generating set for <M>G</M> that matches the restrictions,
##  in the ordering shown by <Ref Func="DisplayAtlasInfo"/>.
##  <P/>
##  Note that even in the case that the user parameter <Q>remote</Q>
##  has the value <K>true</K>
##  (see Section&nbsp;<Ref Subsect="subsect:Local or remote access"/>),
##  <Ref Func="OneAtlasGeneratingSetInfo"/> does <E>not</E> attempt
##  to <E>transfer</E> remote data files,
##  just the table of contents is evaluated.
##  So this function (as well as <Ref Func="AllAtlasGeneratingSetInfos"/>)
##  can be used to check for the availability of certain representations,
##  and afterwards one can call <Ref Func="AtlasGenerators"/> for those
##  representations one wants to work with.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OneAtlasGeneratingSetInfo" );


#############################################################################
##
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>], IsPermGroup[, true] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>], NrMovedPoints, <n> )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>], IsMatrixGroup[, true] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>][, Characteristic, <p>]
#F                                                  [, Dimension, <m>] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>][, Ring, <R>]
#F                                                  [, Dimension, <m>] )
##
##  <#GAPDoc Label="AllAtlasGeneratingSetInfos">
##  <ManSection>
##  <Func Name="AllAtlasGeneratingSetInfos" Arg='[gapname][, std][, ...]'/>
##
##  <Returns>
##  the list of all records describing representations that satisfy
##  the conditions.
##  </Returns>
##  <Description>
##  <Ref Func="AllAtlasGeneratingSetInfos"/> is similar to
##  <Ref Func="OneAtlasGeneratingSetInfo"/>.
##  The difference is that the list of <E>all</E> records describing
##  the available representations with the given properties is returned
##  instead of just one such component.
##  In particular an empty list is returned if no such representation is
##  available.
##  <P/>
##  <Example><![CDATA[
##  gap> AllAtlasGeneratingSetInfos( "A5", IsPermGroup, true );
##  [ rec( groupname := "A5", standardization := 1, 
##        identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##        p := 5, id := "", stabilizer := "A4", size := 60, repnr := 1 ),
##    rec( groupname := "A5", standardization := 1, 
##        identifier := [ "A5", [ "A5G1-p6B0.m1", "A5G1-p6B0.m2" ], 1, 6 ], 
##        p := 6, id := "", stabilizer := "D10", size := 60, repnr := 2 ),
##    rec( groupname := "A5", standardization := 1, 
##        identifier := [ "A5", [ "A5G1-p10B0.m1", "A5G1-p10B0.m2" ], 1, 10 ], 
##        p := 10, id := "", stabilizer := "S3", size := 60, repnr := 3 ) ]
##  ]]></Example>
##  <P/>
##  Note that a matrix representation in any characteristic can be obtained by
##  reducing a permutation representation or an integral matrix representation;
##  however, the &ATLAS; of Group Representations does not <E>store</E> such a
##  representation
##  (cf. Section&nbsp;<Ref Sect="sect:Accessing vs. Constructing Representations"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AllAtlasGeneratingSetInfos" );


#############################################################################
##
#F  OneAtlasGeneratingSet( ... )
##
##  <ManSection>
##  <Func Name="OneAtlasGeneratingSet" Arg='...'/>
##
##  <Description>
##  This function is now deprecated.
##  It was used in earlier versions of the package,
##  when <Ref func="OneAtlasGeneratingSetInfo"/> was not yet available.
##  </Description>
##  </ManSection>
##
BindGlobal( "OneAtlasGeneratingSet", function( arg )
    local res;

    res:= CallFuncList( OneAtlasGeneratingSetInfo, arg );
    if res <> fail then
      res:= AtlasGenerators( res.identifier );
    fi;
    return res;
    end );


#############################################################################
##
#F  AtlasGroup( [<gapname>[, <std>]] )
#F  AtlasGroup( [<gapname>[, <std>]], IsPermGroup[, true] )
#F  AtlasGroup( [<gapname>[, <std>]], NrMovedPoints, <n> )
#F  AtlasGroup( [<gapname>[, <std>]], IsMatrixGroup[, true] )
#F  AtlasGroup( [<gapname>[, <std>]][, Characteristic, <p>]
#F                                  [, Dimension, <m>] )
#F  AtlasGroup( [<gapname>[, <std>]][, Ring, <R>][, Dimension, <m>] )
#F  AtlasGroup( <identifier> )
##
##  <#GAPDoc Label="AtlasGroup">
##  <ManSection>
##  <Heading>AtlasGroup</Heading>
##  <Func Name="AtlasGroup" Arg='[gapname[, std]][, ...]'
##   Label="for various arguments"/>
##  <Func Name="AtlasGroup" Arg='identifier'
##   Label="for an identifier record"/>
##
##  <Returns>
##  a group that satisfies the conditions, or <K>fail</K>.
##  </Returns>
##  <Description>
##  <Ref Func="AtlasGroup" Label="for various arguments"/> takes the same
##  arguments as <Ref Func="OneAtlasGeneratingSetInfo"/>,
##  and returns the group generated by the <C>generators</C> component
##  of the record that is returned by <Ref Func="OneAtlasGeneratingSetInfo"/>
##  with these arguments;
##  if <Ref Func="OneAtlasGeneratingSetInfo"/> returns <K>fail</K> then also
##  <Ref Func="AtlasGroup" Label="for various arguments"/> returns
##  <K>fail</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= AtlasGroup( "A5" );
##  Group([ (1,2)(3,4), (1,3,5) ])
##  ]]></Example>
##  <P/>
##  Alternatively, it is possible to enter exactly one argument,
##  a record <A>identifier</A> as returned by 
##  <Ref Func="OneAtlasGeneratingSetInfo"/> or
##  <Ref Func="AllAtlasGeneratingSetInfos"/>,
##  or the <C>identifier</C> component of such a record.
##  <P/>
##  <Example><![CDATA[
##  gap> info:= OneAtlasGeneratingSetInfo( "A5" );
##  rec( groupname := "A5", standardization := 1, 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], p := 5, 
##    id := "", stabilizer := "A4", size := 60, repnr := 1 )
##  gap> AtlasGroup( info );
##  Group([ (1,2)(3,4), (1,3,5) ])
##  gap> AtlasGroup( info.identifier );
##  Group([ (1,2)(3,4), (1,3,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasGroup" );


#############################################################################
##
#F  AtlasSubgroup( <gapname>[, <std>], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], IsPermGroup[, true], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], NrMovedPoints, <n>, <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], IsMatrixGroup[, true], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>][, Characteristic, <p>]
#F                                  [, Dimension, <m>], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>][, Ring, <R>]
#F                                  [, Dimension, <m>], <maxnr> )
#F  AtlasSubgroup( <identifier>, <maxnr> )
##
##  <#GAPDoc Label="AtlasSubgroup">
##  <ManSection>
##  <Heading>AtlasSubgroup</Heading>
##  <Func Name="AtlasSubgroup" Arg='gapname[, std][, ...], maxnr'
##   Label="for a group name (and various arguments) and a number"/>
##  <Func Name="AtlasSubgroup" Arg='identifier, maxnr'
##   Label="for an identifier record and a number"/>
##
##  <Returns>
##  a group that satisfies the conditions, or <K>fail</K>.
##  </Returns>
##  <Description>
##  The arguments of
##  <Ref Func="AtlasSubgroup" Label="for a group name (and various arguments) and a number"/>,
##  except the last argument <A>maxn</A>, are the same as for
##  <Ref Func="AtlasGroup" Label="for various arguments"/>.
##  If the &ATLAS; of Group Representations provides a straight line program
##  for restricting representations of the group with name <A>gapname</A>
##  (given w.r.t. the <A>std</A>-th standard generators)
##  to the <A>maxnr</A>-th maximal subgroup
##  and if a representation with the required properties is available,
##  in the sense that calling
##  <Ref Func="AtlasGroup" Label="for various arguments"/> with the same
##  arguments except <A>maxnr</A> yields a group, then
##  <Ref Func="AtlasSubgroup" Label="for a group name (and various arguments) and a number"/>
##  returns the restriction of this representation to the <A>maxnr</A>-th
##  maximal subgroup.
##  In all other cases, <K>fail</K> is returned.
##  <P/>
##  Note that the conditions refer to the group and not to the subgroup.
##  It may happen that in the restriction of a permutation representation
##  to a subgroup, fewer points are moved,
##  or that the restriction of a matrix representation turns out to be
##  defined over a smaller ring.
##  Here is an example.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= AtlasSubgroup( "A5", NrMovedPoints, 5, 1 );
##  Group([ (1,5)(2,3), (1,3,5) ])
##  gap> NrMovedPoints( g );
##  4
##  ]]></Example>
##  <P/>
##  Alternatively, it is possible to enter exactly two arguments,
##  the first being a record <A>identifier</A> as returned by 
##  <Ref Func="OneAtlasGeneratingSetInfo"/> or
##  <Ref Func="AllAtlasGeneratingSetInfos"/>,
##  or the <C>identifier</C> component of such a record.
##  <P/>
##  <Example><![CDATA[
##  gap> info:= OneAtlasGeneratingSetInfo( "A5" );
##  rec( groupname := "A5", standardization := 1, 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], p := 5, 
##    id := "", stabilizer := "A4", size := 60, repnr := 1 )
##  gap> AtlasSubgroup( info, 1 );
##  Group([ (1,5)(2,3), (1,3,5) ])
##  gap> AtlasSubgroup( info.identifier, 1 );
##  Group([ (1,5)(2,3), (1,3,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasSubgroup" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsShowUserParameters()
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsShowUserParameters">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsShowUserParameters" Arg=''/>
##
##  <Description>
##  This function prints an overview of the current values of the user
##  parameters introduced in this section.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsShowUserParameters" );


#############################################################################
##
#E

