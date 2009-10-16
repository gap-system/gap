#############################################################################
##
#W twoext.gi .... extensions of nilpotent by derivation lie alg
##

#############################################################################
##
#F  CollectedJacobi( T, M, e, d, i, j, k )
##
CollectedJacobi := function( T, M, e, d, i, j, k )
    local n, m, f, As, Id, Vs, h, t, r, v;

    # set up
    n := Length(T) - e;
    m := n*(n-1)/2;
    f := Field( T[1][1][1] );

    # set up rhd
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
    As[r] := As[r] - M[k]{[e+1..e+d]}{[e+1..e+d]};

    r := FindPosition( j, k );
    As[r] := As[r] - M[i]{[e+1..e+d]}{[e+1..e+d]};

    r := FindPosition( i, k );
    As[r] := As[r] + M[j]{[e+1..e+d]}{[e+1..e+d]};

    # set up lhs
    Vs := List( [1..d], x -> Zero(f) );

    # loop
    for h in [n+1..n+e] do
        v := M[i][h-n]{[e+1..e+d]};
        Vs := Vs + T[j][k][h] * v;

        v := M[j][h-n]{[e+1..e+d]};
        Vs := Vs - T[i][k][h] * v;

        v := M[k][h-n]{[e+1..e+d]};
        Vs := Vs + T[i][j][h] * v;
    od;

    return rec( rhs := As, lhs := Vs );
end;

#############################################################################
##
#F  TwoCocyclesByTables( TN, TK, M, e )
##
TwoCocyclesByTables := function( TN, TK, M, e )
    local n, d, r, Sy, Rd, c, i, j, k, As, sol, nul;

    # set up
    n := Length(TK) - e;
    d := Length(TN) - e;
    r := d*n*(n-1)/2;
 
    # catch a special case
    if n = 1 then return rec( sol := [], all := []); fi;

    # set up system
    Sy := List( [1..r], x -> [] );
    Rd := [];

    # loop
    c := 0;
    for i  in [ 1 .. n ] do
        for j  in [ i+1 .. n ] do
            for k  in [ j+1 .. n ] do
                c := c+1;
                As := CollectedJacobi( TK, M, e, d, i, j, k );
                AddLieEquation( Sy, As.rhs, c );
                Append( Rd, As.lhs );
            od;
        od;
    od;

    # determine solution
    if Length(Sy[1])= 0 then 
        nul := IdentityMat( r, Field(TN[1][1][1]) );
        sol := List( [1..r], x -> 0* TN[1][1][1] );
    else
        sol := SolutionMat( Sy, Rd );
        if IsBool(sol) then return fail; fi;
        nul := TriangulizedNullspaceMat( Sy );
    fi;
    return rec( sol := sol, all := nul );
end;

#############################################################################
##
#F  TwoCoboundsByTables( TN, TK, M, e )
##
TwoCoboundsByTables := function( TN, TK, M, e )
    local n, d, r, f, I, Sy, As, i, j, k;

    # set up
    n := Length(TK) - e;
    d := Length(TN) - e;
    r := d*n;

    # catch a special case
    if n = 1 then return []; fi;

    # set up system
    Sy := List( [1..r], x -> [] );

    # set up identity
    f := Field( TK[1][1][1] );
    I := IdentityMat(d, f);

    # loop
    for i in [1..n] do
        for j in [i+1..n] do
            k := FindPosition( i, j );
            As := List( [1..n], x -> - TK[i][j][x]*I );
            As[i] := As[i] + M[j]{[e+1..e+d]}{[e+1..e+d]};
            As[j] := As[j] - M[i]{[e+1..e+d]}{[e+1..e+d]};
            AddLieEquation( Sy, As, k );
        od;
    od;

    # reduce to a basis
    Sy := TriangulizedBasis( Sy );

    # convert for technical purposes
    for i in [1..Length(Sy)] do
        Sy[i] := Immutable(Sy[i]);
        ConvertToVectorRep(Sy[i], f);
    od;

    return Sy;
end;

#############################################################################
##
#F  TwoCohomologyByTables( TN, TK, M, e )
##
TwoCohomologyByTables := function( TN, TK, M, e )
    local cc, cb;

    # compute
    cc := TwoCocyclesByTables(TN, TK, M, e);
    if IsBool(cc) then return fail; fi;
    if Length(cc.all) = 0 then 
        cb := [];
    else
        cb := TwoCoboundsByTables(TN, TK, M, e);
    fi;

    # check
    if not ForAll( cb, x -> not IsBool( SolutionMat(cc.all,x) ) ) then
        Error("cohomology is screwed up");
    elif cc.sol <> 0*cc.sol then
        Error("an example");
    fi;
 
    # o.k.
    return rec( sol := cc.sol, cc := cc.all, cb := cb );

end;

############################################################################
##
#F  LieExtensionByTablesAndCocycle( TN, TK, M, e, c )
##
LieExtensionByTablesAndCocycle := function( TN, TK, M, e, c )
     local d, k, r, f, p, l, S, w, i, j;

     # catch arguments
     d := Length(TN) - e;
     k := Length(TK) - e;
     r := k*(k-1)/2;
     f := Field( TN[1][1][1] );
     p := Characteristic(f);

     # adjust cocycle
     if IsBool(c) then
         c := List( [1..r], x -> List( [1..d], y -> Zero(f)));
     else
         c := CutVector( c, d );
     fi;

     # start with empty Table
     l := k+d+e;
     S := TrivialTable( l, f );
     w := List( [1..k], x -> Zero(f) );

     # fill up
     for i in [1..l] do
         for j in [i+1..l] do
             if j <= k then
                 S[i][j] := Concatenation( TK[i][j], c[FindPosition(i,j)] );
             elif i <= k then
                 S[i][j] := Concatenation( w, -M[i][j-k] );
             else
                 S[i][j] := Concatenation( w, TN[i-k][j-k] );
             fi;
             S[j][i] := - S[i][j];
         od;
    od;

    # check
    if not IsJacobiTable(S) then Error("extension wrong"); fi;

    # return
    return LieAlgebraByTable(S);
end;

