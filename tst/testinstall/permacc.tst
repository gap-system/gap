gap> START_TEST("permacc.tst");
gap> testPA := function(cat, seed, length, deg, check)
>     local  pa, x, rs, g, i, op, pi, n;
>     pa := AccumulatorCons(cat, ());
>     x := ();
>     rs := RandomSource(IsMersenneTwister, seed);
>     g := SymmetricGroup(deg);
>     for i in [1..length] do
>         op := Random(rs,[1..6]);
>         if op = 1 then
>             pi := Random(rs,g);
>             x := x*pi;
>             RightMultiply(pa,pi);
>         elif op = 2 then
>             pi := Random(rs,g);
>             x := pi*x;
>             LeftMultiply(pa,pi);
>         elif op = 3 then
>             pi := Random(rs,g);
>             x := x/pi;
>             RightDivide(pa,pi);
>         elif op = 4 then
>             pi := Random(rs,g);
>             x := LeftQuotient(pi,x);
>             LeftDivide(pa,pi);
>         elif op = 5 then
>             x := x^-1;
>             Invert(pa);
>         elif op = 6 then
>             pi := Random(rs,g);
>             x := x^pi;
>             Conjugate(pa,pi);
>         fi;
>         if check and x <> ValueAccumulator(pa) then
>             Error();
>             return false;
>         fi;
>     od;
>     return x = ValueAccumulator(pa);
> end;
function( cat, seed, length, deg, check ) ... end
gap> testPA(IsEagerPermutationAccumulatorRep, 1, 100, 100, true);
true
gap> testPA(IsEagerPermutationAccumulatorRep, 2, 100, 100000, true);
true
gap> testPA(IsLazyPermutationAccumulatorRep, 1, 100, 100, true);
true
gap> testPA(IsLazyPermutationAccumulatorRep, 2, 100, 100, false);
true
gap> STOP_TEST("permacc.tst", 1430000);
