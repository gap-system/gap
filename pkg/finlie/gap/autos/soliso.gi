#############################################################################
##
## soliso.gi  .... isomorphisms of soluble lie algebras
##

#############################################################################
##
#F CanonicalFormOfModule( A, T, M )
##
CanonicalFormOfModule := function( A, T, M )
    local f, n, I, d, a, b, G, g, k, R, r, s, m, act, os, N, j, is;

    # set up
    f := Field(T[1][1][1]);
    n := Length(T);
    I := IdentityMat(n, f);
    d := Length(M[1]);

    # rewrite automorphism action
    a := ReducedGeneratingSet(A);
    b := List(a, x -> x^-1);

    # rewrite linear action
    G := GL( d, f );
    g := GeneratorsOfGroup(G);
    k := List( g, x -> KroneckerProduct(TransposedMat(x^-1),x) );

    # set up direct product
    R := DirectProduct( A, G );
    r := Concatenation( List( a, x -> Tuple([x,One(G)]) ),
                        List( g, x -> Tuple([One(A),x]) ) );
    s := Concatenation( List( b, x -> Tuple([x,k[1]^0]) ),
                        List( k, x -> Tuple([One(A),x]) ) );

    # set up module
    m := List( M, Flat );
    act := function( vecs, tup ) return tup[1]*vecs*tup[2]; end;

    # get orbit,stabilizer and transversal
    os := OrbitStabilizerTransversal( R, m, r, s, act );

    # get canonical form
    N := Minimum( os.orbit );
    j := Position(os.orbit, N);

    return rec( modu := List( N, x -> CutVector( x, d ) ),
                auto := ConjugateSubgroup( os.stab, os.trans[j] ),
                isom := os.trans[j] );
end;

#############################################################################
##
#F MinimalPreimage( coh, c )
##
MinimalPreimage := function( coh, c )
    local v, K, B, b, l;

    # catch a special case
    if Length(c) = 0 then 
        v := Zero(Source(coh));
    else
        v := PreImagesRepresentative( coh, c );
    fi;

    # compute
    K := Kernel(coh);
    B := TriangulizedMat(BasisVectors(Basis(K)));
    for b in B do
        l := PositionNonZero(b);
        if v[l] <> 0 * v[l] then
            v := v - b/v[l];
        fi;
    od;
    return v;
end;

#############################################################################
##
#F CanonicalFormOfCocycle( A, T, M, c )
##
CanonicalFormOfCocycle := function( A, T, M, c )
    local gen, coh, mat, v, os, cc, j;

    # the zero case 
    if c = 0*c then return rec(auto:=A, isom:=One(A), cocl:=Flat(c)); fi;

    # generators of CP
    gen := SmallGeneratingSet( A );

    # two cohomology
    Info(InfoLieAut, 3, "  compute two cohomology ");
    coh := TwoCohomologyByTable( T, M );

    # image of c
    v := Image( coh, Flat(c) );
 
    # catch another special case
    if v = 0*v then 
        cc := MinimalPreimage( coh, v );
        return rec( auto := A, isom := One(A), cocl := cc );
    fi;

    # action on coh
    Info( InfoLieAut, 3, "  compute linear action ");
    mat := LinearActionOnCocycles( T, M, coh, gen );

    # compute stabilizer of c
    Info( InfoLieAut, 3, "  stabilize cocycle ");
    os := OrbitStabilizerTransversal( A, v, gen, mat, OnRight );

    # collect results
    cc := Minimum( os.orbit );
    j := Position( os.orbit, cc );

    # translate back one more step
    cc := MinimalPreimage( coh, cc );

    # return results
    return rec( auto := ConjugateSubgroup( os.stab, os.trans[j] ), 
                isom := os.trans[j], 
                cocl := cc ); 
end;

#############################################################################
##
#F PreImageOfIsomorphism( Sc, S, iso )
##
PreImageOfIsomorphism := function( Sc, S, iso )
    local n, d, f, I, r, Sy, vt, i, j, k, As, a, b, s, new, N, M;

    # set up
    n := Length( iso[1] );
    d := Length( iso[2] );
    f := Field( S[1][1][1] );
    I := IdentityMat(d, f);
    r := d*n;

    # set up result
    new := MutableNullMat(n+d,n+d, f);
    for i in [1..n] do
        for j in [1..n] do
            new[i][j] := iso[1][i][j];
        od;
    od;
    for i in [1..d] do
        for j in [1..d] do
            new[n+i][n+j] := iso[2][i][j];
        od;
    od;

    # catch a special case
    if n = 1 or r = 0 then 
        if IsIsomorphismOfTables( Sc, S, new ) <> true then 
            Error("wrong isomorphism");
        fi;
        return new; 
    fi;

    # set up system and vector
    Sy := List( [1..r], x -> [] );
    vt := [];

    # set up linear combinations
    N := List([1..n], x -> NullMat(d,d,f));
    for i in [1..n] do
        for j in [1..d] do
            N[i][j] := Sum( [1..n], k -> new[i][k] * Sc[k][n+j]{[n+1..n+d]});
        od;
    od;

    # loop to get system
    for i in [1..n] do
        for j in [i+1..n] do
            k := FindPosition(i,j);

            # linear system
            As := List( [1..n], x -> NullMat(d,d,f) );
            for a in [1..d] do
                for b in [1..n] do
                    As[b][a][a] := - S[i][j][b];
                od;
            od;
            As[i] := As[i] - N[j];
            As[j] := As[j] + N[i];
            AddLieEquation( Sy, As, k );

            # inhom part
            vt[k] := S[i][j]*new;
            for a in [1..n] do
                for b in [1..n] do
                    vt[k] := vt[k] - new[i][a]*new[j][b]*Sc[a][b];
                od;
            od;
            if vt[k]{[1..n]} <> 0 * vt[k]{[1..n]} then 
                Error("wrong vec"); 
            fi;
            vt[k] := vt[k]{[n+1..n+d]};
        od;
    od;

    # solve and cut
    s := SolutionMat( Sy, Flat(vt) );
    if IsBool(s) then Error("no solution"); fi;
    s := CutVector( s, d );

    # fill into isomorphism
    for i in [1..n] do
        for j in [n+1..n+d] do
            new[i][j] := s[i][j-n];
        od;
    od;

    # check
    if IsIsomorphismOfTables( Sc, S, new ) <> true then 
        Error("wrong isomorphism");
    fi;

    return new;
