#@local f,g,h,l,mh,r,x,makeCounter,funcloop,funcstr
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
Error, Record Element: '<rec>.2' must have an assigned value
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
gap> {}->1;
function(  ) ... end
gap> ({}->1)();
1
gap> Print({}->1, "\n");
function (  )
    return 1;
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
gap> Print({x} -> x, "\n");
function ( x )
    return x;
end
gap> Print({x,y} -> x + y, "\n");
function ( x, y )
    return x + y;
end
gap> String({x,y} -> x + y);
"function ( x, y ) return x + y; end"

# Test nesting
gap> Print(function(x) if x then if x then while x do od; fi; fi; end, "\n");
function ( x )
    if x then
        if x then
            while x do
                ;
            od;
        fi;
    fi;
    return;
end
gap> String(function(x) if x then if x then while x do od; fi; fi; end);
"function ( x ) if x then if x then while x do ; od; fi; fi; return; end"

# Check strings in functions
gap> Print({x} -> "a     b","\n");
function ( x )
    return "a     b";
end
gap> String({x} -> "a     b");
"function ( x ) return \"a     b\"; end"
gap> funcstr := Concatenation("function ( x ) return \"a", ListWithIdenticalEntries(1000, ' '),"b\"; end");;
gap> String(EvalString(funcstr)) = funcstr;
true
gap> f := ({x,y} -> x + y);
function( x, y ) ... end
gap> f(2,3);
5
gap> f := ({x,y..} -> [x,y]);
Syntax error: Three dots required for variadic argument list in stream:1
f := ({x,y..} -> [x,y]);
          ^^
gap> f := ({x,y...} -> [x,y]);
function( x, y... ) ... end
gap> f(2,3);
[ 2, [ 3 ] ]
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
gap> String(x->x);
"function ( x ) return x; end"
gap> DisplayString(x->x);
"function ( x )\n    return x;\nend\n"
gap> Display(x->x);
function ( x )
    return x;
end

#
gap> Display(function() TryNextMethod(); end);
function (  )
    TryNextMethod();
end

# The number of arguments of a function
# is not determined by the name "arg" of the parameter.
gap> f:= function( arg ) return 0; end;
function( arg... ) ... end
gap> ViewString( f );
"function( arg... ) ... end"
gap> Print( f, "\n" );
function ( arg... )
    return 0;
end
gap> f:= arg -> 0;
function( arg ) ... end
gap> ViewString( f );
"function( arg ) ... end"
gap> Print( f, "\n" );
function ( arg )
    return 0;
end

#
gap> InstallGlobalFunction("CheeseCakeFunction123123", function() end);
Error, global function `CheeseCakeFunction123123' is not declared yet

#
# test that the arguments in a function call are evaluated in the right order.
#
gap> makeCounter:= function() local n; n:=0; return function() n:=n+1; return n; end; end;;
gap> f:=makeCounter();;
gap> Print(f(), f(), f(), "\n");
123
gap> g:=function(x,y,z) return [x,y,z]; end;;
gap> g(f(), f(), f());
[ 4, 5, 6 ]
gap> h:=function() return g(f(), f(), f()); end;;
gap> h();
[ 7, 8, 9 ]

#
# Test functions can be evaluated, printed to a string, and re-parsed
gap> funcloop := function(func)
> local syntax, strA, strB, syntaxB;
> syntax := SYNTAX_TREE(func);
> strA := String(func);
> strB := String(EvalString(strA));
> syntaxB := SYNTAX_TREE(EvalString(strB));
> if strA <> strB then Error("Function did not round-trip as String"); fi;
> # Remove name of functions
> Unbind(syntax.name); Unbind(syntaxB.name);
> if syntax <> syntaxB then Error("Function did not round-trip as SyntaxTree"); fi;
> Print(strA,"\n");
> end;;
gap> funcloop(x -> x + x);
function ( x ) return x + x; end
gap> funcloop(x -> (x + x) + x);
function ( x ) return x + x + x; end
gap> funcloop(x -> x + (x + x));
function ( x ) return x + (x + x); end
gap> funcloop(x -> x = x);
function ( x ) return x = x; end
gap> funcloop(x -> (x = x) = x);
function ( x ) return (x = x) = x; end
gap> funcloop(x -> x = (x = x));
function ( x ) return x = (x = x); end
gap> funcloop(x -> (x < x) < x);
function ( x ) return (x < x) < x; end
gap> funcloop(x -> (x < x) > x);
function ( x ) return (x < x) > x; end
gap> funcloop(x -> (x in x) in x);
function ( x ) return (x in x) in x; end
gap> funcloop(x -> x in (x in x));
function ( x ) return x in (x in x); end
gap> funcloop(x -> (x and x) in x);
function ( x ) return (x and x) in x; end
gap> funcloop(x -> x and (x in x));
function ( x ) return x and x in x; end
gap> funcloop(x -> (x in x) and x);
function ( x ) return x in x and x; end
gap> funcloop(x -> x in (x and x));
function ( x ) return x in (x and x); end

# nested sublist extractions
# a single extraction
gap> funcloop(x -> [ x ]{[ 1 ]});
function ( x ) return [ x ]{[ 1 ]}; end

# two extractions
gap> funcloop(x -> ([ x ]{[ 1 ]}){[ 1 ]});
function ( x ) return ([ x ]{[ 1 ]}){[ 1 ]}; end
gap> funcloop(x -> [ [ x ] ]{[ 1 ]}{[ 1 ]});
function ( x ) return [ [ x ] ]{[ 1 ]}{[ 1 ]}; end

# three extractions
gap> funcloop(x -> (([ x ]{[ 1 ]}){[ 1 ]}){[ 1 ]});
function ( x ) return (([ x ]{[ 1 ]}){[ 1 ]}){[ 1 ]}; end
gap> funcloop(x -> ([ [ x ] ]{[ 1 ]}{[ 1 ]}){[ 1 ]});
function ( x ) return ([ [ x ] ]{[ 1 ]}{[ 1 ]}){[ 1 ]}; end
gap> funcloop(x -> ([ [ x ] ]{[ 1 ]}){[ 1 ]}{[ 1 ]});
function ( x ) return ([ [ x ] ]{[ 1 ]}){[ 1 ]}{[ 1 ]}; end

# four extractions
gap> funcloop(x -> ([ [ x ] ]{[ 1 ]}{[ 1 ]}){[ 1 ]}{[ 1 ]});
function ( x ) return ([ [ x ] ]{[ 1 ]}{[ 1 ]}){[ 1 ]}{[ 1 ]}; end
gap> STOP_TEST("function.tst", 1);
