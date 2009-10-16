
#Construction von einfachen Lie algebren "uber F = GF(2):
#
#- Sei n = dim(F). Dann gilt F <= SL(n,2). Finde F als Teilalgebra in
#  der SL.
#- W"ahle G <= GL(n,2) und finde alle F <= SL(n,2), die unter G invariant
#  sind.
#- Dazu: G operiert per Konjugation auf SL(n,2) und diese Operation 
#        entspricht der Operation auf dem Tensorprodukt. Berechne alle
#        minimalen Teilr"aume von G_T mit der Meataxe und untersuche, 
#        ob einer davon zu einer invarianten Lie algebra f"uhrt.
# 
#- Eine Reduktion: suche nur nach restricted Lie algebras.

MatGroupByPermGroup := function( P )
    local d, m;
    d := LargestMovedPoint(P);
    m := List(GeneratorsOfGroup(P), x -> PermutationMat(x,d, GF(2)));
    return Group(m);
end; 

IsUnwanted := function( mat )
    local t, f, g;

    # check that it has trace 0 
    t := TraceMat(mat);
    if t <> 0 * t then return true; fi;

    # check that it is singular
    if Length(NullspaceMat(mat)) = 0 then return true; fi;

    # check its char poly by Vaughan-Lee criterion
    f := CharacteristicPolynomial(mat);
    g := Collected(Factors(f));
    g := Filtered(g, x -> x[1] <> x[1]^0 );
    if Length(g) > 0 and ForAll( g, x -> x[1] = 1 ) then return true; fi;

    # this is all
    return false;
end;

SpanLieAlg := function( base, G )
    local d, mats, done, i, j, new, vec, sol, g;

    # set up
    d := DimensionOfMatrixGroup(G);
    if Length( base ) > d then return []; fi;

    # check matrices
    mats := List( base, x -> CutVector(x, d));
    if ForAny( mats, x -> IsUnwanted(x) ) then return []; fi;

    # loop and expand by Lie-bracket and G-action
    done := false;
    while not done do
        done := true;

        # expand by Lie commutator
        for i in [1..Length(mats)] do
            for j in [i+1..Length(mats)] do
                new := mats[i]*mats[j] - mats[j]*mats[i];
                vec := Flat(new);
                sol := SolutionMat( base, vec );
                if IsBool( sol ) then 
                    Add( mats, new );
                    Add( base, vec );
                    done := false;
                    if Length(mats)>d or IsUnwanted(new) then return []; fi;
                fi;
            od;
       od;

       # expand by action
       for g in GeneratorsOfGroup(G) do
           for i in [1..Length(mats)] do
                new := g^-1 * mats[i] * g;
                vec := Flat(new);
                sol := SolutionMat( base, vec );
                if IsBool( sol ) then 
                    Add( mats, new );
                    Add( base, vec );
                    done := false;
                    if Length(mats)>d or IsUnwanted(new) then return []; fi;
                fi;
           od;
       od;
    od;

    TriangulizeMat(base);
    return base;
end;

ExpandInvariantLieAlgebra := function( base, G, k )
    local full, fact, indm, minm, prei, res, i, spin;

    # induce to factor
    full := IdentityMat( Length(base[1]), GF(2) );
    fact := BaseSteinitzVectors( full, base ).factorspace;
    indm := InducedActionFactor( k, fact, base );

    # determine minimals 
    minm := SMTX.BasesMinimalSubmodules( GModuleByMats( indm, GF(2) ) );

    # loop
    res := [];
    for i in [1..Length(minm)] do
        # Print("  expand ",i," of ",Length(minm),"\n"); 
        prei := Concatenation( minm[i] * fact, MutableCopyMat( base ) );
        spin := SpanLieAlg( prei, G );
        if Length(spin) > 0 then Add( res, spin ); fi;
    od;
    return res;
end;

InvariantSimpleLieAlgebras := function( G )
    local d, g, k, M, todo, done, next, new, l, i, L, sub;

    # set up
    d := DimensionOfMatrixGroup(G);
    g := GeneratorsOfGroup( G );
    k := List( g, x -> KroneckerProduct(TransposedMat(x^-1),x) );
    M := GModuleByMats( k, GF(2) );

    # get minimals 
    todo := SMTX.BasesMinimalSubmodules(M);
    Print(" ",Length(todo)," minimals \n");

    # span minimals
    todo := List( todo, x -> SpanLieAlg( MutableCopyMat(x), G ) );
    done := Filtered( todo, x -> Length(x) = d );
    todo := Filtered( todo, x -> Length(x) > 0 and Length(x) < d );
    Sort( todo, function(a,b) return Length(a)>Length(b); end );

    # loop submodules
    while Length(todo) > 0 do 
        next := MutableCopyMat(todo[Length(todo)]);
        Unbind(todo[Length(todo)]);

        Print("  process dim ",Length(next)," -- ",Length(todo)," to go\n");
        new := ExpandInvariantLieAlgebra( next, G, k );

        # collect results
        sub := Filtered( new, x -> Length(x) = d );
        Append( done, sub );
        done := Set(done);
       
        sub := Filtered( new, x -> Length(x) < d );
        Append(todo, sub );
        todo := Set(todo);
        Sort( todo, function(a,b) return Length(a)>Length(b); end );
    od;

    # adjust and return
    for i in [1..Length(done)] do
        l := List( done[i], x -> CutVector(x,d) );
        L := LieAlgebra( GF(2), l );
        L!.mats := l;
        if IsSimpleLieAlgebra(L) then 
            done[i] := L;
        else
            done[i] := false;
        fi;
    od;
    return Filtered( done, x -> not IsBool(x));
end;

IsInvariant := function( base, g )
    local d, m, h, c, mats, conj;
    d := Length(g[1]);
    mats := List( base, x -> CutVector(x,d) );
    for m in mats do
        for h in g do
            c := Flat( h^-1 * m * h );
            if IsBool(SolutionMat(base,c)) then return false; fi;
        od;
    od;
    return true;
end;

CheckTransitiveGroups := function( deg )
    local n, i, G, H, L, lie, res;
    n := NrTransitiveGroups(deg);
    res := [];
    for i in [1..n] do
        G := TransitiveGroup( deg, i );
        H := MatGroupByPermGroup(G);
        L := Normalizer(GL(deg,2),H);
        Print(i,"th group of size ",Size(L),"\n");
        lie := InvariantSimpleLieAlgebras(L);
        Append(res, lie);
    od;
    return res;
end;
CheckPrimitiveGroups := function( deg )
    local n, i, G, H, lie, res;
    n := NrPrimitiveGroups(deg);
    res := [];
    for i in [1..n] do
        G := PrimitiveGroup( deg, i );
        Print(i,"th group of size ",Size(G),"\n");
        H := MatGroupByPermGroup(G);
        lie := InvariantSimpleLieAlgebras(H);
        Append(res, lie);
    od;
    return res;
end;
