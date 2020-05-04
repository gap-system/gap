#@local S4, A4, S5, F, H, N
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
gap> STOP_TEST("NormalClosure.tst", 1);
