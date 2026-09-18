#@local A,D,F,G,fine,p,x,y,pi
gap> START_TEST("sylowhall.tst");
gap> G := GL(3,4);; PrimeDivisors(Size(G));
[ 2, 3, 5, 7 ]
#@if IsPackageMarkedForLoading( "smallgrp", "" )
gap> IdGroup(SylowSubgroup(G, 2));
[ 64, 242 ]
gap> IdGroup(SylowSubgroup(G, 3));
[ 81, 7 ]
#@fi
gap> StructureDescription(SylowSubgroup(G, 5));
"C5"
gap> StructureDescription(SylowSubgroup(G, 7));
"C7"
gap> SylowSystem(G);
fail
gap> HallSystem(G);
fail
#@if IsPackageMarkedForLoading( "smallgrp", "" )
gap> ForAll(PrimeDivisors(Size(G)), p -> HasHallSubgroup(G, [p]));
true
#@fi

#
gap> G := GL(4,3);; PrimeDivisors(Size(G));
[ 2, 3, 5, 13 ]
gap> HallSubgroup(G, [2, 3, 5, 13]) = G;
true
gap> fine := true;; for p in PrimeDivisors(Size(G)) do fine := fine and HallSubgroup(G, [p]) = SylowSubgroup(G, p); od; fine;
true
gap> IsTrivial(HallSubgroup(G, [7, 11, 17]));
true

#
gap> D := DihedralGroup(24);;
gap> StructureDescription(SylowSubgroup(D,2));
"D8"
gap> StructureDescription(PCore(D, 2));
"C4"
gap> HasHallSubgroup(D,[2]) and HallSubgroup(D,[2]) = SylowSubgroup(D,2);
true
gap> SylowComplement(D,2)=HallSubgroup(D,[3]);
true
gap> SylowComplement(D,2)=SylowSubgroup(D,3);
true
gap> SylowComplement(D,5)=D;
true

#
gap> A := AlternatingGroup(4);;
gap> SylowComplement(A, 3)=Group((1,2)(3,4), (1,3)(2,4));
true

#
gap> G := QuaternionGroup(8);; SylowComplement(G,5)=G;
true
gap> IsTrivial(SylowComplement(G,2));
true

#
gap> G := PcGroupCode(13145332246515941463, 1080);;  # SmallGroup(1080, 248)
gap> List(SylowSystem(G), Size);
[ 8, 27, 5 ]
gap> fine := true;; for p in PrimeDivisors(Size(G)) do fine := fine and HasSylowSubgroup(G, p); od; fine;
true
gap> HasHallSubgroup(G,[2]) and HasHallSubgroup(G,[2]) and HasHallSubgroup(G,[5]);
true
gap> HasHallSubgroup(G, [2, 5]);
false
gap> StructureDescription(HallSubgroup(G, [2,5]));
"C5 x D8"
gap> PCore(G,2) = SylowSubgroup(G,2);
true
gap> IsNilpotentGroup(G);
true
gap> PCore(G,2) = SylowSubgroup(G,2);
true
gap> List(HallSystem(G), Size);
[ 1, 8, 216, 1080, 40, 27, 135, 5 ]
gap> fine := true;; for pi in Combinations(PrimeDivisors(Size(G))) do fine := fine and HasHallSubgroup(G, pi); od; fine;
true
gap> HasSylowComplement(G, 2);
false
gap> SylowComplement(G, 2)=HallSubgroup(G, [3,5]);
true
gap> StructureDescription(HallSubgroup(AlternatingGroup(5), [2,3]));
"A4"
gap> StructureDescription(SylowSubgroup(Group((1,2),(1,2,3,4,5)), 2));
"D8"
gap> StructureDescription(PCore(Group(()), 2));
"1"
gap> PCore(Group((1,2),(1,2,3,4,5)), 2) = PCore(Group((1,2),(1,2,3,4,5)), 7);
true
gap> G := Group((1,3),(1,2,3,4), (5,6,7));;
gap> PCore(G, 2) = Group((1,3),(1,2,3,4));
true

#
gap> F := FreeGroup("x", "y");; x := F.1;; y := F.2;;
gap> G := F/[x*y*x^(-1)*y^(-1), x^30, (x*y)^70];;
gap> StructureDescription(SylowSubgroup(G, 2));
"C2 x C2"
gap> StructureDescription(HallSubgroup(G, [2,3]));
"C6 x C2"
gap> IsAbelian(G);
true
gap> StructureDescription(SylowSubgroup(G, 5));
"C5 x C5"
gap> StructureDescription(HallSubgroup(G, [5,7]));
"C35 x C5"

#
gap> STOP_TEST("sylowhall.tst");
