#############################################################################
##
#W  ghompcgs.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.ghompcgs_gd :=
    "@(#)$Id$";

#############################################################################
##

#P  IsPcGroupHomomorphismByImages( <G>, <H>, <gens>, <imgs> )
##
DeclareRepresentation( "IsPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );
IsPcGroupHomomorphismByImages := IsPcGroupGeneralMappingByImages
                                 and IsMapping;

#############################################################################
##
#P  IsToPcGroupHomomorphismByImages( <G>, <H>, <gens>, <imgs> )
##
DeclareRepresentation( "IsToPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "imagePcgs", "imagePcgsPreimages" ] );
IsToPcGroupHomomorphismByImages := IsToPcGroupGeneralMappingByImages
                                   and IsMapping;

#############################################################################
##
#O  NaturalIsomorphismByPcgs( <grp>, <pcgs> ) . . presentation through <pcgs>
##
DeclareOperation(
    "NaturalIsomorphismByPcgs",
    [ IsGroup, IsPcgs ] );


#############################################################################
##

#E  ghompcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
