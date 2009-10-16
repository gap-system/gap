#############################################################################
##
## general.gi  .... general stuff
##

EigenspaceOfMats := function( mats, p, i )
    local new, spc, j;
    new := List( mats, x -> NullspaceMat(x - i*x^0) );
    spc := new[1];
    for j in [2..Length(new)] do
        spc := SumIntersectionMat( spc, new[j] )[2];
    od;
    return spc;
end;

EigenspacesOfMats := function( mats, p )
    return List( [0..p-1], x -> EigenspaceOfMats( mats, p, x ) );
end;

EigenspaceSeriesOfMats := function( mats, p )
    local eig, bas, tmp, i;
    eig := EigenspacesOfMats( mats, p );
    bas := [[]];
    tmp := [];
    for i in [1..Length(eig)] do
        if Length(eig[i]) > 0 then 
            tmp := Concatenation( tmp, eig[i] );
            TriangulizeMat( tmp );
            Add( bas, tmp );
        fi;
    od;
    if Length( tmp ) < Length(mats[1]) then Add( bas, mats[1]^0 ); fi;
    return Reversed(bas);
end; 

SolveTriangularMat := function( mat, v )
    local c, i, d, j;
    c := List( mat, x -> 0*v[1] );
    d := List( mat, PositionNonZero );
    for i in [1..Length(v)] do
        if v[i] <> 0 * v[i] then
            j := Position( d, i );
            if IsBool(j) then return false; fi;
            c[j] := v[i];
            v := v - c[j] * mat[j];
        fi;
    od;
    return c;
end;

CutVector := function( c, d )
    return List( [1..Length(c)/d], x -> c{[d*(x-1)+1..d*x]} );
end;

TriangulizedMat := function( m )
    local l;
    l := MutableCopyMat(m);
    TriangulizeMat(l);
    return l;
end;

TriangulizedBasis := function( m )
    local l, j;
    if Length(m) = 0 then return m; fi;
    l := TriangulizedMat(m);
    j := Position( l, 0*l[1] );
    if IsBool(j) then return l; fi;
    return l{[1..j-1]};
end;

OnBases := function( base, mat )
    return TriangulizedMat( base * mat );
end;

OnNormedVectors := function( v, mat )
    return NormedRowVector( v * mat );
end;

InstallMethod( SmallGeneratingSet, "for direct product", true, [IsGroup
and HasDirectProductInfo], SUM_FLAGS,
function(D)
    local info, G, H, g, h;
    info := DirectProductInfo(D);
    G := info.groups[1];
    H := info.groups[2];
    g := GeneratorsOfGroup(G);
    h := GeneratorsOfGroup(H);
    g := Filtered( g, x -> x <> x^0 );
    g := Set(g);
    g := List( g, x -> Tuple([x,One(H)]) );
    h := Filtered( h, x -> x <> x^0 );
    h := Set(h);
    h := List( h, x -> Tuple([One(G),x]) );
    return Concatenation(g,h);
end );

ReducedGeneratingSet := function( G )
    local g;
    g := GeneratorsOfGroup(G);
    g := Filtered( g, x -> x <> x^0 );
    return Set(g);
end;

ActOnMatrixAlgebra := function( g )
    local d, f, I, m, i, j, M;
    d := Length(g);
    f := Field(g[1][1]);
    I := IdentityMat( d^2, f );
    m := List( [1..d], x -> [] );
    for i in [1..d] do
        for j in [1..d] do
            M := MutableNullMat(d,d,f);
            M[i][j] := One(f);
            m[i][j] := SolutionMat(I, Flat(g^-1 * M * g) ); 
        od;
    od;
    return Concatenation(m);
end;

