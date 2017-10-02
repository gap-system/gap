gap> START_TEST("RandomUnimodularMat.tst");

#
gap> check:=function(M, n)
>   local inv;
>   Assert(0, Length(M) = n, "bad row count");
>   Assert(0, ForAll(M, row -> Length(row) = n), "bad row length");
>   Assert(0, ForAll(M, row -> ForAll(row, IsInt)), "bad entry");
>   Assert(0, Determinant(M) in [1,-1], "bad determinant");
>   inv := M^-1;
>   Assert(0, ForAll(inv, row -> ForAll(row, IsInt)), "bad entry in inverse");
>   Assert(0, M*inv = IdentityMat(n), "bad inverse");
> end;;

# check with default random source
gap> for n in [1..10] do
>   for i in [1..10] do
>     check(RandomUnimodularMat(n), n);
>   od;
> od;

# check with custom random source
gap> for n in [1..10] do
>   for i in [1..10] do
>     check(RandomUnimodularMat(GlobalMersenneTwister, n), n);
>   od;
> od;

# check invalid arguments
gap> RandomUnimodularMat(-1);
Error, <m> must be a positive integer
gap> RandomUnimodularMat(0);
Error, <m> must be a positive integer
gap> RandomUnimodularMat(fail);
Error, <m> must be a positive integer
gap> RandomUnimodularMat(1,1);
Error, usage: RandomUnimodularMat( [rs ,] <m> )

#
gap> STOP_TEST("RandomUnimodularMat.tst", 1);
