
OneCocyclesByAction := function(L, action)
    local U, B, b, m, cc;

    B := Basis(L);
    b := BasisVectors(B);

    if action = "nat" then
        m := List(b, x -> TransposedMat(AdjointMatrix(B,x))); 
    elif action = "dual" then 
        m := List(b, x -> AdjointMatrix(B,x)); 
    elif action = "cen" then
        m := List(b, x -> IdentityMat(1, GF(2)));
    fi;

    U := LieAlgebraByGapLieAlgebra(L);
    cc := LieOneCocycles(U, m);
    return Length(cc);
end;

TwoCoboundsByAction := function(L, action)
    local U, B, b, m, cc;

    B := Basis(L);
    b := BasisVectors(B);

    if action = "nat" then
        m := List(b, x -> TransposedMat(AdjointMatrix(B,x))); 
    elif action = "dual" then 
        m := List(b, x -> AdjointMatrix(B,x)); 
    elif action = "cen" then
        m := List(b, x -> IdentityMat(1, GF(2)));
    fi;

    U := LieAlgebraByGapLieAlgebra(L);
    cc := LieTwoCobounds(U, m);
    return Length(cc);
end;

TwoCocyclesByAction := function(L, action)
    local U, B, b, m, cc;

    B := Basis(L);
    b := BasisVectors(B);

    if action = "nat" then
        m := List(b, x -> TransposedMat(AdjointMatrix(B,x))); 
    elif action = "dual" then 
        m := List(b, x -> AdjointMatrix(B,x)); 
    elif action = "cen" then
        m := List(b, x -> IdentityMat(1, GF(2)));
    fi;

    U := LieAlgebraByGapLieAlgebra(L);
    cc := LieTwoCocycles(U, m);
    return Length(cc);
end;

FingerprintZeta := function(L, l)
    local B, b, m, d, R, n, dims, u, U, e;
    B := Basis(L);
    b := BasisVectors(B);
    m := List(b, x -> AdjointMatrix(B,x));
    d := Dimension(L);
    R := MatrixAlgebra( LeftActingDomain(L), d );
    dims := [d];
    for n in [1..l] do
        u := List(m, x -> Sum( List([0..n], i -> x^(2^i))));
        U := Subspace( R, u );
        e := Dimension(U);
        #Add( dims, d - e );
        #d := e;
        Add( dims, e );
    od;
    return dims;
end;

FingerprintMinpolsRandom := function(L)
    local pol, i, l, m;
    pol := [];
    for i in [1..Dimension(L)^2] do
        l := Random(L);
        m := AdjointMatrix(Basis(L), l);
        Add( pol, MinimalPolynomial(LeftActingDomain(L), m) );
    od;
    return Collected(pol);
end;
    
PolynomialFlag := function(L, flag)
    local elm, min, sub, e, m, f, j;
    elm := Elements(L);
    min := [];
    sub := [];
    for e in elm do
        if flag = "minpol" then
            f := MinimalPolynomial(GF(2), AdjointMatrix(Basis(L), e));
        elif flag = "charpol" then 
            f := CharacteristicPolynomial(AdjointMatrix(Basis(L), e));
        elif flag = "eigen" then
            m := AdjointMatrix(Basis(L), e);
            f := List(Eigenspaces(GF(2), m), Dimension);
        fi;

        j := Position(min, f);
        if IsBool(j) then 
            Add( min, f );
            Add( sub, [e] );
        else
            Add( sub[j], e );
        fi;
    od;
    return rec( min := min, sub := sub );
end;

LieAlgebraFiltration := function(L)
    local B, b, p, D, m, l, I, hom, C, k, U, u, e, fil, d;

    # set up
    B := Basis(L);
    b := BasisVectors(B);
    p := Characteristic(LeftActingDomain(L));
    fil := [L];

    # determine derivations and inners
    D := LeftDerivations( B );
    m := List( b, x -> AdjointMatrix(B,x));
    l := List( m, LieObject );
    I := Subalgebra( D, l );
    if Dimension(D) = Dimension(I) then return fil; fi;

    # the first subspace L_0
    hom := NaturalHomomorphismByIdeal( D, I );
    C := Basis(Image(hom));
    k := List( m, x -> Coefficients(C, Image( hom, LieObject(x^p) )) );
    u := List( TriangulizedNullspaceMat( k ), x -> x * b );
    U := Subspace( L, u );

    # check and add
    if Length(u) = Dimension(L) then return fil; fi;
    Add( fil, U );
    if Length(u) = 0 then return fil; fi;
    
    # the sequence
    repeat

        # get L_{i-1} and L/L_{i-1}
        hom := NaturalHomomorphismBySubspace( L, U );
        C := Basis(Image(hom));
        d := Dimension(U);

        # annihilate L/L_{i-1}
        for e in b do
            k := List( u, x -> Coefficients( C, Image( hom, x*e ) ) );
            if Length(k) > 0 then 
                u := List( TriangulizedNullspaceMat(k), x -> x * b );
            fi;
        od;

        # set up L_i
        U := Subspace(L, u );

        # check whether we are finished
        if Length(u) = d then return fil; fi;
        Add( fil, U );
        if Length(u) = 0 then return fil; fi;
    until false;
end;

 

