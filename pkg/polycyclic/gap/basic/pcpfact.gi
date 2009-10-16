#############################################################################
##
#W  pcpfact.gi                   Polycyc                         Bettina Eick
##

#############################################################################
##
#M FactorGroupNC( H, N )
##
InstallMethod( FactorGroupNC, 
               true, [IsPcpGroup, IsPcpGroup], 0,
function( H, N )
    local  F;
    if not IsNormal( H, N ) then return fail; fi;
    if not IsSubgroup( H, N ) then H := ClosureGroup( H, N ); fi;

    F := PcpGroupByPcp( Pcp( H, N ) );
    UseFactorRelation( H, N, F );
    return F;
end );

#############################################################################
##
#F NaturalHomomorphismByPcp( pcp )
##
## compute factor and natural homomorphism.
## Setting up F and setting up the homomorphism are time-consuming.
## Speed up homomorphisms by `AddToIgsParallel'
##
InstallGlobalFunction( NaturalHomomorphismByPcp, function( pcp )
    local G, F, N, gens, imgs, hom;

    # G/N = F
    G := GroupOfPcp( pcp );
    N := SubgroupByIgs( G, DenominatorOfPcp( pcp ) );
    F := PcpGroupByPcp( pcp );
    UseFactorRelation( G, N, F );

    # get generators in G and images in F
    gens := ShallowCopy( GeneratorsOfPcp( pcp ) );
    imgs := ShallowCopy( Igs( F ) );
    Append( gens, DenominatorOfPcp( pcp ) );
    Append( imgs, List( DenominatorOfPcp( pcp ), x -> One(F) ) );

    # set up homomorphism
    hom := GroupHomomorphismByImagesNC( G, F, gens, imgs );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );
    return hom;
end );

#############################################################################
##
#F NaturalHomomorphism( G, N )
##
InstallMethod( NaturalHomomorphism, 
        "for pcp groups", true, [IsPcpGroup, IsPcpGroup], 0,
function( G, N )
    if Size(N) = 1 then return IdentityMapping( G ); fi;
    return NaturalHomomorphismByPcp( Pcp( G, N ) );
end );

InstallMethod( NaturalHomomorphismByNormalSubgroupNCOrig, 
        "for pcp groups", true, [IsPcpGroup, IsPcpGroup], 0,
function( G, N ) return NaturalHomomorphism(G,N); end );

        
