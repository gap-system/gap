#@local fields,IsIrreducibleFF,CheckFactors,CheckFactorsField,F,x,f,R
gap> START_TEST("polyfinf.tst");

# GF(2) and 8-bit fields have compressed coefficient lists, the others plain
gap> fields := List([2, 4, 3, 7, 9, 121, 257, 512, 65537], GF);;

#
# factorisation
#

# Rabin: g of degree d > 0 is irreducible iff x^(q^d) = x modulo g and
# gcd(x^(q^(d/r)) - x, g) = 1 for each prime r dividing d
gap> IsIrreducibleFF := function(F, g)
>   local x, q, d;
>   x := IndeterminateOfUnivariateRationalFunction(g);
>   q := Size(F);
>   d := DegreeOfLaurentPolynomial(g);
>   return d > 0 and PowerMod(x, q^d, g) = x mod g
>     and ForAll(PrimeDivisors(d), r -> IsOne(
>                  StandardAssociate(Gcd(PowerMod(x, q^(d/r), g) - x, g))));
> end;;

# also by distinct degrees, which the option onlydegs selects; this one
# first, as Factors stores its result in f
gap> CheckFactors := function(F, f)
>   local R, fd, fa;
>   R := PolynomialRing(F, 1);
>   fd := Factors(R, f : factoroptions := rec(onlydegs :=
>                                   [1 .. DegreeOfLaurentPolynomial(f)]));
>   fa := Factors(R, f);
>   return Product(fa) = f and ForAll(fa, g -> IsIrreducibleFF(F, g))
>     and fa = fd;
> end;;
gap> CheckFactorsField := function(F)
>   local x, q, f;
>   x := Indeterminate(F, 1);
>   q := Size(F);
>   return ForAll([1 .. 8], n -> CheckFactors(F, x^n + RandomPol(F, n - 1)))
>     and CheckFactors(F, x^40 + RandomPol(F, 39))
>     and CheckFactors(F, x^10 * Value(x^10 + RandomPol(F, 9), x + x^-1))
>     and CheckFactors(F,
>           (x^3 + RandomPol(F, 2))^Minimum(Characteristic(F), 3)
>           * (x^4 + RandomPol(F, 3)))
>     and (q > 9 or Length(Factors(PolynomialRing(F, 1), x^(q^2) - x))
>                   = q + (q^2 - q) / 2);
> end;;
gap> ForAll(fields, CheckFactorsField);
true

# with onlydegs, the factors up to its maximum degree, and their cofactor
gap> F := GF(3);; x := Indeterminate(F, 1);; R := PolynomialRing(F, [x]);;
gap> f := (x-1) * (x+1) * (x^2+1) * (x^2+x+2) * (x^3-x+1);;
gap> Factors(R, f : factoroptions := rec(onlydegs := [2]));
[ x_1+Z(3)^0, x_1-Z(3)^0, x_1^2+Z(3)^0, x_1^2+x_1-Z(3)^0, x_1^3-x_1+Z(3)^0 ]
gap> Factors(R, f : factoroptions := rec(onlydegs := [1]));
[ x_1+Z(3)^0, x_1-Z(3)^0, x_1^7+x_1^6-x_1^5+x_1^4-x_1^2-x_1-Z(3)^0 ]
gap> Set(FactorsCommonDegreePol(R, (x^2+1) * (x^2+x+2), 2));
[ x_1^2+Z(3)^0, x_1^2+x_1-Z(3)^0 ]

# factors over a field larger than that of the coefficients
gap> F := GF(4);; x := Indeterminate(F, 1);; R := PolynomialRing(F, [x]);;
gap> Factors(R, x^4 + x + 1);
[ x_1^2+x_1+Z(2^2), x_1^2+x_1+Z(2^2)^2 ]
gap> Factors(R, x^5 + x^2 + 1);
[ x_1^5+x_1^2+Z(2)^0 ]

#
gap> STOP_TEST("polyfinf.tst");
