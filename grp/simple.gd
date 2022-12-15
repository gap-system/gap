#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains basic constructions for nonabelian simple groups of bounded size,
##  if necessary by calling the `atlasrep' package.
##


#############################################################################
##
#F  SimpleGroup( <id> [,<param1>[,<param2>[] )
##
##  <#GAPDoc Label="SimpleGroup">
##  <ManSection>
##  <Func Name="SimpleGroup" Arg='id [,param]'/>
##
##  <Description>
##  This function will construct <B>an</B> instance of the specified nonabelian simple group.
##  Groups are specified via their name in ATLAS style notation, with parameters added
##  if necessary. The intelligence applied to parsing the name is limited, and at the
##  moment no proper extensions can be constructed.
##  For groups who do not have a permutation representation of small degree the
##  ATLASREP package might need to be installed to construct theses groups.
##  <Example><![CDATA[
##  gap> g:=SimpleGroup("M(23)");
##  M23
##  gap> Size(g);
##  10200960
##  gap> g:=SimpleGroup("PSL",3,5);
##  PSL(3,5)
##  gap> Size(g);
##  372000
##  gap> g:=SimpleGroup("PSp6",2);
##  PSp(6,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SimpleGroup");

#############################################################################
##
#F  EpimorphismFromClassical( <G> )
##
##  <#GAPDoc Label="EpimorphismFromClassical">
##  <ManSection>
##  <Func Name="EpimorphismFromClassical" Arg='G'/>
##
##  <Description>
##  For a nonabelian (almost) simple group this homomorphsim will try to construct an
##  epimorphism from a classical group onto it (or return fail if it does
##  not work or is not yet implemented).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EpimorphismFromClassical");


#############################################################################
##
#F  SimpleGroupsIterator( [<start>,<end>] )
##
##  <#GAPDoc Label="SimpleGroupsIterator">
##  <ManSection>
##  <Func Name="SimpleGroupsIterator" Arg='[start[,end]]'/>
##
##  <Description>
##  This function returns an iterator that will run over all nonabelian simple groups, starting
##  at order <A>start</A> if specified, up to order <M>10^{27}</M> (or -- if specified
##  -- order <A>end</A>). If the option <A>NOPSL2</A> is given, groups of type
##  <M>PSL_2(q)</M> are omitted.
##  <Example><![CDATA[
##  gap> it:=SimpleGroupsIterator(20000);
##  <iterator>
##  gap> List([1..8],x->NextIterator(it));
##  [ A8, PSL(3,4), PSL(2,37), PSp(4,3), Sz(8), PSL(2,32), PSL(2,41),
##    PSL(2,43) ]
##  gap> it:=SimpleGroupsIterator(1,2000);;
##  gap> l:=[];;for i in it do Add(l,i);od;l;
##  [ A5, PSL(2,7), A6, PSL(2,8), PSL(2,11), PSL(2,13) ]
##  gap> it:=SimpleGroupsIterator(20000,100000:NOPSL2);;
##  gap> l:=[];;for i in it do Add(l,i);od;l;
##  [ A8, PSL(3,4), PSp(4,3), Sz(8), PSU(3,4), M12 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("SimpleGroupsIterator");
BindGlobal("SIMPLE_GROUPS_ITERATOR_RANGE",10^27);

#############################################################################
##
#F  ClassicalIsomorphismTypeFiniteSimpleGroup(<G>] )
##
##  <#GAPDoc Label="ClassicalIsomorphismTypeFiniteSimpleGroup">
##  <ManSection>
##  <Func Name="ClassicalIsomorphismTypeFiniteSimpleGroup" Arg='G'/>
##  This function returns a result equivalent to (and based on)
##  <Ref Func="IsomorphismTypeInfoFiniteSimpleGroup"/>, but returns a
##  classically names series (consistent with
##  <Ref Func="SimpleGroup"/>) and the parameter always in a list. This makes it
##  easier to parse the result.
##  <Description>
##  <Example><![CDATA[
##  gap> ClassicalIsomorphismTypeFiniteSimpleGroup(SimpleGroup("O+",8,2));
##  rec( parameter := [ 8, 2 ], series := "O+" )
##  gap> IsomorphismTypeInfoFiniteSimpleGroup(SimpleGroup("O+",8,2));
##  rec( name := "D(4,2) = O+(8,2)", parameter := [ 4, 2 ], series := "D" )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("ClassicalIsomorphismTypeFiniteSimpleGroup");

DeclareAttribute("DataAboutSimpleGroup",IsGroup,"mutable");

#############################################################################
##
#F  SufficientlySmallDegreeSimpleGroupOrder(n)
##
##  <#GAPDoc Label="SufficientlySmallDegreeSimpleGroupOrder">
##  <ManSection>
##  <Func Name="SufficientlySmallDegreeSimpleGroupOrder" Arg='n'/>
##  For an order <M>n</M> this function returns a heuristic bound for a
##  small permutation degree of a simple group of that exact order.
##  This function
##  can be used to decide whether it is worth to try the `SmallerDegree'
##  reduction.
##  <#/GAPDoc>
DeclareGlobalFunction("SufficientlySmallDegreeSimpleGroupOrder");

