
KernelOfLieModule := function( M )
    local b, m, v, k;
    b := M.basis;
    m := M.mats;
    v := List(m, Flat);
    k := TriangulizedNullspaceMat(v);
    return List( k, x -> LinearCombination(k,b) );
end;

RewriteByBasis := function( L, M )
    local a, b, c, m;
    a := M.basis;
    b := Basis(L);
    c := List( b, x -> Coefficients(a, x) );
    m := List( c, x -> LinearCombination(x, M.mats) );
    M.basis := b;
    M.mats := m;
    return M;
end;
    
IsInducedByOneDim := function( L, M )
    local k, K, hom, f, e, i, u, U, z, d, char, a, m, N, c;

    if M.dim = 1 then return true; fi;

    # adjust
    M := RewriteByBasis( L, M );

    # get kernel 
    k := KernelOfLieModule(M);
    K := Subalgebra( L, k );
    hom := NaturalHomomorphismByIdeal( L, K );

    # get elements
    f := Elements(Image(hom));
    e := List( f, x -> PreImagesRepresentative( hom, x ) );

    # loop over elements 
    for i in e do
        U := Subalgebra( L, Concatenation( k, [i] ) );
        u := Basis( U, Concatenation(k, [i]) );
        z := List( k, x -> NullMat(1,1,M.field) );
        d := Dimension(L) - Dimension(U);
        char := List( [1..d], x -> Indeterminate(M.field,x) );

        # loop over modules
        for a in M.field do
            m := rec( basis := u, field := M.field, dim := 1, 
                      mats := Concatenation([[[a]]], z) ); 
            N := InducedLieModule( L, U, m, char );
            c := EvalAndChopLieModules( N, char );

            # see whether this does it
            c := Filtered(c, x -> x.dim = M.dim); 
            c := Filtered(c, x -> IsAbsIrrLieModule(x)); 
            c := ReduceLieModules( c );
            c := List( c, x -> RewriteByBasis(L, x) );
            if ForAny(c, x -> IsomorphicLieModules(x,M)) then 
                return true;
            fi;
        od;
    od;
    return false;
end;

