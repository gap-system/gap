gap> START_TEST("depth.tst");

# We don't know what the recursion depth will be when the test starts,
# so do relative comparisons.
gap> curdepth := GetRecursionDepth();;
gap> GetRecursionDepth() - curdepth;
0
gap> dive := function(depth)
>  if depth>1 then
>    dive(depth-1);
>  else
>    Print("Depth ", GetRecursionDepth() - curdepth, "\n");
>  fi;
> end;;
gap> dive(10);
Depth 10
gap> dive(80);
Depth 80
gap> SetRecursionTrapInterval(50);
gap> dive(80);
Error, recursion depth trap (50)
gap> SetRecursionTrapInterval(5000);
gap> dive(80);
Depth 80

# Just want an error to occur to check the depth is reset correctly
gap> IsAbelian(2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IsCommutative' on 1 arguments
gap> dive(80);
Depth 80
gap> STOP_TEST( "depth.tst", 1);
