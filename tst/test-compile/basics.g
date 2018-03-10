# Test all kinds of basic features of the compiler, e.g.
# whether it compiles constants correctly.

#
# test handling of integer constants of various sizes
#
test_int_constants := function()
    local x, y;

    # integer constants < 2^28
    x := 10^5;
    Print(x, "\n");
    y := 100000;
    Print(y, "\n");
    Print(x = y, "\n");

    # integer constants between 2^28 and 2^60
    x := 10^10;
    Print(x, "\n");
    y := 10000000000;
    Print(y, "\n");
    Print(x = y, "\n");

    # integer constants > 2^60
    x := 10^20;
    Print(x, "\n");
    y := 100000000000000000000;
    Print(y, "\n");
    Print(x = y, "\n");
end;


#
# Test calls to functions with 0 to 6 args, and >= 6 args
#
test_func_calls := function()
    local vararg_fun;

    # vararg function
    vararg_fun := function(args...)
        return Length(args);
    end;

    #
    # function calls
    #
    Print(vararg_fun(), "\n");
    Print(vararg_fun(1), "\n");
    Print(vararg_fun(1,2), "\n");
    Print(vararg_fun(1,2,3), "\n");
    Print(vararg_fun(1,2,3,4), "\n");
    Print(vararg_fun(1,2,3,4,5), "\n");
    Print(vararg_fun(1,2,3,4,5,6), "\n");
    Print(vararg_fun(1,2,3,4,5,6,7), "\n");
    # note that immediate integer arguments are treated differently,
    # so test with other args, too
    Print(vararg_fun("x",true,vararg_fun,4,5,6,7), "\n");

    # test function call with options
    Print(vararg_fun(:myopt), "\n");
    Print(vararg_fun(:myopt:="value"), "\n");

    # FIXME: the following legal code triggers a bug in GAC!
#     Print(vararg_fun(:("myopt")), "\n");
#     Print(vararg_fun(:("myopt"):="value"), "\n");


    #
    # procedure calls (i.e. func calls as statements)
    #
    vararg_fun := function(args...)
        Display(Length(args));
    end;
    vararg_fun();
    vararg_fun(1);
    vararg_fun(1,2);
    vararg_fun(1,2,3);
    vararg_fun(1,2,3,4);
    vararg_fun(1,2,3,4,5);
    vararg_fun(1,2,3,4,5,6);
    vararg_fun(1,2,3,4,5,6,7);
    # note that immediate integer arguments are treated differently,
    # so test with other args, too
    vararg_fun("x",true,vararg_fun,4,5,6,7);

    # test function call with options
    vararg_fun(:myopt);
    vararg_fun(:myopt:="value");

    # FIXME: the following legal code triggers a bug in GAC!
#     vararg_fun(:("myopt"));
#     vararg_fun(:("myopt"):="value");

end;


#
# tests for binary operators '=', '<>', '<', '<=', '>', '>=', each
# once compared as an independent expression (which returns the GAP
# objects 'True' or 'False'), and once as condition in an 'if'
# (which avoids use of 'True' and 'False'). Also test optimizations
# for immediate integers args
#
test_cmp_ops := function()
    local x;

    Print("setting x to 2 ...\n");
    x := 2;

    # =
    Print("1 = 2 is ", 1 = 2, "\n");
    Print("1 = x is ", 1 = x, "\n");
    Print("1 = 2 via if is "); if 1 = 2 then Print("true\n"); else Print("false\n"); fi;
    Print("1 = x via if is "); if 1 = x then Print("true\n"); else Print("false\n"); fi;

    # <>
    Print("1 <> 2 is ", 1 <> 2, "\n");
    Print("1 <> x is ", 1 <> x, "\n");
    Print("1 <> 2 via if is "); if 1 <> 2 then Print("true\n"); else Print("false\n"); fi;
    Print("1 <> x via if is "); if 1 <> x then Print("true\n"); else Print("false\n"); fi;

    # <
    Print("1 < 2 is ", 1 < 2, "\n");
    Print("1 < x is ", 1 < x, "\n");
    Print("1 < 2 via if is "); if 1 < 2 then Print("true\n"); else Print("false\n"); fi;
    Print("1 < x via if is "); if 1 < x then Print("true\n"); else Print("false\n"); fi;

    # <=
    Print("1 <= 2 is ", 1 <= 2, "\n");
    Print("1 <= x is ", 1 <= x, "\n");
    Print("1 <= 2 via if is "); if 1 <= 2 then Print("true\n"); else Print("false\n"); fi;
    Print("1 <= x via if is "); if 1 <= x then Print("true\n"); else Print("false\n"); fi;

    # >
    Print("1 > 2 is ", 1 > 2, "\n");
    Print("1 > x is ", 1 > x, "\n");
    Print("1 > 2 via if is "); if 1 > 2 then Print("true\n"); else Print("false\n"); fi;
    Print("1 > x via if is "); if 1 > x then Print("true\n"); else Print("false\n"); fi;

    # >=
    Print("1 >= 2 is ", 1 >= 2, "\n");
    Print("1 >= x is ", 1 >= x, "\n");
    Print("1 >= 2 via if is "); if 1 >= 2 then Print("true\n"); else Print("false\n"); fi;
    Print("1 >= x via if is "); if 1 >= x then Print("true\n"); else Print("false\n"); fi;
