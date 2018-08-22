#
# Tests for functions defined in src/intrprtr.c
#
gap> START_TEST("kernel/intrprtr.tst");

# test Assert with two arguments
gap> Assert(0, 0);
Error, <condition> in Assert must yield 'true' or 'false' (not a integer)
gap> Assert(0, true);
gap> Assert(0, false);
Error, Assertion failure
gap> Assert(100, 0);
gap> Assert(100, true);
gap> Assert(100, false);

# test Assert with three arguments
gap> Assert(0, 0, "message\n");
Error, <condition> in Assert must yield 'true' or 'false' (not a integer)
gap> Assert(0, true, "message\n");
gap> Assert(0, false, "message\n");
message
gap> Assert(0, false, 1); Print("\n"); # message can also be any object
1
gap> Assert(100, 0, "message\n");
gap> Assert(100, true, "message\n");
gap> Assert(100, false, "message\n");

#
gap> STOP_TEST("kernel/intrprtr.tst", 1);
