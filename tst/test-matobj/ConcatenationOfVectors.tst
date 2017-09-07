gap> START_TEST("ConcatenationOfVectors.tst");
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> l2 := [6,2,7,4,5,6];
[ 6, 2, 7, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, l1);
<plist vector over Rationals of length 6>
gap> v2 := Vector(IsPlistVectorRep, Rationals, l2);
<plist vector over Rationals of length 6>
gap> vv := ConcatenationOfVectors( v1, v2, v2 );
<plist vector over Rationals of length 18>
gap> Unpack( vv );
[ 1, 2, 3, 4, 5, 6, 6, 2, 7, 4, 5, 6, 6, 2, 7, 4, 5, 6 ]
gap> v3 := Vector(GF(5), l1*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> v4 := Vector(GF(5), l2*One(GF(5)));
[ Z(5)^0, Z(5), Z(5), Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> vv := ConcatenationOfVectors( [ v3, v4, v3 ] );
< mutable compressed vector length 18 over GF(5) >
gap> Unpack( vv );
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0, Z(5)^0, Z(5), Z(5), Z(5)^2, 
  0*Z(5), Z(5)^0, Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> STOP_TEST("ConcatenationOfVectors.tst",1);
