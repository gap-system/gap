gap> START_TEST ("$Id: test.tst,v 1.5 2007/10/04 16:41:23 gap Exp $");
gap> LoadPackage ("irredsol");
true
gap> UnloadAbsolutelyIrreducibleSolvableGroupData ();
gap> d := 2;;
gap> limit := 2^16-1;;
gap> for d in [2.. limit] do
>    p := SmallestRootInt (d);
>    if IsPrimeInt (p) then
>       m := LogInt (d, p);
>       for e in DivisorsInt (m) do
>          if IsAvailableAbsolutelyIrreducibleSolvableGroupData (m/e, p^e) then
>             LoadAbsolutelyIrreducibleSolvableGroupData (m/e, p^e);
>             if e > 1 then
>                divs := Difference (DivisorsInt (e), [e]);
>                for j in [1..Length(divs)] do
>                   t := divs[j];
>                   inds := IndicesIrreducibleSolvableMatrixGroups (m/t, p^t, e/t);
>                   if m = e then
>                      data := IRREDSOL_DATA.GROUPS_DIM1[p^e];
>                      data := data{[1..Length(data)]}[2];
>                   else
>                      data := IRREDSOL_DATA.GROUPS[m/e][p^e];
>                      data := data{[1..Length(data)]}[3];
>                   fi;
>                   wrong := [];
>                   for i in [1..Length (data)] do
>                      if IsBound (data[i][j]) <> (i in inds) then
>                         Add (wrong, i);
>                      fi;
>                   od;
>                   if Length (wrong) > 0 then
>                      Error ("wrong subfield info for indices ", wrong, " d = ", t);
>                   fi;
>                od;
>             fi;         
>             UnloadAbsolutelyIrreducibleSolvableGroupData (m/e, p^e);
>             LoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex (m/e, p^e);
>             if e < m then
>                for k in Set (IRREDSOL_DATA.FP_INDEX[m/e][p^e][2]) do
>                   LoadAbsolutelyIrreducibleSolvableGroupFingerprintData (m/e, p^e, k);
>                od;
>             fi;
>             UnloadAbsolutelyIrreducibleSolvableGroupFingerprints (m/e, p^e);
>          else
>             Error ("Absolutely irreducible group data for GL(", m/e, ", ", p^e,") not available");
>          fi;
>       od;
>    fi;
> od;

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3));;
gap> SortedList (List (all, Size));
[ 4, 8, 8, 8, 16, 24, 48 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsAbsolutelyIrreducibleMatrixGroup, true);;
gap> SortedList (List (all, Size)) ;
[ 8, 8, 16, 24, 48 ]

gap> List (all, IsAbsolutelyIrreducible);
[ true, true, true, true, true ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsAbsolutelyIrreducibleMatrixGroup, false);;
gap> SortedList (List (all, Size)) ;
[ 4, 8 ]
gap> List (all, IsAbsolutelyIrreducible);
[ false, false ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup, true);;
gap> List (all, Size);
[ 48 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup, false);;
gap> SortedList (List (all, Size)) ;
[ 4, 8, 8, 8, 16, 24 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsAbsolutelyIrreducibleMatrixGroup, true, IsPrimitive, true);;
gap> SortedList (List (all, Size)) ;
[ 8, 16, 24, 48 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsAbsolutelyIrreducibleMatrixGroup, true, IsPrimitive, false);;
gap> SortedList (List (all, Size)) ;
[ 8 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsPrimitive, true);;
gap> SortedList (List (all, Size)) ;
[ 8, 8, 16, 24, 48 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), IsPrimitive, false);;
gap> SortedList (List (all, Size)) ;
[ 4, 8 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), MinimalBlockDimension, [1]);;
gap> SortedList (List (all, Size)) ;
[ 4, 8 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), MinimalBlockDimension, [2]);;
gap> SortedList (List (all, Size)) ;
[ 8, 8, 16, 24, 48 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 2, Field, GF(3), MinimalBlockDimension, [2], IsAbsolutelyIrreducibleMatrixGroup, true);;
gap> SortedList (List (all, Size)) ;
[ 8, 16, 24, 48 ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 4, Field , GF(3), IsPrimitiveMatrixGroup, true);;
gap> Collected (List (all, Size)) ;
[ [ 5, 1 ], [ 10, 2 ], [ 20, 4 ], [ 40, 5 ], [ 80, 5 ], [ 96, 4 ], 
  [ 160, 4 ], [ 192, 6 ], [ 288, 1 ], [ 320, 2 ], [ 384, 1 ], [ 576, 3 ], 
  [ 640, 1 ], [ 1152, 3 ], [ 2304, 1 ] ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 4, Field , GF(3), IsPrimitiveMatrixGroup, false);;
