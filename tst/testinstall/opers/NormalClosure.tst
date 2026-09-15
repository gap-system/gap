#@local S4, A4, S5, F, G, H, N, U
gap> START_TEST("NormalClosure.tst");

#
# setup perm groups
#
gap> S4 := SymmetricGroup(4);;
gap> A4 := AlternatingGroup(4);;
gap> S5 := SymmetricGroup(5);;

# normal closure of a subgroup
gap> S4 = NormalClosure(S4, Group((1,2)));
true
gap> A4 = NormalClosure(S4, Group((1,2,3)));
true
gap> S5 = NormalClosure(S4, Group((4,5)));
true

# normal closure of a bunch of generators
gap> S4 = NormalClosure(S4, [ (1,2) ]);
true
gap> A4 = NormalClosure(S4, [ (1,2,3) ]);
true
gap> S5 = NormalClosure(S4, [ (4,5) ]);
true
gap> IsTrivial(NormalClosure(S4, [ ])); # corner case
true

#
# setup fp groups
#
gap> F := FreeGroup(2);;

# normal closure of a subgroup
gap> H := Subgroup(F, [F.1^2, F.2^2, Comm(F.1, F.2)]);;
gap> N := NormalClosure(F, H);;
gap> Index(F, N);
4

#
gap> N := NormalClosure(F, [F.1^2, F.2^2, Comm(F.1, F.2)]);;
gap> Index(F, N);
4
gap> IsTrivial(NormalClosure(F, [ ])); # corner case
true

#
# pc groups
#
gap> G := DihedralGroup(IsPcGroup, 16);;
gap> U := NormalClosure(G, [ G.1 ]);;
gap> [ Size(U), HasIsNormalInParent(U) and IsNormalInParent(U) ];
[ 8, true ]

# the parent of this closure is G, in which it is not normal
gap> N := NormalClosure(U, [ G.1 ]);;
gap> HasIsNormalInParent(N);
false
gap> IsNormal(G, N);
false

#
gap> STOP_TEST("NormalClosure.tst");
