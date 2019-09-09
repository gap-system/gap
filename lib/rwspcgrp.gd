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
##  This file   contains the operations  for groups   defined by a polycyclic
##  collector.
##


#############################################################################
##
#C  IsElementFinitePolycyclicGroup
#C  IsElementFinitePolycyclicGroupCollection
##
##  <ManSection>
##  <Filt Name="IsElementFinitePolycyclicGroup" Arg='obj' Type='Category'/>
##  <Filt Name="IsElementFinitePolycyclicGroupCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  This category is set if the group defining a family of polycyclic
##  elements is finite. It is used to impliy finiteness for groups generated
##  by elements in this family.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsElementFinitePolycyclicGroup",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );
DeclareCategoryCollections( "IsElementFinitePolycyclicGroup");

InstallTrueMethod(IsSubsetLocallyFiniteGroup,
  IsElementFinitePolycyclicGroupCollection);


#############################################################################
##
#C  IsMultiplicativeElementWithInverseByPolycyclicCollector
##
##  <ManSection>
##  <Filt Name="IsMultiplicativeElementWithInverseByPolycyclicCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector",
    IsMultiplicativeElementWithInverseByRws and IsAssociativeElement );

DeclareCategoryCollections(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector" );


#############################################################################
##
#C  IsPcGroup( <G> )
##
##  <#GAPDoc Label="IsPcGroup">
##  <ManSection>
##  <Filt Name="IsPcGroup" Arg='G' Type='Category'/>
##
##  <Description>
##  tests whether <A>G</A> is a pc group.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 24, 12 );
##  <pc group of size 24 with 4 generators>
##  gap> IsPcGroup( G );
##  true
##  gap> IsFpGroup( G );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsPcGroup",
    IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection
    and IsGroup );


#############################################################################
##
#A  DefiningPcgs( <obj> )
##
##  <ManSection>
##  <Attr Name="DefiningPcgs" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute(
    "DefiningPcgs",
    IsObject );

#############################################################################
##
#F  IsKernelPcWord(obj)
##
##  <ManSection>
##  <Func Name="IsKernelPcWord" Arg='obj'/>
##
##  <Description>
##  This filter is implied by the kernel pc words. It is used solely to
##  increase the rank of the pc words representation (NewRepresenattion does
##  not admit a rank other than 1).
##  </Description>
##  </ManSection>
##
DeclareFilter("IsKernelPcWord",100);


#############################################################################
##
#C  IsElementsFamilyBy8BitsSingleCollector
##
##  <ManSection>
##  <Filt Name="IsElementsFamilyBy8BitsSingleCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsElementsFamilyBy8BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#C  IsElementsFamilyBy16BitsSingleCollector
##
##  <ManSection>
##  <Filt Name="IsElementsFamilyBy16BitsSingleCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsElementsFamilyBy16BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#C  IsElementsFamilyBy32BitsSingleCollector
##
##  <ManSection>
##  <Filt Name="IsElementsFamilyBy32BitsSingleCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsElementsFamilyBy32BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#O  PolycyclicFactorGroup( <fgrp>, <rels> )
#O  PolycyclicFactorGroupNC( <fgrp>, <rels> )
##
##  <ManSection>
##  <Oper Name="PolycyclicFactorGroup" Arg='fgrp, rels'/>
##  <Oper Name="PolycyclicFactorGroupNC" Arg='fgrp, rels'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "PolycyclicFactorGroup",
    [ IsObject, IsList ] );

DeclareOperation(
    "PolycyclicFactorGroupNC",
    [ IsObject, IsList ] );


#############################################################################
##
#O  PolycyclicFactorGroupByRelators( <fam>, <gens>, <rels> )
##
##  <ManSection>
##  <Oper Name="PolycyclicFactorGroupByRelators" Arg='fam, gens, rels'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SingleCollectorByRelators" );

DeclareOperation(
    "PolycyclicFactorGroupByRelatorsNC",
    [ IsFamily, IsList, IsList ] );

DeclareOperation(
    "PolycyclicFactorGroupByRelators",
    [ IsFamily, IsList, IsList ] );
