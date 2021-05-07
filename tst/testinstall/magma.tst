#@local M,T
gap> START_TEST( "magma.tst" );

#
gap> M:= MagmaByMultiplicationTable( [ [ 1, 1 ], [ 1, 1 ] ] );;
gap> IsGeneratorsOfMagmaWithInverses( Elements( M ) );
false

# IsAssociative and IsCommutative
gap> T := [
>   [ 2, 4, 3, 4, 5 ],
>   [ 3, 3, 2, 3, 3 ],
>   [ 5, 5, 5, 4, 4 ],
>   [ 5, 1, 4, 1, 1 ],
>   [ 5, 3, 3, 4, 5 ]
> ];;
gap> M := MagmaByMultiplicationTable(T);
<magma with 5 generators>
gap> IsAssociative(M) or IsCommutative(M);
false
gap> Filtered(Combinations(Elements(M)), x -> Size(x) > 0 and IsAssociative(x));
[ [ m5 ] ]
gap> Filtered(Combinations(Elements(M)), x -> Size(x) > 0 and IsCommutative(x));
[ [ m1 ], [ m1, m5 ], [ m2 ], [ m2, m5 ], [ m3 ], [ m3, m4 ], [ m4 ], [ m5 ] ]
gap> T := [
>   [ 1, 4, 3, 3, 2 ],
>   [ 4, 2, 4, 4, 2 ],
>   [ 3, 4, 3, 4, 1 ],
>   [ 1, 4, 5, 4, 3 ],
>   [ 2, 2, 3, 5, 3 ]
> ];;
gap> M := MagmaByMultiplicationTable(T);
<magma with 5 generators>
gap> IsAssociative(M) or IsCommutative(M);
false
gap> Filtered(Combinations(Elements(M)), x -> Size(x) > 0 and IsAssociative(x));
[ [ m1 ], [ m1, m3 ], [ m2 ], [ m2, m4 ], [ m3 ], [ m4 ] ]
gap> Filtered(Combinations(Elements(M)), x -> Size(x) > 0 and IsCommutative(x));
[ [ m1 ], [ m1, m2 ], [ m1, m2, m3 ], [ m1, m2, m5 ], [ m1, m3 ], [ m1, m5 ], 
  [ m2 ], [ m2, m3 ], [ m2, m4 ], [ m2, m5 ], [ m3 ], [ m4 ], [ m5 ] ]

#
gap> F := Elements( GL(2,2) );;
gap> IsAssociative( F );
true
gap> IsCommutative( F );
false
gap> Number( Combinations( F, 3 ), IsCommutative );
1

#
gap> STOP_TEST( "magma.tst" );
