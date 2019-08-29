gap> START_TEST("Quotient.tst");

#
gap> Quotient(2, 1);
2
gap> Quotient(1, 2);
fail
gap> Quotient(1, 0);
fail
gap> Quotient(Integers, 2, 1);
2
gap> Quotient(Integers, 1, 2);
fail
gap> Quotient(Integers, 1, 0);
fail
gap> Quotient(GaussianIntegers, 2, 1);
2
gap> Quotient(GaussianIntegers, 1, 2);
fail
gap> Quotient(GaussianIntegers, 1, 0);
fail
gap> Quotient(Rationals, 2, 1);
2
gap> Quotient(Rationals, 1, 2);
1/2
gap> Quotient(Rationals, 1, 0);
fail
gap> Quotient(GaussianRationals, 2, 1);
2
gap> Quotient(GaussianRationals, 1, 2);
1/2
gap> Quotient(GaussianRationals, 1, 0);
fail

#
gap> R := GF(7);;
gap> Quotient(Z(7)^2, Z(7));
Z(7)
gap> Quotient(Z(7), Z(7)^2);
Z(7)^5
gap> Quotient(Z(7), 0*Z(7));
fail
gap> Quotient(R, Z(7)^2, Z(7));
Z(7)
gap> Quotient(R, Z(7), Z(7)^2);
Z(7)^5
gap> Quotient(R, Z(7), 0*Z(7));
fail

#
gap> R := Integers mod 6;;
gap> a := ZmodnZObj(2, 6);;
gap> b := ZmodnZObj(5, 6);;
gap> Quotient(a, b);
ZmodnZObj( 4, 6 )
gap> Quotient(b, a);
fail
gap> Quotient(b, 0*a);
fail
gap> Quotient(R, a, b);
ZmodnZObj( 4, 6 )
gap> Quotient(R, b, a);
fail
gap> Quotient(R, b, 0*a);
fail

#
gap> R:=PolynomialRing(Integers, 1);; t:=R.1;;
gap> Quotient(2*t, t);
2
gap> Quotient(t, 2*t);
1/2
gap> Quotient(t, 0*t);
fail
gap> Quotient(R, 2*t, t);
2
gap> Quotient(R, t, 2*t); # FIXME: result is NOT contained in R; bug in polynomial quotient code
1/2
gap> Quotient(R, t, 0*t);
fail

#
gap> R:=PolynomialRing(Rationals, 1);; t:=R.1;;
gap> Quotient(2*t, t);
2
gap> Quotient(t, 2*t);
1/2
gap> Quotient(t, 0*t);
fail
gap> Quotient(R, 2*t, t);
2
gap> Quotient(R, t, 2*t);
1/2
gap> Quotient(R, t, 0*t);
fail

#
gap> R:=PolynomialRing(GF(7), 1);; t:=R.1;;
gap> Quotient(2*t, t);
Z(7)^2
gap> Quotient(t, 2*t);
Z(7)^4
gap> Quotient(t, 0*t);
fail
gap> Quotient(R, 2*t, t);
Z(7)^2
gap> Quotient(R, t, 2*t);
Z(7)^4
gap> Quotient(R, t, 0*t);
fail

#
# the following case has some issues, as the polynomial
# division code 
gap> R:=PolynomialRing(Integers mod 6, 1);; t:=R.1;;
gap> Quotient(2*t, t);
ZmodnZObj(2,6)
gap> #Quotient(t, 2*t); # FIXME: should return fail, but doesn't; bug in polynomial quotient code
gap> Quotient(t, 0*t);
fail
gap> Quotient(R, 2*t, t);
ZmodnZObj(2,6)
gap> #Quotient(R, t, 2*t); # FIXME: should return fail, but doesn't; bug in polynomial quotient code
gap> Quotient(R, t, 0*t);
fail

#
gap> STOP_TEST("Quotient.tst", 1);
