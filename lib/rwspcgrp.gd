#############################################################################
##
#W  rwspcgrp.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file   contains the operations  for groups   defined by a polycyclic
##  collector.
##
Revision.rwspcgrp_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsMultiplicativeElementWithInverseByPolycyclicCollector
##
IsMultiplicativeElementWithInverseByPolycyclicCollector := NewCategory(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector",
    IsMultiplicativeElementWithInverseByRws and IsAssociativeElement );

IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection :=
  CategoryCollections(
    "IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection",
    IsMultiplicativeElementWithInverseByPolycyclicCollector );


#############################################################################
##
#C  IsPcGroup
##
IsPcGroup :=
    IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection
    and IsGroup;


#############################################################################
##

#A  DefiningPcgs( <obj> )
##
DefiningPcgs := NewAttribute(
    "DefiningPcgs",
    IsObject );

SetDefiningPcgs := Setter(DefiningPcgs);
HasDefiningPcgs := Tester(DefiningPcgs);


#############################################################################
##

#C  IsElementsFamilyBy8BitsSingleCollector
##
IsElementsFamilyBy8BitsSingleCollector := NewCategory(
    "IsElementsFamilyBy8BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#C  IsElementsFamilyBy16BitsSingleCollector
##
IsElementsFamilyBy16BitsSingleCollector := NewCategory(
    "IsElementsFamilyBy16BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##
#C  IsElementsFamilyBy32BitsSingleCollector
##
IsElementsFamilyBy32BitsSingleCollector := NewCategory(
    "IsElementsFamilyBy32BitsSingleCollector",
    IsElementsFamilyByRws );


#############################################################################
##

#O  PolycyclicFactorGroup( <fgrp>, <rels> )
##
PolycyclicFactorGroup := NewOperation(
    "PolycyclicFactorGroup",
    [ IsObject, IsList ] );


#############################################################################
##
#O  PolycyclicFactorGroupByRelators( <fam>, <gens>, <rels> )
##
PolycyclicFactorGroupByRelators := NewOperation(
    "PolycyclicFactorGroupByRelators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##

#E  rwspcgrp.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
