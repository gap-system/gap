#
# Tests for functions defined in src/vecgf2.c
#
gap> START_TEST("kernel/vecgf2.tst");

#
gap> TRANSPOSED_GF2MAT(fail);
Error, TRANSPOSED_GF2MAT: Need compressed matrix over GF(2)

#
gap> STOP_TEST("kernel/vecgf2.tst", 1);
