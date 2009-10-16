#############################################################################
##
#M  PseudoRandomNormalClosureElement( <group> ) . . . . . . . . pseudo random elements of a group
##



BindGlobal("Group_InitPseudoRandomNC",function( sub, grp, len, scramble )
    local   gens,  seed,  i;

    # we need at least as many seeds as generators
    gens := GeneratorsOfGroup(sub);
    if 0 = Length(gens)  then
        SetPseudoRandomSeed( sub, [[]] );
        return;
    fi;
    len := Maximum( len, Length(gens), 2 );

    # add random generators
    seed := ShallowCopy(gens);
    for i  in [ Length(gens)+1 .. len ]  do
        seed[i] := Random(gens);
    od;
    SetPseudoRandomNCSeed( sub, [seed,One(grp)] );

    # scramble seed
    for i  in [ 1 .. scramble ]  do
        PseudoRandomNormalClosureElement(grp,sub);
    od;

end);


InstallGlobalFunction(PseudoRandomNormalClosureElement, 
        function(grp,sub)
    local   seed,  i,  j, x;

    # set up the seed
    if not HasPseudoRandomNCSeed(sub)  then
        i := Length(GeneratorsOfGroup(sub));
        Group_InitPseudoRandomNC( sub, grp, i+10, Maximum( i*10, 100 ) );
    fi;
    seed := PseudoRandomNCSeed(sub);
    if 0 = Length(seed[1])  then
        return One(grp);
    fi;

    # construct the next element
    i := Random([ 1 .. Length(seed[1]) ]);

    repeat
        j := Random([ 1 .. Length(seed[1]) ]);
    until i <> j;
    
    x := PseudoRandom(grp);
    if Random([true,false])  then
        seed[1][j] := seed[1][i]^x * seed[1][j];
    else
        seed[1][j] := seed[1][j] * seed[1][i]^x;
    fi;
    
    seed[2] := seed[2]*seed[1][j];
    return seed[2];

end);


InstallGlobalFunction(IsProbablyPerfect, function( G )
    local   NmrTries,  K,  ngens,  ordbounds,  j,  k,  i;
    NmrTries := ValueOption("NmrTries");
    if NmrTries = fail then
        NmrTries := 100;
    fi;
    K := SubgroupNC(G, List(Combinations(GeneratorsOfGroup(G),2), c->Comm(c[1],c[2])));
    if IsTrivial(K) then 
        return IsTrivial(G);
    fi;
    ngens := Length(GeneratorsOfGroup(G));
    ordbounds := ListWithIdenticalEntries(ngens,0);
    for j in [1..NmrTries] do
        k := PseudoRandomNormalClosureElement(G,K);
        for i in [1..ngens] do
            if ordbounds[i] <> 1 then
                ordbounds[i] := Gcd(ordbounds[i], Order(GeneratorsOfGroup(G)[i]*k));
            fi;
        od;
        if ForAll(ordbounds, x->x =1) then 
            return true;
        fi;
    od;
    return false;
end);

InstallGlobalFunction(DerivedSubgroupApproximation, function(G)
    local   NumberOfElements,  gens,  Limit,  nmr,  x;
    NumberOfElements := ValueOption("NumberOfElements");
    if NumberOfElements = fail then
        NumberOfElements := 5;
    fi;
    gens := [];
    Limit := 2*Length(GeneratorsOfGroup(G));
    nmr := 0;
    repeat 
        nmr := nmr + 1;
        x := PseudoRandom(G);
        UniteSet(gens, Set(GeneratorsOfGroup(G), y->Comm(y,x)));
    until nmr >= NumberOfElements or Size(gens) > Limit;
    return SubgroupNC(G,gens);
end);

InstallGlobalFunction(DerivedSubgroupChainApproximation,
        function(G, k)
    local   base,  D,  i;
    if k < 1 then
        return G;
    fi;
    base := 5;
    D := G;
    for i in [1..k] do
        D := DerivedSubgroupApproximation( D : NumberOfElements := base);
        if Length(GeneratorsOfGroup(D)) = 0 then
            return D;
        fi;
    od;
    return D;
end);


BindGlobal("NPPsi",function(e,q)
    local   psi,  phi,  cs,  c,  a;
    psi := 1;
    phi := q^e-1;
    if e <> 1 then
        cs := Set(Factors(e));
        for c in cs do
            a := Gcd(phi,q^(e/c)-1);
            while a > 1 do
                psi := a*psi;
                phi := phi/a;
                a := Gcd(phi,a);
            od;
        od;
    fi;
    return psi;
end);

InstallGlobalFunction(PPDDegrees, function(g,q)
    local   ppds,  f,  x,  l,  degs,  i,  p,  y,  j;
    ppds := [];
    if not IsRationalFunction(g) then
        g := CharacteristicPolynomial(g);
    fi;
    x := IndeterminateOfLaurentPolynomial(g);
    l := Factors(g);
    degs := List(l,DegreeOfLaurentPolynomial);
    SortParallel(degs,l);
    for i in [1..Length(l)] do
        if IsBound(degs[i]) then
            p := NPPsi(degs[i],q);
            y := PowerMod(x,p,l[i]);
            if not IsOne(y) then
                Add(ppds,degs[i]);
                for j in [i+1..Length(degs)] do
                    if degs[j] mod degs[i] = 0 then
                        Unbind(degs[j]);
                    fi;
                od;
            fi;
        fi;
    od;
    return ppds;
end);
                