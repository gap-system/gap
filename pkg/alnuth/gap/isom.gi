#############################################################################
##
#W  isom.gi             Alnuth -  Kant interface               Bjoern Assmann
##

#############################################################################
##
#F IsomorphismOfMultGroupByFieldEl( F, elms )
##
IsomorphismOfMultGroupByFieldEl := function( F, elms )
    local gens, rels, H, nat,CPCS,G;

    # calculate a constructive pc-sequenz
    CPCS := CPCSOfGroupByFieldElements( F, elms ); 
    H := PCPOfGroupByFieldElementsByCPCS( F, CPCS );
    # new generating set for <elms>
    G := GroupByGenerators(CPCS.gens);
    nat := GroupHomomorphismByImagesNC( G, H, CPCS.gens, AsList(Pcp(H)) );
   
    # add infos
    SetIsBijective( nat, true );
    SetIsMapping( nat, true );
    SetKernelOfMultiplicativeGeneralMapping( nat, TrivialSubgroup( G ) );
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
#M Preimages under group field elements isom
##
InstallMethod( PreImagesRepresentative,"for group by field elems isom", true,
[IsMultGroupByFieldElemsIsomorphism, IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local G, e;
    G := Source( nat );
    e := ExponentsByPcp( h, Pcp( Range(nat) ) );
    return MappedVector( e, GeneratorsOfGroup( G ) );
end);

#############################################################################
##
#M Images under  group by field elems isom
##
InstallMethod( ImagesRepresentative, "for group by field elems isom", true,
[IsMultGroupByFieldElemsIsomorphism, IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local F, H, e, CPCS;
    F := nat!.field;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExpVectorOfGroupByFieldElements( F, CPCS,h );
    if e=fail then return fail; fi;
    return MappedVector( e, Pcp(H) );
end);

InstallMethod( ImageElm, "for group by field elems isom", true,
[IsMultGroupByFieldElemsIsomorphism, IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local F, H, e, CPCS;
    F := nat!.field;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExpVectorOfGroupByFieldElements( F, CPCS,h );
    if e=fail then return fail; fi;
    return MappedVector( e, Pcp(H) );
end);

InstallMethod( ImagesSet,"for group by field elems isom", true,
[IsMultGroupByFieldElemsIsomorphism, IsCollection], 0,
function( nat, elms )
    local F, H, e, CPCS,exps,h;
    F := nat!.field;
    CPCS := nat!.CPCS;
    H := Range( nat );
    exps := [];
    for h in elms do
        e := ExpVectorOfGroupByFieldElements( F, CPCS,h ); 
        Add(exps, e );
    od;
    return List( exps, function(x)
                          if x=fail then return fail;
                          else return MappedVector( x, Pcp(H) );
                          fi;
                          end );
end);















