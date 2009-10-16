
ModularGroupAlgebra := function(G)
    return GroupRing(GF(PrimePGroup(G)), G);
end;

VecToList := function(vec)
    local l, i;
    l := [];
    for i in [1..Length(vec)] do
        if vec[i] <> 0*vec[i] then
            Add( l, vec[i] );
            Add( l, i );
        fi;
    od;
    return l;
end;

AlgebraByTable := function( T )
    local n, F, S, i, j;

    n := Length(T);
    F := Field(T[1][1][1]);
    S := EmptySCTable( n, Zero(F) );

    for i in [1..n] do
        for j in [1..n] do
            SetEntrySCTable( S, i, j, VecToList(T[i][j]));
        od;
    od;

    return AlgebraByStructureConstants(F, S);
end;

ProductIdeal := function( A, I, J )
    local b, c, k, i, j;
    b := Basis(I);
    c := Basis(J);
    k := [];
    for i in [1..Length(b)] do
        for j in [1..Length(c)] do
            Add(k, b[i]*c[j]);
        od;
    od;
    return SubalgebraNC( A, k );
end;

IsNilpotentIdeal := function( A, J )
    local s, I;
    s := [J];
    I := StructuralCopy(J);
    while Dimension(I) > 0 do 
        I := ProductIdeal( A, J, I );
        if Dimension(I) >= Dimension( s[Length(s)]) then
            return false;
        fi;
        Add( s, I );
    od;
    return s;
end;


