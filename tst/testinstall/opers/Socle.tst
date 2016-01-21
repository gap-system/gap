gap> START_TEST("socle.tst");
gap> Socle(DihedralGroup(8));
Group([ f3 ])
gap> D := Group((1,3),(1,2,3,4));
Group([ (1,3), (1,2,3,4) ])
gap> Socle(D);
Group([ (1,3)(2,4) ])
gap> Socle(DirectProduct(D, D, D));
Group([ (1,3)(2,4), (5,7)(6,8), (9,11)(10,12) ])
gap> Socle(QuaternionGroup(8));
Group([ y2 ])
gap> Socle(SymmetricGroup(4));
Group([ (1,4)(2,3), (1,2)(3,4) ])
gap> Socle(SymmetricGroup(5));
Alt( [ 1 .. 5 ] )
gap> Socle(PrimitiveGroup(8,3));
Group([ (1,7)(2,8)(3,5)(4,6), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ])
gap> k := 5;; P := SylowSubgroup(SymmetricGroup(4*k), 2);; A := Group((4*k+1, 4*k+2, 4*k+3));; G := ClosureGroup(P, A);
<permutation group with 19 generators>
gap> Socle(G);
Group([ (21,22,23), (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16), (17,18)
(19,20) ])
gap> A := DihedralGroup(16);;
gap> B := SmallGroup(27, 3);;
gap> C := SmallGroup(125, 4);;
gap> D := DirectProduct(A, B, C, SmallGroup(1536, 2));;
gap> GeneratorsOfGroup(Socle(D));
[ f4, f7, f10, f16, f17, f18, f19, f20 ]
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)
> (7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);
Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)
(7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ])
gap> Socle(G);
Group([ (3,7)(5,9), (5,11)(7,9), (1,5,3)(7,11,9), (2,8,10)(4,6,12), (4,6)
(10,12) ])
gap> STOP_TEST("socle", 10000);
