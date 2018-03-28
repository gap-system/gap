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
# lists and posobj
#
gap> l:=[1,2,3];
[ 1, 2, 3 ]

#
gap> l[1] := 42;
42
gap> l[1];
42
gap> IsBound(l[1]);
true
gap> Unbind(l[1]);
gap> l;
[ , 2, 3 ]

#
gap> l![1] := 42;
42
gap> l![1];
42
gap> IsBound(l![1]);
true
gap> Unbind(l![1]);
gap> l;
[ , 2, 3 ]

#
gap> l{[1,3]} := [42, 23];
[ 42, 23 ]
gap> l{[3,1]};
[ 23, 42 ]
gap> IsBound(l{[1,3]});
Syntax error: Illegal operand for 'IsBound' in stream:1
IsBound(l{[1,3]});
                ^
gap> Unbind(l{[1,3]});
Syntax error: Illegal operand for 'Unbind' in stream:1
Unbind(l{[1,3]});
               ^
gap> l;
[ 42, 2, 23 ]

#
gap> l!{[1,3]} := [42, 23];
[ 42, 23 ]
gap> l!{[3,1]};
[ 23, 42 ]
gap> IsBound(l!{[1,3]});
Syntax error: Illegal operand for 'IsBound' in stream:1
IsBound(l!{[1,3]});
                 ^
gap> Unbind(l!{[1,3]});
Syntax error: Illegal operand for 'Unbind' in stream:1
Unbind(l!{[1,3]});
                ^
gap> l;
[ 42, 2, 23 ]

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
