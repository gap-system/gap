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

##
##  To implement new factor group methods, one does not need to deal with
##  most of the following operations (which are only used to cache known
##  homomorphisms and extend them to subdirect factors). Instead only methods
##  for the following three operations might need to be supplied:
##  If a suitable homomorphism cannot be found from the cached homomorphisms
##  pool, `NaturalHomomorphismByNormalSubgroupOp(<G>,<N>)' is called to
##  construct one.
##  The default method for `NaturalHomomorphismByNormalSubgroupOp' then uses
##  two other operations: `DoCheapActionImages' computes actions that come
##  naturally from a groups representation (for example permutation action
##  on orbits and blocks) and can be computed quickly. This is intended
##  as a first test to avoid hard work for homomorphisms that are easy to
##  get.
##  If this fails, `FindActionKernel' is called which will try to find some
##  action which will give a suitable homomorphism. (This can be very time
##  consuming.)
##  The existing methods seem to work reasonably well for permutation groups
##  and pc groups, for other kinds of groups it might be necessary to
##  implement completely new methods.
##  

#############################################################################
##
#O  DoCheapActionImages(<G>)
##
##  computes natural actions for <G> and stores the resulting
##  `NaturalHomomorphismByNormalSubgroup'. The type of the natural actions
##  varies with the representation of <G>, for permutation groups it are for
##  example constituent and block homomorphisms.
##  A method for `DoCheapActionImages' must register all found actions with
##  `AddNaturalHomomorphismsPool' so they become available.
##  
DeclareOperation("DoCheapActionImages",[IsGroup]);
DeclareSynonym("DoCheapOperationImages",DoCheapActionImages);


#############################################################################
##
#O  FindActionKernel( <G>, <N> )  . . . . . . . . . . . . . . . . local
##
##  This operation tries to find a suitable action for the group <G> such
##  that its kernel is <N>. This is used to construct faithful permutation
##  representations for the factor group.
##
DeclareOperation( "FindActionKernel",[IsGroup,IsGroup]);
DeclareSynonym( "FindOperationKernel",FindActionKernel);

#############################################################################
##
#V  InfoFactor
##
DeclareInfoClass("InfoFactor");

#############################################################################
##
#A  NaturalHomomorphismsPool(<G>)
##
## The `NaturalHomomorphismsPool' is a record which contains the following
## components:
##    `group' is the corresponding group.
##    `ker' is a list of normal subgroups, which defines the arrangements.
##          It is sorted.
##    `ops' is a list which gives the best know actions for each normal 
##          subgroup. Its entries are either Homomorphisms from G or
## 	 generator lists (G.generators images) or lists of integers. In the
## 	 latter case the factor is subdirect product of the factors with
## 	 the given numbers.
##    `cost' gives the difficulty for each actions (degree of permgroup). It
##           is used to check whether a new actions is better.
##    `lock' is a bitlist, which indicates whether certain actions are
## 	  locked. If this happens, a better new actions is not entered.
## 	  This allows a computation to access the pool several times and to
## 	  be guaranteed to be returned the same object. Usually a routine
## 	  initially locks and finally unlocks.
## 	  #AH probably one even would like to have a lock counter ?
##    `GopDone' indicates whether all `obvious' actions have been tried
##              already
##    `intersects' is a list of all intersections that have already been
##              formed.
##    `blocksdone' indicates if the actions already has been improved
##         using blocks
##    `in_code' can be set by the code to avoid addition of new actions
##              (and thus resorting)
DeclareAttribute("NaturalHomomorphismsPool",IsGroup,
                                         "mutable");

#############################################################################
##
#O  FactorCosetAction( <G>, <U>, [<N>] )  action on the right cosets Ug
##
##  This command computes the action of <G> on the right cosets of the
##  subgroup <U>. If the normal subgroup <N> is given, it is stored as kernel
##  of this action.
##
DeclareOperation( "FactorCosetAction", [IsGroup,IsGroup] );
DeclareSynonym( "FactorCosetOperation",FactorCosetAction);

