#############################################################################
##
#W  ghompcgs.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.ghompcgs_gd :=
    "@(#)$Id$";

#############################################################################
##
#R  IsGroupGeneralMappingByPcgs(<map>)
##
##  is the representations for mappings that map a pcgs to images and thus
##  may use exponents to decompose generators.
DeclareRepresentation( "IsGroupGeneralMappingByPcgs",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );

#############################################################################
##
#R  IsPcGroupGeneralMappingByImages(<map>)
#R  IsPcGroupHomomorphismByImages(<map>)
##
##  is the representation for mappings from a pc group
DeclareRepresentation( "IsPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByPcgs,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );
DeclareSynonym("IsPcGroupHomomorphismByImages",
  IsPcGroupGeneralMappingByImages and IsMapping);

#############################################################################
##
#R  IsToPcGroupGeneralMappingByImages( <map>)
#R  IsToPcGroupHomomorphismByImages( <map>)
##
##  is the representation for mappings to a pc group
DeclareRepresentation( "IsToPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "rangePcgs", "rangePcgsPreimages" ] );
DeclareSynonym("IsToPcGroupHomomorphismByImages",
  IsToPcGroupGeneralMappingByImages and IsMapping);

#############################################################################
##
#O  NaturalIsomorphismByPcgs( <grp>, <pcgs> ) . . presentation through <pcgs>
##
DeclareOperation( "NaturalIsomorphismByPcgs", [ IsGroup, IsPcgs ] );


#############################################################################
##
#R  IsNaturalHomomorphismPcGroupRep . . . . . . . . natural hom in a pc group
##
DeclareRepresentation( "IsNaturalHomomorphismPcGroupRep",
      IsGroupHomomorphism and IsSurjective and IsSPGeneralMapping and
      IsAttributeStoringRep,
      [ "sourcePcgs", "rangePcgs" ] );

#############################################################################
##
#R  IsPcgsToPcgsGeneralMappingByImages(<obj>)
##
DeclareRepresentation( "IsPcgsToPcgsGeneralMappingByImages",
      IsPcGroupGeneralMappingByImages and IsToPcGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages",
        "rangePcgs", "rangePcgsPreimages" ] );
DeclareSynonym( "IsPcgsToPcgsHomomorphism",
  IsPcgsToPcgsGeneralMappingByImages and IsMapping);


#############################################################################
##
#E  ghompcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
