#@local fields,CheckDivision,F,x,f,g,fc,gc
gap> START_TEST("polyfinf_div.tst");

# GF(2) and 8-bit fields have compressed coefficient lists, the others plain
gap> fields := List([2, 4, 3, 7, 9, 121, 257, 512, 65537], GF);;

#
# division with remainder
#
gap> CheckDivision := function(F, m, n)
>   local x, f, g, qr, rs;
>   x := Indeterminate(F, 1);
>   f := RandomPol(F, m);
>   g := RandomPol(F, n);
>   qr := QuotientRemainder(f, g);
>   rs := GcdRepresentation(f, g);
>   return f = qr[1] * g + qr[2]
>     and DegreeOfLaurentPolynomial(qr[2]) < n
>     and f mod g = qr[2]
>     and EuclideanRemainder(f, g) = qr[2]
>     and Quotient(f - qr[2], g) = qr[1]
>     and (x^3 * f) mod g = (x^3 * qr[2]) mod g
>     and rs[1] * f + rs[2] * g = Gcd(f, g)
>     and PowerMod(f, 5, g) = f^5 mod g;
> end;;
gap> ForAll(fields, F -> ForAll([[0, 3], [5, 5], [6, 1], [40, 17], [90, 31]],
>                              d -> CheckDivision(F, d[1], d[2])));
true

# coefficients in different fields: GF(2) and GF(4), GF(4) and GF(8)
gap> F := GF(4);; x := Indeterminate(F, 1);;
gap> f := x^50 + x^3 + 1;; g := x^7 + Z(4) * x + 1;;
gap> f mod g;
Z(2^2)^2*x_1^6+Z(2^2)*x_1^5+x_1^4+Z(2^2)*x_1^3+x_1^2+x_1
gap> f = QuotientRemainder(f, g)[1] * g + f mod g;
true
gap> g mod (x + Z(4));
0*Z(2)
gap> F := GF(64);; x := Indeterminate(F, 1);;
gap> f := x^30 + Z(4) * x + 1;; g := x^4 + Z(8) * x + 1;;
gap> f = QuotientRemainder(f, g)[1] * g + f mod g;
true

# a compressed and a plain coefficient list, against the loop for two plain
gap> fc := [Z(2), Z(4), 0*Z(2), Z(2), Z(4)^2, Z(2)];; gc := [Z(2), Z(2), Z(2)];;
gap> ConvertToVectorRep(gc, 2);;
gap> QUOTREM_LAURPOLS_LISTS(ShallowCopy(fc), gc)
>    = QUOTREM_LAURPOLS_LISTS(ShallowCopy(fc), List(gc));
true
gap> IsPlistRep(List(gc));
true

#
gap> STOP_TEST("polyfinf_div.tst");
