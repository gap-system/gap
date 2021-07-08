# 2007/03/20 (SL)
gap> x := Z(2,28)^((2^28-1)/16383);;
gap> b := Basis(GF(2^14));;
gap> Coefficients(b,x);
[ 0z, z0, 0z, 0z, 0z, 0z, 0z, 0z, 0z, 0z, 0z, 0z, 0z, 0z ]
