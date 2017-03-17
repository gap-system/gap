gap> START_TEST("sylowhall.tst");
gap> G := GL(3,4);; PrimeDivisors(Size(G));
[ 2, 3, 5, 7 ]
gap> IdGroup(SylowSubgroup(G, 2));
[ 64, 242 ]
gap> IdGroup(SylowSubgroup(G, 3));
[ 81, 7 ]
gap> IdGroup(SylowSubgroup(G, 5));
[ 5, 1 ]
gap> IdGroup(SylowSubgroup(G, 7));
[ 7, 1 ]
gap> SylowSystem(G);
fail
gap> HallSystem(G);
fail
gap> fine := true;; for p in PrimeDivisors(Size(G)) do fine := fine and HasHallSubgroup(G, [p]); od; fine;
true
gap> G := GL(4,3);; PrimeDivisors(Size(G));
[ 2, 3, 5, 13 ]
gap> HallSubgroup(G, [2, 3, 5, 13]) = G;
true
gap> fine := true;; for p in PrimeDivisors(Size(G)) do fine := fine and HallSubgroup(G, [p]) = SylowSubgroup(G, p); od; fine;
true
gap> IsTrivial(HallSubgroup(G, [7, 11, 17]));
true
gap> D := DihedralGroup(24);;
gap> IdGroup(SylowSubgroup(D,2));
[ 8, 3 ]
gap> PCore(D, 2)=D;
false
gap> IdGroup(PCore(D, 2));
[ 4, 1 ]
gap> HasHallSubgroup(D,[2]) and HallSubgroup(D,[2]) = SylowSubgroup(D,2);
true
gap> SylowComplement(D,2)=HallSubgroup(D,[3]);
true
gap> SylowComplement(D,2)=SylowSubgroup(D,3);
true
gap> SylowComplement(D,5)=D;
true
gap> A := AlternatingGroup(4);;
gap> SylowComplement(A, 3)=Group((1,2)(3,4), (1,3)(2,4));
true
gap> G := SmallGroup(8,4);; SylowComplement(G,5)=G;
true
gap> IsTrivial(SylowComplement(G,2));
true
gap> G := SmallGroup(1080, 248);;
gap> List(SylowSystem(G), Size);
[ 8, 27, 5 ]
gap> fine := true;; for p in PrimeDivisors(Size(G)) do fine := fine and HasSylowSubgroup(G, p); od; fine;
true
gap> HasHallSubgroup(G,[2]) and HasHallSubgroup(G,[2]) and HasHallSubgroup(G,[5]);
true
gap> HasHallSubgroup(G, [2, 5]);
false
gap> IdGroup(HallSubgroup(G, [2,5]));
[ 40, 10 ]
gap> PCore(G,2) = SylowSubgroup(G,2);
true
gap> G := SmallGroup(1080, 248);; IsNilpotentGroup(G);
true
gap> PCore(G,2) = SylowSubgroup(G,2);
true
gap> G := SmallGroup(1080, 248);;
gap> List(HallSystem(G), Size);
[ 1, 8, 216, 1080, 40, 27, 135, 5 ]
gap> fine := true;; for pi in Combinations(PrimeDivisors(Size(G))) do fine := fine and HasHallSubgroup(G, pi); od; fine;
true
gap> HasSylowComplement(G, 2);
false
gap> SylowComplement(G, 2)=HallSubgroup(G, [3,5]);
true
gap> IdGroup(HallSubgroup(AlternatingGroup(5), [2,3]));
[ 12, 3 ]
gap> IdGroup(SylowSubgroup(Group((1,2),(1,2,3,4,5)), 2));
[ 8, 3 ]
gap> IdGroup(PCore(Group(()), 2));
[ 1, 1 ]
gap> PCore(Group((1,2),(1,2,3,4,5)), 2) = PCore(Group((1,2),(1,2,3,4,5)), 7);
true
gap> G := Group((1,3),(1,2,3,4), (5,6,7));;
gap> PCore(G, 2) = Group((1,3),(1,2,3,4));
true
gap> F := FreeGroup("x", "y");; x := F.1;; y := F.2;;
gap> G := F/[x*y*x^(-1)*y^(-1), x^30, (x*y)^70];;
gap> IdGroup(SylowSubgroup(G, 2));
[ 4, 2 ]
gap> IdGroup(HallSubgroup(G, [2,3]));
[ 12, 5 ]
gap> IsAbelian(G);
true
gap> IdGroup(SylowSubgroup(G, 5));
[ 25, 2 ]
gap> IdGroup(HallSubgroup(G, [5,7]));
[ 175, 2 ]
gap> STOP_TEST("sylowhall.tst", 1);
