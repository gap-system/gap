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
##  This  file  contains declarations for Morpheus
##

DeclareInfoClass("InfoMorph");

#############################################################################
##
#A  AutomorphismGroup(<obj>)
##
##  <#GAPDoc Label="AutomorphismGroup">
##  <ManSection>
##  <Attr Name="AutomorphismGroup" Arg='G'/>
##
##  <Description>
##  returns the full automorphism group of the group <A>G</A>.
##  The automorphisms act on <A>G</A> by the caret operator <C>^</C>.
##  The automorphism group often stores a <Ref Attr="NiceMonomorphism"/>
##  value whose image is a permutation group,
##  obtained by the action on a subset of <A>G</A>.
##  <P/>
##  Note that current methods for the calculation of the automorphism group
##  of a group <M>G</M> require <M>G</M> to be a permutation group or
##  a pc group to be efficient. For groups in other representations the
##  calculation is likely very slow.
##  <P/>
##  Also, the <Package>AutPGrp</Package> package installs enhanced methods
##  for <Ref Attr="AutomorphismGroup"/> for finite <M>p</M>-groups, and
##  the <Package>FGA</Package> package - for finitely generated subgroups
##  of free groups.
##  <P/>
##  Methods may be installed for <Ref Attr="AutomorphismGroup"/>
##  for other domains, such as e.g. for linear codes in the
##  <Package>GUAVA</Package> package, loops in the <Package>loops</Package>
##  package and nilpotent Lie algebras in the <Package>Sophus</Package>
##  package (see package manuals for their descriptions).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("AutomorphismGroup",IsDomain);

#############################################################################
##
#P  IsGroupOfAutomorphisms(<G>)
##
##  <#GAPDoc Label="IsGroupOfAutomorphisms">
##  <ManSection>
##  <Prop Name="IsGroupOfAutomorphisms" Arg='G'/>
##
##  <Description>
##  indicates whether <A>G</A> consists of automorphisms of another group
##  <M>H</M>.
##  The group <M>H</M> can be obtained from <A>G</A> via the attribute
##  <Ref Attr="AutomorphismDomain"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsGroupOfAutomorphisms", IsGroup );
InstallTrueMethod( IsGroup, IsGroupOfAutomorphisms );

#############################################################################
##
#P  IsGroupOfAutomorphismsFiniteGroup(<G>)
##
##  <ManSection>
##  <Prop Name="IsGroupOfAutomorphismsFiniteGroup" Arg='G'/>
##
##  <Description>
##  indicates whether <A>G</A> consists of automorphisms of another finite group <A>H</A>.
##  The group <A>H</A> can be obtained from <A>G</A> via the attribute
##  <C>AutomorphismDomain</C>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsGroupOfAutomorphismsFiniteGroup", IsGroup );
InstallTrueMethod( IsGroup, IsGroupOfAutomorphismsFiniteGroup );

InstallTrueMethod( IsGroupOfAutomorphisms,IsGroupOfAutomorphismsFiniteGroup);
InstallTrueMethod( IsFinite,IsGroupOfAutomorphismsFiniteGroup);
InstallTrueMethod( IsHandledByNiceMonomorphism,
  IsGroupOfAutomorphismsFiniteGroup);

InstallSubsetMaintenance( IsGroupOfAutomorphisms,
    IsGroup and IsGroupOfAutomorphisms, IsGroup );

InstallSubsetMaintenance( IsGroupOfAutomorphismsFiniteGroup,
    IsGroup and IsGroupOfAutomorphismsFiniteGroup, IsGroup );

#############################################################################
##
#A  AutomorphismDomain(<G>)
##
##  <#GAPDoc Label="AutomorphismDomain">
##  <ManSection>
##  <Attr Name="AutomorphismDomain" Arg='G'/>
##
##  <Description>
##  If <A>G</A> consists of automorphisms of <M>H</M>,
##  this attribute returns <M>H</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AutomorphismDomain", IsGroupOfAutomorphisms );

