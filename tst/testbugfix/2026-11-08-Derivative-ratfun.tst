# Derivative of Laurent polynomials with negative exponents, and the
# factorization of the denominator stored by Derivative of a univariate
# rational function
gap> x := Indeterminate(Rationals, "x");;
gap> Derivative(x^-1);
-x^-2
gap> Derivative(x^-2+3);
-2*x^-3
gap> Derivative(x^-1+x);
1-x^-2
gap> y := Indeterminate(GF(5), "y");;
gap> Derivative(y^-1+y^-3);
-y^-2+Z(5)*y^-4
gap> d := Derivative(1/((x+1)*(x+2)));
(-2*x-3)/(x^4+6*x^3+13*x^2+12*x+4)
gap> Factors(DenominatorOfRationalFunction(d));
[ x+1, x+1, x+2, x+2 ]
gap> d := Derivative((x+5)/((x+1)^2*(x+2)^2));
(-3*x^2-23*x-28)/(x^6+9*x^5+33*x^4+63*x^3+66*x^2+36*x+8)
gap> Factors(DenominatorOfRationalFunction(d));
[ x+1, x+1, x+1, x+2, x+2, x+2 ]
gap> d := Derivative(1/(3*(x+1)^2));
(-2/3)/(x^3+3*x^2+3*x+1)
gap> Factors(DenominatorOfRationalFunction(d));
[ x+1, x+1, x+1 ]
