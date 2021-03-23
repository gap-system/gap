#
# Tests for functions defined in src/read.c
#
gap> START_TEST("kernel/read.tst");

#
# ReadFuncCallOption
#
gap> IsInt(1 : "a");
Syntax error: Identifier expected in stream:1
IsInt(1 : "a");
          ^^^

#
# ReadSelector
#
gap> r:=rec(a:=1);;
gap> r."a";
Syntax error: Record component name expected in stream:1
r."a";
  ^^^
gap> r!."a";
Syntax error: Record component name expected in stream:1
r!."a";
   ^^^

#
# ReadVar
#
gap> IsBound("a");
Syntax error: Identifier expected in stream:1
IsBound("a");
        ^^^

#
# ReadCallVarAss
#
gap> IsBound(x->x);
Syntax error: Function literal in impossible context in stream:1
IsBound(x->x);
         ^^

#
# ReadListExpr
#
gap> [,2..5];
Syntax error: Must have no unbound entries in range in stream:1
[,2..5];
   ^^
gap> [1,2,3..5];
Syntax error: Must have at most 2 entries before '..' in stream:1
[1,2,3..5];
      ^^
gap> [1..~];
Syntax error: Sorry, '~' not allowed in range in stream:1
[1..~];
     ^

#
# ReadRecExpr
#
gap> rec("a":=1);
Syntax error: Identifier expected in stream:1
rec("a":=1);
    ^^^

#
# ReadFuncArgList
#
gap> function(a,) end;;
Syntax error: identifier expected in stream:1
function(a,) end;;
           ^
gap> function(a end;;
Syntax error: ) expected in stream:1
function(a end;;
           ^^^
gap> {a -> a;
Syntax error: } expected in stream:1
{a -> a;
   ^^

#
# ReadFactor
#
gap> 2^3^4;
Syntax error: '^' is not associative in stream:1
2^3^4;
   ^

#
# ReadAtomic
#
gap> f := atomic function() end;;

#
# ReadEvalCommand
#
# See also https://github.com/gap-system/gap/issues/995
#

# some inputs which immediately trigger an error in ReadEvalCommand,
# even before an interpreter has been started
gap> '
Syntax error: Character literal must not include <newline> in stream:1
'
^
gap> 'x
Syntax error: Missing single quote in character constant in stream:1
'x
^^
gap> "
Syntax error: String must not include <newline> in stream:1
"
^
gap> "x
Syntax error: String must not include <newline> in stream:1
"x
^^

# similar inputs to the above, but here the error is triggered a bit
# later, after the interpreter has already started
gap> s := '
Syntax error: Character literal must not include <newline> in stream:1
s := '
     ^
Syntax error: ; expected in stream:2
gap> s := 'x
Syntax error: Missing single quote in character constant in stream:1
s := 'x
     ^^
Syntax error: ; expected in stream:2
gap> s := "
Syntax error: String must not include <newline> in stream:1
s := "
     ^
Syntax error: ; expected in stream:2
gap> s := "x
Syntax error: String must not include <newline> in stream:1
s := "x
     ^^
Syntax error: ; expected in stream:2

# errors in the middle of parsing a float literal
gap> 12.34\56;
Syntax error: Badly formed number in stream:1
12.34\56;
^^^^^
gap> 12.34\a56;
Syntax error: Badly formed number in stream:1
12.34\a56;
^^^^^
gap> 12.34\56a;
Syntax error: Badly formed number in stream:1
12.34\56a;
^^^^^

# the help command '?' and pragmas should not act as semicolon
# (see https://github.com/gap-system/gap/issues/2017)
gap> 1?abc
Syntax error: ; expected in stream:1
1?abc
 ^^^^
gap> 1#%abc
Syntax error: ; expected in stream:1
1#%abc
 ^^^^^

#
# ReadEvalFile / READ_AS_FUNC / READ_AS_FUNC_STREAM / ReadAsFunction
#
gap> f:=ReadAsFunction(InputTextString("return 1;"));
function(  ) ... end
gap> Display(f);
function (  )
    return 1;
end
gap> f();
1
gap> f:={} -> ReadAsFunction(InputTextString("return 1;"));;
gap> f();
function(  ) ... end
gap> Display(f());
function (  )
    return 1;
end
gap> f()();
1

# check that locals are supported
gap> f:=ReadAsFunction(InputTextString("local x; x:=1; return x;"));
function(  ) ... end
gap> Display(f);
function (  )
    local x;
    x := 1;
    return x;
end
gap> f();
1

# and nested functions
gap> f:=ReadAsFunction(InputTextString("local x; x := function(a) return a; end;; return x(1);"));
function(  ) ... end
gap> Display(f);
function (  )
    local x;
    x := function ( a )
          return a;
      end;
    return x( 1 );
end
gap> f();
1

# with syntax errors
gap> f:=ReadAsFunction(InputTextString("return 1"));;
Syntax error: ; expected in stream:1
gap> f:={} -> ReadAsFunction(InputTextString("return 1"));;
gap> f();
Syntax error: ; expected in stream:1
fail

# with execution errors
gap> f:=ReadAsFunction(InputTextString("return 1/0;"));;
gap> f();
Error, Rational operations: <divisor> must not be zero
gap> f:={} -> ReadAsFunction(InputTextString("return 1/0;"));;
gap> f();
function(  ) ... end
gap> f()();
Error, Rational operations: <divisor> must not be zero

# with syntax errors nested one level deep
gap> f:=ReadAsFunction(InputTextString("local x; x := function(a) return a end;; return x(1);"));;
Syntax error: ; expected in stream:1
local x; x := function(a) return a end;; return x(1);
                                   ^^^
gap> f:={} -> ReadAsFunction(InputTextString("return 1"));;
gap> f();
Syntax error: ; expected in stream:1
fail

# empty body
gap> ReadAsFunction(InputTextString(""));
function(  ) ... end

# check what happens if the function body ends earlier than
# anticipated (FIXME: implement a better error message)
gap> ReadAsFunction(InputTextString("return 1; end"));
Syntax error: <end-of-file> expected in stream:1
fail

#
gap> STOP_TEST("kernel/read.tst", 1);
