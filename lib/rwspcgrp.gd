#############################################################################
##
#W  rwspcgrp.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareCategory(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector",
    IsMultiplicativeElementWithInverseByRws and IsAssociativeElement );

DeclareCategoryCollections(
    "IsMultiplicativeElementWithInverseByPolycyclicCollector" );


#############################################################################
##
#C  IsPcGroup
##
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
##
DeclareOperation(
    "PolycyclicFactorGroup",
    [ IsObject, IsList ] );


#############################################################################
##
#O  PolycyclicFactorGroupByRelators( <fam>, <gens>, <rels> )
##
DeclareOperation(
    "PolycyclicFactorGroupByRelators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##

#E  rwspcgrp.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
