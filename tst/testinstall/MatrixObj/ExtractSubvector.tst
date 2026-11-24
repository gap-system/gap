gap> START_TEST("ExtractSubVector.tst");
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> ExtractSubVector( l1, [1,2,4] );
[ 1, 2, 4 ]
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
gap> for F in [ GF(2), GF(7), GF(257), Integers mod 6 ] do
>      v1 := Vector( IsPackedVectorRep, F, l1 * One( F ) );
>      Print( Unpack( ExtractSubVector( v1, [1,2,4] ) ) = [ 1, 2, 4 ] * One( F ), " ",
>             Unpack( v1{ [ 6, 4 .. 2 ] } ) = [ 6, 4, 2 ] * One( F ), "\n" );
>    od;
true true
true true
true true
true true
gap> STOP_TEST("ExtractSubVector.tst");
