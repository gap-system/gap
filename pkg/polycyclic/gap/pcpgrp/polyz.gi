############################################################################
##
#W  polyz.gi                    Polycyc                         Bettina Eick
##

############################################################################
##
#F GeneratorsOfCentralizerOfPcp( gens, pcp )
##
GeneratorsOfCentralizerOfPcp := function( gens, pcp )
    local idm, v, mats;
    idm := IdentityMat( Length( pcp ), GF( RelativeOrdersOfPcp(pcp)[1] ) );
    for v in idm do
        mats := LinearActionOnPcp( gens, pcp );
        gens := PcpOrbitStabilizer( v, gens, mats, OnRight ).stab;
    od;
    return gens;
end;

############################################################################
##
#F PolyZNormalSubgroup( G )
##
## returns a normal subgroup N of finite index in G such that N has a
## normal series with free abelian factors. 
##
InstallGlobalFunction( PolyZNormalSubgroup, function( G )
    local N, F, U, ser, nat, pcps, m, i, free, j, p;

    # set up
    N   := TrivialSubgroup( G );
    ser := [N];
    nat := IdentityMapping( G );
    F   := Image( nat );

    # loop
    while not IsFinite( F ) do

        # get gens of free abelian normal subgroup
        pcps := PcpsOfEfaSeries(F);
        m    := Length( pcps );
        i    := m;
        while RelativeOrdersOfPcp( pcps[i] )[1] > 0 do
            i := i - 1;
        od; 
        free := AsList( pcps[i] );
        for j in [i+1..m] do
            free := GeneratorsOfCentralizerOfPcp( free, pcps[j] );
            p    := RelativeOrdersOfPcp( pcps[j] )[1];
            if p = 2 then
                free := List( free, x -> x^4 );
            else
                free := List( free, x -> x^p );
            fi;
        od;

        # reset  
        U := Subgroup( F, free );
        N := PreImage( nat, U );
        Add( ser, N );
        nat := NaturalHomomorphism( G, N );
        F := Image( nat );
    od;
    SetEfaSeries( N, Reversed( ser ) );
    return N;
end );

