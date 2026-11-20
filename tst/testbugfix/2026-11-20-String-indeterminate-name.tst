# String of a polynomial and of a polynomial ring reflects a name given to
# the indeterminate after String was first called
# See https://github.com/gap-system/gap/issues/6864
gap> fam := RationalFunctionsFamily(FamilyObj(1));;
gap> n := First([1..10000], i -> not HasIndeterminateName(fam, i));;
gap> x := Indeterminate(Rationals, n);;
gap> f := x^2 + 1;;
gap> R := PolynomialRing(Rationals, [n]);;
gap> String(x) = Concatenation("x_", String(n));
true
gap> String(f) = Concatenation("x_", String(n), "^2+1");
true
gap> String(R) = Concatenation("PolynomialRing( Rationals, [ x_", String(n), " ] )");
true
gap> IndeterminateNumberOfLaurentPolynomial(Indeterminate(Rationals, "k_6864")) = n;
true
gap> String(x);
"k_6864"
gap> String(f);
"k_6864^2+1"
gap> String(R);
"PolynomialRing( Rationals, [ k_6864 ] )"
