#############################################################################
##
#W  isom.gi         Alnuth - ALgebraic NUmber THeory         Bjoern Assmann
##

#############################################################################
##
#F IsomorphismOfMultGroupByFieldEl( F, elms )
##
IsomorphismOfMultGroupByFieldEl := function( F, elms )
    local gens, rels, H, nat,CPCS,G;

    # calculate a constructive pc-sequence
    CPCS := CPCSOfGroupByFieldElements( F, elms ); 
    H := PCPOfGroupByFieldElementsByCPCS( F, CPCS );
    # new generating set for <elms>
    G := GroupByGenerators(CPCS.gens);
    nat := GroupHomomorphismByImagesNC( G, H, CPCS.gens, AsList(Pcp(H)) );
   
    # add infos
    SetIsBijective( nat, true );
    SetIsMultGroupByFieldElemsIsomorphism( nat, true );

    nat!.CPCS := CPCS;
    nat!.field := F;
    return nat;
end;

#############################################################################
##
#M Create isom to pcp group
##
InstallOtherMethod( IsomorphismPcpGroup, "for matrix fields", true,
[IsNumberFieldByMatrices, IsCollection], 0, 
function( F, elms ) return IsomorphismOfMultGroupByFieldEl( F, elms ); 
end);

InstallOtherMethod( IsomorphismPcpGroup, "for fields def. by polynomial", 
true, [IsNumberField and IsAlgebraicExtension, IsCollection], 0, 
function( F, elms ) return IsomorphismOfMultGroupByFieldEl( F, elms ); 
end);

#############################################################################
##
#M Images under  group by field elems isom
##
InstallMethod( ImagesRepresentative, "for group by field elems isom",
FamSourceEqFamElm,
[IsGroupGeneralMappingByImages and IsMultGroupByFieldElemsIsomorphism,
 IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local F, H, e, CPCS;
    F := nat!.field;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExpVectorOfGroupByFieldElements( F, CPCS,h );
    if e=fail then return fail; fi;
    return MappedVector( e, Pcp(H) );
end);
