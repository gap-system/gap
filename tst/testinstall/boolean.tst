#############################################################################
##
#W  boolean.tst                GAP Library                      Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##
gap> START_TEST("boolean.tst");
gap> not true;
false
gap> not false;
true
gap> true = true;
true
gap> true = false;
false
gap> false = true;
false
gap> false = false;
true
gap> true < true;
false
gap> true < false;
true
gap> false < true;
false
gap> false < false;
false
gap> true or true;
true
gap> true or false;
true
gap> false or true;
true
gap> false or false;
false
gap> true and true;
true
gap> true and false;
false
gap> false and true;
false
gap> false and false;
false
gap> String(true); String(false); String(fail);
"true"
"false"
"fail"
gap> ViewString(true); ViewString(false); ViewString(fail);
"true"
"false"
"fail"
gap> TNUM_OBJ(fail)[2];
"boolean or fail"
gap> STOP_TEST( "boolean.tst", 1);

#############################################################################
##
#E
