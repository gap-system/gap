#############################################################################
##
#A  hom.gd                    Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##

#############################################################################
##
#P  IsPointHomomorphism . . . . . . . . . . . . . . . . . IsPointHomomorphism
##
DeclareProperty( "IsPointHomomorphism", IsGroupGeneralMappingByImages );

#############################################################################
##
#A  NiceToCryst . . . . . . .Lift from NiceObject of PointGroup to CrystGroup 
##
DeclareAttribute( "NiceToCryst", IsPointGroup );

#############################################################################
##
#F  NiceToCrystStdRep( P, perm )
##
DeclareGlobalFunction( "NiceToCrystStdRep" );

#############################################################################
##
#P  IsFromAffineCrystGroupToFpGroup
##
DeclareProperty( "IsFromAffineCrystGroupToFpGroup", 
                                             IsGroupGeneralMappingByImages );
#############################################################################
##
#P  IsFromAffineCrystGroupToPcpGroup
##
DeclareProperty( "IsFromAffineCrystGroupToPcpGroup", 
                                             IsGroupGeneralMappingByImages );

#############################################################################
##
#A  MappingGeneratorsImages - for compatibility with GAP 4.2 and GAP 4.1
##
if not CompareVersionNumbers( VERSION, "4.3" ) then
    if not IsBound( MappingGeneratorsImages ) then
        DeclareAttribute( "MappingGeneratorsImages", IsGeneralMapping );
    fi;
fi;
