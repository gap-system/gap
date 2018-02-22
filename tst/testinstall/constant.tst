# create a plain global var and perform some test
gap> testvar := 2;
2
gap> IsReadOnlyGlobal(testvar);
Error, CheckGlobalName: the argument must be a string
gap> IsReadOnlyGlobal("testvar");
false
gap> IsConstantGlobal("testvar");
false

# make the global var readonly and perform some test
gap> MakeReadOnlyGlobal("testvar");
gap> IsReadOnlyGlobal("testvar");
true
gap> IsConstantGlobal("testvar");
false
gap> testvar := 3;
Error, Variable: 'testvar' is read only

# make the global var readwrite again and perform some test
gap> MakeReadWriteGlobal("testvar");
gap> IsReadOnlyGlobal("testvar");
false
gap> IsConstantGlobal("testvar");
false
gap> testvar := 3;
3

# make the global var constant and perform some test
gap> MakeConstantGlobal("testvar");
gap> testvar := 4;
Error, Variable: 'testvar' is constant
gap> IsReadOnlyGlobal("testvar");
false
gap> IsConstantGlobal("testvar");
true
gap> IsBound(testvar);
true
gap> Unbind(testvar);
Error, Variable: 'testvar' is constant

# Try making a global var constants whose value is not eligible
gap> newtestvar := fail;;
gap> MakeConstantGlobal("newtestvar");
Error, Variable: 'newtestvar' must be assigned a small integer, true or false
gap> IsConstantGlobal("newtestvar");
false

# some more tests with constant gvars with boolean value
gap> booltruevar := true;;
gap> boolfalsevar := false;;
gap> f := function()
> if booltruevar then return 1; else return 2; fi;
> if booltruevar then return 3; fi;
> if boolfalsevar then return 4; else return 5; fi;
> if boolfalsevar then return 6; fi;
> if booltruevar then return 7; elif 1=2 then return 8; else return 9; fi;
> if boolfalsevar then return 10; elif booltruevar then return 11; else return 12; fi;
> end;;
gap> Print(f,"\n");
function (  )
    if booltruevar then
        return 1;
    else
        return 2;
    fi;
    if booltruevar then
        return 3;
    fi;
    if boolfalsevar then
        return 4;
    else
        return 5;
    fi;
    if boolfalsevar then
        return 6;
    fi;
    if booltruevar then
        return 7;
    elif 1 = 2 then
        return 8;
    else
        return 9;
    fi;
    if boolfalsevar then
        return 10;
    elif booltruevar then
        return 11;
    else
        return 12;
    fi;
    return;
end
gap> MakeConstantGlobal("booltruevar");
gap> MakeConstantGlobal("boolfalsevar");
gap> Print(f,"\n");
function (  )
    if booltruevar then
        return 1;
    else
        return 2;
    fi;
    if booltruevar then
        return 3;
    fi;
    if boolfalsevar then
        return 4;
    else
        return 5;
    fi;
    if boolfalsevar then
        return 6;
    fi;
    if booltruevar then
        return 7;
    elif 1 = 2 then
        return 8;
    else
        return 9;
    fi;
    if boolfalsevar then
        return 10;
    elif booltruevar then
        return 11;
    else
        return 12;
    fi;
    return;
end
gap> f := function()
> if booltruevar then return 1; else return 2; fi;
> if booltruevar then return 3; fi;
> if boolfalsevar then return 4; else return 5; fi;
> if boolfalsevar then return 6; fi;
> if booltruevar then return 7; elif 1=2 then return 8; else return 9; fi;
> if boolfalsevar then return 10; elif booltruevar then return 11; else return 12; fi;
> end;;
gap> Print(f, "\n");
function (  )
    return 1;
    return 3;
    return 5;
    ;
    return 7;
    return 11;
end
gap> (function() if booltruevar then return 1; fi; return 2; end)();
1
gap> (function() if boolfalsevar then return 1; fi; return 2; end)();
2
gap> (function() if booltruevar then return 1; else return 2; fi; end)();
1
gap> (function() if boolfalsevar then return 1; else return 2; fi; end)();
2
gap> (function() if boolfalsevar then return 1; elif booltruevar then return 2; else return 3; fi; end)();
2
gap> (function() if boolfalsevar then return 1; elif boolfalsevar then return 2; else return 3; fi; end)();
3
gap> BindConstant("constx", 3);
gap> constx;
3
gap> BindConstant("constx", 3);
gap> BindConstant("constx", 4);
Error, Variable: 'constx' is constant
gap> BindConstant("constx", true);
Error, Variable: 'constx' is constant
gap> BindConstant("consty", true);
gap> consty;
true
gap> BindConstant("constz", false);
gap> constz;
false
gap> BindConstant(23, 3);
Error, CheckGlobalName: the argument must be a string
gap> BindConstant( (1,2), 3);
Error, CheckGlobalName: the argument must be a string