end;

#############################################################################
##
#F CanonicalFormOfSpecialTable( T, wg )
##
InstallGlobalFunction( CanonicalFormOfSpecialTable, function( T, wg )
    local f, cg, n, N, Nc, Ac, ic, iv, v, d, k, K, Kc, M, Mc, i, j, W, Wc, 
          c, cc, DA;

    # set up
    f := Field( T[1][1][1] );
    cg := Collected(wg);
    Info( InfoLieAut, 1, "compute cf for table with weights ",cg);

    # the first step is trivial
    n := cg[1][2];
    N := TrivialTable( n, f );
    Ac := GL( n, f );
    Nc := N;
    ic := IdentityMat( n, f );

    # loop over series
    cg := cg{[2..Length(cg)]};
    for v in cg do
        Info(InfoLieAut, 2, " ");
        Info(InfoLieAut, 2, "start layer ", v," with size ", Size(Ac));

        # get indices
        d := v[2];
        k := n;
        n := k + d;

        # set up factors
        K := N;
        N := TableMod( T, n );
        Kc := Nc;

        # extend isom
        ic := Tuple( [ic, IdentityMat(d,f)] );
        iv := ic^-1;

        # get modules for K and for Kc
        Info(InfoLieAut, 2, "  correct module with size ", Size(Ac));

        M := List( [1..k], x -> [] );
        for i in [1..k] do
            for j in [1..d] do
                M[i][j] := -N[i][k+j]{[k+1..n]}; 
            od;
        od;
        Mc := List( [1..k], x -> LinearCombination( iv[1][x], M ) );
   
        # find canonical form for module + compatible pairs
        Mc := CanonicalFormOfModule( Ac, Kc, Mc );

        # collect results
        ic := ic * Mc.isom;
        iv := ic^-1;
        Ac := Mc.auto;
        Mc := Mc.modu;
          
        # get cocycles for K and for Kc
        Info(InfoLieAut, 2, "  correct cocycle with size ", Size(Ac));

        W := List( [1..k], x -> [] );
        c := [];
        for i in [1..k] do
            W[i][i] := 0*Mc[1][1];
            for j in [i+1..k] do
                W[i][j] := N[i][j]{[k+1..n]};
                W[j][i] := -W[i][j];
                c[FindPosition(i,j)] := W[i][j];
            od;
        od;

        Wc := Mult( Mult( iv[1], W ), TransposedMat(iv[1]) );
        cc := [];
        for i in [1..k] do
            for j in [i+1..k] do
                cc[FindPosition(i,j)] := Wc[i][j] * ic[2];
            od;
        od;

        # find canonical form for cocycle + inducible pairs
        cc := CanonicalFormOfCocycle( Ac, Kc, Mc, cc );

        # collect results
        ic := ic * cc.isom;
        Ac := cc.auto;
        cc := cc.cocl;

        # compute extension
        Nc := ExtensionTableByTableAndCocycle( Kc, Mc, cc );

        # compute isomorphism
        ic := PreImageOfIsomorphism( Nc, N, ic );
 
        # compute automorphism group
        DA := DerivationAutomorphisms( Kc, Mc );
        Ac := PreImageOfInduciblePairs( Kc, Mc, Nc, Ac, DA );
    od;
    return rec( Table := Nc, isom := ic, auto := Ac );
end );

#############################################################################
##
#F CanonicalFormOfOfSolvableLieAlgebra( L )
##
InstallGlobalFunction( CanonicalFormOfSolvableLieAlgebra, function( L )
    local B, T, S, C;
    Info( InfoLieAut, 1, "determine special table ");
    B := LowerNilpotentBasis( L );
    T := TableByBasis( L, B.basis );
    S := CanonicalFormOfSpecialTable( T, B.weights );
    C := LieAlgebraByTable(S.Table);
    C!.isom := S.isom;
    C!.autgrp := S.auto;
    return C;
end );

InstallMethod( CanonicalFormOfLieAlgebra, true, [IsLieAlgebra], 0,
function( L )
    if not IsLieSolvable(L) then TryNextMethod(); fi;
    return CanonicalFormOfSolvableLieAlgebra(L);
end);
