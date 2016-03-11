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

#
gap> STOP_TEST( "fpmon.tst", 10000);
