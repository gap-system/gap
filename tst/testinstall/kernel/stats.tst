#
# Tests for functions defined in src/stats.c
#
gap> START_TEST("kernel/stats.tst");

# test checks in ExecForRangeHelper
gap> f := function(a) local x; for x in [a..1] do od; end;;
gap> f('x');
Error, Range: <first> must be a small integer (not a character)
gap> f := function(a) local x; for x in [1..a] do od; end;;
gap> f('x');
Error, Range: <last> must be a small integer (not a character)

# test Assert with two arguments
gap> function() Assert(fail, 0); end();
Error, Assert: <lev> must be a small integer (not the value 'fail')
gap> function() Assert(0, 0); end();
Error, Assert: <cond> must be 'true' or 'false' (not the integer 0)
gap> function() Assert(0, true); end();
gap> function() Assert(0, false); end();
Error, Assertion failure
gap> function() Assert(100, 0); end();
gap> function() Assert(100, true); end();
gap> function() Assert(100, false); end();

# test Assert with three arguments
gap> function() Assert(fail, 0, "message\n"); end();
Error, Assert: <lev> must be a small integer (not the value 'fail')
gap> function() Assert(0, 0, "message\n"); end();
Error, Assert: <cond> must be 'true' or 'false' (not the integer 0)
gap> function() Assert(0, true, "message\n"); end();
gap> function() Assert(0, false, "message\n"); end();
message
gap> function() Assert(0, false, 1); Print("\n"); end(); # message can also be any object
1
gap> function() Assert(100, 0, "message\n"); end();
gap> function() Assert(100, true, "message\n"); end();
gap> function() Assert(100, false, "message\n"); end();

#
gap> STOP_TEST("kernel/stats.tst", 1);
