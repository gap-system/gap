gap> START_TEST("Unpack.tst");
gap> ll := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, ll);
<plist vector over Rationals of length 6>
gap> Unpack( v1 );
[ 1, 2, 3, 4, 5, 6 ]
gap> v5 := Vector(GF(5), ll*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> Unpack( v5 );
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> STOP_TEST( "Unpack.tst", 1);
