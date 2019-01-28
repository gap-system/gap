#
# Tests for the GAP interpreter logic.
#
# For now this mostly focuses on testing edge cases and error
# handling in the interpreter.
#
# The files coder.tst and interpreter.tst closely mirror each other.
#
gap> START_TEST("interpreter.tst");

#
# non boolean expression as condition
#
gap> if 1 then fi;
Error, <expr> must be 'true' or 'false' (not the integer 1)

#
# 'quit' inside functions
#
gap> function() quit; end;
Syntax error: 'quit;' cannot be used in this context in stream:1
function() quit; end;
           ^^^^

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
gap> r!.a;
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

# test special case in IntrRecExprBeginElmExpr
gap> rec( x:= 1, ("y") := 2, 42 := 3, (43) := 4);
rec( 42 := 3, 43 := 4, x := 1, y := 2 )

#
# component objects (atomic by default in HPC-GAP)
#
gap> r := Objectify(NewType(NewFamily("MockFamily"), IsComponentObjectRep), rec());;

#
gap> r!.a := 1;
1
gap> r!.a;
1
gap> IsBound(r!.a);
true
gap> Unbind(r!.a);

#
gap> r!.("a") := 1;
1
gap> r!.("a");
1
gap> IsBound(r!.("a"));
true
gap> Unbind(r!.("a"));

#
# lists
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
gap> l![fail] := 42;
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')
gap> l![fail];
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> IsBound(l![fail]);
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> Unbind(l![fail]);
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')

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
# posobj
#
gap> l := Objectify(NewType(NewFamily("MockFamily"), IsPositionalObjectRep),[]);;

#
gap> l![1] := 42;
42
gap> l![1];
42
gap> IsBound(l![1]);
true
gap> Unbind(l![1]);
gap> IsBound(l![1]);
false

#
gap> l![fail] := 42;
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')
gap> l![fail];
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> IsBound(l![fail]);
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> Unbind(l![fail]);
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')

#
# atomic posobj (HPC-GAP)
#
gap> l := Objectify(NewType(NewFamily("MockFamily"), IsAtomicPositionalObjectRep),[23]);;

#
gap> l![1] := 42;
42
gap> l![1];
42
gap> IsBound(l![1]);
true
gap> Unbind(l![1]);
gap> IsBound(l![1]);
false

#
gap> l![fail] := 42;
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')
gap> l![fail];
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> IsBound(l![fail]);
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> Unbind(l![fail]);
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')

#
#
gap> STOP_TEST("interpreter.tst", 1);
