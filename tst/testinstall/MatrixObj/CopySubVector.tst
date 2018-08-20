gap> START_TEST("CopySubVector.tst");
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, l1);
<plist vector over Rationals of length 6>
gap> l2 := [1,1,1,2,2,2,3,3,3];
[ 1, 1, 1, 2, 2, 2, 3, 3, 3 ]
gap> v2 := Vector(IsPlistVectorRep, Rationals, l2);
<plist vector over Rationals of length 9>
gap> CopySubVector( v1, [2,4,6], v2, [1,2,4] );
gap> Unpack(v1);
[ 1, 1, 3, 1, 5, 2 ]
gap> v3 := Vector(GF(5), l1*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> v4 := Vector(GF(5), l2*One(GF(5)));
[ Z(5)^0, Z(5)^0, Z(5)^0, Z(5), Z(5), Z(5), Z(5)^3, Z(5)^3, Z(5)^3 ]
gap> CopySubVector( v4, [2,4,6], v3, [1,2,3] );
gap> v4;
[ Z(5)^0, Z(5)^0, Z(5)^0, Z(5), Z(5), Z(5)^3, Z(5)^3, Z(5)^3, Z(5)^3 ]
gap> STOP_TEST("CopySubVector.tst",1);
