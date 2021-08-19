#
# Tests for functions defined in src/funcs.c
#
gap> START_TEST("kernel/funcs.tst");

#
gap> SetRecursionTrapInterval(fail);
Error, SetRecursionTrapInterval: <interval> must be a small integer greater th\
an 5 (not the value 'fail')

#
gap> STOP_TEST("kernel/funcs.tst", 1);
