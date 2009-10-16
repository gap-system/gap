#############################################################################
##
## solaut.gi  .... using the lower nilpotent basis
##

#############################################################################
##
#F GetModule( T, k, d )
##
GetModule := function( T, k, d )
    local n, I, M, i, j;
    n := k+d;
    I := IdentityMat( n, Field(T[1][1][1]) );
    M := List( [1..k], x -> [] );
    for i in [1..k] do
        for j in [1..d] do
            M[i][j] := -T[i][k+j]{[k+1..n]};
        od;
    od;
    return M;
end;

#############################################################################
##
#F GetCocycle( T, k, d )
##
GetCocycle := function( T, k, d )
    local n, c, i, j;
    n := k + d;
    c := [];
    for i in [1..k] do
        for j in [i+1..k] do
            c[FindPosition(i,j)] := T[i][j]{[k+1..n]};
        od;
    od;
    return Flat(c);
end;

#############################################################################
##
#F DerivationAutomorphisms( T, M )
##
DerivationAutomorphisms := function( T, M )
    local n, d, l, f, cc, au, i, j, k;

    n := Length(T);
    d := Length(M[1]);
    l := n + d;
    f := Field(T[1][1][1]);

    cc := OneCocyclesByTable( T, M );
    au := List( cc, x -> MutableIdentityMat( l, f ) );
    
    for i in [1..Length(cc)] do
        for j in [1..n] do
            for k in [1..d] do
                au[i][j][n+k] := cc[i][d*(j-1)+k];
            od;
        od;
    od;

    return au; 
end;

#############################################################################
##
#F CompatiblePairsOfTable( A, G, T, M )
##
CompatiblePairsOfTable := function( A, G, T, M )
    local f, n, I, m, C, D, d, g, k, R, r, s, J, act, U;

    # set up
    f := Field(T[1][1][1]);
    n := Length(T);
    I := IdentityMat(n, f);

    # get the centralizer of M and its factor
    m := List( M, Flat );
    C := TriangulizedNullspaceMat( m );
    D := TriangulizedBasis( m );
    d := Length(D);
    if d = 0 then return DirectProduct( A, G ); fi;
    
    # stabilize C in A
    if Length(C) > 0 and Size(A) > 1 then
        A := Stabilizer( A, C, OnBases );
        Info(InfoLieAut, 3, "     stabilizer of kernel has size ",Size(A));
    fi;

    # stabilize D in G
    if Size(G) > 1 and Length(D) < Length(D[1]) then
        g := GeneratorsOfGroup(G);
        k := List( g, x -> KroneckerProduct( TransposedMat(x^-1), x ) );
        G := Stabilizer( G, D, g, k, OnBases );
        Info(InfoLieAut, 3, "     stabilizer of image has size ",Size(G));
    fi;

    # set up direct product and its action
    R := DirectProduct( A, G );
    if Size(R) = 1 then return R; fi;
    r := SmallGeneratingSet(R);
    s := List( r, x -> 
         Tuple([x[1]^-1, KroneckerProduct(TransposedMat(x[2]^-1),x[2])]));

    # stabilize
    Info(InfoLieAut, 3, "     stabilize module ");
    act := function( M, tup ) return tup[1]*M*tup[2]; end;
    return StabilizerPlus( R, m, r, s, act, false );

    # alternative method which might in some cases be faster
    s := List( s, x -> KroneckerProduct( TransposedMat(x[1]), x[2] ) );
    act := OnRight;
    return StabilizerPlus( R, Flat(m), r, s, act, false );
end;

