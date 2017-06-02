gap> START_TEST("Randomize.tst");
gap> Reset( GlobalMerseeneTwister, 0 );
Error, Variable: 'GlobalMerseeneTwister' must have a value
not in any function at *stdin*:2
gap> ll := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, ll);
<plist vector over Rationals of length 6>
gap> Randomize( v1 );
gap> Unpack( v1 );
[ -2/3, 2, 1, -4, 0, 1 ]
gap> Randomize( v1 );
gap> Unpack( v1 );
[ -1, -1, 1/2, 0, -2, 1/2 ]
gap> v2 := Vector(GF(5), ll*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> Randomize( v2 );
[ 0*Z(5), Z(5)^2, Z(5)^0, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> v2;
[ 0*Z(5), Z(5)^2, Z(5)^0, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> Randomize( v2 );
[ Z(5), Z(5)^0, 0*Z(5), Z(5)^3, Z(5)^3, Z(5)^3 ]
gap> v2;
[ Z(5), Z(5)^0, 0*Z(5), Z(5)^3, Z(5)^3, Z(5)^3 ]
gap> STOP_TEST( "Randomize.tst", 1);
