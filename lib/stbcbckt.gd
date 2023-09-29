#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#V  InfoBckt
##
##  <#GAPDoc Label="InfoBckt">
##  <ManSection>
##  <InfoClass Name="InfoBckt"/>
##
##  <Description>
##  is the info class for the partition backtrack routines.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoBckt" );

DeclareGlobalFunction( "UnslicedPerm@" );
DeclareGlobalFunction( "PreImageWord" );
DeclareGlobalFunction( "ExtendedT" );
DeclareGlobalFunction( "MeetPartitionStrat" );
DeclareGlobalFunction( "MeetPartitionStratCell" );
DeclareGlobalFunction( "StratMeetPartition" );
DeclareGlobalFunction( "Suborbits" );
DeclareGlobalFunction( "OrbitalPartition" );
DeclareGlobalFunction( "EmptyRBase" );
DeclareGlobalFunction( "IsTrivialRBase" );
DeclareGlobalFunction( "AddRefinement" );
DeclareGlobalFunction( "ProcessFixpoint" );
DeclareGlobalFunction( "RegisterRBasePoint" );
DeclareGlobalFunction( "NextRBasePoint" );
DeclareGlobalFunction( "RRefine" );
DeclareGlobalFunction( "PBIsMinimal" );
DeclareGlobalFunction( "SubtractBlistOrbitStabChain" );
DeclareGlobalFunction( "PartitionBacktrack" );

DeclareGlobalFunction("SuboLiBli");
DeclareGlobalFunction("SuboSiBli");
DeclareGlobalFunction("SuboTruePos");
DeclareGlobalFunction("SuboUniteBlist");
DeclareGlobalFunction("ConcatSubos");

DeclareGlobalFunction("Refinements_ProcessFixpoint");
DeclareGlobalFunction("Refinements_Intersection");
DeclareGlobalFunction("Refinements_Centralizer");
DeclareGlobalFunction("Refinements__MakeBlox");
DeclareGlobalFunction("Refinements_SplitOffBlock");
DeclareGlobalFunction("Refinements__RegularOrbit1");
DeclareGlobalFunction("Refinements_RegularOrbit2");
DeclareGlobalFunction("Refinements_RegularOrbit3");
DeclareGlobalFunction("Refinements_Suborbits0");
DeclareGlobalFunction("Refinements_Suborbits1");
DeclareGlobalFunction("Refinements_Suborbits2");
DeclareGlobalFunction("Refinements_Suborbits3");
DeclareGlobalFunction("Refinements_TwoClosure");


DeclareGlobalFunction( "NextLevelRegularGroups" );
DeclareGlobalFunction( "RBaseGroupsBloxPermGroup" );
DeclareGlobalFunction( "RepOpSetsPermGroup" );
DeclareGlobalFunction( "RepOpElmTuplesPermGroup" );
DeclareGlobalFunction( "ConjugatorPermGroup" );
DeclareGlobalFunction( "NormalizerPermGroup" );


