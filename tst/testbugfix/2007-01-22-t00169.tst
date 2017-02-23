# 2007/01/22 (SL)
gap> F := GF(7,3);;
gap> F1 := GF(F,2);;
gap> a := PrimitiveRoot(F1);;
gap> B := Basis(F1);;
gap> Coefficients(B,a^0);
[ z0, 0z ]
