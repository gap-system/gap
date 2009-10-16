#############################################################################
##
#W  fitting.gi                   Polycyc                         Bettina Eick
##
##  Fitting subgroup, Centre, FCCentre and NilpotentByAbelianByFiniteSeries.
##

#############################################################################
##
#A SemiSimpleEfaSeries( G )
##
SemiSimpleEfaSeriesPcpGroup := function(G)
    local efas, pcps, refs, i, rels, d, mats, subs, j, gens, U, f;

    efas := EfaSeries( G );
    pcps := PcpsBySeries( efas, "snf" );
    refs := [G];

    # loop over series and refine each factor
    for i in [1..Length(pcps)] do

        # compute radical series
        rels := RelativeOrdersOfPcp( pcps[i] );
        mats := LinearActionOnPcp( Igs(G), pcps[i] ); 
        d := Length( rels );
        if rels[1] > 0 then 
            f := GF( rels[1] );
            mats := InducedByField( mats, f );
            subs := RadicalSeriesOfFiniteModule( mats, d, f );
        fi;
        if rels[1] = 0 then 
            subs := RadicalSeriesOfRationalModule( mats, d );
            subs := List( subs, x -> PurifyRationalBase( x ) );
        fi;

        # refine pcp by subs
        for j in [2..Length(subs)] do
            gens := List( subs[j], x -> MappedVector(x, pcps[i]) );
            gens := AddIgsToIgs( gens, DenominatorOfPcp( pcps[i] ) );
            U := SubgroupByIgs( G, gens );
            Add( refs, U );
        od;
    od;

    # that's it
    return refs;
end;

InstallMethod( SemiSimpleEfaSeries, 
               "for pcp groups", true, [IsPcpGroup], 0,
function( G ) return SemiSimpleEfaSeriesPcpGroup(G); end );

## return LowerCentralSeries for nilpotent groups?

#############################################################################
##
#F FittingSubgroup( G )
##
FittingSubgroupPcpGroup := function( G )
    local efas, pcps, l, F, i;

    efas := SemiSimpleEfaSeries( G );
    pcps := PcpsBySeries( efas, "snf" ); 
    l := Length( efas ) - 1;
    Info( InfoPcpGrp, 1, "determined semisimple series of length ",l);
    
    # compute centralizer of ssefa - finite cases first
    F := G;
    for i in [1..l] do
        Info( InfoPcpGrp, 1, "centralize ",i,"th layer - finite");
        F := KernelOfFiniteAction( F, pcps[i] );
        if RelativeOrdersOfPcp(pcps[i])[1] = 0 then 
            Info( InfoPcpGrp, 1, "centralize ",i,"th layer - infinite");
            F := KernelOfCongruenceAction( F, pcps[i] );
        fi;
    od;

    return F;
end;

InstallMethod( FittingSubgroup, 
               "for pcp groups", true, [IsPcpGroup and IsNilpotentGroup], 0,
function( G ) return G; end );

InstallMethod( FittingSubgroup, 
               "for pcp groups", true, [IsPcpGroup], 0,
function( G )
    local F;
    F := FittingSubgroupPcpGroup(G); 
    SetIsNilpotentGroup( F, true );
    if IndexNC( G, F ) = 1 then SetIsNilpotentGroup( G, true ); fi;
    return F;
end );

#############################################################################
##
#F IsNilpotentByFinite( G )
##
IsNilpotentByFinitePcpGroup := function( G )
    local efas, pcps, l, F, i, mats, idmt;

    efas := SemiSimpleEfaSeries( G );
    pcps := PcpsBySeries( efas, "snf" );
    l := Length( efas ) - 1;
    Info( InfoPcpGrp, 1, "determined semisimple series of length ",l);

    F := G;
    for i in [1..l] do
        Info( InfoPcpGrp, 1, "centralize ",i,"th layer");
        F := KernelOfFiniteAction( F, pcps[i] );
        if RelativeOrdersOfPcp(pcps[i])[1] = 0 then
            mats := LinearActionOnPcp( Igs(F), pcps[i] );
            idmt := IdentityMat( Length( pcps[i] ) );
            if ForAny( mats, x -> x <> idmt ) then return false; fi;
        fi;
    od;
    return true;
end;

InstallMethod( IsNilpotentByFinite,
               "for pcp groups", true, [IsPcpGroup], 0,
function( G ) return IsNilpotentByFinitePcpGroup( G ); end );

InstallMethod( IsNilpotentByFinite,
               "for pcp groups", true, [IsPcpGroup and IsNilpotentGroup], 0,
function( G ) return true; end );

