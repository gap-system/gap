#############################################################################
##
#W  fpmon.tst
#Y  James D. Mitchell
##
#############################################################################
##

gap> START_TEST("fpmon.tst");

# Test that the inverse of an isomorphism from an fp monoid to an fp semigroup
# is really the inverse.
gap> F := FreeMonoid(2);; 
gap> rels := [ [ F.1^2, F.1 ], [ F.2^2, F.2 ], [ F.1*F.2*F.1, F.1*F.2 ], 
> [ F.2*F.1*F.2, F.1*F.2 ] ];;
gap> S := F / rels;
<fp monoid on the generators [ m1, m2 ]>
gap> map := IsomorphismFpSemigroup(S);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(S, x -> (x ^ map) ^ inv = x);
true

# Test that free monoids cannot be used to make fp semigroups or vice versa
gap> F := FreeMonoid(2);;
gap> rels := [ [ F.1^2, F.1 ], [ F.2^2, F.2 ] ];;
gap> FactorFreeSemigroupByRelations(F, rels);
Error, first argument <F> should be a free semigroup
gap> F := FreeSemigroup(2);;
gap> rels := [ [ F.1^2, F.1 ], [ F.2^2, F.2 ] ];;
gap> FactorFreeMonoidByRelations(F, rels);
Error, first argument <F> should be a free monoid

# Test isomorphisms from fp monoids to fp semigroups and vice versa
gap> F := FreeMonoid(2);;
gap> M := F / [[F.2 ^ 2, F.2]];;
gap> iso := IsomorphismFpSemigroup(M);;
gap> S := Range(iso);;
gap> x := S.2 * S.3 * S.2;;
gap> y := x ^ InverseGeneralMapping(iso);
m1*m2*m1
gap> y := x ^ InverseGeneralMapping(iso);
m1*m2*m1
gap> y in M;
true
gap> x := M.1 * M.2 * M.1;;
gap> y := x ^ iso;
m1*m2*m1
gap> y := x ^ iso;
m1*m2*m1
gap> y in S;
true

#
gap> STOP_TEST( "fpmon.tst", 1);