#############################################################################
##
#P  IsAutomorphismGroup(<G>)
##
##  <#GAPDoc Label="IsAutomorphismGroup">
##  <ManSection>
##  <Prop Name="IsAutomorphismGroup" Arg='G'/>
##
##  <Description>
##  indicates whether <A>G</A>, which must be
##  <Ref Prop="IsGroupOfAutomorphisms"/>,
##  is the full automorphism group of another
##  group <M>H</M>, this group is given as <Ref Attr="AutomorphismDomain"/>
##  value of <A>G</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,3));
##  Group([ (1,2,3,4), (1,3) ])
##  gap> au:=AutomorphismGroup(g);
##  <group of size 8 with 3 generators>
##  gap> GeneratorsOfGroup(au);
##  [ Pcgs([ (2,4), (1,2,3,4), (1,3)(2,4) ]) ->
##      [ (1,2)(3,4), (1,2,3,4), (1,3)(2,4) ],
##    Pcgs([ (2,4), (1,2,3,4), (1,3)(2,4) ]) ->
##      [ (1,3), (1,2,3,4), (1,3)(2,4) ],
##    Pcgs([ (2,4), (1,2,3,4), (1,3)(2,4) ]) ->
##      [ (2,4), (1,4,3,2), (1,3)(2,4) ] ]
##  gap> NiceObject(au);
##  Group([ (1,2,4,6), (1,4)(2,6), (2,6)(3,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsAutomorphismGroup", IsGroupOfAutomorphisms );
InstallTrueMethod( IsGroupOfAutomorphisms,IsAutomorphismGroup );

#############################################################################
##
#A  InnerAutomorphismsAutomorphismGroup(<autgroup>)
##
##  <#GAPDoc Label="InnerAutomorphismsAutomorphismGroup">
##  <ManSection>
##  <Attr Name="InnerAutomorphismsAutomorphismGroup" Arg='autgroup'/>
##
##  <Description>
##  For an automorphism group <A>autgroup</A> of a group
##  this attribute stores the subgroup of inner automorphisms
##  (automorphisms induced by conjugation) of the original group.
##  <Example><![CDATA[
##  gap> InnerAutomorphismsAutomorphismGroup(au);
##  <group with 2 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("InnerAutomorphismsAutomorphismGroup",IsGroup);

#############################################################################
##
#A  InnerAutomorphismGroup(<G>)
##
##  <#GAPDoc Label="InnerAutomorphismGroup">
##  <ManSection>
##  <Attr Name="InnerAutomorphismGroup" Arg='G'/>
##
##  <Description>
##  For a group <A>G</A> this attribute stores the group of inner
##  automorphisms (automorphisms induced by conjugation) of the original group.
##  <Example><![CDATA[
##  gap> InnerAutomorphismGroup(SymmetricGroup(5));
##  <group with 2 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("InnerAutomorphismGroup", IsGroup);

#############################################################################
##
#F  AssignNiceMonomorphismAutomorphismGroup(<autgrp>,<group>)   local
##
##  <#GAPDoc Label="AssignNiceMonomorphismAutomorphismGroup">
##  <ManSection>
##  <Func Name="AssignNiceMonomorphismAutomorphismGroup" Arg='autgrp, group'/>
##
##  <Description>
##  computes a nice monomorphism for <A>autgroup</A> acting on <A>group</A>
##  and stores it as <Ref Attr="NiceMonomorphism"/> value of <A>autgrp</A>.
##  <P/>
##  If the centre of <Ref Attr="AutomorphismDomain"/> of <A>autgrp</A> is
##  trivial, the operation will first try to represent all automorphisms by
##  conjugation (in <A>group</A> or in a natural parent of <A>group</A>).
##  <P/>
##  If this fails the operation tries to find a small subset of <A>group</A>
##  on which the action will be faithful.
##  <P/>
##  The operation sets the attribute <Ref Attr="NiceMonomorphism"/>
##  and does not return a value.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AssignNiceMonomorphismAutomorphismGroup");

