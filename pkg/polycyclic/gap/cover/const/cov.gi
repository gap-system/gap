##
## Covers
##
SchurCovers := function(G)
    local p, GG, K, R, M, D, Z, k, H, C, T, P, e, O, bij, f, t, m, A, c, 
          l, n, i;

    if not IsPGroup(G) then return fail; fi;

    # set up
    p := Factors(Size(G))[1];

    # move to Pcp groups if necessary
    if IsPcGroup(G) then 
        GG := PcGroupToPcpGroup(G);
    else
        GG := G;
    fi;

    # cover and subgroups
    AddSExtension(GG);
    K := GG!.scov;
    R := GG!.modu;
    M := GG!.mult;
 
    #  info 
    Print("  Schur Mult has type ",AbelianInvariants(M),"\n");

    # catch a trival case
    if GG!.mord = 1 then return G; fi;

    # determine Z = Z(K) cap RK'
    D := ProductPcpGroups(K, R, DerivedSubgroup(K));
    Z := Intersection(Center(K), D);

    # determine phi(G) in K
    P := Subgroup(K, Concatenation(Igs(D), List(Pcp(K,D), x -> x^p)));

    # get small cover of K/Z
    H := Subgroup(K, GeneratorsOfPcp(Pcp(K,P)));

    # reduce into H and obtain H > C > T > M > 1
    C := Intersection( Z, H );
    T := TorsionSubgroup(C);

    # add in powers
    e := ExponentAbelianPcpGroup(T);
    O := OmegaAbelianPcpGroup(C, e);
    T := ProductPcpGroups(H, T, O);
    M := ProductPcpGroups(H, M, O);

    # change presentation
    k := Pcp(H,C);
    c := Pcp(C,T,"snf");
    t := Pcp(T,M,"snf");
    m := Pcp(M,O,"snf");
    H := PcpFactorByPcps(H, [k,c,t,m]);

    # move
    n := Length(Cgs(H));
    C := SubgroupByIgs(H, Cgs(H){[Length(k)+1..n]});
    T := SubgroupByIgs(H, Cgs(H){[Length(k)+Length(c)+1..n]});
    M := SubgroupByIgs(H, Cgs(H){[Length(k)+Length(c)+Length(t)+1..n]});
    f := Pcp(C,T); t := Pcp(T); m := Pcp(M);

    # info
    Print("  Schur Mult new type ",AbelianInvariants(T),"\n");

    # the acting automorphisms
    A := AutomorphismActionCover( H, C );

    # induce to desired action
    A.agAutos := List( A.agAutos, x -> InducedAutCover(x, f,t,e) );
    A.glAutos := List( A.glAutos, x -> InducedAutCover(x, f,t,e) );

    # determine complement classes under action of A
    c := FactorsComplementClasses( A, H, f, t, m );

    # adjust if necessary
    if IsPcGroup(G) and not CODEONLY then 
        for i in [1..Length(c)] do
            c[i] := PcpGroupToPcGroup(RefinedPcpGroup(c[i]));
        od;
    fi;

    return c;
end;

