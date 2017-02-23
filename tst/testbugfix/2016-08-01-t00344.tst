#2016/8/1 (#869)
gap> x:=X(GF(4));;e:=AlgebraicExtension(GF(4),x^3+x+1);;
gap> Length(Elements(e));
64
gap> Length(Set(Elements(e)));
64
