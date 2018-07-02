gap> START_TEST("evalstring.tst");

#
gap> EvalString("1+1");
2
gap> EvalString("(1,2,3) * (2,3,4)^2") = (1,2,3) * (2,3,4)^2;
true

#
gap> global_a := 0;;
gap> global_b := 0;;
gap> example := function ( local_a )
>     local  local_b;
>     local_b := 5;
>     global_a := local_a;
>     global_b := local_b;
>     return EvalString( "global_a * global_b" );
> end;;
gap> example( 2 );
10

#
# Error cases
#

#
gap> EvalString("");
Error, Function Calls: <func> must return a value

#
gap> f := function() local x; return x; end;;
gap> EvalString("f();");
Error, Variable: 'x' must have an assigned value

#
gap> Unbind(local_a); Unbind(local_b);
gap> example := function ( local_a )
>   local local_b;
>   local_b := 5;
>   return EvalString( "local_a * local_b" );
> end;;
gap> example(1);
Syntax warning: Unbound global variable in stream:2
local_a * local_b;
        ^
Syntax warning: Unbound global variable in stream:2
local_a * local_b;
                 ^
Error, Variable: 'local_a' must have an assigned value

#
gap> x:=0;
0
gap> EvalString("x := 15;");
Syntax error: ; expected in stream:2
x := 15;;
   ^
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CallFuncList' on 2 arguments
The 1st argument is 'fail' which might point to an earlier problem


#
gap> EvalString("Print(\"Hello, world\\n\");");
Hello, world
Error, Function Calls: <func> must return a value
gap> EvalString("15 + 1; Print(\"Hello, world\");");
16

#
gap> STOP_TEST( "evalstring.tst", 1);
