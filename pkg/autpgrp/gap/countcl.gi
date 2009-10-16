#############################################################################
##
#W  countcl.gi                                                   Bettina Eick
##
#W  Let GL(n,p) act linearly on some space V. The function in this file can 
#W  be used to count the number of orbits of subspaces of dimension k arising 
#W  in this action.
##
#W  As an application, the function in this file can be used to count the 
#W  number of p-groups of p-class 2 with n generators or the number of 
#W  Lie algebras over GF(p) with n generators.
##

#############################################################################
##
#F SpinUpCyclic( v, mat, d )
##
SpinUpCyclic := function( v, mat, d )
    local b, i;
    b := [v]; for i in [1..d-1] do b[i+1] := b[i] * mat; od;
    TriangulizeMat(b);
    return b;
end;

#############################################################################
##
#F JordanBlockLengths( mat, F )
##
JordanBlockLengths := function( g, F )
    local chr, min, fc, fm, ns, V, W, U, i, f, e, h, k, v, t;

    # char poly 
    chr := CharacteristicPolynomial(g);
    fc := Collected(Factors(chr));

    # min poly 
    min := MinimalPolynomial(F, g);
    fm := Factors(min);

    # set up
    ns := List( fc, x -> List( [1..x[2]], y -> 0 ) );
    V := g^0;

    # loop 
    for i in [1..Length(fc)] do

        # determine V_i
        f := fc[i][1];
        e := Length(Filtered(fm, x -> x = f)); 
        h := Value( f^e, g );
        W := TriangulizedNullspaceMat(h);
        k := InducedActionFactor( [g], W, [] )[1];

        # split cyclic
        while not IsBool(k) do 
            ns[i][e] := ns[i][e] + 1;
            if Length(k) = e * Degree(f) then 
                k := false;
            else
                h := Value( f^(e-1), k );
                v := First( k^0, x -> x*h <> 0*x );
                W := SpinUpCyclic( v, k, e*Degree(f) );
                U := BaseSteinitzVectors(k^0, W).factorspace;
                k := InducedActionFactor( [k], U, W )[1];
                t := Collected(Factors(MinimalPolynomial( F, k )));
                e := t[1][2];
            fi;
        od;
    od;
    return rec( blks := ns, degs := List(fc, x -> Degree(x[1])));
end;

#############################################################################
##
#F Two small help functions
##
WeightedSum := function(vec)
    return Sum(List( [1..Length(vec)], x -> x * vec[x] ));
end;

PartialSums := function(vec)
    return List( [1..Length(vec)], x -> Sum(vec{[x..Length(vec)]}));
end;

#############################################################################
##
#F Deltas( blls, degs, k )
##
Deltas := function( ni, d, k )
    local ds, i, r, new, del, s, j, m;
    ds := [[]];
    i := 1;
    r := Length(d);
    while i <= r do
        new := [];
        for del in ds do
            s := Sum(List([1..i-1], x -> del[x]*d[x]));
            if i < r then 
                m := Minimum( ni[i], QuoInt(k-s, d[i]) );
                for j in [0..m] do
                    Add( new, Concatenation( del, [j] ) );
                od;
            fi;
            if i = r then 
                j := (k-s) / d[i];
                if IsInt(j) and j <= ni[i] then 
                    Add( new, Concatenation( del, [j] ) );
                fi;
            fi;
        od;
        ds := new;
        i := i + 1;
    od;
    return ds;
end;

#############################################################################
##
#F Gammas( deli, vis )
##
Gammas := function( d, v )
    local par, i;
    par := Partitions( d );
    for i in [1..Length(par)] do
        if Length(par[i]) <= Length(v) and 
           ForAll( [1..Length(par[i])], x -> par[i][x] <= v[x] ) then 
            par[i] := Concatenation(par[i], 0*[1..Length(v)-Length(par[i])]);
        else
            par[i] := false;
        fi;
    od;
    return Filtered(par, x -> not IsBool(x));
end;

#############################################################################
##
#F PChoose( n, k, q ) . . . . . . . . . .number of k-dim subspaces in GF(q)^n
##
PChoose := function( n, k, q )
    local qn, qd, i, size;
    if n / 2 < k then k:= n - k; fi;
    size:= 1;
    qn:= q^n;
    qd:= q;
    for i in [ 1 .. k ] do
        size:= size * ( qn - 1 ) / ( qd - 1 );
        qn:= qn / q;
        qd:= qd * q;
    od;
    return size;
    #return Size(Subspaces(GF(q)^n, k));
end;

