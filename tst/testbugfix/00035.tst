##  bug 4 for fix 6
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> z := Indeterminate( Rationals : old );
x_1
gap> lin := Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3 := First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> ser := MolienSeries( tbl, lin[1] + deg3, lin[2] );;
gap> MolienSeriesWithGivenDenominator( ser, [ 6,6,4,4 ] );
( 2*z^2+z^3+3*z^4+6*z^5+3*z^6+7*z^7+7*z^8+3*z^9+6*z^10+4*z^11+z^12+3*z^13+z^14\
+z^16 ) / ( (1-z^6)^2*(1-z^4)^2 )
