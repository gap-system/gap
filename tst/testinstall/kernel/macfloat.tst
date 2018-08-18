#
# Tests for functions defined in src/macfloat.c
#
gap> START_TEST("kernel/macfloat.tst");

#
gap> MACFLOAT_INT(fail);
fail

#
gap> MACFLOAT_STRING(fail);
Error, MACFLOAT_STRING: object to be converted must be a string not a boolean \
or fail

#
gap> pi := 3.1415926535897932384626433;
3.14159
gap> STRING_DIGITS_MACFLOAT(10, pi);
"3.141592654"
gap> STRING_DIGITS_MACFLOAT(20, pi);
"3.141592653589793116"
gap> STRING_DIGITS_MACFLOAT(40, pi);
"3.141592653589793115997963468544185161591"
gap> STRING_DIGITS_MACFLOAT(50, pi);
"3.141592653589793115997963468544185161591"

#
gap> LDEXP_MACFLOAT(pi,1);
6.28319
gap> LDEXP_MACFLOAT(pi,-1);
1.5708
gap> LDEXP_MACFLOAT(pi,0);
3.14159

#
gap> FREXP_MACFLOAT(0.);
[ 0., 0 ]
gap> FREXP_MACFLOAT(1.);
[ 0.5, 1 ]
gap> FREXP_MACFLOAT(pi);
[ 0.785398, 2 ]

#
gap> STOP_TEST("kernel/macfloat.tst", 1);
