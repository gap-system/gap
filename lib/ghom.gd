#############################################################################
##
#W  ghom.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.15  1996/12/19 09:58:54  htheisse
#H  added revision lines
#H
##
Revision.ghom_gd :=
    "@(#)$Id$";

RespectsMultiplication := NewProperty( "RespectsMultiplication",
                                  IsGeneralMapping );
SetRespectsMultiplication := Setter( RespectsMultiplication );
HasRespectsMultiplication := Tester( RespectsMultiplication );

RespectsOne := NewProperty( "RespectsOne", IsGeneralMapping );
SetRespectsOne := Setter( RespectsOne );
HasRespectsOne := Tester( RespectsOne );

RespectsInverses := NewProperty( "RespectsInverses", IsGeneralMapping );
SetRespectsInverses := Setter( RespectsInverses );
HasRespectsInverses := Tester( RespectsInverses );

IsMonoidGeneralMapping := IsGeneralMapping
                          and RespectsMultiplication and RespectsOne;
IsGroupGeneralMapping := IsMonoidGeneralMapping and RespectsInverses;
IsMonoidHomomorphism := IsMapping and RespectsMultiplication and RespectsOne;
IsGroupHomomorphism := IsMonoidHomomorphism and RespectsInverses;

Kernel := NewAttribute( "Kernel", IsMonoidGeneralMapping );
SetKernel := Setter( Kernel );
HasKernel := Tester( Kernel );

CoKernel := NewAttribute( "CoKernel", IsMonoidGeneralMapping );
SetCoKernel := Setter( CoKernel );
HasCoKernel := Tester( CoKernel );

IsGroupGeneralMappingByImages := NewRepresentation
    ( "IsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsAttributeStoringRep,
      [ "generators", "genimages", "elements", "images" ] );

IsGroupGeneralMappingByPcgs := NewRepresentation
    ( "IsGroupGeneralMappingByPcgs",
      IsGroupGeneralMappingByImages, [ "pcgs", "generators", "genimages" ] );

IsGroupGeneralMappingByAsGroupGeneralMappingByImages := NewRepresentation
    ( "IsGroupGeneralMappingByAsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsAttributeStoringRep, [  ] );

AsGroupGeneralMappingByImages := NewAttribute( "AsGroupGeneralMappingByImages",
    IsGroupGeneralMapping );
SetAsGroupGeneralMappingByImages := Setter( AsGroupGeneralMappingByImages );
HasAsGroupGeneralMappingByImages := Tester( AsGroupGeneralMappingByImages );

GroupGeneralMappingByImages := NewOperation( "GroupGeneralMappingByImages",
    [ IsGroup, IsGroup, IsList, IsList ] );
GroupHomomorphismByImages := NewOperation( "GroupHomomorphismByImages",
    [ IsGroup, IsGroup, IsList, IsList ] );

InnerAutomorphism := NewOperation( "InnerAutomorphism",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );

IsInnerAutomorphismRep := NewRepresentation( "IsInnerAutomorphismRep",
    IsGroupHomomorphism and IsBijective and IsAttributeStoringRep
    and IsMultiplicativeElementWithInverse, [ "conjugator" ] );

#############################################################################
##
#O  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . map onto factor group
##
NaturalHomomorphismByNormalSubgroup := NewOperation
    ( "NaturalHomomorphismByNormalSubgroup", [ IsGroup, IsGroup ] );

#############################################################################
##
#A  NaturalHomomorphismByNormalSubgroupInParent( <N> )  .  if G is the parent
##
NaturalHomomorphismByNormalSubgroupInParent := NewAttribute
    ( "NaturalHomomorphismByNormalSubgroupInParent", IsGroup );

#############################################################################
##
#R  IsNaturalHomomorphismPcGroupRep . . . . . . . . natural hom in a pc group
##
##  In this representation, the range is always a pc group. This fact is used
##  by the methods for `IsLeftQuotientNaturalHomomorphismsPcGroup'.
##
IsNaturalHomomorphismPcGroupRep := NewRepresentation
    ( "IsNaturalHomomorphismPcGroupRep",
      IsGroupHomomorphism and IsSurjective and
      IsComponentObjectRep and IsAttributeStoringRep,
      [ "pcgsSource", "pcgsRange" ] );

#############################################################################
##
#R  IsLeftQuotientNaturalHomomorphisms  . . . natural homomorphism G/N -> G/M
##
IsLeftQuotientNaturalHomomorphisms := NewRepresentation
    ( "IsLeftQuotientNaturalHomomorphisms",
      IsGroupHomomorphism and IsSurjective and
      IsComponentObjectRep and IsAttributeStoringRep,
      [ "modM", "modN" ] );

#############################################################################
##
#R  IsLeftQuotientNaturalHomomorphismsPcGroup .  nat. homomorphism G/N -> G/M
##
##  Because   of     the  remark   after   `IsNaturalHomomorphismPcGroupRep',
##  homomorphisms in this representation  always go from a  pc group to  a pc
##  group.
##
IsLeftQuotientNaturalHomomorphismsPcGroup := NewRepresentation
    ( "IsLeftQuotientNaturalHomomorphismsPcGroup",
      IsLeftQuotientNaturalHomomorphisms,
      [ "modM", "modN" ] );

FilterGroupGeneralMappingByImages := NewOperationArgs( "FilterGroupGeneralMappingByImages" );
MakeMapping := NewOperationArgs( "MakeMapping" );
GroupIsomorphismByFunctions := NewOperationArgs( "GroupIsomorphismByFunctions" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  12345678.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
