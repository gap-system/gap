
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
gap> test_tree := function( f )
>       local curr_tree, new_func, new_tree;
>       curr_tree := SYNTAX_TREE( f );
>       new_func := SYNTAX_TREE_CODE( curr_tree );
>       new_tree := SYNTAX_TREE( new_func );
>       return new_tree = curr_tree;
> end;;

# Just try compiling all functions we can find in the workspace
# to see nothing crashes.
gap> for n in NamesGVars() do
>        if IsBoundGlobal(n) and not IsAutoGlobal(n) then
>            v := ValueGlobal(n);
>            if IsFunction(v) and not IsKernelFunction(v) then
>                if not test_tree(v) then
>                   Print("failed round trip: ",n,"\n");
>                fi;
>            elif IsOperation(v) then
>                for i in [1..6] do
>                    for x in METHODS_OPERATION(v, i) do
>                        if IsFunction(x) and not IsKernelFunction(v) then
>                            if not test_tree(v) then
>                                Print("METHODS_OPERATION(", n, ",", i, ") failed round trip\n");
>                            fi;
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
>   return test_tree( f );
> end;;

# STAT_PROCCALL_0ARGS
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
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_0ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_1ARGS
gap> testit(function(x) x(1); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_1ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_2ARGS
gap> testit(function(x) x(1,2); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ), rec(
                      type := "EXPR_INT",
                      value := 2 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_2ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_3ARGS
gap> testit(function(x) x(1,2,3); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ), rec(
                      type := "EXPR_INT",
                      value := 2 ), rec(
                      type := "EXPR_INT",
                      value := 3 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_3ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_4ARGS
gap> testit(function(x) x(1,2,3,4); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ), rec(
                      type := "EXPR_INT",
                      value := 2 ), rec(
                      type := "EXPR_INT",
                      value := 3 ), rec(
                      type := "EXPR_INT",
                      value := 4 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_4ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_5ARGS
gap> testit(function(x) x(1,2,3,4,5); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ), rec(
                      type := "EXPR_INT",
                      value := 2 ), rec(
                      type := "EXPR_INT",
                      value := 3 ), rec(
                      type := "EXPR_INT",
                      value := 4 ), rec(
                      type := "EXPR_INT",
                      value := 5 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_5ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_6ARGS
gap> testit(function(x) x(1,2,3,4,5,6); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ), rec(
                      type := "EXPR_INT",
                      value := 2 ), rec(
                      type := "EXPR_INT",
                      value := 3 ), rec(
                      type := "EXPR_INT",
                      value := 4 ), rec(
                      type := "EXPR_INT",
                      value := 5 ), rec(
                      type := "EXPR_INT",
                      value := 6 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_6ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_XARGS
gap> testit(function(x) x(1,2,3,4,5,6,7); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [ rec(
                      type := "EXPR_INT",
                      value := 1 ), rec(
                      type := "EXPR_INT",
                      value := 2 ), rec(
                      type := "EXPR_INT",
                      value := 3 ), rec(
                      type := "EXPR_INT",
                      value := 4 ), rec(
                      type := "EXPR_INT",
                      value := 5 ), rec(
                      type := "EXPR_INT",
                      value := 6 ), rec(
                      type := "EXPR_INT",
                      value := 7 ) ],
              funcref := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_PROCCALL_XARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_PROCCALL_OPTS
gap> testit(function(x) x(1 : opt); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              call := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "STAT_PROCCALL_1ARGS" ),
              opts := rec(
                  keyvalue := [ rec(
                          key := "opt",
                          value := rec(
                              type := "EXPR_TRUE" ) ) ],
                  type := "EXPR_REC" ),
              type := "STAT_PROCCALL_OPTS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                          type := "EXPR_INT",
                          value := 1 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "STAT_PROCCALL_1ARGS" ),
              opts := rec(
                  keyvalue := [ rec(
                          key := "opt",
                          value := rec(
                              type := "EXPR_INT",
                              value := 42 ) ) ],
                  type := "EXPR_REC" ),
              type := "STAT_PROCCALL_OPTS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_EMPTY
gap> testit(function(x) ; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_EMPTY" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT
gap> testit(function(x) return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ), rec(
                                  type := "STAT_RETURN_VOID" ) ],
                          type := "STAT_SEQ_STAT" ),
                      condition := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ) ) ],
              type := "STAT_IF" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT2
gap> testit(function(x) return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT3
gap> testit(function(x) return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT3" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT4
gap> testit(function(x) return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT4" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT5
gap> testit(function(x) return; return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT5" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT6
gap> testit(function(x) return; return; return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT6" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_SEQ_STAT7
gap> testit(function(x) return; return; return; return; return; return; return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT7" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# 
# STAT_IF
# STAT_IF_ELSE
# STAT_IF_ELIF
# STAT_IF_ELIF_ELSE
gap> testit(function(x) if x then fi; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              branches := [ rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ) ) ],
              type := "STAT_IF" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          type := "EXPR_TRUE" ) ) ],
              type := "STAT_IF_ELSE" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 2,
                          type := "EXPR_REF_LVAR" ) ) ],
              type := "STAT_IF_ELIF" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 2,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          type := "EXPR_TRUE" ) ) ],
              type := "STAT_IF_ELIF_ELSE" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 2,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          lvar := 3,
                          type := "EXPR_REF_LVAR" ) ), rec(
                      body := rec(
                          type := "STAT_EMPTY" ),
                      condition := rec(
                          type := "EXPR_TRUE" ) ) ],
              type := "STAT_IF_ELIF_ELSE" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_FOR
