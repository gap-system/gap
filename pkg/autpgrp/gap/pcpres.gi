#############################################################################
##
#W  autpgrp.gi                                                   Bettina Eick
##
#W  The input to the following function is the output of 
#W  AutomorphismGroupPGroup( G ) of the autpgrp package.
##
#W  The function computes a pc presentation for the solvable subgroup
#W  of Aut(G) defined by the agAutos of the input.
##

#############################################################################
##
#F PcgsInfoAutPGroup( A ) . . . . . . . . . . . . . . . set up info on layers
##
PcgsInfoAutPGroup := function( A )
    local G, d, p, f, spec, gens, layer, bases, i, auto, imgs, base, j,
          s, n, B, P, M, pcgs, e;

    # set up
    G := A.group;
    d := RankPGroup(G);
    p := PrimePGroup(G);
    f := GF(p);
    spec := SpecialPcgs( G );
    gens := spec{[1..d]};

    # catch layers and bases
    layer := [];
    bases := [];
    for i in [1..Length(A.agAutos)] do
        auto := A.agAutos[i];
        imgs := List( gens, x -> ExponentsOfPcElement( spec, x^auto ) );
        base := imgs{[1..d]}{[1..d]};
        
        # if base <> idmat, then the FrattiniFactor is permuted
        if base <> IdentityMat(d) then
            layer[i] := 1;
            bases[i] := base * One(f);
        else
            for j in [1..d] do imgs[j][j] := 0; od;
            e := Minimum( List( imgs, PositionNonZero ) );
            j := LGLayers( spec )[e];
            s := LGFirst( spec )[j];
            n := LGFirst( spec )[j+1];
            base := imgs{[1..d]}{[s..n-1]};
            layer[i] := j;
            bases[i] := Concatenation( base ) * One(f);
        fi;
    od;

    # set up
    B := rec();
    B.agAutos := A.agAutos;
    B.agOrder := A.agOrder;
    B.bases := bases;
    B.layer := layer;
    B.group := G;
    B.field := f;
    B.spec := spec;
    B.gens := gens;
    B.rank := d;

    # the first layer is particularly nasty 
    j := PositionNot( layer, 1 ); 
    if j > 1 then 
        M := Group( bases{[1..j-1]}, IdentityMat(d, f) );
        B.agHomom := IsomorphismPermGroup(M);
        P := Image(B.agHomom);
        pcgs := List( bases{[1..j-1]}, x -> Image(B.agHomom,x) );
        pcgs := PcgsByPcSequence( FamilyObj(One(P)), pcgs );
        SetRelativeOrders( pcgs, B.agOrder );
        B.agTopfc := pcgs;
    fi;
    return B;
end;

#############################################################################
##
#F ExponentsAutPGroup( B, auto ) . . . . . . . . . . .compute exponent vector
##
ExponentsAutPGroup := function( B, auto )
    local exps, imgs, perm, news, tmpa, j, e, s, n, subs, base;

    exps := List( B.agAutos, x -> 0 );
    imgs := List( B.gens, x -> ExponentsOfPcElement( B.spec, x^auto ) );
    base := imgs{[1..B.rank]}{[1..B.rank]};

    # if base <> idmat, then the FrattiniFactor is permuted
    if base <> IdentityMat(B.rank) then
        base := base * One(B.field);
        perm := Image( B.agHomom, base );
        news := ExponentsOfPcElement( B.agTopfc, perm );
        exps{[1..Length(news)]} := news; 
        tmpa := MappedVector( news, B.agAutos{[1..Length(news)]} );
        auto := tmpa^-1 * auto;
    fi;

    imgs := List( B.gens, x -> ExponentsOfPcElement( B.spec, x^auto ) );
    for j in [1..B.rank] do imgs[j][j] := 0; od;
    e := Minimum( List( imgs, PositionNonZero ) );
    while e <= Length( B.spec ) do

        # determine base for auto
        j := LGLayers( B.spec )[e];
        s := LGFirst( B.spec )[j];
        n := LGFirst( B.spec )[j+1];
        base := Concatenation( imgs{[1..B.rank]}{[s..n-1]} ) * One(B.field);

        # determine bases for layer
        s := PositionSorted( B.layer, j );
        n := PositionSorted( B.layer, j+1 );
        subs := B.bases{[s..n-1]};

        # solve and set exponents
        news := IntVecFFE( SolutionMat( subs, base ) );
        exps{[s..n-1]} := news; 

        # divide off and reset
        tmpa := MappedVector( news, B.agAutos{[s..n-1]} );
        auto := tmpa^-1 * auto;
        imgs := List( B.gens, x -> ExponentsOfPcElement( B.spec, x^auto ) );
        for j in [1..B.rank] do imgs[j][j] := 0; od;
        e := Minimum( List( imgs, PositionNonZero ) );
    od;
    return exps;
end;

#############################################################################
##
#F ImageAutPGroup( B, G, auto ) . . . . . . . . . . . . . . image in pc group
##
InstallGlobalFunction( ImageAutPGroup,
  function( B, G, auto )
    local exp;
    exp := ExponentsAutPGroup( B, auto );
    return MappedVector( exp, GeneratorsOfGroup( G ) );
  end);

#############################################################################
##
#F PcGroupAutPGroup(A) . . . . . . . . . . . . . . . . . . . compute pc group
##
InstallGlobalFunction( PcGroupAutPGroup, function( A )
    local B, C, m, F, f, r, i, j, o, w, e;
    B := PcgsInfoAutPGroup( A );
    m := Length( B.agAutos );
    F := FreeGroup( m );
    f := GeneratorsOfGroup(F);
    r := [];
    for i in [1..m] do
        for j in [i..m] do
            if i = j then
                o := B.agOrder[i];
                w := B.agAutos[i]^o;
                e := ExponentsAutPGroup( B, w );
                Add( r, f[i]^o / MappedVector( e, f ) );
            else
                w := B.agAutos[j]^B.agAutos[i];
                e := ExponentsAutPGroup( B, w );
                Add( r, f[j]^f[i] / MappedVector( e, f ) );
            fi;
        od;
    od;
    C := PcGroupFpGroup( F/r );
    C!.autos := B.agAutos;
    C!.autrec := B;
    return C;
end );

#############################################################################
##
#F InnerAutGroupPGroup( C ). . . . . . . . . . . . embed Inn(G) into pc group
##
InstallGlobalFunction( InnerAutGroupPGroup,
  function( C )
    local B, G, gens, auts, imgs, I;
    B := C!.autrec;
    G := B.group;
    gens := Pcgs(G);
    auts := List(gens, x -> PGAutomorphism(G, gens, List(gens, y->y^x)));
    imgs := List( auts, x -> ImageAutPGroup( B, C, x ) );
    I := Subgroup(C, imgs );
    return I;
  end);
