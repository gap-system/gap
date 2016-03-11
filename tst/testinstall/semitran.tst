#############################################################################
##
#W  semitran.tst
#Y  James D. Mitchell
##
#############################################################################
##

gap> START_TEST("semitran.tst");

# Test that the inverse of an isomorphism from a partial perm monoid to a
# transformation monoid is really the inverse.
gap> S := InverseMonoid(PartialPerm([1, 2], [2, 1]),
>                       PartialPerm([1, 2], [3, 1]));
<inverse partial perm monoid of rank 3 with 2 generators>
gap> map := IsomorphismTransformationMonoid(S);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(S, x -> (x ^ map) ^ inv = x);
true
gap> ForAll(Range(map), x -> (x ^ inv) ^ map = x);
true

# Test that the inverse of an isomorphism from a partial perm semigroup to a
# transformation semigroup is really the inverse.
gap> S := InverseSemigroup(PartialPerm([1, 2], [2, 1]),
>                          PartialPerm([1, 2], [3, 1]));
<inverse partial perm semigroup of rank 3 with 2 generators>
gap> map := IsomorphismTransformationSemigroup(S);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(S, x -> (x ^ map) ^ inv = x);
true
gap> ForAll(Range(map), x -> (x ^ inv) ^ map = x);
true

#
gap> STOP_TEST( "semitran.tst", 10000);
