#############################################################################
##
#W  intarith.tst                  GAP library                 	Markus Pfeiffer 
##
##
#Y  Copyright (C)  2015,  University of St Andrews, Scotland.
##
##  Based on zmodnz.tst by Thomas Breuer
gap> START_TEST("intarith.tst");
gap> 1 + 1;
2
gap> 1 - 1;
0
gap> 1 * 1;
1
gap> 1 / 1;
1
gap> RemInt(1,1);
0
gap> QuoInt(1,1);
1

# We need to cover four cases for (opL, opR) of 
# each binary operation: (small,small), (small,gmp), (gmp,small),
# (gmp,gmp). Since being small depends on whether we are
# compiled for 32bit or 64bit, we test with inputs being
# < 30bit, between 31 and 62 bit and > 62 bit.
# TODO: Check borderline cases?
# Checked against ghci's and python's arithmetic
gap> op1 := 32555; op2 := 2^30 + 511; op3 := 1099655260031; op4 := 18446744073801981967;
32555
1073742335
1099655260031
18446744073801981967
gap> op1 + op2; op2 + op1; op1 - op2; op2 - op1;
1073774890
1073774890
-1073709780
1073709780
gap> op1 + op3; op3 + op1; op1 - op3; op3 - op1;
1099655292586
1099655292586
-1099655227476
1099655227476
gap> op1 + op4; op4 + op1; op1 - op4; op4 - op1;
18446744073802014522
18446744073802014522
-18446744073801949412
18446744073801949412
gap> op2 + op3; op3 + op2; op2 - op3; op3 - op2;
1100729002366
1100729002366
-1098581517696
1098581517696
gap> op2 + op4; op4 + op2; op2 - op4; op4 - op2;
18446744074875724302
18446744074875724302
-18446744072728239632
18446744072728239632
gap> op3 + op4; op4 + op3; op3 - op4; op4 - op3;
18446745173457241998
18446745173457241998
-18446742974146721936
18446742974146721936
gap> op1 + op1; op1 - op1;
65110
0
gap> op2 + op2; op2 - op2;
2147484670
0
gap> op3 + op3; op3 - op3;
2199310520062
0
gap> op4 + op4; op4 - op4;
36893488147603963934
0
gap> RemInt(op1,op2); RemInt(op2,op1); QuoInt(op1,op2); QuoInt(op2,op1);
32555
13325
0
32982
gap> RemInt(op1,op3); RemInt(op3, op1); QuoInt(op1,op3); QuoInt(op3,op1);
32555
1466
0
33778383
gap> RemInt(op1,op4); RemInt(op4, op1); QuoInt(op1,op4); QuoInt(op4,op1);
32555
28297
0
566633207611794
gap> op1 < op2; op2 < op1; op1 < op3; op3 < op1; op1 < op4; op4 < op1;
true
false
true
false
true
false
gap> op1 = op1; op2 = op2; op3 = op3; op4 = op4; op1 = op2; op1 = op3; op1 = op4; op2 = op3; op2 = op4; op3 = op4;
true
true
true
true
false
false
false
false
false
false
gap> -0;
0
gap> Int("0");
0
gap> Int("00");
0
gap> Int("--0");
0
gap> Int("---0");
0
gap> Int("01");
1
gap> Int("-01");
-1
gap> Int("--1");
1
gap> Int("---1");
-1
gap> Int("100000000");
100000000
gap> Int("100000001");
100000001
gap> Int("-100000001");
-100000001
gap> Int("-100000000");
-100000000
gap> Int("123456789012345678901234567890");
123456789012345678901234567890
gap> Int("-123456789012345678901234567890");
-123456789012345678901234567890
gap> Int("");
fail
gap> Int("-");
fail
gap> Int("--");
fail
gap> Int("+");
fail
gap> Int("+0");
fail
gap> Int("a");
fail
gap> Int("0 ");
fail
gap> Int(" 0");
fail
gap> Int("123456789123456789123456789123456789+1");
fail
gap> Int("A");
fail
gap> Int(['-', '1', '2', '3']);
-123
gap> Int(['1', '2', '\000', '3']);
12
gap> STOP_TEST( "intarith.tst", 330000);

#############################################################################
##
#E
