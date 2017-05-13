gap> START_TEST("function.tst");
gap> IsKernelFunction(IsKernelFunction);
true
gap> IsKernelFunction(function(x) return 1; end);
false
gap> IsKernelFunction(5);
fail
gap> IsKernelFunction(rec( a := function() return 0; end ));
fail
gap> f := function() end;;
gap> g := function() return 2; end;;
gap> h := function(T) end;;
gap> mh := function(T...) return 3; end;;
gap> l := [1,2,3];;
gap> f();
gap> (f)();
gap> f() + 2;
Error, Function call: <func> must return a value
gap> f(f());
Error, Function call: <func> must return a value
gap> h(f());
Error, Function call: <func> must return a value
gap> mh(1,2,f);
3
gap> mh(f());
Error, Function call: <func> must return a value
gap> mh(1,2,f());
Error, Function call: <func> must return a value
gap> mh(1,2,g());
3
gap> l[f()];
Error, Function call: <func> must return a value
gap> l{[1..f()]};
Error, Function call: <func> must return a value
gap> l{[f()..f()]};
Error, Function call: <func> must return a value
gap> l{[f()..1]};
Error, Function call: <func> must return a value
gap> r := rec(f := f, g := g);
rec( f := function(  ) ... end, g := function(  ) ... end )
gap> r.f();
gap> r.f()();
Error, Function call: <func> must return a value
gap> (r.f)();
gap> (r.g)();
2
gap> (r.g)() + 3;
5
gap> (r.f)() + 3;
Error, Function call: <func> must return a value
gap> (1,f());
Error, Function call: <func> must return a value
gap> (f(),1);
Error, Function call: <func> must return a value
gap> (1,g());
(1,2)
gap> (g(),1);
(1,2)
gap> x := f();
Error, Function call: <func> must return a value
gap> 2 < f();
Error, Function call: <func> must return a value
gap> f() < f();
Error, Function call: <func> must return a value
gap> f() < g();
Error, Function call: <func> must return a value
gap> g() < f();
Error, Function call: <func> must return a value
gap> g() < g();
false
gap> (x -> f())();
Error, Function: number of arguments must be 1 (not 0)
gap> (x -> f())(1);
Error, Function Calls: <func> must return a value
gap> Assert(1000, f());
gap> Assert(0, f());
Error, Function call: <func> must return a value
gap> Assert(f(), f());
Error, Function call: <func> must return a value
gap> Assert(f(), g());
Error, Function call: <func> must return a value
gap> Info(InfoWarning, 1, f());
Error, Function call: <func> must return a value
gap> Info(f(), 1, "hello");
Error, Function call: <func> must return a value
gap> Info(InfoWarning, f(), "hello");
Error, Function call: <func> must return a value
gap> Info(InfoWarning, 1, f());
Error, Function call: <func> must return a value
gap> Info(InfoWarning, 1000, f());
gap> r.(f());
Error, Function call: <func> must return a value
gap> r.(g());
Error, Record: '<rec>.2' must have an assigned value
gap> (function() end)();
gap> (function() return 2; end)();
2
gap> (function() return function() end; end)()();
gap> (function() return function() return 3; end; end)()();
3
gap> x -> x;
function( x ) ... end
gap> (x->x)("abc");
"abc"
gap> (x -> 2*x)(4);
8
gap> Print(x->x, "\n");
function ( x )
    return x;
end
gap> x -> y -> x+y;
function( x ) ... end
gap> Print(x -> y -> x+y, "\n");
function ( x )
    return function ( y )
          return x + y;
      end;
end
gap> f := x -> y -> x+y;
function( x ) ... end
gap> f(1)(2);
3
gap> function(a,a) end;
Syntax error: Name used for two arguments in stream:1
function(a,a) end;
           ^
gap> function(a,b,a) end;
Syntax error: Name used for two arguments in stream:1
function(a,b,a) end;
             ^
gap> function(a,b) local c,c; end;
Syntax error: Name used for two locals in stream:1
function(a,b) local c,c; end;
                      ^
gap> function(a,b) local c,b,c; end;
Syntax error: Name used for argument and local in stream:1
function(a,b) local c,b,c; end;
                      ^
gap> function(a,b) local b,c,b,c; end;
Syntax error: Name used for argument and local in stream:1
function(a,b) local b,c,b,c; end;
                    ^
gap> STOP_TEST("function.tst", 1);
