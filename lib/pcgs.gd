#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for polycyclic generating systems.
##

#############################################################################
##
#C  IsGeneralPcgs(<obj>)
##
##  <ManSection>
##  <Filt Name="IsGeneralPcgs" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of general pcgs. Each modulo pcgs is a general pcgs.
##  Relative orders are known for general pcgs, but it might not be possible
##  to compute exponent vectors or other elementary operations with respect
##  to a general pcgs. (For performance reasons immediate methods are always
##  ignored for Pcgs.)
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsGeneralPcgs",
    IsHomogeneousList and IsDuplicateFreeList and IsConstantTimeAccessList
    and IsFinite and IsMultiplicativeElementWithInverseCollection
    and IsNoImmediateMethodsObject);

#############################################################################
##
#C  IsModuloPcgs(<obj>)
##
##  <#GAPDoc Label="IsModuloPcgs">
##  <ManSection>
##  <Filt Name="IsModuloPcgs" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of modulo pcgs. Note that each pcgs is a modulo pcgs for
##  the trivial subgroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsModuloPcgs",IsGeneralPcgs);

#############################################################################
##
#C  IsPcgs(<obj>)
##
##  <#GAPDoc Label="IsPcgs">
##  <ManSection>
##  <Filt Name="IsPcgs" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of pcgs.
##  <Example><![CDATA[
##  gap> G := Group((1,2,3,4),(1,2));;
##  gap> p := Pcgs(G);
##  Pcgs([ (3,4), (2,4,3), (1,4)(2,3), (1,3)(2,4) ])
##  gap> IsPcgs( p );
##  true
##  gap> p[1];
##  (3,4)
##  gap> G := Group((1,2,3,4,5),(1,2));;
##  gap> Pcgs(G);
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPcgs", IsModuloPcgs);


#############################################################################
##
#C  IsPcgsFamily
##
##  <ManSection>
##  <Filt Name="IsPcgsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsPcgsFamily",
    IsFamily );


#############################################################################
##
#R  IsPcgsDefaultRep
##
##  <ManSection>
##  <Filt Name="IsPcgsDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation(
    "IsPcgsDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##
#O  PcgsByPcSequence( <fam>, <pcs> )
#O  PcgsByPcSequenceNC( <fam>, <pcs> )
##
##  <#GAPDoc Label="PcgsByPcSequence">
##  <ManSection>
##  <Oper Name="PcgsByPcSequence" Arg='fam, pcs'/>
##  <Oper Name="PcgsByPcSequenceNC" Arg='fam, pcs'/>
##
##  <Description>
##  constructs a pcgs for the elements family <A>fam</A> from the elements in
##  the list <A>pcs</A>. The elements must lie in the family <A>fam</A>.
##  <Ref Oper="PcgsByPcSequence"/> and its <C>NC</C> variant will always
##  create a new pcgs which is not induced by any other pcgs
##  (cf. <Ref Oper="InducedPcgsByPcSequence"/>).
##  <Example><![CDATA[
##  gap> fam := FamilyObj( (1,2) );; # the family of permutations
##  gap> p := PcgsByPcSequence( fam, [(1,2),(1,2,3)] );
##  Pcgs([ (1,2), (1,2,3) ])
##  gap> RelativeOrders(p);
##  [ 2, 3 ]
##  gap> ExponentsOfPcElement( p, (1,3,2) );
##  [ 0, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PcgsByPcSequence", [ IsFamily, IsList ] );
DeclareOperation( "PcgsByPcSequenceNC", [ IsFamily, IsList ] );


#############################################################################
##
#O  PcgsByPcSequenceCons( <req-filters>, <imp-filters>, <fam>, <pcs>,<attr> )
##
##  <ManSection>
##  <Oper Name="PcgsByPcSequenceCons"
##   Arg='req-filters, imp-filters, fam, pcs,attr'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "PcgsByPcSequenceCons",
    [ IsObject, IsObject, IsFamily, IsList,IsList ] );


#############################################################################
##
#A  PcGroupWithPcgs( <mpcgs> )
##
##  <#GAPDoc Label="PcGroupWithPcgs">
##  <ManSection>
##  <Attr Name="PcGroupWithPcgs" Arg='mpcgs'/>
##
##  <Description>
##  creates a new pc group <A>G</A> whose family pcgs is isomorphic to the
##  (modulo) pcgs <A>mpcgs</A>.
##  <Example><![CDATA[
##  gap> G := Group( (1,2,3), (3,4,1) );;
##  gap> PcGroupWithPcgs( Pcgs(G) );
##  <pc group of size 12 with 3 generators>
##  ]]></Example>
##  <P/>
##  If a pcgs is only given by a list of pc elements,
##  <Ref Oper="PcgsByPcSequence"/> can be used:
##  <Example><![CDATA[
##  gap> G:=Group((1,2,3,4),(1,2));;
##  gap> p:=PcgsByPcSequence(FamilyObj(One(G)),
##  > [ (3,4), (2,4,3), (1,4)(2,3), (1,3)(2,4) ]);
##  Pcgs([ (3,4), (2,4,3), (1,4)(2,3), (1,3)(2,4) ])
##  gap> PcGroupWithPcgs(p);
##  <pc group of size 24 with 4 generators>
##  gap> G := SymmetricGroup( 5 );
##  Sym( [ 1 .. 5 ] )
##  gap> H := Subgroup( G, [(1,2,3,4,5), (3,4,5)] );
##  Group([ (1,2,3,4,5), (3,4,5) ])
##  gap> modu := ModuloPcgs( G, H );
##  Pcgs([ (4,5) ])
##  gap> PcGroupWithPcgs(modu);
##  <pc group of size 2 with 1 generator>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PcGroupWithPcgs", IsModuloPcgs );
DeclareSynonymAttr( "GroupByPcgs", PcGroupWithPcgs );


#############################################################################
##
#A  GroupOfPcgs( <pcgs> )
##
##  <#GAPDoc Label="GroupOfPcgs">
##  <ManSection>
##  <Attr Name="GroupOfPcgs" Arg='pcgs'/>
##
##  <Description>
##  The group generated by <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "GroupOfPcgs",
    IsPcgs );