# STAT_FOR2
# STAT_FOR3
gap> testit(function(x) for x in x do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "STAT_EMPTY" ) ],
              collection := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_FOR",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ) ],
              collection := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_FOR",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              collection := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_FOR2",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              collection := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_FOR3",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ) ],
                      type := "STAT_SEQ_STAT4" ) ],
              collection := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_FOR",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_FOR_RANGE
# STAT_FOR_RANGE2
# STAT_FOR_RANGE3
gap> testit(function(x) for x in [1..2] do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "STAT_EMPTY" ) ],
              collection := rec(
                  first := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  last := rec(
                      type := "EXPR_INT",
                      value := 2 ),
                  type := "EXPR_RANGE" ),
              type := "STAT_FOR_RANGE",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ) ],
              collection := rec(
                  first := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  last := rec(
                      type := "EXPR_INT",
                      value := 2 ),
                  type := "EXPR_RANGE" ),
              type := "STAT_FOR_RANGE",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              collection := rec(
                  first := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  last := rec(
                      type := "EXPR_INT",
                      value := 2 ),
                  type := "EXPR_RANGE" ),
              type := "STAT_FOR_RANGE2",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              collection := rec(
                  first := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  last := rec(
                      type := "EXPR_INT",
                      value := 2 ),
                  type := "EXPR_RANGE" ),
              type := "STAT_FOR_RANGE3",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ) ],
                      type := "STAT_SEQ_STAT4" ) ],
              collection := rec(
                  first := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  last := rec(
                      type := "EXPR_INT",
                      value := 2 ),
                  type := "EXPR_RANGE" ),
              type := "STAT_FOR_RANGE",
              variable := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ) ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_WHILE
# STAT_WHILE2
# STAT_WHILE3
gap> testit(function(x) while true do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "STAT_EMPTY" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_WHILE" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_WHILE" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_WHILE2" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_WHILE3" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ) ],
                      type := "STAT_SEQ_STAT4" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_WHILE" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_REPEAT
# STAT_REPEAT2
# STAT_REPEAT3
gap> testit(function(x) repeat until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "STAT_EMPTY" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT2" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ), rec(
                      type := "STAT_RETURN_VOID" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT3" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ), rec(
                              type := "STAT_RETURN_VOID" ) ],
                      type := "STAT_SEQ_STAT4" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ATOMIC
