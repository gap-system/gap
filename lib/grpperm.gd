#############################################################################
##
#W  grpperm.gd                  GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.grpperm_gd :=
    "@(#)$Id$";


IsPermGroup := IsGroup and IsPermCollection;


#############################################################################
##
#M  IsSubsetLocallyFiniteGroup( <G> ) . . . . . .  for magmas of permutations
##
#T  Here we assume implicitly that all permutations are finitary!
#T  (What would be a permutation with unbounded largest moved point?
#T  Perhaps a permutation of possibly infinite order?)
##
InstallTrueMethod( IsSubsetLocallyFiniteGroup, IsPermCollection );
    

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

IndependentGeneratorsAbelianPPermGroup := NewOperationArgs( "IndependentGeneratorsAbelianPPermGroup" );
OrbitPerms := NewOperationArgs( "OrbitPerms" );
OrbitsPerms := NewOperationArgs( "OrbitsPerms" );
SmallestMovedPointPerms := NewOperationArgs( "SmallestMovedPointPerms" );
LargestMovedPointPerms := NewOperationArgs( "LargestMovedPointPerms" );
MovedPointsPerms := NewOperationArgs( "MovedPointsPerms" );
NrMovedPointsPerms := NewOperationArgs( "NrMovedPointsPerms" );
SylowSubgroupPermGroup := NewOperationArgs( "SylowSubgroupPermGroup" );
SignPermGroup := NewOperationArgs( "SignPermGroup" );
CycleStructuresGroup := NewOperationArgs( "CycleStructuresGroup" );
#############################################################################
##
#M  ApproximateSuborbitsStabilizerPermGroup(<G>,<pnt>) . . . approximation of
##  the orbits of Stab_G(pnt) on all points of the orbit pnt^G. (As not
##  all schreier generators are used, the results may be the orbits of a
##  subgroup.)
##
ApproximateSuborbitsStabilizerPermGroup :=
  NewOperationArgs("ApproximateSuborbitsStabilizerPermGroup");

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
#E  grpperm.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

