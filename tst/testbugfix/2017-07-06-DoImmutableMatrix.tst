# handling of finite fields of size q <= 256 but not GF(q)
gap> f1 := AlgebraicExtension(GF(3), CyclotomicPolynomial(GF(3), 5));
<algebra-with-one of dimension 4 over GF(3)>
gap> a := RootOfDefiningPolynomial(f1);
a
gap> mat := [[a]];
[ [ a ] ]
gap> DoImmutableMatrix(f1, mat, false);
[ [ a ] ]