end;


#
# arithmetic tests
#
test_arith := function()
    local x;

    # additive inverse
    x := 5;
    x := -x;
    x := 1/2;
    x := -x;
end;


#
# test tilde expressions
#
test_tilde := function()
    local x;

# FIXME: handling of tilde expressions is currently broken in gac
#
#     # list tilde expression
#     x := [~];
#     Display(x);
#
#     # record tilde expression
#     x := rec( next := ~);
#     Display(x);
#
#     # tilde expression
#     x := [ [ 1, 2 ], ~[ 1 ] ];
#     Display(x);
end;


#
#
#
test_list_rec_exprs := function()
    local x;

    Display( [ ] );
    Display( [ 1, 2, 3 ] );
    Display( [ 1, , 3, [ 4, 5 ], rec( x := [ 6, rec(), ] ) ] );

    x := rec(a:=1);
    x.b := 2;
    x.("c") := x.a + x.("b");
    Display(x);
    Print("x.a = ", x.a, "\n");
    Print("x.b = ", x.("b"), "\n");
end;


#
# IsBound / Unbind
#
myglobal := 1;
test_IsBound_Unbind := function()
    local x;

    #
    Print("Testing IsBound and Unbind for lvar\n");
    x := 42;
    Display(IsBound(x));
    Unbind(x);
    Display(IsBound(x));

    #
    Print("Testing IsBound and Unbind for gvar\n");
    myglobal := 42;
    Display(IsBound(myglobal));
    Unbind(myglobal);
    Display(IsBound(myglobal));

    #
    Print("Testing IsBound and Unbind for list\n");
    x := [1,2,3];
    Display(IsBound(x[2]));
    Unbind(x[2]);
    Display(IsBound(x[2]));

    #
    Print("Testing IsBound and Unbind for list with bang\n");
    x := [1,2,3];
    Display(IsBound(x![2]));
    Unbind(x![2]);
    Display(IsBound(x![2]));

    #
    Print("Testing IsBound and Unbind for record\n");
    x := rec( a := 1 );
    Display(IsBound(x.a));
    Unbind(x.a);
    Display(IsBound(x.a));

    #
    Print("Testing IsBound and Unbind for record with expr\n");
    x := rec( a := 1 );
    Display(IsBound(x.("a")));
    Unbind(x.("a"));
    Display(IsBound(x.("a")));

    #
    Print("Testing IsBound and Unbind for record with bang\n");
    x := rec( a := 1 );
    Display(IsBound(x!.a));
    Unbind(x!.a);
    Display(IsBound(x!.a));

    #
    Print("Testing IsBound and Unbind for record with bang and expr\n");
    x := rec( a := 1 );
    Display(IsBound(x!.("a")));
    Unbind(x!.("a"));
    Display(IsBound(x!.("a")));

end;


#
#
#
test_loops := function()
    local x;

    Display("testing repeat loop");
    x := 0;
    repeat
        x := x + 1;
        if x = 1 then
            continue;
        elif x = 4 then
            break;
        else
            Display(x);
        fi;
    until x >= 100;

    Display("testing while loop");
    x := 0;
    while x < 100 do
        x := x + 1;
        if x = 1 then
            continue;
        elif x = 4 then
            break;
        else
            Display(x);
        fi;
    od;

    Display("testing for loop");
    # for loop
    for x in [1..100] do
        if x = 1 then
            continue;
        elif x = 4 then
            break;
        else
            Display(x);
        fi;
    od;

end;


#
# run all tests
#
runtest := function()
    test_int_constants();
    test_func_calls();
    test_cmp_ops();
    test_arith();
    test_tilde();
    test_list_rec_exprs();
    test_IsBound_Unbind();
    test_loops();

    # test trivial permutation
    Display( () );
end;
