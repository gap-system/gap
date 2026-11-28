#@local fields,CheckPowerModCoeffs
gap> START_TEST("powermodcoeffs.tst");

# GF(2) and 8-bit fields have compressed coefficient lists, the others plain
gap> fields := List([2, 4, 3, 7, 9, 121, 257, 512, 65537], GF);;

#
# powers of coefficient lists, including the exponent 0
#
gap> CheckPowerModCoeffs := function(F)
>   local l, m, p, e, r, c;
>   l := List([1 .. 30], i -> Random(F));
>   m := List([1 .. 12], i -> Random(F));
>   m[12] := One(F);
>   ConvertToVectorRep(l);
>   ConvertToVectorRep(m);
>   p := [One(F)];
>   for e in [0 .. 6] do
>     r := ShallowCopy(PowerModCoeffs(l, e, m));
>     ShrinkRowVector(r);
>     c := ShallowCopy(p);
>     ReduceCoeffs(c, m);
>     ShrinkRowVector(c);
>     if r <> c then
>       return false;
>     fi;
>     p := ProductCoeffs(p, l);
>   od;
>   return PowerModCoeffs(l, 0, m{[12]}) = [];
> end;;
gap> ForAll(fields, CheckPowerModCoeffs);
true
gap> PowerModCoeffs([1, 2], 0, [1, 1]);
[ 1 ]
gap> PowerModCoeffs([1, 2], -1, [1, 1]);
Error, power <exp> must be nonnegative

#
gap> STOP_TEST("powermodcoeffs.tst");
