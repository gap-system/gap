#############################################################################
##
#W  rwspcgrp.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file   contains the operations  for groups   defined by a polycyclic
##  collector.
##
Revision.rwspcgrp_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsElementFinitePolycyclicGroup
#C  IsElementFinitePolycyclicGroupCollection
##
##  This category is set if the group defining a family of polycyclic
##  elements is finite. It is used to impliy finiteness for groups generated
##  by elements in this family.
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
DeclareCategory(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector",
    IsMultiplicativeElementWithInverseByRws and IsAssociativeElement );

DeclareCategoryCollections(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector" );


#############################################################################
##
#C  IsPcGroup( <G> )
##
##  tests whether <G> is a pc group.
DeclareSynonym( "IsPcGroup",
    IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection
    and IsGroup );


#############################################################################
##
#A  DefiningPcgs( <obj> )
##
DeclareAttribute(
    "DefiningPcgs",
    IsObject );

#############################################################################
##
#F  IsKernelPcWord(obj)
##
##  This filter is implied by the kernel pc words. It is used solely to
##  increase the rank of the pc words representation (NewRepresenattion does
##  not admit a rank other than 1).
DeclareFilter("IsKernelPcWord",100);


#############################################################################
##
#C  IsElementsFamilyBy8BitsSingleCollector
##
DeclareCategory(
    "IsElementsFamilyBy8BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#C  IsElementsFamilyBy16BitsSingleCollector
##
DeclareCategory(
    "IsElementsFamilyBy16BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#C  IsElementsFamilyBy32BitsSingleCollector
##
DeclareCategory(
    "IsElementsFamilyBy32BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#O  PolycyclicFactorGroup( <fgrp>, <rels> )
#O  PolycyclicFactorGroupNC( <fgrp>, <rels> )
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
DeclareGlobalFunction( "SingleCollectorByRelators" );

DeclareOperation(
    "PolycyclicFactorGroupByRelatorsNC",
    [ IsFamily, IsList, IsList ] );

DeclareOperation(
    "PolycyclicFactorGroupByRelators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##

#E  rwspcgrp.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
