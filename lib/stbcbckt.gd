#############################################################################
##
#W  stbcbckt.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.5  1997/02/06 09:52:58  htheisse
#H  threw away some unused code
#H
#H  Revision 4.4  1997/01/13 16:59:34  htheisse
#H  uses a quick for `IsSymmetricGroup'
#H
#H  Revision 4.3  1996/12/19 09:59:16  htheisse
#H  added revision lines
#H
##
Revision.stbcbckt_gd :=
    "@(#)$Id$";

InfoBckt := NewInfoClass( "InfoBckt" );

IsoTypeParam := NewOperationArgs( "IsoTypeParam" );
UnionBlist := NewOperationArgs( "UnionBlist" );
IsSymmetricGroupQuick := NewOperationArgs( "IsSymmetricGroupQuick" );
YndexSymmetricGroup := NewOperationArgs( "YndexSymmetricGroup" );
AsPerm := NewOperationArgs( "AsPerm" );
IsSlicedPerm := NewOperationArgs( "IsSlicedPerm" );
IsSlicedPermInv := NewOperationArgs( "IsSlicedPermInv" );
PreImageWord := NewOperationArgs( "PreImageWord" );
ExtendedT := NewOperationArgs( "ExtendedT" );
MeetPartitionStrat := NewOperationArgs( "MeetPartitionStrat" );
StratMeetPartition := NewOperationArgs( "StratMeetPartition" );
Suborbits := NewOperationArgs( "Suborbits" );
OnSuborbits := NewOperationArgs( "OnSuborbits" );
OrbitalPartition := NewOperationArgs( "OrbitalPartition" );
EmptyRBase := NewOperationArgs( "EmptyRBase" );
IsTrivialRBase := NewOperationArgs( "IsTrivialRBase" );
AddRefinement := NewOperationArgs( "AddRefinement" );
ProcessFixpoint := NewOperationArgs( "ProcessFixpoint" );
RegisterRBasePoint := NewOperationArgs( "RegisterRBasePoint" );
NextRBasePoint := NewOperationArgs( "NextRBasePoint" );
RRefine := NewOperationArgs( "RRefine" );
PBIsMinimal := NewOperationArgs( "PBIsMinimal" );
SubtractBlistOrbitStabChain := NewOperationArgs( "SubtractBlistOrbitStabChain" );
PartitionBacktrack := NewOperationArgs( "PartitionBacktrack" );
Refinements := NewOperationArgs( "Refinements" );
NextLevelRegularGroups := NewOperationArgs( "NextLevelRegularGroups" );
RBaseGroupsBloxPermGroup := NewOperationArgs( "RBaseGroupsBloxPermGroup" );
RepOpSetsPermGroup := NewOperationArgs( "RepOpSetsPermGroup" );
RepOpElmTuplesPermGroup := NewOperationArgs( "RepOpElmTuplesPermGroup" );
IsomorphismPermGroup := NewOperationArgs( "IsomorphismPermGroup" );
AutomorphismGroupPermGroup := NewOperationArgs( "AutomorphismGroupPermGroup" );
PermGroupOps_ElementProperty := NewOperationArgs( "PermGroupOps_ElementProperty" );
PermGroupOps_SubgroupProperty := NewOperationArgs( "PermGroupOps_SubgroupProperty" );
PermGroupOps_TwoClosure := NewOperationArgs( "PermGroupOps_TwoClosure" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  stbcbckt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

