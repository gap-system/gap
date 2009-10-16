#############################################################################
##
#W  unithom.gi             Alnuth - Kant interface               Bettina Eick
##

#############################################################################
##
#M Create unit group hom
##
InstallMethod( IsomorphismPcpGroup, "for unit group", true,
[IsUnitGroup ], 0, function( G ) return G!.nathom; end);

InstallMethod( IsomorphismPcpGroup,"for unit group which are matrix groups",
 true,
[IsUnitGroup and IsMatrixGroup], 0, function( G ) return G!.nathom;
end);

#############################################################################
##
#F Preimages under unit group homs
##
InstallMethod( PreImagesRepresentative, "for unit group homs", true,
[IsUnitGroupIsomorphism, IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local G, e;
    G := Source( nat );
    e := ExponentsByPcp( h, Pcp( Range(nat) ) );
    return MappedVector( e, GeneratorsOfGroup( G ) );
end);

#############################################################################
##
#F Images under unit group homs
##
InstallMethod( ImagesRepresentative, "for unit groups", true,
[IsUnitGroupIsomorphism, IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local F, H, e;
    F := FieldOfUnitGroup( Source( nat ) );
    H := Range( nat );
    e := ExponentsOfUnits( F, [h] )[1];
    return MappedVector( e, Pcp(H) );
end);

InstallMethod( ImageElm, "for unit groups", true,
[IsUnitGroupIsomorphism, IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local F, H, e;
    F := FieldOfUnitGroup( Source( nat ) );
    H := Range( nat );
    e := ExponentsOfUnits( F, [h] )[1];
    return MappedVector( e, Pcp(H) );
end);

InstallMethod( ImagesSet, "for unit groups", true,
[IsUnitGroupIsomorphism, IsCollection], 0,
function( nat, elms )
    local F, H, e;
    F := FieldOfUnitGroup( Source( nat ) );
    H := Range( nat );
    e := ExponentsOfUnits( F, elms );
    return List( e, x -> MappedVector( x, Pcp(H) ) );
end);







