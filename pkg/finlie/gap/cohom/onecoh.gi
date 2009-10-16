#############################################################################
##
#W onecohom .... for lie algebras and modules 
##

#############################################################################
##
#F AddLieEquation( Sy, As, a )
##
AddLieEquation := function( Sy, As, a )
    local d, m, l, i, j, k, r, s;

    # catch a special case
    if IsBool(a) and As = 0 * As then return; fi;

    # get dimensions
    d := Length(As[1]);
    m := Length(As);
    if IsBool(a) then
        l := Length(Sy[1]);
    else
        l := d*(a-1);
    fi;

    # loop
    for i in [1..m] do
        for j in [1..d] do
            for k in [1..d] do
                r := (i-1)*d+j;
                s := l+k;
                Sy[r][s] := As[i][j][k];
            od;
        od;
    od;
end;

#############################################################################
##
#F OneCocyclesByTable( T, M )
##
OneCocyclesByTable := function( T, M )
    local n, d, r, Sy, f, I, i, j, As;

    # set up
    n := Length(T);
    d := Length(M[1]);
    r := d*n;
    if r = 0 then return []; fi;

    # set up system
    Sy := List( [1..r], x -> [] );

    # set up identity
    f := Field( T[1][1][1] );
    I := IdentityMat(d, f);

    # loop
    for i in [1..n] do
        for j in [i+1..n] do
            As := List( [1..n], x -> - T[i][j][x]*I );
            As[i] := As[i] + M[j];
            As[j] := As[j] - M[i];
            AddLieEquation( Sy, As, true );
        od;
    od;

    if Length(Sy[1]) = 0 then
        return IdentityMat( r, Field(T[1][1][1]) );
    else
        return TriangulizedNullspaceMat( Sy );
    fi;
end;

#############################################################################
##
#F OneCoboundsByTable( T, M )
##
OneCoboundsByTable := function( T, M )
    local n, d, r, f, cb, i, j, k;

    # set up 
    n := Length(M);
    d := Length(M[1]);
    r := d*n;
    if r = 0 then return []; fi;
    f := Field(T[1][1][1]);

    # set up for generators
    cb := NullMat( d, r, f );
    
    # add entries
    for i in [1..d] do
        for j in [1..n] do
            for k in [1..d] do
                cb[i][(j-1)*d + k] := M[j][i][k];
            od;
        od;
    od;

    # reduce to basis
    cb := TriangulizedBasis( cb );
    for i in [1..Length(cb)] do
        cb[i] := Immutable(cb[i]);
        ConvertToVectorRep(cb[i], f);
    od;

    # that's it
    return cb;
end;

#############################################################################
##
#F OneCohomologyByTable( T, M )
##
OneCohomologyByTable := function( T, M )
    local cc, cb, n, d, l, f, V;

    cc := OneCocyclesByTable(T, M);
    cb := OneCoboundsByTable(T, M);

    f := Field( T[1][1][1] );
    n := Length(M);
    d := Length(M[1]);
    l := d*n;

    V := f^l;
    cc := Subspace(V, cc);
    cb := Subspace(V, cb);

    return NaturalHomomorphismBySubspace( cc, cb );
end;

#############################################################################
##
#F LieOneCohomology( L, B, M )
##
LieOneCocycles := function( L, B, M )
    return OneCocyclesByTable( TableByBasis(L, B), M );
end;

LieOneCobounds := function( L, B, M )
    return OneCoboundsByTable( TableByBasis(L, B), M );
end;

LieOneCohomology := function( L, B, M )
    return OneCohomologyByTable( TableByBasis(L, B), M );
end;


