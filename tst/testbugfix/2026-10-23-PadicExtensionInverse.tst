# Inverting a non-invertible element of a p-adic extension family whose
# polynomial is reducible modulo p
gap> fam := PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]);;
gap> x := PadicNumber(fam, [0, [0, 1]]) - One(fam);;
gap> Inverse(x);
Error, <x> is not invertible; the polynomials defining its family violate the \
conditions of PadicExtensionNumberFamily
gap> fam := PadicExtensionNumberFamily(5, 5, [1,1,1], [1,1]);;
gap> x := PadicNumber(fam, [0, [0, 1]]) - One(fam);;
gap> x * Inverse(x) = One(fam);
true