#############################################################################
##
#F  LinearActionOnCocycles( T, M, coh, cp )
##
LinearActionOnCocycles := function( T, M, coh, cp )
    local d, n, cc, at, ta, bt, ms, i, j, W, U, w, u, v, k, h;

    # get dimensions
    d := Length( M[1] );
    n := Length(T);

    # set up
    cc := List(Basis(Image(coh)), x -> PreImagesRepresentative(coh,x));
    at := List( cp, x -> x[1]^-1 );
    ta := List( at, TransposedMat );
    bt := List( cp, x -> x[2] );

    # set up matrices
    ms := List( cp, x -> [] );

    # loop over preimages
    for j in [1..Length(cc)] do

        # cut into pieces
        w := CutVector( cc[j], d );

        # turn vectors into a table
        W := List( [1..n], x -> [] );
        for k in [1..n] do
            W[k][k] := 0 * w[1];
            for h in [k+1..n] do
                W[k][h] :=  w[FindPosition(k,h)];
                W[h][k] := -W[k][h];
            od;
        od;

        for i in [1..Length(cp)] do

            # act on tails-table
            U := Mult( Mult( at[i], W ), ta[i] );

            # return from table to vectors
            u := [];
            for k in [1..n] do
                for h in [k+1..n] do
                    u[FindPosition(k,h)] := U[k][h];
                od;
            od;
    
            # act on vectors
            v := List( u, x -> x * bt[i] );

            # insert v into m 
            ms[i][j] := Image( coh, Concatenation( v ) );
        od;
    od;

    return ms;
end;

#############################################################################
##
#F InduciblePairsOfTable( CP, T, M, c )
##
InduciblePairsOfTable := function( CP, T, M, c )
    local gen, coh, mat, v;

    # catch a trivial case
    if Length(c) = 0 then return CP; fi;

    # generators of CP
    gen := GeneratorsOfGroup( CP );
    if Length(gen) = 0 then return CP; fi;

    # two cohomology
    Info(InfoLieAut, 3, "     compute two cohomology ");
    coh := TwoCohomologyByTable( T, M );
    if Dimension(Image(coh)) = 0 then return CP; fi;
   
    # image of c 
    v := Image( coh, c );
    if v = 0*v then return CP; fi;

    # action on coh
    Info(InfoLieAut, 3, "     compute linear action ");
    mat := LinearActionOnCocycles( T, M, coh, gen );

    # compute stabilizer of c
    Info(InfoLieAut, 3, "     stabilize cocycle ");
    return StabilizerPlus( CP, v, gen, mat, OnRight, false );
end;

#############################################################################
##
#F PreImageOfAutomorphism( T, M, S, aut )
##
PreImageOfAutomorphism := function( T, M, S, aut )
    local n, d, f, I, r, Sy, vt, N, i, j, k, As, a, b, s;

    # set up
    n := Length(T);
    d := Length(M[1]);
    f := Field( T[1][1][1] );
    I := IdentityMat(d, f);
    r := d*n;

    # catch a special case
    if n = 1 or r = 0 then 
        if not IsBool( IsAutomorphismOfTable(S,aut) ) then 
            Error("wrong lifting");
        fi;
        return aut;
    fi;

    # set up system and vector
    Sy := List( [1..r], x -> [] );
    vt := [];

    # adjoints for ai^alpha
    N := List( aut, x -> LinearCombination( x{[1..n]}, M ) );

    # loop to get system
    for i in [1..n] do
        for j in [i+1..n] do
            k := FindPosition(i,j);

            # linear system
            As := List( [1..n], x -> T[i][j][x]*I );
            As[i] := As[i] - N[j];
            As[j] := As[j] + N[i];
            AddLieEquation( Sy, As, k );

            # inhom part 
            vt[k] := - S[i][j]*aut;
            for a in [1..n] do
                for b in [1..n] do
                    vt[k] := vt[k] + aut[i][a]*aut[j][b]*S[a][b];
                od;
            od;
            vt[k] := vt[k]{[n+1..n+d]};
        od;
    od;

    # solve and cut  
    s := SolutionMat( Sy, Flat(vt) );
    if IsBool(s) then Error("no solution"); fi;
    s := CutVector( s, d );

    # fill into automorphism
    for i in [1..n] do
        for j in [n+1..n+d] do
            aut[i][j] := s[i][j-n];
        od;
    od;

    # check
    if not IsBool( IsAutomorphismOfTable(S,aut) ) then 
        Error("wrong lifting");
    fi;
    return aut;
