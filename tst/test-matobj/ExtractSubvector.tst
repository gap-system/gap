gap> START_TEST("ExtractSubVector.tst");
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v3 := Vector(GF(5), l1*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> ExtractSubVector( v3, [1,2,4] );
[ Z(5)^0, Z(5), Z(5)^2 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, l1);
<plist vector over Rationals of length 6>
gap> ExtractSubVector( v1, [1,2,4] );
<plist vector over Rationals of length 3>
gap> Unpack( last );
[ 1, 2, 4 ]
gap> END_TEST("ExtractSubVector.tst",1);
