#############################################################################
##
## autiso.gi  .... general stuff on lie automorphisms
##

#############################################################################
##
#F IsIsomorphismOfTables( S, T, a )
##
IsIsomorphismOfTables := function( S, T, a )
    local z, n, i, j, rh, lh, k, l;

    z := 0 * T[1][1][1];
    if z <> 0 * S[1][1][1] then return false; fi;
    n := Length(T);
    if n <> Length(S) then return false; fi;

    for i in [1..n] do
        for j in [i+1..n] do

            # the right hand side
            rh := T[i][j] * a;

            # the left hand side
            lh := z;
            for k in [1..n] do
                for l in [1..n] do
                    lh := lh + a[i][k]*a[j][l]*S[k][l];
                od;
            od;

            if lh <> rh then return [i,j]; fi;
        od;
    od;
    return true;
end;

#############################################################################
##
#F IsomorphismOfLieAlgebras( L, M )
##
InstallGlobalFunction( IsomorphismOfLieAlgebras, function( L, M )
    local BT, BS, TT, SS, c, d, i, f, p, G, g, m, w;

    # get special tables
    BT := LowerNilpotentBasis( L );
    BS := LowerNilpotentBasis( M );
    if BT.weights <> BS.weights then return fail; fi;

    TT := TableByBasis( L, BT.basis );
    SS := TableByBasis( M, BS.basis );
    m := List( BT.basis, x -> x![1] );
    w := List( BS.basis, x -> x![1] );
    if TT = SS then return m * w^-1; fi;

    # get indices
    c := Collected( BT.weights );
    d := [Length(BT.weights)];
    for i in [1..Length(c)] do
        Add( d, d[Length(d)] - c[i][2] );
    od;

    # set up
    f := LeftActingDomain(L);
    p := Characteristic( f );
    G := SeriesStabilizingGL(d,p);

    # check for isomorphism
    for g in G do
        if IsIsomorphismOfTables( TT, SS, g ) = true then 
            return w^-1 * g * m; 
        fi;
    od;

    # non-isom
    return fail;
end );

#############################################################################
##
#F AreIsomorphicLieAlgebras( L, M )
##
InstallGlobalFunction( AreIsomorphicLieAlgebras, function(L,M)
    local sL, sM, bL, bM, TL, TM;

    # set up
    sL := IsLieSolvable(L);
    sM := IsLieSolvable(M);
    if sL <> sM then return false; fi;

    # the solvable case
    if sL then 
        bL := LowerNilpotentBasis(L);
        bM := LowerNilpotentBasis(M);
        if bL.weights <> bM.weights then return false; fi;

        TL := TableByBasis( L, bL.basis );        
        TL := CanonicalFormOfSpecialTable( TL, bL.weights ).Table;
        TM := TableByBasis( M, bM.basis );        
        TM := CanonicalFormOfSpecialTable( TM, bM.weights ).Table;
        
        return TL = TM;
    fi;

    # the non-solvable case
    return not IsBool( IsomorphismOfLieAlgebras(L,M) );
end);

#############################################################################
##
#F IsAutomorphismOfTable( T, a )
##
IsAutomorphismOfTable := function( T, a )
    local z, n, i, j, rh, lh, k, l;

    z := 0 * T[1][1][1];
    n := Length(T);

    for i in [1..n] do
        for j in [i+1..n] do

            # the right hand side
            rh := T[i][j] * a;

            # the left hand side
            lh := z;
            for k in [1..n] do
                for l in [1..n] do
                    lh := lh + a[i][k]*a[j][l]*T[k][l];
                od;
            od;

            if lh <> rh then return [i,j]; fi;
        od;
    od;
    return true;
end;

#############################################################################
##
#F IsAutomorphismOfTable2( T, a )
##
Mult := function( a, b )
    local n, c, i, j, l, k;
    n := Length(a);
    c := NullMat(n,n);
    for i in [1..n] do
        for j in [1..n] do
            l := a[i][1] * b[1][j];
            for k in [2..n] do
                l := l + a[i][k]*b[k][j];
            od;
            c[i][j] := l;
        od;
    od;
    return c;
end;

IsAutomorphismOfTable2 := function( T, a )
    return Mult( Mult(a, T), TransposedMat(a)) = T * a;
end;
 
#############################################################################
##
#F AutomorphismGroupOfLieAlgebra( L )
##
InstallGlobalFunction( AutomorphismGroupOfLieAlgebra, function( L )
    local B, S, c, d, i, f, p, G, autos, g, b, m;

    # set up
    B := LowerNilpotentBasis( L );
    S := TableByBasis( L, B.basis );
    c := Collected( B.weights );

    # get indices
    d := [Length(B.basis)];
    for i in [1..Length(c)] do
        Add( d, d[Length(d)] - c[i][2] );
    od;

    # set up
    f := LeftActingDomain( L );
    p := Characteristic( f );
    G := SeriesStabilizingGL(d,p);

    # check for isomorphism
    autos := [];
    for g in G do
        if IsAutomorphismOfTable( S, g ) = true then 
            Add( autos, g );
        fi;
        Print(Size(Group(autos)), "\n");
    od;

    # translate back
    m := List( B.basis, x -> x![1] );
    b := List( autos, x -> m^-1 * x * m );
    return GroupByGenerators(b);
end );

#############################################################################
##
#F AutomorphismGroupOfLieAlgebraRandom( L )
##
InstallGlobalFunction( AutomorphismGroupOfLieAlgebraRandom, function( L )
    local S, d, f, p, G, U, autos, hit, g, V;

    # set up
    S := TableByBasis( L, CBS(L) );
    d := Length(CBS(L));

    # set up
    f := LeftActingDomain( L );
    p := Characteristic( f );
    G := GL(d,p);
    U := Subgroup(G, []);

    # check for isomorphism
    autos := [];
    hit := 0;
    while hit <= 10 do
        g := Random(G);
        if IsAutomorphismOfTable( S, g ) = true then 
            V := ClosureSubgroup( U, g );
            if Size(V) > Size(U) then 
                Print("size of aut ",Size(V), "\n");
                U := V;
            else
                Print("limit ", hit, "\n");
                hit := hit+1;
            fi;
        else
            Print("next try \n");
        fi;
    od;

    return U;
end );

#############################################################################
##
#F AutomorphismGroup( L )
##
InstallOtherMethod( AutomorphismGroup, true, [IsLieAlgebra], 0,
function(L)
    if IsBound(L!.AutGroup) then 
        return L!.AutGroup;
    elif IsLieSolvable(L) then 
        return AutomorphismGroupOfSolvableLieAlgebra(L);
    else
        return AutomorphismGroupOfLieAlgebra(L);
    fi;
end );


