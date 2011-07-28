LoadPackage ("irredsol", "", false);
SetInfoLevel (InfoIrredsol, 4);
LoadPackage ("crisp", "", false);
ReadPackage ("crisp", "private/maximal.gi");

RecognitionPrimitiveSolvableGroup (SymmetricGroup (3), true);
RecognitionPrimitiveSolvableGroup (SymmetricGroup (4), true);

RandomPrimitiveSolvablePermGroup := function (n, p, d, k)

    local G, H, g;
    
    
    G := PrimitiveSolvablePermGroup (n, p, d, k);
    H := TrivialSubgroup (G);
    Info (InfoIrredsol, 2, "constructing random primitive perm group with id ", [n,p,d,k]);
    
    while Size (H) < Size (G) do
        g := Random (G);
        H := ClosureSubgroupNC (H, g);
    od;
    H := Group (GeneratorsOfGroup (H));
    return H;
end;

I

    
RandomPrimitiveSolvablePcGroup := function (n, p, d, k)

    local G, H, g, pcgs, N, max;
    
    
    G := PrimitivePcGroup (n, p, d, k);
    Info (InfoIrredsol, 2, "constructing random primitive pc group with id ", [n,p,d,k]);
    H := G;
    pcgs := [];
    while Size (H) > 1 do
        max := PcgsMaximalSubgroupClassReps (FamilyPcgs (G), InducedPcgsWrtFamilyPcgs (H), fail, true);
        N := GroupOfPcgs (Random(max));
        repeat
            g := Random (H);
        until not g in N;
        H := N;
        Add (pcgs, g);
    od;
    pcgs := PcgsByPcSequenceNC (FamilyObj (One(G)), pcgs);
    H := PcGroupWithPcgs (pcgs);
    if Size (H) <> Size (G) then
        Error ("new group has wrong size");
    fi;
    return H;
end;



RecognizeRandomPrimitivePcGroup := function (n, p, full)

    local k, d, e, G, info;
   
    d := Random (DivisorsInt (n));
    k := Random (IndicesIrreducibleSolvableMatrixGroups(n, p, d));
    G :=  RandomPrimitiveSolvablePcGroup (n, p, d, k);
    info := RecognitionPrimitiveSolvableGroup (G, full);
    if info.id <> [n, p, d, k] then
        Error ("wrong id");
    fi;
end;


