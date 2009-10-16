#############################################################################
##
#F  orbits.gi  .... various orbit stabilizer methods
##

#############################################################################
##
#F MatrixOrbits( mats, dim, field )
##
MatrixOrbits := function( mats, dim, field )
    local  p, q, r, l, n, seen, reps, lens, rest, i, v, orb, j, w, im, h, 
           mat, rep;

    # set up
    p := Characteristic( field );
    q := p ^ dim;
    r := p ^ dim - 1;
    l := List( [ 1 .. dim ], x -> p );
    n := Length( mats );

    # set up storage
    seen := [  ];
    seen[q] := false;
    for i  in [ 1 .. q - 1 ]  do seen[i] := false; od;
    IsBlist( seen );

    # set up representatives and rest counter
    reps := [];
    lens := [];
    rest := r;

    # loop
    for i  in [ 1 .. r ]  do
        if not seen[i]  then
            seen[i] := true;

            # got a new orbit to compute
            v := CoefficientsMultiadic( l, i );
            orb := [ v ];
            rep := v;
            rest := rest - 1;
            Add( reps, rep );

            # list orbit
            j := 1;
            while j <= Length( orb )  do
                w := orb[j];
                for mat  in mats  do
                    im := w * mat;
                    h := MyIntCoefficients( p, dim, im );
                    if not seen[h]  then
                        seen[h] := true;
                        rest := rest - 1;
                        Add( orb, im );
                    fi;
                od;
                if rest = 0  then j := Length( orb ); fi;
                j := j + 1;
            od;
            Add( lens, Length(orb) );
        fi;
    od;
    return rec( lens := lens, reps := reps * One( field ) );
end;

#############################################################################
##
#F Isomorphisms
##
IsomorphismPermGroupDP := function(D)
    local info, G, H, isoG, isoH, DI;

    # check
    if IsBound(D!.isos) then return D!.isos; fi;

    if not HasDirectProductInfo(D) then 
        return IsomorphismPermGroup(D);
    fi;

    # create isos
    info := DirectProductInfo(D).groups;
    G := info[1];
    H := info[2];
    isoG := IsomorphismPermGroup(G);
    isoH := IsomorphismPermGroup(H);

    # set up image
    DI := DirectProduct( Image(isoG), Image(isoH) );

    # set up result
    D!.isos := [isoG,isoH, Embedding(DI,1), Embedding(DI,2)];
    return D!.isos;
end;

ImageDP := function( iso, tup )
    local p1, p2;
    if not IsList(iso) then return Image(iso, tup); fi;
    p1 := Image(iso[1], tup[1]);
    p2 := Image(iso[2], tup[2]);
    p1 := Image(iso[3], p1);
    p2 := Image(iso[4], p2);
    return p1*p2;
end;

#############################################################################
##
#F Done( l, L, D, o )
##
Done := function( l, L, D, o )
    if IsInt(l) and Size(L) * l = Size(D) then return true; fi;
    if IsBool(l) and Size(L) * o = Size(D) then return true; fi;
    return false;
end;

#############################################################################
##
#F StabilizerPlus( D, v, tups, gens, act, l )
##
StabilizerPlus := function( D, v, tups, gens, act, l )
    local orbit, trans, u, U, L, iso, k, i, w, j, tup, per, K;

    if Length(tups) = 0 or (IsInt(l) and l = 1) then return D; fi;

    # set up orbit and transversal 
    orbit := [ v ];
    trans := [ One(D) ];

    # set up stabilizer
    u := [One(D)];
    L := Group( () );

    # take permutation group isom
    iso := IsomorphismPermGroupDP(Parent(D));

    # list orbit and stabilizer
    k := 1;
    while k <= Length( orbit ) do
        for i in [ 1..Length(gens) ] do

            # compute the image of a point
            w := act( orbit[k], gens[i] );
            j := Position( orbit, w );

            if IsBool( j ) then

                # enlarge orbit and transversal
                Add( orbit, w );
                Add( trans, trans[k] * tups[i] );

            else

                # get stabilizer elements
                tup := trans[k] * tups[i] * trans[j]^-1;

                # check if its known
                if not tup in u then
                    per := ImageDP( iso, tup );
                    K := ClosureGroup( L, per );
                    if Size(K) > Size(L) then
                        L := K;
                        Add( u, tup );

                        # check if this is it
                        if Done( l, L, D, Length(orbit) ) then
                            U := SubgroupNC(D, u{[2..Length(u)]}); 
                            SetSize(U, Size(L));
                            return U;
                        fi;
                    fi;
                fi;
            fi;
        od;
        k := k + 1;
    od;

    if Done( l, L, D, Length(orbit) ) then
        U := SubgroupNC(D, u{[2..Length(u)]});
        SetSize(U, Size(L));
        return U;
    fi;

    Error("could not find stabilizer");
end;

