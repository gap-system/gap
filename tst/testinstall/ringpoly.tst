#@local R
gap> START_TEST("ringpoly.tst");

# Commutativity and associativity
gap> R := PolynomialRing(Integers, 2);;
gap> HasIsIntegralRing(R) and IsIntegralRing(R);
true
gap> HasIsCommutative(R) and IsCommutative(R);
true
gap> HasIsAssociative(R) and IsAssociative(R);
true

# Integral ring
gap> R := PolynomialRing(Integers, 2);;
gap> HasIsIntegralRing(R) and IsIntegralRing(R);
true

#
gap> STOP_TEST("ringpoly.tst");
