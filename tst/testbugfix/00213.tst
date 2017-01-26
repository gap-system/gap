# 2008/11/16 (TB)
gap> t:= [ [ 1, 2, 3, 4, 5 ], [ 2, 1, 4, 5, 3 ], [ 3, 5, 1, 2, 4 ],
>          [ 4, 3, 5, 1, 2 ], [ 5, 4, 2, 3, 1 ] ];;
gap> m:= MagmaByMultiplicationTable( t );;
gap> IsAssociative( m );
false
gap> AsGroup( m );
fail