#############################################################################
##
#F  ElementProperty( <G>, <Pr>[, <L>[, <R>]] )      one element with property
##
##  <#GAPDoc Label="ElementProperty">
##  <ManSection>
##  <Func Name="ElementProperty" Arg='G, Pr[, L[, R]]'/>
##
##  <Description>
##  <Ref Func="ElementProperty"/> returns an element <M>\pi</M> of the
##  permutation group <A>G</A> such that the one-argument function <A>Pr</A>
##  returns <K>true</K> for <M>\pi</M>.
##  It returns <K>fail</K> if no such element exists in <A>G</A>.
##  The optional arguments <A>L</A> and <A>R</A> are subgroups of <A>G</A>
##  such that the property <A>Pr</A> has the same value for all elements in
##  the cosets <A>L</A> <M>g</M> and <M>g</M> <A>R</A>, respectively,
##  with <M>g \in <A>G</A></M>.
##  <P/>
##  A typical example of using the optional subgroups <A>L</A> and <A>R</A>
##  is the conjugacy test for elements <M>a</M> and <M>b</M> for which one
##  can set <A>L</A><M>:= C_{<A>G</A>}(a)</M> and
##  <A>R</A><M>:= C_{<A>G</A>}(b)</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> propfun:= el -> (1,2,3)^el in [ (1,2,3), (1,3,2) ];;
##  gap> SubgroupProperty( g, propfun, Subgroup( g, [ (1,2,3) ] ) );
##  Group([ (1,2,3), (2,3) ])
##  gap> ElementProperty( g, el -> Order( el ) = 2 );
##  (2,4)
##  ]]></Example>
##  <P/>
##  Chapter&nbsp;<Ref Chap="Permutations"/> describes special operations to
##  construct permutations in the symmetric group without using backtrack
##  constructions.
##  <P/>
##  Backtrack routines are also called by the methods for permutation groups
##  that compute centralizers, normalizers, intersections,
##  conjugating elements as well as stabilizers for the operations of a
##  permutation group via <Ref Func="OnPoints"/>, <Ref Func="OnSets"/>,
##  <Ref Func="OnTuples"/> and <Ref Func="OnSetsSets"/>.
##  Some of these methods use more specific refinements than
##  <Ref Func="SubgroupProperty"/> or <Ref Func="ElementProperty"/>.
##  For the definition of refinements, and how one can define refinements,
##  see Section&nbsp;<Ref Sect="The General Backtrack Algorithm with Ordered Partitions"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ElementProperty" );


#############################################################################
##
#F  SubgroupProperty( <G>, <Pr>[, <L> ] ) . . . . . . . . fulfilling subgroup
##
##  <#GAPDoc Label="SubgroupProperty">
##  <ManSection>
##  <Func Name="SubgroupProperty" Arg='G, Pr[, L ]'/>
##
##  <Description>
##  <A>Pr</A> must be a one-argument function that returns <K>true</K> or
##  <K>false</K> for elements of the permutation group <A>G</A>,
##  and the subset of elements of <A>G</A> that fulfill <A>Pr</A> must
##  be a subgroup. (<E>If the latter is not true the result of this operation
##  is unpredictable!</E>) This command computes this subgroup.
##  The optional argument <A>L</A> must be a subgroup of the set of all
##  elements in <A>G</A> fulfilling <A>Pr</A> and can be given if known
##  in order to speed up the calculation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubgroupProperty" );


#############################################################################
##
#O  PartitionStabilizerPermGroup( <G>, <part> )
##
##  <ManSection>
##  <Oper Name="PartitionStabilizerPermGroup" Arg='G, part'/>
##
##  <Description>
##  <A>part</A> must be a list of pairwise disjoint sets of points
##  on which the permutation group <A>G</A> acts via <C>OnPoints</C>.
##  This function computes the stabilizer in <A>G</A> of <A>part</A>, that is,
##  the subgroup of all those elements in <A>G</A> that map each set in <A>part</A>
##  onto a set in <A>part</A>, via <C>OnSets</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PartitionStabilizerPermGroup" );


#############################################################################
##
#A  TwoClosure( <G> )
##
##  <#GAPDoc Label="TwoClosure">
##  <ManSection>
##  <Attr Name="TwoClosure" Arg='G'/>
##
##  <Description>
##  The <E>2-closure</E> of a transitive permutation group <A>G</A> on
##  <M>n</M> points is the largest subgroup of the symmetric group <M>S_n</M>
##  which has the same orbits on sets of ordered pairs of points as the group
##  <A>G</A> has.
##  It also can be interpreted as the stabilizer of the orbital graphs of
##  <A>G</A>.
##  <Example><![CDATA[
##  gap> TwoClosure(Group((1,2,3),(2,3,4)));
##  Sym( [ 1 .. 4 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TwoClosure", IsPermGroup );
