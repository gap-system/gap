gap> START_TEST("AutomorphismGroup.tst");

# abelian group
gap> Size(AutomorphismGroup(CyclicGroup(49)));
42
gap> G:=AbelianGroup([2,2,2,5,5,5,49]);
<pc group of size 49000 with 7 generators>
gap> Size(AutomorphismGroup(last));
10499328000
gap> Size(GL(3,2))*Size(GL(3,5))*42;
10499328000

# nilpotent group which is not a p-group
gap> gs:=[ExtraspecialGroup( 27, 3 ), DihedralGroup(32)];
[ <pc group of size 27 with 3 generators>,
  <pc group of size 32 with 5 generators> ]
gap> G:=DirectProduct(gs);
<pc group of size 864 with 8 generators>
gap> Size(AutomorphismGroup(G));
55296
gap> Size(AutomorphismGroup(G)) = Product(gs, g->Size(AutomorphismGroup(g)));
true

# solvable group
gap> G:=DihedralGroup(100);
<pc group of size 100 with 4 generators>
gap> IsFrattiniFree(G);
false
gap> AutomorphismGroup(G);
<group of size 1000 with 6 generators>

# solvable Frattini-free groups, handled by AutomorphismGroupFrattFreeGroup
gap> G:=SymmetricGroup(4);;
gap> IsFrattiniFree(G);
true
gap> Size(AutomorphismGroup(G));
24
gap> Size(AutomorphismGroup(SymmetricGroup(IsPcGroup,4)));
24
gap> G:=Group((1,2,3,4,5),(2,3,5,4));;  # Frobenius group of order 20
gap> Size(AutomorphismGroup(G));
20

#
gap> STOP_TEST("AutomorphismGroup.tst");
