#############################################################################
##
#W  ghom.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.ghom_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  GroupGeneralMappingByImages( <G>, <H>, <gensG>, <gensH> )
##
GroupGeneralMappingByImages := NewOperation( "GroupGeneralMappingByImages",
    [ IsGroup, IsGroup, IsList, IsList ] );


#############################################################################
##
#O  GroupHomomorphismByImages( <G>, <H>, <gensG>, <gensH> )
##
GroupHomomorphismByImages := NewOperation( "GroupHomomorphismByImages",
    [ IsGroup, IsGroup, IsList, IsList ] );


#############################################################################
##
#O  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . map onto factor group
##
NaturalHomomorphismByNormalSubgroup := NewOperation(
    "NaturalHomomorphismByNormalSubgroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  NaturalHomomorphismByNormalSubgroupInParent( <N> )  .  if G is the parent
##
NaturalHomomorphismByNormalSubgroupInParent := NewAttribute(
    "NaturalHomomorphismByNormalSubgroupInParent", IsGroup );


IsGroupGeneralMappingByImages := NewRepresentation
    ( "IsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep,
      [ "generators", "genimages", "elements", "images" ] );

IsGroupGeneralMappingByPcgs := NewRepresentation
    ( "IsGroupGeneralMappingByPcgs",
      IsGroupGeneralMappingByImages, [ "pcgs", "generators", "genimages" ] );

IsGroupGeneralMappingByAsGroupGeneralMappingByImages := NewRepresentation
    ( "IsGroupGeneralMappingByAsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep,
      [  ] );

AsGroupGeneralMappingByImages := NewAttribute( "AsGroupGeneralMappingByImages",
    IsGroupGeneralMapping );
SetAsGroupGeneralMappingByImages := Setter( AsGroupGeneralMappingByImages );
HasAsGroupGeneralMappingByImages := Tester( AsGroupGeneralMappingByImages );

InnerAutomorphism := NewOperation( "InnerAutomorphism",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );

IsInnerAutomorphismRep := NewRepresentation( "IsInnerAutomorphismRep",
    IsGroupHomomorphism and IsBijective and IsAttributeStoringRep
    and IsMultiplicativeElementWithInverse and IsSPGeneralMapping,
    [ "conjugator" ] );


#############################################################################
##
#R  IsNaturalHomomorphismPcGroupRep . . . . . . . . natural hom in a pc group
##
IsNaturalHomomorphismPcGroupRep := NewRepresentation
    ( "IsNaturalHomomorphismPcGroupRep",
      IsGroupHomomorphism and IsSurjective and IsSPGeneralMapping and
      IsAttributeStoringRep,
      [ "pcgsSource", "pcgsRange" ] );

FilterGroupGeneralMappingByImages := NewOperationArgs(
    "FilterGroupGeneralMappingByImages" );

MakeMapping := NewOperationArgs( "MakeMapping" );
GroupIsomorphismByFunctions := NewOperationArgs(
    "GroupIsomorphismByFunctions" );

IsomorphismPermGroup := NewAttribute("IsomorphismPermGroup",IsGroup);

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  ghom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
