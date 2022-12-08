#
# Tests for functions defined in src/vec8bit.c
#
gap> START_TEST("kernel/vec8bit.tst");

#
gap> TRANSPOSED_MAT8BIT(fail);
Error, TRANSPOSED_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value\
 'fail')

#
gap> STOP_TEST("kernel/vec8bit.tst", 1);
