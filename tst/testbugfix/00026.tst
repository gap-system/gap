##  bug 7 for fix 5
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> lin:= Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3:= First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> MolienSeries( tbl, lin[1] + deg3, lin[2] );
( 2*z^2+z^3-z^4+z^6 ) / ( (1-z^3)^2*(1-z^2)^2 )
