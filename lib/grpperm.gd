#############################################################################
##
#W  grpperm.gd                  GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
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
#P  IsSymmetricGroup( <G> ) . . . . . . . . . is it the full symmetric group?
##
IsSymmetricGroup := NewProperty( "IsSymmetricGroup", IsPermGroup );
SetIsSymmetricGroup := Setter( IsSymmetricGroup );
HasIsSymmetricGroup := Tester( IsSymmetricGroup );

#############################################################################
##
#P  IsAlternatingGroup( <G> ) . . . . . . . is it the full alternating group?
##
IsAlternatingGroup := NewProperty( "IsAlternatingGroup", IsPermGroup );
SetIsAlternatingGroup := Setter( IsAlternatingGroup );
HasIsAlternatingGroup := Tester( IsAlternatingGroup );

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
AlternatingGroup := NewOperationArgs( "AlternatingGroup" );
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

# just a function variable for the selection functions
DegreeOperation := NewOperationArgs( "DegreeOperation" );

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

