#############################################################################
##
#W  ghompcgs.gd                 GAP library                      Bettina Eick
##
Revision.ghompcgs_gd :=
    "@(#)$Id$";

#############################################################################
##

#P  IsPcGroupHomomorphismByImages( <G>, <H>, <gens>, <imgs> )
##
IsPcGroupGeneralMappingByImages := NewRepresentation
    ( "IsPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );
IsPcGroupHomomorphismByImages := IsPcGroupGeneralMappingByImages
                                 and IsMapping;

#############################################################################
##
#P  IsToPcGroupHomomorphismByImages( <G>, <H>, <gens>, <imgs> )
##
IsToPcGroupGeneralMappingByImages := NewRepresentation
    ( "IsToPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "imagePcgs", "imagePcgsPreimages" ] );
IsToPcGroupHomomorphismByImages := IsToPcGroupGeneralMappingByImages
                                   and IsMapping;

#############################################################################
##
#O  NaturalIsomorphismByPcgs( <grp>, <pcgs> ) . . presentation through <pcgs>
##
NaturalIsomorphismByPcgs := NewOperation(
    "NaturalIsomorphismByPcgs",
    [ IsGroup, IsPcgs ] );


#############################################################################
##

#E  ghompcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
