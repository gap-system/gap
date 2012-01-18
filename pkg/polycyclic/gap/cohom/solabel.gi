#############################################################################
##
#W  solabel.gi                  Polycyc                         Bettina Eick
##

# Input: 
#  n integer, m integer, p prime, 
#  e = [e_1, ..., e_k] list of p-powers e_1 <= ... <= e_k
#  A = nk x mk integer matrix
#  b = integer vector of lenth mk 

SeriesSteps := function(e)
    local l, f, p, k, s, i;

    l := Length(e);
    f := Factors(e[l]); 
    p := f[1]; 
    k := Length(f);

    s := []; 
    for i in [1..k] do
        s[i] := Length(Filtered(e, x -> x < p^i));
    od;

    return s;
end;

DepthVector := function( vec )
    local i;
    for i in [1..Length(vec)] do
        if vec[i] <> 0*vec[i] then return i; fi;
    od;
    return Length(vec)+1;
end;

StripIt := function( mat, l )
    local n, d, k;
    n := Length( mat );
    d := List( mat, DepthVector );
    k := First( [1..n], x -> d[x] >= l );
    if IsBool(k) then return Length(mat)+1; fi;
    return k;
end;

Strip := function( mat, l )
    return mat{[StripIt(mat,l)..Length(mat)]};
end;

DivideVec := function(t,p)
    local i;
    for i in [1..Length(t)] do
        if t[i] <> 0 then 
            t[i] := t[i]/p;
        fi;
    od;
    return t;
end;

TransversalMat := function( M, n )
    local d;
    if Length(M) = 0 then return IdentityMat(n); fi;
    d := List(M, DepthVector);
    d := Difference([1..Length(M[1])], d);
    return IdentityMat(n){d};
end;

KernelSystemGauss := function( A, e, p )
    local k, n, m, q, F, s, AA, SS, KK, II, TT, K, I, i, dW, dV, rT,
          B, J, W, S, U; 

    # catch arguments
    k := Length(e);
    n := Length(A)/k; if not IsInt(n) then return fail; fi;
    m := Length(A[1])/k; if not IsInt(m) then return fail; fi;
    F := GF(p);

    # get steps in series
    s := SeriesSteps(e);

    # solve mod p 
    AA := A*One(F); ConvertToMatrixRepNC(AA, F);
    SS := TriangulizedNullspaceMat(AA);

    # extract info
    KK := List(SS, IntVecFFE);
    TT := TransversalMat( KK, n*k );
    II := List(TT, x -> x*A );

    # init for induction
    K := ShallowCopy(KK);

    # use induction
    for i in [2..Length(s)] do
        q := p^(i-1);

        # catch ranges
        dW := [m*s[i]+1..m*k];
        dV := n*s[i]+1;
        rT := [StripIt( TT, dV )..Length(TT)];

        # image of K
        B := List( A, x -> x{dW} );
        J := List( K, x -> DivideVec( x*B, q ) ); 
        
        # extend kernel and image
        Append( K, q * TT{rT} );
        Append( J, List( rT, x -> II[x]{dW} ));

        # apply gauss 
        W := J*One(F); ConvertToMatrixRepNC(W, F);
        S := TriangulizedNullspaceMat(W);

        # convert
        K := List(S, x -> IntVecFFE(x)*K);
        Append(K, q*Strip( KK, dV ) );

    od;
        
    return K;
end;

ReduceVecMod := function( vec, e )
    local i, m;
    m := Length(vec)/Length(e);
    for i in [1..Length(vec)] do
        vec[i] := vec[i] mod e[Int((i-1)/m)+1];
    od;
    return vec;
end;

CheckKernelSpecial := function( A, e )
    local W, I, w, v;
    W := ExponentsByRels( e );
    I := [];
    for w in W do
        v := ReduceVecMod( w*A, e );
        if v = 0*v then Add(I, w); fi;
    od;
    return I;
end;
    
TransversalSystemGauss := function( A, K, e, p )
    local k, n, m, s, d, l, I, T, i, q, t, J, u, r;

    # catch arguments
    k := Length(e);
    n := Length(A)/k; if not IsInt(n) then return fail; fi;
    m := Length(A[1])/k; if not IsInt(m) then return fail; fi;
    s := SeriesSteps(e);

    d := List(K, DepthVector);
    l := List([1..Length(d)], x -> K[x][d[x]]);
    I := IdentityMat(n*k);
    T := [];

    for i in [1..Length(s)] do

        # general
        q := p^(i-1);
        t := n*s[i]+1;

        # kernel
        u := Filtered([1..Length(d)], x -> l[x] = q);
        r := Difference( [t..n*k], d{u} );

        # transversal
        Append(T, q*I{r});
    od;
    return T;
