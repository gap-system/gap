#############################################################################
##
## fitaut.gi  .... using the upper nilpotent basis
##

#############################################################################
##
#F LinearActionOnBasis( base, mats )
##
LinearActionOnBasis := function( base, mats )
    local imgs, invs, flat, mat, new, i;
    imgs := [];
    invs := List( mats, x -> x^-1 );
    flat := List( base, Flat );
    for i in [1..Length(mats)] do
        new := List( base, x -> Flat( invs[i] * x * mats[i] ) );
        imgs[i] := List( new, x -> SolutionMat( flat, x ) );
    od;
    return imgs;
end;

#############################################################################
##
#F AutomorphismGroupFittingFactor( T, d )
##
AutomorphismGroupFittingFactor := function( T, d )
    local n, k, f, p, K, M, m, c, G, g, h, S, s, a, u, A, D, U, I, b,
          C;

    # set up
    n := Length(T);
    k := n-d;
    f := Field( T[1][1][1] );
    p := Characteristic(f);
    K := TableMod(T,k);
    Print("  start first layer with dim ", d," and factor dim ",k,"\n");

    # get module and cocycle
    M := GetModule( T, k, d );
    m := TriangulizedBasis( List( M, Flat ) );
    c := GetCocycle( T, k, d );

    # get kernel automorphisms
    D := DerivationAutomorphisms( K, M );
 
    # set up for compatible pairs
    b := EigenspaceOfMats( M, p, 0 );
    G := SumStabilizingGL( [b], d, p );
    g := GeneratorsOfGroup(G);
    h := List( g, x -> KroneckerProduct( TransposedMat(x^-1), x ) );

    # normalize K under A
    Print("  compute stabilizer in group of size ",Size(G),"\n");
    S := Stabilizer( G, m, g, h, OnBases );

    # get gens of compatible pairs
    s := GeneratorsOfGroup(S);
    a := LinearActionOnBasis( M, s );
    u := List([1..Length(s)], x -> Tuple( [a[x],s[x]] ) ); 

    # get group
    A := Group( a, IdentityMat(k,f) );
    U := Subgroup( DirectProduct(A,S), u );
    SetSize(U, Size(S));

    # stabilize cocycle
    Print("  compute inducible pairs in group of size ",Size(U),"\n");
    I := InduciblePairsOfTable( U, K, M, c );

    # put all things together
    Print("  collect results \n\n");
    return PreImageOfInduciblePairs( K, M, T, I, D );
end;

#############################################################################
##
#F AutomorphismGroupOfFittingTable( S, wg )
##
AutomorphismGroupOfFittingTable := function( S, wg )
    local cg, f, A, v, k, n, d, K, N, I, M, i, j, c, b, a, DA, CP, IP;

    # set up
    f := Field( S[1][1][1] );
    cg := Collected(wg);

    # the first step
    if cg[1][1] = 0 then  # non-nilpotent case
        d := cg[2][2];
        n := cg[1][2] + d;
        N := TableMod( S, n );
        A := AutomorphismGroupFittingFactor( N, d );
        cg := cg{[3..Length(cg)]};
    else                  # nilpotent case
        d := cg[1][2];
        n := d;
        N := TableMod( S, n );
        A := GL(cg[1][2], f);
        cg := cg{[2..Length(cg)]};
    fi;

    # loop
    for v in cg do

        # get stepsize and factor
        Info( InfoLieAut, 1, "  start layer ", v," with size ",Size(A));
        k := n;
        d := v[2];
        n := k + d;
        K := N;
        N := TableMod( S, n );

        # get module and cocycle
        M := GetModule( N, k, d );
        c := GetCocycle( N, k, d );

        # get kernel automorphisms
        DA := DerivationAutomorphisms( K, M );

        # get compatible pairs
        Info( InfoLieAut, 1, "  compute compatible pairs in size",Size(A));
        CP := CompatiblePairsOfTable( A, GL(d,f), K, M );

        # get inducible pairs
        Info( InfoLieAut, 1, "  compute inducible pairs in size ",Size(CP));
        IP := InduciblePairsOfTable( CP, K, M, c ); 

        # put results together for next step
        Info( InfoLieAut, 1, "  collect results \n");
        A := PreImageOfInduciblePairs( K, M, N, IP, DA );

    od;
    return A;
end;

#############################################################################
##
#F AutomorphismGroupOfSolvableLieAlgebraByFitting( L )
##
InstallGlobalFunction( AutomorphismGroupOfSolvableLieAlgebraByFitting,
function( L )
    local B, S, A, a, b, w;

    # get table with series
    Info( InfoLieAut, 1, "get special table \n");
    B := UpperNilpotentBasis( L );
    S := TableByBasis( L, B.basis );
    Info( InfoLieAut, 1, "got table with weigths ",B.weights);

    # compute automorphism group
    A := AutomorphismGroupOfFittingTable( S, B.weights );
    a := GeneratorsOfGroup(A);

    # translate back
    Info( InfoLieAut, 1, "translate back");
    w := List( B.basis, x -> x![1] );
    b := List( a, x -> w^-1 * x * w );
    B := Group(b);
    SetSize(B, Size(A));

    return B;
end );

#############################################################################
##
#F AutomorphismGroupOfSolvableLieAlgebra( L )
##
InstallGlobalFunction( AutomorphismGroupOfSolvableLieAlgebra, function( L )

    # default: by Special
    return AutomorphismGroupOfSolvableLieAlgebraBySpecial(L);

    # alternative: by Fitting
    return AutomorphismGroupOfSolvableLieAlgebraByFitting(L);

end );


