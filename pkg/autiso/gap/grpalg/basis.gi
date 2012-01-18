
CoeffsNatBasis := function(A)
    local d, F, I, i;
    d := Dimension(A);
    F := LeftActingDomain(A);
    I := MutableIdentityMat(d, F){[2..d]};
    for i in [1..d-1] do I[i][1] := -One(F); od;
    return I;
end;

TableNatBasis := function(A)
    local F, p, w, v, G, e, f, n, m, i, j, S, a, d, h, g;

    # get field info
    F := LeftActingDomain(A);
    p := Characteristic(F);
    w := -One(F);
    v := -2*One(F);

    # get group info
    G := UnderlyingMagma(A);
    e := Filtered(Elements(G), x -> x <> One(G));
    f := List( e, x -> ExponentsOfPcElement( Pcgs(G), x ) );
    g := SortingPerm(f);
    h := g^-1;
    d := Permuted(f,g);
    n := Length(e);
    m := MutableNullMat(n,n);
    for i in [1..n] do
        for j in [1..n] do
            a := ExponentsOfPcElement(Pcgs(G), e[i]*e[j]);
            if a = 0*a then 
                m[i][j] := 0;
            else
                m[i][j] := PositionSorted(d,a)^h;
            fi;
        od;
    od;

    # sort this into table
    S := List( [1..n], x -> MutableNullMat(n,n,F));
    for i in [1..n] do
        for j in [1..n] do
            if m[i][j] <> 0 then S[i][j][m[i][j]] := One(F); fi;
            if i <> j then 
                S[i][j][i] := w;
                S[i][j][j] := w;
            elif p <> 2 then 
                S[i][j][i] := v;
            fi;
            ConvertToVectorRepNC(S[i][j], F);
        od;
    od;
    return S;
end;

InstallMethod( CoeffsPowerBasis,
               "for group rings", 
               [IsGroupRing], 
               function(A)
    local G, p, n, jb, jw, ww, wb, wc, df, i, h;

    # set up
    G := UnderlyingMagma(A);
    p := PrimePGroup(G);
    n := Length(Pcgs(G));

    # get a special basis of G
    jb := DimensionBasis( G ).dimensionBasis;
    jw := DimensionBasis( G ).weights;
    df := List( jb, x -> (x-One(A)) );

    # set up for basis with weights
    wc := Tuples( [ 0 .. p-1 ], n ); RemoveSet( wc, 0*[1 .. n] );
    ww := [];
    wb := [];

    # determine a basis with weights for A
    for i in [1..Length(wc)] do
        ww[i] := Sum( [1..n], x -> wc[i][x]*jw[x] );
        wb[i] := Product( [1..n], x -> df[x]^wc[i][x] );
        wb[i] := Coefficients( Basis(A), wb[i] );
    od;

    # sort and return
    h := Sortex(ww);
    return rec( basis := Permuted(wb, h), 
                weights := ww,
                exps := Permuted(wc, h) );
end );

InstallMethod( TablePowerBasis,
               "for group rings", 
               [IsGroupRing], 
               function(A)
    local d, n, F, I, S, C, b, c, T, l, m, i, j, s, e, r, f, g;

    # set up
    d := Dimension(A);
    n := Dimension(A)-1;
    F := LeftActingDomain(A);
    I := IdentityMat(Length(Pcgs(UnderlyingMagma(A))));

    # get table for basis B = {g-1 | g in G, g <> 1} of I
    S := TableNatBasis(A);

    # get coeffs for basis C = {v_c | c coeff, c <> 0} of I
    C := CoeffsPowerBasis(A);

    # add base changes B <-> C 
    b := List( C.basis, x -> x{[2..n+1]} );
    ConvertToMatrixRep(b);
    c := b^-1;

    # initialize table wrt C
    T := List([1..n], x -> MutableNullMat(n,n,F));

    # loop over elements of C in an efficient form
    l := List( C.exps, Sum );
    m := C.weights[n];

    # the case of sum 1
    for i in [1..n] do
        if l[i] = 1 then 
            for j in [1..n] do
                if C.weights[i]+C.weights[j] <= m then 
                    T[i][j] := MultBySC1( S, F, n, b[i], b[j] );
                fi;
            od;
            ConvertToMatrixRep(T[i]);
        fi;
    od;

    # the higher sums
    for s in [2..Maximum(l)] do
        for i in [1..n] do
            if l[i] = s then 
                e := C.exps[i];
                r := PositionNonZero(e);
                f := Position( C.exps, e-I[r] );
                g := Position( C.exps, I[r] );
                for j in [1..n] do
                    if C.weights[i]+C.weights[j] <= m then 
                        T[i][j] := MultBySC1( S, F, n, b[g], T[f][j] );
                    fi;
                od;
                ConvertToMatrixRep(T[i]);
            fi;
        od;
    od;

    # adjust by base change and return
    for i in [1..n] do T[i] := T[i]*c; od;
    return T;

end );


