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
#O  NaturalHomomorphismByNormalSubgroupNC(<G>,<N> )
##
##  returns a homomorphism from <G> to another group whose kernel is <N>.
##  \GAP will try to select the image group as to make computations in it as
##  efficient as possible. As the factor group $<G>/<N>$ can be identified 
##  with the image of <G> this permits efficient computations in the factor
##  group. The `NC' variant does not check whether <N> is normal in <G>.
NaturalHomomorphismByNormalSubgroup:=
  NewOperationArgs("NaturalHomomorphismByNormalSubgroup");

tmp:= InParentFOA( "NaturalHomomorphismByNormalSubgroup", IsGroup, IsGroup,
              NewAttribute );
NaturalHomomorphismByNormalSubgroupNC       := tmp[1];
NaturalHomomorphismByNormalSubgroupOp       := tmp[2];
NaturalHomomorphismByNormalSubgroupInParent := tmp[3];
SetNaturalHomomorphismByNormalSubgroupInParent :=
  Setter( NaturalHomomorphismByNormalSubgroupInParent );
HasNaturalHomomorphismByNormalSubgroupInParent :=
  Tester( NaturalHomomorphismByNormalSubgroupInParent );


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

InstallAttributeMethodByGroupGeneralMappingByImages :=
  function( attr, value_filter )
    InstallMethod( attr, "via `AsGroupGeneralMappingByImages'", true,
            [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages ], 0,
            hom -> attr( AsGroupGeneralMappingByImages( hom ) ) );
    InstallMethod( Setter( attr ),
            "also for `AsGroupGeneralMappingByImages'", true,
            [ HasAsGroupGeneralMappingByImages, value_filter ], SUM_FLAGS,
            function( hom, value )
                local    asggmbi;

                asggmbi := AsGroupGeneralMappingByImages( hom );
                if not HasAsGroupGeneralMappingByImages( asggmbi )  then
                    Setter( attr )( asggmbi, value );
                fi;
                TryNextMethod();
            end );
end;
    
InnerAutomorphism := NewOperation( "InnerAutomorphism",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );

IsInnerAutomorphismRep := NewRepresentation( "IsInnerAutomorphismRep",
    IsGroupHomomorphism and IsBijective and IsAttributeStoringRep
    and IsSPGeneralMapping,
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

MakeMapping := NewOperationArgs( "MakeMapping" );

IsomorphismPermGroup := NewAttribute("IsomorphismPermGroup",IsGroup);
HasIsomorphismPermGroup := Tester( IsomorphismPermGroup );
SetIsomorphismPermGroup := Setter( IsomorphismPermGroup );

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
