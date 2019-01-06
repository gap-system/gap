# No local variables
#@local
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

# crazy stuff that is accepted by interpreter and executor
gap> false and 1;
false
gap> true or 1;
true
gap> function() return false and 1; end();
false
gap> function() return true or 1; end();
true

# test error handling in interpreter
gap> not 1;
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> false or 1;
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> 1 or false;
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> true and 1;
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> 1 and true;
Error, <expr> must be 'true' or 'false' or a filter (not the integer 1)
gap> ReturnTrue and ReturnTrue;
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> ReturnTrue and true;
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> IsAssociative and ReturnTrue;
Error, <oper2> must be a filter (not a function)
gap> IsAssociative and true;
Error, <oper2> must be a filter (not the value 'true')
gap> IsAssociative and Center;
Error, <oper2> must be a filter (not a function)
gap> IsAssociative and FirstOp;
Error, <oper2> must be a filter (not a function)
gap> true and IsAssociative;
Error, <expr> must be 'true' or 'false' (not a function)
gap> Center and IsAssociative;
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> FirstOp and IsAssociative;
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> IsAssociative and IsAssociative;
<Property "IsAssociative">

# test error handling in executor
gap> function() return not 1; end();
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> function() return false or 1; end();
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> function() return 1 or false; end();
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> function() return true and 1; end();
Error, <expr> must be 'true' or 'false' (not the integer 1)
gap> function() return 1 and true; end();
Error, <expr> must be 'true' or 'false' or a filter (not the integer 1)
gap> function() return ReturnTrue and ReturnTrue; end();
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> function() return ReturnTrue and true; end();
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> function() return IsAssociative and ReturnTrue; end();
Error, <oper2> must be a filter (not a function)
gap> function() return IsAssociative and true; end();
Error, <oper2> must be a filter (not the value 'true')
gap> function() return IsAssociative and Center; end();
Error, <oper2> must be a filter (not a function)
gap> function() return IsAssociative and FirstOp; end();
Error, <oper2> must be a filter (not a function)
gap> function() return true and IsAssociative; end();
Error, <expr> must be 'true' or 'false' (not a function)
gap> function() return Center and IsAssociative; end();
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> function() return FirstOp and IsAssociative; end();
Error, <expr> must be 'true' or 'false' or a filter (not a function)
gap> function() return IsAssociative and IsAssociative; end();
<Property "IsAssociative">

#
gap> STOP_TEST( "boolean.tst", 1);
