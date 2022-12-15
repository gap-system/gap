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
##  This file contains operations for  polycyclic rewriting systems, with  or
##  without torsion free  generators.   There are  two  subcategories, namely
##  polycyclic rewriting  systems defined by a  power/commutator presentation
##  and rws defined by a power/conjugate presentation.
##
##  Any  implementation  of  a collector must   at  least  specify  a  way to
##  construct such a collector and must implement  methods for `SetPower' and
##  `CollectWordOrFail'.    A  power/commutator collector must also implement
##  `SetCommutator',    a  power/conjugate  collector   `SetConjugate'.   The
##  operation  `CollectWordOrFail'   allows a  collector to return  `fail' if
##  the     given   stacks    were too   small,    however     in  this  case
##  `CollectWordOrFail'  is  responsible  for    enlarging the  stacks.   The
##  default method for `CollectWord' uses `CollectWordOrFail' and copy.
##
##  The default method for `ReducedForm' uses `CollectWordOrFail' in order to
##  compute the reduced form.
##
##  Polycyclic rewriting systems   assume that the  underlying structures are
##  groups, therefore they have the feature `IsBuiltFromGroup'.
##
##  Polycyclic rewriting systems must also specify how to construct a word in
##  the underlying   free group given an  exponent  vector.  The operation is
##  `ObjExponents'.
##
##  As in most applications  you will start with an  empty collector, fill in
##  most  of   the commutators  and   powers, and  then start  collecting,  a
##  collector can be  up    to  date  or out    of  date.  If   the   feature
##  `IsUpToDatePolycyclicCollector'  is present,  then  `CollectWord' can  be
##  used.  Otherwise `UpdatePolycyclicCollector'  must be called before using
##  `CollectWord'.
##
##  WARNING: you     must    *never* ever   install   an   implications   for
##  `IsUpToDatePolycyclicCollector' because it is reset when the presentation
##  is changed.
##

#############################################################################
##
#C  IsPolycyclicCollector( <obj> )
##
##  <ManSection>
##  <Filt Name="IsPolycyclicCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsPolycyclicCollector",
    IsRewritingSystem and IsBuiltFromGroup );


#############################################################################
##
#C  IsPowerConjugateCollector( <obj> )
##
##  <ManSection>
##  <Filt Name="IsPowerConjugateCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsPowerConjugateCollector",
    IsPolycyclicCollector );


#############################################################################
##
#C  IsPowerCommutatorCollector( <obj> )
##
##  <ManSection>
##  <Filt Name="IsPowerCommutatorCollector" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsPowerCommutatorCollector",
    IsPolycyclicCollector );


#############################################################################
##
#A  RelativeOrders( <col> )
##
##  <ManSection>
##  <Attr Name="RelativeOrders" Arg='col'/>
##
##  <Description>
##  The list of relative orders corresponding to <A>col</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "RelativeOrders", IsRewritingSystem );


#############################################################################
##
#P  IsUpToDatePolycyclicCollector( <col> )
##
DeclareFilter("IsUpToDatePolycyclicCollector");


#############################################################################
##
#O  OutdatePolycyclicCollector( <col> )
##
##  <ManSection>
##  <Oper Name="OutdatePolycyclicCollector" Arg='col'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "OutdatePolycyclicCollector",
    [ IsPolycyclicCollector and IsMutable ] );


#############################################################################
##
#O  UpdatePolycyclicCollector( <col> )
##
##  <ManSection>
##  <Oper Name="UpdatePolycyclicCollector" Arg='col'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="CollectWordOrFail" Arg='col, v, w'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "CollectWordOrFail",
    [ IsPolycyclicCollector, IsList, IsObject ] );


#############################################################################
##
#O  NonTrivialRightHandSides( <col> )
##
##  <ManSection>
##  <Oper Name="NonTrivialRightHandSides" Arg='col'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "NonTrivialRightHandSides",
    [ IsPolycyclicCollector ] );


#############################################################################
##
#O  ObjByExponents( <col>, <data> )
##
##  <ManSection>
##  <Oper Name="ObjByExponents" Arg='col, data'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ObjByExponents",
    [ IsPolycyclicCollector, IsObject ] );


#############################################################################
##
#O  SetCommutator( <col>, <i>, <j>, <rhs> )
##
##  <ManSection>
##  <Oper Name="SetCommutator" Arg='col, i, j, rhs'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "SetCommutator",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

