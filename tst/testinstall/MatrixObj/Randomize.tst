gap> START_TEST("Randomize.tst");
gap> ll := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, ll);
<plist vector over Rationals of length 6>
gap> Randomize( v1 );
<plist vector over Rationals of length 6>
gap> Unpack( v1 );
[ -2/3, 2, 1, -4, 0, 1 ]
gap> Randomize( v1 );
<plist vector over Rationals of length 6>
gap> Unpack( v1 );
[ -1, -1, 1/2, 0, -2, 1/2 ]
gap> v2 := Vector(GF(5), ll*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> Randomize( v2 );
[ Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^2, Z(5)^3, 0*Z(5) ]
gap> v2;
[ Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^2, Z(5)^3, 0*Z(5) ]
gap> Randomize( v2 );
[ Z(5)^0, 0*Z(5), Z(5)^3, Z(5), Z(5), Z(5) ]
gap> v2;
[ Z(5)^0, 0*Z(5), Z(5)^3, Z(5), Z(5), Z(5) ]
gap> v3 := Vector(IsPackedVectorRep, GF(5), ll*One(GF(5)));
<packed vector over GF(5) of length 6>
gap> Randomize( v3 );
<packed vector over GF(5) of length 6>
gap> Unpack( v3 );
[ Z(5), Z(5)^2, Z(5)^2, Z(5)^0, Z(5), Z(5)^2 ]
gap> Randomize( RandomSource( IsMersenneTwister, 1 ), v3 );;
gap> Unpack( v3 );
[ Z(5)^3, 0*Z(5), Z(5), Z(5), Z(5)^0, 0*Z(5) ]
gap> m := ZeroMatrix( IsPackedMatrixRep, Integers mod 6, 2, 3 );;
gap> Randomize( m );
<2x3 packed matrix over (Integers mod 6)>
gap> Unpack( m );
[ [ ZmodnZObj( 2, 6 ), ZmodnZObj( 3, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 2, 6 ), ZmodnZObj( 3, 6 ), ZmodnZObj( 2, 6 ) ] ]
gap> STOP_TEST( "Randomize.tst" );
