
if not IsBound( USE_NFMI ) then
    USE_NFMI := false;
fi;

if not IsBound( CHECKPCP ) then
    CHECKPCP := false;
fi;


#############################################################################
##
#A ReduceVector 
##
ReduceVector := function( v, d, f )
    local i;
    for i in [1..Length(v)] do
        if d[i] > 1 then v[i] := v[i] mod d[i]; fi;
    od;
    return v{f};
end;

ReduceTail := function( w, n, Q, d, f )
    local   i,  a,  v;

    i := 1;
    while i < Length(w) and w[i] <= n do i := i+2; od;

    a := w{[1..i-1]};

    v := Q[1] * 0;
    while i < Length(w) do
        v := v + Q[ w[i] - n ] * w[i+1];
        i := i+2;
    od;
    
    for i in [1..Length(v)] do
        if d[i] > 1 then v[i] := v[i] mod d[i]; fi;
    od;
    
    for i in [1..Length(f)] do 
        Add( a, n+i ); Add( a, v[ f[i] ] );
    od;

    return a;
end;

#############################################################################
##
#A OldSchurExtension(G) .. . . . . . . . . . . . . . . . . . . . . . .F/[R,F]
##
OldSchurExtension := function(G)
    local g, r, n, C, c, M, D, P, Q, d, f, l, I, coll, i, j, e, a, b,
          ocoll, H, U;

    # set up
    g := Igs(G);
    r := List(g, x -> RelativeOrderPcp(x));
    n := Length(Igs(G));

    # cohomology record and system
    C := CRRecordByMats(G, List(g, x -> IdentityMat(1)));
    c := IntTwoCocycleSystemCR(C); 
    M := c.base;

    # check
    if c.len = 0 then return G; fi;
    if Length(M) = 0 then M := NullMat(c.len, c.len); fi;
    if Length(M) < Length(M[1]) then 
         for i in [1..Length(M[1])-Length(M)] do
             Add(M, 0*M[1]);
         od;
    fi;

    Print( "#  SchurExtension: Dealing with ", 
           Length(M), "x", Length(M[1]), 
           "-matrix from cohomology calculation\n" );

    # set up
    if USE_NFMI then
        D := NormalFormIntMat(M,13);
        Q := D.coltrans;
        P := D.rowtrans;
        d := DiagonalOfMat( D.normal );
    else
        D := NormalFormConsistencyRelations(M);
        Q := D.coltrans;
        P := D.rowtrans;
        d := [1..Length(M[1])] * 0;
        d{List( D.normal, r->PositionNot( r, 0 ) )} := 
          List( D.normal, r->First( r, e->e<>0 ) ); 
    fi;    

    f := Filtered([1..Length(d)], x -> d[x] <> 1);
    l := Length(f);

    Print( "#  SchurExtension: Setting up collector with ", n+l, 
           " generators\n" );

    # initialize collector
    coll := FromTheLeftCollector(n+l);

    # relative orders
    for i in [1..n] do
        SetRelativeOrder(coll, i, r[i]);
    od;
    for i in [1..l] do
        SetRelativeOrder(coll, n+i, d[f[i]]);
    od;
    
    # relations of G
    ocoll := Collector( G );
    for i in [1..Length(C.enumrels)] do
        e := C.enumrels[i];
        b := ReduceVector(Q[i], d, f);
        if e[1] = e[2] then
            a := ExponentsByObj( ocoll, GetPower( ocoll, e[1] ) );
            SetPower(coll, e[1], ObjByExponents(coll, Concatenation(a,b)));
        elif e[1] > e[2] then
            a := ExponentsByObj( ocoll, GetConjugate( ocoll, e[1], e[2] ) );
            SetConjugate(coll, e[1], e[2], 
                     ObjByExponents(coll, Concatenation(a,b)));
        elif e[1] < e[2] then
            a := ExponentsByObj( ocoll, 
                         GetConjugate( ocoll, e[1], -(e[2]-e[1]) ) );
            SetConjugate(coll, e[1], -(e[2]-e[1]), 
                     ObjByExponents(coll, Concatenation(a,b)));
        fi;
    od;

    # set up group 
    UpdatePolycyclicCollector( coll );
    H := PcpGroupByCollectorNC(coll);

    # enforce surjectivity
    U := Subgroup(H, Cgs(H){[1..Length(Igs(G))]}); 
    Cgs(U);
    return U;
