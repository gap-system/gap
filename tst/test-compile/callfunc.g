# proc calls
p0 := function(f)
    Print("p0\n");
    f();
end;

p1 := function(f)
    Print("p1\n");
    f(1);
end;

p7 := function(f)
    Print("p7\n");
    f(1,2,3,4,5,6,7);
end;

# func calls
f0 := function(f)
    Print("f0\n");
    Display(f());
end;

f1 := function(f)
    Print("f1\n");
    Display(f(1));
end;

f7 := function(f)
    Print("f7\n");
    Display(f(1,2,3,4,5,6,7));
end;

runtest := function()
    local IsCustomFunction, f;

    Print("test with a regular function\n");
    f := ReturnTrue;

    p0(f);
    p1(f);
    p7(f);

    f0(f);
    f1(f);
    f7(f);

    Print("test with a custom function\n");
    IsCustomFunction := NewCategory("IsCustomFunction", IsFunction);;
    InstallMethod(CallFuncList, [IsCustomFunction, IsList], {func, args} -> args);
    f := Objectify(NewType(NewFamily("CustomFunctionFamily"),
                           IsCustomFunction and IsPositionalObjectRep), []);;

    p0(f);
    p1(f);
    p7(f);

    f0(f);
    f1(f);
    f7(f);

    BreakOnError := false;

    Print("test with a non-function\n");
    CALL_WITH_CATCH(function() p0(fail); end, []);
    CALL_WITH_CATCH(function() p1(fail); end, []);
    CALL_WITH_CATCH(function() p7(fail); end, []);

    CALL_WITH_CATCH(function() f0(fail); end, []);
    CALL_WITH_CATCH(function() f1(fail); end, []);
    CALL_WITH_CATCH(function() f7(fail); end, []);

end;
