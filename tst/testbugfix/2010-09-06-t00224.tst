# 2010/09/06 (TB)
gap> G:= SL( 2, 3 );;
gap> x:= [ [ Z(9), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ];;
gap> y:= [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(9) ] ];;
gap> IsConjugate( G, x, y );
true
