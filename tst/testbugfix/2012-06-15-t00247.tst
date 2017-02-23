# 2012/06/15 (AH)
gap> rng := PolynomialRing(Rationals,2);
Rationals[x_1,x_2]
gap> ind := IndeterminatesOfPolynomialRing(rng);
[ x_1, x_2 ]
gap> x := ind[1];
x_1
gap> y := ind[2];
x_2
gap> pol:=5*(x+1)^2;
5*x_1^2+10*x_1+5
gap> factors := Factors(pol);
[ 5*x_1+5, x_1+1 ]
gap> factors[2] := y;
x_2
gap> factors[1] := [];
[  ]
gap> Factors( pol );
[ 5*x_1+5, x_1+1 ]
