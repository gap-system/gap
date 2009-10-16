
MyBaseMat := function(mat)
    local new, j;
    if Length(mat) = 0 then return mat; fi;
    new := StructuralCopy(mat);
    TriangulizeMat(new);
    j := Position(new, 0*new[1]);
    if IsBool(j) then return new; fi;
    return new{[1..j-1]};
end;

IsInvariant := function( base, mats )
    local mat, b;
    for mat in mats do
        for b in base do
            if IsBool(SolutionMat(base, b*mat)) then return false; fi;
        od;
    od;
    return true;
end;

LastNonZero := function( list, F )
    local i;
    for i in Reversed( [1..Length(list)] ) do
        if list[i] <> Zero(F) then return i; fi;
    od;
    return false;
end;

IndVector := function( g, d, base )
    if IsBool(base) then return g; fi;
    return SolutionMat(base, g){[1..d]};
end;

IndMatrix := function( hom, mat )
    local ind, baseI, baseS, b, e, f, g;
    ind := [];
    baseI := Basis( ImagesSource( hom ) );
    baseS := Basis( Source( hom ) );
    for b in baseI do
        e := PreImagesRepresentative( hom, b );
        f := e * mat;
        g := ImagesRepresentative( hom, f );
        Add( ind, Coefficients( baseI, g ) );
    od;
    ind := Immutable(ind);
    ConvertToMatrixRep( ind );
    return ind;
end;

BasisSocleSeries := function( G )
    local d, F, s, m, M, L, N, W, U, b, i, c, w;

    # set up
    d := Length(G.one[2]);
    F := G.field;
    s := [[]];

    # construct module
    m := Union(List(G.glAutos, x->x[2]),List(G.agAutos,x->x[2]));
    M := GModuleByMats( m, d, F );

    # construct series stepwise
    U := [];
    while Length(U) < d do
        L := SMTX.InducedActionFactorModuleWithBasis( M, U );
        N := GModuleByMats( Set(L[1].generators), F );
        W := SMTX.BasisSocle( N );
        U := EcheloniseMat(Concatenation(W * L[2], U));
        Add( s, U );
    od;
    s := Reversed(s);

    # get basis and weights
    b := [];
    w := [];
    for i in [1..Length(s)-1] do
        c := BaseSteinitzVectors(s[i],s[i+1]).factorspace;
        Append(b, c);
        Append(w, List(c, x -> i));
    od;

    # return basis
    return rec( basis := b, weights := w );
end;

SeriesByWeights := function( w, F )
    local d, s, I;
    d := Length(w);
    I := IdentityMat( d, F );
    s := List( Set(w), x -> I{[Position(w,x)..d]} ); Add(s, []);
    return s;
end;

