#############################################################################
##
#W  interfac.gd          GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration part of the ``high level'' GAP
##  interface to the ATLAS of Group Representations.
##


#############################################################################
##
#F  DisplayAtlasInfo( [<listofnames>][,][<std>][,]["contents", <sources>]
#F                    [, IsPermGroup[, true]]
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>]
#F                    [, Position, <n>]
#F                    [, Character, <chi>]
#F                    [, Identifier, <id>] )
#F  DisplayAtlasInfo( <gapname>[, <std>][, "contents", <sources>]
#F                    [, IsPermGroup[, true]]
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>]
#F                    [, Position, <n>]
#F                    [, Character, <chi>]
#F                    [, Identifier, <id>]
#F                    [, IsStraightLineProgram[, true]] )
##
##  <#GAPDoc Label="DisplayAtlasInfo">
##  <ManSection>
##  <Func Name="DisplayAtlasInfo"
##  Arg='[listofnames][,][std][,]["contents", sources][, ...]'/>
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
##  An interactive alternative to <Ref Func="DisplayAtlasInfo"/> is the
##  function <Ref Func="BrowseAtlasInfo" BookName="Browse"/>,
##  see <Cite Key="Browse"/>.
##  <P/>
##  Called without arguments, <Ref Func="DisplayAtlasInfo"/> prints an
##  overview what information the &ATLAS; of Group Representations provides.
##  One line is printed for each group <M>G</M>, with the following columns.
##  <P/>
##  <List>
##  <Mark><C>group</C></Mark>
##  <Item>
##    the &GAP; name of <M>G</M> (see
##    Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>),
##  </Item>
##  <Mark><C>#</C></Mark>
##  <Item>
##    the number of faithful representations stored for <M>G</M>
##    that satisfy the additional conditions given (see below),
##  </Item>
##  <Mark><C>maxes</C></Mark>
##  <Item>
##    the number of available straight line programs
##    <Index>straight line program</Index>
##    for computing generators of maximal subgroups of <M>G</M>,
##  </Item>
##  <Mark><C>cl</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program for computing representatives
##    of conjugacy classes of elements of <M>G</M> is stored,
##  </Item>
##  <Mark><C>cyc</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program for computing representatives
##    of classes of maximally cyclic subgroups of <M>G</M> is stored,
##  </Item>
##  <Mark><C>out</C></Mark>
##  <Item>
##    descriptions of outer automorphisms of <M>G</M> for which at least
##    one program is stored,
##  </Item>
##  <Mark><C>fnd</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program is available for finding
##    standard generators,
##  </Item>
##  <Mark><C>chk</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program is available for checking
##    whether a set of generators is a set of standard generators,
##    and
##  </Item>
##  <Mark><C>prs</C></Mark>
##  <Item>
##    a <C>+</C> sign if at least one program is available that encodes a
##    presentation.
##  </Item>
##  </List>
##  <P/>
##  (The list can be printed to the screen or can be fed into a pager,
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
##  One line is printed for each faithful representation,
##  showing the number of this representation
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
##      <C>ℤ</C> (denoting the ring of integers),
##      a description of an algebraic extension field,
##      <C>ℂ</C> (denoting an unspecified algebraic extension field), or
##      <C>ℤ/<A>m</A>ℤ</C> for an integer <A>m</A>
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
##    restrict to representations with <C>identifier</C> component in the
##    list <A>id</A> (note that this component is itself a list, entering
##    this list is not admissible),
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
##  </Item>
##  <Mark><C>Ring</C>, <A>R</A>, <C>Dimension</C>,
##        and the string <C>"minimal"</C></Mark>
##  <Item>
##    for a ring <A>R</A>, restrict to faithful matrix representations
##    over this ring that have minimal dimension
##    (if this information is available),
##  </Item>
##  <Mark><C>Character</C> and <A>chi</A></Mark>
##  <Item>
##    for a class function or a list of class functions <A>chi</A>,
##    restrict to matrix representations with these characters
##    (note that the underlying characteristic of the class function,
##    see Section&nbsp;<Ref Sect="UnderlyingCharacteristic" BookName="ref"/>,
##    determines the characteristic of the matrices),
##    and
##  </Item>
##  <Mark><C>IsStraightLineProgram</C> and <K>true</K></Mark>
##  <Item>
##    restrict to straight line programs,
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
##  this is because the stored information was precomputed just for
##  the groups in the &ATLAS; of Group Representations,
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
##  group |  # | maxes | cl | cyc | out | fnd | chk | prs
##  ------+----+-------+----+-----+-----+-----+-----+----
##  M11   | 42 |     5 |  + |  +  |     |  +  |  +  |  +
##  A5    | 18 |     3 |    |     |     |     |  +  |  +
##  ]]></Example>
##  <P/>
##  The above output means that the &ATLAS; of Group Representations contains
##  <M>42</M> representations of the Mathieu group <M>M_{11}</M>,
##  straight line programs for computing generators of representatives
##  of all five classes of maximal subgroups,
##  for computing representatives of the conjugacy classes of elements
##  and of generators of maximally cyclic subgroups,
##  contains no straight line program for applying outer automorphisms
##  (well, in fact <M>M_{11}</M> admits no nontrivial outer automorphism),
##  and contains straight line decisions that check a set of generators
##  or a set of group elements for being a set of standard generators.
##  Analogously,
##  <M>18</M> representations of the alternating group <M>A_5</M> are
##  available, straight line programs for computing generators of
##  representatives of all three classes of maximal subgroups,
##  and no straight line programs for computing representatives
##  of the conjugacy classes of elements,
##  of generators of maximally cyclic subgroups,
##  and no for computing images under outer automorphisms;
##  straight line decisions for checking the standardization of generators
##  or group elements are available.
##  <P/>
##  <Example><![CDATA[
##  gap> DisplayAtlasInfo( "A5", IsPermGroup, true );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##  1: G <= Sym(5)  3-trans., on cosets of A4 (1st max.)
##  2: G <= Sym(6)  2-trans., on cosets of D10 (2nd max.)
##  3: G <= Sym(10) rank 3, on cosets of S3 (3rd max.)
##  gap> DisplayAtlasInfo( "A5", NrMovedPoints, [ 4 .. 9 ] );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##  1: G <= Sym(5) 3-trans., on cosets of A4 (1st max.)
##  2: G <= Sym(6) 2-trans., on cosets of D10 (2nd max.)
##  ]]></Example>
##  <P/>
##  The first three representations stored for <M>A_5</M> are
##  (in fact primitive) permutation representations.
##  <P/>
##  <Example><![CDATA[
##  gap> DisplayAtlasInfo( "A5", Dimension, [ 1 .. 3 ] );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##   8: G <= GL(2a,4)
##   9: G <= GL(2b,4)
##  10: G <= GL(3,5)
##  12: G <= GL(3a,9)
##  13: G <= GL(3b,9)
##  17: G <= GL(3a,Field([Sqrt(5)]))
##  18: G <= GL(3b,Field([Sqrt(5)]))
##  gap> DisplayAtlasInfo( "A5", Characteristic, 0 );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##  14: G <= GL(4,Z)
##  15: G <= GL(5,Z)
##  16: G <= GL(6,Z)
##  17: G <= GL(3a,Field([Sqrt(5)]))
##  18: G <= GL(3b,Field([Sqrt(5)]))
##  ]]></Example>
##  <P/>
##  The representations with number between <M>4</M> and <M>13</M> are
##  (in fact irreducible) matrix representations over various finite fields,
##  those with numbers <M>14</M> to <M>16</M> are integral matrix
##  representations,
##  and the last two are matrix representations over the field generated by
##  <M>\sqrt{{5}}</M> over the rational number field.
##  <P/>
##  <Example><![CDATA[
##  gap> DisplayAtlasInfo( "A5", Identifier, "a" );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##   4: G <= GL(4a,2)
##   8: G <= GL(2a,4)
##  12: G <= GL(3a,9)
##  17: G <= GL(3a,Field([Sqrt(5)]))
##  ]]></Example>
##  <P/>
##  Each of the representations with the numbers <M>4, 8, 12</M>,
##  and <M>17</M> is labeled with the distinguishing letter <C>a</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> DisplayAtlasInfo( "A5", NrMovedPoints, IsPrimeInt );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##  1: G <= Sym(5) 3-trans., on cosets of A4 (1st max.)
##  gap> DisplayAtlasInfo( "A5", Characteristic, IsOddInt );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##   6: G <= GL(4,3)
##   7: G <= GL(6,3)
##  10: G <= GL(3,5)
##  11: G <= GL(5,5)
##  12: G <= GL(3a,9)
##  13: G <= GL(3b,9)
##  gap> DisplayAtlasInfo( "A5", Dimension, IsPrimeInt );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##   8: G <= GL(2a,4)
##   9: G <= GL(2b,4)
##  10: G <= GL(3,5)
##  11: G <= GL(5,5)
##  12: G <= GL(3a,9)
##  13: G <= GL(3b,9)
##  15: G <= GL(5,Z)
##  17: G <= GL(3a,Field([Sqrt(5)]))
##  18: G <= GL(3b,Field([Sqrt(5)]))
##  gap> DisplayAtlasInfo( "A5", Ring, IsFinite and IsPrimeField );
##  Representations for G = A5:    (all refer to std. generators 1)
##  ---------------------------
##   4: G <= GL(4a,2)
##   5: G <= GL(4b,2)
##   6: G <= GL(4,3)
##   7: G <= GL(6,3)
##  10: G <= GL(3,5)
##  11: G <= GL(5,5)
##  ]]></Example>
##  <P/>
##  The above examples show how the output can be restricted using a property
##  (a unary function that returns either <K>true</K> or <K>false</K>)
##  that follows <Ref Func="NrMovedPoints" BookName="ref"/>,
##  <Ref Func="Characteristic" BookName="ref"/>,
##  <Ref Func="Dimension" BookName="ref"/>,
##  or <Ref Func="Ring" BookName="ref"/>
##  in the argument list of <Ref Func="DisplayAtlasInfo"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> DisplayAtlasInfo( "A5", IsStraightLineProgram, true );
##  Programs for G = A5:    (all refer to std. generators 1)
##  --------------------
##  presentation
##  std. gen. checker
##  maxes (all 3):
##    1:  A4
##    2:  D10
##    3:  S3
##  ]]></Example>
##  <P/>
##  Straight line programs are available for computing generators of
##  representatives of the three classes of maximal subgroups of <M>A_5</M>,
##  and a straight line decision for checking whether given generators are
##  in fact standard generators is available as well as a presentation
##  in terms of standard generators,
##  see&nbsp;<Ref Func="AtlasProgram"/>.
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
##  The result record has at least the following components.
##  <P/>
##  <List>
##  <Mark><C>generators</C></Mark>
##  <Item>
##    a list of generators for the group,
##  </Item>
##  <Mark><C>groupname</C></Mark>
##  <Item>
##    the &GAP; name of the group (see
##    Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>),
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
##  <Mark><C>standardization</C></Mark>
##  <Item>
##    the positive integer denoting the underlying standard generators,
##  </Item>
##  </List>
##  <P/>
##  Additionally, the group order may be stored in the component <C>size</C>,
##  and describing components may be available that depend on the data type
##  of the representation:
##  For permutation representations, these are <C>p</C> for the number of
##  moved points, <C>id</C> for the distinguishing string as described for
##  <Ref Func="DisplayAtlasInfo"/>, and information about primitivity,
##  point stabilizers etc. if available;
##  for matrix representations, these are <C>dim</C> for the dimension of the
##  matrices, <C>ring</C> (if known) for the ring generated by the matrix
##  entries, <C>id</C> for the distinguishing string, and information about
##  the character if available.
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
##  <P/>
##  <Example><![CDATA[
##  gap> gens1:= AtlasGenerators( "A5", 1 );
##  rec( generators := [ (1,2)(3,4), (1,3,5) ], groupname := "A5", id := "", 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2, 
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> gens8:= AtlasGenerators( "A5", 8 );
##  rec( dim := 2, 
##    generators := [ [ [ Z(2)^0, 0*Z(2) ], [ Z(2^2), Z(2)^0 ] ], 
##        [ [ 0*Z(2), Z(2)^0 ], [ Z(2)^0, Z(2)^0 ] ] ], groupname := "A5", 
##    id := "a", identifier := [ "A5", [ "A5G1-f4r2aB0.m1", "A5G1-f4r2aB0.m2" ], 
##        1, 4 ], repname := "A5G1-f4r2aB0", repnr := 8, ring := GF(2^2), 
##    size := 60, standardization := 1, type := "matff" )
##  gap> gens17:= AtlasGenerators( "A5", 17 );
##  rec( dim := 3, 
##    generators := 
##      [ [ [ -1, 0, 0 ], [ 0, -1, 0 ], [ -E(5)-E(5)^4, -E(5)-E(5)^4, 1 ] ], 
##        [ [ 0, 1, 0 ], [ 0, 0, 1 ], [ 1, 0, 0 ] ] ], groupname := "A5", 
##    id := "a", identifier := [ "A5", "A5G1-Ar3aB0.g", 1, 3 ], 
##    repname := "A5G1-Ar3aB0", repnr := 17, ring := NF(5,[ 1, 4 ]), size := 60, 
##    standardization := 1, type := "matalg" )
##  ]]></Example>
##  <P/>
##  Each of the above pairs of elements generates a group isomorphic to
##  <M>A_5</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> gens1max2:= AtlasGenerators( "A5", 1, 2 );
##  rec( generators := [ (1,2)(3,4), (2,3)(4,5) ], groupname := "D10",
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5, 2 ],
##    repnr := 1, size := 10, standardization := 1 )
##  gap> id:= gens1max2.identifier;;
##  gap> gens1max2 = AtlasGenerators( id );
##  true
##  gap> max2:= Group( gens1max2.generators );;
##  gap> Size( max2 );
##  10
##  gap> IdGroup( max2 ) = IdGroup( DihedralGroup( 10 ) );
##  true
##  ]]></Example>
##  <P/>
##  The elements stored in <C>gens1max2.generators</C> describe the
##  restriction of the first representation of <M>A_5</M> to a group in the
##  second class of maximal subgroups of <M>A_5</M> according to the list in
##  the &ATLAS; of Finite Groups&nbsp;<Cite Key="CCN85"/>;
##  this subgroup is isomorphic to the dihedral group <M>D_{10}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasGenerators" );