#@if IsHPCGAP
gap> testit(function(x) atomic x do od; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := rec(
                  type := "STAT_EMPTY" ),
              locks := [ rec(
                      type := "EXPR_INT",
                      value := 0 ), rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ) ],
              type := "STAT_ATOMIC" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true
#@fi

# STAT_BREAK
gap> testit(function(x) repeat break; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "STAT_BREAK" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_CONTINUE
gap> testit(function(x) repeat continue; until true; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              body := [ rec(
                      type := "STAT_CONTINUE" ) ],
              condition := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_REPEAT" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_RETURN_OBJ
gap> testit(function(x) return 42; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_INT",
                  value := 42 ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_RETURN_VOID
gap> testit(function(x) return; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_LVAR
gap> testit(function(x) x := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              lvar := 1,
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_LVAR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_LVAR
gap> testit(function(x) Unbind(x); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              lvar := 1,
              type := "STAT_UNB_LVAR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_HVAR
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
                                  type := "EXPR_INT",
                                  value := 1 ),
                              type := "STAT_ASS_HVAR" ), rec(
                              type := "STAT_RETURN_VOID" ) ],
                      type := "STAT_SEQ_STAT2" ),
                  type := "EXPR_FUNC",
                  variadic := false ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_HVAR
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
                              type := "STAT_UNB_HVAR" ), rec(
                              type := "STAT_RETURN_VOID" ) ],
                      type := "STAT_SEQ_STAT2" ),
                  type := "EXPR_FUNC",
                  variadic := false ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_GVAR