#############################################################################
##
#A  OneOfPcgs( <pcgs> )
##
##  <#GAPDoc Label="OneOfPcgs">
##  <ManSection>
##  <Attr Name="OneOfPcgs" Arg='pcgs'/>
##
##  <Description>
##  The identity of the group generated by <A>pcgs</A>.
##  <Example><![CDATA[
##  gap> G := Group( (1,2,3,4),(1,2) );; p := Pcgs(G);;
##  gap> RelativeOrders(p);
##  [ 2, 3, 2, 2 ]
##  gap> IsFiniteOrdersPcgs(p);
##  true
##  gap> IsPrimeOrdersPcgs(p);
##  true
##  gap> PcSeries(p);
##  [ Group([ (3,4), (2,4,3), (1,4)(2,3), (1,3)(2,4) ]),
##    Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ]),
##    Group([ (1,4)(2,3), (1,3)(2,4) ]), Group([ (1,3)(2,4) ]), Group(())
##   ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "OneOfPcgs",
    IsPcgs );


#############################################################################
##
#A  PcSeries( <pcgs> )
##
##  <#GAPDoc Label="PcSeries">
##  <ManSection>
##  <Attr Name="PcSeries" Arg='pcgs'/>
##
##  <Description>
##  returns the subnormal series determined by <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PcSeries", IsPcgs );

#############################################################################
##
#P  IsPcgsElementaryAbelianSeries( <pcgs> )
##
##  <#GAPDoc Label="IsPcgsElementaryAbelianSeries">
##  <ManSection>
##  <Prop Name="IsPcgsElementaryAbelianSeries" Arg='pcgs'/>
##
##  <Description>
##  returns <K>true</K> if the pcgs <A>pcgs</A> refines an elementary abelian
##  series.
##  <Ref Attr="IndicesEANormalSteps"/> then gives the indices in the Pcgs,
##  at which the subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsPcgsElementaryAbelianSeries", IsPcgs );

#############################################################################
##
#A  PcgsElementaryAbelianSeries( <G> )
#A  PcgsElementaryAbelianSeries( [<G>,<N1>,<N2>,....])
##
##  <#GAPDoc Label="PcgsElementaryAbelianSeries">
##  <ManSection>
##  <Attr Name="PcgsElementaryAbelianSeries" Arg='G' Label="for a group"/>
##  <Attr Name="PcgsElementaryAbelianSeries" Arg='list'
##   Label="for a list of normal subgroups"/>
##
##  <Description>
##  computes a pcgs for <A>G</A> that refines an elementary abelian series.
##  <Ref Attr="IndicesEANormalSteps"/> gives the indices in the pcgs,
##  at which the normal subgroups of this series start.
##  The second variant returns a pcgs that runs through the normal subgroups
##  in the list <A>list</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PcgsElementaryAbelianSeries", IsGroup );

#############################################################################
##
#A  IndicesEANormalSteps(<pcgs>)
#A  IndicesEANormalStepsBounded(<pcgs>,<bound>)
##
##  <#GAPDoc Label="IndicesEANormalSteps">
##  <ManSection>
##  <Attr Name="IndicesEANormalSteps" Arg='pcgs'/>
##  <Func Name="IndicesEANormalStepsBounded" Arg='pcgs,bound'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a series of normal
##  subgroups with elementary abelian factors (for example from calling
##  <Ref Attr="PcgsElementaryAbelianSeries" Label="for a group"/>)
##  Then <Ref Attr="IndicesEANormalSteps"/> returns a sorted list of
##  integers, indicating the tails of <A>pcgs</A> which generate these normal
##  subgroup of <A>G</A>.
##  If <M>i</M> is an element of this list, <M>(g_i, \ldots, g_n)</M>
##  is a normal subgroup of <A>G</A>.  The list always starts with <M>1</M>
##  and ends with <M>n+1</M>.
##  (These indices form <E>one</E> series with elementary abelian
##  subfactors, not necessarily the most refined one.)
##  <P/>
##  The attribute <Ref Attr="EANormalSeriesByPcgs"/> returns the actual
##  series of subgroups.
##  <P/>
##  For arbitrary pcgs not obtained as belonging to a special series such a
##  set of indices not necessarily exists,
##  and <Ref Attr="IndicesEANormalSteps"/> is not
##  guaranteed to work in this situation.
##  <P/>
##  Typically, <Ref Attr="IndicesEANormalSteps"/> is set by
##  <Ref Attr="PcgsElementaryAbelianSeries" Label="for a group"/>.
##  <P/>
##  The variant <Ref Func="IndicesEANormalStepsBounded"/> will aim to ensure
##  that no factor will be larger than the given bound.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndicesEANormalSteps", IsPcgs );
DeclareGlobalFunction( "IndicesEANormalStepsBounded" );

#############################################################################
##
#A  EANormalSeriesByPcgs(<pcgs>)
##
##  <#GAPDoc Label="EANormalSeriesByPcgs">
##  <ManSection>
##  <Attr Name="EANormalSeriesByPcgs" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a series of normal
##  subgroups with elementary abelian factors (for example from calling
##  <Ref Attr="PcgsElementaryAbelianSeries" Label="for a group"/>).
##  This attribute returns the actual series of normal subgroups,
##  corresponding to <Ref Attr="IndicesEANormalSteps"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("EANormalSeriesByPcgs",IsPcgs);

DeclareGlobalFunction( "BoundedRefinementEANormalSeries" );

#############################################################################
##
#P  IsPcgsCentralSeries( <pcgs> )
##
##  <#GAPDoc Label="IsPcgsCentralSeries">
##  <ManSection>
##  <Prop Name="IsPcgsCentralSeries" Arg='pcgs'/>
##
##  <Description>
##  returns <K>true</K> if the pcgs <A>pcgs</A> refines an central elementary
##  abelian series.
##  <Ref Attr="IndicesCentralNormalSteps"/> then gives the indices in the
##  pcgs, at which the subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsPcgsCentralSeries", IsPcgs );

