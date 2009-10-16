#############################################################################
##
## functions to create examples for pc groups
##

RandomVector := function( n, i, rels )
    local vec, j, k, x;
    vec := List( [1..n], x -> 0 );
    for j in [i+1..n] do
        x := Random( [1..n] );
        if x = 1 then
            if IsBound( rels[j] ) then
                k := Random( [1..rels[j]] );
                if k = rels[j] then k := 0; fi;
            else
                k := Random( Integers );
                if k < 0 then k := -k; fi;
            fi;
            vec[j] := k;
        fi;
    od;
    return vec;
end;

WordByVector := function( expo )
    local word, i;
    word := [];
    for i in [1..Length(expo)] do
        if expo[i] <> 0 then
            Add( word, i );
            Add( word, expo[i] );
        fi;
    od;
    return word;
end;

RandomPcpLoop := function( n, rels )
    local coll, i, expo, word, j;

    coll := FromTheLeftCollector( n );
    for i in [1..n] do
        if IsBound( rels[i] ) then
            SetRelativeOrder( coll, i, rels[i] );
            expo := RandomVector( n, i, rels );
            word := WordByVector( expo );
            SetPower( coll, i, word );
        fi;
        for j in [1..i-1] do
            expo := RandomVector( n, j, rels );
            word := WordByVector( expo );
            SetCommutator( coll, i, j, word );
        od;
    od;
    UpdatePolycyclicCollector( coll );
    return PcpGroupByCollector( coll ); 
end;

NilpotentRandomPcpLoop := function( n, rels )
    local coll, i, expo, word, j, G;

    coll := FromTheLeftCollector( n );
    for i in [1..n] do
        if IsBound( rels[i] ) then
            SetRelativeOrder( coll, i, rels[i] );
            expo := RandomVector( n, i, rels );
            word := WordByVector( expo );
            SetPower( coll, i, word );
        fi;
        for j in [1..i-1] do
            expo := RandomVector( n, i, rels );
            word := WordByVector( expo );
            SetCommutator( coll, i, j, word );
        od;
    od;
    UpdatePolycyclicCollector( coll );
    G := PcpGroupByCollector( coll ); 
    SetIsNilpotentGroup( G, true );
    return G;
end;

RandomPcpGroup := function( n, rels, nil )
    local found, G;
    found := false;
    while not found do
        # Print("next try \n");
        if nil then
            G := NilpotentRandomPcpLoop( n, rels );
        else
            G := RandomPcpLoop( n, rels );
        fi;
        found := IsConfluent( Collector( One( G ) ) );
    od;
    return G;
end;

#############################################################################


coll := FromTheLeftCollector( 2 );
SetRelativeOrder( coll, 1, 2 );
UpdatePolycyclicCollector( coll );

coll1 := FromTheLeftCollector( 2 );
SetRelativeOrder( coll1, 1, 2 );
SetConjugate( coll1, 2, 1, [2,-1] );
UpdatePolycyclicCollector( coll1 );

coll2 := FromTheLeftCollector( 4 );
SetRelativeOrder( coll2, 1, 2 );
SetPower( coll2, 1, [4,1] );
SetConjugate( coll2, 2,1, [2,-1] );
SetConjugate( coll2, 3,1, [3,-1] );
SetConjugate( coll2, 3,2, [3,1,4,2] );
UpdatePolycyclicCollector( coll2 );

coll3 := FromTheLeftCollector( 2 );
SetRelativeOrder( coll3, 1, 2 );
SetRelativeOrder( coll3, 2, 3 );
SetConjugate( coll3, 2, 1, [2,2] );
UpdatePolycyclicCollector( coll3 );

f := FreeGroup( 2 );
g := GeneratorsOfGroup( f );
single := SingleCollector( g, [2,3] );
SetConjugate( single, 2, 1, g[2]^2 );
