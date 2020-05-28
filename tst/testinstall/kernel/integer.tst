#
# Tests for functions defined in src/integer.c
#
gap> START_TEST("kernel/integer.tst");

#
gap> INT_STRING(fail);
fail

#
gap> ABS_INT(-100);
100
gap> ABS_INT(-100000000000);
100000000000

#
gap> SIGN_INT(-100);
-1
gap> SIGN_INT(-100000000000);
-1

#
gap> FACTORIAL_INT(fail);
Error, FACTORIAL_INT: <n> must be a non-negative small integer (not the value \
'fail')

#
#
#
gap> N := 2^(8*GAPInfo.BytesPerVariable-1);;
gap> data:=Set([0, 1, 2^28-1, 2^28, 2^28+1, INTOBJ_MAX-1, INTOBJ_MAX, INTOBJ_MAX+1, N-1 ]);;
gap> data64:=Union(data, [ 2^60-1, 2^60, 2^60+1, 2^63-1]);;

#
gap> ForAll(data, n -> INTERNAL_TEST_CONV_INT(n) = n);
true
gap> ForAll(data, n -> INTERNAL_TEST_CONV_INT(-n) = -n);
true
gap> INTERNAL_TEST_CONV_INT(-N) = -N;
true
gap> INTERNAL_TEST_CONV_INT(N-1) = N-1;
true
gap> INTERNAL_TEST_CONV_INT(-N-1);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT(N);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT(2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT(-2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT(fail);
Error, Conversion error: <i> must be an integer (not the value 'fail')

#
gap> ForAll(data, n -> INTERNAL_TEST_CONV_UINT(n) = n);
true
gap> INTERNAL_TEST_CONV_UINT(2*N-1) = 2*N-1;
true
gap> INTERNAL_TEST_CONV_UINT(2*N);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_UINT(2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_UINT(-1);
Error, Conversion error: cannot convert negative integer to unsigned type
gap> INTERNAL_TEST_CONV_UINT(fail);
Error, Conversion error: <i> must be a non-negative integer (not the value 'fa\
il')

#
gap> ForAll(data, n -> INTERNAL_TEST_CONV_UINTINV(n) = -n);
true
gap> -INTERNAL_TEST_CONV_UINTINV(2*N-1) = 2*N-1;
true
gap> INTERNAL_TEST_CONV_UINTINV(2*N);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_UINTINV(2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_UINTINV(-1);
Error, Conversion error: cannot convert negative integer to unsigned type
gap> INTERNAL_TEST_CONV_UINTINV(fail);
Error, Conversion error: <i> must be a non-negative integer (not the value 'fa\
il')

#
gap> ForAll(data64, n -> INTERNAL_TEST_CONV_INT8(n) = n);
true
gap> ForAll(data64, n -> INTERNAL_TEST_CONV_INT8(-n) = -n);
true
gap> INTERNAL_TEST_CONV_INT8(-2^63) = -2^63;
true
gap> INTERNAL_TEST_CONV_INT8(2^63-1) = 2^63-1;
true
gap> INTERNAL_TEST_CONV_INT8(-2^63-1);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT8(2^63);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT8(2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT8(-2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_INT8(fail);
Error, Conversion error: <i> must be an integer (not the value 'fail')

#
gap> ForAll(data64, n -> INTERNAL_TEST_CONV_UINT8(n) = n);
true
gap> INTERNAL_TEST_CONV_UINT8(2^64-1) = 2^64-1;
true
gap> INTERNAL_TEST_CONV_UINT8(2^64);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_UINT8(2^100);
Error, Conversion error: integer too large
gap> INTERNAL_TEST_CONV_UINT8(-1);
Error, Conversion error: cannot convert negative integer to unsigned type
gap> INTERNAL_TEST_CONV_UINT8(fail);
Error, Conversion error: <i> must be a non-negative integer (not the value 'fa\
il')

#
gap> STOP_TEST("kernel/integer.tst", 1);
