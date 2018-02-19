gap> START_TEST("evalstring.tst");

#
gap> EvalString("");

#
gap> f := function() local x; return x; end;;
gap> EvalString("f();");
Error, Variable: 'x' must have an assigned value
Error, Could not evaluate string.


#
gap> EvalString("x := 15;");
15

#
gap> EvalString("Print(\"Hello, world\\n\");");
Hello, world
gap> EvalString("15 + 1; Print(\"Hello, world\");");
Hello, world16

#
gap> STOP_TEST( "evalstring.tst", 1);
