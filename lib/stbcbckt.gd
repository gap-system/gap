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
DeclareInfoClass( "InfoBckt" );

DeclareGlobalFunction( "IsSymmetricGroupQuick" );
DeclareGlobalFunction( "YndexSymmetricGroup" );
DeclareGlobalFunction( "AsPerm" );
DeclareGlobalFunction( "PreImageWord" );
DeclareGlobalFunction( "ExtendedT" );
DeclareGlobalFunction( "MeetPartitionStrat" );
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

DeclareGlobalVariable( "Refinements" );

DeclareGlobalFunction( "NextLevelRegularGroups" );
DeclareGlobalFunction( "RBaseGroupsBloxPermGroup" );
DeclareGlobalFunction( "RepOpSetsPermGroup" );
DeclareGlobalFunction( "RepOpElmTuplesPermGroup" );
DeclareGlobalFunction( "IsomorphismPermGroups" );
DeclareGlobalFunction( "AutomorphismGroupPermGroup" );

#############################################################################
##
#F  ElementProperty( <G>, <Pr> [, <L> [, <R> ] ] )  one element with property
##
##  tries to find an element of <G> for which the one-argument function <Pr>
##  returns true and returns 'fail' if no such element exists. the optional
##  groups <L> and <R> are subgroups of <G> with the properties that the
##  property <Pr> has the same value for all elements in the cosets <L><g>,
##  respectively <g><R>.
DeclareGlobalFunction( "ElementProperty" );

#############################################################################
##
#F  SubgroupProperty( <G>, <Pr> [, <L> ] )  . . . . . . . fulfilling subgroup
##
##  <Pr> must be a one-argument function that returns `true' or 'false' for
##  elements of <G> and the subset of elements of <G> that fulfill <Pr> must
##  be a subgroup. This command computes this subgroup.  The optional
##  argument <L> must a subgroup of the set of all elements fulfilling <Pr>
##  and can be given if known to speed up the calculation.
DeclareGlobalFunction( "SubgroupProperty" );

#############################################################################
##
#O  PartitionStabilizerPermGroup(<G>,<part>)
##
##  <part> must be a list of sets of points, on which <G> acts. This
##  function computes the stabilizer in <G> of <part>, that is the subgroup
##  which maps every set from <part> to another set from <part>.
DeclareGlobalFunction("PartitionStabilizerPermGroup");

#############################################################################
##
#A  TwoClosure(<G>)
##
##  The *2-closure* of a transitive permutation group <G>  on $n$ points is
##  the largest subgroup of $S_n$ which has the same orbits on sets of
##  points of size 2 as the group <G> has. It also can be interpreted as the
##  stabilizer of the orbital graphs of <G>.
DeclareAttribute("TwoClosure",IsPermGroup);


#############################################################################
##
#E  stbcbckt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

