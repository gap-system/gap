AddPermOper := function(A)
    local G, r, p, base, V, norm, f, M, iso, P;

    # set up
    G := A.group;
    r := RankPGroup( G );
    p := PrimePGroup( G );

    # points
    base := IdentityMat( r, GF(p) );
    V    := GF(p)^r;
    norm := NormedVectors( V );

    # oper
    f    := function( pt, a ) return NormedRowVector( pt * a ); end;
    M    := Group( A.glOper, base );
    iso  := ActionHomomorphism( M, norm, f );
    P    := Image( iso );

    # reset
    A.glOper := GeneratorsOfGroup( P );
end;

ReduceAuto := function( auto, C, isom, gens, imgs )
    local news;
    news := List(imgs, x -> Image(auto, x));
    news := List(news, x -> PreImagesRepresentative(isom, x));
    news := GroupHomomorphismByImagesNC( C, C, gens, news );
    SetIsBijective( news, true );
    return news;
end;

AutomorphismActionCover := function( G, C )
    local pcgs, first, p, n, r, f, i, 
          chars, bases, S, H, kern, A, 
          F, Q, s, t, P, M, N, U, baseN, baseU, 
          OnSubs, gens, imgs, isom, Cimg;

    # start off
    pcgs := SpecialPcgs( G );
    first := LGFirst( SpecialPcgs(G) );
    p := PrimePGroup( G );
    n := Length(pcgs);
    r := RankPGroup( G );
    f := GF(p);

    # init automorphism group - compute Aut(G/G_1)
    Print("  AG: step 1: ",p,"^", first[2]-1, "\n");

    # compute characteristic subgroups
    chars := TwoStepCentralizersByLcs(G); Add(chars, C);
    bases := List( chars, x -> FrattiniQuotientBase( pcgs, x ) ) * One(f);

    # compute the matrixgroup stabilising all subspaces in chain
    S := StabilizingMatrixGroup( bases, r, p );

    # the Frattini Quotient
    H := FrattiniQuotientPGroup( G );
    kern := InitAgAutos( H, p );

    # set up aut group
    A := rec( );
    A.glAutos := InitGlAutos( H, GeneratorsOfGroup(S) );
    A.glOrder := Size(S) / Product( kern.rels );
    A.glOper  := GeneratorsOfGroup(S);
    A.agAutos := kern.auts;
    A.agOrder := kern.rels;
    A.one     := IdentityPGAutomorphism( H );
    A.group   := H;
    A.size    := A.glOrder * Product( A.agOrder );

    # add perm rep 
    AddPermOper(A);

    # check for large solvable subgroups
    TrySolvableSubgroup(A);

    # loop over remaining steps
    F := Range( IsomorphismFpGroupByPcgs( pcgs, "f" ) );
    Q := PQuotient( F, p, 1 );
    for i in [2..Length(first)-1] do

        # print info
        s := first[i];
        t := first[i+1];
        Print("  AG: step ",i ,": ",p,"^", t-s, " -- size ", A.size,"\n" );

        # the cover
        P := PCover( Q );
        M := PMultiplicator( Q, P );
        N := Nucleus( Q, P );
        U := AllowableSubgroup( Q, P );
        AddInfoCover( Q, P, M, U );

        # induced action of A on M
        LinearActionAutGrp( A, P, M );

        # compute stabilizer
        baseN := GeneratorsOfGroup(N);
        baseU := GeneratorsOfGroup(U);
        baseN := List(baseN, x -> ExponentsOfPcElement(Pcgs(M), x)) * One(f);
        baseU := List(baseU, x -> ExponentsOfPcElement(Pcgs(M), x)) * One(f);
        baseU := EcheloniseMat( baseU );
        PGOrbitStabilizer( A, baseU, baseN, false );

        # next step of p-quotient
        IncorporateCentralRelations( Q );
        RenumberHighestWeightGenerators( Q );

        # induce to next factor
        A := InduceAutGroup( A, Q, P, M, U );
    od;

    # now get a real automorphism group
    Print("  AG: full has type ", A.glOrder, " by ",A.agOrder,"\n" );

    # translate
    isom := CgsParallel( pcgs{[1..r]}, Pcgs(A.group){[1..r]});
    gens := Cgs(C);
    imgs := List(gens, x->MappedVector(ExponentsByIgs(isom[1],x),isom[2]));
    Cimg := Subgroup(A.group, imgs);

    # stabilise C
    OnSubs := function( U, auto, info ) return Image(auto, U); end;
    PGHybridOrbitStabilizer(A,A.glAutos,A.agAutos,Cimg,OnSubs,true);
    Print("  AG: stab has type ", A.glOrder, " by ",A.agOrder,"\n" );

    # convert A
    isom := GroupHomomorphismByImagesNC(C, Cimg, gens, imgs);
    A.agAutos := List(A.agAutos, x -> ReduceAuto(x, C, isom, gens, imgs));
    A.glAutos := List(A.glAutos, x -> ReduceAuto(x, C, isom, gens, imgs));
    A.one := IdentityMapping(C);
    A.group := C;

    return A;
end;

InducedAutCover := function(aut, f, t, e)
    local actT, invF, trs;

    # construct linear actions on t and f/f^e
    actT := AsMat(aut,t);
    invF := InvertMod(AsMat(aut,f), e);

    # construct translation
    trs := List([1..Length(f)], x -> MappedVector(invF[x],f));
    trs := List([1..Length(f)], x -> f[x]^-1 * Image(aut,trs[x]));
    trs := List(trs, x -> ExponentsByPcp(t,x));

    # return all
    return [actT, invF, trs];
end;