#############################################################################
##
#F Centre( G )
##
CentrePcpGroup := function( G )
    local F, C, pcp, mat, rel, fix, i, gens, g;

    # compute Z(Fit(G))
    F := FittingSubgroup( G );
    C := Centre( F );

    # find iterated centralizer under action of G
    gens := Pcp( G, F );
    for g in Reversed(AsList( gens )) do

        # get pcp and its relation matrix
        pcp := Pcp( C, "snf" );
        rel := ExponentRelationMatrix( pcp );
        if Length( pcp ) = 0 then return C; fi;

        # compute action by g on pcp
        mat := LinearActionOnPcp( [g], pcp )[1];
        mat := mat - mat^0;
        Append( mat, rel );

        # compute fixed point space
        fix := PcpNullspaceIntMat( mat, Length( mat ) );
        for i in [1..Length(fix)] do
            fix[i] := MappedVector( fix[i]{[1..Length(pcp)]}, pcp );
        od;
        C := Subgroup( G, fix );
    od;
    return C;
end;

InstallMethod( Centre, 
               "for pcp groups", true, [IsPcpGroup], 0,
function( G ) 
    if IsAbelian(G) then 
        return G;
    elif IsNilpotentGroup(G) then 
        return CentreNilpotentPcpGroup(G);
    else
        return CentrePcpGroup(G); 
    fi;
end );

#############################################################################
##
#F UpperCentralSeries( G )
##
UpperCentralSeriesPcpGroup := function( G )
    local C, upp, nat, N, H;
    C := TrivialSubgroup(G);
    upp := [C];
    N := Centre(G);
    while IndexNC( N, C ) > 1 do
        C := N;
        Add( upp, C );
        nat := NaturalHomomorphism( G, C );
        H := Image( nat );
        N := PreImage( nat, Centre(H) );
    od;
    return Reversed( upp );
end;

InstallMethod( UpperCentralSeriesOfGroup, true, [IsPcpGroup], 0,
function( G )
    if IsNilpotentGroup(G) then 
        return UpperCentralSeriesNilpotentPcpGroup(G);
    fi;
    return UpperCentralSeriesPcpGroup(G);
end );


#############################################################################
##  
#F FCCentre( G )
##  
FCCentrePcpGroup := function( G )
    local N, hom, H, F, C, K, gens, g, pcp, mat, fix;

    # mod out torsion
    N := NormalTorsionSubgroup( G );
    hom := NaturalHomomorphism( G, N );
    H := Image( hom );

    # compute Z(Fit(H))
    F := FittingSubgroup( H );
    C := Centre( F );
    if Size(C) = 1 then return N; fi;

    # find iterated centralizer under action of K_p(G)
    K := KernelOfFiniteAction( H, Pcp(C) );
    gens := Pcp( K, F );
    for g in AsList( gens ) do

        # get pcp 
        pcp := Pcp( C ); 
        if Length( pcp ) = 0 then return C; fi;

        # compute action by g on pcp
        mat := LinearActionOnPcp( [g], pcp )[1];
        mat := mat - mat^0;

        # compute fixed point space
        fix := PcpNullspaceIntMat( mat, Length( mat ) );
        C := Subgroup( C, List( fix, x -> MappedVector( x, pcp ) ) );
    od;
    return PreImage( hom, C );
end;

InstallMethod( FCCentre, 
               "FCCentre for pcp groups", true, [IsPcpGroup], 0,
function( G ) 
    if IsFinite(G) then return G; fi;
    return FCCentrePcpGroup(G);
end );

InstallMethod( FCCentre, 
               "FCCentre for finite groups", true, [IsGroup and IsFinite], 0,
function( G ) return G; end );

#############################################################################
##  
#F NilpotentByAbelianByFiniteSeries( G )
##
InstallGlobalFunction( NilpotentByAbelianByFiniteSeries, function( G )
    local F, U, nath, L, A;

    # first step - get the Fitting subgroup and check its index
    F := FittingSubgroup( G );
    U := TrivialSubgroup( G );
    if IndexNC( G, F ) < infinity then return [G, F, F, U]; fi;

    # if this is not sufficient, then use Fitting factor
    nath := NaturalHomomorphism( G, F );
    L := FittingSubgroup( Image( nath ) );
    A := PreImage( nath, Centre(L) );
    if IndexNC( G, A ) = infinity then Error("wrong subgroup"); fi;
    return [G, A, F, U];
end );

