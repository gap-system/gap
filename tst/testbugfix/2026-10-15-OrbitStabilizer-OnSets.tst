gap> START_TEST( "2026-10-15-OrbitStabilizer-OnSets.tst" );

# OrbitStabilizer used to return a list of "BoundedTuples" data as orbit
# instead of the actual orbit, causing RepresentativeAction with OnSets
# to fail.
gap> G := Group( [ (1,2,3) ] );;
gap> orb := Set( OrbitStabilizer( G, [ 1, 2 ], OnSets ).orbit );
[ [ 1, 2 ], [ 1, 3 ], [ 2, 3 ] ]
gap> orb = Set( Orbit( G, [ 1, 2 ], OnSets ) );
true
gap> Set( orb, x -> RepresentativeAction( G, [ 1, 2 ], x, OnSets ) );
[ (), (1,2,3), (1,3,2) ]

#
gap> STOP_TEST( "2026-10-15-OrbitStabilizer-OnSets.tst" );
