#############################################################################
##
#W  ghomperm.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.1  1996/11/18 08:55:28  htheisse
#H  renamed representations of GHBIs, improved the cokernel gens iterator
#H
##
Revision.ghomperm_gd :=
    "@(#)$Id$";

IsPermGroupGeneralMappingByImages := NewRepresentation
    ( "IsPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsPermGroupHomomorphismByImages := IsPermGroupGeneralMappingByImages
                               and IsMapping;

IsToPermGroupGeneralMappingByImages := NewRepresentation
    ( "IsToPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsToPermGroupHomomorphismByImages := IsToPermGroupGeneralMappingByImages
                                 and IsMapping;

AddGeneratorsGenimagesExtendSchreierTree := NewOperationArgs( "AddGeneratorsGenimagesExtendSchreierTree" );
ImageSiftedBaseImage := NewOperationArgs( "ImageSiftedBaseImage" );
IsCoKernelGensIterator := NewOperationArgs( "IsCoKernelGensIterator" );
CoKernelGensIterator := NewOperationArgs( "CoKernelGensIterator" );
CoKernelGensPermHom := NewOperationArgs( "CoKernelGensPermHom" );
StabChainPermGroupToPermGroupGeneralMappingByImages := NewOperationArgs( "StabChainPermGroupToPermGroupGeneralMappingByImages" );
MakeStabChainLong := NewOperationArgs( "MakeStabChainLong" );
ImageKernelBlocksHomomorphism := NewOperationArgs( "ImageKernelBlocksHomomorphism" );
PreImageSetStabBlocksHomomorphism := NewOperationArgs( "PreImageSetStabBlocksHomomorphism" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  ghomperm.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here