#############################################################################
##
#F  NiceMonomorphismAutomGroup(<autgrp>,<elms>,<elmsgens>)
##
##  <#GAPDoc Label="NiceMonomorphismAutomGroup">
##  <ManSection>
##  <Func Name="NiceMonomorphismAutomGroup" Arg='autgrp, elms, elmsgens'/>
##
##  <Description>
##  This function creates a monomorphism for an automorphism group
##  <A>autgrp</A> of a group by permuting the group elements in the list
##  <A>elms</A>.
##  This list must be chosen to yield a faithful representation.
##  <A>elmsgens</A> is a list of generators which are a subset of
##  <A>elms</A>.
##  (They can differ from the group's original generators.)
##  It does not yet assign it as <Ref Attr="NiceMonomorphism"/> value.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NiceMonomorphismAutomGroup");

#############################################################################
##
#F  MorFroWords(<gens>) . . . . . . create some pseudo-random words in <gens>
##
##  <ManSection>
##  <Func Name="MorFroWords" Arg='gens'/>
##
##  <Description>
##  This function takes a generator list <A>gens</A> and creates a list of
##  pseudo-random words in them. These words can be used for example to test
##  quickly whether generator mappings extend to a homomorphism. The words
##  are taken from the MeatAxe FRO routine.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MorFroWords");

#############################################################################
##
#F  MorRatClasses(<G>) . . . . . . . . . . . local
##
##  <ManSection>
##  <Func Name="MorRatClasses" Arg='G'/>
##
##  <Description>
##  yields a list of rational classes as a collection of ordinary classes.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MorRatClasses");

#############################################################################
##
#F  MorMaxFusClasses(<l>) . .  maximal possible morphism fusion of classlists
##
##  <ManSection>
##  <Func Name="MorMaxFusClasses" Arg='l'/>
##
##  <Description>
##  computes a list of classes (as unions of rational classes) which will be
##  respected by any automorphism. This is used to determine potential
##  automorphism images of elements.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MorMaxFusClasses");


#############################################################################
##
#F  MorClassLoop(<range>,<classes>,<params>,<action>)     class loop
##
##  <#GAPDoc Label="MorClassLoop">
##  <ManSection>
##  <Func Name="MorClassLoop" Arg='range, classes, params, action'/>
##
##  <Description>
##  This function loops over element tuples taken from <A>classes</A> and
##  checks these for properties such as generating a given group,
##  or fulfilling relations.
##  This can be used to find small generating sets or all types of Morphisms.
##  The element tuples are used only up to inner automorphisms as
##  all images can be obtained easily from them by conjugation while
##  running through all of them usually would take too long.
##  <P/>
##  <A>range</A> is a group from which these elements are taken.
##  The classes are given in a list <A>classes</A> which  is a list of records
##  with the following components.
##  <List>
##  <Mark><C>classes</C></Mark>
##  <Item>
##   list of conjugacy classes
##  </Item>
##  <Mark><C>representative</C></Mark>
##  <Item>
##   One element in the union of these classes
##  </Item>
##  <Mark><C>size</C></Mark>
##  <Item>
##   The sum of the sizes of these classes
##  </Item>
##  </List>
##  <P/>
##  <A>params</A> is a record containing the following optional components.
##  <List>
##  <Mark><C>gens</C></Mark>
##  <Item>
##   generators that are to be mapped (for testing morphisms). The length
##   of this list determines the length of element tuples considered.
##  </Item>
##  <Mark><C>from</C></Mark>
##  <Item>
##   a preimage group (that contains <C>gens</C>)
##  </Item>
##  <Mark><C>to</C></Mark>
##  <Item>
##   image group (which might be smaller than <C>range</C>)
##  </Item>
##  <Mark><C>free</C></Mark>
##  <Item>
##   free generators, a list of the same length than the
##   generators <C>gens</C>.
##  </Item>
##  <Mark><C>rels</C></Mark>
##  <Item>
##   some relations that hold among the generators <C>gens</C>.
##   They are given as a list <C>[ word, order ]</C>
##   where <C>word</C> is a word in the free generators <C>free</C>.
##  </Item>
##  <Mark><C>dom</C></Mark>
##  <Item>
##   a set of elements on which automorphisms act faithfully (used to do
##   element tests in partial automorphism groups).
##  </Item>
##  <Mark><C>aut</C></Mark>
##  <Item>
##   Subgroup of already known automorphisms.
##  </Item>
##  <Mark><C>condition</C></Mark>
##  <Item>
##   A function that will be applied to the homomorphism and must return
##  <K>true</K> for the homomorphism to be accepted.
##  </Item>
##  </List>
##  <P/>
##  <A>action</A> is a number whose bit-representation indicates
##  the requirements which are enforced on the element tuples found,
##  as follows.
##  <List>
##  <Mark>1</Mark>
##  <Item>
##     homomorphism
##  </Item>
##  <Mark>2</Mark>
##  <Item>
##     injective
##  </Item>
##  <Mark>4</Mark>
##  <Item>
##     surjective
##  </Item>
##  <Mark>8</Mark>
##  <Item>
##     find all (otherwise stops after the first find)
##  </Item>
##  </List>
##  If the search is for homomorphisms, the function returns homomorphisms
##  obtained by mapping the given generators <C>gens</C>
##  instead of element tuples.
##  <P/>
##  The <Q>Morpheus</Q> algorithm used to find homomorphisms is described in
##  <Cite Key="Hulpke96" Where="Section V.5"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MorClassLoop");