#############################################################################
##
#A  PcgsCentralSeries( <G> )
##
##  <#GAPDoc Label="PcgsCentralSeries">
##  <ManSection>
##  <Attr Name="PcgsCentralSeries" Arg='G'/>
##
##  <Description>
##  computes a pcgs for <A>G</A> that refines a central elementary abelian
##  series.
##  <Ref Attr="IndicesCentralNormalSteps"/> gives the indices in the pcgs,
##  at which the normal subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PcgsCentralSeries", IsGroup);

#############################################################################
##
#A  IndicesCentralNormalSteps(<pcgs>)
##
##  <#GAPDoc Label="IndicesCentralNormalSteps">
##  <ManSection>
##  <Attr Name="IndicesCentralNormalSteps" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a series of normal
##  subgroups with central elementary abelian factors
##  (for example from calling <Ref Attr="PcgsCentralSeries"/>).
##  Then <Ref Attr="IndicesCentralNormalSteps"/> returns a sorted list of
##  integers, indicating the tails of <A>pcgs</A> which generate these normal
##  subgroups of <A>G</A>.
##  If <M>i</M> is an element of this list, <M>(g_i, \ldots, g_n)</M>
##  is a normal subgroup of <A>G</A>.
##  The list always starts with <M>1</M> and ends with <M>n+1</M>.
##  (These indices form <E>one</E> series with central elementary abelian
##  subfactors, not necessarily the most refined one.)
##  <P/>
##  The attribute <Ref Attr="CentralNormalSeriesByPcgs"/> returns the actual
##  series of subgroups.
##  <P/>
##  For arbitrary pcgs not obtained as belonging to a special series such a
##  set of indices not necessarily exists,
##  and <Ref Attr="IndicesCentralNormalSteps"/>
##  is not guaranteed to work in this situation.
##  <P/>
##  Typically, <Ref Attr="IndicesCentralNormalSteps"/> is set by
##  <Ref Attr="PcgsCentralSeries"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndicesCentralNormalSteps", IsPcgs );

#############################################################################
##
#A  CentralNormalSeriesByPcgs(<pcgs>)
##
##  <#GAPDoc Label="CentralNormalSeriesByPcgs">
##  <ManSection>
##  <Attr Name="CentralNormalSeriesByPcgs" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a series of normal
##  subgroups with central elementary abelian factors (for example from
##  calling <Ref Attr="PcgsCentralSeries"/>).
##  This attribute returns the actual series of normal subgroups,
##  corresponding to <Ref Attr="IndicesCentralNormalSteps"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("CentralNormalSeriesByPcgs",IsPcgs);

#############################################################################
##
#P  IsPcgsPCentralSeriesPGroup( <pcgs> )
##
##  <#GAPDoc Label="IsPcgsPCentralSeriesPGroup">
##  <ManSection>
##  <Prop Name="IsPcgsPCentralSeriesPGroup" Arg='pcgs'/>
##
##  <Description>
##  returns <K>true</K> if the pcgs <A>pcgs</A> refines a <M>p</M>-central
##  elementary abelian series for a <M>p</M>-group.
##  <Ref Attr="IndicesPCentralNormalStepsPGroup"/> then gives the indices in
##  the pcgs, at which the subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsPcgsPCentralSeriesPGroup", IsPcgs );

#############################################################################
##
#A  PcgsPCentralSeriesPGroup( <G> )
##
##  <#GAPDoc Label="PcgsPCentralSeriesPGroup">
##  <ManSection>
##  <Attr Name="PcgsPCentralSeriesPGroup" Arg='G'/>
##
##  <Description>
##  computes a pcgs for the <M>p</M>-group <A>G</A> that refines a
##  <M>p</M>-central elementary abelian series.
##  <Ref Attr="IndicesPCentralNormalStepsPGroup"/> gives the
##  indices in the pcgs, at which the normal subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PcgsPCentralSeriesPGroup", IsGroup);

#############################################################################
##
#A  IndicesPCentralNormalStepsPGroup(<pcgs>)
##
##  <#GAPDoc Label="IndicesPCentralNormalStepsPGroup">
##  <ManSection>
##  <Attr Name="IndicesPCentralNormalStepsPGroup" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a series of normal
##  subgroups with <M>p</M>-central elementary abelian factors
##  (for example from calling <Ref Attr="PcgsPCentralSeriesPGroup"/>).
##  Then <Ref Attr="IndicesPCentralNormalStepsPGroup"/> returns a sorted list
##  of integers, indicating the tails of <A>pcgs</A> which generate these
##  normal subgroups of <A>G</A>.
##  If <M>i</M> is an element of this list, <M>(g_i, \ldots, g_n)</M>
##  is a normal subgroup of <A>G</A>.
##  The list always starts with <M>1</M> and ends with <M>n+1</M>.
##  (These indices form <E>one</E> series with central elementary abelian
##  subfactors, not necessarily the most refined one.)
##  <P/>
##  The attribute <Ref Attr="PCentralNormalSeriesByPcgsPGroup"/> returns the
##  actual series of subgroups.
##  <P/>
##  For arbitrary pcgs not obtained as belonging to a special series such a
##  set of indices not necessarily exists, and
##  <Ref Attr="IndicesPCentralNormalStepsPGroup"/>
##  is not guaranteed to work in this situation.
##  <P/>
##  Typically, <Ref Attr="IndicesPCentralNormalStepsPGroup"/> is set by
##  <Ref Attr="PcgsPCentralSeriesPGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndicesPCentralNormalStepsPGroup", IsPcgs );

#############################################################################
##
#A  PCentralNormalSeriesByPcgsPGroup(<pcgs>)
##
##  <#GAPDoc Label="PCentralNormalSeriesByPcgsPGroup">
##  <ManSection>
##  <Attr Name="PCentralNormalSeriesByPcgsPGroup" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a series of normal
##  subgroups with <M>p</M>-central elementary abelian factors
##  (for example from calling <Ref Attr="PcgsPCentralSeriesPGroup"/>).
##  This attribute returns the actual series of normal subgroups,
##  corresponding to <Ref Attr="IndicesPCentralNormalStepsPGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("PCentralNormalSeriesByPcgsPGroup",IsPcgs);

