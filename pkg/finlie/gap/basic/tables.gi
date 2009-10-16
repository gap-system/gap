#############################################################################
##
#F tables.gi  .... contains computations with Tables
##
## A table is a 3-dim array such that [bi,bj] = sum_k T[i][j][k] bk holds
## for a basis [b1, .., bn].
## 

#############################################################################
##
#F IsJacobiTable( T )
##
IsJacobiTable := function( T )
    local  z, n, i, j, k, m, s, l;

    z := 0*T[1][1][1];
    n := Length( T );

    for i in [1..n-2]  do
        for j in [i+1..n-1]  do
            for k in [j+1..n]  do
                for m in [1..n]  do
                    s := z;
                    for l in [1..n] do
                        s := s + T[j][k][l]*T[i][l][m];
                        s := s + T[k][i][l]*T[j][l][m];
                        s := s + T[i][j][l]*T[k][l][m];
                    od;
                    if s <> z then return [i,j,k]; fi;
                od;
            od;
        od;
    od;
    return true;
end;

#############################################################################
##
#F IsAntiSymmetricTable(T)
##
IsAntiSymmetricTable := function( T )
    local i, j;
    for i in [1..Length(T)] do
        for j in [i..Length(T)] do
            if T[i][j] <> - T[j][i] then return false; fi;
        od;
    od;
    return true;
end;

#############################################################################
##
#F PrintTable( T )
##
PrintTable := function( T )
    local n, i, j, k, w, S, f, t;

    # first check field and use prime field case
    f := Field(Flat(T));
    if IsPrimeField(f) then  
        S := List( T, M -> List(M, IntVecFFE) );
    else
        S := T;
    fi;

    # print
    n := Length(T);
    for i in [1..n] do
        for j in [i+1..n] do
            w := S[i][j];
            t := false;
            if w <> 0 * w then 
                Print("[a",i,", a",j,"] = ");
                for k in [1..n] do
                    if w[k] = w[k]^0 then 
                        if t then Print(" + "); fi;
                        Print("a",k);
                        if not t then t := true; fi;
                    elif w[k] <> 0 * w[k] then 
                        if t then Print(" + "); fi;
                        Print(w[k], "*a",k);
                        if not t then t := true; fi;
                    fi;
                od;
                Print("\n");
            fi;
        od;
    od;
end;

#############################################################################
##
#F TrivialTable( n, f )
##
TrivialTable := function( n, f )
    local z;
    z := Zero(f^n);
    return List( [1..n], x -> List( [1..n], y -> Immutable(ShallowCopy(z))));
end;

#############################################################################
##
#F RandomTable := function( n, p )
##
RandomTable := function( n, p )
    local m, q, l, V, v, k, c, T, h, i, j, r;
    m := n * (n-1)/2;
    q := p^n;
    l := List( [1..m], x -> q );
    V := GF(p)^n;
    v := Elements(V);
    r := Minimum( q^m-1, 2^28-1);
    while true do
        k := Random([0..r]);
        c := CoefficientsMultiadic( l, k );
        T := List( [1..n], x -> List( [1..n], y -> Zero(V) ) );
        h := 1;
        for i in [1..n] do
            for j in [i+1..n] do
                T[i][j] := v[c[h]+1];
                T[j][i] := -T[i][j];
                h := h + 1;
            od;
        od;
        if IsJacobiTable(T) = true then return T; fi;
    od;
end;

#############################################################################
##
#F Lie( T, a, b )
##
Lie := function( T, a, b )
    local c, i, j;
    c := 0*a;
    for i in [1..Length(T)] do
        for j in [1..Length(T)] do
            if i <> j and a[i] <> 0 * a[i] and b[j] <> 0*b[j] then
                c := c + a[i]*b[j]*T[i][j];
            fi;
        od;
    od;
    return c;
end;

#############################################################################
##
#F WordOfVector( w )
##
WordOfVector := function( w )
    local v, i;
    v := [];
    for i in [1..Length(w)] do
        if w[i] <> 0 * w[i] then Add( v, w[i] ); Add( v, i ); fi; 
    od;
    return v;
end;

#############################################################################
##
#F LieAlgebraByTable( S )
##
LieAlgebraByTable := function( S )
    local n, F, T, i, j, w;

    # set up
    n := Length(S);
    F := Field(Flat(S));
    T := EmptySCTable( n, Zero(F), "antisymmetric" );

    # fill in structure constants
    for i in [1..n] do
        for j in [i+1..n] do
            w := WordOfVector(S[i][j]);
            SetEntrySCTable( T, i, j, w );
        od;
    od;
    return LieAlgebraByStructureConstants( F, T );
end;

#############################################################################
##
#F TableByBasis( <L>, <b> )
##
TableByBasis := function( L, b )
    local n, S, i, j, s;
    n := Length(b);
    S := TrivialTable( n, LeftActingDomain(L) );
    for i in [1..n] do
        for j in [i+1..n] do
            s := Coefficients( b, b[i]*b[j] );
            S[i][j] := s;
            S[j][i] := -s;
        od;
    od;
    return S;
end;

#############################################################################
##
#F Table( <L> )
##
InstallMethod( Table, true, [IsLieAlgebra], 0, 
    function(L) return TableByBasis( L, Basis(L) ); 
end);

#############################################################################
##
#F TableByMatrices( <M> )
##
TableByMatrices := function( M )
    local n, A, f, S, i, j, s, c;

    # set up
    n := Length( M );
    A := List( M, Flat );
    f := Field( Flat(A) );
    S := TrivialTable( n, f );

    # compute entries
    for i in [ 1 .. n ] do
        for j in [ i+1 ..n ] do
            s := Flat( M[i]*M[j] - M[j]*M[i] );
            c := SolutionMat( A, s );
            S[i][j] := c; S[j][i] := -c;
        od;
    od;
    return S;
end;

#############################################################################
##
#F TableMod( <T>, <j> )
##
TableMod := function( T, j )
    return T{[1..j]}{[1..j]}{[1..j]};
end;

