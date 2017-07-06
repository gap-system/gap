# this should be fast and avoid irreducibility tests
gap> t := Runtime();;
gap> f0 := GF(13);;
gap> p1 := CyclotomicPolynomial(f0, 5);;
gap> f1 := AlgebraicExtension(f0, p1);;
gap> p2 := Indeterminate(f1)^5 - RootOfDefiningPolynomial(f1);;
gap> f2 := AlgebraicExtension(f1, p2);;
gap> p3 := Indeterminate(f2)^5 - RootOfDefiningPolynomial(f2);;
gap> f3 := AlgebraicExtension(f2, p3);;
gap> p4 := Indeterminate(f3)^5 - RootOfDefiningPolynomial(f3);;
gap> f4 := AlgebraicExtension(f3, p4);;
gap> Runtime() - t < 1000;
true
