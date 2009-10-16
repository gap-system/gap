#############################################################################
##
#F lieext.gi .... extensions of lie algebras
##

#############################################################################
##
#F  ExtensionTableByTableAndCocycle( T, M, v )
##
ExtensionTableByTableAndCocycle := function( T, M, v )
     local n, d, l, m, c, f, V, W, S, i, j;

     # set up
     n := Length(T);
     d := Length(M[1]);
     l := n+d;
     m := n*(n-1)/2;

     # construct spaces
     f := Field( T[1][1][1] );
     V := f^l;
     W := f^n;

     # catch a special case
     if IsBool(v) then v := List( [1..d*m], x -> Zero(f) ); fi;

     # start with empty Table and cut cocycle
     S := List( [1..l], x -> List( [1..l], y -> Zero(V) ) );
     c := CutVector( v, d );

     # fill up
     for i in [1..l] do
         for j in [i+1..l] do
             if j <= n then
                 S[i][j] := Concatenation( T[i][j], c[FindPosition(i,j)] );
             elif i <= n then
                 S[i][j] := Concatenation( Zero(W), -M[i][j-n] );
             fi;
             S[j][i] := - S[i][j];
         od;
    od;

    return S;
end;

#############################################################################
##
#F  LieExtensionByCocycle( L, B, M, v )
##
LieExtensionByCocycle := function(L, B, M, v)
    local T, S;
    T := TableByBasis(L, B);
    S := ExtensionTableByTableAndCocycle( T, M, v );
    if not IsBool(IsJacobiTable(S)) then Error("v is not a cocycle"); fi;
    return LieAlgebraByTable(S);
end;

#############################################################################
##
#F  LieExtensionByDerivations( N ) ... extend N by Der(N)
##
LieExtensionByDerivations := function( N )
    local B, L, M, l, dl, m, dm, d, f, T, cm, cl, i, j, c;

    # set up Lie algebras
    B := Basis(N);
    if Length(B) < Length(B[1]![1]) then 
        L := LieAlgebraByBasis( N, B );
    else
        L := N;
    fi;
    M := Derivations( B );

    # set up some stuff
    l := Basis(L);
    dl := Dimension(L);
    m := Basis(M);
    dm := Dimension(M);
    
    # the extension
    d := dm + dl;
    f := LeftActingDomain(L);
    T := TrivialTable( d, f );

    # get zeros
    cm := List( [1..dm], x -> 0 ) * One(f);
    cl := List( [1..dl], x -> 0 ) * One(f);

    # add bottom entries
    for i in [1..dm] do
        for j in [i+1..dm] do
            c := Concatenation( Coefficients( m, m[i]*m[j] ), cl );
            T[i][j] := c;
            T[j][i] := -c;
        od;
    od;

    # add top entries to table
    for i in [1..dl] do
        for j in [i+1..dl] do
            c := Concatenation( cm, Coefficients( l, l[i]*l[j] ) );
            T[dm+i][dm+j] := c;
            T[dm+j][dm+i] := -c;
        od;
    od;

    # add mixed entries 
    for i in [1..dm] do
        for j in [1..dl] do
            c := (l[j]![1])*(m[i]![1]);
            c := Concatenation(cm, c);
            T[i][dm+j] := c;
            T[dm+j][i] := -c;
        od;
    od;
   
    return LieAlgebraByTable(T);
end;
