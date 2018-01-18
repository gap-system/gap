gap> START_TEST("pgroups.tst");
gap> A := Group((1,2),(3,4),(5,6));
Group([ (1,2), (3,4), (5,6) ])
gap> G := DirectProduct(A, A);
Group([ (1,2), (3,4), (5,6), (7,8), (9,10), (11,12) ])
gap> IsPGroup(G); 
true
gap> HasPrimePGroup(A) and HasPrimePGroup(G);
true
gap> PrimePGroup(A);
2
gap> PrimePGroup(G);
2
gap> B := Group((1,2,3),(4,5,6));
Group([ (1,2,3), (4,5,6) ])
gap> IsAbelian(B);
true
gap> G := DirectProduct(B, B);
Group([ (1,2,3), (4,5,6), (7,8,9), (10,11,12) ])
gap> IsPGroup(G); 
true
gap> HasPrimePGroup(G);
true
gap> PrimePGroup(G);
3
gap> C := Group((1,2,3,4),(5,6,7,8));
Group([ (1,2,3,4), (5,6,7,8) ])
gap> IsAbelian(C);
true
gap> G := DirectProduct(C, C);
Group([ (1,2,3,4), (5,6,7,8), (9,10,11,12), (13,14,15,16) ])
gap> Size(G);
256
gap> IsPGroup(G);
true
gap> HasPrimePGroup(G);
true
gap> PrimePGroup(G);
2
gap> D := Group((1,3),(1,2,3,4));
Group([ (1,3), (1,2,3,4) ])
gap> G := DirectProduct(D, D);
Group([ (1,3), (1,2,3,4), (5,7), (5,6,7,8) ])
gap> IsPGroup(G);
true
gap> HasPrimePGroup(D) and HasPrimePGroup(G);
true
gap> PrimePGroup(D);
2
gap> PrimePGroup(G);
2
gap> Q := Group( (1,2,3,8)(4,5,6,7), (1,7,3,5)(2,6,8,4) );
Group([ (1,2,3,8)(4,5,6,7), (1,7,3,5)(2,6,8,4) ])
gap> SetIsPGroup(Q,true); 
gap> PrimePGroup(Q);
2
gap> G := DihedralGroup(IsFpGroup, 8);
<fp group of size 8 on the generators [ r, s ]>
gap> IsPGroup(G);
true
gap> H := CyclicGroup(IsFpGroup, 2);
<fp group of size 2 on the generators [ a ]>
gap> hom := GroupHomomorphismByImages(G, H, [G.1, G.2], [H.1, One(H)]);
[ r, s ] -> [ a, <identity ...> ]
gap> K := Kernel(hom);
Group(<fp, no generators known>)
gap> SetIsPGroup(K, true);
gap> PrimePGroup(K);
2
gap> IsPGroup(TrivialGroup());
true
gap> PrimePGroup(TrivialGroup());
fail
gap> IsPGroup(AbelianGroup([2, 4, 8, 16]));
true
gap> IsPGroup(AbelianGroup([2, 4, 8, 18]));
false
gap> H1 := Group((1,2)(3,4),(1,2,3));
Group([ (1,2)(3,4), (1,2,3) ])
gap> IsPGroup(H1); 
false
gap> H2 := Group((1,2),(3,4,5));
Group([ (1,2), (3,4,5) ])
gap> IsPGroup(H2);
false
gap> H3 := Group((1,2),(3,4,5));
Group([ (1,2), (3,4,5) ])
gap> IsAbelian(H3);
true
gap> IsPGroup(H3);
false
gap> H4 := Group((1,2),(3,4,5));
Group([ (1,2), (3,4,5) ])
gap> IsAbelian(H4);
true
gap> Size(H4);
6
gap> IsPGroup(H4);
false
gap> K := Group((1,3),(1,2,3,4),(5,6,7));
Group([ (1,3), (1,2,3,4), (5,6,7) ])
gap> IsNilpotentGroup(K);
true
gap> HasIsPGroup(K);
true
gap> IsPGroup(K);
false
gap> L := Group((2,4), (1,2,3,4));
Group([ (2,4), (1,2,3,4) ])
gap> IsNilpotentGroup(L);
true
gap> HasIsPGroup(L) and HasPrimePGroup(L);
true
gap> IsPGroup(L);
true
gap> PrimePGroup(L);
2
gap> F := FreeGroup("r","s");
<free group on the generators [ r, s ]>
gap> r := F.1; s := F.2;
r
s
gap> G := F/[ r^4, s^2, s*r*s*r ];
<fp group on the generators [ r, s ]>
gap> IsNilpotentGroup(G);
true
gap> G := F/[ r^3, s^2, r*s*r*s ];
<fp group on the generators [ r, s ]>
gap> IsNilpotentGroup(G);
false
gap> ForAll(List([1..11], i -> TransitiveGroup(8,i)), IsPGroup);
true
gap> IsPGroup(TransitiveGroup(8, 12));
false
gap> IsNilpotentGroup(TransitiveGroup(8, 12));
false
gap> IsPGroup(AlternatingGroup(3));
true
gap> IsPGroup(AlternatingGroup(4));
false
gap> IsPGroup(SymmetricGroup(3));
false
gap> G := SymmetricGroup(8);
Sym( [ 1 .. 8 ] )
gap> s := Size(G);
40320
gap> IsPGroup(G);
false
gap> IsNilpotentGroup(G);
false
gap> ForAll(PrimeDivisors(s), p -> HasIsPGroup(SylowSubgroup(G, p)));
true
gap> ForAll(PrimeDivisors(s), p -> HasPrimePGroup(SylowSubgroup(G, p)));
true
gap> ForAll(PrimeDivisors(s), p -> p=PrimePGroup(SylowSubgroup(G, p)));
true
gap> G := DihedralGroup(Factorial(8));
<pc group of size 40320 with 11 generators>
gap> IsPGroup(G);
false
gap> IsNilpotentGroup(G);
false
gap> s := Size(G);
40320
gap> ForAll(PrimeDivisors(s), p -> HasIsPGroup(SylowSubgroup(G, p)));
true
gap> ForAll(PrimeDivisors(s), p -> HasPrimePGroup(SylowSubgroup(G, p)));
true
gap> ForAll(PrimeDivisors(s), p -> p=PrimePGroup(SylowSubgroup(G, p)));
true
gap> JenningsSeries(CyclicGroup(4));
[ <pc group of size 4 with 2 generators>, Group([ f2 ]), 
  Group([ <identity> of ... ]) ]
gap> G:=CyclicGroup(9);;
gap> HasIsPowerfulPGroup(G);
true
gap> IsPowerfulPGroup(G);
true
gap> G:=CyclicGroup(10);;
gap> IsPowerfulPGroup(G);
false
gap> G:=SmallGroup(243,11);;
gap> HasIsPowerfulPGroup(G);
false
gap> IsPowerfulPGroup(G);
true
gap> N:=NormalSubgroups(G)[3];;
gap> H:=FactorGroup(G,N);;
gap> HasIsPowerfulPGroup(H);
true
gap> IsPowerfulPGroup(H);
true
gap> myList:=AllSmallGroups(5^4);;
gap> Number(myList,g->IsPowerfulPGroup(g));
9
gap> newList:=AllSmallGroups(5^4);;
gap> for g in newList do
> RankPGroup(g);
> Agemo(g,5);
> od;
gap> Number(newList,g->IsPowerfulPGroup(g));
9
gap> myList:=AllSmallGroups(2^4);;
gap> Number(myList,g->IsPowerfulPGroup(g));
6
gap> STOP_TEST("pgroups.tst", 1);
