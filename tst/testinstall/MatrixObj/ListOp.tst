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
gap> v:= [ Z(2) ];;  ConvertToVectorRep( v, 4 );;  Unbind( v[1] );  v;
< mutable compressed vector length 0 over GF(4) >
gap> List( v );
[  ]
gap> List( v, DegreeFFE );
[  ]
gap> ConvertToVectorRep( v, 2 );;  v;
<a GF2 vector of length 0>
gap> List( v );
[  ]
gap> List( v, DegreeFFE );
[  ]
gap> STOP_TEST( "ListOp.tst", 1);
