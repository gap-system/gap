gap> START_TEST("RandomUnimodularMat.tst");

#
gap> for n in [1..10] do
>   Print("Testing n = ", n, "\n");
>   for i in [1..10] do
>     M := RandomUnimodularMat( n );
>     Assert(0, Length(M) = n);
>     Assert(0, ForAll(M, row -> Length(row) = n));
>     Assert(0, ForAll(M, row -> ForAll(row, x -> IsInt(x))));
>     Assert(0, Determinant(M) in [1,-1]);
>   od;
> od;
Testing n = 1
Testing n = 2
Testing n = 3
Testing n = 4
Testing n = 5
Testing n = 6
Testing n = 7
Testing n = 8
Testing n = 9
Testing n = 10

#
gap> RandomUnimodularMat(0);
Error, <m> must be a positive integer

#
gap> STOP_TEST("RandomUnimodularMat.tst", 1);
