#
gap> tab := [[4, 2, 1, 4], [2, 2, 2, 3], [2, 4, 3, 1], [4, 1, 1, 4]];;
gap> m := MagmaByMultiplicationTable(tab);;
gap> m = Submagma(m, Filtered(m, IsIdempotent));
true
gap> SetIsIdempotentGenerated(m, true);
gap> not (HasIsSemiband(m) and IsSemiband(m));
true
gap> IsAssociative(m);
false
gap> IsSemigroup(m);
false
