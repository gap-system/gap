gap> START_TEST("ZeroVector.tst");
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, l1);
<plist vector over Rationals of length 6>
gap> v0 := ZeroVector( 15, v1 );
<plist vector over Rationals of length 15>
gap> Unpack( v0 );
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> v3 := Vector(GF(5), l1*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> v0 := ZeroVector( 12, v3 );
< mutable compressed vector length 12 over GF(5) >
gap> Unpack( v0 );
[ 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5) ]
gap> STOP_TEST("ZeroVector.tst",1);
