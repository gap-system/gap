
##
## List iterated Schur covers of coclass r and rank d.
##
SchurCoversByCoclass := function(ccpsfile, p,r,d)
    local file, res, i, j, G, l, new, H, c, q;

    if not d in [2..r+1] then return fail; fi;

    # get file
    file := Concatenation(ccpsfile,
                             "_",String(p),
                             "_",String(r),
                             "_",String(d),
                             ".gi");

    # init file
    PrintTo(file,"CCover[",p,"][",r,"][",d,"] := [\n");

    # set up
    res := [];

    # 1. step : smaller coclass
    Print("extend smaller coclass \n");
    for i in [1..r-1] do
        for j in [1..NrCcCovers(p,i,d)] do

            # get group
            G := CcCover(p,i,d,j);
            l := Length(Factors(G!.mord));

            # check relevance
            if G!.mord > 1 and r = i+l-1 then
                Print("start group ",j," of ",NrCcCovers(p,i,d),"\n");
                new := SchurCovers(G);
                for H in new do 
                    c := CoverCode(H);
                    AppendTo(file, c,", \n"); 
                    if c[2] = p then Add(res, c); fi;
                od;
            fi;
        od;
    od;

    # 2. step : abelian groups of rank d and coclass r
    Print("abelian groups \n");
    for q in Partitions(r+1) do
        if Length(q) = d then 
            G := AbelianPcpGroup(Length(q), List(q, x -> p^x));
            c := CoverCode(G);
            AppendTo(file, c,", \n");
            if c[2] = p then Add(res, c); fi;
        fi;
    od;

    # 3. step : iterated extensions
    j := 1;
    Print("extend same coclass \n");
    while j <= Length(res) do
        Print("start group ",j," of ",Length(res),"\n");
        G := CodeCover(res[j]);
        new := SchurCovers(G);
        for H in new do 
            c := CoverCode(H);
            AppendTo(file, c,", \n"); 
            if c[2] = p then Add(res, c); fi;
        od;
        j := j+1;
    od;

    AppendTo(file,"];\n");
    AddSet(availc[p],[r,d]);
    ReadCcFile(p,r,d);
end;


