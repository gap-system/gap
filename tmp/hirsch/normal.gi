#############################################################################
##
#F NormalClosure( K, U )
##
InstallMethod( NormalClosureOp, true, [IsPcpGroup, IsPcpGroup], 0,
function( K, U )
    local tmpN, id, gensK, pcpN, k, n, c, N;

    # take initial pcp
    tmpN := ShallowCopy( Pcp( U ) );
    if Length( tmpN ) = 0 then return U; fi;

    # take generating sets
    id := One( K );
    gensK := GeneratorsOfGroup(K);
    gensK := List( gensK, x -> ReducedPcpElement( tmpN, x ) );
    gensK := Filtered( gensK, x -> x <> id );

    # repeat until N becomes stable
    repeat
        pcpN := ShallowCopy( tmpN );
        tmpN := [];
        for k in gensK do
            for n in pcpN do
                c := ReducedPcpElement( pcpN, Comm( k, n ) );
                if c <> id then Add( tmpN, c ); fi;
            od;
        od;
        tmpN := AddToInducedPcp( pcpN, tmpN );
    until Length(tmpN) = Length(pcpN);

    # set up result
    N := Subgroup( Parent(U), pcpN );
    SetPcp( N, pcpN );
    return N; 
end);

