#############################################################################
##
#F CyclicDecomposition( G )
##
CyclicDecomposition := function( G )
    local pcp, rel, n, mat, i, row, new, gens, rels, g, coll;

    # pcp, rel, n;
    pcp := Pcp( G );
    rel := List( pcp, RelativeOrder );
    n   := Length( pcp );
    coll:= Collector( One( G ) );
    

    # create relator matrix for power relators
    mat := [];
    for i in [1..n] do
        if IsInt( rel[i] ) then
            row := Exponents( pcp[i]^rel[i] );
            row[i] := row[i] - rel[i];
            Add( mat, row );
        else
            Add( mat, List( [1..n], x -> 0 ) );
        fi;
    od;

    # solve matrix
    new := SmithNormalFormSQ( mat );

    # get gens
    gens := [];
    rels := [];
    for i in [1..n] do

        if new.D[i][i] = 0 then
            g := PcpElementByExponentsNC( coll, new.I[i] );
            Add( gens, g );
            Add( rels, infinity );
        elif new.D[i][i] > 1 then
            g := PcpElementByExponentsNC( coll, new.I[i] );
            Add( gens, g );
            Add( rels, new.D[i][i] );
        fi;
    od;

    return rec( Generators := gens, RelativeOrders := rels );
end;

TorsionSubgroupAbelianGroup := function( G )
    local cyc, sub;
    cyc := CyclicDecomposition( G );
    sub := cyc.Generators{Filtered( [1..Length(cyc.Generators)], 
                          x -> cyc.RelativeOrders[x] <> 0 )};
    return Subgroup(G, sub );
end;