#############################################################################
##
#F Feval(a, b, q ) . . . . . . . . . . . . . . . . . . .evaluate f on a, b, q
##
Feval := function( a, b, q )
    local l, s, i;
    Add( b, 0 );
    l := Length(a);
    s := 1;
    for i in [1..l] do
        s := s * q^(b[i+1]*(a[i]-b[i]));
        s := s * PChoose(a[i]-b[i+1], b[i]-b[i+1], q);
    od;
    return s;
end;

#############################################################################
##
#F FixedPointsByDecom( blocks, degs, p, k )
##
FixedPointsByDecom := function( blks, degs, p, k )
    local r, ni, ds, vi, t, td, tg, delta, gamma, i, gs;

    # set up
    r := Length(degs);

    # compute deltas
    ni := List( blks, WeightedSum );
    ds := Deltas( ni, degs, k );

    # precompute vij
    vi := List( blks, PartialSums );

    # add up
    t := 0;
    for delta in ds do
        td := 1;
        for i in [1..r] do
            gs := Gammas( delta[i], vi[i] );
            tg := 0;
            for gamma in gs do
                tg := tg + Feval( vi[i], gamma, p^degs[i] );
            od;
            td := td * tg;
        od;
        t := t + td;
    od;

    # that's it
    return t;
end;

############################################################################
##
#F CountOrbitsGL( n, p, k, Action )  . . . . . . count the orbits of GL(n,p) 
##
## Action defines the action and k the dimension of the subspaces to count.
##
InstallGlobalFunction( CountOrbitsGL, function( n, p, k, Action )
    local G, cls, jor, len, fix, cl, g, h, J, t, j, l;

    # set up
    G := GL(n,p);
    cls := ConjugacyClasses(G);

    # catch input
    if IsBool(k) then l := n*(n-1)/2-1; fi;

    # infos
    jor := [];
    len := [];
    fix := [];

    for cl in cls do

        # get g and action
        g := Representative(cl);
        h := Action(g, GF(p));
        Info(InfoAutGrp, 1, "start class of order ", Order(g));

        # compute jordan blocks n_{ij}
        J := JordanBlockLengths(h, GF(p));

        # check if known
        j := Position( jor, J );
        if IsBool( j ) then 
            Info( InfoAutGrp, 2, "  Degree: ",J.degs," -- Jordan ", J.blks);
            if IsBool(k) then 
                t := List([1..l], x -> FixedPointsByDecom(J.blks,J.degs,p,x));
            else
                t := FixedPointsByDecom( J.blks, J.degs, p, k );
            fi;
            Add( jor, J );
            Add( len, Size(cl) );
            Add( fix, t );
            Info( InfoAutGrp, 2, "  class yields ",t);
        else
            len[j] := len[j] + Size(cl);
        fi;
    od;
    return Sum( List( [1..Length(jor)], i -> len[i]*fix[i] ) ) / Size(G);
end );
 
#############################################################################
##
#F Some Actions
##
WedgeAction := function( mat, f )
    local M, N;
    M := GModuleByMats( [mat], f );
    N := WedgeGModule( M );
    return N.generators[1];
end;

TensorAction := function( mat, f )
    return KroneckerProduct( mat, mat );
end;

WedgePlusAction := function( mat, f )
    return DirectSumMat( WedgeAction(mat,f), mat );
end;

############################################################################
##
#F NumberOfPClass2PGroups( n, p, [k] )
##
InstallGlobalFunction( NumberOfPClass2PGroups, function( arg )
    local n, k, c, m;
    if Length(arg) = 3 then 
        return CountOrbitsGL( arg[1], arg[2], arg[3], WedgePlusAction );
    elif Length(arg) = 2 then
        n := arg[1];
        m := n*(n+1)/2;
        c := []; c[m] := 1;
        for k in [1..m-1] do
            if not IsBound( c[k] ) then 
                c[k] := CountOrbitsGL( n, arg[2], k, WedgePlusAction );
                c[m-k] := c[k];
            fi;
        od;
        return c;
    fi;
    Error("wrong input");
end );

############################################################################
##
#F NumberOfClass2LieAlgebras( n, p, [k] )
##
InstallGlobalFunction( NumberOfClass2LieAlgebras, function( arg )
    local n, k, c, m;
    if Length(arg) = 3 then 
        return CountOrbitsGL( arg[1], arg[2], arg[3], WedgeAction );
    elif Length(arg) = 2 then
        n := arg[1];
        m := n*(n-1)/2;
        c := []; c[m] := 1;
        for k in [1..m-1] do
            if not IsBound( c[k] ) then 
                c[k] := CountOrbitsGL( n, arg[2], k, WedgeAction );
                c[m-k] := c[k];
            fi;
        od;
        return c;
    fi;
    Error("wrong input");
end );

