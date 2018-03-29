#
# Tests for functions defined in src/read.c
#

#
# ReadFuncCallOption
#
gap> IsInt(1 : "a");
Syntax error: Identifier expected in stream:1
IsInt(1 : "a");
            ^

#
# ReadSelector
#
gap> r:=rec(a:=1);;
gap> r."a";
Syntax error: Record component name expected in stream:1
r."a";
    ^
gap> r!."a";
Syntax error: Record component name expected in stream:1
r!."a";
     ^

#
# ReadVar
#
gap> IsBound("a");
Syntax error: Identifier expected in stream:1
IsBound("a");
          ^

#
# ReadCallVarAss
#
gap> IsBound(x->x);
Syntax error: Function literal in impossible context in stream:1
IsBound(x->x);
          ^

#
# ReadListExpr
#
gap> [,2..5];
Syntax error: Must have no unbound entries in range in stream:1
[,2..5];
    ^
gap> [1,2,3..5];
Syntax error: Must have at most 2 entries before '..' in stream:1
[1,2,3..5];
       ^
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
      ^
