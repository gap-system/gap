LoadPackage ("irredsol", "", false);
SetInfoLevel (InfoIrredsol, 4);

RecognitionPrimitiveSolvableGroup (SymmetricGroup (3), true);
RecognitionPrimitiveSolvableGroup (SymmetricGroup (4), true);


RandomIrreducibleSolvableMatrixGroup := function (n, q, d, k, e)

    local x, y, G, H1, H, gens, M, rep;
 
    G := IrreducibleSolvableMatrixGroup (n, q, d, k);
    
    H1 := Source (RepresentationIsomorphism (G));
    
    H := TrivialSubgroup (H1);
    gens := [];
    while Size (H) < Size (H1) do
       x := Random (H1);
       if not x in H then
          H := ClosureSubgroupNC (H, x);
          Add (gens, x);
       fi;
    od;
    
    y := RandomInvertibleMat (n, GF(q^e));
    
    M := GroupWithGenerators (List (gens, x -> ImageElm (RepresentationIsomorphism (G), x)^y));
    SetSize (M, Size (G));
    SetIsSolvableGroup (M, true);
    SetIdIrreducibleSolvableMatrixGroup (M, IdIrreducibleSolvableMatrixGroup (G));
    rep := GroupGeneralMappingByImages (H1, M, gens, GeneratorsOfGroup (M));
    SetIsGroupHomomorphism (rep, true);
    SetIsSingleValued (rep, true);
    SetIsBijective (rep, true);
    SetRepresentationIsomorphism (M, rep);
    return M;
end;


   
RecognizeRandomIrred := function (n, q, full)

   local k, d, e, G, info, repG, repH;
   
   d := Random (DivisorsInt (n));
   k := Random (IndicesIrreducibleSolvableMatrixGroups(n, q, d));
   repeat
      e := Random ([1..n-1]);
      e := Random ([1..e]);
   until d = 1 or Gcd (n, e) = 1; # make sure that G is irreducible
   
   G := RandomIrreducibleSolvableMatrixGroup (n, q, d, k, e);
   
   Info (InfoIrredsol, 1, "testing group identification for group of order ", Order (G), 
      " and id ", [n, q, d, k]);
   
   info := RecognitionIrreducibleSolvableMatrixGroup (G, full, full, full);
   if info.id <> [n, q, d, k] then
      Error ("wrong id");
    else
        Info (InfoIrredsol, 1, "correct group id");
   fi;
   if full then
        if IdIrreducibleSolvableMatrixGroup (info.group) <> [n, q, d, k] then
            Error ("wrong of group");
        else
            Info (InfoIrredsol, 1, "correct group");
        fi;
        repG := RepresentationIsomorphism (G);
        repH := RepresentationIsomorphism (info.group);
        if ForAny (GeneratorsOfGroup (Source (repG)), 
            g -> ImageElm (repG, g) ^info.mat <> ImageElm (repH, ImageElm (info.iso, g))) then
                Error ("wrong conjugating matrix");
        else
            Info (InfoIrredsol, 1, "correct conjugation action");
        fi;
   fi;
end;

   

inds := [ 1168, 1224, 1229, 1231, 1237, 1242, 1247, 1249, 1513, 1515, 1517, 1519,  1533 ];;
for i in inds do
    G := RandomIrreducibleSolvableMatrixGroup (8, 3, 2, i, 3);
    info := RecognitionIrreducibleSolvableMatrixGroup (G, true, true); 
    if G^info.mat <> info.group or info.id <> IdIrreducibleSolvableMatrixGroup (G) then
       Error ("wrong result for group of id ", IdIrreducibleSolvableMatrixGroup (G));
    fi;
 od;
G1:=Group([ [ [ Z(7), 0*Z(7) ], [ 0*Z(7), Z(7) ] ], [ [ Z(7)^0, Z(7)^0 ],
 [ Z(7)^5, Z(7)^3 ] ], [ [ Z(7)^4, 0*Z(7) ], [ Z(7)^4, Z(7)^2 ] ]]);;
IdIrreducibleSolvableMatrixGroup(G1);
# [ 2, 7, 1, 20 ]
G2:=Group([ [ [ Z(7), Z(7)^5 ], [ Z(7), Z(7)^0 ] ],[ [ Z(7), Z(7)^3 ], [
  Z(7), Z(7)^4 ] ] ]);;
IdIrreducibleSolvableMatrixGroup(G2);
#[ 2, 7, 1, 21 ]
