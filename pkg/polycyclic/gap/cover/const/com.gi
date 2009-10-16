if not IsBound(CODEONLY) then CODEONLY := false; fi;

NrToElm := function(rels, nr, n)
    local q, elm, i;
    elm := []; elm[n] := 0;
    for i in Reversed([1..n]) do
        q := QuotientRemainder(nr, rels[i]);
        nr := q[1];
        elm[i] := q[2];
    od;
    return elm;
end;

ElmToNr := function(rels, elm, n)
    local nr, i;
    nr := elm[1];
    for i in [2..n] do
        nr := nr*rels[i] + elm[i];
    od;
    return nr;
end;

ComplementCover := function(H, n, f, t, coc)
    local d, e;
    d := CutVector(coc, n);
    e := List([1..n], x -> f[x] * MappedVector( d[x], t));
    return Subgroup(H, e);
end;

ConstructPerm := function(n, r, s)
    local l, m, g, i;

    # catch a trivial case
    if r=s then return (); fi;

    # set up
    l := Length(s);
    m := Length(r)-Length(s);

    # get list
    g := [];
    for i in [1..n] do
        Append(g, (i-1)*m+[1..m]);
        Append(g, n*m + (i-1)*l + [1..l]);
    od;

    return PermList(g);
end;

GetExponents := function(pcp, x)
    return ExponentsByPcp(pcp, MappedVector(x,pcp));
end;

FactorsComplementClasses := function(A, H, f, t, m)
    local n, nn, r, s, rr, oper, elms, os, i, p, q;

    # set up
    n := Length(f);
    r := RelativeOrdersOfPcp(t);
    s := RelativeOrdersOfPcp(m);

    # construct perms
    p := ConstructPerm(n,r,s);
    q := p^-1;

    # long rels
    rr := Permuted(Flat(List([1..n], x -> r)),p);
    nn := Length(rr);

    # the action
    oper := function(nr, aut)
        local coc, cut, new;
        coc := Permuted(NrToElm(rr, nr, nn),q);
        cut := CutVector(coc, n);
        new := List([1..n],x->(aut[2][x]*cut)*aut[1]+aut[3][x]);
        new := List(new, x -> GetExponents(t,x));
        coc := Concatenation(new);
        return ElmToNr(rr, Permuted(coc,p), nn);
    end;

    # orbits
    os := MyOrbits(A, Product(s)^n, oper);

    # translate
    for i in [1..Length(os)] do
        os[i] := Permuted(NrToElm(rr, os[i], nn),q);
        os[i] := ComplementCover(H,n,f,t,os[i]);
        os[i] := H/os[i];
        if CODEONLY then 
            AddMOrder(os[i]);
            os[i] := [Size(os[i]), os[i]!.mord,
                      CodePcGroup(PcpGroupToPcGroup(RefinedPcpGroup(os[i])))];
        fi;
    od;

    return os;
end;

AllComplementsCover := function(K, f, m)
    local n, r, s, elms;

    # set up 
    n := Length(f);
    s := RelativeOrdersOfPcp(m);

    # the points
    elms := ExponentsByRels(s);
    elms := List( Tuples(elms,n), Flat );

    # translate
    return List(elms, x -> ComplementCover(K, n, f, m, x));
end;

