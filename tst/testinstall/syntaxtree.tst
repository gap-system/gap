
#
gap> SYNTAX_TREE(1);
Error, SYNTAX_TREE: <func> must be a plain GAP function (not the integer 1)
gap> SYNTAX_TREE(\+);
Error, SYNTAX_TREE: <func> must be a plain GAP function (not a function)
gap> SyntaxTree(1);
Error, SYNTAX_TREE: <func> must be a plain GAP function (not the integer 1)
gap> SyntaxTree(x -> x);
<syntax tree>
gap> SyntaxTree(\+);
Error, SYNTAX_TREE: <func> must be a plain GAP function (not a function)

# Just try compiling all functions we can find in the workspace
# to see nothing crashes.
gap> for n in NamesGVars() do
>        if IsBoundGlobal(n) and not IsAutoGlobal(n) then
>            v := ValueGlobal(n);
>            if IsFunction(v) and not IsKernelFunction(v) then
>                SYNTAX_TREE(v);
>            elif IsOperation(v) then
>                for i in [1..6] do
>                    for x in METHODS_OPERATION(v, i) do
>                        if IsFunction(x) and not IsKernelFunction(v) then
>                        SYNTAX_TREE(x);
>                        fi;
>                    od; 
>                od;
>            fi;
>        fi;
> od;;

#
# statements
#
gap> testit := function(f)
>   local tree;
>   tree := SYNTAX_TREE(f);
>   Display(tree);
>   # TODO: recode the tree, then decode again and compare
>   return true;
> end;;

# T_PROCCALL_0ARGS
gap> testit(function(x) x(); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [  ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_0ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_1ARGS
gap> testit(function(x) x(1); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_1ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_2ARGS
gap> testit(function(x) x(1,2); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ), rec(
                      type := "T_INTEXPR",
                      value := 2 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_2ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_3ARGS
gap> testit(function(x) x(1,2,3); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ), rec(
                      type := "T_INTEXPR",
                      value := 2 ), rec(
                      type := "T_INTEXPR",
                      value := 3 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_3ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_4ARGS
gap> testit(function(x) x(1,2,3,4); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ), rec(
                      type := "T_INTEXPR",
                      value := 2 ), rec(
                      type := "T_INTEXPR",
                      value := 3 ), rec(
                      type := "T_INTEXPR",
                      value := 4 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_4ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_5ARGS
gap> testit(function(x) x(1,2,3,4,5); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ), rec(
                      type := "T_INTEXPR",
                      value := 2 ), rec(
                      type := "T_INTEXPR",
                      value := 3 ), rec(
                      type := "T_INTEXPR",
                      value := 4 ), rec(
                      type := "T_INTEXPR",
                      value := 5 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_5ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_6ARGS
gap> testit(function(x) x(1,2,3,4,5,6); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ), rec(
                      type := "T_INTEXPR",
                      value := 2 ), rec(
                      type := "T_INTEXPR",
                      value := 3 ), rec(
                      type := "T_INTEXPR",
                      value := 4 ), rec(
                      type := "T_INTEXPR",
                      value := 5 ), rec(
                      type := "T_INTEXPR",
                      value := 6 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_6ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_XARGS
gap> testit(function(x) x(1,2,3,4,5,6,7); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "T_INTEXPR",
                      value := 1 ), rec(
                      type := "T_INTEXPR",
                      value := 2 ), rec(
                      type := "T_INTEXPR",
                      value := 3 ), rec(
                      type := "T_INTEXPR",
                      value := 4 ), rec(
                      type := "T_INTEXPR",
                      value := 5 ), rec(
                      type := "T_INTEXPR",
                      value := 6 ), rec(
                      type := "T_INTEXPR",
                      value := 7 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_PROCCALL_XARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROCCALL_OPTS
gap> testit(function(x) x(1 : opt); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              call := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_PROCCALL_1ARGS" ),
              opts := rec(
                  keyvalue := [ rec(
                          key := "opt",
                          value := rec(
                              type := "T_TRUE_EXPR" ) ) ],
                  type := "T_REC_EXPR" ),
              type := "T_PROCCALL_OPTS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) x(1 : opt := 42); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              call := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_PROCCALL_1ARGS" ),
              opts := rec(
                  keyvalue := [ rec(
                          key := "opt",
                          value := rec(
                              type := "T_INTEXPR",
                              value := 42 ) ) ],
                  type := "T_REC_EXPR" ),
              type := "T_PROCCALL_OPTS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_EMPTY
gap> testit(function(x) ; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_EMPTY" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT
gap> testit(function(x) return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) if x then return; return; return; return; return; return; return; return; fi; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          statements := [ rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ), rec(
                                  type := "T_RETURN_VOID" ) ],
                          type := "T_SEQ_STAT" ),
                      condition := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ) ) ],
              type := "T_IF" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT2
gap> testit(function(x) return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT3
gap> testit(function(x) return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT3" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT4
gap> testit(function(x) return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT4" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT5
gap> testit(function(x) return; return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT5" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT6
gap> testit(function(x) return; return; return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT6" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SEQ_STAT7
gap> testit(function(x) return; return; return; return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT7" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# 
# T_IF
# T_IF_ELSE
# T_IF_ELIF
# T_IF_ELIF_ELSE
gap> testit(function(x) if x then fi; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ) ) ],
              type := "T_IF" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) if x then else fi; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          type := "T_TRUE_EXPR" ) ) ],
              type := "T_IF_ELSE" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x,y) if x then elif y then fi; end);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 2,
                          type := "T_REFLVAR" ) ) ],
              type := "T_IF_ELIF" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x,y) if x then elif y then else fi; end);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 2,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          type := "T_TRUE_EXPR" ) ) ],
              type := "T_IF_ELIF_ELSE" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x,y,z) if x then elif y then elif z then else fi; end);
