#############################################################################
##
#W  rwspcclt.gd                 GAP Library                      Frank Celler
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains operations for  polycyclic rewriting systems, with  or
##  without torsion free  generators.   There are  two  subcategories, namely
##  polycyclic rewriting  systems defined by a  power/commutator presentation
##  and rws defined by a power/conjugate presentation.
##
##  Any  implementation  of  a collector must   at  least  specify  a  way to
##  construct such a collector and must implement  methods for 'SetPower' and
##  'CollectWordOrFail'.    A  power/commutator collector must also implement
##  'SetCommutator',    a  power/conjugate  collector   'SetConjugate'.   The
##  operation  'CollectWordOrFail'   allows a  collector to return  'fail' if
##  the     given   stacks    were too   small,    however     in  this  case
##  'CollectWordOrFail'  is  responsible  for    enlarging the  stacks.   The
##  default method for 'CollectWord' uses 'CollectWordOrFail' and copy.
##
##  The default method for 'ReducedForm' uses 'CollectWordOrFail' in order to
##  compute the reduced form.
##
##  Polycyclic rewriting systems   assume that the  underlying structures are
##  groups, therefore they have the feature 'IsBuiltFromGroup'.
##
##  Polycyclic rewriting systems must also specify how to construct a word in
##  the underlying   free group given an  exponent  vector.  The operation is
##  'ObjExponents'.
##
##  As in most applications  you will start with an  empty collector, fill in
##  most  of   the commutators  and   powers, and  then start  collecting,  a
##  collector can be  up    to  date  or out    of  date.  If   the   feature
##  'IsUpToDatePolycyclicCollector'  is present,  then  'CollectWord' can  be
##  used.  Otherwise 'UpdatePolycyclicCollector'  must be called before using
##  'CollectWord'.
##
##  WARNING: you     must    *never* ever   install   an   implications   for
##  'IsUpToDatePolycyclicCollector' because it is reset when the presentation
##  is changed.
##
Revision.rwspcclt_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsPolycyclicCollector( <obj> )
##
DeclareCategory(
    "IsPolycyclicCollector",
    IsRewritingSystem and IsBuiltFromGroup );


#############################################################################
##
#C  IsPowerConjugateCollector( <obj> )
##
DeclareCategory(
    "IsPowerConjugateCollector",
    IsPolycyclicCollector );


#############################################################################
##
#C  IsPowerCommutatorCollector( <obj> )
##
DeclareCategory(
    "IsPowerCommutatorCollector",
    IsPolycyclicCollector );


#############################################################################
##

#A  RelativeOrders( <col> )
##
DeclareAttribute(
    "RelativeOrders",
    IsObject );



#############################################################################
##

#P  IsUpToDatePolycyclicCollector( <col> )
##
DeclareFilter("IsUpToDatePolycyclicCollector");


#############################################################################
##
#O  OutdatePolycyclicCollector( <col> )
##
DeclareOperation(
    "OutdatePolycyclicCollector",
    [ IsPolycyclicCollector and IsMutable ] );


#############################################################################
##
#O  UpdatePolycyclicCollector( <col> )
##
DeclareOperation(
    "UpdatePolycyclicCollector",
    [ IsPolycyclicCollector ] );


#############################################################################
##

#O  CollectWord( <col>, <v>, <w> )
##
DeclareOperation(
    "CollectWord", 
    [ IsPolycyclicCollector, IsList, IsObject ] );


#############################################################################
##
#O  CollectWordOrFail( <col>, <v>, <w> )
##
DeclareOperation(
    "CollectWordOrFail",
    [ IsPolycyclicCollector, IsList, IsObject ] );


#############################################################################
##
#O  NonTrivialRightHandSides( <col> )
##
DeclareOperation(
    "NonTrivialRightHandSides",
    [ IsPolycyclicCollector ] );


#############################################################################
##
#O  ObjByExponents( <col>, <data> )
##
DeclareOperation(
    "ObjByExponents",
    [ IsPolycyclicCollector, IsObject ] );


#############################################################################
##
#O  SetCommutator( <col>, <i>, <j>, <rhs> )
##
DeclareOperation(
    "SetCommutator",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

DeclareOperation(
    "SetCommutatorNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );


#############################################################################
##
#O  SetConjugate( <col>, <i>, <j>, <rhs> )
##
DeclareOperation(
    "SetConjugate",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

DeclareOperation(
    "SetConjugateNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

        
#############################################################################
##
#O  SetPower( <col>, <i>, <rhs> )
##
DeclareOperation(
    "SetPower",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

DeclareOperation(
    "SetPowerNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );


#############################################################################
##
#O  SetRelativeOrder( <col>, <i>, <order> )
##
DeclareOperation(
    "SetRelativeOrder",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

DeclareOperation(
    "SetRelativeOrderNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );


#############################################################################
##

#O  SingleCollector( <fgrp>, <orders> )
##
DeclareOperation(
    "SingleCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  SingleCollectorByGenerators( <fam>, <gens>, <orders> )
##
DeclareOperation(
    "SingleCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  DeepThoughtCollector( <fgrp>, <orders> )
##
DeclareOperation(
    "DeepThoughtCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  DeepThoughtCollectorByGenerators( <fam>, <gens>, <orders> )
##
DeclareOperation(
    "DeepThoughtCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##

#E  rwspcclt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
