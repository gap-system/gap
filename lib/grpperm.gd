#############################################################################
##
#W  grpperm.gd                  GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.14  1997/01/21 15:49:06  htheisse
#H  added `MinimizeExplicitTransversal'
#H
#H  Revision 4.13  1997/01/16 14:14:56  ahulpke
#H  replaced DegreeOperation by NrMovedPoints
#H
#H  Revision 4.12  1997/01/15 15:23:17  fceller
#H  added 'SymmetricGroup' to basic group library,
#H  changed 'IsSymmetricGroup' to 'IsNaturalSymmetricGroup'
#H
#H  Revision 4.11  1997/01/07 13:35:07  ahulpke
#H  Added the transitive groups data library
#H
#H  Revision 4.10  1997/01/06 16:44:22  ahulpke
#H  Added 'AlternatingGroup'
#H
#H  Revision 4.9  1996/12/19 09:59:04  htheisse
#H  added revision lines
#H
##
Revision.grpperm_gd :=
    "@(#)$Id$";

IsPermGroup := IsGroup and IsPermCollection;
IsFactorGroup := ReturnFalse;  # temporarily

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

MinimizeExplicitTransversal := NewOperationArgs
                               ( "MinimizeExplicitTransversal" );
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
SignPermGroup := NewOperationArgs( "SignPermGroup" );
CycleStructuresGroup := NewOperationArgs( "CycleStructuresGroup" );

#############################################################################
##
#A  AllBlocks . . . . . Representatives of all block systems
##
AllBlocks := NewAttribute( "AllBlocks", IsPermGroup );
SetAllBlocks := Setter( AllBlocks );
HasAllBlocks := Tester( AllBlocks );

#############################################################################
##
#A  TransitiveIdentification . . . . . . . . . . in transitive groups library
##
TransitiveIdentification := NewAttribute( "TransitiveIdentification",
                                          IsPermGroup );
SetTransitiveIdentification := Setter( TransitiveIdentification );
HasTransitiveIdentification := Tester( TransitiveIdentification );

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