end;

#############################################################################
##
#F PreImageOfInduciblePairs( T, M, S, img, ker )
##
PreImageOfInduciblePairs := function( T, M, S, img, ker )
    local n, d, l, f, p, ug, au, i, j, k, A;

    l := Length(T) + Length(M[1]);
    f := Field(T[1][1][1]);
    p := Characteristic(f);

    ug := ReducedGeneratingSet(img);
    au := List( ug, x -> MutableNullMat( l, l, f ) );

    if Length(ug) = 0 then 
        A := Group( ker );
        SetSize( A, p^Length(ker) );
        return A;
    fi;

    n := Length(ug[1][1]);
    d := Length(ug[1][2]);
   
    for i in [1..Length(au)] do
        for j in [1..l] do
            for k in [1..l] do
                if j <= n and k <= n then
                    au[i][j][k] := ug[i][1][j][k];
                elif j > n and k > n then
                    au[i][j][k] := ug[i][2][j-n][k-n];
                fi;
            od;
        od;
        au[i] := PreImageOfAutomorphism( T, M, S, au[i] );
    od;

    # add centrals
    Append( au, ker );

    # set up group
    A := Group(au);
    SetSize(A, Size(img)*p^Length(ker));
    return A;
end;

#############################################################################
##
#F AutomorphismGroupOfSpecialTable( S, wg )
##
AutomorphismGroupOfSpecialTable := function( S, wg )
    local f, cg, A, N, K, n, k, d, v, M, c, DA, CP, IP;

    # set up
    f := Field( S[1][1][1] );
    cg := Collected(wg);
    Info(InfoLieAut, 1, "got table with weights ",cg);

    # the first step is trivial
    n := cg[1][2];
    A := GL( n, f );
    N := TrivialTable( n, f );
    cg := cg{[2..Length(cg)]};

    # loop over series
    for v in cg do

        # get stepsize and factor
        Info(InfoLieAut, 1, "start layer ", v," with size ",Size(A));
        k := n;
        K := N;
        d := v[2];
        n := k + d;
        N := TableMod( S, n );

        # get module
        M := GetModule( N, k, d );

        # get cocycle
        c := GetCocycle( N, k, d );

        # get kernel automorphisms
        DA := DerivationAutomorphisms( K, M );

        # get compatible pairs
        Info(InfoLieAut, 2, "  compute comp-pairs in group of size ",Size(A));
        CP := CompatiblePairsOfTable( A, GL(d,f), K, M );

        # get inducible pairs
        Info(InfoLieAut, 2, "  compute indu-pairs in group of size ",Size(CP));
        IP := InduciblePairsOfTable( CP, K, M, c ); 

        # put results together for next step
        Info(InfoLieAut, 2, "  collect results \n");
        A := PreImageOfInduciblePairs( K, M, N, IP, DA );

    od;
    return A;
end;

#############################################################################
##
#F AutomorphismGroupOfSolvableLieAlgebraBySpecial( L )
##
InstallGlobalFunction(AutomorphismGroupOfSolvableLieAlgebraBySpecial, 
function( L )
    local B, S, A, a, b, w;

    # get table with series
    Info(InfoLieAut, 1, "get special table");
    B := LowerNilpotentBasis( L );
    S := TableByBasis( L, B.basis );

    # compute automorphism group
    A := AutomorphismGroupOfSpecialTable( S, B.weights );
    a := GeneratorsOfGroup(A);

    # translate back
    w := List( B.basis, x -> Coefficients( CBS(L), x ) );
    b := List( a, x -> w^-1 * x * w );
    B := Group(b);
    SetSize(B, Size(A));

    return B;
end ); 


