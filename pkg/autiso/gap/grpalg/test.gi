
RandomPcPres := function(G)
    return PcGroupCode( RandomSpecialPcgsCoded(G), Size(G) );
end;

TestCanoForm := function(G)
    local T, S, F, A, B, C, H, i;

    F := GF(PrimePGroup(G));
    A := GroupRing(F,G);
    T := TableNatBasis(A);
    B := CanoFormWithAutGroup(A);

    i := 1;
    while i <= 10 do
        H := RandomPcPres(G);
        A := GroupRing(F, H);
        S := TableNatBasis(A);
        if S=T then 
            Print("-- trivial -- \n"); 
        else
            C := CanoFormWithAutGroup(A);
            if B.size <> C.size then return false; fi;
            if B.cano <> C.cano then return false; fi;
        fi;
        i := i+1;
    od;

    return true;
end;

TestCanoForms := function(n)
    local i, G;
    for i in [1..NumberSmallGroups(n)] do
        G := SmallGroup(n,i);
        if not TestCanoForm(G) then Error("wrong form"); fi;
        Print(i," done \n\n");
    od;
end;