rec(
  nams := [ "x", "y", "z" ],
  narg := 3,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 2,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          lvar := 3,
                          type := "T_REFLVAR" ) ), rec(
                      body := rec(
                          type := "T_EMPTY" ),
                      condition := rec(
                          type := "T_TRUE_EXPR" ) ) ],
              type := "T_IF_ELIF_ELSE" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FOR
# T_FOR2
# T_FOR3
gap> testit(function(x) for x in x do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_EMPTY" ) ],
              collection := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_FOR",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in x do return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ) ],
              collection := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_FOR",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in x do return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              collection := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_FOR2",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in x do return; return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              collection := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_FOR3",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in x do return; return; return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      statements := [ rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ) ],
                      type := "T_SEQ_STAT4" ) ],
              collection := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_FOR",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FOR_RANGE
# T_FOR_RANGE2
# T_FOR_RANGE3
gap> testit(function(x) for x in [1..2] do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_EMPTY" ) ],
              collection := rec(
                  first := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  last := rec(
                      type := "T_INTEXPR",
                      value := 2 ),
                  type := "T_RANGE_EXPR" ),
              type := "T_FOR_RANGE",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in [1..2] do return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ) ],
              collection := rec(
                  first := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  last := rec(
                      type := "T_INTEXPR",
                      value := 2 ),
                  type := "T_RANGE_EXPR" ),
              type := "T_FOR_RANGE",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in [1..2] do return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              collection := rec(
                  first := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  last := rec(
                      type := "T_INTEXPR",
                      value := 2 ),
                  type := "T_RANGE_EXPR" ),
              type := "T_FOR_RANGE2",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in [1..2] do return; return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              collection := rec(
                  first := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  last := rec(
                      type := "T_INTEXPR",
                      value := 2 ),
                  type := "T_RANGE_EXPR" ),
              type := "T_FOR_RANGE3",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) for x in [1..2] do return; return; return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      statements := [ rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ) ],
                      type := "T_SEQ_STAT4" ) ],
              collection := rec(
                  first := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  last := rec(
                      type := "T_INTEXPR",
                      value := 2 ),
                  type := "T_RANGE_EXPR" ),
              type := "T_FOR_RANGE",
              variable := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ) ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_WHILE
# T_WHILE2
# T_WHILE3
gap> testit(function(x) while true do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_EMPTY" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_WHILE" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) while true do return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_WHILE" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) while true do return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_WHILE2" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) while true do return; return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_WHILE3" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) while true do return; return; return; return; od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      statements := [ rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ) ],
                      type := "T_SEQ_STAT4" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_WHILE" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_REPEAT
# T_REPEAT2
# T_REPEAT3
gap> testit(function(x) repeat until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_EMPTY" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) repeat return; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) repeat return; return; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT2" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) repeat return; return; return; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ), rec(
                      type := "T_RETURN_VOID" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT3" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) repeat return; return; return; return; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      statements := [ rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ), rec(
                              type := "T_RETURN_VOID" ) ],
                      type := "T_SEQ_STAT4" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ATOMIC
