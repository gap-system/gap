# See https://github.com/gap-system/gap/issues/6716
gap> START_TEST( "2026-10-13-MinimalGeneratingSet-cyclic.tst" );

# For finite groups with CanEasilyComputePcgs false, the highest
# ranked method would assume non-cyclicness and return generating
# sets of 2+ elements, even when the group was actually cyclic
gap> F := FreeGroup( "a", "b" );;
gap> R := [ F.1 ^ 2, F.2 ^ 3, Comm( F.1, F.2 ) ];;
gap> G := F/R;;
gap> IsFinite( G ); # force finiteness test
true
gap> Length( MinimalGeneratingSet( G ) );
1

#
gap> STOP_TEST( "2026-10-13-MinimalGeneratingSet-cyclic.tst" );
