# 2005/07/20 (TB)
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> A:= AlgebraByStructureConstants( Rationals, T, "A." );;
gap> GeneratorsOfAlgebra( A );
[ A.1, A.2 ]
