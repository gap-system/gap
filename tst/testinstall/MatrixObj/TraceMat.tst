gap> START_TEST( "TraceMat.tst" );
gap> l := [[1,2],[3,4]];
[ [ 1, 2 ], [ 3, 4 ] ]
gap> m1 := Matrix(l);;
gap> m2 := Matrix(Integers,l);;
gap> m3 := Matrix(GF(7),l*One(GF(7)));;
gap> TraceMat( m1 );
5
gap> TraceMat( m2 );
5
gap> TraceMat( m3 );
Z(7)^5
gap> STOP_TEST( "TraceMat.tst", 1);
