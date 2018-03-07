#
# Tests for the GAP interpreter logic.
#
# For now this mostly focuses on testing edge cases and error
# handling in the interpreter.
#

#
# non boolean expression as condition
#
gap> if 1 then fi;
Error, <expr> must be 'true' or 'false' (not a integer)

#
# 'quit' inside functions
#
gap> function() quit; end;
Syntax error: 'quit;' cannot be used in this context in stream:1
function() quit; end;
               ^

#
# return is not allowed in interpreter
#
gap> return;
'return' must not be used in file read-eval loop
gap> return 1;
'return' must not be used in file read-eval loop

#
# isolated quit and QUIT are ignore in test files
#
gap> quit;
gap> QUIT;

#
# help system
#
gap> ?qwert_asdf
Help: no matching entry found

#
# tilde
#
gap> ~;
Error, '~' does not have a value here

#
# function call with options
#
gap> f:=x->ValueOption("a");;
gap> f(1);
fail
gap> f(1 : a);
true
gap> f(1 : ("a") );
true
gap> f(1 : a := 23);
23
gap> f(1 : ("a") := 23 );
23

#
# records
#
gap> r:=rec(a:=1);
rec( a := 1 )

#
gap> r.a := 1;
1
gap> r.a;
1
gap> IsBound(r.a);
true
gap> Unbind(r.a);
gap> r;
rec(  )

#
gap> r!.a := 1;
1
gap> r!.("a");
1
gap> IsBound(r!.a);
true
gap> Unbind(r!.a);
gap> r;
rec(  )

#
gap> r.("a") := 1;
1
gap> r.("a");
1
gap> IsBound(r.("a"));
true
gap> Unbind(r.("a"));
gap> r;
rec(  )

#
gap> r!.("a") := 1;
1
gap> r!.("a");
1
gap> IsBound(r!.("a"));
true
gap> Unbind(r!.("a"));
gap> r;
rec(  )

#
# assertions
#
gap> Assert(0, true);
gap> Assert(0, false);
Error, Assertion Failure
gap> Assert(0, 0);
Error, <condition> in Assert must yield 'true' or 'false' (not a integer)
gap> Assert(0, true, "bla");
gap> Assert(0, false, "bla\n");
bla
gap> Assert(0, false, 1); Print("\n");
1
gap> Assert(0, 0, "bla");
Error, <condition> in Assert must yield 'true' or 'false' (not a integer)
