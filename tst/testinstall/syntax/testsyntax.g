# Test data for syntax trees

# values
expr_test1 := function()
    local x;
    x := true;
    x := false;
    x := 5;
    x := 500000000000000000000000000000;
    x := ' ';
    x := "Hello, world";
    x := (1,2,3);
    x := [1];
    x := [1..4];
    x := [1,3..5];
    x := rec( x := 4 );
    x := [ ~ ];
    x := rec( p := ~ );
end;;

# expressions involving operators
expr_test2 := function()
    local x, y, z;

    z := x or y;
    z := x and y;
    z := not x;
    z := x = y;
    z := x <> y;
    z := x < y;
    z := x > y;
    z := x <= y;
    z := x >= y;
    z := x in y;
    z := x + y;
    z := -x;
    z := x - y;
    z := x * y;
    z := x / y;
    z := 1/x;
    z := x mod y;
    z := x^y;
end;;

stat_test_if := function()
    local x;
    if true then
        return 0;
    fi;

    if true then
        return 0;
    else
        return 1;
    fi;

    if true then
        return 0;
    elif false then
        return 1;
    fi;

    if x = true then
        return 0;
    elif x = false then
        return 1;
    else
        return 2;
    fi;
end;;

stat_test_for := function()
    local i, j, l;

    for i in l do
        j := i;
    od;

    for i in l do
        j := i;
        j := i;
    od;

    for i in l do
        j := i;
        j := i;
        j := i;
        j := i;
    od;

    for i in [1..2] do
        j := i;
    od;

    for i in [1..2] do
        j := i;
        j := i;
    od;

    for i in [1..2] do
        j := i;
        j := i;
        j := i;
        j := i;
    od;
end;;

stat_test_while := function()
    local i;

    while true do
        i := 1;
    od;
    while true do
        i := 1;
        i := 1;
    od;
    while true do
        i := 1;
        i := 1;
        i := 1;
        i := 1;
    od;
end;;

stat_test_repeat := function()
    local i;

    repeat
        i := 1;
    until true;
    repeat
        i := 1;
        i := 1;
    until true;
    repeat
        i := 1;
        i := 1;
        i := 1;
        i := 1;
    until true;
end;;

stat_test_return_void := function()
    return;
end;;

stat_test_return_obj := function()
    return 4;
end;;

test_lvar := function()
    local i;

    i := 5;
    Unbind(i);
    # IsBound wants an LValue
    i := IsBound(i);
end;;

test_hvar := function()
    local i, f;
    i := 5;

    f := function()
        i := 6;
        Unbind(i);
        i := IsBound(i);
    end;
end;;

_syntaxtree_test_global := "";;
test_gvar := function()
    _syntaxtree_test_global := "hello";
    Unbind(_syntaxtree_test_global);
    _syntaxtree_test_global := IsBound(_syntaxtree_test_global);
end;;

test_list := function()
    local list;

    list := [];
    list[1] := "hello";
    Unbind(list[1]);
    list := IsBound(list[1]);

    list{[1,2,3]} := [1,2,3];

    list[1,2] := [2,3];
    list[1,2,'a'] := [1,2,3];

end;;

test_rec := function()
    local r;

    r := rec();

    r.a := 5;
    Unbind(r.a);
    r.a := IsBound(r.a);

    r.("bla") := 5;
    Unbind(r.("bla"));
    r.a := IsBound(r.("bla"));
end;;

test_comobj := function()
    local r;

    r := rec();

    r!.a := 5;
    Unbind(r!.a);
    r!.a := IsBound(r!.a);

    r.("bla") := 5;
    Unbind(r.("bla"));
    r.a := IsBound(r.("bla"));
end;;

test_posobj := function()
    local list;

    list := [];
    list![1] := "hello";
    Unbind(list![1]);
    list := IsBound(list![1]);

    list!{[1,2,3]} := [1,2,3];
end;;

test_funccall := function()
    local f, g;

    f := g();
    f();

    f := g(1);
    f(1);

    f := g(1,2);
    f(1,2);

    f := g(1,2,3,4,5,6,7,8);
    f(1,2,3,4,5,6,7,8);
end;

trees := List( [ expr_test1
               , expr_test2
               , stat_test_if
               , stat_test_for
               , stat_test_while
               , stat_test_repeat
               , stat_test_return_void
               , stat_test_return_obj
               , test_lvar
               , test_hvar
               , test_gvar
               , test_list
               , test_rec
               , test_comobj
               , test_posobj
               , test_funccall
               ], SYNTAX_TREE);;


