# 2007/03/20 (SL)
gap> x := Z(2,18)^((2^18-1)/511);;
gap> b := Basis(GF(512));;
gap> Coefficients(b,x);
[ 0z, z0, 0z, 0z, 0z, 0z, 0z, 0z, 0z ]
