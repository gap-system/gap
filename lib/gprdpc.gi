#############################################################################
##
#F  DirectProductPcGroupConstructor( G, H, groups, lenlist )
##
DirectProductPcGroupConstructor := function( G, H, groups, lenlist )
    local lenG, lenH, FG, gensFG, FH, gensFH, F, gens, rels, D, info, list,
          grps;

    lenG := Length( Pcgs( G ) );
    lenH := Length( Pcgs( H ) );
   
    FG := FpGroupPcGroup( G ); gensFG := GeneratorsOfGroup( FG.group );
    FH := FpGroupPcGroup( H ); gensFH := GeneratorsOfGroup( FH.group );

    F  := FreeGroup( lenG + lenH );
    gens := GeneratorsOfGroup( F );
 
    rels := List( FG.relators, x -> MappedWord( x, gensFG, 
                  gens{[1..lenG]} ) );
    Append( rels, 
            List( FH.relators, x -> MappedWord( x, gensFH,
                  gens{[lenG+1..lenG+lenH]} ) ) );
    
    # create direct product
    D := PcGroupFpGroup( rec( group := F, relators := rels ) );

    # create info
    grps := Concatenation( groups, [H] );
    list := Concatenation( lenlist, [lenG+lenH] );
    info := rec( groups := grps,
                 lenlist := list,
                 embeddings := [],
                 projections := [] );
    SetDirectProductInfo( D, info );
    return D;
end;
 
#############################################################################
##
#M  DirectProduct2( <G>, <H> )  . . . . . . . direct product of two pc groups
##
InstallMethod( DirectProduct2,
        "of pc group and pc groups",
        true, [ IsPcGroup, IsPcGroup ], 0,
    function( G, H )
    return DirectProductPcGroupConstructor(G, H, [G], [0, Length(Pcgs(G))]);
end );

InstallMethod( DirectProduct2,
        "of direct product and another pc group",
        true, [ IsPcGroup and HasDirectProductInfo, IsPcGroup ], 0,
    function( D, H )
    local info;
    info := DirectProductInfo( D );
    return DirectProductPcGroupConstructor(D, H, info.groups, info.lenlist);
end );

#############################################################################
##
#A EmbeddingOp
##
InstallMethod( EmbeddingOp,
        "of pc group and integer",
         true, 
         [ IsPcGroup and HasDirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then 
        return info.embeddings[i];
    fi;

    # compute embedding
    G   := info.groups[i];
    imgs := Pcgs(D){[info.lenlist[i]+1 .. info.lenlist[i+1]]};
    hom := GroupHomomorphismByImages( G, D, AsList( Pcgs(G) ), imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    SetDirectProductInfo( D, info );
    return hom;
end );

#############################################################################
##
#A ProjectionOp
##
InstallMethod( ProjectionOp,
        "of pc group and integer",
         true, 
         [ IsPcGroup and HasDirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom, N, list;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then 
        return info.projections[i];
    fi;

    # compute projection
    G    := info.groups[i];
    list := info.lenlist;
    imgs := Concatenation( List( [1..list[i]], x -> One( G ) ),
                           AsList( Pcgs(G) ),
                           List( [list[i+1]+1..Length(Pcgs(D))], x -> One(G)));
    hom := GroupHomomorphismByImages( D, G, AsList( Pcgs(D) ), imgs );
    N := Subgroup( D, Pcgs(D){Concatenation( [1..list[i]], 
                                             [list[i+1]+1..Length(Pcgs(D))])});
    SetIsSurjective( hom, true );
    # SetKernel( hom, N );

    # store information
    info.projections[i] := hom;
    SetDirectProductInfo( D, info );
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
    info := rec( factor := G,
                 subgroup := N,
                 embeddings := [],
                 projections := [] );
    SetSemidirectProductInfo( H, info );
    return H;
end );

InstallOtherMethod( SemidirectProduct,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject ],
    0,
function( G, M )
    return Extension( G, M, 0 );
end );

