gap> START_TEST("MemoryUsage.tst");

#
# test internal objects
#
gap> MemoryUsage(42) / GAPInfo.BytesPerVariable;
1
gap> (MemoryUsage(2/3) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
3
gap> str := "abcd";;
gap> (MemoryUsage(str) - Length(str) - 1 - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
2
gap> MemoryUsage(Z(2)) / GAPInfo.BytesPerVariable;
1
gap> MemoryUsage(Z(3)) / GAPInfo.BytesPerVariable;
1
gap> g := (1,2,3);;
gap> MemoryUsage(g) - MU_MemBagHeader - MU_MemPointer;
6

#
# test records
#
gap> (MemoryUsage(rec()) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
3
gap> (MemoryUsage(rec(a:=0)) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
5

#
# test plain lists
#
gap> (MemoryUsage([]) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
2
gap> (MemoryUsage([1]) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
3
gap> (MemoryUsage([1,2]) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
4
gap> (MemoryUsage([1,2,3]) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
5
gap> (MemoryUsage([1,,3]) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
5

#
# test self referential records and lists
gap> MemoryUsage([~]) = MemoryUsage([1]);
true
gap> MemoryUsage([0,~]) = MemoryUsage([0,1]);
true
gap> MemoryUsage([~,0,~]) = MemoryUsage([0,1,2]);
true
gap> MemoryUsage(rec(a:=~)) =MemoryUsage(rec(a:=0));
true

#
# test ranges
#
gap> (MemoryUsage([1..100]) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
4

#
# test component objects
#
gap> G := Group(g);;
gap> MemoryUsage(G) = SHALLOW_SIZE(G) + MU_MemBagHeader + MU_MemPointer
> + Sum(NamesOfComponents(G), n -> MemoryUsage(G!.(n)));
true

#
# test families and types
#
gap> MemoryUsage(FamilyObj(42));
0
gap> MemoryUsage(TypeObj(42));
0

#
# test positional objects
#
gap> (MemoryUsage(ZmodnZObj(5,8)) - MU_MemBagHeader) / GAPInfo.BytesPerVariable;
3

#
gap> F := FreeGroup(3);;
gap> w := One(F);;
gap> w:=Product(GeneratorsOfGroup(F))^3;
(f1*f2*f3)^3
gap> MemoryUsage(w![1]) = SHALLOW_SIZE(w![1]) + MU_MemBagHeader + MU_MemPointer;
true
gap> MemoryUsage(w) = SHALLOW_SIZE(w) + MU_MemBagHeader + MU_MemPointer + MemoryUsage(w![1]);
true
gap> o := ExtRepOfObj(w);
[ 1, 1, 2, 1, 3, 1, 1, 1, 2, 1, 3, 1, 1, 1, 2, 1, 3, 1 ]
gap> MemoryUsage(o) = SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer;
true

#
# test functions
#
gap> f:=x->x;; MemoryUsage(f) - SHALLOW_SIZE(f) in [160, 132];
true
gap> f:=x->x+1;; MemoryUsage(f) - SHALLOW_SIZE(f) in [184, 156];
true
gap> MemoryUsage(f) = MemoryUsage(f);
true

#
# bugfix test from 2007/12/14 (MN)
#
gap> a := [1..100];;
gap> MemoryUsage(a) = MemoryUsage(a);
true

#
gap> STOP_TEST("MemoryUsage.tst", 1);