# This list contains the expected syntax trees for the test
# data above
expect_trees := [
                  # expr_test1
                  rec( type := "T_FUNC_EXPR",
                       variadic := false,
                       argnams := [  ],
                       locnams := [ "x" ],
                       name := "expr_test1",
                       narg := 0,
                       nloc := 1,
                       stats := rec( statements := [ rec( lvar := 1,
                                                          rhs := rec( type := "T_TRUE_EXPR" ),
                                                          type := "T_ASS_LVAR" ),
                                                     rec( lvar := 1,
                                                          rhs := rec( type := "T_FALSE_EXPR" ),
                                                          type := "T_ASS_LVAR" ),
                                                     rec( lvar := 1,
                                                          rhs := rec( type := "T_INTEXPR",
                                                                      value := 5 ),
                                                          type := "T_ASS_LVAR" ),
                                                     rec( lvar := 1,
                                                          rhs := rec( type := "T_INT_EXPR",
                                                                      value := 500000000000000000000000000000 ),
                                                          type := "T_ASS_LVAR" ),
                                                     rec( lvar := 1,
                                                          rhs := rec( result := ' ',
                                                                      type := "T_CHAR_EXPR" ),
                                                          type := "T_ASS_LVAR" ),
                                                     rec( lvar := 1,
                                                          rhs := rec( string := "Hello, world",
                                                                      type := "T_STRING_EXPR" ),
                                                          type := "T_ASS_LVAR" ),
                                                     rec( statements := [ rec( lvar := 1,
                                                                               rhs := rec( cycles := [ [ rec( type := "T_INTEXPR", value := 1 ),
                                                                                                         rec( type := "T_INTEXPR", value := 2 ),
                                                                                                         rec( type := "T_INTEXPR", value := 3 ) ] ],
                                                                                           type := "T_PERM_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( lvar := 1,
                                                                               rhs := rec( list := [ rec( type := "T_INTEXPR", value := 1 ) ],
                                                                                           type := "T_LIST_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( lvar := 1,
                                                                               rhs := rec( first := rec( type := "T_INTEXPR", value := 1 ),
                                                                                           last := rec( type := "T_INTEXPR", value := 4 ),
                                                                                           type := "T_RANGE_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( lvar := 1,
                                                                               rhs := rec( first := rec( type := "T_INTEXPR", value := 1 ),
                                                                                           second := rec( type := "T_INTEXPR", value := 3 ),
                                                                                           last := rec( type := "T_INTEXPR", value := 5 ),
                                                                                           type := "T_RANGE_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( lvar := 1,
                                                                               rhs := rec( keyvalue := [ rec( key := "x",
                                                                                                              value := rec( type := "T_INTEXPR", value := 4 ) ) ],
                                                                                           type := "T_REC_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( lvar := 1,
                                                                               rhs := rec( list := [ rec( type := "T_TILDE_EXPR" ) ],
                                                                                           type := "T_LIST_TILD_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( lvar := 1,
                                                                               rhs := rec( type := "T_REC_TILD_EXPR" ),
                                                                               type := "T_ASS_LVAR" ),
                                                                          rec( type := "T_RETURN_VOID" ) ],
                                                          type := "T_SEQ_STAT" ) ],
                                     type := "T_SEQ_STAT7" ) ),
                  # expr_test2
                  rec( type := "T_FUNC_EXPR",
                       variadic := false,
                       argnams := [  ], locnams := [ "x", "y", "z" ], name := "expr_test2", narg := 0, nloc := 3, 
                       stats := rec( statements := [ rec( lvar := 3,
                                                          rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                      right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_OR" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( lvar := 3,
                                                          rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                      right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_AND" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( lvar := 3,
                                                          rhs := rec( op := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                      type := "T_NOT" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( lvar := 3,
                                                          rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                      right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_EQ" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( lvar := 3,
                                                          rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                      right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_NE" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( lvar := 3,
                                                          rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                      right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_LT" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( statements := [ rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_GT" ),
                                                                               type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ), 
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_LE" ),
                                                                               type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_GE" ),
                                                                               type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_IN" ),
                                                                               type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ), 
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_SUM" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( op := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           type := "T_AINV" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_DIFF" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_PROD" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_QUO" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( type := "T_INTEXPR", value := 1 ),
                                                                                           right := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           type := "T_QUO" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_MOD" ), type := "T_ASS_LVAR" ), 
                                                                          rec( lvar := 3,
                                                                               rhs := rec( left := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           right := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                           type := "T_POW" ), 
                                                                               type := "T_ASS_LVAR" ), 
                                                                          rec( type := "T_RETURN_VOID" ) ],
                                                          type := "T_SEQ_STAT" ) ],
                                     type := "T_SEQ_STAT7" )),
                  # stat_test_if
                  rec( type := "T_FUNC_EXPR",
                       variadic := false,
                       argnams := [  ], locnams := [ "x" ], name := "stat_test_if", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( branches := [ rec( condition := rec( type := "T_TRUE_EXPR" ), stats := rec( obj := rec( type := "T_INTEXPR", value := 0 ), type := "T_RETURN_OBJ" ) ) ], type := "T_IF" ), 
                                                     rec( branches := [ rec( condition := rec( type := "T_TRUE_EXPR" ), stats := rec( obj := rec( type := "T_INTEXPR", value := 0 ), type := "T_RETURN_OBJ" ) ), 
                                                                        rec( condition := rec( type := "T_TRUE_EXPR" ), stats := rec( obj := rec( type := "T_INTEXPR", value := 1 ), type := "T_RETURN_OBJ" ) ) ], type := "T_IF_ELSE" ), 
                                                     rec( branches := [ rec( condition := rec( type := "T_TRUE_EXPR" ), stats := rec( obj := rec( type := "T_INTEXPR", value := 0 ), type := "T_RETURN_OBJ" ) ), 
                                                                        rec( condition := rec( type := "T_FALSE_EXPR" ), stats := rec( obj := rec( type := "T_INTEXPR", value := 1 ), type := "T_RETURN_OBJ" ) ) ], type := "T_IF_ELIF" ), 
                                                     rec( branches := [ rec( condition := rec( left := rec( lvar := 1, type := "T_REFLVAR" ), right := rec( type := "T_TRUE_EXPR" ), type := "T_EQ" ), 
                                                                           stats := rec( obj := rec( type := "T_INTEXPR", value := 0 ), type := "T_RETURN_OBJ" ) ), 
                                                                        rec( condition := rec( left := rec( lvar := 1, type := "T_REFLVAR" ), right := rec( type := "T_FALSE_EXPR" ), type := "T_EQ" ), 
                                                                           stats := rec( obj := rec( type := "T_INTEXPR", value := 1 ), type := "T_RETURN_OBJ" ) ), 
                                                                        rec( condition := rec( type := "T_TRUE_EXPR" ), stats := rec( obj := rec( type := "T_INTEXPR", value := 2 ), type := "T_RETURN_OBJ" ) ) ], type := "T_IF_ELIF_ELSE" ), 
                                                     rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT5" )),

                  # stat_test_for
                  rec( argnams := [  ], locnams := [ "i", "j", "l" ], name := "stat_test_for", narg := 0, nloc := 3, 
                       stats := rec( statements := [ rec( body := [ rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),, ], collection := rec( lvar := 3, type := "T_REFLVAR" ), type := "T_FOR", 
                                                          variable := rec( lvar := 1, type := "T_REFLVAR" ) ), 
                                                     rec( body := [ rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ), rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),, ], 
                                                          collection := rec( lvar := 3, type := "T_REFLVAR" ), type := "T_FOR2", variable := rec( lvar := 1, type := "T_REFLVAR" ) ), 
                                                     rec( body := [ rec( statements := [ rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ), 
                                                                                         rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ) ],
                                                                         type := "T_SEQ_STAT4" ),, ],
                                                          collection := rec( lvar := 3, type := "T_REFLVAR" ), type := "T_FOR", variable := rec( lvar := 1, type := "T_REFLVAR" ) ), 
                                                     rec( body := [ rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),, ],
                                                          collection := rec( first := rec( type := "T_INTEXPR", value := 1 ), 
                                                                             last := rec( type := "T_INTEXPR", value := 2 ),
                                                                             type := "T_RANGE_EXPR" ), 
                                                          type := "T_FOR_RANGE",
                                                          variable := rec( lvar := 1, type := "T_REFLVAR" ) ), 
                                                     rec( body := [ rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),
                                                                    rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),, ], 
                                                          collection := rec( first := rec( type := "T_INTEXPR", value := 1 ),
                                                                             last := rec( type := "T_INTEXPR", value := 2 ),
                                                                             type := "T_RANGE_EXPR" ),
                                                          type := "T_FOR_RANGE2", 
                                                          variable := rec( lvar := 1, type := "T_REFLVAR" ) ), 
                                                     rec( body := [ rec( statements := [ rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ), 
                                                                                         rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 2, rhs := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ASS_LVAR" ) ], 
                                                                         type := "T_SEQ_STAT4" ),, ],
                                                          collection := rec( first := rec( type := "T_INTEXPR", value := 1 ),
                                                                             last := rec( type := "T_INTEXPR", value := 2 ),
                                                                             type := "T_RANGE_EXPR" ), 
                                                          type := "T_FOR_RANGE",
                                                          variable := rec( lvar := 1, type := "T_REFLVAR" ) ),
                                                     rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT7" ),
                       type := "T_FUNC_EXPR",
                       variadic := false ),
                  # stat_test_while
                  rec( argnams := [  ], locnams := [ "i" ], name := "stat_test_while", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( body := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ) ],
                                                          condition := rec( type := "T_TRUE_EXPR" ),
                                                          type := "T_WHILE" ), 
                                                     rec( body := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ), rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ) ], 
                                                          condition := rec( type := "T_TRUE_EXPR" ),
                                                          type := "T_WHILE2" ), 
                                                     rec( body := [ rec( statements := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                                         rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ) ], 
                                                                         type := "T_SEQ_STAT4" ) ], condition := rec( type := "T_TRUE_EXPR" ),
                                                          type := "T_WHILE" ), rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT4" ),
                       type := "T_FUNC_EXPR",
                       variadic := false ),

                  # stat_test_repeat
                  rec( argnams := [  ], locnams := [ "i" ], name := "stat_test_repeat", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( body := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ), ],
                                                          condition := rec( type := "T_TRUE_EXPR" ),
                                                          type := "T_REPEAT" ), 
                                                     rec( body := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                    rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ), ], 
                                                          condition := rec( type := "T_TRUE_EXPR" ),
                                                          type := "T_REPEAT2" ), 
                                                     rec( body :=  [ rec( statements := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                                          rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                                          rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ),
                                                                                          rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 1 ), type := "T_ASS_LVAR" ) ], 
                                                                          type := "T_SEQ_STAT4" ), ],
                                                          condition := rec( type := "T_TRUE_EXPR" ), 
                                                          type := "T_REPEAT" ),
                                                     rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT4" ),
                       type := "T_FUNC_EXPR", 
                       variadic := false ),
                  # return
                  rec( argnams := [  ], locnams := [  ], name := "stat_test_return_void", narg := 0, nloc := 0,
                       stats := rec( statements := [ rec( type := "T_RETURN_VOID" ) ],
                                     type := "T_SEQ_STAT" ), 
                       type := "T_FUNC_EXPR", variadic := false ),
                  rec( argnams := [  ], locnams := [  ], name := "stat_test_return_obj", narg := 0, nloc := 0,
                       stats := rec( statements := [ rec( obj := rec( type := "T_INTEXPR", value := 4 ), type := "T_RETURN_OBJ" ) ], 
                                     type := "T_SEQ_STAT" ), 
                       type := "T_FUNC_EXPR", variadic := false ),
                  
                  # local variables
                  rec( argnams := [  ], locnams := [ "i" ], name := "test_lvar", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 5 ), type := "T_ASS_LVAR" ),
                                                     rec( lvar := 1, type := "T_UNB_LVAR" ),
                                                     rec( lvar := 1, rhs := rec( lvar := 1, type := "T_ISB_LVAR" ), type := "T_ASS_LVAR" ),
                                                     rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT4" ),
                       type := "T_FUNC_EXPR", variadic := false ),

                  # higher variables
                  rec( argnams := [  ], locnams := [ "i", "f" ], name := "test_hvar", narg := 0, nloc := 2, 
                       stats := rec( statements := [ rec( lvar := 1, rhs := rec( type := "T_INTEXPR", value := 5 ), type := "T_ASS_LVAR" ), 
                                                     rec( lvar := 2, rhs := rec( argnams := [  ], locnams := [  ], narg := 0, nloc := 0, 
                                                                                 stats := rec( statements := [ rec( hvar := 65537, rhs := rec( type := "T_INTEXPR", value := 6 ), type := "T_ASS_HVAR" ),
                                                                                                               rec( hvar := 65537, type := "T_UNB_HVAR" ), 
                                                                                                               rec( hvar := 65537, rhs := rec( hvar := 65537, type := "T_ISB_HVAR" ), type := "T_ASS_HVAR" ),
                                                                                                               rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT4" ),
                                                                                 type := "T_FUNC_EXPR", variadic := false ), type := "T_ASS_LVAR" ),
                                                     rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT3" ),
                       type := "T_FUNC_EXPR", variadic := false ),

                  # global variables
                  rec( argnams := [  ], locnams := [  ], name := "test_gvar", narg := 0, nloc := 0, 
                       stats := rec( statements := [ rec( gvar := "_syntaxtree_test_global",
                                                          rhs := rec( string := "hello",
                                                                      type := "T_STRING_EXPR" ),
                                                          type := "T_ASS_GVAR" ), 
                                                     rec( gvar := "_syntaxtree_test_global",
                                                          type := "T_UNB_GVAR" ), 
                                                     rec( gvar := "_syntaxtree_test_global",
                                                          rhs := rec( gvar := "_syntaxtree_test_global",
                                                                      type := "T_ISB_GVAR" ),
                                                          type := "T_ASS_GVAR" ),
                                                     rec( type := "T_RETURN_VOID" ) ],
                                     type := "T_SEQ_STAT4" ),
                       type := "T_FUNC_EXPR", variadic := false ),
 
                  # lists
                  rec( argnams := [  ], locnams := [ "list" ], name := "test_list", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( lvar := 1, rhs := rec( list := [  ], type := "T_LIST_EXPR" ), type := "T_ASS_LVAR" ), 
                                                     rec( list := rec( lvar := 1, type := "T_REFLVAR" ), pos := rec( type := "T_INTEXPR", value := 1 ), rhs := rec( string := "hello", type := "T_STRING_EXPR" ), type := "T_ASS_LIST" ), 
                                                     rec( list := rec( lvar := 1, type := "T_REFLVAR" ), pos := rec( type := "T_INTEXPR", value := 1 ), type := "T_UNB_LIST" ), 
                                                     rec( lvar := 1, rhs := rec( list := rec( lvar := 1, type := "T_REFLVAR" ), pos := rec( type := "T_INTEXPR", value := 1 ), type := "T_ISB_LIST" ), type := "T_ASS_LVAR" ), 
                                                     rec( list := rec( lvar := 1, type := "T_REFLVAR" ),
                                                          poss := rec( list := [ rec( type := "T_INTEXPR", value := 1 ),
                                                                                 rec( type := "T_INTEXPR", value := 2 ),
                                                                                 rec( type := "T_INTEXPR", value := 3 ) ], 
                                                                       type := "T_LIST_EXPR" ),
                                                          rhss := rec( list := [ rec( type := "T_INTEXPR", value := 1 ),
                                                                                 rec( type := "T_INTEXPR", value := 2 ),
                                                                                 rec( type := "T_INTEXPR", value := 3 ) ],
                                                                       type := "T_LIST_EXPR" )
                                                          , type := "T_ASSS_LIST" ),
                                                     rec( type := "T_RETURN_VOID" ) ],
                                     type := "T_SEQ_STAT6" ),
                       type := "T_FUNC_EXPR", variadic := false ),
                  
                  # records
                  rec( argnams := [  ], locnams := [ "r" ], name := "test_rec", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( lvar := 1, rhs := rec( keyvalue := [  ], type := "T_REC_EXPR" ), type := "T_ASS_LVAR" ), 
                                                     rec( record := rec( lvar := 1, type := "T_REFLVAR" ), rhs := rec( type := "T_INTEXPR", value := 5 ), rnam := "a", type := "T_ASS_REC_NAME" ), 
                                                     rec( record := rec( lvar := 1, type := "T_REFLVAR" ), rnam := "a", type := "T_UNB_REC_NAME" ), 
                                                     rec( record := rec( lvar := 1, type := "T_REFLVAR" ), rhs := rec( name := "a", record := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_ISB_REC_NAME" ), rnam := "a", type := "T_ASS_REC_NAME" ), 
                                                     rec( expression := rec( string := "bla", type := "T_STRING_EXPR" ), record := rec( lvar := 1, type := "T_REFLVAR" ), rhs := rec( type := "T_INTEXPR", value := 5 ), type := "T_ASS_REC_EXPR" ), 
                                                     rec( expression := rec( string := "bla", type := "T_STRING_EXPR" ), record := rec( lvar := 1, type := "T_REFLVAR" ), type := "T_UNB_REC_EXPR" ), 
                                                     rec( statements := [ rec( record := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                               rhs := rec( expression := rec( string := "bla", type := "T_STRING_EXPR" ),
                                                                                           record := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                                           type := "T_ISB_REC_EXPR" ), rnam := "a", type := "T_ASS_REC_NAME" ),
                                                                          rec( type := "T_RETURN_VOID" ) ], type := "T_SEQ_STAT2" ) ],
                                     type := "T_SEQ_STAT7" ),
                       type := "T_FUNC_EXPR", variadic := false ),

                  # component objects
                  rec( argnams := [  ], locnams := [ "r" ], name := "test_comobj", narg := 0, nloc := 1, 
                       stats := rec( statements := [ rec( lvar := 1, rhs := rec( keyvalue := [  ], type := "T_REC_EXPR" ), type := "T_ASS_LVAR" ),
                                                     rec( comobj := rec( lvar := 1, type := "T_REFLVAR" ), rnam := "a", type := "T_ASS_COMOBJ_NAME" ),
                                                     rec( comobj := rec( lvar := 1, type := "T_REFLVAR" ), name := rec( type := "T_INTEXPR", value := 12 ), type := "T_UNB_COMOBJ_NAME" ), 
                                                     rec( comobj := rec( lvar := 1, type := "T_REFLVAR" ), rnam := "a", type := "T_ASS_COMOBJ_NAME" ),
                                                     rec( expression := rec( string := "bla", type := "T_STRING_EXPR" ),
                                                          record := rec( lvar := 1,
                                                                         type := "T_REFLVAR" ),
                                                          rhs := rec( type := "T_INTEXPR", 
                                                                      value := 5 ),
                                                          type := "T_ASS_REC_EXPR" ),
                                                     rec( expression := rec( string := "bla",
                                                                             type := "T_STRING_EXPR" ), 
                                                          record := rec( lvar := 1,
                                                                         type := "T_REFLVAR" ),
                                                          type := "T_UNB_REC_EXPR" ), 
                                                     rec( statements := [ rec( record := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                               rhs := rec( expression := rec( string := "bla",
                                                                                                              type := "T_STRING_EXPR" ),
                                                                                           record := rec( lvar := 1,
                                                                                                          type := "T_REFLVAR" ), 
                                                                                           type := "T_ISB_REC_EXPR" ),
                                                                               rnam := "a",
                                                                               type := "T_ASS_REC_NAME" ),
                                                                          rec( type := "T_RETURN_VOID" ) ],
                                                          type := "T_SEQ_STAT2" ) ],
                                     type := "T_SEQ_STAT7" ),
                       type := "T_FUNC_EXPR", 
                       variadic := false ),
                  
                  # positional object
                  rec( argnams := [  ],
                       locnams := [ "list" ],
                       name := "test_posobj",
                       narg := 0,
                       nloc := 1, 
                       stats := rec( statements := [ rec( lvar := 1,
                                                          rhs := rec( list := [  ],
                                                                      type := "T_LIST_EXPR" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( pos := rec( type := "T_INTEXPR",
                                                                      value := 1 ),
                                                          posobj := rec( lvar := 1, 
                                                                         type := "T_REFLVAR" ),
                                                          rhs := rec( string := "hello",
                                                                      type := "T_STRING_EXPR" ),
                                                          type := "T_ASS_POSOBJ" ), 
                                                     rec( pos := rec( type := "T_INTEXPR",
                                                                      value := 1 ),
                                                          posobj := rec( lvar := 1,
                                                                         type := "T_REFLVAR" ),
                                                          type := "T_UNB_POSOBJ" ), 
                                                     rec( lvar := 1,
                                                          rhs := rec( pos := rec( type := "T_INTEXPR",
                                                                                  value := 1 ),
                                                                         posobj := rec( lvar := 1,
                                                                                        type := "T_REFLVAR" ),
                                                                         type := "T_ISB_POSOBJ" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( posobj := rec( lvar := 1,
                                                                         type := "T_REFLVAR" ),
                                                          poss := rec( list := [ rec( type := "T_INTEXPR",
                                                                                      value := 1 ),
                                                                                 rec( type := "T_INTEXPR",
                                                                                      value := 2 ),
                                                                                 rec( type := "T_INTEXPR",
                                                                                      value := 3 ) ], 
                                                                       type := "T_LIST_EXPR" ),
                                                          rhss := rec( list := [ rec( type := "T_INTEXPR",
                                                                                      value := 1 ),
                                                                                 rec( type := "T_INTEXPR",
                                                                                      value := 2 ),
                                                                                 rec( type := "T_INTEXPR",
                                                                                      value := 3 ) ],
                                                                       type := "T_LIST_EXPR" )
                                                          , type := "T_ASSS_POSOBJ" ),
                                                     rec( type := "T_RETURN_VOID" ) ],
                                     type := "T_SEQ_STAT6" ),
                       type := "T_FUNC_EXPR",
                       variadic := false ),
                  rec( argnams := [  ],
                       locnams := [ "f", "g" ],
                       name := "test_funccall",
                       narg := 0,
                       nloc := 2, 
                       stats := rec( statements := [ rec( lvar := 1,
                                                          rhs := rec( args := [  ],
                                                                      funcref := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_FUNCCALL_0ARGS" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( args := [  ],
                                                          funcref := rec( lvar := 1, type := "T_REFLVAR" ),
                                                          type := "T_PROCCALL_0ARGS" ), 
                                                     rec( lvar := 1,
                                                          rhs := rec( args := [ rec( type := "T_INTEXPR", value := 1 ) ],
                                                                      funcref := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_FUNCCALL_1ARGS" ),
                                                          type := "T_ASS_LVAR" ), 
                                                     rec( args := [ rec( type := "T_INTEXPR", value := 1 ) ],
                                                          funcref := rec( lvar := 1, type := "T_REFLVAR" ),
                                                          type := "T_PROCCALL_1ARGS" ), 
                                                     rec( lvar := 1,
                                                          rhs := rec( args := [ rec( type := "T_INTEXPR", value := 1 ), rec( type := "T_INTEXPR", value := 2 ) ],
                                                                      funcref := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                      type := "T_FUNCCALL_2ARGS" ), 
                                                          type := "T_ASS_LVAR" ),
                                                     rec( args := [ rec( type := "T_INTEXPR", value := 1 ), rec( type := "T_INTEXPR", value := 2 ) ],
                                                          funcref := rec( lvar := 1, type := "T_REFLVAR" ), 
                                                          type := "T_PROCCALL_2ARGS" ), 
                                                     rec( statements := [ 
                                                              rec( lvar := 1, rhs := rec( args := [ rec( type := "T_INTEXPR", value := 1 ),
                                                                                                    rec( type := "T_INTEXPR", value := 2 ),
                                                                                                    rec( type := "T_INTEXPR", value := 3 ), 
                                                                                                    rec( type := "T_INTEXPR", value := 4 ),
                                                                                                    rec( type := "T_INTEXPR", value := 5 ),
                                                                                                    rec( type := "T_INTEXPR", value := 6 ),
                                                                                                    rec( type := "T_INTEXPR", value := 7 ),
                                                                                                    rec( type := "T_INTEXPR", value := 8 ) ],
                                                                                          funcref := rec( lvar := 2, type := "T_REFLVAR" ),
                                                                                          type := "T_FUNCCALL_XARGS" ),
                                                                   type := "T_ASS_LVAR" ), 
                                                              rec( args := [ rec( type := "T_INTEXPR", value := 1 ),
                                                                             rec( type := "T_INTEXPR", value := 2 ),
                                                                             rec( type := "T_INTEXPR", value := 3 ),
                                                                             rec( type := "T_INTEXPR", value := 4 ), 
                                                                             rec( type := "T_INTEXPR", value := 5 ),
                                                                             rec( type := "T_INTEXPR", value := 6 ),
                                                                             rec( type := "T_INTEXPR", value := 7 ),
                                                                             rec( type := "T_INTEXPR", value := 8 ) ], 
                                                                   funcref := rec( lvar := 1, type := "T_REFLVAR" ),
                                                                   type := "T_PROCCALL_XARGS" ),
                                                              rec( type := "T_RETURN_VOID" ) ],
                                                          type := "T_SEQ_STAT3" ) ],
                                     type := "T_SEQ_STAT7" ),
                       type := "T_FUNC_EXPR",
                       variadic := false )
                 ];
