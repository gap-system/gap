
#############################################################################
##
#F LieAlgebraByJSystem( A, J )
##
LieAlgebraByJSystem := function( A, J )
    local n, S, i, j, k;

    n := Length(J);
    S := EmptySCTable( n, Zero(GF(2)), "antisymmetric" );

    for i in [1..n] do
        for j in [i+1..n] do
            if J[i] * A * J[j] <> Zero(GF(2)) then 
                k := Position( J, J[i]+J[j] );
                if IsBool(k) then return fail; fi;
                SetEntrySCTable( S, j, i, [1,k] );
            fi;
        od;
    od;

    return AlgebraByStructureConstants( GF(2), S );
end;

#############################################################################
##
#F Checks for Gram matrices
##
IsSymmetricMat := function(A)
    return A = TransposedMat(A);
end;

IsSingularMat := function(A)
    return RankMat(A) < Length(A);
end;

IsAlternateMat := function(A)
    return ForAll( [1..Length(A)], x -> A[x][x] = 0*A[x][x]);
end;

#############################################################################
##
#F IsJSystem
##
IsJSystem := function(A, J)
    local i, j;
    for i in [1..Length(J)] do
        for j in [1..i-1] do
            if J[i] * A * J[j] = One(GF(2)) then 
                if not J[i]+J[j] in J then return false; fi;
            fi;
        od;
    od;
    return true;
end;

#############################################################################
##
#F Gram Matrices
##
OnForms := function( elm, mat )
    return mat * elm * TransposedMat(mat);
end;

GramMatrices := function(n)
    local G, e, o;
    G := GL(n, GF(2));
    e := Filtered(Elements(G), IsSymmetricMat);
    o := Orbits(G, e, OnForms);
    return List(o, x -> x[1]);
end;

AlternateGramMatrices := function(n)
    local G, e, o;
    G := GL(n, GF(2));
    e := Filtered(Elements(G), IsSymmetricMat);
    e := Filtered(Elements(G), IsAlternateMat);
    o := Orbits(G, e, OnForms);
    return List(o, x -> x[1]);
end;

NonAlternateGramMatrices := function(n)
    local G, e, o;
    G := GL(n, GF(2));
    e := Filtered(Elements(G), IsSymmetricMat);
    e := Filtered(Elements(G), x -> not IsAlternateMat(x));
    o := Orbits(G, e, OnForms);
    return List(o, x -> x[1]);
end;

#############################################################################
##
#F SimpleLieAlgebraByGramMatrix1(n). . . . . . . . . . .  Kaplanski's case 1
##
SimpleLieAlgebraByGramMatrix1 := function(n)
    local A, V, J, L;

    # take Gram matrix
    A := Reversed(IdentityMat(n,GF(2)));
    if IsInt(n/2) then A[n][n] := One(GF(2)); fi;

    # construct basis
    V := GF(2)^n;
    J := Elements(V);
    J := Filtered( J, x -> x <> Zero(V) );
    if IsInt(n/2) then 
       J := Filtered( J, x -> x <> IdentityMat(n,GF(2))[1] );
    else
       J := Filtered( J, x -> x <> DiagonalOfMat(A) );
    fi;

    L := LieAlgebraByJSystem(A,J);
    SetName(L, Concatenation("K1(",String(n),")"));
    return L;
end;

#############################################################################
##
#F SimpleLieAlgebraByGramMatrix2(n) . . . . . . . . . . .  Kaplanski's case 2
##
SimpleLieAlgebraByGramMatrix2 := function(n)
    local A, V, J, L;

    if not IsInt(n/2) then return fail; fi;

    # take Gram matrix
    A := Reversed(IdentityMat(n,GF(2)));

    # construct basis
    V := GF(2)^n;
    J := Elements(V);
    J := Filtered( J, x -> x <> Zero(V) );

    L := LieAlgebraByJSystem(A,J);
    SetName(L, Concatenation("K2(",String(n),")"));
    return L;
end;

#############################################################################
##
#F SimpleLieAlgebraAlternateMats(n) . . . . . . . . . . . .Kaplanski's case 3
##
SimpleLieAlgebraAlternateMats := function(n)
    local mats, i, j, m, L;

    # take all alternate n x n matrices 
    mats := [];
    for i in [2..n+1] do
        for j in [i+1..n+1] do
            m := MutableNullMat(n+1,n+1,GF(2));
            m[i][j] := One(GF(2));
            m[j][i] := One(GF(2));
            Add(mats, m);
        od;
    od;
   
    # contruct
    L := LieAlgebra(GF(2), mats, "basis" );
    L := LieAlgebraByTable(TableByBasis(L, Basis(L)));
    SetName(L, Concatenation("K3(",String(n),")"));
    return L;
end;

#############################################################################
##
#F SimpleLieAlgebraByQuadraticForm(Q) . . . . . . . . . . .Kaplanski's case 4
##
SimpleLieAlgebraByQuadraticForm := function(Q)
    local n, V, J, L, A, i, j, b;

    # Q must be invertible
    if IsSingularMat(Q) then Error("Q is singular"); fi;
    n := Length(Q);

    ## check 
    #if n <= 8 or not IsInt(n/2) then 
    #    Error("dimension must be even and at least 8");
    #fi;

    # get a J system 
    V := GF(2)^n;
    J := Filtered( Elements(V), x -> x * Q * x = One(GF(2)) );

    # get a bilinear form
    A := NullMat( n, n, GF(2) );
    b := IdentityMat(n, GF(2) );
    for i in [1..n] do
        for j in [1..n] do
            A[i][j] := (b[i]+b[j])*Q*(b[i]+b[j]) - b[i]*Q*b[i] - b[j]*Q*b[j]; 
        od;
    od;

    # return 
    L := LieAlgebraByJSystem(A,J);
    if IsBool(L) then Error(); fi;
    return L;
end;

