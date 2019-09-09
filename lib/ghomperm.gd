#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#R  IsPermGroupGeneralMapping(<map>)
#R  IsPermGroupGeneralMappingByImages(<map>)
#R  IsPermGroupHomomorphism(<map>)
#R  IsPermGroupHomomorphismByImages(<map>)
##
##  <#GAPDoc Label="IsPermGroupGeneralMapping">
##  <ManSection>
##  <Filt Name="IsPermGroupGeneralMapping" Arg='map' Type='Representation'/>
##  <Filt Name="IsPermGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsPermGroupHomomorphism" Arg='map' Type='Representation'/>
##  <Filt Name="IsPermGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  are the representations for mappings that map from a perm group
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsPermGroupGeneralMapping",
      IsGroupGeneralMapping,[]);
DeclareRepresentation( "IsPermGroupGeneralMappingByImages",
      IsPermGroupGeneralMapping and IsGroupGeneralMappingByImages, [] );
DeclareSynonym( "IsPermGroupHomomorphism",
    IsPermGroupGeneralMapping and IsMapping );
DeclareSynonym( "IsPermGroupHomomorphismByImages",
    IsPermGroupGeneralMappingByImages and IsMapping );


#############################################################################
##
#R  IsToPermGroupGeneralMappingByImages(<map>)
#R  IsToPermGroupHomomorphismByImages(<map>)
##
##  <#GAPDoc Label="IsToPermGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsToPermGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsToPermGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representation for mappings that map to a perm group
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsToPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
DeclareSynonym( "IsToPermGroupHomomorphismByImages",
    IsToPermGroupGeneralMappingByImages and IsMapping );


#############################################################################
##
#F  RelatorsPermGroupHom(<hom>,<gens>)
##
##  <ManSection>
##  <Func Name="RelatorsPermGroupHom" Arg='hom,gens'/>
##
##  <Description>
##  <C>RelatorsPermGroupHom</C> is an internal function which is called by the
##  operation <C>IsomorphismFpGroupByGeneratorsNC</C> in case of a permutation group.
##  It implements John Cannon's multi-stage relations finding algorithm as
##  described in&nbsp;<Cite Key="Neu82"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorsPermGroupHom");


#############################################################################
DeclareGlobalFunction( "AddGeneratorsGenimagesExtendSchreierTree" );
DeclareGlobalFunction( "ImageSiftedBaseImage" );
DeclareGlobalFunction( "CoKernelGensIterator" );
DeclareGlobalFunction( "CoKernelGensPermHom" );
DeclareGlobalFunction( "StabChainPermGroupToPermGroupGeneralMappingByImages" );
DeclareGlobalFunction( "MakeStabChainLong" );
DeclareGlobalFunction( "ImageKernelBlocksHomomorphism" );
DeclareGlobalFunction( "PreImageSetStabBlocksHomomorphism" );