#############################################################################
##
#F  AtlasProgramInfo( <gapname>[, <std>][, "maxes"], <maxnr> )
#F  AtlasProgramInfo( <gapname>[, <std>], "classes" )
#F  AtlasProgramInfo( <gapname>[, <std>], "cyclic" )
#F  AtlasProgramInfo( <gapname>[, <std>], "automorphism", <autname> )
#F  AtlasProgramInfo( <gapname>[, <std>], "check" )
#F  AtlasProgramInfo( <gapname>[, <std>], "pres" )
#F  AtlasProgramInfo( <gapname>[, <std>], "find" )
#F  AtlasProgramInfo( <gapname>, <std>, "restandardize", <std2> )
#F  AtlasProgramInfo( <gapname>[, <std>], "other", <descr> )
##
##  <#GAPDoc Label="AtlasProgramInfo">
##  <ManSection>
##  <Func Name="AtlasProgramInfo"
##  Arg='gapname[, std][, "contents", sources][, ...]'/>
##
##  <Returns>
##  a record describing a program, or <K>fail</K>.
##  </Returns>
##  <Description>
##  <Ref Func="AtlasProgramInfo"/> takes the same arguments as
##  <Ref Func="AtlasProgram"/>, and returns a similar result.
##  The only difference is that the records returned by
##  <Ref Func="AtlasProgramInfo"/> have no components <C>program</C> and
##  <C>outputs</C>.
##  The idea is that one can use <Ref Func="AtlasProgramInfo"/> for
##  testing whether the program in question is available at all,
##  but without transferring it from a remote server.
##  The <C>identifier</C> component of the result of
##  <Ref Func="AtlasProgramInfo"/> can then be used to fetch the program
##  with <Ref Func="AtlasProgram"/>.
##
##  <Example><![CDATA[
##  gap> AtlasProgramInfo( "J1", "cyclic" );
##  rec( groupname := "J1", identifier := [ "J1", "J1G1-cycW1", 1 ], 
##    standardization := 1 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasProgramInfo" );


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
##    <Index Subkey="for outer automorphisms">straight line program</Index>
##    <Index>automorphisms</Index>
##    the required program computes images of standard generators under
##    the outer automorphism of <M>G</M> that is given by this string.
##    <P/>
##    Note that a value <C>"2"</C> of <A>autname</A> means that the square of
##    the automorphism is an inner automorphism of <M>G</M> (not necessarily
##    the identity mapping) but the automorphism itself is not.
##  </Item>
##  <Mark>the string <C>"check"</C></Mark>
##  <Item>
##    <Index Subkey="for checking standard generators">straight line decision
##    </Index>
##    the required result is a straight line decision that
##    takes a list of generators for <M>G</M>
##    and returns <K>true</K> if these generators are standard generators of
##    <M>G</M> w.r.t.&nbsp;the standardization <A>std</A>,
##    and <K>false</K> otherwise.
##  </Item>
##  <Mark>the string <C>"presentation"</C></Mark>
##  <Item>
##    <Index Subkey="encoding a presentation">straight line decision
##    </Index>
##    the required result is a straight line decision that
##    takes a list of group elements
##    and returns <K>true</K> if these elements are standard generators of
##    <M>G</M> w.r.t.&nbsp;the standardization <A>std</A>,
##    and <K>false</K> otherwise.
##    <P/>
##    See <Ref Func="StraightLineProgramFromStraightLineDecision"/> for an
##    example how to derive defining relators for <M>G</M> in terms of the
##    standard generators from such a straight line decision.
##  </Item>
##  <Mark>the string <C>"find"</C></Mark>
##  <Item>
##    <Index Subkey="for finding standard generators">black box program
##    </Index>
##    the required result is a black box program that takes <M>G</M>
##    and returns a list of standard generators of <M>G</M>,
##    w.r.t.&nbsp;the standardization <A>std</A>.
##  </Item>
##  <Mark>the string <C>"restandardize"</C> and an integer <A>std2</A></Mark>
##  <Item>
##    <Index Subkey="for restandardizing">straight line program</Index>
##    the required result is a straight line program that computes
##    standard generators of <M>G</M> w.r.t. the <A>std2</A>-th set
##    of standard generators of <M>G</M>;
##    in this case, the argument <A>std</A> must be given.
##  </Item>
##  <Mark>the strings <C>"other"</C> and <A>descr</A></Mark>
##  <Item>
##    <Index Subkey="free format">straight line program</Index>
##    the required program is described by <A>descr</A>.
##  </Item>
##  </List>
##  <P/>
##  The second form of <Ref Func="AtlasProgram"/>,
##  with only argument the list <A>identifier</A>,
##  can be used to fetch the result record with <C>identifier</C> value equal
##  to <A>identifier</A>.
##  <Example><![CDATA[
##  gap> prog:= AtlasProgram( "A5", 2 );
##  rec( groupname := "A5", identifier := [ "A5", "A5G1-max2W1", 1 ],
##    program := <straight line program>, size := 10, standardization := 1,
##    subgroupname := "D10" )
##  gap> StringOfResultOfStraightLineProgram( prog.program, [ "a", "b" ] );
##  "[ a, bbab ]"
##  gap> gens1:= AtlasGenerators( "A5", 1 );
##  rec( generators := [ (1,2)(3,4), (1,3,5) ], groupname := "A5", id := "", 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2, 
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> maxgens:= ResultOfStraightLineProgram( prog.program, gens1.generators );
##  [ (1,2)(3,4), (2,3)(4,5) ]
##  gap> maxgens = gens1max2.generators;
##  true
##  ]]></Example>
##  <P/>
##  The above example shows that for restricting representations given by
##  standard generators to a maximal subgroup of <M>A_5</M>,
##  we can also fetch and apply the appropriate straight line program.
##  Such a program
##  (see&nbsp;<Ref Sect="Straight Line Programs" BookName="ref"/>)
##  takes standard generators of a group --in this example <M>A_5</M>--
##  as its input, and returns a list of elements in this group
##  --in this example generators of the <M>D_{10}</M> subgroup we had met
##  above--
##  which are computed essentially by evaluating structured words in terms of
##  the standard generators.
##  <P/>
##  <Example><![CDATA[
##  gap> prog:= AtlasProgram( "J1", "cyclic" );
##  rec( groupname := "J1", identifier := [ "J1", "J1G1-cycW1", 1 ],
##    outputs := [ "6A", "7A", "10B", "11A", "15B", "19A" ],
##    program := <straight line program>, standardization := 1 )
##  gap> gens:= GeneratorsOfGroup( FreeGroup( "x", "y" ) );;
##  gap> ResultOfStraightLineProgram( prog.program, gens );
##  [ x*y*x*y^2*x*y*x*y^2*x*y*x*y*x*y^2*x*y^2, x*y, x*y*x*y^2*x*y*x*y*x*y^2*x*y^2,
##    x*y*x*y*x*y^2*x*y^2*x*y*x*y^2*x*y*x*y*x*y^2*x*y^2*x*y*x*y^2*x*y*x*y*x*y^
##      2*x*y^2, x*y*x*y*x*y^2*x*y^2, x*y*x*y^2 ]
##  ]]></Example>
##  <P/>
##  The above example shows how to fetch and use straight line programs for
##  computing generators of representatives of maximally cyclic subgroups
##  of a given group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasProgram" );


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
##  If no representation satisfying the given conditions is available
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
##  <P/>
##  In the following example, we try to access information about
##  permutation representations for the alternating group <M>A_5</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> info:= OneAtlasGeneratingSetInfo( "A5" );
##  rec( groupname := "A5", id := "",
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ],
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2,
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4",
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> gens:= AtlasGenerators( info.identifier );
##  rec( generators := [ (1,2)(3,4), (1,3,5) ], groupname := "A5", id := "", 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2, 
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> info = OneAtlasGeneratingSetInfo( "A5", IsPermGroup, true );
##  true
##  gap> info = OneAtlasGeneratingSetInfo( "A5", NrMovedPoints, "minimal" );
##  true
##  gap> info = OneAtlasGeneratingSetInfo( "A5", NrMovedPoints, [ 1 .. 10 ] );
##  true
##  gap> OneAtlasGeneratingSetInfo( "A5", NrMovedPoints, 20 );
##  fail
##  ]]></Example>
##  <P/>
##  Note that a permutation representation of degree <M>20</M> could be
##  obtained by taking twice the primitive representation on <M>10</M> points;
##  however, the &ATLAS; of Group Representations does not store this
##  imprimitive representation (cf.
##  Section&nbsp;<Ref Sect="sect:Accessing vs. Constructing Representations"/>).
##  <P/>
##  We continue this example a little.
##  Next we access matrix representations of <M>A_5</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> info:= OneAtlasGeneratingSetInfo( "A5", IsMatrixGroup, true );
##  rec( dim := 4, groupname := "A5", id := "a",
##    identifier := [ "A5", [ "A5G1-f2r4aB0.m1", "A5G1-f2r4aB0.m2" ], 1, 2 ],
##    repname := "A5G1-f2r4aB0", repnr := 4, ring := GF(2), size := 60,
##    standardization := 1, type := "matff" )
##  gap> gens:= AtlasGenerators( info.identifier );
##  rec( dim := 4, 
##    generators := [ <an immutable 4x4 matrix over GF2>, 
##        <an immutable 4x4 matrix over GF2> ], groupname := "A5", id := "a", 
##    identifier := [ "A5", [ "A5G1-f2r4aB0.m1", "A5G1-f2r4aB0.m2" ], 1, 2 ], 
##    repname := "A5G1-f2r4aB0", repnr := 4, ring := GF(2), size := 60, 
##    standardization := 1, type := "matff" )
##  gap> info = OneAtlasGeneratingSetInfo( "A5", Dimension, 4 );
##  true
##  gap> info = OneAtlasGeneratingSetInfo( "A5", Characteristic, 2 );
##  true
##  gap> info = OneAtlasGeneratingSetInfo( "A5", Ring, GF(2) );
##  true
##  gap> OneAtlasGeneratingSetInfo( "A5", Characteristic, [2,5], Dimension, 2 );
##  rec( dim := 2, groupname := "A5", id := "a",
##    identifier := [ "A5", [ "A5G1-f4r2aB0.m1", "A5G1-f4r2aB0.m2" ], 1, 4 ],
##    repname := "A5G1-f4r2aB0", repnr := 8, ring := GF(2^2), size := 60,
##    standardization := 1, type := "matff" )
##  gap> OneAtlasGeneratingSetInfo( "A5", Characteristic, [2,5], Dimension, 1 );
##  fail
##  gap> info:= OneAtlasGeneratingSetInfo( "A5", Characteristic, 0, Dimension, 4 );
##  rec( dim := 4, groupname := "A5", id := "",
##    identifier := [ "A5", "A5G1-Zr4B0.g", 1, 4 ], repname := "A5G1-Zr4B0",
##    repnr := 14, ring := Integers, size := 60, standardization := 1,
##    type := "matint" )
##  gap> gens:= AtlasGenerators( info.identifier );
##  rec( dim := 4, 
##    generators := 
##      [ [ [ 1, 0, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 1, 0, 0 ], [ -1, -1, -1, -1 ] ], 
##        [ [ 0, 1, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ], [ 1, 0, 0, 0 ] ] ], 
##    groupname := "A5", id := "", identifier := [ "A5", "A5G1-Zr4B0.g", 1, 4 ], 
##    repname := "A5G1-Zr4B0", repnr := 14, ring := Integers, size := 60, 
##    standardization := 1, type := "matint" )
##  gap> info = OneAtlasGeneratingSetInfo( "A5", Ring, Integers );
##  true
##  gap> info = OneAtlasGeneratingSetInfo( "A5", Ring, CF(37) );
##  true
##  gap> OneAtlasGeneratingSetInfo( "A5", Ring, Integers mod 77 );
##  fail
##  gap> info:= OneAtlasGeneratingSetInfo( "A5", Ring, CF(5), Dimension, 3 );
##  rec( dim := 3, groupname := "A5", id := "a",
##    identifier := [ "A5", "A5G1-Ar3aB0.g", 1, 3 ], repname := "A5G1-Ar3aB0",
##    repnr := 17, ring := NF(5,[ 1, 4 ]), size := 60, standardization := 1,
##    type := "matalg" )
##  gap> gens:= AtlasGenerators( info.identifier );
##  rec( dim := 3, 
##    generators := 
##      [ [ [ -1, 0, 0 ], [ 0, -1, 0 ], [ -E(5)-E(5)^4, -E(5)-E(5)^4, 1 ] ], 
##        [ [ 0, 1, 0 ], [ 0, 0, 1 ], [ 1, 0, 0 ] ] ], groupname := "A5", 
##    id := "a", identifier := [ "A5", "A5G1-Ar3aB0.g", 1, 3 ], 
##    repname := "A5G1-Ar3aB0", repnr := 17, ring := NF(5,[ 1, 4 ]), size := 60, 
##    standardization := 1, type := "matalg" )
##  gap> OneAtlasGeneratingSetInfo( "A5", Ring, GF(17) );
##  fail
##  ]]></Example>
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
##  [ rec( groupname := "A5", id := "",
##        identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ],
##        isPrimitive := true, maxnr := 1, p := 5, rankAction := 2,
##        repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4",
##        standardization := 1, transitivity := 3, type := "perm" ),
##    rec( groupname := "A5", id := "",
##        identifier := [ "A5", [ "A5G1-p6B0.m1", "A5G1-p6B0.m2" ], 1, 6 ],
##        isPrimitive := true, maxnr := 2, p := 6, rankAction := 2,
##        repname := "A5G1-p6B0", repnr := 2, size := 60, stabilizer := "D10",
##        standardization := 1, transitivity := 2, type := "perm" ),
##    rec( groupname := "A5", id := "",
##        identifier := [ "A5", [ "A5G1-p10B0.m1", "A5G1-p10B0.m2" ], 1, 10 ],
##        isPrimitive := true, maxnr := 3, p := 10, rankAction := 3,
##        repname := "A5G1-p10B0", repnr := 3, size := 60, stabilizer := "S3",
##        standardization := 1, transitivity := 1, type := "perm" ) ]
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
#A  AtlasRepInfoRecord( <G> )
##
##  <#GAPDoc Label="AtlasRepInfoRecord">
##  <ManSection>
##  <Attr Name="AtlasRepInfoRecord" Arg='G'/>
##  <Returns>
##  the record stored in the group <A>G</A> when this was constructed
##  with <Ref Func="AtlasGroup" Label="for various arguments"/>.
##  </Returns>
##  <Description>
##  For a group <A>G</A> that has been constructed with
##  <Ref Func="AtlasGroup" Label="for various arguments"/>,
##  the value of this attribute is the info record that describes <A>G</A>,
##  in the sense that this record was the first argument of the call to
##  <Ref Func="AtlasGroup" Label="for various arguments"/>, or it is the
##  result of the call to <Ref Func="OneAtlasGeneratingSetInfo"/> with the
##  conditions that were listed in the call to
##  <Ref Func="AtlasGroup" Label="for various arguments"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> AtlasRepInfoRecord( AtlasGroup( "A5" ) );
##  rec( groupname := "A5", id := "", 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2, 
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AtlasRepInfoRecord", IsGroup );


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
##  rec( groupname := "A5", id := "",
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2, 
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> AtlasGroup( info );
##  Group([ (1,2)(3,4), (1,3,5) ])
##  gap> AtlasGroup( info.identifier );
##  Group([ (1,2)(3,4), (1,3,5) ])
##  ]]></Example>
##  <P/>
##  In the groups returned by
##  <Ref Func="AtlasGroup" Label="for various arguments"/>,
##  the value of the attribute <Ref Attr="AtlasRepInfoRecord"/> is set.
##  This information is used for example by
##  <Ref Func="AtlasSubgroup" Label="for a group and a number"/>
##  when this function is called with second argument a group created by
##  <Ref Func="AtlasGroup" Label="for various arguments"/>.
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
#F  AtlasSubgroup( <G>, <maxnr> )
##
##  <#GAPDoc Label="AtlasSubgroup">
##  <ManSection>
##  <Heading>AtlasSubgroup</Heading>
##  <Func Name="AtlasSubgroup" Arg='gapname[, std][, ...], maxnr'
##   Label="for a group name (and various arguments) and a number"/>
##  <Func Name="AtlasSubgroup" Arg='identifier, maxnr'
##   Label="for an identifier record and a number"/>
##  <Func Name="AtlasSubgroup" Arg='G, maxnr'
##   Label="for a group and a number"/>
##
##  <Returns>
##  a group that satisfies the conditions, or <K>fail</K>.
##  </Returns>
##  <Description>
##  The arguments of
##  <Ref Func="AtlasSubgroup"
##   Label="for a group name (and various arguments) and a number"/>,
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
##  <Ref Func="AtlasSubgroup"
##   Label="for a group name (and various arguments) and a number"/>
##  returns the restriction of this representation to the <A>maxnr</A>-th
##  maximal subgroup.
##  <P/>
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
##  or the <C>identifier</C> component of such a record,
##  or a group <A>G</A> constructed with
##  <Ref Func="AtlasGroup" Label="for an identifier record"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> info:= OneAtlasGeneratingSetInfo( "A5" );
##  rec( groupname := "A5", id := "", 
##    identifier := [ "A5", [ "A5G1-p5B0.m1", "A5G1-p5B0.m2" ], 1, 5 ], 
##    isPrimitive := true, maxnr := 1, p := 5, rankAction := 2, 
##    repname := "A5G1-p5B0", repnr := 1, size := 60, stabilizer := "A4", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> AtlasSubgroup( info, 1 );
##  Group([ (1,5)(2,3), (1,3,5) ])
##  gap> AtlasSubgroup( info.identifier, 1 );
##  Group([ (1,5)(2,3), (1,3,5) ])
##  gap> AtlasSubgroup( AtlasGroup( "A5" ), 1 );
##  Group([ (1,5)(2,3), (1,3,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasSubgroup" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsUserParameters()
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsShowUserParameters">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsUserParameters" Arg=''/>
##
##  <Description>
##  This function returns a string that describes an overview of the current
##  values of the user parameters introduced in this section.
##  One can use <Ref Func="Print" BookName="ref"/> or
##  <Ref Func="Pager" BookName="ref"/> for showing the overview.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsUserParameters" );


#############################################################################
##
#E

