#############################################################################
##
#W  grphoms.gi                   Polycyc                         Bettina Eick
##

#############################################################################
##
## Functions to deal with homomorphisms to and from pcp groups.
##

#############################################################################
##
#M GGMBI( G, H ) . . . . . . . . . . . . . . . . . . . for G and H pcp groups
##
InstallMethod( GroupGeneralMappingByImages,
               true, [IsPcpGroup, IsPcpGroup, IsList, IsList], 0,
function( G, H, gens, imgs )
    local new, filt, type, hom;
 
    if Length( gens ) <> Length( imgs ) then
        Error("gens and imgs must have same length");
    fi;

    if gens <> Igs(G) then
        new := IgsParallel( gens, imgs );
    else
        new := [gens, imgs];
    fi;
    new := [Immutable(new[1]), Immutable(new[2])];

    filt := IsGroupGeneralMappingByImages and IsTotal
            and IsPcpGHBI and IsFromPcpGHBI and IsToPcpGHBI 
            and HasSource and HasRange and HasMappingGeneratorsImages;

    type := NewType( GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                     ElementsFamily( FamilyObj( H ) ) ), filt );

    hom  := rec( );
    ObjectifyWithAttributes( hom, type, Source, G, Range, H,
                             MappingGeneratorsImages, new );
    return hom;
end );

InstallMethod( GroupGeneralMappingByImages,
               true, [IsPcpGroup, IsGroup, IsList, IsList], 0,
function( G, H, gens, imgs )
    local new, filt, type, hom;
 
    if Length( gens ) <> Length( imgs ) then
        Error("gens and imgs must have same length");
    fi;

    if gens <> Igs(G) then
        new := IgsParallel( gens, imgs );
    else
        new := [gens, imgs];
    fi;
    new := [Immutable(new[1]), Immutable(new[2])];

    filt := IsGroupGeneralMappingByImages and IsTotal
            and IsPcpGHBI and IsFromPcpGHBI 
            and HasSource and HasRange and HasMappingGeneratorsImages;

    if IsFpGroup(H) then 
        filt := filt and IsToFpGroupGeneralMappingByImages;
    elif IsPcGroup(H) then 
        filt := filt and IsToPcGroupGeneralMappingByImages;
    elif IsPermGroup(H) then 
        filt := filt and IsToPermGroupGeneralMappingByImages;
    fi;

    type := NewType( GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                     ElementsFamily( FamilyObj( H ) ) ), filt );

    hom  := rec( );
    ObjectifyWithAttributes( hom, type, Source, G, Range, H,
                             MappingGeneratorsImages, new );
    return hom;
end );

InstallMethod( GroupGeneralMappingByImages,
               true, [IsGroup, IsPcpGroup, IsList, IsList], 0,
function( G, H, gens, imgs )
    local new, filt, type, hom;

    if Length( gens ) <> Length( imgs ) then
        Error("gens and imgs must have same length");
    fi;
    
    new := [Immutable(gens), Immutable(imgs)];

    filt := IsGroupGeneralMappingByImages and IsTotal
            and IsPcpGHBI and IsToPcpGHBI 
            and HasSource and HasRange and HasMappingGeneratorsImages;

    if IsFpGroup(G) then 
        filt := filt and IsFromFpGroupGeneralMappingByImages;
    fi;

    type := NewType( GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                     ElementsFamily( FamilyObj( H ) ) ), filt );

    hom  := rec( );
    ObjectifyWithAttributes( hom, type, Source, G, Range, H,
                             MappingGeneratorsImages, new );
    return hom;
end );

#############################################################################
##
#M GHBI( G, H )
##
InstallMethod( GroupHomomorphismByImagesNC,
               true, [IsGroup, IsPcpGroup, IsList, IsList], 0,
function( G, H, gens, imgs )
    local hom;
    hom := GroupGeneralMappingByImages( G, H, gens, imgs );
    SetIsMapping(hom, true);
    SetIsSingleValued(hom,true);
    SetIsTotal(hom,true);
    return hom;
end );

InstallMethod( GroupHomomorphismByImagesNC,
               true, [IsPcpGroup, IsGroup, IsList, IsList], 0,
function( G, H, gens, imgs )
    local hom;
    hom := GroupGeneralMappingByImages( G, H, gens, imgs );
    SetIsMapping(hom, true);
    SetIsSingleValued(hom,true);
    SetIsTotal(hom,true);
    return hom;
end );

#############################################################################
##
#M IsPcpGroupHomomorphism( <map> )
##
IsPcpGroupHomomorphism := function(hom)
    local gens, imgs, i, a, b, j;

    # check relators 
    gens := MappingGeneratorsImages( hom )[1];
    imgs := MappingGeneratorsImages( hom )[2];
   
    for i in [1..Length( gens )] do
        if RelativeOrderPcp( gens[i] ) > 0 then
            a := gens[i]^RelativeOrderPcp( gens[i] );
            a := MappedVector(ExponentsByIgs(gens, a),imgs);
            b := imgs[i]^RelativeOrderPcp( gens[i] );
            if a <> b then return false; fi;
        fi;
        for j in [1..i-1] do
            a := gens[i] ^ gens[j];
            a := MappedVector(ExponentsByIgs(gens, a),imgs);
            b := imgs[i] ^ imgs[j];
            if a <> b then return false; fi;

            if RelativeOrderPcp( gens[i] ) = 0 then 
                a := gens[i] ^ (gens[j]^-1);
                a := MappedVector(ExponentsByIgs(gens, a),imgs);
                b := imgs[i] ^ (imgs[j]^-1);
                if a <> b then return false; fi;
            fi;
        od;
    od;
    return true;
