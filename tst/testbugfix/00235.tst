# 2011/06/01 (TB)
gap> F2:= GF( 2 );;
gap> x:= Indeterminate( F2 );;
gap> F:= AlgebraicExtension( F2, x^2+x+1 );;
gap> Trace( RootOfDefiningPolynomial( F ) );
Z(2)^0
