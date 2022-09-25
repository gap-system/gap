#@local G1, G2, F, res1, res2;
gap> START_TEST( "grpreps.tst" );

# Compare the two methods for 'AbsolutelyIrreducibleModules'.
gap> G1:= DihedralGroup( 10 );;
gap> G2:= DihedralGroup( IsPermGroup, 10 );;
gap> F:= GF(2);;
gap> # Make sure that different methods will be called.
gap> ApplicableMethod( AbsolutelyIrreducibleModules, [ G1, F, 10 ] )
> <> ApplicableMethod( AbsolutelyIrreducibleModules, [ G2, F, 10 ] );
true
gap> res1:= AbsolutelyIrreducibleModules( G1, F, 10 );;
gap> List( res1[2], r -> [ r.field, r.dimension ] );
[ [ GF(2), 1 ] ]
gap> res2:= AbsolutelyIrreducibleModules( G2, F, 10 );;
gap> List( res2[2], r -> [ r.field, r.dimension ] );
[ [ GF(2), 1 ] ]

#
gap> STOP_TEST( "grpreps.tst" );