end;

InstallMethod( IsSingleValued, true, [IsFromPcpGHBI], 0,
function(hom) return IsPcpGroupHomomorphism(hom); end );

InstallMethod( IsTotal, true, [IsFromPcpGHBI], 0,
function(hom) 
    return Subgroup(Source(hom),MappingGeneratorsImages(hom)[1])
           = Source(hom);
end );

#############################################################################
##
#M  \=
##
InstallMethod( \=,
               IsIdenticalObj, [ IsPcpGHBI, IsPcpGHBI ], SUM_FLAGS,
function( a, b )
    if a!.Source <> b!.Source then
        return false;
    elif a!.Range <> b!.Range then
        return false;
    elif MappingGeneratorsImages( a ) <> MappingGeneratorsImages( b ) then
        return false;
    fi;
    return true;
end );

#############################################################################
##
#M  \*
##
InstallMethod( CompositionMapping2, FamSource1EqFamRange2, 
               [ IsPcpGHBI, IsPcpGHBI ], SUM_FLAGS,
function( a, b )
  local hom;
  hom := GroupHomomorphismByImagesNC( Source(b), Range(a), 
                 MappingGeneratorsImages( b )[1],
                 List( MappingGeneratorsImages( b )[2], 
                       x -> ImagesRepresentative(a, x) ) );
  return hom;
end );

#############################################################################
##
#M  Images
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
               [ IsFromPcpGHBI, IsMultiplicativeElementWithInverse ], 
               SUM_FLAGS,
function( hom, elm )
    local g, h, e;
    g := MappingGeneratorsImages(hom)[1];
    h := MappingGeneratorsImages(hom)[2];
    e := ExponentsByIgs( g, elm );
    if IsEmpty(e) then return One(Range(hom)); fi;
    return MappedVector( e, h );
end );

#############################################################################
##
#M  AddPreimagesInfo - a helper
##
AddPreimagesInfo := function(hom)
    local  new;
    if IsBound( hom!.impcp ) then return; fi;
    new := IgsParallel( MappingGeneratorsImages(hom)[2],
                        MappingGeneratorsImages(hom)[1] );
    hom!.impcp := new[1];
    hom!.prpcp := new[2];
end;

#############################################################################
##
#M  PreImages
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
               [ IsToPcpGHBI, IsMultiplicativeElementWithInverse ], 
               SUM_FLAGS,
function( hom, elm )
    local new;
    AddPreimagesInfo(hom);
    if Length(hom!.impcp) = 0 then return One(hom!.Source); fi;
    return MappedVector(ExponentsByIgs(hom!.impcp, elm), hom!.prpcp);
end );

InstallMethod( PreImagesSet, true,
               [ IsPcpGHBI, IsPcpGroup ], SUM_FLAGS,
function( hom, U )
    local prei, kern;
    prei := List( Igs(U), x -> PreImagesRepresentative(hom,x) );
    kern := Igs( Kernel( hom ) );
    return SubgroupByIgs( Source(hom), kern, prei );
end );

InstallMethod( PreImagesSet, true,
               [ IsToPcpGHBI and IsInjective, IsPcpGroup ], SUM_FLAGS,
function( hom, U )
    local gens, prei;
    gens := GeneratorsOfGroup( U );
    prei := List( gens, x -> PreImagesRepresentative(hom,x) );
    return SubgroupNC( Source(hom), prei );
end );

#############################################################################
##
#M  Kernel
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
               true, [ IsPcpGHBI and IsFromPcpGHBI and IsToPcpGHBI], 
               SUM_FLAGS,
function( hom )
    local A, a, B, b, D, u, kern, i, g;
    
    # set up
    A := Source(hom);
    a := MappingGeneratorsImages(hom)[1];
    B := Range(hom);
    b := MappingGeneratorsImages(hom)[2];
    D := DirectProduct(B,A);
    u := Cgs(Subgroup(D, List([1..Length(a)], x ->
          Image(Embedding(D,1),b[x])*Image(Embedding(D,2),a[x]))));

    # filter kernel gens
    kern := [];
    for i in [1..Length(u)] do
        g := Image(Projection(D,1),u[i]);
        if g = One(B) then 
            Add(kern, Image(Projection(D,2),u[i]));
        fi;
    od;

    # create group
    return Subgroup( Source(hom), kern);
end );

#############################################################################
##
#M  IsInjective( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( IsInjective,
               true, [ IsPcpGHBI ], SUM_FLAGS,
function( hom )
    return Size( KernelOfMultiplicativeGeneralMapping(hom) ) = 1;
end );