end;

#############################################################################
##
#A SchurExtension(G) . . . . . . . . . . . . . . . . . . . . . . . .  F/[R,F]
##
SchurExtension := function(G)
    local g, r, n, y, coll, k, i, j, e, sys, T;

    # set up
    g := Igs(G);
    r := List(g, x -> RelativeOrderPcp(x));
    n := Length(Igs(G));

    # get collector for extension
    y := n*(n-1)/2 + Length(Filtered(r, x -> x>0));
    coll := FromTheLeftCollector(n+y);

    # add a tail to each power and each positive conjugate relation
    k := n;
    for i in [1..n] do
        SetRelativeOrder(coll, i, r[i]);

        if r[i] > 0 then
            e := ObjByExponents(coll, Exponents(g[i]^r[i]));
            k := k+1; 
            Append(e, [k,1]); 
            SetPower(coll,i,e);
        fi;

        for j in [1..i-1] do
            e := ObjByExponents(coll, Exponents(g[i]^g[j]));
            k := k+1; 
            Append(e, [k,1]);
            SetConjugate(coll,i,j,e);
        od;
    od;

    # update 
    CompleteConjugatesInCentralCover(coll, Collector(G));
    UpdatePolycyclicCollector(coll);

    # evaluate consistency
    sys := CRSystem(1, y, 0);
    EvalConsistency( coll, sys );

    # determine quotient
    T := QuotientBySystem( coll, sys, n );

    return T;
end;

SchurExtensionEpimorphism := function( G )
    local   ext,  extgens,  Ggens,  images,  epi;

    ext := SchurExtension( G );
    extgens := GeneratorsOfGroup( ext );

    Ggens := GeneratorsOfGroup( G );
    images := List( extgens, g->Identity(G) );
    images{[1..Length(Ggens)]} := Ggens;

    epi := GroupHomomorphismByImagesNC( ext, G, extgens, images );
    SetFeatureObj( epi, IsMapping, true );
    SetFeatureObj( epi, IsGroupHomomorphism, true );
    SetFeatureObj( epi, IsSurjective, true );

    return epi;
end;

#############################################################################
##
#A SchurMultiplicator(G) . . . . . . . . . . . . . . . . . . . . . . . . M(G)
##
InstallMethod( SchurMultiplicator, true, [IsPcpGroup], 0, function(G)
    local n, H, M, T, D, I;

    # a simple check
    if Size(G) = 1 or IsCyclic(G) then return []; fi;

    # otherwise compute
    n := Length(Igs(G));
    H := SchurExtension(G); 
    M := Subgroup(H, Igs(H){[n+1..Length(Igs(H))]});

    # the finite case
    if IsFinite(G) then 
        T := TorsionSubgroup(M);
        return AbelianInvariants(T);
    fi;

    # the other case
    D := DerivedSubgroup(H);
    I := Intersection(M, D);
    return AbelianInvariants(I);
end);

#############################################################################
##
#A SchurCovering(G) . . . . . . . . . . . . . . . . . . . .M(G) extended by G
##
SchurCovering := function(G)
    local g, H, h, m, M, I, C;

    if Size(G) = 1 then return G; fi;

    # set up
    g := Igs(G);

    # get full extension F/[R,F]
    H := SchurExtension(G);
    h := Igs(H);

    # get R/[R,F]
    m := h{[Length(g)+1..Length(h)]};
    M := SubgroupByIgs(H, m);

    # get R cap F'
    I := Intersection(M, DerivedSubgroup(H));

    # get complement
    C := Subgroup(H, GeneratorsOfPcp( Pcp(M,I,"snf")));

    if not IsFreeAbelian(C) then Error("wrong complement"); fi;

    # get complement to I in M
    return H/C;
