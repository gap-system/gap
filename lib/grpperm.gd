#############################################################################
##
#W  grpperm.gd                  GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.9  1996/12/19 09:59:04  htheisse
#H  added revision lines
#H
##
Revision.grpperm_gd :=
    "@(#)$Id$";

#############################################################################
##
#R  IsPermGroupEnumerator . . . . . . . . . . . . . enumerator for perm group
##
IsPermGroupEnumerator := NewRepresentation( "IsPermGroupEnumerator",
    IsEnumerator, [ "stabChain" ] );

#############################################################################
##
#R  IsRightTransversalPermGroup . . . . . . . right transversal of perm group
##
IsRightTransversalPermGroup := NewRepresentation
    ( "IsRightTransversalPermGroup", IsRightTransversal,
      [ "group", "subgroup", "stabChainGroup", "stabChainSubgroup" ] );

AddCosetInfoStabChain := NewOperationArgs( "AddCosetInfoStabChain" );
NumberCoset := NewOperationArgs( "NumberCoset" );
CosetNumber := NewOperationArgs( "CosetNumber" );

CycleStructurePerm := NewOperationArgs( "CycleStructurePerm" );
RestrictedPerm := NewOperationArgs( "RestrictedPerm" );
MappingPermListList := NewOperationArgs( "MappingPermListList" );
IndependentGeneratorsAbelianPPermGroup := NewOperationArgs( "IndependentGeneratorsAbelianPPermGroup" );
IndependentGeneratorsAbelianPermGroup := NewOperationArgs( "IndependentGeneratorsAbelianPermGroup" );
OrbitPerms := NewOperationArgs( "OrbitPerms" );
OrbitsPerms := NewOperationArgs( "OrbitsPerms" );
SmallestMovedPointPerms := NewOperationArgs( "SmallestMovedPointPerms" );
LargestMovedPointPerms := NewOperationArgs( "LargestMovedPointPerms" );
MovedPointsPerms := NewOperationArgs( "MovedPointsPerms" );
NrMovedPointsPerms := NewOperationArgs( "NrMovedPointsPerms" );
SylowSubgroupPermGroup := NewOperationArgs( "SylowSubgroupPermGroup" );
OmegaPN := NewOperationArgs( "OmegaPN" );
SymmetricGroup := NewOperationArgs( "SymmetricGroup" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  grpperm.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

