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
gap> TNAM_OBJ(fail);
"boolean or fail"

# test error handling
gap> not 1;
Error, <expr> must be 'true' or 'false' (not a integer)
gap> false or 1;
Error, <expr> must be 'true' or 'false' (not a integer)
gap> 1 or false;
Error, <expr> must be 'true' or 'false' (not a integer)
gap> true and 1;
Error, <expr> must be 'true' or 'false' (not a integer)
gap> 1 and true;
Error, <expr> must be 'true' or 'false' (not a integer)
gap> ReturnTrue and ReturnTrue;
Error, <expr> must be 'true' or 'false' (not a function)
gap> ReturnTrue and true;
Error, <expr> must be 'true' or 'false' (not a function)
gap> IsAssociative and ReturnTrue;
Error, <expr> must be 'true' or 'false' (not a function)
gap> IsAssociative and true;
Error, <expr> must be 'true' or 'false' (not a function)
gap> true and IsAssociative;
Error, <expr> must be 'true' or 'false' (not a function)

#
gap> STOP_TEST( "boolean.tst", 1);

#############################################################################
##
#E