gap> Collected (List (all, Size)) ;
[ [ 16, 5 ], [ 32, 12 ], [ 48, 2 ], [ 64, 12 ], [ 96, 5 ], [ 128, 10 ], 
  [ 192, 4 ], [ 256, 6 ], [ 384, 3 ], [ 512, 1 ], [ 768, 1 ], [ 1152, 1 ], 
  [ 2304, 2 ], [ 4608, 1 ] ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 4, Field , GF(3), MinimalBlockDimension, 2);;
gap> Collected (List (all, Size)) ;
[ [ 16, 2 ], [ 32, 7 ], [ 48, 2 ], [ 64, 8 ], [ 96, 4 ], [ 128, 9 ], 
  [ 192, 1 ], [ 256, 6 ], [ 384, 2 ], [ 512, 1 ], [ 768, 1 ], [ 1152, 1 ], 
  [ 2304, 2 ], [ 4608, 1 ] ]

gap> all := AllIrreducibleSolvableMatrixGroups (Degree, 4, Field , GF(3), MinimalBlockDimension, 1);;
gap> Collected (List (all, Size)) ;
[ [ 16, 3 ], [ 32, 5 ], [ 64, 4 ], [ 96, 1 ], [ 128, 1 ], [ 192, 3 ], 
  [ 384, 1 ] ]


gap> RandomIrreducibleSolvableMatrixGroup := function (n, q, d, k, e)
> 
>    local x, y, G, H1, H, gens, M, rep;
> 
>    G := IrreducibleSolvableMatrixGroup (n, q, d, k);
>    
>    H1 := Source (RepresentationIsomorphism (G));
>    
>    H := TrivialSubgroup (H1);
>    gens := [];
>    while Size (H) < Size (H1) do
>       x := Random (H1);
>       if not x in H then
>          H := ClosureSubgroupNC (H, x);
>          Add (gens, x);
>       fi;
>    od;
>    
>    y := RandomInvertibleMat (n, GF(q^e));
>    
>    M := GroupWithGenerators (List (gens, x -> ImageElm (RepresentationIsomorphism (G), x)^y));
>    SetSize (M, Size (G));
>    SetIsSolvableGroup (M, true);
>    SetIdIrreducibleSolvableMatrixGroup (M, IdIrreducibleSolvableMatrixGroup (G));
>    rep := GroupGeneralMappingByImages (H1, M, gens, GeneratorsOfGroup (M));
>    SetIsGroupHomomorphism (rep, true);
>    SetIsSingleValued (rep, true);
>    SetIsBijective (rep, true);
>    SetRepresentationIsomorphism (M, rep);
>    return M;
> end;
function( n, q, d, k, e ) ... end
gap> inds := [ 1168, 1224, 1229, 1231, 1237, 1242, 1247, 1249, 1513, 1515, 1517, 1519,  1533 ];;
gap> for i in inds do
>    G := RandomIrreducibleSolvableMatrixGroup (8, 3, 2, i, 1);
>    info := RecognitionIrreducibleSolvableMatrixGroup (G, true, true); 
>    if G^info.mat <> info.group or info.id <> IdIrreducibleSolvableMatrixGroup (G) then
>       Error ("wrong result for group of id ", IdIrreducibleSolvableMatrixGroup (G));
>    fi;
> od;
gap> G1:=Group([ [ [ Z(7), 0*Z(7) ], [ 0*Z(7), Z(7) ] ], [ [ Z(7)^0, Z(7)^0 ],
> [ Z(7)^5, Z(7)^3 ] ], [ [ Z(7)^4, 0*Z(7) ], [ Z(7)^4, Z(7)^2 ] ]]);;
gap> IdIrreducibleSolvableMatrixGroup(G1);
[ 2, 7, 1, 20 ]
gap> G2:=Group([ [ [ Z(7), Z(7)^5 ], [ Z(7), Z(7)^0 ] ],[ [ Z(7), Z(7)^3 ], [
>  Z(7), Z(7)^4 ] ] ]);;
gap> IdIrreducibleSolvableMatrixGroup(G2);
[ 2, 7, 1, 21 ]
gap> STOP_TEST ("test.tst", 0);