end;
    
#############################################################################
##
#A NonAbelianExteriorSquareEpimorphism(G) . . . . . . . . .  G wegde G --> G'
##
NonAbelianExteriorSquareEpimorphism := function( G )
    local   lift,  D,  gens,  imgs,  epi,  lambda;

    if Size(G) = 1 then return IdentityMapping( G ); fi;

    lift := SchurExtensionEpimorphism(G);
    D    := DerivedSubgroup( Source(lift) );

    gens := GeneratorsOfGroup( D );
    imgs := List( gens, g->Image( lift, g ) );
    epi  := GroupHomomorphismByImagesNC( D, DerivedSubgroup(G), gens, imgs );
                    
    SetFeatureObj( epi, IsMapping, true );
    SetFeatureObj( epi, IsGroupHomomorphism, true );
    SetFeatureObj( epi, IsSurjective, true );

    lambda := function( g, h )
        return Comm( PreImagesRepresentative( lift, g ),
                     PreImagesRepresentative( lift, h ) );
    end;

    D!.epimorphism := epi;
    D!.crossedPairing := lambda;

    return epi;
end;

#############################################################################
##
#A NonAbelianExteriorSquare(G) . . . . . . . . . . . . . . . . . .(G wegde G)
##
InstallMethod( NonAbelianExteriorSquare, true, [IsPcpGroup], 0, function(G)
    return Source( NonAbelianExteriorSquareEpimorphism( G ) );
end );
 
#############################################################################
##
#A NonAbelianExteriorSquarePlus(G) . . . . . . . . . . (G wegde G) by (G x G)
##
## This is the group tau(G) in our paper. 
##
## The follwoing function comutes the embedding of the non-abelian exterior
## square of G into tau(G).
##
NonAbelianExteriorSquarePlusEmbedding := function(G)
    local   g,  n,  r,  w,  extlift,  F,  f,  D,  d,  m,  s,  c,  i,  
            e,  j,  gens,  imgs,  k,  alpha,  S,  embed;

    if Size(G) = 1 then return G; fi;

    # set up
    g := Pcp(G);
    n := Length(g);
    r := RelativeOrdersOfPcp(g);
    w := List([1..2*n], x -> 0);

    extlift := NonAbelianExteriorSquareEpimorphism( G );

    # F/[R,F] = G*
    F := Parent( Source( extlift ) );
    f := Pcp(F);

    # the non-abelian exterior square D = G^G
    D := Source( extlift );
    d := Pcp(D);
    m := Length(d);
    s := RelativeOrdersOfPcp(d);

