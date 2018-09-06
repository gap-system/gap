gap> START_TEST( "TraceMat.tst" );
gap> l := [[1,2],[3,4]];
[ [ 1, 2 ], [ 3, 4 ] ]
gap> m1 := Matrix(l);
<2x2-matrix over Rationals>
gap> m2 := Matrix(Integers,l);
<2x2-matrix over Integers>
gap> m3 := Matrix(GF(7),l*One(GF(7)));
[ [ Z(7)^0, Z(7)^2 ], [ Z(7), Z(7)^4 ] ]
gap> TraceMat( m1 );
5
gap> TraceMat( m2 );
5
gap> TraceMat( m3 );
Z(7)^5
gap> STOP_TEST( "TraceMat.tst", 1);
