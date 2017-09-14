gap> START_TEST("RandomInvertibleMat.tst");

#
gap> check:=function(M, n, R)
>   local inv;
>   Assert(0, Length(M) = n, "bad row count");
>   Assert(0, ForAll(M, row -> Length(row) = n), "bad row length");
>   Assert(0, ForAll(M, row -> ForAll(row, x -> x in R)), "bad entry");
>   inv := M^-1;
>   Assert(0, M*inv = IdentityMat(n, R), "bad inverse");
> end;;

# default ring = Integers
gap> for n in [1..10] do
>   for i in [1..4] do
>     check(RandomInvertibleMat(n), n, Integers);
>   od;
> od;
gap> for n in [1..10] do
>   for i in [1..4] do
>     check(RandomInvertibleMat(GlobalMersenneTwister, n), n, Integers);
>   od;
> od;

#
gap> R := GF(2);;
gap> for n in [1..10] do
>   for i in [1..4] do
>     check(RandomInvertibleMat(n, R), n, R);
>   od;
> od;
gap> for n in [1..10] do
>   for i in [1..4] do
>     check(RandomInvertibleMat(GlobalMersenneTwister, n, R), n, R);
>   od;
> od;

#
gap> R := GF(9);;
gap> for n in [1..10] do
>   for i in [1..4] do
>     check(RandomInvertibleMat(n, R), n, R);
>   od;
> od;
gap> for n in [1..10] do
>   for i in [1..4] do
>     check(RandomInvertibleMat(GlobalMersenneTwister, n, R), n, R);
>   od;
> od;

#
gap> RandomInvertibleMat(1,1,1);
Error, usage: RandomInvertibleMat( [rs ,] <m> [, <R>] )

#
gap> STOP_TEST("RandomInvertibleMat.tst", 1);
