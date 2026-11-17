# See https://github.com/gap-system/gap/issues/6746
gap> START_TEST( "2026-10-15-OrbitStabilizer-domain.tst" );

# The hint returned by DomainForAction was taken for the whole domain:
# an orbit as long as the hint was returned as the hint itself
gap> Set( OrbitStabilizer( SymmetricGroup( 3 ), [ 1 ], OnSets ).orbit );
[ [ 1 ], [ 2 ], [ 3 ] ]
gap> G := GL( 2, 2 );;
gap> Size( Set( OrbitStabilizer( G, One( G ), OnRight ).orbit ) );
6

# TransitiveGroup( 30, 5419 )
gap> G := Group(
>  ( 1,17, 4,20, 5,19, 3,16, 2,18)( 6,14,10,12, 8,13, 7,15, 9,11)(21,27)
>  (22,28,24,30)(23,26,25,29),
>  ( 1,27, 5,26)( 2,28, 3,30)( 4,29)( 6,21,10,24)( 7,25, 9,23)( 8,22)
>  (11,17)(12,20)(13,16,14,18,15,19) );;
gap> idx := List( ConjugacyClassesMaximalSubgroups( G ),
>                c -> Index( G, Representative( c ) ) );;
gap> Collected( idx ) = [ [ 2, 1 ], [ 3, 1 ], [ 15625, 1 ], [ 46656, 1 ],
>                         [ 216000, 6 ], [ 1000000, 1 ], [ 12960000, 1 ] ];
true

#
gap> STOP_TEST( "2026-10-15-OrbitStabilizer-domain.tst" );
