# arithmetic with rationals and minimal polynomials in towers of extensions
#@local x, F, K, L, a, b, c, e
gap> x := Indeterminate(Rationals, "x");;
gap> F := AlgebraicExtension(Rationals, x^2-2, "r2");;
gap> K := AlgebraicExtension(F, Indeterminate(F, "y")^2-3, "r3");;
gap> L := AlgebraicExtension(K, Indeterminate(K, "z")^2-5, "r5");;
gap> a := RootOfDefiningPolynomial(F);;
gap> b := RootOfDefiningPolynomial(K);;
gap> c := RootOfDefiningPolynomial(L);;
gap> e := a+b;;
gap> e^4 - 10*e^2 + 1 = Zero(K);
true
gap> 1 + b = b + 1;
true
gap> b - 1/2 = -(1/2 - b);
true
gap> (b + 1) * 2 = 2*b + 2;
true
gap> (e/2) * 2 = e;
true
gap> (c + 1)^2 = 2*c + 6;
true
gap> (a + c)^2 = 2*a*c + 7;
true
gap> a*c = c*a;
true
gap> MinimalPolynomial(Rationals, e) = x^4 - 10*x^2 + 1;
true
gap> MinimalPolynomial(Rationals, b) = x^2 - 3;
true
gap> MinimalPolynomial(Rationals, b^2) = x - 3;
true
gap> MinimalPolynomial(Rationals, a+b+c) = x^8 - 40*x^6 + 352*x^4 - 960*x^2 + 576;
true
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(F, b+c));
4
gap> Value(MinimalPolynomial(F, b+c), b+c) = Zero(L);
true
