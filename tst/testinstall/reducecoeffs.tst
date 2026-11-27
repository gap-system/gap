#@local CheckReduceCoeffs
gap> START_TEST("reducecoeffs.tst");

#
# remainders of plain coefficient lists, short and long divisors
#
gap> CheckReduceCoeffs := function(R, m, n)
>   local a, b, c, k;
>   a := List([1 .. m], i -> Random(R));
>   b := List([1 .. n], i -> Random(R));
>   b[n] := One(R);
>   c := ShallowCopy(a);
>   k := ReduceCoeffs(c, b);
>   return k < n and ForAll([k + 1 .. m], i -> IsZero(c[i]))
>     and a = ProductCoeffs(QuotRemCoeffs(a, b)[1], b) + c;
> end;;
gap> ForAll([GF(257), GF(512), GF(65537), Rationals], R ->
>      ForAll([[1, 1], [10, 3], [40, 31], [40, 32], [100, 33], [200, 90]],
>             d -> CheckReduceCoeffs(R, d[1], d[2])));
true

#
gap> STOP_TEST("reducecoeffs.tst");
