TestMaximals := function( dim )
    local l, le, ce, so, i, G, n, m, k, lst, x;

    # the numbers
    if dim = 2 then l := 17; fi;
    if dim = 3 then l := 230; fi;

    # the flags
    le := rec( latticeequal := true );
    ce := rec( classequal := true, primes := [2,3,5] );
    so := rec( primes := [2,3,5] );

    # loop
    for i in [1..l] do
        G := SpaceGroupIT( dim, i );

        # lattice
        Print("max, start lattice equal of group ",[dim,i],"\n");
        n := Length( MaximalSubgroupClassReps( G, le ) );

        # class
        Print("max, start class equal of group ",[dim,i],"\n");
        lst :=  Flat( MaximalSubgroupClassReps( G, ce ) );
        for x in lst do CheckTranslationBasis(x); od;
        m := Length( lst );

        # primes
        Print("max, start with primes of group ",[dim,i],"\n");
        k := Length( MaximalSubgroupClassReps( G, so ) );

        # compare
        Print("\n");
        if not n+m = k then
            Error("wrong numbers ");
        fi;
    od;
end;

TestWyckoff := function( dim )
    local l, i, G;

    # the numbers
    if dim = 2 then l := 17; fi;
    if dim = 3 then l := 230; fi;

    # just loop
    for i in [1..l] do
        G := SpaceGroupIT( dim, i );
        Print("wyckoff, start group ",[dim,i],"\n");
        WyckoffPositions( G );
    od;

end;

TestZassenhaus := function( dim )
    local l, i, G;

    # the numbers
    if dim = 2 then l := 17; fi;
    if dim = 3 then l := 230; fi;

    # just loop
    for i in [1..l] do
        G := SpaceGroupIT( dim, i );
        Print("zass, start group ",[dim,i],"\n");
        SpaceGroupsByPointGroup( PointGroup(G) );
    od;

end;

TestMaximals(2);
TestMaximals(3);
TestWyckoff(2);
TestWyckoff(3);
TestZassenhaus(2);
TestZassenhaus(3);
