# Invoking Z(p,d) with p not a prime used to crash gap, which we fixed.
# However, invocations like `Z(4,5)` still would erroneously trigger the
# creation of a type object for fields of size p^d (in the example: 1024),
# with the non-prime value p set as characteristic. This could then corrupt
# subsequent computations.
gap> Z(4,5);
Error, Z: <p> must be a prime
gap> FieldByGenerators(GF(2), [ Z(1024) ]);
GF(2^10)
gap> Characteristic(Z(1024));
2
gap> Characteristic(FamilyObj(Z(1024)));
2
