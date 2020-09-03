#############################################################################
##
##  Test of algebraic extensions.
##
#@local t, f0, p1, f1, p2, f2, p3, f3, p4, f4, x, l, a, ll, b, pol, K, xinv, c
gap> START_TEST("algext.tst");
gap> t := Runtime();;
gap> f0 := GF(3);;
gap> p1 := CyclotomicPolynomial(f0, 5);;
gap> f1 := AlgebraicExtensionNC(f0, p1);;
gap> p2 := Indeterminate(f1)^5 - RootOfDefiningPolynomial(f1);;
gap> f2 := AlgebraicExtensionNC(f1, p2);;
gap> p3 := Indeterminate(f2)^5 - RootOfDefiningPolynomial(f2);;
gap> f3 := AlgebraicExtensionNC(f2, p3);;
gap> p4 := Indeterminate(f3)^5 - RootOfDefiningPolynomial(f3);;
gap> f4 := AlgebraicExtensionNC(f3, p4);;
gap> Runtime() - t < 1000;
true
gap> x := Indeterminate(Rationals);;
gap> l := AlgebraicExtension(Rationals, x^4-x^2+1, "alpha");;
gap> a := RootOfDefiningPolynomial(l);;
gap> x := Indeterminate(l);;
gap> ll := AlgebraicExtension(l, x^5-2, "beta");;
gap> b := RootOfDefiningPolynomial(ll);;
gap> (a+b)^5-(a-b)^5;
20*alpha^2*beta^3+(10*alpha^2-10)*beta+!4

#
gap> pol := UnivariatePolynomial(GF(293), Z(293)^0 * ConwayPol(293,8));;
gap> K := AlgebraicExtension(GF(293), pol);;
gap> xinv := 1/PrimitiveElement(K);
Z(293)^145*a^7+Z(293)^274*a^3+Z(293)^120*a^2+Z(293)^134*a+Z(293)^179
gap> c := Random(K);;

#
gap> STOP_TEST("algext.tst",1);