#    Print( "#  NonAbelianExteriorSquarePlus: Setting up collector with ", 2*n+m, 
#           " generators\n" );

    # set up collector for non-abelian exterior square plus
    c := FromTheLeftCollector(2*n+m);

    # the relators of GxG
    for i in [1..n] do

        # relative order and power
        if r[i] > 0 then 
            SetRelativeOrder(c, i, r[i]);
            e := ExponentsByPcp(g, g[i]^r[i]);
            SetPower(c, i, ObjByExponents(c,e));

            SetRelativeOrder(c, n+i, r[i]);
            e := Concatenation(0*e, e);
            SetPower(c, n+i, ObjByExponents(c,e));
        fi;

        # conjugates
        for j in [1..i-1] do
            e := ExponentsByPcp(g, g[i]^g[j]);
            SetConjugate(c, i, j, ObjByExponents(c,e));

            e := Concatenation(0*e, e);
            SetConjugate(c, n+i, n+j, ObjByExponents(c,e));

            if r[j] = 0 then
                e := ExponentsByPcp(g, g[i]^(g[j]^-1));
                SetConjugate(c, i, -j, ObjByExponents(c,e));
                e := Concatenation(0*e, e);
                SetConjugate(c, n+i, -(n+j), ObjByExponents(c,e));
            fi;

        od;
    od;

    # the relators of G^G
    for i in [1..m] do

        # relative order and power
        if s[i] > 0 then 
            SetRelativeOrder(c, 2*n+i, s[i]);
            e := ExponentsByPcp(d, d[i]^s[i]);
            e := Concatenation(w, e);
            SetPower(c, 2*n+i, ObjByExponents(c,e));
        fi;

        # conjugates
        for j in [1..i-1] do
            e := ExponentsByPcp(d, d[i]^d[j]);
            e := Concatenation(w, e);
            SetConjugate(c, 2*n+i, 2*n+j, ObjByExponents(c,e));

            if s[j] = 0 then
                e := ExponentsByPcp(d, d[i]^(d[j]^-1));
                e := Concatenation(w, e);
                SetConjugate(c, 2*n+i, -(2*n+j), ObjByExponents(c,e));
            fi;
        od;
    od;

    # the extension of G^G by GxG 
    #
    # This is the computation of \lambda in our paper: For (g_i,g_j) we take
    # preimages (f_i,f_j) in G* and calculate the image of (g_i,g_j) under
    # \lambda as the commutator [f_i,f_j].
    for i in [1..n] do
        for j in [1..n] do
            e := ExponentsByPcp(d, Comm(f[j], f[i]));
            e := Concatenation(w, e); e[n+j] := 1;
            SetConjugate(c, n+j, i, ObjByExponents(c,e));

            if r[i] = 0 then
                e := ExponentsByPcp(d, Comm(f[j], f[i]^-1));
                e := Concatenation(w, e); e[n+j] := 1;
                SetConjugate(c, n+j, -i, ObjByExponents(c,e));
            fi;
        od;
    od;

    # the action on G^G by GxG 
    for i in [1..n] do

        # create action homomorphism
        # G^G is generated by commutators of G*
        # G acts on G^G via conjugation with preimages in G*.
        gens := []; imgs := [];
        for k in [1..n] do
            for j in [1..n] do
                Add(gens, Comm(f[k], f[j]));
                Add(imgs, Comm(f[k]^f[i], f[j]^f[i]));
            od;
        od;
        alpha := GroupHomomorphismByImagesNC(D,D,gens,imgs);

        # compute conjugates
        for j in [1..m] do
            e := ExponentsByPcp(d, Image(alpha, d[j]));
            e := Concatenation(w, e);
            SetConjugate(c, 2*n+j, i, ObjByExponents(c,e));
            SetConjugate(c, 2*n+j, n+i, ObjByExponents(c,e));
        od;

        if r[i] = 0 then
            # create action homomorphism
            gens := []; imgs := [];
            for k in [1..n] do
                for j in [1..n] do
                    Add(gens, Comm(f[k], f[j]));
                    Add(imgs, Comm(f[k]^(f[i]^-1), f[j]^(f[i]^-1)));
                od;
            od;
            alpha := GroupHomomorphismByImagesNC(D,D,gens,imgs);

            # compute conjugates
            for j in [1..m] do
                e := ExponentsByPcp(d, Image(alpha, d[j]));
                e := Concatenation(w, e);
                SetConjugate(c, 2*n+j, -i, ObjByExponents(c,e));
                SetConjugate(c, 2*n+j, -(n+i), ObjByExponents(c,e));
            od;

        fi;

    od;

    if CHECKPCP then
        S := PcpGroupByCollector(c);
    else
        UpdatePolycyclicCollector(c);
        S := PcpGroupByCollectorNC(c);
    fi;
    S!.group := G;

    gens := GeneratorsOfGroup(S){[2*n+1..2*n+m]};
    embed := GroupHomomorphismByImagesNC( D, S, GeneratorsOfPcp(d), gens );

    return embed;
end;

NonAbelianExteriorSquarePlus := function( G )

    return Range( NonAbelianExteriorSquarePlusEmbedding( G ) );
end;

