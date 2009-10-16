
IsAutomorphismByTable := function( T, m )
    local i, j, a, b;
    if Length(m) <> Length(T) then return false; fi;
    if RankMat(m) <> Length(m) then return false; fi;
    for i in [1..Length(T)] do
        for j in [1..Length(T)] do
            a := MultBySC( T, Field(T[1][1][1]), m[i], m[j] );
            b := T[i][j] * m;
            if a <> b then return false; fi;
        od;
    od;
    return true;
end;

IsAutomorphismByAlgebra := function( A, m )
    local  i, j, B, l, r;
    B := Basis( A );
    for i  in [ 1 .. Length(B) ]  do
        for j  in [ i + 1 .. Length(B) ]  do
            l := (B[i]*B[j]) * m;
            r := (B[i]*m) * (B[j]*m);
            if l <> r then return false; fi;
        od;
    od;
    return true;
end;

CheckGroupByTable := function( G, T )
    local g;
    for g in G.glAutos do
        if not IsAutomorphismByTable( T, g ) then 
            return false;
        fi;
    od;
    for g in G.agAutos do
        if not IsAutomorphismByTable( T, g ) then 
            return false;
        fi;
    od;
    if not IsAutomorphismByTable( T, G.one ) then 
        return false;
    fi;
    return true;
end;

CheckGroupByAlgebra := function( G, A )
    local g, hom;
    for g in G.glAutos do
        hom := AlgebraHomomorphismByImages( A, A, Basis(A), Basis(A)*g );
        if not IsAlgebraHomomorphism(hom) then 
            return false;
        fi;
    od;
    for g in G.agAutos do
        hom := AlgebraHomomorphismByImages( A, A, Basis(A), Basis(A)*g );
        if not IsAlgebraHomomorphism(hom) then 
            return false;
        fi;
    od;
    return true;
end;

CheckIsomByTables := function( T, S, epi )
    local n, i, j, a, b; 

    # first check bijective
    if not RankMat(epi) = Length(epi[1]) then return false; fi;
    if not Length(epi) = Length(epi[1]) then return false; fi;

    # now check multiplicative
    n := Length(T);
    for i in [1..n] do
        for j in [1..n] do
            a := T[i][j] * epi;
            b := MultBySC( S, Field(S[1][1][1]), epi[i], epi[j] );
            if a <> b then 
                Error(i,"  ",j);
            fi;
        od;
    od;
    return true;
end;

CheckCoverEpimorphism := function( C, S )
    local n, m, i, j, a, b, c, epi; 

    epi := C.iso;

    # check epi
    if not RankMat(epi) = Length(epi[1]) then return false; fi;

    # check multiplicative
    m := Length(C.mul);
    n := Length(C.cov)-m;

    # check top part only
    for i in [1..n] do
        for j in [1..n] do
            a := C.cov[i][j]{[1..n]};
            b := C.cov[i][j]{[n+1..n+m]} * C.mul^-1;
            a := Concatenation(a,b)*epi;
            c := MultBySC( S, Field(S[1][1][1]), epi[i], epi[j] );
            if a <> c then 
                Print(i," ",j," \n");
                return false; 
            fi;
        od;
    od;

    return true;
end;

