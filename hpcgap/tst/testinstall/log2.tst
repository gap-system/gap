gap> START_TEST("log2.tst");
gap> List([-5..5], Log2Int);
[ 2, 2, 1, 1, 0, -1, 0, 1, 1, 2, 2 ]
gap> ForAll([2..100], x -> Log2Int(2^x) = x and
>                         Log2Int(2^x-1) = x-1 and
>                         Log2Int(2^x+1) = x);
true
gap> ForAll([2..100], x -> Log2Int(-(2^x)) = x and
>                         Log2Int(-(2^x)-1) = x and
>                         Log2Int(-(2^x)+1) = x-1);
true
gap> STOP_TEST( "log2.tst", 1);
