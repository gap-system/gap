# 2008/09/11 (AH)
gap> x:=Indeterminate(CF(7));;
gap> K:=AlgebraicExtension(CF(7),x^2-3);;
gap> a:=GeneratorsOfField(K)[1];;
gap> x2 := E(7)+a*(E(7)^2+E(7)^3);
(E(7)^2+E(7)^3)*a+E(7)
