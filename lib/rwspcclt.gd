#############################################################################
##
#W  rwspcclt.gd                 GAP Library                      Frank Celler
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
IsPolycyclicCollector := NewCategory(
    "IsPolycyclicCollector",
    IsRewritingSystem and IsBuiltFromGroup );


#############################################################################
##
#C  IsPowerConjugateCollector( <obj> )
##
IsPowerConjugateCollector := NewCategory(
    "IsPowerConjugateCollector",
    IsPolycyclicCollector );


#############################################################################
##
#C  IsPowerCommutatorCollector( <obj> )
##
IsPowerCommutatorCollector := NewCategory(
    "IsPowerCommutatorCollector",
    IsPolycyclicCollector );


#############################################################################
##

#A  RelativeOrders( <col> )
##
RelativeOrders := NewAttribute(
    "RelativeOrders",
    IsObject );

HasRelativeOrders := Tester( RelativeOrders );
SetRelativeOrders := Setter( RelativeOrders );


#############################################################################
##

#P  IsUpToDatePolycyclicCollector( <col> )
##
IsUpToDatePolycyclicCollector := NewFilter("IsUpToDatePolycyclicCollector");


#############################################################################
##
#O  OutdatePolycyclicCollector( <col> )
##
OutdatePolycyclicCollector := NewOperation(
    "OutdatePolycyclicCollector",
    [ IsPolycyclicCollector and IsMutable ] );


#############################################################################
##
#O  UpdatePolycyclicCollector( <col> )
##
UpdatePolycyclicCollector := NewOperation(
    "UpdatePolycyclicCollector",
    [ IsPolycyclicCollector ] );


#############################################################################
##

#O  CollectWord( <col>, <v>, <w> )
##
CollectWord := NewOperation(
    "CollectWord", 
    [ IsPolycyclicCollector, IsList, IsObject ] );


#############################################################################
##
#O  CollectWordOrFail( <col>, <v>, <w> )
##
CollectWordOrFail := NewOperation(
    "CollectWordOrFail",
    [ IsPolycyclicCollector, IsList, IsObject ] );


#############################################################################
##
#O  NonTrivialRightHandSides( <col> )
##
NonTrivialRightHandSides := NewOperation(
    "NonTrivialRightHandSides",
    [ IsPolycyclicCollector ] );


#############################################################################
##
#O  ObjByExponents( <col>, <data> )
##
ObjByExponents := NewOperation(
    "ObjExponents",
    [ IsPolycyclicCollector, IsObject ] );


#############################################################################
##
#O  SetCommutator( <col>, <i>, <j>, <rhs> )
##
SetCommutator := NewOperation(
    "SetCommutator",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

SetCommutatorNC := NewOperation(
    "SetCommutatorNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );


#############################################################################
##
#O  SetConjugate( <col>, <i>, <j>, <rhs> )
##
SetConjugate := NewOperation(
    "SetConjugate",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

SetConjugateNC := NewOperation(
    "SetConjugateNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

        
#############################################################################
##
#O  SetPower( <col>, <i>, <rhs> )
##
SetPower := NewOperation(
    "SetPower",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

SetPowerNC := NewOperation(
    "SetPowerNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );


#############################################################################
##
#O  SetRelativeOrder( <col>, <i>, <order> )
##
SetRelativeOrder := NewOperation(
    "SetRelativeOrder",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

SetRelativeOrderNC := NewOperation(
    "SetRelativeOrderNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );


#############################################################################
##

#O  SingleCollector( <fgrp>, <orders> )
##
SingleCollector := NewOperation(
    "SingleCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  SingleCollectorByGenerators( <fam>, <gens>, <orders> )
##
SingleCollectorByGenerators := NewOperation(
    "SingleCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  DeepThoughtCollector( <fgrp>, <orders> )
##
DeepThoughtCollector := NewOperation(
    "DeepThoughtCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  DeepThoughtCollectorByGenerators( <fam>, <gens>, <orders> )
##
DeepThoughtCollectorByGenerators := NewOperation(
    "DeepthoughtCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##

#E  rwspcclt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