end;

ImageSystemGauss := function( A, K, e, p )
    local k, n, m, s, d, l, I, T, i, q, t, J, u, r;

    # catch arguments
    k := Length(e);
    n := Length(A)/k; if not IsInt(n) then return fail; fi;
    m := Length(A[1])/k; if not IsInt(m) then return fail; fi;
    s := SeriesSteps(e);

    d := List(K, DepthVector);
    l := List([1..Length(d)], x -> K[x][d[x]]);
    I := IdentityMat(n*k);
    T := [];

    for i in [1..Length(s)] do

        # general
        q := p^(i-1);
        t := n*s[i]+1;

        # kernel
        u := Filtered([1..Length(d)], x -> l[x] = q);
        r := Difference( [t..n*k], d{u} );

        # image
        J := I{r}*A;

        # add
        Append(T, List( q*J, x -> ReduceVecMod( x, e )));
    od;
    return T;
end;

FindSpecialSolution := function( S, vec )
    local m, n, z, sol, i, vno, x;
    m := Length(vec);
    n := Length(S.coeffs[1]);
    z := Zero(vec[1]);
    sol := ListWithIdenticalEntries(n,z); ConvertToVectorRepNC(sol);
    for i in [1..m] do
        vno := S.heads[i];
        if vno <> 0 then
            x := vec[i];
            if x <> z then
                AddRowVector(vec, S.vectors[vno], -x);
                AddRowVector(sol, S.coeffs[vno], x);
            fi;
        fi;
    od;
    if IsZero(vec) then
        return sol;
    else
        return fail;
    fi;
end;

SolveSystemGauss := function( A, e, p, b )
    local k, n, m, q, F, s, AA, SE, SS, KK, II, TT, sl, ss, h, K, I, i, 
          dW, dV, rT, B, J, W, S, U, v, u, f, M; 

    # catch arguments
    k := Length(e);
    n := Length(A)/k; if not IsInt(n) then return fail; fi;
    m := Length(A[1])/k; if not IsInt(m) then return fail; fi;
    F := GF(p);
    f := (b <> 0*b);

    # get steps in series
    s := SeriesSteps(e);

    # solve mod p 
    AA := A*One(F); ConvertToMatrixRepNC(AA, F);
    SE := SemiEchelonMatTransformation(AA);
    SS := MutableCopyMat(SE.relations); TriangulizeMat(SS);
    if f then sl := FindSpecialSolution(SE, b*One(F)); fi;

    # extract info
    KK := List(SS, IntVecFFE);
    TT := TransversalMat( KK, n*k );
    II := List(TT, x -> x*A );
    if f then ss := IntVecFFE(sl); fi;

    # init for induction
    K := ShallowCopy(KK);
    if f then h := ShallowCopy(ss); fi;

    # use induction
    for i in [2..Length(s)] do
        q := p^(i-1);

        # catch ranges
        dW := [m*s[i]+1..m*k];
        dV := n*s[i]+1;
        rT := [StripIt( TT, dV )..Length(TT)];

        # image of K
        B := List( A, x -> x{dW} );
        J := List( K, x -> DivideVec( x*B, q ) ); 

        # extend kernel and image
        Append( K, q * TT{rT} );
        Append( J, List( rT, x -> II[x]{dW} ));

        # apply gauss 
        W := J*One(F); ConvertToMatrixRepNC(W, F);
        M := SemiEchelonMatTransformation(W);
        S := MutableCopyMat(M.relations); TriangulizeMat(S);
    
        # consider special solution
        if f then 
            v := DivideVec( h*B - b{dW}, q );
            u := IntVecFFE(FindSpecialSolution(M, v*One(F)));
            h := h - u*K;
        fi;

        # convert
        K := List(S, x -> IntVecFFE(x)*K);
        Append(K, q*Strip( KK, dV ) );

    od;
        
    if f then 
        return rec( kernel := K, sol := h );
    else
        return K;
    fi;
end;

