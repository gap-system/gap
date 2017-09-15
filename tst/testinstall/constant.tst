gap> testvar := 2;
2
gap> IsReadOnlyGlobal(testvar);
Error, CheckGlobalName: the argument must be a string
gap> IsReadOnlyGlobal("testvar");
false
gap> IsConstantGlobal("testvar");
false
gap> MakeReadOnlyGlobal("testvar");
gap> IsReadOnlyGlobal("testvar");
true
gap> IsConstantGlobal("testvar");
false
gap> testvar := 3;
Error, Variable: 'testvar' is read only
gap> MakeReadWriteGlobal("testvar");
gap> IsReadOnlyGlobal("testvar");
false
gap> IsConstantGlobal("testvar");
false
gap> testvar := 3;
3
gap> MakeConstantGlobal("testvar");
gap> testvar := 4;
Syntax error: ; expected in stream:1
testvar := 4;
         ^
4
gap> IsReadOnlyGlobal("testvar");
false
gap> IsConstantGlobal("testvar");
true
gap> newtestvar := fail;;
gap> MakeConstantGlobal("newtestvar");
Error, Variable: 'newtestvar' must be assigned a small integer, true or false
gap> IsConstantGlobal("newtestvar");
false
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
    if true then
        return 7;
    elif 1 = 2 then
        return 8;
    else
        return 9;
    fi;
    if false then
        return 10;
    elif true then
        return 11;
    else
        return 12;
    fi;
    return;
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
