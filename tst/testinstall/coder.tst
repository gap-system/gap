#
# Tests for the GAP coder logic.
#
# For now this mostly focuses on testing edge cases and error
# handling in the coder.
#
# The files coder.tst and interpreter.tst closely mirror each other.
#
gap> START_TEST("coder.tst");

#
# function call with options
#
gap> f:=x->ValueOption("a");;
gap> ({}-> f(1) )();
fail
gap> ({}-> f(1 : a) )();
true
gap> ({}-> f(1 : ("a") ) )();
true
gap> ({}-> f(1 : a := 23) )();
23
gap> ({}-> f(1 : ("a") := 23 ) )();
23

#
# records
#
gap> function()
>   local r;
>   r := rec(a:=1);
>   Display(r);
>   r.a := 1;
>   Display(r.a);
>   Display(IsBound(r.a));
>   Unbind(r.a);
>   return r;
> end();
rec(
  a := 1 )
1
true
rec(  )

#
gap> function()
>   local r;
>   r := rec(a:=1);
>   Display(r);
>   r!.a := 1;
>   Display(r!.a);
>   Display(IsBound(r!.a));
>   Unbind(r!.a);
>   return r;
> end();
rec(
  a := 1 )
1
true
rec(  )

#
gap> function()
>   local r;
>   r := rec(("a"):=1);
>   Display(r);
>   r.("a") := 1;
>   Display(r.("a"));
>   Display(IsBound(r.("a")));
>   Unbind(r.("a"));
>   return r;
> end();
rec(
  a := 1 )
1
true
rec(  )

#
gap> function()
>   local r;
>   r := rec(("a"):=1);
>   Display(r);
>   r!.("a") := 1;
>   Display(r!.("a"));
>   Display(IsBound(r!.("a")));
>   Unbind(r!.("a"));
>   return r;
> end();
rec(
  a := 1 )
1
true
rec(  )

# test special case in CodeRecExprBeginElmExpr
gap> f:=x-> rec( x:= 1, ("y") := 2, 42 := 3, (43) := 4);; Display(f); f(0);
function ( x )
    return rec(
        x := 1,
         ("y") := 2,
        42 := 3,
        43 := 4 );
end
rec( 42 := 3, 43 := 4, x := 1, y := 2 )

#
# component objects (atomic by default in HPC-GAP)
#
gap> r := Objectify(NewType(NewFamily("MockFamily"), IsComponentObjectRep), rec());;

#
gap> function()
>   r!.a := 1;
>   Display(r!.a);
>   Display(IsBound(r!.a));
>   Unbind(r!.a);
>   Display(IsBound(r!.a));
> end();
1
true
false

#
gap> function()
>   r!.("a") := 1;
>   Display(r!.("a"));
>   Display(IsBound(r!.("a")));
>   Unbind(r!.("a"));
>   Display(IsBound(r!.("a")));
> end();
1
true
false

#
# lists
#
gap> function()
>   local l;
>   l:=[1,2,3];
>   Display(l);
>   l[1] := 42;
>   Display(l[1]);
>   Display(IsBound(l[1]));
>   Unbind(l[1]);
>   Display(l);
>   l{[1,3]} := [42, 23];
>   Display(l);
>   Display(l{[3,1]});
> end();
[ 1, 2, 3 ]
42
true
[ , 2, 3 ]
[ 42, 2, 23 ]
[ 23, 42 ]
gap> function()
>   local l;
>   l:=[1,2,3];
>   IsBound(l{[1,3]});
> end;
Syntax error: statement expected in stream:4
  IsBound(l{[1,3]});
  ^^^^^^^
gap> function()
>   local l;
>   l:=[1,2,3];
>   Unbind(l{[1,3]});
> end;
Syntax error: Illegal operand for 'Unbind' in stream:4
  Unbind(l{[1,3]});
                 ^

#
gap> f:=function()
>   local l;
>   l:=[1,2,3];
>   Display(l);
>   l![1] := 42;
>   Display(l![1]);
>   Display(IsBound(l![1]));
>   Unbind(l![1]);
>   Display(l);
> end;;
gap> Display(f);
function (  )
    local l;
    l := [ 1, 2, 3 ];
    Display( l );
    l![1] := 42;
    Display( l![1] );
    Display( IsBound( l![1] ) );
    Unbind( l![1] );
    Display( l );
    return;
end
gap> f();
[ 1, 2, 3 ]
42
true
[ , 2, 3 ]

#
gap> l := [1,2,3];;
gap> function() l![fail] := 42; end();
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')
gap> function() return l![fail]; end();
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> function() return IsBound(l![fail]); end();
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> function() Unbind(l![fail]); end();
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')

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
gap> function()
>   l![1] := 42;
>   Display(l![1]);
>   Display(IsBound(l![1]));
>   Unbind(l![1]);
>   Display(IsBound(l![1]));
> end();
42
true
false

#
gap> function() l![fail] := 42; end();
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')
gap> function() return l![fail]; end();
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> function() return IsBound(l![fail]); end();
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> function() Unbind(l![fail]); end();
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
gap> function()
>   l![1] := 42;
>   Display(l![1]);
>   Display(IsBound(l![1]));
>   Unbind(l![1]);
>   Display(IsBound(l![1]));
> end();
42
true
false

#
gap> function() l![fail] := 42; end();
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')
gap> function() return l![fail]; end();
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> function() return IsBound(l![fail]); end();
Error, PosObj Element: <position> must be a positive small integer (not the va\
lue 'fail')
gap> function() Unbind(l![fail]); end();
Error, PosObj Assignment: <position> must be a positive small integer (not the\
 value 'fail')

#
gap> STOP_TEST("coder.tst", 1);