#############################################################################
##
#P  IsPcgsChiefSeries( <pcgs> )
##
##  <#GAPDoc Label="IsPcgsChiefSeries">
##  <ManSection>
##  <Prop Name="IsPcgsChiefSeries" Arg='pcgs'/>
##
##  <Description>
##  returns <K>true</K> if the pcgs <A>pcgs</A> refines a chief series.
##  <Ref Attr="IndicesChiefNormalSteps"/> then gives the indices in the pcgs,
##  at which the subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsPcgsChiefSeries", IsPcgs );

#############################################################################
##
#A  PcgsChiefSeries( <G> )
##
##  <#GAPDoc Label="PcgsChiefSeries">
##  <ManSection>
##  <Attr Name="PcgsChiefSeries" Arg='G'/>
##
##  <Description>
##  computes a pcgs for <A>G</A> that refines a chief series.
##  <Ref Attr="IndicesChiefNormalSteps"/> gives the indices in the pcgs,
##  at which the normal subgroups of this series start.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PcgsChiefSeries", IsGroup );

#############################################################################
##
#A  IndicesChiefNormalSteps(<pcgs>)
##
##  <#GAPDoc Label="IndicesChiefNormalSteps">
##  <ManSection>
##  <Attr Name="IndicesChiefNormalSteps" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a chief series
##  for example from calling <Ref Attr="PcgsChiefSeries"/>).
##  Then <Ref Attr="IndicesChiefNormalSteps"/> returns a sorted list of
##  integers, indicating the tails of <A>pcgs</A> which generate these normal
##  subgroups of <A>G</A>.
##  If <M>i</M> is an element of this list, <M>(g_i, \ldots, g_n)</M>
##  is a normal subgroup of <A>G</A>.
##  The list always starts with <M>1</M> and ends with <M>n+1</M>.
##  (These indices form <E>one</E> series with elementary abelian
##  subfactors, not necessarily the most refined one.)
##  <P/>
##  The attribute <Ref Attr="ChiefNormalSeriesByPcgs"/> returns the actual
##  series of subgroups.
##  <P/>
##  For arbitrary pcgs not obtained as belonging to a special series such a
##  set of indices not necessarily exists,
##  and <Ref Attr="IndicesChiefNormalSteps"/> is not
##  guaranteed to work in this situation.
##  <P/>
##  Typically, <Ref Attr="IndicesChiefNormalSteps"/> is set by
##  <Ref Attr="PcgsChiefSeries"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndicesChiefNormalSteps", IsPcgs );

#############################################################################
##
#A  ChiefNormalSeriesByPcgs(<pcgs>)
##
##  <#GAPDoc Label="ChiefNormalSeriesByPcgs">
##  <ManSection>
##  <Attr Name="ChiefNormalSeriesByPcgs" Arg='pcgs'/>
##
##  <Description>
##  Let <A>pcgs</A> be a pcgs obtained as corresponding to a chief series
##  (for example from calling
##  <Ref Attr="PcgsChiefSeries"/>). This attribute returns the actual series
##  of normal subgroups,
##  corresponding to <Ref Attr="IndicesChiefNormalSteps"/>.
##
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> p:=PcgsElementaryAbelianSeries(g);
##  Pcgs([ (3,4), (2,4,3), (1,4)(2,3), (1,3)(2,4) ])
##  gap> IndicesEANormalSteps(p);
##  [ 1, 2, 3, 5 ]
##  gap> g:=Group((1,2,3,4),(1,5)(2,6)(3,7)(4,8));;
##  gap> p:=PcgsCentralSeries(g);
##  Pcgs([ (1,5)(2,6)(3,7)(4,8), (5,6,7,8), (5,7)(6,8),
##    (1,4,3,2)(5,6,7,8), (1,3)(2,4)(5,7)(6,8) ])
##  gap> IndicesCentralNormalSteps(p);
##  [ 1, 2, 4, 5, 6 ]
##  gap> q:=PcgsPCentralSeriesPGroup(g);
##  Pcgs([ (1,5)(2,6)(3,7)(4,8), (5,6,7,8), (5,7)(6,8),
##    (1,4,3,2)(5,6,7,8), (1,3)(2,4)(5,7)(6,8) ])
##  gap> IndicesPCentralNormalStepsPGroup(q);
##  [ 1, 3, 5, 6 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ChiefNormalSeriesByPcgs",IsPcgs);

#############################################################################
##
#A  IndicesNormalSteps( <pcgs> )
##
##  <#GAPDoc Label="IndicesNormalSteps">
##  <ManSection>
##  <Attr Name="IndicesNormalSteps" Arg='pcgs'/>
##
##  <Description>
##  returns the indices of <E>all</E> steps in the pc series,
##  which are normal in the group defined by the pcgs.
##  <P/>
##  (In general, this function yields a slower performance than the more
##  specialized index functions for elementary abelian series etc.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndicesNormalSteps", IsPcgs );

#############################################################################
##
#A  NormalSeriesByPcgs( <pcgs> )
##
##  <#GAPDoc Label="NormalSeriesByPcgs">
##  <ManSection>
##  <Attr Name="NormalSeriesByPcgs" Arg='pcgs'/>
##
##  <Description>
##  returns the subgroups the pc series, which are normal in
##  the group defined by the pcgs.
##  <P/>
##  (In general, this function yields a slower performance than the more
##  specialized index functions for elementary abelian series etc.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NormalSeriesByPcgs", IsPcgs);

#############################################################################
##
#P  IsPrimeOrdersPcgs( <pcgs> )
##
##  <#GAPDoc Label="IsPrimeOrdersPcgs">
##  <ManSection>
##  <Prop Name="IsPrimeOrdersPcgs" Arg='pcgs'/>
##
##  <Description>
##  tests whether the relative orders of <A>pcgs</A> are prime numbers.
##  Many algorithms require a pcgs to have this property.
##  The operation&nbsp;<Ref Attr="IsomorphismRefinedPcGroup"/>
##  can be of help here.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPrimeOrdersPcgs", IsGeneralPcgs );
InstallTrueMethod( IsGeneralPcgs, IsPrimeOrdersPcgs );