gap> testit(function(x) testit := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              gvar := "testit",
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_GVAR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_GVAR
gap> testit(function(x) Unbind(testit); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              gvar := "testit",
              type := "STAT_UNB_GVAR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_LIST
gap> testit(function(x) x[42] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              pos := rec(
                  type := "EXPR_INT",
                  value := 42 ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_LIST" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_MAT
gap> testit(function(x) x[42,23] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              col := rec(
                  type := "EXPR_INT",
                  value := 23 ),
              list := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              row := rec(
                  type := "EXPR_INT",
                  value := 42 ),
              type := "STAT_ASS_MAT" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASSS_LIST
gap> testit(function(x) x{[42]} := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              poss := rec(
                  list := [ rec(
                          type := "EXPR_INT",
                          value := 42 ) ],
                  type := "EXPR_LIST" ),
              rhss := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASSS_LIST" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_LIST_LEV
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
                      type := "EXPR_REF_LVAR" ),
                  poss := rec(
                      list := [ rec(
                              type := "EXPR_INT",
                              value := 42 ) ],
                      type := "EXPR_LIST" ),
                  type := "EXPR_ELMS_LIST" ),
              pos := rec(
                  type := "EXPR_INT",
                  value := 23 ),
              rhss := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_LIST_LEV" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASSS_LIST_LEV
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
                      type := "EXPR_REF_LVAR" ),
                  poss := rec(
                      list := [ rec(
                              type := "EXPR_INT",
                              value := 42 ) ],
                      type := "EXPR_LIST" ),
                  type := "EXPR_ELMS_LIST" ),
              poss := rec(
                  list := [ rec(
                          type := "EXPR_INT",
                          value := 23 ) ],
                  type := "EXPR_LIST" ),
              rhss := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASSS_LIST_LEV" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_LIST
gap> testit(function(x) Unbind(x[42]); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              list := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              pos := rec(
                  type := "EXPR_INT",
                  value := 42 ),
              type := "STAT_UNB_LIST" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_REC_NAME
gap> testit(function(x) x.abc := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              record := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              rnam := "abc",
              type := "STAT_ASS_REC_NAME" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_REC_EXPR
gap> testit(function(x) x.("x") := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              expression := rec(
                  type := "EXPR_STRING",
                  value := "x" ),
              record := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_REC_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                  type := "EXPR_INT",
                  value := 1 ),
              record := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_REC_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_REC_NAME
gap> testit(function(x) Unbind(x.abc); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              record := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rnam := "abc",
              type := "STAT_UNB_REC_NAME" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_REC_EXPR
gap> testit(function(x) Unbind(x.("x")); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              expression := rec(
                  type := "EXPR_STRING",
                  value := "x" ),
              record := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_UNB_REC_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                  type := "EXPR_INT",
                  value := 1 ),
              record := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_UNB_REC_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_POSOBJ
gap> testit(function(x) x![42] := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              pos := rec(
                  type := "EXPR_INT",
                  value := 42 ),
              posobj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_POSOBJ" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_POSOBJ
gap> testit(function(x) Unbind(x![42]); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              pos := rec(
                  type := "EXPR_INT",
                  value := 42 ),
              posobj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_UNB_POSOBJ" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_COMOBJ_NAME
gap> testit(function(x) x!.abc := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              rnam := "abc",
              type := "STAT_ASS_COMOBJ_NAME" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASS_COMOBJ_EXPR
gap> testit(function(x) x!.("x") := 1; end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              expression := rec(
                  type := "EXPR_STRING",
                  value := "x" ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_COMOBJ_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                  type := "EXPR_REF_LVAR" ),
              expression := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              rhs := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_ASS_COMOBJ_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_COMOBJ_NAME
gap> testit(function(x) Unbind(x!.abc); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              rnam := "abc",
              type := "STAT_UNB_COMOBJ_NAME" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_UNB_COMOBJ_EXPR
gap> testit(function(x) Unbind(x!.("x")); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              comobj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              expression := rec(
                  type := "EXPR_STRING",
                  value := "x" ),
              type := "STAT_UNB_COMOBJ_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
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
                  type := "EXPR_REF_LVAR" ),
              expression := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_UNB_COMOBJ_EXPR" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_INFO
gap> testit(function(x) Info(1, "test"); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              args := [  ],
              lev := rec(
                  type := "EXPR_STRING",
                  value := "test" ),
              sel := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_INFO" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASSERT_2ARGS
gap> testit(function(x) Assert(0, true); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              condition := rec(
                  type := "EXPR_TRUE" ),
              level := rec(
                  type := "EXPR_INT",
                  value := 0 ),
              type := "STAT_ASSERT_2ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# STAT_ASSERT_3ARGS
gap> testit(function(x) Assert(0, true, "message"); end);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              condition := rec(
                  type := "EXPR_TRUE" ),
              level := rec(
                  type := "EXPR_INT",
                  value := 0 ),
              message := rec(
                  type := "EXPR_STRING",
                  value := "message" ),
              type := "STAT_ASSERT_3ARGS" ), rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT2" ),
  type := "EXPR_FUNC",
  variadic := false )
true

#
# expressions
#

#
# EXPR_FUNCCALL_0ARGS
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
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_0ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_1ARGS
gap> testit(x -> x(1));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_1ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_2ARGS
gap> testit(x -> x(1,2));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_2ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_3ARGS
gap> testit(x -> x(1,2,3));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ), rec(
                          type := "EXPR_INT",
                          value := 3 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_3ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_4ARGS
gap> testit(x -> x(1,2,3,4));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ), rec(
                          type := "EXPR_INT",
                          value := 3 ), rec(
                          type := "EXPR_INT",
                          value := 4 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_4ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_5ARGS
gap> testit(x -> x(1,2,3,4,5));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ), rec(
                          type := "EXPR_INT",
                          value := 3 ), rec(
                          type := "EXPR_INT",
                          value := 4 ), rec(
                          type := "EXPR_INT",
                          value := 5 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_5ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_6ARGS
gap> testit(x -> x(1,2,3,4,5,6));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ), rec(
                          type := "EXPR_INT",
                          value := 3 ), rec(
                          type := "EXPR_INT",
                          value := 4 ), rec(
                          type := "EXPR_INT",
                          value := 5 ), rec(
                          type := "EXPR_INT",
                          value := 6 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_6ARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_XARGS
gap> testit(x -> x(1,2,3,4,5,6,7));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  args := [ rec(
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ), rec(
                          type := "EXPR_INT",
                          value := 3 ), rec(
                          type := "EXPR_INT",
                          value := 4 ), rec(
                          type := "EXPR_INT",
                          value := 5 ), rec(
                          type := "EXPR_INT",
                          value := 6 ), rec(
                          type := "EXPR_INT",
                          value := 7 ) ],
                  funcref := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_FUNCCALL_XARGS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNC
gap> testit(function(x) local y, z; end);
rec(
  nams := [ "x", "y", "z" ],
  narg := 1,
  nloc := 2,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true
gap> testit(function(arg) end);
rec(
  nams := [ "arg" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := true )
true
gap> testit(function(x,y...) end);
rec(
  nams := [ "x", "y" ],
  narg := 2,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := true )
true
gap> testit(function(x1,x2,x3,x4,x5,x6,x7,x8,x9) end);
rec(
  nams := [ "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9" ],
  narg := 9,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              type := "STAT_RETURN_VOID" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                                          type := "EXPR_REF_HVAR" ), rec(
                                          lvar := 1,
                                          type := "EXPR_REF_LVAR" ) ],
                                  type := "EXPR_LIST" ),
                              type := "STAT_RETURN_OBJ" ) ],
                      type := "STAT_SEQ_STAT" ),
                  type := "EXPR_FUNC",
                  variadic := false ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FUNCCALL_OPTS
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
                              type := "EXPR_INT",
                              value := 1 ) ],
                      funcref := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ),
                      type := "EXPR_FUNCCALL_1ARGS" ),
                  opts := rec(
                      keyvalue := [ rec(
                              key := "opt",
                              value := rec(
                                  type := "EXPR_TRUE" ) ) ],
                      type := "EXPR_REC" ),
                  type := "EXPR_FUNCCALL_OPTS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                              type := "EXPR_INT",
                              value := 1 ) ],
                      funcref := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ),
                      type := "EXPR_FUNCCALL_1ARGS" ),
                  opts := rec(
                      keyvalue := [ rec(
                              key := "opt",
                              value := rec(
                                  type := "EXPR_INT",
                                  value := 42 ) ) ],
                      type := "EXPR_REC" ),
                  type := "EXPR_FUNCCALL_OPTS" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_OR
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_OR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_AND
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_AND" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_NOT
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
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_NOT" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_EQ
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_EQ" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_NE
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_NE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_LT
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_LT" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_GE
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_GE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_GT
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_GT" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_LE
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_LE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_IN
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_IN" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_SUM
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_SUM" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_AINV
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
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_AINV" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_DIFF
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_DIFF" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_PROD
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_PROD" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_QUO
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_QUO" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_MOD
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_MOD" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_POW
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
                      type := "EXPR_REF_LVAR" ),
                  right := rec(
                      lvar := 2,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_POW" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_INT
gap> testit(x -> 1);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_INT",
                  value := 1 ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_INTPOS
gap> testit(x -> 12345678901234567890);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_INTPOS",
                  value := 12345678901234567890 ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_TRUE
gap> testit(x -> true);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_TRUE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FALSE
gap> testit(x -> false);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_FALSE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_TILDE
gap> [ testit(x -> ~) ];
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_TILDE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
[ true ]

# EXPR_CHAR
gap> testit(x -> 'a');
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_CHAR",
                  value := 'a' ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_PERM
# EXPR_PERM_CYCLE
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
                                  type := "EXPR_INT",
                                  value := 1 ), rec(
                                  type := "EXPR_INT",
                                  value := 2 ) ],
                          type := "EXPR_PERM_CYCLE" ), rec(
                          points := [ rec(
                                  type := "EXPR_INT",
                                  value := 3 ), rec(
                                  type := "EXPR_INT",
                                  value := 4 ), rec(
                                  type := "EXPR_INT",
                                  value := 5 ) ],
                          type := "EXPR_PERM_CYCLE" ) ],
                  type := "EXPR_PERM" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_LIST
