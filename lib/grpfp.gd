#############################################################################
##
#W  grpfp.gd                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.grpfp_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  CosetTableDefaultLimit
##
CosetTableDefaultLimit := 1000;


#############################################################################
##
#V  CosetTableDefaultMaxLimit
##
CosetTableDefaultMaxLimit := 64000;


#############################################################################
##
#V  InfoFpGroup
##
InfoFpGroup := NewInfoClass( "InfoFpGroup" );


#############################################################################
##
#C  IsSubgroupFpGroup
##
IsSubgroupFpGroup := NewCategory( "IsSubgroupFpGroup", IsGroup );


#############################################################################
##
#C  IsElementOfFpGroup
##
IsElementOfFpGroup := NewCategory( "IsElementOfFpGroup",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );


#############################################################################
##
#C  IsElementOfFpGroupCollection
##
IsElementOfFpGroupCollection := CategoryCollections(
    "IsElementOfFpGroupCollection",
    IsElementOfFpGroup );


#############################################################################
##
#M  IsSubgroupFpGroup
##
InstallTrueMethod( IsSubgroupFpGroup,
    IsGroup and IsElementOfFpGroupCollection );


#############################################################################
##
#C  IsFamilyOfFpGroupElements
##
IsFamilyOfFpGroupElements := CategoryFamily( "IsFamilyOfFpGroupElements",
    IsElementOfFpGroup );


#############################################################################
##
#O  ElementOfFpGroup( <Fam>, <word> )
##
ElementOfFpGroup := NewOperation( "ElementOfFpGroup",
    [ IsFamilyOfFpGroupElements, IsAssocWordWithInverse ] );


############################################################################
##
#F  RelatorRepresentatives
##
RelatorRepresentatives := NewOperationArgs("RelatorRepresentatives");


############################################################################
##
#F  RelsSortedByStartGen
##
RelsSortedByStartGen := NewOperationArgs("RelsSortedByStartGen");


############################################################################
##
#F  CosetTableFromGensAndRels
##
CosetTableFromGensAndRels := NewOperationArgs("CosetTableFromGensAndRels");


############################################################################
##
#F  CosetTableFromGensAndRels
##
CosetTableFromGensAndRels := NewOperationArgs("CosetTableFromGensAndRels");

############################################################################
##
#F RelatorsOfFpGroup 
##
RelatorsOfFpGroup := NewOperationArgs( "RelatorsOfFpGroup" );

#############################################################################
##
#F FreeGeneratorsOfFpGroup( F )
##
FreeGeneratorsOfFpGroup := NewOperationArgs( "FreeGeneratorsOfFpGroup" );

############################################################################
##
#F FreeGroupOfFpGroup 
##
FreeGroupOfFpGroup := NewOperationArgs( "FreeGroupOfFpGroup" );


############################################################################
##
#F IsToFpGroupGeneralMappingByImages
##
IsToFpGroupGeneralMappingByImages := NewRepresentation
    ( "IsToFpGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsToFpGroupHomomorphismByImages := IsToFpGroupGeneralMappingByImages
                               and IsMapping;

#############################################################################
##
#E  grpfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