#############################################################################
##
#P  IsFiniteOrdersPcgs( <pcgs> )
##
##  <#GAPDoc Label="IsFiniteOrdersPcgs">
##  <ManSection>
##  <Prop Name="IsFiniteOrdersPcgs" Arg='pcgs'/>
##
##  <Description>
##  tests whether the relative orders of <A>pcgs</A> are all finite.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFiniteOrdersPcgs", IsGeneralPcgs );
InstallTrueMethod( IsGeneralPcgs, IsFiniteOrdersPcgs );

#############################################################################
##
#A  RefinedPcGroup( <G> )
##
##  <#GAPDoc Label="RefinedPcGroup">
##  <ManSection>
##  <Attr Name="RefinedPcGroup" Arg='G'/>
##
##  <Description>
##  returns the range of the <Ref Attr="IsomorphismRefinedPcGroup"/> value of
##  <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RefinedPcGroup", IsPcGroup );

#############################################################################
##
#A  IsomorphismRefinedPcGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismRefinedPcGroup">
##  <ManSection>
##  <Attr Name="IsomorphismRefinedPcGroup" Arg='G'/>
##
##  <Description>
##  <Index Subkey="pc group">isomorphic</Index>
##  returns an isomorphism from <A>G</A> onto an isomorphic pc group
##  whose family pcgs is a prime order pcgs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismRefinedPcGroup", IsGroup );

#############################################################################
##
#A  RelativeOrders( <pcgs> )
##
##  <#GAPDoc Label="RelativeOrders:pcgs">
##  <ManSection>
##  <Attr Name="RelativeOrders" Arg='pcgs'/>
##
##  <Description>
##  <Index Subkey="of a pcgs" Key="RelativeOrders">
##  <C>RelativeOrders</C></Index>
##  returns the list of relative orders of the pcgs <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RelativeOrders", IsGeneralPcgs );

#############################################################################
##
#O  DepthOfPcElement( <pcgs>, <elm> )
##
##  <#GAPDoc Label="DepthOfPcElement">
##  <ManSection>
##  <Oper Name="DepthOfPcElement" Arg='pcgs, elm'/>
##
##  <Description>
##  returns the depth of the element <A>elm</A> with respect to <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DepthOfPcElement", [ IsModuloPcgs, IsObject ] );

#############################################################################
##
#O  DifferenceOfPcElement( <pcgs>, <left>, <right> )
##
##  <ManSection>
##  <Oper Name="DifferenceOfPcElement" Arg='pcgs, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "DifferenceOfPcElement", [ IsPcgs, IsObject, IsObject ] );

#############################################################################
##
#O  ExponentOfPcElement( <pcgs>, <elm>, <pos> )
##
##  <#GAPDoc Label="ExponentOfPcElement">
##  <ManSection>
##  <Oper Name="ExponentOfPcElement" Arg='pcgs, elm, pos'/>
##
##  <Description>
##  returns the <A>pos</A>-th exponent of <A>elm</A> with respect to
##  <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentOfPcElement",
                  [ IsModuloPcgs, IsObject, IsPosInt ] );

#############################################################################
##
#O  ExponentsOfPcElement( <pcgs>, <elm>[, <posran>] )
##
##  <#GAPDoc Label="ExponentsOfPcElement">
##  <ManSection>
##  <Oper Name="ExponentsOfPcElement" Arg='pcgs, elm[, posran]'/>
##
##  <Description>
##  returns the exponents of <A>elm</A> with respect to <A>pcgs</A>.
##  The three argument version returns the exponents in the positions
##  given in <A>posran</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentsOfPcElement",
    [ IsModuloPcgs, IsObject ] );

#############################################################################
##
#O  ExponentsOfConjugate( <pcgs>, <i>, <j> )
##
##  <#GAPDoc Label="ExponentsOfConjugate">
##  <ManSection>
##  <Oper Name="ExponentsOfConjugate" Arg='pcgs, i, j'/>
##
##  <Description>
##  returns the exponents of
##  <C><A>pcgs</A>[<A>i</A>]^<A>pcgs</A>[<A>j</A>]</C> with respect to
##  <A>pcgs</A>. For the family pcgs or pcgs induced by it (see section
##  <Ref Sect="Subgroups of Polycyclic Groups - Induced Pcgs"/>), this
##  might be faster than computing the element and computing its exponent
##  vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentsOfConjugate",
    [ IsModuloPcgs, IsPosInt,IsPosInt ] );

#############################################################################
##
#O  ExponentsOfRelativePower( <pcgs>, <i> )
##
##  <#GAPDoc Label="ExponentsOfRelativePower">
##  <ManSection>
##  <Oper Name="ExponentsOfRelativePower" Arg='pcgs, i'/>
##
##  <Description>
##  For <M>p = <A>pcgs</A>[<A>i</A>]</M> this function returns the
##  exponent vector with respect to <A>pcgs</A> of the element <M>p^e</M>
##  where <M>e</M> is the relative order of <A>p</A> in <A>pcgs</A>.
##  For the family pcgs or pcgs induced by it (see section
##  <Ref Sect="Subgroups of Polycyclic Groups - Induced Pcgs"/>), this
##  might be faster than computing the element and computing its exponent
##  vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentsOfRelativePower",
    [ IsModuloPcgs, IsPosInt ] );

#############################################################################
##
#O  ExponentsOfCommutator( <pcgs>, <i>, <j> )
##
##  <#GAPDoc Label="ExponentsOfCommutator">
##  <ManSection>
##  <Oper Name="ExponentsOfCommutator" Arg='pcgs, i, j'/>
##
##  <Description>
##  returns the exponents of the commutator
##  <C>Comm( </C><M><A>pcgs</A>[<A>i</A>], <A>pcgs</A>[<A>j</A>]</M><C> )</C>
##  with respect to <A>pcgs</A>. For the family pcgs or pcgs induced by it,
##  (see section <Ref Sect="Subgroups of Polycyclic Groups - Induced Pcgs"/>),
##  this might be faster than computing the element and computing its
##  exponent vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentsOfCommutator",
    [ IsModuloPcgs, IsPosInt,IsPosInt ] );