gap> testit(x -> []);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [  ],
                  type := "EXPR_LIST" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                          type := "EXPR_INT",
                          value := 1 ), rec(
                          type := "EXPR_INT",
                          value := 2 ) ],
                  type := "EXPR_LIST" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true
gap> testit( x -> [, [] ] );
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [ , rec(
                          list := [  ],
                          type := "EXPR_LIST" ) ],
                  type := "EXPR_LIST" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_LIST_TILDE
gap> testit(x -> [~]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [ rec(
                          type := "EXPR_TILDE" ) ],
                  type := "EXPR_LIST_TILDE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_RANGE
gap> testit(x -> [1..x]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  first := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  last := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_RANGE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_STRING
gap> testit(x -> "abc");
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_STRING",
                  value := "abc" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_REC
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
                              type := "EXPR_INT",
                              value := 1 ) ) ],
                  type := "EXPR_REC" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                              type := "EXPR_REF_LVAR" ),
                          value := rec(
                              type := "EXPR_INT",
                              value := 1 ) ) ],
                  type := "EXPR_REC" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                              type := "EXPR_STRING",
                              value := "abc" ),
                          value := rec(
                              type := "EXPR_INT",
                              value := 1 ) ) ],
                  type := "EXPR_REC" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                              type := "EXPR_INT",
                              value := 1 ) ) ],
                  type := "EXPR_REC" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_REC_TILDE
