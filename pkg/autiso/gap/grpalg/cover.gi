AssocRelation1 := function( T, S, d, l, i, j, k )
    local a, r;

    # (ij) k  
    a := T[i][j][1] * S[1][k];
    for r in [2..d] do
        if T[i][j][r] <> 0*T[i][j][r] then
            AddRowVector( a, S[r][k], T[i][j][r] );
        fi;
    od;
    return a;
end;

AssocRelation2 := function( T, S, d, l, i, j, k )
    local b, s;

    # i (jk)
    b := T[j][k][1] * S[i][1];
    for s in [2..d] do
        if T[j][k][s] <> 0*T[j][k][s] then
            AddRowVector( b, S[i][s], T[j][k][s] );
        fi;
    od;
    return b;
end;

CheckAssoc := function( T, S, pw, wg, d, l, n, i, j, k )
    local a, b;
    if pw[i][j] + wg[k] <= n+1 and wg[i] + pw[j][k] <= n+1 then
        a := AssocRelation1( T, S, d, l, i, j, k );
        b := AssocRelation2( T, S, d, l, i, j, k );
        return a-b;
    elif pw[i][j] + wg[k] <= n+1 then
        a := AssocRelation1( T, S, d, l, i, j, k );
        return a;
    elif wg[i] + pw[j][k] <= n+1 then
        b := AssocRelation2( T, S, d, l, i, j, k );
        return b;
    fi;
    return false;
end;

Weight := function( wg, i )
    if i > Length(wg) then return wg[Length(wg)]+1; fi;
    return wg[i];
end;

ProductWeights := function( T, df, wg )
    local d, pw, i, j, a, b;

    d := Length(T);

    # init 
    pw := MutableNullMat(d,d);

    # start with SC-table 
    for i in [1..d] do
        for j in [1..d] do
            pw[i][j] := Weight( wg, PositionNonZero(T[i][j]) );
        od;
    od;

    # improve by sum-weights
    for i in [1..d] do
        for j in [1..d] do
            pw[i][j] := Maximum( pw[i][j], wg[i] + wg[j] );
        od;
    od;

    # improve by defs
    for i in [1..d] do
        for j in [1..d] do
            if IsList(df[j]) then 
                a := wg[i] + pw[df[j][1]][df[j][2]];
                b := pw[i][df[j][1]] + wg[df[j][2]];
                pw[i][j] := Maximum(pw[i][j],a,b);
            fi;
        od;
    od;

    return pw;
end;

CoveringTable := function( R )
    local T, F, S, C,                # tables and fields
          d, n, m, l, e,             # dimensions
          df, wg, rl, ct, pw,        # info-lists
          u, v, U, V, W, h,          # vector space related
          i, j, k, s;                # loop variables

    # catch arguments
    T := R.tab;
    df := R.dfR;
    wg := R.wgR;

    # set up
    F := Field(T[1][1][1]);
    d := Length(T);
    n := wg[d];
    m := Length( Filtered( wg, x -> x = 1 ) );

    # compute weights for products
    pw := ProductWeights( T, df, wg );

    # determine the size of the extension
    l := 0;
    for i in [1..m] do
        for j in [1..d] do
            if not [i,j] in df and pw[i][j] <= n+1 then
                l := l+1;
            fi;
        od;
    od;
    #Print("      extend table of dim ",d," by ",l,"\n");

    # create table of tails
    S := List([1..d], x -> MutableNullMat(d,l,F));
    rl := [];
    ct := 1;
    for i in [1..d] do
        for j in [1..d] do
            if not [i,j] in df and pw[i][j] <= n+1 then
                if wg[i] = 1 then
                    S[i][j][ct] := One(F);
                    ct := ct+1;
                    ConvertToVectorRep( S[i][j], F );
                else
                    k := df[i][1]; h := df[i][2];
                    for s in [1..d] do
                        if T[h][j][s] <> Zero(F) then
                            S[i][j] := S[i][j] + T[h][j][s]*S[k][s];
                        fi;
                    od;
                    Add( rl, [k, h, j] );
                    ConvertToVectorRep( S[i][j], F );
                fi;
            fi;
        od;
    od;

    # check associativity
    #Print("      check associativity \n");
    u := [];
    for i in [1..m] do
        for j in [1..d] do
            for k in [1..d] do
                if not [i,j,k] in rl then
                    v := CheckAssoc( T, S, pw, wg, d, l, n, i, j, k );
                    if not IsBool(v) and v <> 0*v then Add(u, v); fi;
                fi;
            od;
        od;
    od;

    # factor
    V := F^l;
    U := SubspaceNC(V, MyBaseMat(u), "basis" );
    h := NaturalHomomorphismBySubspaceOntoFullRowSpace(V,U);
    e := Dimension(U);
    
    # create a table for factor
    C := List([1..d+l-e], x -> MutableNullMat( d+l-e, d+l-e, F));
    for i in [1..d] do
        for j in [1..d] do
            C[i][j]{[1..d]} := T[i][j];
            if not [i,j] in df and pw[i][j] <= n+1 then 
                C[i][j]{[d+1..d+l-e]} := Image( h, S[i][j] );
            fi;
        od;
    od;
            
    return rec( cov := C );