#############################################################################
##
#O  LeadingExponentOfPcElement( <pcgs>, <elm> )
##
##  <#GAPDoc Label="LeadingExponentOfPcElement">
##  <ManSection>
##  <Oper Name="LeadingExponentOfPcElement" Arg='pcgs, elm'/>
##
##  <Description>
##  returns the leading exponent of <A>elm</A> with respect to <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeadingExponentOfPcElement",
    [ IsModuloPcgs, IsObject ] );

#############################################################################
##
#O  DepthAndLeadingExponentOfPcElement( <pcgs>, <elm> )
##
##  <#GAPDoc Label="DepthAndLeadingExponentOfPcElement">
##  <ManSection>
##  <Oper Name="DepthAndLeadingExponentOfPcElement" Arg='pcgs, elm'/>
##
##  <Description>
##  returns a list containing the depth of <A>elm</A> and the leading
##  exponent of <A>elm</A> with respect to <A>pcgs</A>. (This is sometimes
##  faster than asking separately.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DepthAndLeadingExponentOfPcElement",
    [ IsModuloPcgs, IsObject ] );


#############################################################################
##
#O  PcElementByExponents( <pcgs>, <list> )
#O  PcElementByExponentsNC( <pcgs>[, <basisind>], <list> )
##
##  <#GAPDoc Label="PcElementByExponents">
##  <ManSection>
##  <Func Name="PcElementByExponents" Arg='pcgs, list'/>
##  <Oper Name="PcElementByExponentsNC" Arg='pcgs[, basisind], list'/>
##
##  <Description>
##  returns the element corresponding to the exponent vector <A>list</A>
##  with respect to <A>pcgs</A>.
##  The exponents in <A>list</A> must be in the range of permissible
##  exponents for <A>pcgs</A>.
##  <E>It is not guaranteed that <Ref Func="PcElementByExponents"/> will
##  reduce the exponents modulo the relative orders</E>.
##  (You should use the operation <Ref Func="LinearCombinationPcgs"/>
##  for this purpose.)
##  The <C>NC</C> version does not check that the lengths of the lists
##  fit together and does not check the exponent range.
##  <P/>
##  The three argument version gives exponents only w.r.t. the generators
##  in <A>pcgs</A> indexed by <A>basisind</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PcElementByExponents");
DeclareOperation( "PcElementByExponentsNC",
    [ IsModuloPcgs, IsList ] );

#############################################################################
##
#O  LinearCombinationPcgs( <pcgs>, <list>[, <one>] )
##
##  <#GAPDoc Label="LinearCombinationPcgs">
##  <ManSection>
##  <Func Name="LinearCombinationPcgs" Arg='pcgs, list[, one]'/>
##
##  <Description>
##  returns the product <M>\prod_i <A>pcgs</A>[i]^{{<A>list</A>[i]}}</M>.
##  In contrast to <Ref Func="PcElementByExponents"/> this permits negative
##  exponents.
##  <A>pcgs</A> might be a list of group elements.
##  In this case, an appropriate identity element
##  <A>one</A> must be given.
##  <A>list</A> can be empty.
##  <Example><![CDATA[
##  gap> G := Group( (1,2,3,4),(1,2) );; P := Pcgs(G);;
##  gap> g := PcElementByExponents(P, [0,1,1,1]);
##  (1,2,3)
##  gap> ExponentsOfPcElement(P, g);
##  [ 0, 1, 1, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("LinearCombinationPcgs");

#############################################################################
##
#F  PowerPcgsElement( <pcgs>, <i>, <exp> )
##
##  <ManSection>
##  <Func Name="PowerPcgsElement" Arg='pcgs, i, exp'/>
##
##  <Description>
##  returns the power <C><A>pcgs</A>[<A>i</A>]^<A>exp</A></C>.
##  <A>exp</A> may be negative.
##  The function caches the results which can be advantageous in particular
##  if the pcgs is not family.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("PowerPcgsElement");

#############################################################################
##
#F  LeftQuotientPowerPcgsElement( <pcgs>, <i>, <exp>, <elm> )
##
##  <ManSection>
##  <Func Name="LeftQuotientPowerPcgsElement" Arg='pcgs, i, exp, elm'/>
##
##  <Description>
##  returns the left quotient of <A>elm</A> by the power
##  <C><A>pcgs</A>[<A>i</A>]^<A>exp</A></C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("LeftQuotientPowerPcgsElement");


#############################################################################
##
#O  SumOfPcElement( <pcgs>, <left>, <right> )
##
##  <ManSection>
##  <Oper Name="SumOfPcElement" Arg='pcgs, left, right'/>
##
##  <Description>
##  returns the element in the span of <A>pcgs</A> whose coefficients are
##  the sums of the coefficients of <A>left</A> and <A>right</A>
##  with respect to <A>pcgs</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "SumOfPcElement",
    [ IsModuloPcgs, IsObject, IsObject ] );

#############################################################################
##
#O  ReducedPcElement( <pcgs>, <x>, <y> )
##
##  <#GAPDoc Label="ReducedPcElement">
##  <ManSection>
##  <Oper Name="ReducedPcElement" Arg='pcgs, x, y'/>
##
##  <Description>
##  reduces the element <A>x</A> by dividing off (from the left) a power of
##  <A>y</A> such that the leading coefficient of the result with respect to
##  <A>pcgs</A> becomes zero.
##  The elements <A>x</A> and <A>y</A> therefore have to have the same depth.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ReducedPcElement", [ IsModuloPcgs, IsObject, IsObject ] );


#############################################################################
##
#O  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
##  <#GAPDoc Label="RelativeOrderOfPcElement">
##  <ManSection>
##  <Oper Name="RelativeOrderOfPcElement" Arg='pcgs, elm'/>
##
##  <Description>
##  The relative order of <A>elm</A> with respect to the prime order pcgs
##  <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "RelativeOrderOfPcElement",
    [ IsModuloPcgs, IsObject ] );


