
##
## List iterated Schur covers of order p^n and rank d and print to file.
##
SchurCoversByOrder := function(grpsfile, p,n,d)
    local file, i, j, G, new, q, H;

    if not d in [2..n] then return fail; fi;

    # get file
    file := Concatenation(grpsfile,
                             "_",String(p),
                             "_",String(n),
                             "_",String(d),
                             ".gi");

    PrintTo(file,"SCover[",p,"][",n,"][",d,"] := [\n"); 

    # extend gps
    Print("compute covers \n");
    for i in [1..n-1] do
        for j in [1..NrItCovers(p,i,d)] do

            # get group
            G := ItCover(p,i,d,j);
    
            # check relevance and extend if necessary
            if Size(G)*G!.mord = p^n then 
    
                # info
                Print("start group ",j," of ",NrItCovers(p,i,d));
                Print(" with order p^",i," \n");
    
                # get covers
                new := SchurCovers(G);

                # print to file
                for H in new do AppendTo(file, CoverCode(H),", \n"); od;
            fi;
        od;
    od;

    # add abelians
    Print("add abelian groups \n");
    for q in Partitions(n) do
        if Length(q) = d then 
 
            # get group
            G := AbelianPcpGroup(d, List(q, x -> p^x));

            # print 
            AppendTo(file, CoverCode(G),", \n");
        fi;
    od;

    AppendTo(file,"];\n");
    AddSet(availb[p],[n,d]);
    ReadDBFile(p,n,d);
end;

