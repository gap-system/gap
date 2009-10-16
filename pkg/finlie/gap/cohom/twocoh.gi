#############################################################################
##
#W twocohom .... for lie algebras and modules
##

#############################################################################
##
#F  Position of ( i, j ) in vector and reverse.
##
FindPosition := function( i, j ) return (j-1)*(j-2)/2 + i; end;

#############################################################################
##
#F  CollectedLieWord( T, M, i, j, k )
##
CollectedLieWord := function( T, M, i, j, k )
    local n, m, d, As, Id, h, t, r, f;

    # compute a set of matrices
    n := Length(T);
    m := n*(n-1)/2;
    d := Length( M[1] );
    f := Field( T[1][1][1] );
    As := List( [1..m], x -> NullMat( d, d, f ) );
    Id := IdentityMat( d, f );

    # loop 
    for h in [1..n] do

        t := T[j][k][h];
        if t <> 0 * t then 
            if i > h then 
                r := FindPosition( h, i );
                As[r] := As[r] - t * Id;
            elif i < h then
                r := FindPosition( i,h );
                As[r] := As[r] + t * Id;
            fi;
        fi;

        t := T[k][i][h];
        if t <> 0 * t then 
            if j > h then 
                r := FindPosition( h, j );
                As[r] := As[r] - t * Id;
            elif j < h then
                r := FindPosition( j, h );
                As[r] := As[r] + t * Id;
            fi;
        fi;

        t := T[i][j][h];
        if t <> 0 * t then 
            if k > h then
                r := FindPosition( h, k );
                As[r] := As[r] - t * Id;
            elif k < h then
                r := FindPosition( k, h );
                As[r] := As[r] + t * Id;
            fi;
        fi;

    od;
 
    # add the action
    r := FindPosition( i, j );
    As[r] := As[r] - M[k];

    r := FindPosition( j, k );
    As[r] := As[r] - M[i];

    r := FindPosition( i, k );
    As[r] := As[r] + M[j];

    return As;
end;

#############################################################################
##
#F  TwoCocyclesByTable( T, M )
##
TwoCocyclesByTable := function( T, M )
    local  n, d, r, Sy, i, j, k, As;
            
    # set up
    n := Length(T);
    d := Length(M[1]);
    r := d*n*(n-1)/2;
    if r = 0 then return []; fi;

    # set up system
    Sy := List( [1..r], x -> [] );

    # loop
    for i  in [ 1 .. n ] do
        for j  in [ i+1 .. n ] do
            for k  in [ j+1 .. n ] do
                As := CollectedLieWord( T, M, i, j, k );
                AddLieEquation( Sy, As, true );
            od;
        od;
    od;

    # and return solution
    if Length(Sy[1]) = 0 then 
        return IdentityMat( r, Field(T[1][1][1]) );
    else
        return TriangulizedNullspaceMat( Sy );
    fi;
end;

#############################################################################
##
#F  TwoCoboundsByTable( T, M )
##
##  T ist ein Lie-Table und M eine Liste von Matrizen.
##
TwoCoboundsByTable := function( T, M )
    local n, d, r, Sy, f, I, i, j, k, As;

    # set up
    n := Length(T);
    d := Length(M[1]);
    r := d*n;

    # catch a special case
    if n = 1 then return []; fi;

    # set up system
    Sy := List( [1..r], x -> [] );

    # set up identity
    f := Field( T[1][1][1] );
    I := IdentityMat(d, f);

    # loop
    for i in [1..n] do
        for j in [i+1..n] do
            k := FindPosition( i, j );
            As := List( [1..n], x -> - T[i][j][x]*I );
            As[i] := As[i] + M[j];
            As[j] := As[j] - M[i];
            AddLieEquation( Sy, As, k );
        od;
    od;

    # triangulize and convert
    Sy := TriangulizedBasis( Sy );
    for i in [1..Length(Sy)] do
        Sy[i] := Immutable(Sy[i]);
        ConvertToVectorRep(Sy[i], f);
    od;

    # that's it
    return Sy;
end;

#############################################################################
##
#F  TwoCohomologyByTable( T, M )
##
TwoCohomologyByTable := function( T, M )
    local cc, cb, n, d, l, f, V;

    cc := TwoCocyclesByTable(T, M);
    cb := TwoCoboundsByTable(T, M);

    n := Length(T);
    d := Length(M[1]);
    l := d*n*(n-1)/2;
    f := Field( T[1][1][1] );

    V := f^l;
    cc := Subspace(V, cc);
    cb := Subspace(V, cb);

    return NaturalHomomorphismBySubspace( cc, cb );
end;

#############################################################################
##
#F  LieTwoCohomology( L, B, M )
##
LieTwoCocycles := function( L, B, M)
    return TwoCocyclesByTable( TableByBasis(L, B), M );
end;

LieTwoCobounds := function( L, B, M)
    return TwoCoboundsByTable( TableByBasis(L, B), M );
end;

LieTwoCohomology := function( L, B, M )
    return TwoCohomologyByTable( TableByBasis(L, B), M );
end;