#############################################################################
##
#O  HeadPcElementByNumber( <pcgs>, <elm>, <dep> )
##
##  <#GAPDoc Label="HeadPcElementByNumber">
##  <ManSection>
##  <Oper Name="HeadPcElementByNumber" Arg='pcgs, elm, dep'/>
##
##  <Description>
##  returns an element in the span of <A>pcgs</A> whose exponents for indices
##  <M>1</M> to <A>dep</A><M>-1</M> with respect to <A>pcgs</A> are the same
##  as those of <A>elm</A>, the remaining exponents are zero.
##  This can be used to obtain more
##  <Q>simple</Q> elements if only representatives in a factor are required.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "HeadPcElementByNumber",
    [ IsModuloPcgs, IsObject, IsInt ] );

#############################################################################
##
#O  CleanedTailPcElement( <pcgs>, <elm>, <dep> )
##
##  <#GAPDoc Label="CleanedTailPcElement">
##  <ManSection>
##  <Oper Name="CleanedTailPcElement" Arg='pcgs, elm, dep'/>
##
##  <Description>
##  returns an element in the span of <A>pcgs</A> whose exponents for indices
##  <M>1</M> to <M><A>dep</A>-1</M> with respect to <A>pcgs</A> are the same
##  as those of <A>elm</A>, the remaining exponents are undefined.
##  This can be used to obtain more
##  <Q>simple</Q> elements if only representatives in a factor are required,
##  see&nbsp;<Ref Sect="Factor Groups of Polycyclic Groups - Modulo Pcgs"/>.
##  <P/>
##  The difference to <Ref Oper="HeadPcElementByNumber"/>
##  is that this function is guaranteed to zero out trailing
##  coefficients while <Ref Oper="CleanedTailPcElement"/> will only do this
##  if it can be done cheaply.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CleanedTailPcElement",
    [ IsModuloPcgs, IsObject, IsInt ] );


#############################################################################
##
#O  ExtendedIntersectionSumPcgs( <parent-pcgs>, <n>, <u>, <modpcgs> )
##
##  <ManSection>
##  <Oper Name="ExtendedIntersectionSumPcgs"
##   Arg='parent-pcgs, n, u, modpcgs'/>
##
##  <Description>
##  <E>@ The specification of this function is not clear. Do not use (or
##  document this function properly before using it</E>@.
##  The function returns a record whose entries are <E>not</E> pcgs but only
##  lists of pc elements (to avoid unnecessary creation of InducedPcgs)
##  If <A>modpcgs</A> is a tail if the <A>parent-pcgs</A>
##  it is sufficient to give the starting depth,
##  </Description>
##  </ManSection>
##
DeclareOperation( "ExtendedIntersectionSumPcgs",
    [ IsModuloPcgs, IsList, IsList, IsObject ] );


#############################################################################
##
#O  IntersectionSumPcgs( <parent-pcgs>, <n>, <u> )
##
##  <ManSection>
##  <Oper Name="IntersectionSumPcgs" Arg='parent-pcgs, n, u'/>
##
##  <Description>
##  <E>@ The specification of this function is not clear. Do not use (or
##  document this function properly before using it</E>@.
##  </Description>
##  </ManSection>
##
DeclareOperation( "IntersectionSumPcgs", [ IsModuloPcgs, IsList, IsList ] );


#############################################################################
##
#O  NormalIntersectionPcgs( <parent-pcgs>, <n>, <u> )
##
##  <ManSection>
##  <Oper Name="NormalIntersectionPcgs" Arg='parent-pcgs, n, u'/>
##
##  <Description>
##  <E>@ The specification of this function is not clear. Do not use (or
##  document this function properly before using it</E>@.
##  </Description>
##  </ManSection>
##
DeclareOperation( "NormalIntersectionPcgs", [ IsModuloPcgs, IsList, IsList ] );


#############################################################################
##
#O  SumPcgs( <parent-pcgs>, <n>, <u> )
##
##  <ManSection>
##  <Oper Name="SumPcgs" Arg='parent-pcgs, n, u'/>
##
##  <Description>
##  <E>@ The specification of this function is not clear. Do not use (or
##  document this function properly before using it</E>@.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SumPcgs", [ IsModuloPcgs, IsList, IsList ] );


#############################################################################
##
#O  SumFactorizationFunctionPcgs( <parentpcgs>, <n>, <u>, <kerpcgs> )
##
##  <#GAPDoc Label="SumFactorizationFunctionPcgs">
##  <ManSection>
##  <Oper Name="SumFactorizationFunctionPcgs"
##   Arg='parentpcgs, n, u, kerpcgs'/>
##
##  <Description>
##  computes the sum and intersection of the lists <A>n</A> and <A>u</A> whose
##  elements form modulo pcgs induced by <A>parentpcgs</A> for two subgroups
##  modulo a kernel given by <A>kerpcgs</A>.
##  If <A>kerpcgs</A> is a tail if the <A>parent-pcgs</A> it is sufficient
##  to give the starting depth,
##  this can be more efficient than to construct an explicit pcgs.
##  The factor group modulo <A>kerpcgs</A> generated by <A>n</A> must be
##  elementary abelian and normal under <A>u</A>.
##  <P/>
##  The function returns a record with components
##  <List>
##  <Mark><C>sum</C></Mark>
##  <Item>
##    elements that form a modulo pcgs for the span of both subgroups.
##  </Item>
##  <Mark><C>intersection</C></Mark>
##  <Item>
##    elements that form a modulo pcgs for the intersection of
##    both subgroups.
##  </Item>
##  <Mark><C>factorization</C></Mark>
##  <Item>
##    a function that returns for an element <A>x</A> in the span
##    of <C>sum</C> a record with components <C>u</C> and <C>n</C>
##    that give its decomposition.
##  </Item>
##  </List>
##  <P/>
##  The record components <C>sum</C> and <C>intersection</C> are <E>not</E>
##  pcgs but only lists of pc elements (to avoid unnecessary creation of
##  induced pcgs).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "SumFactorizationFunctionPcgs",
    [ IsModuloPcgs, IsList, IsList, IsObject ] );


#############################################################################
##
#F  EnumeratorByPcgs( <pcgs>, <poss> )
##
##  <ManSection>
##  <Func Name="EnumeratorByPcgs" Arg='pcgs, poss'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "EnumeratorByPcgs",
    [ IsModuloPcgs ] );