gap> testit(x -> [~]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  list := [ rec(
                          type := "EXPR_TILDE" ) ],
                  type := "EXPR_LIST_TILDE" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FLOAT_EAGER
gap> testit(x -> 1.0_);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  mark := '\000',
                  string := "1.0",
                  type := "EXPR_FLOAT_EAGER",
                  value := 1. ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_FLOAT_LAZY
gap> testit(x -> 1.0);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  type := "EXPR_FLOAT_LAZY",
                  value := "1.0" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_REF_LVAR
gap> testit(x -> x);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  lvar := 1,
                  type := "EXPR_REF_LVAR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_LVAR
gap> testit(x -> IsBound(x));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  lvar := 1,
                  type := "EXPR_ISB_LVAR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_REF_HVAR
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
                                  type := "EXPR_REF_HVAR" ),
                              type := "STAT_RETURN_OBJ" ) ],
                      type := "STAT_SEQ_STAT" ),
                  type := "EXPR_FUNC",
                  variadic := false ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_HVAR
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
                                  type := "EXPR_ISB_HVAR" ),
                              type := "STAT_RETURN_OBJ" ) ],
                      type := "STAT_SEQ_STAT" ),
                  type := "EXPR_FUNC",
                  variadic := false ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_REF_GVAR
gap> testit(x -> testit);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  gvar := "testit",
                  type := "EXPR_REF_GVAR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_GVAR
gap> testit(x -> IsBound(testit));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  gvar := "testit",
                  type := "EXPR_ISB_GVAR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_LIST
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
                      type := "EXPR_REF_LVAR" ),
                  pos := rec(
                      type := "EXPR_INT",
                      value := 42 ),
                  type := "EXPR_ELM_LIST" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_MAT
gap> testit(x -> x[42,23]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  col := rec(
                      type := "EXPR_INT",
                      value := 23 ),
                  list := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  row := rec(
                      type := "EXPR_INT",
                      value := 42 ),
                  type := "EXPR_ELM_MAT" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELMS_LIST
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
                      type := "EXPR_REF_LVAR" ),
                  poss := rec(
                      list := [ rec(
                              type := "EXPR_INT",
                              value := 42 ) ],
                      type := "EXPR_LIST" ),
                  type := "EXPR_ELMS_LIST" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_LIST_LEV
