#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#R  IsGroupGeneralMappingByPcgs(<map>)
##
##  <#GAPDoc Label="IsGroupGeneralMappingByPcgs">
##  <ManSection>
##  <Filt Name="IsGroupGeneralMappingByPcgs" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representations for mappings that map a pcgs to images and thus
##  may use exponents to decompose generators.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsGroupGeneralMappingByPcgs",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );

#############################################################################
##
#R  IsPcGroupGeneralMappingByImages(<map>)
#R  IsPcGroupHomomorphismByImages(<map>)
##
##  <#GAPDoc Label="IsPcGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsPcGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsPcGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representation for mappings from a pc group
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
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
##  <#GAPDoc Label="IsToPcGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsToPcGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsToPcGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representation for mappings to a pc group
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsToPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "rangePcgs", "rangePcgsPreimages" ] );
DeclareSynonym("IsToPcGroupHomomorphismByImages",
  IsToPcGroupGeneralMappingByImages and IsMapping);

#############################################################################
##
#O  NaturalIsomorphismByPcgs( <grp>, <pcgs> ) . . presentation through <pcgs>
##
##  <ManSection>
##  <Oper Name="NaturalIsomorphismByPcgs" Arg='grp, pcgs'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "NaturalIsomorphismByPcgs", [ IsGroup, IsPcgs ] );


#############################################################################
##
#R  IsNaturalHomomorphismPcGroupRep . . . . . . . . natural hom in a pc group
##
##  <ManSection>
##  <Filt Name="IsNaturalHomomorphismPcGroupRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsNaturalHomomorphismPcGroupRep",
      IsGroupHomomorphism and IsSurjective and IsSPGeneralMapping and
      IsAttributeStoringRep,
      [ "sourcePcgs", "rangePcgs" ] );

#############################################################################
##
#R  IsPcgsToPcgsGeneralMappingByImages(<obj>)
##
##  <ManSection>
##  <Filt Name="IsPcgsToPcgsGeneralMappingByImages" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsPcgsToPcgsGeneralMappingByImages",
      IsPcGroupGeneralMappingByImages and IsToPcGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages",
        "rangePcgs", "rangePcgsPreimages" ] );
DeclareSynonym( "IsPcgsToPcgsHomomorphism",
  IsPcgsToPcgsGeneralMappingByImages and IsMapping);