end;

AddDefsAndIsom := function( C, R, S )
    local F, A, I, n, m, d, l, s, i, j, c, t, z;

    # set up
    F := Field(C.cov[1][1][1]);
    n := Length(R.wgR);
    m := Length(C.cov) - n;
    d := Length(Filtered( R.wgR, x -> x = 1 ));

    # get starting points
    l := Maximum(R.wgR);
    s := List([1..l], x -> Position( R.wgR, x ));
    Add( s, n+1 );

    # init
    C.mul := []; 
    C.def := [];

    # determine defs in N
    for i in [s[1] .. s[2]-1] do
        for j in [s[l] .. s[l+1]-1] do
            c := C.cov[i][j]{[n+1..n+m]};
            if IsNewBasisVector( C.mul, c ) then 
                Add( C.mul, c );
                Add( C.def, [i,j] );
            fi;
        od;
    od;
    C.nuc := Length(C.mul);

    # extend to defs in M
    for i in [s[1] .. s[2]-1] do
        for j in [s[1] .. s[l]-1] do
            c := C.cov[i][j];
            t := c{[1..n]};
            c := c{[n+1..n+m]};
            if Length(C.mul) < m and IsNewBasisVector( C.mul, c ) then 
                Add( C.mul, c );
                if t = 0*t then
                    Add( C.def, [i,j] );
                else
                    Add( C.def, [i,j,t] );
                fi;
            fi;
        od;
    od;

    # init extension of iso R -> T to C -> S
    z := List( [1..Length(S)-n], x -> Zero(F) );
    A := List( R.iso{[1..d]}, x -> Concatenation( x, z ) );

    # extend first step using defs of R
    for i in [d+1..n] do
        s := R.dfR[i];
        A[i] := MultBySC( S, F, A[s[1]], A[s[2]] );
    od;

    # extend second step using defs of M
    I := [];
    for i in [1..m] do
        s := C.def[i];
        I[i] := MultBySC( S, F, A[s[1]], A[s[2]] );
        if Length(s) = 3 then I[i] := I[i] - s[3]*A; fi;
    od;

    # store result
    C.iso := Concatenation( A, I );
end;

AllowableSubspace := function( C )
    local m, n, I, K;
    m := Length(C.mul);
    n := Length(C.cov) - m;
    I := C.iso{[n+1..n+m]};
    K := NullspaceMat(I);
    if Length(K) = 0 then return K; fi;
    K := K * C.mul;
    TriangulizeMat(K);
    return K;
end;

QuotientTable := function( C, R, W, wg )
    local F, n, m, w, l, t, I, B, Q, i, j;

    # set up
    F := Field( C.cov[1][1][1] );
    n := Length( R.tab );
    m := Length( C.cov ) - n;
    w := Length( W.cf );
    l := m-w;

    # pick basis for M/W
    I := [];
    B := ShallowCopy(W.cf);
    for i in [1..C.nuc] do
        if Length(B) < m then 
            if IsNewBasisVector( B, C.mul[i] ) then 
                Add( I, i );
                Add( B, C.mul[i] );
            fi;
        fi;
    od;

    # check 
    if Length(B) < m then Error("no basis for quotient table"); fi;

    # determine quotient table
    Q := List([1..n+l], x -> MutableNullMat( n+l, n+l, F));
    for i in [1..n] do
        for j in [1..n] do
            t := C.cov[i][j]{[n+1..n+m]};
            Q[i][j]{[1..n]} := ShallowCopy(R.tab[i][j]);
            Q[i][j]{[n+1..n+l]} := SolutionMat(B, t){[w+1..m]};
        od;
    od;

    return rec( tab := Q, 
                dfR := Concatenation( R.dfR, C.def{I} ),
                wgR := wg );
end;

AddIsomQuotientTable := function( R, S, C, W )
    local F, n, d, l, z, s, i;

    # set up
    F := Field( C.cov[1][1][1] );
    n := Length( R.tab );
    d := Length( Filtered( R.wgR, x -> x = 1 ) );
    l := Length( C.mul ) - Length( W.cf );
    z := List( [1..l], x -> Zero(F) );

    # determine new isom - set up
    R.iso := [];
    for i in [1..d] do
        R.iso[i] := Concatenation( W.ti[1][i], z ) * C.iso;
    od;

    # extend using defs of R
    for i in [d+1..n] do
        s := R.dfR[i];
        R.iso[i] := MultBySC( S, F, R.iso[s[1]], R.iso[s[2]] );
    od;

end;

