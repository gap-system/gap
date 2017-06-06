gap> START_TEST("ListOp.tst");
gap> ll := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, ll);
<plist vector over Rationals of length 6>
gap> List( v1 );
[ 1, 2, 3, 4, 5, 6 ]
gap> List( v1, x->x^2 );
[ 1, 4, 9, 16, 25, 36 ]
gap> v5 := Vector(GF(5), ll*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> List( v5, x->x^2 );
[ Z(5)^0, Z(5)^2, Z(5)^2, Z(5)^0, 0*Z(5), Z(5)^0 ]
gap> STOP_TEST( "ListOp.tst", 1);
