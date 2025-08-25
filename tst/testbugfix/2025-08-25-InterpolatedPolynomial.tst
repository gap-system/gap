# InterpolatedPolynomial should always return a polynomial.
# Reported by István Szöllősi during GAP Days 2025.
#
gap> f:=InterpolatedPolynomial( Integers, [ 1, 2, 3 ], [ 5, 5, 5 ] );
5
gap> IsInt(f);
false
gap> IsPolynomial(f);
true

#
gap> f:=InterpolatedPolynomial( Integers, [ 1 ], [ 5 ] );
5
gap> IsInt(f);
false
gap> IsPolynomial(f);
true
