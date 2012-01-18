#############################################################################
##
#W  unithom.gi      Alnuth - ALgebraic NUmber THeory           Bettina Eick
#W                                                          Andreas Distler
##

#############################################################################
##
#F Images under unit group homs
##
InstallMethod( ImagesRepresentative, "for unit groups", FamSourceEqFamElm,
[IsGroupGeneralMappingByImages and IsUnitGroupIsomorphism,
 IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local F, H, e;
    F := FieldOfUnitGroup( Source( nat ) );
    H := Range( nat );
    e := ExponentsOfUnits( F, [h] )[1];
    return MappedVector( e, Pcp(H) );
end);
