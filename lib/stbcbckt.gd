#############################################################################
##
#W  stbcbckt.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.stbcbckt_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoBckt
##
##  is the info class for the partition backtrack routines.
##
DeclareInfoClass( "InfoBckt" );

DeclareGlobalFunction( "AsPerm" );
DeclareGlobalFunction( "PreImageWord" );
DeclareGlobalFunction( "ExtendedT" );
DeclareGlobalFunction( "MeetPartitionStrat" );
DeclareGlobalFunction( "MeetPartitionStratCell" );
DeclareGlobalFunction( "StratMeetPartition" );
DeclareGlobalFunction( "Suborbits" );
DeclareGlobalFunction( "OrbitalPartition" );
DeclareGlobalFunction( "EmptyRBase" );
DeclareGlobalFunction( "IsTrivialRBase" );
DeclareGlobalFunction( "AddRefinement" );
DeclareGlobalFunction( "ProcessFixpoint" );
DeclareGlobalFunction( "RegisterRBasePoint" );
DeclareGlobalFunction( "NextRBasePoint" );
DeclareGlobalFunction( "RRefine" );
DeclareGlobalFunction( "PBIsMinimal" );
DeclareGlobalFunction( "SubtractBlistOrbitStabChain" );
DeclareGlobalFunction( "PartitionBacktrack" );

DeclareGlobalFunction("SuboLiBli");
DeclareGlobalFunction("SuboSiBli");
DeclareGlobalFunction("SuboTruePos");
DeclareGlobalFunction("SuboUniteBlist");
DeclareGlobalFunction("ConcatSubos");

DeclareGlobalFunction("Refinements_ProcessFixpoint");
DeclareGlobalFunction("Refinements_Intersection");
DeclareGlobalFunction("Refinements_Centralizer");
DeclareGlobalFunction("Refinements__MakeBlox");
DeclareGlobalFunction("Refinements_SplitOffBlock");
DeclareGlobalFunction("Refinements__RegularOrbit1");
DeclareGlobalFunction("Refinements_RegularOrbit2");
DeclareGlobalFunction("Refinements_RegularOrbit3");
DeclareGlobalFunction("Refinements_Suborbits0");
DeclareGlobalFunction("Refinements_Suborbits1");
DeclareGlobalFunction("Refinements_Suborbits2");
DeclareGlobalFunction("Refinements_Suborbits3");
DeclareGlobalFunction("Refinements_TwoClosure");


DeclareGlobalVariable( "Refinements" );

DeclareGlobalFunction( "NextLevelRegularGroups" );
DeclareGlobalFunction( "RBaseGroupsBloxPermGroup" );
DeclareGlobalFunction( "RepOpSetsPermGroup" );
DeclareGlobalFunction( "RepOpElmTuplesPermGroup" );
DeclareGlobalFunction( "IsomorphismPermGroups" );
DeclareGlobalFunction( "AutomorphismGroupPermGroup" );


#############################################################################
##
#F  ElementProperty( <G>, <Pr>[, <L>[, <R>]] )      one element with property
##
##  `ElementProperty' returns an element $\pi$ of the permutation group <G>
##  such that the one-argument function <Pr> returns `true' for $\pi$.
##  It returns `fail' if no such element exists in <G>.
##  The optional arguments <L> and <R> are subgroups of <G> such that the
##  property <Pr> has the same value for all elements in the cosets <L><g>
##  and <g><R>, respectively.
##
DeclareGlobalFunction( "ElementProperty" );


#############################################################################
##
#F  SubgroupProperty( <G>, <Pr>[, <L> ] ) . . . . . . . . fulfilling subgroup
##
##  <Pr> must be a one-argument function that returns `true' or `false' for
##  elements of <G> and the subset of elements of <G> that fulfill <Pr> must
##  be a subgroup. (*If the latter is not true the result of this operation
##  is unpredictable!*) This command computes this subgroup.
##  The optional argument <L> must be a subgroup of the set of all elements
##  fulfilling <Pr> and can be given if known
##  in order to speed up the calculation.
##
DeclareGlobalFunction( "SubgroupProperty" );


#############################################################################
##
#O  PartitionStabilizerPermGroup( <G>, <part> )
##
##  <part> must be a list of pairwise disjoint sets of points
##  on which the permutation group <G> acts via `OnPoints'.
##  This function computes the stabilizer in <G> of <part>, that is,
##  the subgroup of all those elements in <G> that map each set in <part>
##  onto a set in <part>, via `OnSets'.
##
DeclareGlobalFunction( "PartitionStabilizerPermGroup" );


#############################################################################
##
#A  TwoClosure( <G> )
##
##  The *2-closure* of a transitive permutation group <G> on $n$ points is
##  the largest subgroup of $S_n$ which has the same orbits on sets of
##  ordered pairs of points as the group <G> has.
##  It also can be interpreted as the stabilizer of the orbital graphs of
##  <G>.
##
DeclareAttribute( "TwoClosure", IsPermGroup );


#############################################################################
##
#E

