#############################################################################
##
#W  gprdpc.gi                   GAP library                      Bettina Eick
##
Revision.gprdpc_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  DirectProductOfPcGroups( list )
##
DirectProductOfPcGroups := function( list )
    local len, F, gensF, relsF, s, G, pcgsG, isoG, FG, relsG, gensG, n, D,
          info, first;

    len := Sum( List( list, x -> Length( Pcgs( x ) ) ) );
    F   := FreeGroup( len );
    gensF := GeneratorsOfGroup( F );
    relsF := [];

    s := 0;
    first := [1];
    for G in list do
        pcgsG := Pcgs( G );
        isoG  := IsomorphismFpGroupByPcgs( pcgsG, "F" );
        FG    := Image( isoG );
        relsG := RelatorsOfFpGroup( FG );
        gensG := GeneratorsOfGroup( FreeGroupOfFpGroup( FG ) );
        n     := s + Length( pcgsG );
        Append( relsF, List( relsG, 
                       x -> MappedWord( x, gensG, gensF{[s+1..n]} ) ) );
        s := n;
        Add( first, n+1 );
    od;

    # create direct product
    D := PcGroupFpGroup( F / relsF );

    # create info
    info := rec( groups := list,
                 first  := first,
                 embeddings := [],
                 projections := [] );
    SetDirectProductInfo( D, info );
    return D;
end;
 
#############################################################################
##
#A Embedding
##
InstallMethod( Embedding,
        "of pc group and integer",
         true, 
         [ IsPcGroup and HasDirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then 
        return info.embeddings[i];
    fi;

    # compute embedding
    G   := info.groups[i];
    gens := Pcgs( G );
    imgs := Pcgs(D){[info.first[i] .. info.first[i+1]-1]};
    hom := GroupHomomorphismByImages( G, D, gens, imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallMethod( Projection,
        "of pc group and integer",
         true, 
         [ IsPcGroup and HasDirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom, N, list, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then 
        return info.projections[i];
    fi;

    # compute projection
    G    := info.groups[i];
    gens := Pcgs( D );
    imgs := Concatenation( List( [1..info.first[i]-1], x -> One( G ) ),
                           Pcgs( G ),
                           List( [info.first[i+1]..Length(gens)], x -> One(G)));
    hom := GroupHomomorphismByImages( D, G, gens, imgs );
    N := Subgroup( D, gens{Concatenation( [1..info.first[i]-1], 
                           [info.first[i+1]..Length(gens)] )} );
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections[i] := hom;
    return hom;
end );

#############################################################################
##
#M SemidirectProduct
##
InstallMethod( SemidirectProduct,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsGroupHomomorphism, IsPcGroup ],
    0,
function( G, aut, N )
    local info, H;
    H := SplitExtension( G, aut, N );
    info := rec( groups := [G, N],
                 lenlist := [0, Length(Pcgs(G)), Length(Pcgs(H))],
                 embeddings := [],
                 projections := true );
    SetSemidirectProductInfo( H, info );
    return H;
end );

InstallOtherMethod( SemidirectProduct,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsRecord],
    0,
function( G, M )
    local H, info;
    H := Extension( G, M, 0 );
    info := rec( groups := [G, AbelianGroup( 
                 List([1..M.dimension], x -> Characteristic(M.field)) )],
                 lenlist := [0, Length(Pcgs(G)), Length(Pcgs(H))],
                 embeddings := [],
                 projections := true );
    SetSemidirectProductInfo( H, info );
    return H;
end );

InstallOtherMethod( SemidirectProduct,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsGroupHomomorphism],
    0,
function( G, pr )
    local U, M, H, info;
    U := Image( pr );
    M := rec( dimension  := DimensionOfMatrixGroup( U ),
              field      := FieldOfMatrixGroup( U ),
              generators := List( Pcgs( G ), x -> Image( pr, x ) ) );
    return SemidirectProduct( G, M );
end );

#############################################################################
##
#A Embedding
##
InstallMethod( Embedding,
        "of semidirect pc group and integer",
         true, 
         [ IsPcGroup and HasSemidirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom;

    # check
    info := SemidirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then 
        return info.embeddings[i];
    fi;

    # compute embedding
    G := info.groups[i];
    imgs := Pcgs(D){[info.lenlist[i]+1 .. info.lenlist[i+1]]};
    hom := GroupHomomorphismByImages( G, D, AsList( Pcgs(G) ), imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallOtherMethod( Projection,
        "of semidirect pc group and integer",
         true, 
         [ IsPcGroup and HasSemidirectProductInfo ],
         0,
    function( D )
    local info, G, imgs, hom, N, list;

    # check
    info := SemidirectProductInfo( D );
    if not IsBool( info.projections ) then
        return info.projections;
    fi;

    # compute projection
    G    := info.groups[1];
    list := info.lenlist;
    imgs := Concatenation( AsList( Pcgs(G) ),
                           List( [list[2]+1..list[3]], x -> One(G)) );
    hom := GroupHomomorphismByImages( D, G, AsList( Pcgs(D) ), imgs );
    N := Subgroup( D, Pcgs(D){[list[2]+1..list[3]]});
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections := hom;
    return hom;
end );

