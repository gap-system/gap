gap> START_TEST("varargs.tst");
gap> f := function(a,b...) return [a,b]; end;
function( a, b... ) ... end
gap> Display(f);
function ( a, b... )
    return [ a, b ];
end
gap> f(1);
[ 1, [  ] ]
gap> f(1,2);
[ 1, [ 2 ] ]
gap> f(1,2,3);
[ 1, [ 2, 3 ] ]
gap> f := function(arg) return arg; end;
function( arg... ) ... end
gap> Display(f);
function ( arg... )
    return arg;
end
gap> f();
[  ]
gap> f(1);
[ 1 ]
gap> f(1,2);
[ 1, 2 ]
gap> f(1,2,3);
[ 1, 2, 3 ]
gap> f := function(arg...) return arg; end;
function( arg... ) ... end
gap> Display(f);
function ( arg... )
    return arg;
end
gap> f();
[  ]
gap> f(1);
[ 1 ]
gap> f(1,2);
[ 1, 2 ]
gap> f(1,2,3);
[ 1, 2, 3 ]
gap> f := function(a...) return a; end;
function( a... ) ... end
gap> Display(f);
function ( a... )
    return a;
end
gap> f();
[  ]
gap> f(1);
[ 1 ]
gap> f(1,2);
[ 1, 2 ]
gap> f(1,2,3);
[ 1, 2, 3 ]
gap> function(a,b..) end;
Syntax error: Three dots required for variadic argument list in stream line 1
function(a,b..) end;
             ^
gap> function(a...,b) end;
Syntax error: Only final argument can be variadic in stream line 1
function(a...,b) end;
             ^
gap> function(a..,b) end;
Syntax error: Three dots required for variadic argument list in stream line 1
function(a..,b) end;
           ^
gap> function(a....,b) end;
Syntax error: ) expected in stream line 1
function(a....,b) end;
             ^
gap> function(a,b....) end;
Syntax error: ) expected in stream line 1
function(a,b....) end;
               ^
gap> f := function(a,b..) end;
Syntax error: Three dots required for variadic argument list in stream line 1
f := function(a,b..) end;
                  ^
gap> Display(RETURN_FIRST);
function ( object... )
    <<kernel or compiled code>>
end
gap> [1..2];
[ 1, 2 ]
gap> [1...2];
Syntax error: Only two dots in a range in stream line 1
[1...2];
    ^
gap> f := function(a,arg) return [a,arg]; end;
function( a, arg ) ... end
gap> f(1,2);
[ 1, 2 ]
gap> STOP_TEST("varargs.tst", 1);
