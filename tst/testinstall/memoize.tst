gap> START_TEST("memoize.tst");
gap> func := function(x) Print("Check:",x,"\n"); return x*x; end;;
gap> f1 := MemoizePosIntFunction(func);;
gap> f1(1);
Check:1
1
gap> f1(2);
Check:2
4
gap> f1(2);
4
gap> f1(6);
Check:6
36
gap> f1(-1);
Error, <val> must be a positive integer
gap> f1( () );
Error, <val> must be a positive integer
gap> f2 := MemoizePosIntFunction(func,
> rec(defaults := [10,,20], errorHandler := x -> "Woops"));;
gap> f2(1);
10
gap> f2(2);
Check:2
4
gap> f2(2);
4
gap> f2(3);
20
gap> f2(10);
Check:10
100
gap> f2(-1);
"Woops"
gap> f2( () );
"Woops"
gap> f3 := MemoizePosIntFunction(func,
> rec(defaults := [10,,20], flush := false));;
gap> f3(1);
10
gap> f3(2);
Check:2
4
gap> f3(2);
4
gap> f3(6);
Check:6
36

# HPCGAP currently disables flushing caches
gap> FlushCaches();
gap> if IsHPCGAP then Print("Check:6\n"); fi; f1(6);
Check:6
36
gap> if IsHPCGAP then Print("Check:10\n"); fi; f2(10);
Check:10
100
gap> f3(6);
36
gap> STOP_TEST("memoize.tst", 1);