#############################################################################
##
#F OrbitStabilizerTransversal( D, v, tups, gens, act )
##
OrbitStabilizerTransversal := function( D, v, tups, gens, act )
    local orbit, trans, u, U, L, iso, k, i, w, j, tup, per, K;

    # set up orbit and transversal 
    orbit := [ v ];
    trans := [ One(D) ];

    # set up stabilizer
    u := [One(D)];
    L := Group( () );

    # take permutation group isom
    iso := IsomorphismPermGroupDP(Parent(D));

    # list orbit and stabilizer
    k := 1;
    while k <= Length( orbit ) do
        for i in [ 1..Length(gens) ] do

            # compute the image of a point
            w := act( orbit[k], gens[i] );
            j := Position( orbit, w );

            if IsBool( j ) then

                # enlarge orbit and transversal
                Add( orbit, w );
                Add( trans, trans[k] * tups[i] );

            else

                # get stabilizer elements
                tup := trans[k] * tups[i] * trans[j]^-1;

                # check if its known
                if not tup in u then
                    per := ImageDP( iso, tup );
                    K := ClosureGroup( L, per );
                    if Size(K) > Size(L) then
                        L := K;
                        Add( u, tup );

                        # check if this is it
                        if Done( false, L, D, Length(orbit) ) then
                            U := Subgroup(D, u{[2..Length(u)]}); 
                            SetSize(U, Size(L));
                            return rec( stab := U, 
                                        orbit := orbit, 
                                        trans := trans);
                        fi;
                    fi;
                fi;
            fi;
        od;
        k := k + 1;
    od;

    if Done( false, L, D, Length(orbit) ) then
        U := Subgroup(D, u{[2..Length(u)]});
        SetSize(U, Size(L));
        return rec( stab := U, orbit := orbit, trans := trans );
    fi;

    Error("could not find stabilizer");
end;

#############################################################################
##
#F SeriesStabilizingGL( d, p )
##
SeriesStabilizingGL := function( d, p )
    local f, mats, l, size, i, n, j, mat, G;

    # set up
    f := GF(p);
    mats  := [];
    l     := 0;
    size  := 1;

    # loop
    for i in [2..Length(d)] do
        n := d[i-1] - d[i];

        # enlarge the size
        for j in [1..n] do
            size := size * (p^(d[1]-l) - p^(d[1]-l-j));
        od;

        # Construct the generators.
        if p = 2 then
            if n >= 2 then
                mat := MutableIdentityMat(d[1], f);
                mat[l+1][l+n] := One( f );
                mat[l+1][l+1] := Zero( f );
                for j in [ 2 .. n ] do
                    mat[l+j][l+j-1] := One( f );
                    mat[l+j][l+j]   := Zero( f );
                od;
                Add( mats, mat );

                mat := MutableIdentityMat(d[1], f);
                mat[l+1][l+2] := One( f );
                Add( mats, mat );
            fi;
        else
            mat := MutableIdentityMat(d[1], f);
            mat[l+1][l+1] := PrimitiveRoot( f );
            Add( mats, mat );

            if n >= 2 then
                mat := MutableIdentityMat(d[1], f);
                mat[l+1][l+1] := -One( f );
                mat[l+1][l+n] := One( f );
                for j in [ 2 .. n ] do
                    mat[l+j][l+j-1] := -One( f );
                    mat[l+j][l+j]   := Zero( f );
                od;
                Add( mats, mat );
            fi;
        fi;
        l := l + n;
        if l < d[1] then
            mat := MutableIdentityMat(d[1], f);
            mat[l][l+1] := One( f );
            Add( mats, mat );
        fi;
    od;

    G := GroupByGenerators( mats );
    SetSize( G, size );

    return G;
end;

#############################################################################
##
#F DiagonalBlockMat( mats, f )
##
DiagonalBlockMat := function( mats, f )
    local   n,  M,  m,  d;
    n := Sum( mats, m->Length(m) );
    M := NullMat( n, n, f );
    n := 0;
    for m in mats do
        d := Length(m);
        M{[1..d] + n}{[1..d] + n} := m;
        n := n + d;
    od;
    return M;
end;

#############################################################################
##
#F MatrixDirectProduct( G, H )
##
MatrixDirectProduct := function(G, H)
    local g, a, h, b, i, d, D, f;

    g := GeneratorsOfGroup(G);
    a := One(G);
    h := GeneratorsOfGroup(H);
    b := One(H);
    f := FieldOfMatrixGroup(G);

    d := [];
    for i in [1..Length(g)] do
        Add( d, DiagonalBlockMat( [g[i], b], f ) );
    od;
    for i in [1..Length(h)] do
        Add( d, DiagonalBlockMat( [a, h[i]], f ) );
    od;
    D := Group(d);
    SetSize(D, Size(G) * Size(H) );
    return D;
end;

#############################################################################
##
#F SumStabilizingGL( bases, d, p )
##
SumStabilizingGL := function( bases, d, p )
    local f, l, r, h, i, G, m, s, g, b;

    # set up
    f := GF(p);
    l := List( bases, Length );
    r := d - Sum(l);

    # start of
    if r > 0 then 
        G := GL(r,p);
    else
        G := false;
    fi;
    h := [];

    # loop
    for i in [1..Length(l)] do
        if l[i] > 0 then
            if IsBool(G) then 
                G := GL(l[i], p);
            else
                G := MatrixDirectProduct( G, GL(l[i], p) );
            fi;
            if r > 0 then
                m := MutableIdentityMat(d, f); 
                m[1][r+Sum(l{[1..i-1]})+1] := One( f );
                Add( h, m );
            fi;
        fi;
    od;

    # enlarge further
    s := Size(G);
    g := Filtered( GeneratorsOfGroup(G), x -> x <> x^0 );
    if r > 0 then
        s := s * p^(r*Sum(l));
        g := Concatenation( g, h );
    fi;

    # find conjugating matrix and conjugate
    b := Concatenation( bases );
    f := BaseSteinitzVectors( IdentityMat(d, f), b ).factorspace;
    b := Concatenation( f, b );
    g := List( g, x -> b^-1*x*b );

    # return
    G := Group(g, IdentityMat(d, GF(p)) );
    SetSize(G, s);
    return G;
end;


