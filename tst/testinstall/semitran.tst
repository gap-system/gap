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

# Test IsFullTransformationSemigroup in trivial cases
gap> IsFullTransformationSemigroup(Semigroup(Transformation([1])));
true
gap> IsFullTransformationSemigroup(Semigroup(Transformation([1, 1])));
false

# Test IsomorphismTransformationMonoid for a perm group
gap> G := Group((2,3)(5,6)(8,9)(11,12)(14,15)(17,18)(20,21)(23,24)
> (26,27)(29,30));;
gap> map := IsomorphismTransformationMonoid(G);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(G, x -> (x ^ map) ^ inv = x);
true
gap> ForAll(Range(map), x -> (x ^ inv) ^ map = x);
true

#
gap> STOP_TEST( "semitran.tst", 10000);