#@if IsHPCGAP
gap> testit(function(x) atomic x do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := rec(
                  type := "T_EMPTY" ),
              locks := [ rec(
                      type := "T_INTEXPR",
                      value := 0 ), rec(
                      lvar := 1,
                      type := "T_REFLVAR" ) ],
              type := "T_ATOMIC" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
#@fi

# T_BREAK
gap> testit(function(x) repeat break; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_BREAK" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_CONTINUE
gap> testit(function(x) repeat continue; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "T_CONTINUE" ) ],
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_REPEAT" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_RETURN_OBJ
gap> testit(function(x) return 42; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_INTEXPR",
                  value := 42 ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_RETURN_VOID
gap> testit(function(x) return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_LVAR
gap> testit(function(x) x := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              lvar := 1,
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_LVAR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_LVAR
gap> testit(function(x) Unbind(x); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              lvar := 1,
              type := "T_UNB_LVAR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_HVAR
gap> testit(x -> function(y) x := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  nams := [ "y" ],
                  narg := 1,
                  nloc := 0,
                  stats := rec(
                      statements := [ rec(
                              hvar := 65537,
                              rhs := rec(
                                  type := "T_INTEXPR",
                                  value := 1 ),
                              type := "T_ASS_HVAR" ), rec(
                              type := "T_RETURN_VOID" ) ],
                      type := "T_SEQ_STAT2" ),
                  type := "T_FUNC_EXPR",
                  variadic := false ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_HVAR
gap> testit(x -> function(y) Unbind(x); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  nams := [ "y" ],
                  narg := 1,
                  nloc := 0,
                  stats := rec(
                      statements := [ rec(
                              hvar := 65537,
                              type := "T_UNB_HVAR" ), rec(
                              type := "T_RETURN_VOID" ) ],
                      type := "T_SEQ_STAT2" ),
                  type := "T_FUNC_EXPR",
                  variadic := false ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_GVAR
gap> testit(function(x) testit := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              gvar := "testit",
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_GVAR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_GVAR
gap> testit(function(x) Unbind(testit); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              gvar := "testit",
              type := "T_UNB_GVAR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_LIST
gap> testit(function(x) x[42] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              pos := rec(
                  type := "T_INTEXPR",
                  value := 42 ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_LIST" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS2_LIST
gap> testit(function(x) x[42,23] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              pos := rec(
                  type := "T_INTEXPR",
                  value := 42 ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 23 ),
              type := "T_ASS2_LIST" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASSS_LIST
gap> testit(function(x) x{[42]} := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              poss := rec(
                  list := [ rec(
                          type := "T_INTEXPR",
                          value := 42 ) ],
                  type := "T_LIST_EXPR" ),
              rhss := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASSS_LIST" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_LIST_LEV
gap> testit(function(x) x{[42]}[23] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              level := 1,
              lists := rec(
                  list := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  poss := rec(
                      list := [ rec(
                              type := "T_INTEXPR",
                              value := 42 ) ],
                      type := "T_LIST_EXPR" ),
                  type := "T_ELMS_LIST" ),
              pos := rec(
                  type := "T_INTEXPR",
                  value := 23 ),
              rhss := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_LIST_LEV" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASSS_LIST_LEV
gap> testit(function(x) x{[42]}{[23]} := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              level := 1,
              lists := rec(
                  list := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  poss := rec(
                      list := [ rec(
                              type := "T_INTEXPR",
                              value := 42 ) ],
                      type := "T_LIST_EXPR" ),
                  type := "T_ELMS_LIST" ),
              poss := rec(
                  list := [ rec(
                          type := "T_INTEXPR",
                          value := 23 ) ],
                  type := "T_LIST_EXPR" ),
              rhss := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASSS_LIST_LEV" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_LIST
gap> testit(function(x) Unbind(x[42]); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              pos := rec(
                  type := "T_INTEXPR",
                  value := 42 ),
              type := "T_UNB_LIST" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_REC_NAME
gap> testit(function(x) x.abc := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              record := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              rnam := "abc",
              type := "T_ASS_REC_NAME" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_REC_EXPR
gap> testit(function(x) x.("x") := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              expression := rec(
                  type := "T_STRING_EXPR",
                  value := "x" ),
              record := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_REC_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) x.(1) := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              expression := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              record := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_REC_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_REC_NAME
gap> testit(function(x) Unbind(x.abc); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              record := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rnam := "abc",
              type := "T_UNB_REC_NAME" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_REC_EXPR
gap> testit(function(x) Unbind(x.("x")); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              expression := rec(
                  type := "T_STRING_EXPR",
                  value := "x" ),
              record := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_UNB_REC_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) Unbind(x.(1)); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              expression := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              record := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_UNB_REC_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_POSOBJ
gap> testit(function(x) x![42] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              pos := rec(
                  type := "T_INTEXPR",
                  value := 42 ),
              posobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_POSOBJ" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_POSOBJ
gap> testit(function(x) Unbind(x![42]); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              pos := rec(
                  type := "T_INTEXPR",
                  value := 42 ),
              posobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_UNB_POSOBJ" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_COMOBJ_NAME
gap> testit(function(x) x!.abc := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rnam := "abc",
              type := "T_ASS_COMOBJ_NAME" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASS_COMOBJ_EXPR
gap> testit(function(x) x!.("x") := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              expression := rec(
                  type := "T_STRING_EXPR",
                  value := "x" ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_COMOBJ_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) x!.(1) := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              expression := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              rhs := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_ASS_COMOBJ_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_COMOBJ_NAME
gap> testit(function(x) Unbind(x!.abc); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              rnam := "abc",
              type := "T_UNB_COMOBJ_NAME" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_UNB_COMOBJ_EXPR
gap> testit(function(x) Unbind(x!.("x")); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              expression := rec(
                  type := "T_STRING_EXPR",
                  value := "x" ),
              type := "T_UNB_COMOBJ_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(x) Unbind(x!.(1)); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              expression := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_UNB_COMOBJ_EXPR" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_INFO
gap> testit(function(x) Info(1, "test"); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [  ],
              lev := rec(
                  type := "T_STRING_EXPR",
                  value := "test" ),
              sel := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_INFO" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASSERT_2ARGS
gap> testit(function(x) Assert(0, true); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              level := rec(
                  type := "T_INTEXPR",
                  value := 0 ),
              type := "T_ASSERT_2ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ASSERT_3ARGS
gap> testit(function(x) Assert(0, true, "message"); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              condition := rec(
                  type := "T_TRUE_EXPR" ),
              level := rec(
                  type := "T_INTEXPR",
                  value := 0 ),
              message := rec(
                  type := "T_STRING_EXPR",
                  value := "message" ),
              type := "T_ASSERT_3ARGS" ), rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT2" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

#
# expressions
#

#
# T_FUNCCALL_0ARGS
gap> testit(x -> x());
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [  ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_0ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_1ARGS
gap> testit(x -> x(1));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_1ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_2ARGS
gap> testit(x -> x(1,2));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_2ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_3ARGS
gap> testit(x -> x(1,2,3));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ), rec(
                          type := "T_INTEXPR",
                          value := 3 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_3ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_4ARGS
gap> testit(x -> x(1,2,3,4));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ), rec(
                          type := "T_INTEXPR",
                          value := 3 ), rec(
                          type := "T_INTEXPR",
                          value := 4 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_4ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_5ARGS
gap> testit(x -> x(1,2,3,4,5));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ), rec(
                          type := "T_INTEXPR",
                          value := 3 ), rec(
                          type := "T_INTEXPR",
                          value := 4 ), rec(
                          type := "T_INTEXPR",
                          value := 5 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_5ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_6ARGS
gap> testit(x -> x(1,2,3,4,5,6));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ), rec(
                          type := "T_INTEXPR",
                          value := 3 ), rec(
                          type := "T_INTEXPR",
                          value := 4 ), rec(
                          type := "T_INTEXPR",
                          value := 5 ), rec(
                          type := "T_INTEXPR",
                          value := 6 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_6ARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_XARGS
gap> testit(x -> x(1,2,3,4,5,6,7));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ), rec(
                          type := "T_INTEXPR",
                          value := 3 ), rec(
                          type := "T_INTEXPR",
                          value := 4 ), rec(
                          type := "T_INTEXPR",
                          value := 5 ), rec(
                          type := "T_INTEXPR",
                          value := 6 ), rec(
                          type := "T_INTEXPR",
                          value := 7 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_FUNCCALL_XARGS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNC_EXPR
gap> testit(function(x) local y, z; end);
rec(
  nams := [ "x", "y", "z" ],
  narg := 1,
  nloc := 2,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(function(arg) end);
rec(
  nams := [ "arg" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := true )
true
gap> testit(function(x,y...) end);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := true )
true
gap> testit(function(x1,x2,x3,x4,x5,x6,x7,x8,x9) end);
rec(
  nams := [ "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9" ],
  narg := 9,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "T_RETURN_VOID" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> y -> [x,y]); # nested functions
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  nams := [ "y" ],
                  narg := 1,
                  nloc := 0,
                  stats := rec(
                      statements := [ rec(
                              obj := rec(
                                  list := [ rec(
                                          hvar := 65537,
                                          type := "T_REF_HVAR" ), rec(
                                          lvar := 1,
                                          type := "T_REFLVAR" ) ],
                                  type := "T_LIST_EXPR" ),
                              type := "T_RETURN_OBJ" ) ],
                      type := "T_SEQ_STAT" ),
                  type := "T_FUNC_EXPR",
                  variadic := false ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FUNCCALL_OPTS
gap> testit(x -> x(1 : opt));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  call := rec(
                      args := [ rec(
                              type := "T_INTEXPR",
                              value := 1 ) ],
                      funcref := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ),
                      type := "T_FUNCCALL_1ARGS" ),
                  opts := rec(
                      keyvalue := [ rec(
                              key := "opt",
                              value := rec(
                                  type := "T_TRUE_EXPR" ) ) ],
                      type := "T_REC_EXPR" ),
                  type := "T_FUNCCALL_OPTS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> x(1 : opt := 42));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  call := rec(
                      args := [ rec(
                              type := "T_INTEXPR",
                              value := 1 ) ],
                      funcref := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ),
                      type := "T_FUNCCALL_1ARGS" ),
                  opts := rec(
                      keyvalue := [ rec(
                              key := "opt",
                              value := rec(
                                  type := "T_INTEXPR",
                                  value := 42 ) ) ],
                      type := "T_REC_EXPR" ),
                  type := "T_FUNCCALL_OPTS" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_OR
gap> testit({x,y} -> x or y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_OR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_AND
gap> testit({x,y} -> x and y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_AND" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_NOT
gap> testit(x -> not x);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  op := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_NOT" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_EQ
gap> testit({x,y} -> x = y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_EQ" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_NE
gap> testit({x,y} -> x <> y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_NE" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_LT
gap> testit({x,y} -> x < y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_LT" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_GE
gap> testit({x,y} -> x >= y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_GE" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_GT
gap> testit({x,y} -> x > y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_GT" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_LE
gap> testit({x,y} -> x <= y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_LE" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_IN
gap> testit({x,y} -> x in y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_IN" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_SUM
gap> testit({x,y} -> x + y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_SUM" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_AINV
gap> testit(x -> -x);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  op := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_AINV" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_DIFF
gap> testit({x,y} -> x - y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_DIFF" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PROD
gap> testit({x,y} -> x * y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_PROD" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_QUO
gap> testit({x,y} -> x / y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_QUO" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_MOD
gap> testit({x,y} -> x mod y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_MOD" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_POW
gap> testit({x,y} -> x ^ y);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  left := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "T_REFLVAR" ),
                  type := "T_POW" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_INTEXPR
gap> testit(x -> 1);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_INTEXPR",
                  value := 1 ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_INT_EXPR
gap> testit(x -> 12345678901234567890);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_INT_EXPR",
                  value := 12345678901234567890 ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_TRUE_EXPR
gap> testit(x -> true);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_TRUE_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FALSE_EXPR
gap> testit(x -> false);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_FALSE_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_TILDE_EXPR
gap> [ testit(x -> ~) ];
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_TILDE_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
[ true ]

# T_CHAR_EXPR
gap> testit(x -> 'a');
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_CHAR_EXPR",
                  value := 'a' ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_PERM_EXPR
# T_PERM_CYCLE
gap> testit(x -> (1,2)(3,4,5));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  cycles := [ rec(
                          points := [ rec(
                                  type := "T_INTEXPR",
                                  value := 1 ), rec(
                                  type := "T_INTEXPR",
                                  value := 2 ) ],
                          type := "T_PERM_CYCLE" ), rec(
                          points := [ rec(
                                  type := "T_INTEXPR",
                                  value := 3 ), rec(
                                  type := "T_INTEXPR",
                                  value := 4 ), rec(
                                  type := "T_INTEXPR",
                                  value := 5 ) ],
                          type := "T_PERM_CYCLE" ) ],
                  type := "T_PERM_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_LIST_EXPR
gap> testit(x -> []);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [  ],
                  type := "T_LIST_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> [1,2]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [ rec(
                          type := "T_INTEXPR",
                          value := 1 ), rec(
                          type := "T_INTEXPR",
                          value := 2 ) ],
                  type := "T_LIST_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_LIST_TILDE_EXPR
gap> testit(x -> [~]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [ rec(
                          type := "T_TILDE_EXPR" ) ],
                  type := "T_LIST_TILDE_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_RANGE_EXPR
gap> testit(x -> [1..x]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  first := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  last := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_RANGE_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_STRING_EXPR
gap> testit(x -> "abc");
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_STRING_EXPR",
                  value := "abc" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_REC_EXPR
gap> testit(x -> rec( abc := 1 ));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  keyvalue := [ rec(
                          key := "abc",
                          value := rec(
                              type := "T_INTEXPR",
                              value := 1 ) ) ],
                  type := "T_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> rec( (x) := 1 ));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  keyvalue := [ rec(
                          key := rec(
                              lvar := 1,
                              type := "T_REFLVAR" ),
                          value := rec(
                              type := "T_INTEXPR",
                              value := 1 ) ) ],
                  type := "T_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> rec( ("abc") := 1 ));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  keyvalue := [ rec(
                          key := rec(
                              type := "T_STRING_EXPR",
                              value := "abc" ),
                          value := rec(
                              type := "T_INTEXPR",
                              value := 1 ) ) ],
                  type := "T_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> rec( (1) := 1 )); # this gets optimized
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  keyvalue := [ rec(
                          key := "1",
                          value := rec(
                              type := "T_INTEXPR",
                              value := 1 ) ) ],
                  type := "T_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_REC_TILDE_EXPR
gap> testit(x -> [~]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [ rec(
                          type := "T_TILDE_EXPR" ) ],
                  type := "T_LIST_TILDE_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FLOAT_EXPR_EAGER
gap> testit(x -> 1.0_);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_FLOAT_EXPR_EAGER",
                  value := 1 ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_FLOAT_EXPR_LAZY
gap> testit(x -> 1.0);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "T_FLOAT_EXPR_LAZY",
                  value := "1.0" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_REFLVAR
gap> testit(x -> x);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  lvar := 1,
                  type := "T_REFLVAR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_LVAR
gap> testit(x -> IsBound(x));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  lvar := 1,
                  type := "T_ISB_LVAR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_REF_HVAR
gap> testit(x -> y -> x);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  nams := [ "y" ],
                  narg := 1,
                  nloc := 0,
                  stats := rec(
                      statements := [ rec(
                              obj := rec(
                                  hvar := 65537,
                                  type := "T_REF_HVAR" ),
                              type := "T_RETURN_OBJ" ) ],
                      type := "T_SEQ_STAT" ),
                  type := "T_FUNC_EXPR",
                  variadic := false ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_HVAR
gap> testit(x -> y -> IsBound(x));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  nams := [ "y" ],
                  narg := 1,
                  nloc := 0,
                  stats := rec(
                      statements := [ rec(
                              obj := rec(
                                  hvar := 65537,
                                  type := "T_ISB_HVAR" ),
                              type := "T_RETURN_OBJ" ) ],
                      type := "T_SEQ_STAT" ),
                  type := "T_FUNC_EXPR",
                  variadic := false ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_REF_GVAR
gap> testit(x -> testit);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  gvar := "testit",
                  type := "T_REF_GVAR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_GVAR
gap> testit(x -> IsBound(testit));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  gvar := "testit",
                  type := "T_ISB_GVAR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_LIST
gap> testit(x -> x[42]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  pos := rec(
                      type := "T_INTEXPR",
                      value := 42 ),
                  type := "T_ELM_LIST" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM2_LIST
gap> testit(x -> x[42,23]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  pos1 := rec(
                      type := "T_INTEXPR",
                      value := 42 ),
                  pos2 := rec(
                      type := "T_INTEXPR",
                      value := 23 ),
                  type := "T_ELM2_LIST" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELMS_LIST
gap> testit(x -> x{[42]});
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  poss := rec(
                      list := [ rec(
                              type := "T_INTEXPR",
                              value := 42 ) ],
                      type := "T_LIST_EXPR" ),
                  type := "T_ELMS_LIST" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_LIST_LEV
gap> testit(x -> x{[42]}[23]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  level := rec(
                      type := "T_INTEXPR",
                      value := 0 ),
                  lists := rec(
                      list := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ),
                      poss := rec(
                          list := [ rec(
                                  type := "T_INTEXPR",
                                  value := 42 ) ],
                          type := "T_LIST_EXPR" ),
                      type := "T_ELMS_LIST" ),
                  pos := rec(
                      type := "T_INTEXPR",
                      value := 23 ),
                  type := "T_ELM_LIST_LEV" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELMS_LIST_LEV
gap> testit(x -> x{[42]}{[23]});
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  level := rec(
                      type := "T_INTEXPR",
                      value := 0 ),
                  lists := rec(
                      list := rec(
                          lvar := 1,
                          type := "T_REFLVAR" ),
                      poss := rec(
                          list := [ rec(
                                  type := "T_INTEXPR",
                                  value := 42 ) ],
                          type := "T_LIST_EXPR" ),
                      type := "T_ELMS_LIST" ),
                  poss := rec(
                      list := [ rec(
                              type := "T_INTEXPR",
                              value := 23 ) ],
                      type := "T_LIST_EXPR" ),
                  type := "T_ELMS_LIST_LEV" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_LIST
gap> testit(x -> IsBound(x[42]));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  pos := rec(
                      type := "T_INTEXPR",
                      value := 42 ),
                  type := "T_ISB_LIST" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_REC_NAME
gap> testit(x -> x.abc);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  name := "abc",
                  record := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ELM_REC_NAME" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_REC_EXPR
gap> testit(x -> x.("x"));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  expression := rec(
                      type := "T_STRING_EXPR",
                      value := "x" ),
                  record := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ELM_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> x.(1));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  expression := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  record := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ELM_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_REC_NAME
gap> testit(x -> IsBound(x.abc));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  name := "abc",
                  record := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ISB_REC_NAME" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_REC_EXPR
gap> testit(x -> IsBound(x.("x")));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  expression := rec(
                      type := "T_STRING_EXPR",
                      value := "x" ),
                  record := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ISB_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> IsBound(x.(1)));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  expression := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  record := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ISB_REC_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_POSOBJ
gap> testit(x -> x![42]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  pos := rec(
                      type := "T_INTEXPR",
                      value := 42 ),
                  posobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ELM_POSOBJ" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_POSOBJ
gap> testit(x -> IsBound(x![42]));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  pos := rec(
                      type := "T_INTEXPR",
                      value := 42 ),
                  posobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  type := "T_ISB_POSOBJ" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_COMOBJ_NAME
gap> testit(x -> x!.abc);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  comobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  name := "abc",
                  type := "T_ELM_COMOBJ_NAME" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ELM_COMOBJ_EXPR
gap> testit(x -> x!.("x"));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  comobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  expression := rec(
                      type := "T_STRING_EXPR",
                      value := "x" ),
                  type := "T_ELM_COMOBJ_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> x!.(1));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  comobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  expression := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  type := "T_ELM_COMOBJ_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_COMOBJ_NAME
gap> testit(x -> IsBound(x!.abc));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  comobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  name := "abc",
                  type := "T_ISB_COMOBJ_NAME" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true

# T_ISB_COMOBJ_EXPR
gap> testit(x -> IsBound(x!.("x")));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  comobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  expression := rec(
                      type := "T_STRING_EXPR",
                      value := "x" ),
                  type := "T_ISB_COMOBJ_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
gap> testit(x -> IsBound(x!.(1)));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  comobj := rec(
                      lvar := 1,
                      type := "T_REFLVAR" ),
                  expression := rec(
                      type := "T_INTEXPR",
                      value := 1 ),
                  type := "T_ISB_COMOBJ_EXPR" ),
              type := "T_RETURN_OBJ" ) ],
      type := "T_SEQ_STAT" ),
  type := "T_FUNC_EXPR",
  variadic := false )
true
