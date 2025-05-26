#@local R
gap> START_TEST("ringpoly.tst");

# Integral ring
gap> R := PolynomialRing(Integers, 2);;
gap> HasIsIntegralRing(R) and IsIntegralRing(R);
true

#
gap> STOP_TEST("ringpoly.tst");