#@local fields,CheckResultant,x,y
gap> START_TEST("polyfinf_resultant.tst");

# GF(2) and 8-bit fields have compressed coefficient lists, the others plain
gap> fields := List([2, 4, 3, 7, 9, 121, 257, 512, 65537], GF);;

#
# resultants: the determinant of the Sylvester matrix
#
gap> CheckResultant := function(F, m, n)
>   local f, g, h, fc, gc, M, i;
>   f := RandomPol(F, m);
>   g := RandomPol(F, n);
>   fc := Reversed(CoefficientsOfUnivariatePolynomial(f));
>   gc := Reversed(CoefficientsOfUnivariatePolynomial(g));
>   M := NullMat(m + n, m + n, F);
>   for i in [1 .. n] do
>     M[i]{[i .. i + m]} := fc;
>   od;
>   for i in [1 .. m] do
>     M[n + i]{[i .. i + n]} := gc;
>   od;
>   h := RandomPol(F, 2);
>   return Resultant(f, g, 1) = Determinant(M)
>     and IsZero(Resultant(f * h, g * h, 1));
> end;;
gap> ForAll(fields, F -> ForAll([[0, 3], [4, 0], [1, 1], [5, 3],
>                                [3, 5], [20, 20], [40, 35]],
>                               d -> CheckResultant(F, d[1], d[2])));
true
gap> x := Indeterminate(GF(4), 1);; y := Indeterminate(GF(4), 2);;
gap> Resultant(x^3 + Z(4), x^2 + x + 1, 1);
Z(2^2)
gap> Resultant(x^2 + y, x + y^2, 1);
x_2^4+x_2

#
gap> STOP_TEST("polyfinf_resultant.tst");
