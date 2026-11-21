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

# Test that the delegation between methods for 'IrreducibleModules' works.
gap> IrreducibleModules( GroupByGenerators( [], () ), GF(2) );;
gap> G1:= TrivialGroup();;
gap> res1:= IrreducibleModules( G1, GF(2), 1 );;
gap> res1[1] = Pcgs( G1 );
true
gap> Length( res1[2] ) = 1;
true
gap> Length( IrreducibleModules( AlternatingGroup(5), GF(3), 1 )[2] ) = 1;
true
gap> Length( IrreducibleModules( Group( (1,2), (1,2) ), GF(3), 1 )[2] ) = 2;
true
gap> Length( IrreducibleModules( Group( (1,2), (1,2) ), GF(4), 1 )[2] ) = 1;
true
gap> Length( IrreducibleModules( Group( (1,2,3,4,5) ), GF(4), 1 )[2] ) = 1;
true
gap> Length( IrreducibleModules( CyclicGroup( IsFpGroup, 2 ), GF(3), 1 )[2] ) = 2;
true
gap> Length( IrreducibleModules( CyclicGroup( IsFpGroup, 2 ), GF(4), 1 )[2] ) = 1;
true
gap> Length( IrreducibleModules( SymmetricGroup(5), GF(3), 1 )[2] ) = 2;
true

# Modules computed from the factor group by the p-core
gap> G1:= SymmetricGroup( 4 );;
gap> G2:= Image( IsomorphismPcGroup( G1 ) );;
gap> res1:= IrreducibleModules( G1, GF(2), 0 );;
gap> res2:= IrreducibleModules( G2, GF(4), 0 );;
gap> List( [ res1, res2 ], r -> List( r[2], m -> m.dimension ) );
[ [ 1, 2 ], [ 1, 2 ] ]
gap> ForAll( [ [ G1, res1 ], [ G2, res2 ] ], p -> ForAll( p[2][2], m ->
>      GroupHomomorphismByImages( p[1], Group( m.generators ),
>                                 p[2][1], m.generators ) <> fail ) );
true

#
gap> STOP_TEST( "grpreps.tst" );
