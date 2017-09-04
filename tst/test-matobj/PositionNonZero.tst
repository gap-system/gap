gap> START_TEST( "PositionNonZero.tst" );
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, l1);
<plist vector over Rationals of length 6>
gap> PositionNonZero( v1 );
1
gap> l2 := [0,2,3,0,5,6];
[ 0, 2, 3, 0, 5, 6 ]
gap> v2 := Vector(IsPlistVectorRep, Rationals, l2);
<plist vector over Rationals of length 6>
gap> PositionNonZero( v2 );
2
gap> l3 := [0,0,0,0,0,0];
[ 0, 0, 0, 0, 0, 0 ]
gap> v3 := Vector(IsPlistVectorRep, Rationals, l3);
<plist vector over Rationals of length 6>
gap> PositionNonZero( v3 );
7
gap> v4 := Vector(GF(5), l1*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> PositionNonZero( v4 );
1
gap> v5 := Vector(GF(5), l2*One(GF(5)));
[ 0*Z(5), Z(5), Z(5)^3, 0*Z(5), 0*Z(5), Z(5)^0 ]
gap> PositionNonZero( v5 );
2
gap> v6 := Vector(GF(5), l3*One(GF(5)));
[ 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5) ]
gap> PositionNonZero( v6 );
7
gap> STOP_TEST( "PositionNonZero.tst", 1);
