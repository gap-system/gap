#############################################################################
##
#W  grpfp.gd                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
IsElementOfFpGroupCollection := CategoryCollections( IsElementOfFpGroup );


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
IsFamilyOfFpGroupElements := CategoryFamily( IsElementOfFpGroup );


#############################################################################
##
#O  ElementOfFpGroup( <Fam>, <word> )
##
ElementOfFpGroup := NewOperation( "ElementOfFpGroup",
    [ IsFamilyOfFpGroupElements, IsAssocWordWithInverse ] );


############################################################################
##
#F  CosetTableFpGroup
##
CosetTableFpGroup := NewOperationArgs("CosetTableFpGroup");


############################################################################
##
#F  CosetTableFromGensAndRels
##
CosetTableFromGensAndRels := NewOperationArgs("CosetTableFromGensAndRels");


############################################################################
##
#F  FreeGeneratorsOfFpGroup( F )
##
FreeGeneratorsOfFpGroup := NewOperationArgs( "FreeGeneratorsOfFpGroup" );


############################################################################
##
#F  FreeGroupOfFpGroup 
##
FreeGroupOfFpGroup := NewOperationArgs( "FreeGroupOfFpGroup" );


############################################################################
##
#F  IsFromFpGroupStdGensGeneralMappingByImages . . . Mapping from Fp group,
##                                    just mapping the standard generators
##
IsFromFpGroupStdGensGeneralMappingByImages := NewRepresentation
    ( "IsFromFpGroupStdGensGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsFromFpGroupStdGensHomomorphismByImages :=
  IsFromFpGroupStdGensGeneralMappingByImages and IsMapping;


############################################################################
##
#F  IsToFpGroupGeneralMappingByImages
##
IsToFpGroupGeneralMappingByImages := NewRepresentation
    ( "IsToFpGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsToFpGroupHomomorphismByImages := IsToFpGroupGeneralMappingByImages
                               and IsMapping;


############################################################################
##
#F  LowIndexSubgroupsFpGroup
##
LowIndexSubgroupsFpGroup := NewOperationArgs("LowIndexSubgroupsFpGroup");


############################################################################
##
#F  MostFrequentGeneratorFpGroup
##
MostFrequentGeneratorFpGroup :=
    NewOperationArgs("MostFrequentGeneratorFpGroup");


############################################################################
##
#F  RelatorsOfFpGroup 
##
RelatorsOfFpGroup := NewOperationArgs( "RelatorsOfFpGroup" );


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


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##     determinate subgroup generators form fee generators, relators and
##     coset table. It returns elements of the free group!
##
SubgroupGeneratorsCosetTable := NewOperationArgs(
  "SubgroupGeneratorsCosetTable" );


#############################################################################
##
#E  grpfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



