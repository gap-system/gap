#############################################################################
##
#W  factgrp.gd                      GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of operations for factor group maps
##
Revision.factgrp_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoFactor
##
InfoFactor := NewInfoClass("InfoFactor");

#############################################################################
##
#A  NaturalHomomorphismsPool(<G>)
##
## The 'NaturalHomomorphismsPool' is a record which contains the following
## components:
##    'group' is the corresponding group.
##    'ker' is a list of normal subgroups, which defines the arrangements.
##          It is sorted.
##    'ops' is a list which gives the best know operations for each normal 
##          subgroup. Its entries are either Homomorphisms from G or
## 	 generator lists (G.generators images) or lists of integers. In the
## 	 latter case the factor is subdirect product of the factors with
## 	 the given numbers.
##    'cost' gives the difficulty for each operation (degree of permgroup). It
##           is used to check whether a new operation is better.
##    'lock' is a bitlist, which indicates whether certain operations are
## 	  locked. If this happens, a better new operation is not entered.
## 	  This allows a computation to access the pool several times and to
## 	  be guaranteed to be returned the same object. Usually a routine
## 	  initially locks and finally unlocks.
## 	  #AH probably one even would like to have a lock counter ?
##    'GopDone' indicates whether all 'obvious' operations have been tried
##              already
##    'intersects' is a list of all intersections that have already been
##              formed.
##    'blocksdone' indicates if the operation already has been improved
##         using blocks
##    'in_code' can be set by the code to avoid addition of new actions
##              (and thus resorting)
NaturalHomomorphismsPool := NewAttribute("NaturalHomomorphismsPool",IsGroup,
                                         "mutable");
HasNaturalHomomorphismsPool := Tester(NaturalHomomorphismsPool);
SetNaturalHomomorphismsPool := Setter(NaturalHomomorphismsPool);

#############################################################################
##
#F  FactorCosetOperation( <G>, <U>, [<N>] )  operation on the right cosets Ug
##                                        with possibility to indicate Kernel
##
FactorCosetOperation := NewOperationArgs( "FactorCosetOperation" );

#############################################################################
##
#F  ImproveOperationDegreeByBlocks( <G>, <N> , {hom/subgrp} [,forceblocks] )
##  extension of <U> in <G> such that   \bigcap U^g=N remains valid
##
ImproveOperationDegreeByBlocks := NewOperationArgs(
  "ImproveOperationDegreeByBlocks" );

#############################################################################
##
#F  FindOperationKernel( <G>, <N> )  . . . . . . . . . . . . . . . . local
##                                  workhorse for NHBNS
##
FindOperationKernel := NewOperation( "FindOperationKernel",[IsGroup,IsGroup]);


#############################################################################
##
#O  AddNaturalHomomorphismsPool(G,N,op[,cost[,blocksdone]]) . Store operation
##       op for kernel N if there is not already a cheaper one
##       returns false if nothing had been added and 'fail' if adding was
##       forbidden
##
AddNaturalHomomorphismsPool :=
  NewOperationArgs("AddNaturalHomomorphismsPool");


#############################################################################
##
#O  LockNaturalHomomorphismsPool(G,N)  . .  store flag to prohibit changes of
##                                                               the map to N
##
LockNaturalHomomorphismsPool :=
  NewOperationArgs("LockNaturalHomomorphismsPool");

#############################################################################
##
#O  UnlockNaturalHomomorphismsPool(G,N) . . .  clear flag to allow changes of
##                                                               the map to N
##
UnlockNaturalHomomorphismsPool :=
  NewOperationArgs("UnlockNaturalHomomorphismsPool");

#############################################################################
##
#O  KnownNaturalHomomorphismsPool(G,N) . . . . .  check whether Hom is stored
##                                                               (or obvious)
##
KnownNaturalHomomorphismsPool :=
  NewOperationArgs("KnownNaturalHomomorphismsPool");

#############################################################################
##
#O  GetNaturalHomomorphismsPool(G,N)  . . . .  get operation for G/N if known
##
GetNaturalHomomorphismsPool :=
  NewOperationArgs("GetNaturalHomomorphismsPool");

#############################################################################
##
#O  DegreeNaturalHomomorphismsPool(G,N) degree for operation for G/N if known
##
DegreeNaturalHomomorphismsPool :=
  NewOperationArgs("DegreeNaturalHomomorphismsPool");


#############################################################################
##
#O  CloseNaturalHomomorphismsPool(<G>[,<N>]) . . calc intersections of known
##         operation kernels, don't continue anything whic is smaller than N
##
CloseNaturalHomomorphismsPool :=
  NewOperationArgs("CloseNaturalHomomorphismsPool");


#############################################################################
##
#O  DoCheapOperationImages(G) . . . . . . . . . . All cheap operations for G
##
DoCheapOperationImages := NewOperation("DoCheapOperationImages",[IsGroup]);


#############################################################################
##
#E  factgrp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