#############################################################################
##
#F  ImproveActionDegreeByBlocks( <G>, <N> , <hom> [,forceblocks] )
#F  ImproveActionDegreeByBlocks( <G>, <N> , <U> [,forceblocks] )
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
DeclareGlobalFunction( "ImproveActionDegreeByBlocks" );
DeclareSynonym( "ImproveOperationDegreeByBlocks",
                        ImproveActionDegreeByBlocks );

#############################################################################
##
#F  SmallerDegreePermutationRepresentation( <G> )
##
##  Let <G> be a permutation group that acts transitively
##  on its moved points.
##  `SmallerDegreePermutationRepresentation' tries to find a faithful
##  permutation representation of smaller degree.
##  The result is a group homomorphism onto a permutation group,
##  in the worst case this is the identity mapping on <G>.
##
##  Note that the result is not guaranteed to be a faithful permutation
##  representation of smallest degree,
##  or of smallest degree among the transitive permutation representations
##  of <G>.
##  Using {\GAP} interactively, one might be able to choose subgroups
##  of small index for which the cores intersect trivially;
##  in this case, the actions on the cosets of these subgroups give rise to
##  an intransitive permutation representation
##  the degree of which may be smaller than the original degree.
##
DeclareGlobalFunction( "SmallerDegreePermutationRepresentation" );


#############################################################################
##
#F  AddNaturalHomomorphismsPool(G,N,op[,cost[,blocksdone]])
##
##  This function stores a computed action of <G> with kernel <N> in the
##  `NaturalHomomorphismsPool' of <G>, unless a ``better'' action is already
##  known. <op> usually is a homomorphism of <G> with kernel <N>. It may also
##  be a subgroup of <G>, in which case the action of <G> on its cosets is
##  taken.
##  If the optional parameter <cost> is not given, <cost> is taken to be the
##  degree of the image representation (or 1 if the image is a pc group). This
##  <cost> is stored with the action to determine later whether another
##  action is ``better''.
##  The optional boolean parameter <blocksdone> indicates if set to true, that
##  all block systems of the image of <op> have already been computed and the
##  resulting (lower degree, but not necessarily faithful for $G/N$) actions
##  have been already considered. (Otherwise such a test may be done later by
##  `DoCheapActionImages'.)
##  The function internally re-sorts the list of normal subgroups to permit
##  binary search among them. If a new action is returns the re-sorting
##  permutation applied there. If returns `false' if a ``better'' action was
##  already known, it returns ``fail'' if this factor is locked.
##
DeclareGlobalFunction("AddNaturalHomomorphismsPool");


#############################################################################
##
#F  LockNaturalHomomorphismsPool(<G>,<N>)  . .  store flag to prohibit changes 
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
#F  UnlockNaturalHomomorphismsPool(<G>,<N>) .  clear flag to allow changes of
##
##  clears the flag set by `LockNaturalHomomorphismsPool(<G>,<N>)'.
##
DeclareGlobalFunction("UnlockNaturalHomomorphismsPool");

#############################################################################
##
#F  KnownNaturalHomomorphismsPool(<G>,<N>) . . .  check whether Hom is stored
##
##  This function tests whether an homomorphism for
##  `NaturalHomomorphismByNormalSubgroup(<G>,<N>)' is already known (or
##  computed trivially for $G=N$ or $N=\langle1\rangle$).
##
DeclareGlobalFunction("KnownNaturalHomomorphismsPool");

#############################################################################
##
#F  GetNaturalHomomorphismsPool(<G>,<N>) . . . get action for G/N if known
##
##  returns a `NaturalHomomorphismByNormalSubgroup(<G>,<N>)' if one is
##  stored already in the `NaturalHomomorphismsPool' of <G>.
##  (As the homomorphism may be stored by a ``recipe'' this command can
##  still take some time when called the first time.)
##
DeclareGlobalFunction("GetNaturalHomomorphismsPool");

#############################################################################
##
#F  DegreeNaturalHomomorphismsPool(<G>,<N>) degree for action for G/N 
##
##  returns the cost (see "AddNaturalHomomorphismsPool") of a stored action
##  for $G/N$ and fail if no such action is stored.
##
DeclareGlobalFunction("DegreeNaturalHomomorphismsPool");


#############################################################################
##
#F  CloseNaturalHomomorphismsPool(<G>[,<N>]) . . calc intersections of known
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
#E  factgrp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