DeclareOperation(
    "SetCommutatorNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

DeclareOperation(
    "SetCommutatorANC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );


#############################################################################
##
#O  SetConjugate( <col>, <i>, <j>, <rhs> )
##
##  <ManSection>
##  <Oper Name="SetConjugate" Arg='col, i, j, rhs'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "SetConjugate",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

DeclareOperation(
    "SetConjugateNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );

DeclareOperation(
    "SetConjugateANC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject, IsObject ] );


#############################################################################
##
#O  SetPower( <col>, <i>, <rhs> )
##
##  <ManSection>
##  <Oper Name="SetPower" Arg='col, i, rhs'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "SetPower",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

DeclareOperation(
    "SetPowerNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

DeclareOperation(
    "SetPowerANC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );


#############################################################################
##
#O  SetRelativeOrder( <col>, <i>, <order> )
##
##  <ManSection>
##  <Oper Name="SetRelativeOrder" Arg='col, i, order'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "SetRelativeOrder",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );

DeclareOperation(
    "SetRelativeOrderNC",
    [ IsPolycyclicCollector and IsMutable, IsObject, IsObject ] );


#############################################################################
##
#O  GetCommutatorNC( <col>, <h>, <g> )
##
##  <ManSection>
##  <Oper Name="GetCommutatorNC" Arg='col, h, g'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
        "GetCommutatorNC",
        [ IsPolycyclicCollector, IsObject, IsObject ] );

#############################################################################
##
#O  GetConjugateNC( <col>, <h>, <g> )
##
##  <ManSection>
##  <Oper Name="GetConjugateNC" Arg='col, h, g'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
        "GetConjugateNC",
        [ IsPolycyclicCollector, IsObject, IsObject ] );

#############################################################################
##
#O  GetPowerNC( <col>, <g> )
##
##  <ManSection>
##  <Oper Name="GetPowerNC" Arg='col, g'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
        "GetPowerNC",
        [ IsPolycyclicCollector, IsObject ] );

#############################################################################
##
#O  SingleCollector( <fgrp>, <orders> )
##
##  creates a single collector to the free group <fgrp> and the relative
##  orders <orders>.
##
DeclareOperation(
    "SingleCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  SingleCollectorByGenerators( <fam>, <gens>, <orders> )
##
##  <ManSection>
##  <Oper Name="SingleCollectorByGenerators" Arg='fam, gens, orders'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "SingleCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );
#T 1997/01/16 fceller was old `NewConstructor'

#############################################################################
##
#O  CombinatorialCollector( <fgrp>, <orders> )
##
##  <ManSection>
##  <Oper Name="CombinatorialCollector" Arg='fgrp, orders'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "CombinatorialCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  CombinatorialCollectorByGenerators( <fam>, <gens>, <orders> )
##
##  <ManSection>
##  <Oper Name="CombinatorialCollectorByGenerators" Arg='fam, gens, orders'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "CombinatorialCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##
#O  DeepThoughtCollector( <fgrp>, <orders> )
##
##  <ManSection>
##  <Oper Name="DeepThoughtCollector" Arg='fgrp, orders'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "DeepThoughtCollector",
    [ IsObject, IsObject ] );


#############################################################################
##
#O  DeepThoughtCollectorByGenerators( <fam>, <gens>, <orders> )
##
##  <ManSection>
##  <Oper Name="DeepThoughtCollectorByGenerators" Arg='fam, gens, orders'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "DeepThoughtCollectorByGenerators",
    [ IsFamily, IsList, IsList ] );


#############################################################################
##
#O  EvaluateOverlapCBA  . . . . . . . . . . . . . evaluate a consistency test
#O  EvaluateOverlapBNA  . . . . . . . . . . . . . evaluate a consistency test
#O  EvaluateOverlapBAN  . . . . . . . . . . . . . evaluate a consistency test
#O  EvaluateOverlapANA  . . . . . . . . . . . . . evaluate a consistency test
##
##  <ManSection>
##  <Oper Name="EvaluateOverlapCBA" Arg='...'/>
##  <Oper Name="EvaluateOverlapBNA" Arg='...'/>
##  <Oper Name="EvaluateOverlapBAN" Arg='...'/>
##  <Oper Name="EvaluateOverlapANA" Arg='...'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "EvaluateOverlapCBA",
        [ IsPolycyclicCollector, IsList, IsList, IsInt, IsInt, IsInt ] );
DeclareOperation( "EvaluateOverlapBNA",
        [ IsPolycyclicCollector, IsList, IsList, IsInt, IsInt, IsInt ] );
DeclareOperation( "EvaluateOverlapBAN",
        [ IsPolycyclicCollector, IsList, IsList, IsInt, IsInt, IsInt ] );
DeclareOperation( "EvaluateOverlapANA",
        [ IsPolycyclicCollector, IsList, IsList, IsInt, IsInt ] );
