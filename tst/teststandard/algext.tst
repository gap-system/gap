#############################################################################
##
#W  algext.tst                   GAP library		     Frank Lübeck
##
##  Test of algebraic extensions.
##
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

# Unbind variables so we can GC memory
gap> Unbind(f0); Unbind(p1); Unbind(f1); Unbind(p2); Unbind(f2);
gap> Unbind(p3); Unbind(f3); Unbind(p4); Unbind(f4);
gap> Unbind(x); Unbind(l); Unbind(a); Unbind(ll); Unbind(b);
gap> STOP_TEST("algext.tst",1);
