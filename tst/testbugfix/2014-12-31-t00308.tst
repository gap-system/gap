# 2014/12/31 (AH, reported by Daniel Błażewicz)
gap> x := Indeterminate( Rationals, "x" );;
gap> ProbabilityShapes(x^5+5*x^2+3);
[ 2 ]
gap> GaloisType(x^12+63*x-450); # this was causing an infinite loop
301
