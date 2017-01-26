# 2012/08/14 (AK)
gap> R:=PolynomialRing(GF(5),"mu");;
gap> mu:=Indeterminate(GF(5));;
gap> T:=AlgebraicExtension(GF(5),mu^5-mu+1);;
gap> A:=PolynomialRing(T,"x");
<field of size 3125>[x]