gap> testit(x -> x{[42]}[23]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  level := rec(
                      type := "EXPR_INT",
                      value := 0 ),
                  lists := rec(
                      list := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ),
                      poss := rec(
                          list := [ rec(
                                  type := "EXPR_INT",
                                  value := 42 ) ],
                          type := "EXPR_LIST" ),
                      type := "EXPR_ELMS_LIST" ),
                  pos := rec(
                      type := "EXPR_INT",
                      value := 23 ),
                  type := "EXPR_ELM_LIST_LEV" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELMS_LIST_LEV
gap> testit(x -> x{[42]}{[23]});
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  level := rec(
                      type := "EXPR_INT",
                      value := 0 ),
                  lists := rec(
                      list := rec(
                          lvar := 1,
                          type := "EXPR_REF_LVAR" ),
                      poss := rec(
                          list := [ rec(
                                  type := "EXPR_INT",
                                  value := 42 ) ],
                          type := "EXPR_LIST" ),
                      type := "EXPR_ELMS_LIST" ),
                  poss := rec(
                      list := [ rec(
                              type := "EXPR_INT",
                              value := 23 ) ],
                      type := "EXPR_LIST" ),
                  type := "EXPR_ELMS_LIST_LEV" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_LIST
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
                      type := "EXPR_REF_LVAR" ),
                  pos := rec(
                      type := "EXPR_INT",
                      value := 42 ),
                  type := "EXPR_ISB_LIST" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_REC_NAME
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
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ELM_REC_NAME" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_REC_EXPR
gap> testit(x -> x.("x"));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  expression := rec(
                      type := "EXPR_STRING",
                      value := "x" ),
                  record := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ELM_REC_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                      type := "EXPR_INT",
                      value := 1 ),
                  record := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ELM_REC_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_REC_NAME
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
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ISB_REC_NAME" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_REC_EXPR
gap> testit(x -> IsBound(x.("x")));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  expression := rec(
                      type := "EXPR_STRING",
                      value := "x" ),
                  record := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ISB_REC_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                      type := "EXPR_INT",
                      value := 1 ),
                  record := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ISB_REC_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_POSOBJ
gap> testit(x -> x![42]);
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  pos := rec(
                      type := "EXPR_INT",
                      value := 42 ),
                  posobj := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ELM_POSOBJ" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_POSOBJ
gap> testit(x -> IsBound(x![42]));
rec(
  nams := [ "x" ],
  narg := 1,
  nloc := 0,
  stats := rec(
      statements := [ rec(
              obj := rec(
                  pos := rec(
                      type := "EXPR_INT",
                      value := 42 ),
                  posobj := rec(
                      lvar := 1,
                      type := "EXPR_REF_LVAR" ),
                  type := "EXPR_ISB_POSOBJ" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_COMOBJ_NAME
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
                      type := "EXPR_REF_LVAR" ),
                  name := "abc",
                  type := "EXPR_ELM_COMOBJ_NAME" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ELM_COMOBJ_EXPR
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
                      type := "EXPR_REF_LVAR" ),
                  expression := rec(
                      type := "EXPR_STRING",
                      value := "x" ),
                  type := "EXPR_ELM_COMOBJ_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                      type := "EXPR_REF_LVAR" ),
                  expression := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  type := "EXPR_ELM_COMOBJ_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_COMOBJ_NAME
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
                      type := "EXPR_REF_LVAR" ),
                  name := "abc",
                  type := "EXPR_ISB_COMOBJ_NAME" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true

# EXPR_ISB_COMOBJ_EXPR
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
                      type := "EXPR_REF_LVAR" ),
                  expression := rec(
                      type := "EXPR_STRING",
                      value := "x" ),
                  type := "EXPR_ISB_COMOBJ_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
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
                      type := "EXPR_REF_LVAR" ),
                  expression := rec(
                      type := "EXPR_INT",
                      value := 1 ),
                  type := "EXPR_ISB_COMOBJ_EXPR" ),
              type := "STAT_RETURN_OBJ" ) ],
      type := "STAT_SEQ_STAT" ),
  type := "EXPR_FUNC",
  variadic := false )
true
