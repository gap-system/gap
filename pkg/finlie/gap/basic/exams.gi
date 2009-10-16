#############################################################################
##
## exams.gi  .... examples
##

#############################################################################
##
#F AbelianLieAlgebra( n, p )
##
AbelianLieAlgebra := function( n, p )
    return LieAlgebraByTable( TrivialTable( n, GF(p) ) );
end;

#############################################################################
##
#F UnipotentLieAlgebra( n, p )
##
UnipotentLieAlgebra := function( n, p )
    local f, M, i, j, m, T, L;

    # set up
    f := GF(p);

    # define matrices
    M := [];
    for i in [1..n] do
        for j in [i+1..n] do
            m := MutableNullMat( n, n, f );
            m[i][j] := One(f);
            Add( M, m );
        od;
    od;

    # get table and Lie algebra
    T := TableByMatrices( M );
    L := LieAlgebraByTable( T );
    L!.mats := M;

    # return
    return L;
end;

#############################################################################
##
#F TriangularLieAlgebra( n, p )
##
TriangularLieAlgebra := function( n, p )
    local f, M, i, j, m, T, L;

    # set up
    f := GF(p);

    # the acting matrices
    M := [];
    for i in [1..n] do
        for j in [i..n] do
            m := MutableNullMat( n, n, f );
            m[i][j] := One(f);
            Add( M, m );
        od;
    od;

    # get table and Lie algebra
    T := TableByMatrices( M );
    L := LieAlgebraByTable( T );
    L!.mats := M;

    # return
    return L;
end;

#############################################################################
##
#F RandomSolvableMatrixLieAlgebra( n, p )
##
RandomSolvableMatrixLieAlgebra := function( n, p )
    local M, m, u, d, done, i, U;

    # get the full matrix algebra
    M := FullMatrixLieAlgebra( GF(p), n );
    m := Basis(M);
    u := [];
    d := 0;

    # find a soluble subalgebra
    done := false;
    while not done do 
        done := true;
        for i in [1..10] do
            U := Subalgebra( M, Concatenation(u,[Random(m)]) );
            if IsLieSolvable(U) and Dimension(U) > d then 
                u := BasisVectors(Basis(U));
                d := Dimension(U);
                done := false;
            fi;
        od;
    od;

    # get the structure constants
    U := Subalgebra( M, u );
    return LieAlgebraByTable( TableByBasis( U, Basis(U) ) );
end;

#############################################################################
##
#F LieAlgebraByMatrices( mats )
##
LieAlgebraByMatrices := function( mats )
    local T, L;
    T := TableByMatrices( mats );
    L := LieAlgebraByTable( T );
    L!.mats := mats;
    return L;
end;

#############################################################################
##
#F LieAlgebraByBasis( L, basis )
##
LieAlgebraByBasis := function( L, basis )
    return LieAlgebraByTable( TableByBasis(L, basis) );
end;