#############################################################################
##
#F  MorFindGeneratingSystem(<G>,<cl>) . .  local
##
##  <ManSection>
##  <Func Name="MorFindGeneratingSystem" Arg='G,cl'/>
##
##  <Description>
##  tries to find generating system with as few as possible generators
##  which will be taken preferraby from the first classes in <A>cl</A>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MorFindGeneratingSystem");


#############################################################################
##
#F  Morphium(<G>,<H>,<DoAuto>) . . . . . . . . local
##
##  <ManSection>
##  <Func Name="Morphium" Arg='G,H,DoAuto'/>
##
##  <Description>
##  This function is a frontend to <C>MorClassLoop</C> and is used to find
##  isomorphisms between <A>G</A> and <A>H</A> or the automorphism group of <A>G</A> (in which
##  case <A>G</A> must equal <A>H</A>). The boolean flag <A>DoAuto</A> indicates if all
##  automorphisms should be found.
##  The function requires, that both groups are not cyclic!
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("Morphium");

#############################################################################
##
#F  AutomorphismGroupAbelianGroup(<G>)
##
##  <ManSection>
##  <Func Name="AutomorphismGroupAbelianGroup" Arg='G'/>
##
##  <Description>
##  computes the automorphism group of an abelian group <A>G</A>, using the theorem
##  of Shoda.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("AutomorphismGroupAbelianGroup");

DeclareGlobalFunction("AutomorphismGroupFittingFree");

#############################################################################
##
#F  IsomorphismAbelianGroups(<G>,<H>)
##
##  <ManSection>
##  <Func Name="IsomorphismAbelianGroups" Arg='G,H'/>
##
##  <Description>
##  computes an isomorphism between the abelian groups <A>G</A> and <A>H</A>
##  if they are isomorphic and returns <K>fail</K> otherwise.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsomorphismAbelianGroups");

#############################################################################
##
#F  IsomorphismGroups(<G>,<H>)
##
##  <#GAPDoc Label="IsomorphismGroups">
##  <ManSection>
##  <Func Name="IsomorphismGroups" Arg='G,H'/>
##
##  <Description>
##  computes an isomorphism between the groups <A>G</A> and <A>H</A>
##  if they are isomorphic and returns <K>fail</K> otherwise.
##  <P/>
##  With the existing methods the amount of time needed grows with
##  the size of a generating system of <A>G</A>. (Thus in particular for
##  <M>p</M>-groups calculations can be slow.) If you do only need to know
##  whether groups are isomorphic, you might want to consider
##  <Ref BookName="smallgrp" Func="IdGroup"/> or the random isomorphism test
##  (see&nbsp;<Ref Func="RandomIsomorphismTest"/>).
##  <P/>
##  <Index Subkey="find all">isomorphisms</Index>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,3));;
##  gap> h:=Group((1,4,6,7)(2,3,5,8), (1,5)(2,6)(3,4)(7,8));;
##  gap> IsomorphismGroups(g,h);
##  [ (1,2,3,4), (1,3) ] -> [ (1,4,6,7)(2,3,5,8), (1,2)(3,7)(4,8)(5,6) ]
##  gap> IsomorphismGroups(g,Group((1,2,3,4),(1,2)));
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IsomorphismGroups");
DeclareGlobalFunction("IsomorphismSimpleGroups");

