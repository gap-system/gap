gap> START_TEST("RandomMat.tst");

#
gap> check:=function(M, m, n, R)
>   Assert(0, Length(M) = m, "bad row count");
>   Assert(0, ForAll(M, row -> Length(row) = n), "bad row length");
>   Assert(0, ForAll(M, row -> ForAll(row, x -> x in R)), "bad entry");
> end;;

#
gap> for n in [1..10] do
>   for m in [1..10] do
>     check(RandomMat(m, n), m, n, Integers);
>   od;
> od;
gap> for n in [1..10] do
>   for m in [1..10] do
>     check(RandomMat(GlobalMersenneTwister, m, n), m, n, Integers);
>   od;
> od;

#
gap> R := GF(2);;
gap> for n in [1..10] do
>   for m in [1..10] do
>     check(RandomMat(m, n, R), m, n, R);
>   od;
> od;
gap> for n in [1..10] do
>   for m in [1..10] do
>     check(RandomMat(GlobalMersenneTwister, m, n, R), m, n, R);
>   od;
> od;

#
gap> RandomMat(0);
Error, usage: RandomMat( [rs ,] <m>, <n> [, <F>] )

#
gap> STOP_TEST("RandomMat.tst", 1);
