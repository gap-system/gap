# Factors over large finite fields must not compute discrete logarithms
# to take p-th roots of coefficients
gap> F := GF(2^61);;
gap> y := Indeterminate(F, "y");;
gap> a := Z(2^61)^(2^59+12345);;
gap> h := (y+a)^2*(y+One(F));;
gap> fs := Factors(h);;
gap> Product(fs) = h;
true
gap> List(fs, DegreeOfLaurentPolynomial);
[ 1, 1, 1 ]
gap> R := PolynomialRing(GF(3^5), ["z"]);;
gap> z := R.1;;
gap> g := z^2+Z(3^5)^7*z+Z(3^5)^100;;
gap> RootsRepresentativeFFPol(R, g^3, 3) = g;
true
