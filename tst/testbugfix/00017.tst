##  bug 11 for fix 4.
gap> x:= Indeterminate( Rationals );;
gap> f:= x^4 + 3*x^2 + 1;;
gap> F:= AlgebraicExtension( Rationals, f );;
gap> Basis( F )[1];;
