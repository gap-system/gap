#############################################################################
##
#W  ghomperm.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.ghomperm_gd :=
    "@(#)$Id$";

DeclareRepresentation( "IsPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsPermGroupHomomorphismByImages := IsPermGroupGeneralMappingByImages
                               and IsMapping;

DeclareRepresentation( "IsToPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsToPermGroupHomomorphismByImages := IsToPermGroupGeneralMappingByImages
                                 and IsMapping;

DeclareGlobalFunction( "AddGeneratorsGenimagesExtendSchreierTree" );
DeclareGlobalFunction( "ImageSiftedBaseImage" );
DeclareGlobalFunction( "CoKernelGensIterator" );
DeclareGlobalFunction( "CoKernelGensPermHom" );
DeclareGlobalFunction( "StabChainPermGroupToPermGroupGeneralMappingByImages" );
DeclareGlobalFunction( "MakeStabChainLong" );
DeclareGlobalFunction( "ImageKernelBlocksHomomorphism" );
DeclareGlobalFunction( "PreImageSetStabBlocksHomomorphism" );


#############################################################################
##
#E  ghomperm.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

