
FPMinOverIdeals := function(A, v)
    local F, B, T, n, I, d, m, V, U, i, j, res;

    # set up
    F := LeftActingDomain(A);
    B := CoeffsPowerBasis(A);
    T := TablePowerBasis(A);
    n := Dimension(A)-1;
    I := IdentityMat(n, F);

    # get min overs 
    d := Length(Filtered(B.weights, x -> x = 1));
    m := List(v, x -> x * I{[1..d]});

    # get products in I^2
    V := [];
    for i in [d+1..n] do
        for j in [d+1..n] do
            Add( V, T[i][j] );
        od;
    od;
    V := MyBaseMat(V);

    # add products with min overs
    res := [];
    for i in [1..Length(m)] do
        U := StructuralCopy(V);
        
        # 1. step
        Add(U, MultBySC( T, F, m[i], m[i] ));

        # 2. step
        for j in [d+1..n] do
            Add(U, MultBySC( T, F, m[i], I[j] ));
        od;

        # 3. step
        for j in [d+1..n] do
            Add(U, MultBySC( T, F, I[j], m[i] ));
        od;

        # get result
        res[i] := Length(MyBaseMat(U));
    od;

    # that's it
    return res;
end;

InitAutomGroup := function( A )
    local d, F, H, G, V, v, m, s, inv, ind, bas, h, P, i;

    # set up full GL
    d := Length(Filtered(CoeffsPowerBasis(A).weights, x -> x=1));
    F := LeftActingDomain(A);
    H := GL(d, F);
    V := F^d;

    # set up aut group record
    G := rec();
    G.agAutos := [];
    G.one     := One(H);
    G.field   := F;

    # use subgroup of H if desired
    if USE_PARTI then 

        # fingerprint
        v := List(NormedRowVectors(V), Reversed);
        m := FPMinOverIdeals(A, v);
        s := Set(m);
        Print("   found partition ",m,"\n");

        # translate to invariant subspaces
        inv := [1..Length(s)];
        for i in [1..Length(s)] do
            ind := Filtered([1..Length(m)], x -> m[x] = s[i]);
            inv[i] := MyBaseMat( v{ind} );
        od;

        # create a chain from invariant subspaces
        inv := Filtered(inv, x -> Length(x)<d);
        bas := BasisBySubspaces( inv, F, d );
        Print("   found basis with weights ",bas.weights,"\n");

        # compute mat group that stabilizes this chain
        H := ChainStabilizer( bas.weights, F );

        # reset and add relevant entries in aut group record
        G.basis   := bas.basis;
        G.partition := Collected(m);
    else
        G.basis   := IdentityMat(d,F);
    fi;

    # add perm action 
    v := Filtered( Elements(V), x -> x <> Zero(V) );
    h := ActionHomomorphism( H, v, OnRight, "surjective" );
    P := Image(h);
    SetSize(P, Size(H));

    # reset relevant entries in aut group record
    G.glPerms := SmallGeneratingSet(P);
    G.glAutos := List(G.glPerms, x -> PreImagesRepresentative(h,x));
    G.glOrder := Size(H);
    G.size    := Size(H);

    # that's it
    return G;
end;

