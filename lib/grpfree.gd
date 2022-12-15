#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Free groups are treated as   special cases of finitely presented  groups.
##  In addition,   elements  of  a free   group are
##  (associative) words, that is they have a normal  form that allows an easy
##  equalitity test.
##


#############################################################################
##
#F  IsElementOfFreeGroup  . . . . . . . . . . . . .  elements in a free group
##
##  <ManSection>
##  <Func Name="IsElementOfFreeGroup" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "IsElementOfFreeGroup", IsAssocWordWithInverse );
DeclareSynonym( "IsElementOfFreeGroupFamily",IsAssocWordWithInverseFamily );


#############################################################################
##
#F  FreeGroup( [<wfilt>,]<rank>[, <name>] )
#F  FreeGroup( [<wfilt>,][<name1>[, <name2>[, ...]]] )
#F  FreeGroup( [<wfilt>,]<names> )
#F  FreeGroup( [<wfilt>,]infinity[, <name>][, <init>] )
##
##  <#GAPDoc Label="FreeGroup">
##  <ManSection>
##  <Heading>FreeGroup</Heading>
##  <Func Name="FreeGroup" Arg='[wfilt, ]rank[, name]'
##   Label="for given rank"/>
##  <Func Name="FreeGroup" Arg='[wfilt, ][name1[, name2[, ...]]]'
##   Label="for various names"/>
##  <Func Name="FreeGroup" Arg='[wfilt, ]names'
##   Label="for a list of names"/>
##  <Func Name="FreeGroup" Arg='[wfilt, ]infinity[, name][, init]'
##   Label="for infinitely many generators"/>
##
##  <Description>
##  <C>FreeGroup</C> returns a free group. The number of
##  generators, and the labels given to the generators, can be specified in
##  several different ways.
##  Warning: the labels of generators are only an aid for printing,
##  and do not necessarily distinguish generators;
##  see the examples at the end of
##  <Ref Func="FreeSemigroup" Label="for given rank"/>
##  for more information.
##  <List>
##    <Mark>
##      1: For a given rank, and an optional generator name prefix
##    </Mark>
##    <Item>
##      Called with a nonnegative integer <A>rank</A>,
##      <Ref Func="FreeGroup" Label="for given rank"/> returns
##      a free group on <A>rank</A> generators.
##      The optional argument <A>name</A> must be a string;
##      its default value is <C>"f"</C>. <P/>
##
##      If <A>name</A> is not given but the <C>generatorNames</C> option is,
##      then this option is respected as described in
##      Section&nbsp;<Ref Sect="Generator Names"/>. <P/>
##
##      Otherwise, the generators of the returned free group are labelled
##      <A>name</A><C>1</C>, ..., <A>name</A><C>k</C>,
##      where <C>k</C> is the value of <A>rank</A>. <P/>
##    </Item>
##    <Mark>2: For given generator names</Mark>
##    <Item>
##      Called with various nonempty strings,
##      <Ref Func="FreeGroup" Label="for various names"/> returns
##      a free group on as many generators as arguments, which are labelled
##      <A>name1</A>, <A>name2</A>, etc.
##    </Item>
##    <Mark>3: For a given list of generator names</Mark>
##    <Item>
##      Called with a finite list <A>names</A> of
##      nonempty strings,
##      <Ref Func="FreeGroup" Label="for a list of names"/> returns
##      a free group on <C>Length(<A>names</A>)</C> generators, whose
##      <C>i</C>-th generator is labelled <A>names</A><C>[i]</C>.
##    </Item>
##    <Mark>
##      4: For the rank <K>infinity</K>,
##         an optional default generator name prefix,
##         and an optional finite list of generator names
##    </Mark>
##    <Item>
##      Called in the fourth form,
##      <Ref Func="FreeGroup" Label="for infinitely many generators"/>
##      returns a free group on infinitely many generators.
##      The optional argument <A>name</A> must be a string; its default value is
##      <C>"f"</C>,
##      and the optional argument <A>init</A> must be a finite list of
##      nonempty strings; its default value is an empty list.
##      The generators are initially labelled according to the list <A>init</A>,
##      followed by
##      <A>name</A><C>i</C> for each <C>i</C> in the range from
##      <C>Length(<A>init</A>)+1</C> to <K>infinity</K>.
##    </Item>
##  </List>
##  If the optional first argument <A>wfilt</A> is given, then it must be either
##  <C>IsSyllableWordsFamily</C>, <C>IsLetterWordsFamily</C>,
##  <C>IsWLetterWordsFamily</C>, or <C>IsBLetterWordsFamily</C>.
##  This filter specifies the representation used for the elements of
##  the free group
##  (see&nbsp;<Ref Sect="Representations for Associative Words"/>).
##  If no such filter is given, a letter representation is used.
##  <P/>
##  (For interfacing to old code that omits the representation flag, use of
##  the syllable representation is also triggered by setting the option
##  <C>FreeGroupFamilyType</C> to the string <C>"syllable"</C>; this is
##  overwritten by the optional first argument if it is given.)
##
##  <Example><![CDATA[
##  gap> FreeGroup(5);
##  <free group on the generators [ f1, f2, f3, f4, f5 ]>
##  gap> FreeGroup(4, "gen");
##  <free group on the generators [ gen1, gen2, gen3, gen4 ]>
##  gap> FreeGroup(3 : generatorNames := "ack");
##  <free group on the generators [ ack1, ack2, ack3 ]>
##  gap> FreeGroup(2 : generatorNames := ["u", "v", "w"]);
##  <free group on the generators [ u, v ]>
##  gap> FreeGroup();
##  <free group of rank zero>
##  gap> FreeGroup("a", "b", "c");
##  <free group on the generators [ a, b, c ]>
##  gap> FreeGroup(["x", "y"]);
##  <free group on the generators [ x, y ]>
##  gap> FreeGroup(infinity);
##  <free group with infinity generators>
##  gap> F := FreeGroup(infinity, "g", ["a", "b"]);
##  <free group with infinity generators>
##  gap> GeneratorsOfGroup(F){[1..4]};
##  [ a, b, g3, g4 ]
##  gap> GeneratorsOfGroup(FreeGroup(infinity, "gen")){[1..3]};
##  [ gen1, gen2, gen3 ]
##  gap> FreeGroup(IsSyllableWordsFamily, 50);
##  <free group with 50 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeGroup" );
