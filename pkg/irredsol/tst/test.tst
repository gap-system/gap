gap> START_TEST("$Id: test.tst,v 1.8 2011/05/18 14:37:33 gap Exp $");
gap> LoadPackage ("irredsol", "", false);
true
gap> SetInfoLevel (InfoIrredsol, 0);
gap> UnloadAbsolutelyIrreducibleSolvableGroupData ();
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


gap> TestRandomIrreducibleSolvableMatrixGroup := function (n, q, d, k, e)
> 
>    local x, y, G, repG, H1, H, gens, M, rep, info;
> 
>    G := IrreducibleSolvableMatrixGroup (n, q, d, k);
>    repG := RepresentationIsomorphism (G);
>    
>    H1 := Source (repG);
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
>    M := GroupWithGenerators (List (gens, x -> ImageElm (repG, x)^y));
>    SetSize (M, Size (G));
>    SetIsSolvableGroup (M, true);
>    SetIdIrreducibleSolvableMatrixGroup (M, IdIrreducibleSolvableMatrixGroup (G));
>    rep := GroupGeneralMappingByImages (H1, M, gens, GeneratorsOfGroup (M));
>    SetIsGroupHomomorphism (rep, true);
>    SetIsSingleValued (rep, true);
>    SetIsBijective (rep, true);
>    SetRepresentationIsomorphism (M, rep);
>    info := RecognitionIrreducibleSolvableMatrixGroup (M, true, true, true); 
>    if ForAny (GeneratorsOfGroup (Source (rep)), 
>        g -> ImageElm (rep, g) ^info.mat <> ImageElm (RepresentationIsomorphism(info.group), ImageElm (info.iso, g))) then
>            Error ("wrong conjugating matrix");
>    fi;
> end;;
gap> inds := [ 1168, 1224, 1229, 1231, 1237, 1242, 1247, 1249, 1513, 1515, 1517, 1519,  1533 ];;
gap> for i in inds do
>    TestRandomIrreducibleSolvableMatrixGroup (8, 3, 2, i, 3);
> od;
gap> inds := [ 6081, 6082, 6083, 6084, 6085, 6086, 6087, 6088 ];;
gap> for i in inds do
>    TestRandomIrreducibleSolvableMatrixGroup (8, 3, 1, i, 3);
> od;
gap> inds := [ 1513, 1514, 1515 ];;
gap> for i in inds do
>    TestRandomIrreducibleSolvableMatrixGroup (6, 5, 1, i, 4);
> od;
gap> inds := [ 1..6 ];;
gap> for i in inds do
>    TestRandomIrreducibleSolvableMatrixGroup (4, 3, 4, i, 3);
> od;
gap> G1:=Group([ [ [ Z(7), 0*Z(7) ], [ 0*Z(7), Z(7) ] ], [ [ Z(7)^0, Z(7)^0 ], [ Z(7)^5, Z(7)^3 ] ], 
> [ [ Z(7)^4, 0*Z(7) ], [ Z(7)^4, Z(7)^2 ] ]]);;
gap> IdIrreducibleSolvableMatrixGroup(G1);
[ 2, 7, 1, 20 ]
gap> G2:=Group([ [ [ Z(7), Z(7)^5 ], [ Z(7), Z(7)^0 ] ],[ [ Z(7), Z(7)^3 ], [Z(7), Z(7)^4 ] ] ]);;
gap> IdIrreducibleSolvableMatrixGroup(G2);
[ 2, 7, 1, 21 ]
gap> STOP_TEST("test.tst", 0);
$Id: test.tst,v 1.8 2011/05/18 14:37:33 gap Exp $
GAP4stones: 0
