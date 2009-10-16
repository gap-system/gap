
IsNewBasisVector := function( B, c )
    if c = 0*c then return false; fi;
    if Length(B) = 0 then return true; fi;
    return IsBool(SolutionMat(B, c));
end;

MultBySC := function( S, F, v, w )
    local u, i, j;
    u := ShallowCopy( 0 * v );
    ConvertToVectorRep( u, F );
    for i in [1..Length(v)] do
        if v[i] <> Zero(F) then
            for j in [1..Length(w)] do
                if w[j] <> Zero(F) then
                    AddRowVector( u, S[i][j], v[i]*w[j] );
                fi;
            od;
        fi;
    od;
    return u;
end;

MultBySC1 := function( S, F, n, v, w )
    local u, d, j;
    d := DepthVector(v);
    u := w[1] * S[d][1];
    for j in [2..n] do
        #if w[j] <> Zero(F) then
            AddRowVector( u, S[d][j], w[j] );
        #fi;
    od;
    return u;
end;

MultByCoeffs := function( S, F, x, y )
    local v, i, j;
    v := ShallowCopy( 0 * x );
    for i in [1..Length(x)] do
        if x[i] <> Zero(F) then
            for j in [1..Length(y)] do
                if y[j] <> Zero(F) then
                    v[S[i][j]] := v[S[i][j]]+ x[i]*y[j];
                fi;
            od;
        fi;
    od;
    return v;
end;

BySum := function( v, w )
    if Sum(v) < Sum(w) then return true; fi;
    if Sum(v) = Sum(w) then return v<w; fi;
    return false;
end;

MatPlus := function( mat, F )
    local M, i, j;
    M := MutableNullMat( Length(mat)+1, Length(mat)+1, F );
    M[1][1] := One(F);
    for i in [1..Length(mat)] do
        for j in [1..Length(mat)] do
            M[i+1][j+1] := mat[i][j];
        od;
    od;
    return M;
end;

