#############################################################################
##
#W  factgrp.gd                      GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of operations for factor group maps
##
Revision.factgrp_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoFactor
##
DeclareInfoClass("InfoFactor");

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
DeclareAttribute("NaturalHomomorphismsPool",IsGroup,
                                         "mutable");

#############################################################################
##
#F  FactorCosetOperation( <G>, <U>, [<N>] )  operation on the right cosets Ug
##
##  This command computes the operation of <G> on the right cosets of the
##  subgroup <U>. If the normal subgroup <N> is given, it is stored as kernel
##  of this operation.
##
DeclareOperation( "FactorCosetOperation", [IsGroup,IsGroup] );

#############################################################################
##
#F  ImproveOperationDegreeByBlocks( <G>, <N> , <hom> [,forceblocks] )
#F  ImproveOperationDegreeByBlocks( <G>, <N> , <U> [,forceblocks] )
##
##  In the first usage, <N> is a normal subgroup of <G> and <hom> a
##  homomorphism from <G> to a permutation group with kernel <N>. In the second
##  usage, <hom> is taken to be the action of <G> on the cosets of <U> by right
##  multiplication.
##  The function tries to find another homomorphism with the same kernel but
##  image group of smaller degree by looking for block systems of the image
##  group. An improved result is stored in the `NaturalHomomorphismsPool', the
##  function returns the degree of this image (or the degree of the original
##  image).
##  If the image degree is larger than 500, only one block system is tested by
##  standard. A test of all block systems is enforced by the optional boolean
##  parameter <forceblocks>
##
DeclareGlobalFunction( "ImproveOperationDegreeByBlocks" );

#############################################################################
##
#F  SmallerDegreePermutationRepresentation( <G> )
##
##  tries to find a smaller degree faithful permutation representation for
##  the group <G>.
##
DeclareGlobalFunction("SmallerDegreePermutationRepresentation");

#############################################################################
##
#F  FindOperationKernel( <G>, <N> )  . . . . . . . . . . . . . . . . local
##
##  This operation tries to find a suitable operation for the group <G> such
##  that its kernel is <N>. This is used to construct faithful permutation
##  representations for the factor group.
##
DeclareOperation( "FindOperationKernel",[IsGroup,IsGroup]);


#############################################################################
##
#O  AddNaturalHomomorphismsPool(G,N,op[,cost[,blocksdone]]) . Store operation
##
##  This function stores a computed operation of <G> with kernel <N> in the
##  `NaturalHomomorphismsPool' of <G>, unless a ``better'' operation is already
##  known. <op> usually is a homomorphism of <G> with kernel <N>. It may also
##  be a subgroup of <G>, in which case the operation of <G> on its cosets is
##  taken.
##  If the optional parameter <cost> is not given, <cost> is taken to be the
##  degree of the image representation (or 1 if the image is a pc group). This
##  <cost> is stored with the operation to determine later whether another
##  operation is ``better''.
##  The optional boolean parameter <blocksdone> indicates if set to true, that
##  all block systems of the image of <op> have already been computed and the
##  resulting (lower degree, but not necessarily faithful for $G/N$) operations
##  have been already considered. (Otherwise such a test may be done later by
##  `DoCheapOperationImages'.)
##  The function internally re-sorts the list of normal subgroups to permit
##  binary search among them. If a new operation is returns the re-sorting
##  permutation applied there. If returns `false' if a ``better'' operation was
##  already known, it returns ``fail'' if this factor is locked.
##
DeclareGlobalFunction("AddNaturalHomomorphismsPool");


#############################################################################
##
#O  LockNaturalHomomorphismsPool(<G>,<N>)  . .  store flag to prohibit changes 
##
##  Calling this function stores a flag in the `NaturalHomomorphismsPool' of
##  <G> to prohibit it to store new (even better) faithful actions for $G/N$.
##  This can be used in algorithms to ensure that
##  `NaturalHomomorphismByNormalSubgroup(<G>,<N>)' will always return the same
##  mapping, even if in the meantime other homomorphisms are computed anew,
##  which -- as a side effect -- obtained a better action for $G/N$ which {\GAP}
##  normally would store.
##  The locking can be reverted by `UnlockNaturalHomomorphismsPool(<G>,<N>)'.
##
DeclareGlobalFunction("LockNaturalHomomorphismsPool");

#############################################################################
##
#O  UnlockNaturalHomomorphismsPool(<G>,<N>) .  clear flag to allow changes of
##
##  clears the flag set by `LockNaturalHomomorphismsPool(<G>,<N>)'.
##
DeclareGlobalFunction("UnlockNaturalHomomorphismsPool");

#############################################################################
##
#O  KnownNaturalHomomorphismsPool(<G>,<N>) . . .  check whether Hom is stored
##
##  This function tests whether an homomorphism for
##  `NaturalHomomorphismByNormalSubgroup(<G>,<N>)' is already known (or
##  computed trivially for $G=N$ or $N=\langle1\rangle$).
##
DeclareGlobalFunction("KnownNaturalHomomorphismsPool");

#############################################################################
##
#O  GetNaturalHomomorphismsPool(<G>,<N>) . . . get operation for G/N if known
##
##  returns a `NaturalHomomorphismByNormalSubgroup(<G>,<N>)' if one is
##  stored already in the `NaturalHomomorphismsPool' of <G>.
##  (As the homomorphism may be stored by a ``recipe'' this command can
##  still take some time when called the first time.)
##
DeclareGlobalFunction("GetNaturalHomomorphismsPool");

#############################################################################
##
#O  DegreeNaturalHomomorphismsPool(<G>,<N>) degree for operation for G/N 
##
##  returns the cost (see "AddNaturalHomomorphismsPool") of a stored action
##  for $G/N$ and fail if no such action is stored.
##
DeclareGlobalFunction("DegreeNaturalHomomorphismsPool");


#############################################################################
##
#O  CloseNaturalHomomorphismsPool(<G>[,<N>]) . . calc intersections of known
##
##  This command tries to build actions for (new) factor groups from the
##  already known actions in the `NaturalHomomorphismsPool(<G>)' by considering
##  intransitive representations for subdirect products. Any new or better
##  homomorphism obtained this way is stored (see
##  "AddNaturalHomomorphismsPool"). 
##  If the optional parameter <N> is given, only actions which have <N> in their
##  kernel are considered.
##  The function keeps track of already considered subdirect products, thus
##  there is no overhead in calling it several times.
##
DeclareGlobalFunction("CloseNaturalHomomorphismsPool");


#############################################################################
##
#O  DoCheapOperationImages(<G>) . . . . . . . . . All cheap operations for G
##
##  computes natural actions for <G> and stores the resulting
##  `NaturalHomomorphismByNormalSubgroup'. The type of the natural actions
##  varies with the representation of <G>, for permutation groups it are for
##  example constituent and block homomorphisms.
##  
DeclareOperation("DoCheapOperationImages",[IsGroup]);


#############################################################################
##
#E  factgrp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