#############################################################################
##
#O  GQuotients(<F>,<G>)  . . . . . epimorphisms from F onto G up to conjugacy
##
##  <#GAPDoc Label="GQuotients">
##  <ManSection>
##  <Oper Name="GQuotients" Arg='F, G'/>
##
##  <Description>
##  computes all epimorphisms from <A>F</A> onto <A>G</A> up to automorphisms
##  of <A>G</A>.
##  This classifies all factor groups of <A>F</A> which are isomorphic to
##  <A>G</A>.
##  <P/>
##  With the existing methods the amount of time needed grows with
##  the size of a generating system of <A>G</A>. (Thus in particular for
##  <M>p</M>-groups calculations can be slow.)
##  <P/>
##  If the <C>findall</C> option is set to <K>false</K>,
##  the algorithm will stop once one homomorphism has been found
##  (this can be faster and might be sufficient if not all homomorphisms
##  are needed).
##  <P/>
##  <Index Subkey="find all">epimorphisms</Index>
##  <Index Subkey="find all">projections</Index>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));
##  Group([ (1,2,3,4), (1,2) ])
##  gap> h:=Group((1,2,3),(1,2));
##  Group([ (1,2,3), (1,2) ])
##  gap> quo:=GQuotients(g,h);
##  [ [ (1,2,3,4), (1,4,3) ] -> [ (2,3), (1,2,3) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("GQuotients",[IsGroup,IsGroup]);

#############################################################################
##
#O  IsomorphicSubgroups(<G>,<H>)  monomorphisms from H onto G up to conjugacy
##
##  <#GAPDoc Label="IsomorphicSubgroups">
##  <ManSection>
##  <Oper Name="IsomorphicSubgroups" Arg='G,H'/>
##
##  <Description>
##  computes all monomorphisms from <A>H</A> into <A>G</A> up to
##  <A>G</A>-conjugacy of the image groups.
##  This classifies all <A>G</A>-classes of subgroups of <A>G</A> which
##  are isomorphic to <A>H</A>.
##  <P/>
##  With the existing methods, the amount of time needed grows with
##  the size of a generating system of <A>G</A>. (Thus in particular for
##  <M>p</M>-groups calculations can be slow.) A main use of
##  <Ref Oper="IsomorphicSubgroups"/> therefore is to find nonsolvable
##  subgroups (which often can be generated by 2 elements).
##  <P/>
##  (To find <M>p</M>-subgroups it is often faster to compute the subgroup
##  lattice of the Sylow subgroup and to use <Ref BookName="smallgrp" Func="IdGroup"/>
##  to identify the type of the subgroups.)
##  <P/>
##  If the <C>findall</C> option is set to <K>false</K>,
##  the algorithm will stop once one homomorphism has been found
##  (this can be faster and might be sufficient if not all homomorphisms are
##  needed).
##  <P/>
##  <Index Subkey="find all">embeddings</Index>
##  <Index Subkey="find all">monomorphisms</Index>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));
##  Group([ (1,2,3,4), (1,2) ])
##  gap> h:=Group((3,4),(1,2));;
##  gap> emb:=IsomorphicSubgroups(g,h);
##  [ [ (3,4), (1,2) ] -> [ (1,2), (3,4) ],
##    [ (3,4), (1,2) ] -> [ (1,3)(2,4), (1,2)(3,4) ] ]
##  gap> g1:=PSO(-1,8,2);;
##  gap> Length(IsomorphicSubgroups(g1,PSL(2,7)));
##  3
##  gap> Length(IsomorphicSubgroups(g1,PSL(2,7):findall:=false));
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("IsomorphicSubgroups",[IsGroup,IsGroup]);

DeclareGlobalFunction("PatheticIsomorphism");
