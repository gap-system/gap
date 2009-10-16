#############################################################################
##
#W deriv.gi                                                      Bettina Eick 
##

#############################################################################
##
#F AdjointAction( <L>, <l> )
##
AdjointAction := function( L, l )
    local B, C;
    B := CBS(L);
    C := List( B, x -> l * x );
    return List( C, x -> CoefficientsByCBS( B, C ) );
end;

#############################################################################
##
#F DerivationsLieAlgebra(L)
##
DerivationsLieAlgebra := function( L )
    local n, T, f, A, e, i, j, m, k, a, M;

    # set up
    n := Dimension(L);
    T := TableByBasis(L, CBS(L));
    f := LeftActingDomain( L );

    # Construct the equation system.
    A:= NullMat( n^2, (n-1)*n*n/2, f );
    e:= 0;
    for i in [ 1 .. n ] do
        for j in [ i+1 .. n ] do
            for m in [ 1 .. n ] do
                e:= e+1;
                for k in [ 1 .. n ] do
                    A[ (k-1)*n+m ][e]:= A[ (k-1)*n+m ][e] + T[i][j][k];
                    A[ (i-1)*n+k ][e]:= A[ (i-1)*n+k ][e] - T[k][j][m];
                    A[ (j-1)*n+k ][e]:= A[ (j-1)*n+k ][e] - T[i][k][m];
                od;
            od;
        od;
    od;

    # Solve the equation system.
    if n = 1 then 
        A := [ [ One( f ) ] ]; 
    else 
        A := TriangulizedNullspaceMat(A);
    fi;
    a := Length(A); if a = 0 then Error("this should not happen"); fi;

    # Construct the generating matrices from the vectors.
    M := List( A, v -> CutVector(v, n) );
    return LieAlgebraByMatrices( M );
end;

#############################################################################
##
#M Derivations(L)
##
InstallOtherMethod( Derivations, true, [IsLieAlgebra], 0,
function(L) return DerivationsLieAlgebra(L); end);

#############################################################################
##
#M InnerDerivations( L, D )
##
InstallGlobalFunction( InnerDerivations, function( L, D )
    local T, M, c, I;
    T := List( TableByBasis(L, CBS(L)), Flat);
    M := List( D!.mats, Flat );
    c := List( T, x -> SolutionMat( M, x ) ) * CBS(D);
    I := Subalgebra( D, c );
    I!.acthom := LieHomomorphism( L, I, CBS(L), c );
    return I;
end );

#############################################################################
##
#M OperOnDerivations
##
OperOnDerivations := function( N, D, A )
    local gens, mats, flat, derm, a, d, m, v, c, B, nat;

    # get infos
    gens := GeneratorsOfGroup(A);
    mats := D!.mats;
    flat := List( mats, Flat );

    # compute action
    derm := [];
    for a in gens do
        d := [];
        for m in mats do
            v := a^-1 * m * a;
            c := SolutionMat( flat, Flat(v) );
            Add( d, c );
        od;
        Add( derm, d );
    od;

    # set up result
    B := Group( derm, derm[1]^0 );
    nat := GroupHomomorphismByImagesNC( A, B, gens, derm );
    return nat;
end;