#############################################################################
##
#O  ExtendedPcgs( <N>, <gens> )
##
##  <#GAPDoc Label="ExtendedPcgs">
##  <ManSection>
##  <Oper Name="ExtendedPcgs" Arg='N, gens'/>
##
##  <Description>
##  extends the pcgs <A>N</A> (induced w.r.t. <A>home</A>) to a new
##  induced pcgs by prepending <A>gens</A>.
##  No checks are performed that this really yields an induced pcgs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExtendedPcgs", [ IsModuloPcgs, IsList ] );


#############################################################################
##
#F  PcgsByIndependentGeneratorsOfAbelianGroup( <A> )
##
##  <ManSection>
##  <Func Name="PcgsByIndependentGeneratorsOfAbelianGroup" Arg='A'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PcgsByIndependentGeneratorsOfAbelianGroup" );

#############################################################################
##
#F  Pcgs_OrbitStabilizer( <pcgs>,<domain>,<pnt>,<oprs>,<opr> )
##
##  <#GAPDoc Label="Pcgs_OrbitStabilizer:pcgs">
##  <ManSection>
##  <Func Name="Pcgs_OrbitStabilizer" Arg='pcgs,domain,pnt,oprs,opr'/>
##
##  <Description>
##  runs a solvable group orbit-stabilizer algorithm on <A>pnt</A> with
##  <A>pcgs</A> acting via the images <A>oprs</A> and the operation function
##  <A>opr</A>.
##  The domain <A>domain</A> can be used to speed up search,
##  if it is not known, <K>false</K> can be given instead.
##  The function
##  returns a record with components <C>orbit</C>, <C>stabpcgs</C> and
##  <C>lengths</C>, the
##  latter indicating the lengths of the orbit whenever it got extended.
##  This can be used to recompute transversal elements.
##  This function should be used only inside algorithms when speed is
##  essential.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Pcgs_OrbitStabilizer" );
DeclareGlobalFunction( "Pcs_OrbitStabilizer" );
DeclareGlobalFunction( "Pcgs_OrbitStabilizer_Blist" );

##  <#GAPDoc Label="[1]{pcgs}">
##  The following functions are intended for working with factor groups
##  obtained by factoring out the tail of a pcgs.
##  They provide a way to map elements or induced pcgs quickly in the factor
##  (respectively to take preimages) without the need to construct a
##  homomorphism.
##  <P/>
##  The setup is always a pcgs <A>pcgs</A> of <A>G</A> and a pcgs
##  <A>fpcgs</A> of a factor group <M>H = <A>G</A>/<A>N</A></M>
##  which corresponds to a head of <A>pcgs</A>.
##  <P/>
##  No tests for validity of the input are performed.
##  <#/GAPDoc>
##

#############################################################################
##
#F  LiftedPcElement( <pcgs>, <fpcgs>, <elm> )
##
##  <#GAPDoc Label="LiftedPcElement">
##  <ManSection>
##  <Func Name="LiftedPcElement" Arg='pcgs, fpcgs, elm'/>
##
##  <Description>
##  returns a preimage in <A>G</A> of an element <A>elm</A> of <A>H</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LiftedPcElement" );

#############################################################################
##
#F  ProjectedPcElement( <pcgs>, <fpcgs>, <elm> )
##
##  <#GAPDoc Label="ProjectedPcElement">
##  <ManSection>
##  <Func Name="ProjectedPcElement" Arg='pcgs, fpcgs, elm'/>
##
##  <Description>
##  returns the image in <A>H</A> of an element <A>elm</A> of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ProjectedPcElement" );

#############################################################################
##
#F  ProjectedInducedPcgs( <pcgs>, <fpcgs>, <ipcgs> )
##
##  <#GAPDoc Label="ProjectedInducedPcgs">
##  <ManSection>
##  <Func Name="ProjectedInducedPcgs" Arg='pcgs, fpcgs, ipcgs'/>
##
##  <Description>
##  <A>ipcgs</A> must be an induced pcgs with respect to <A>pcgs</A>.
##  This operation returns an induced pcgs with respect to <A>fpcgs</A>
##  consisting of the nontrivial images of <A>ipcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ProjectedInducedPcgs" );

#############################################################################
##
#F  LiftedInducedPcgs( <pcgs>, <fpcgs>, <ipcgs>, <ker> )
##
##  <#GAPDoc Label="LiftedInducedPcgs">
##  <ManSection>
##  <Func Name="LiftedInducedPcgs" Arg='pcgs, fpcgs, ipcgs, ker'/>
##
##  <Description>
##  <A>ipcgs</A> must be an induced pcgs with respect to <A>fpcgs</A>.
##  This operation returns an induced pcgs with respect to <A>pcgs</A>
##  consisting of the preimages of <A>ipcgs</A>,
##  appended by the elements in <A>ker</A> (assuming
##  there is a bijection of <A>pcgs</A> mod <A>ker</A> to <A>fpcgs</A>).
##  <A>ker</A> might be a simple element list.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LiftedInducedPcgs" );


#############################################################################
##
#F  PcgsByPcgs( <pcgs>, <decomp>, <family>, <images> )
##
##  <#GAPDoc Label="PcgsByPcgs">
##  <ManSection>
##  <Func Name="PcgsByPcgs" Arg='pcgs, decomp, family, images'/>
##
##  <Description>
##  Constructs a pcgs that will use another pcgs (via an isomorphism pc
##  group) to determine exponents. The assumption is that exponents will be
##  so expensive that a pc group collection is of neglegible cost.
##  <A>pcgs</A> is the list of pc elements
##  desired. <A>decomp</A> is another pcgs with respect to which we can
##  compute exponents. It corresponds to the family pcgs <A>family</A> of an
##  isomorphic pc group. In this pc group <A>images</A> are the images of
##  <A>pcgs</A>. Exponents will be computed by forming exponents with
##  respect to <A>decomp</A>, forming the image in the pc group, and then
##  computing exponents of this image by <A>images</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PcgsByPcgs" );
