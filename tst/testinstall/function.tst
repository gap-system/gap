gap> START_TEST("function.tst");
gap> IsKernelFunction(IsKernelFunction);
true
gap> IsKernelFunction(function(x) return 1; end);
false
gap> IsKernelFunction(5);
fail
gap> IsKernelFunction(rec( a := function() return 0; end ));
fail
gap> STOP_TEST("function.tst", 1);
