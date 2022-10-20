MatObjTest_CallAndCatchError := function(f, args)
    local out, res, oldBreakOnError, oldErrorOutput, str;

    str := "";
    out := OutputTextString(str, true);

    oldBreakOnError := BreakOnError;
    oldErrorOutput := ERROR_OUTPUT;
    BreakOnError := false;
    MakeReadWriteGlobal("ERROR_OUTPUT");
    ERROR_OUTPUT := out;
    res := CALL_WITH_CATCH(f, args);
    BreakOnError := oldBreakOnError;
    ERROR_OUTPUT := oldErrorOutput;
    CloseStream(out);
    MakeReadOnlyGlobal("ERROR_OUTPUT");
    return [res,str];
end;

MatObjTest_AppendErrorFail := function(f, args, catch, errors)
    local errorMsg;

    errorMsg := Concatenation("The function ", NameFunction(f), " failed with Error Message:\n", catch[2], "\n Called with arguments:\n");
    for arg in args do 
        Append(errorMsg, Concatenation(String(arg),"\n\n"));
    od;
    Add(errors, errorMsg);
end;

MatObjTest_HandleErrorWrongResult := function(msg, args, breakOnError, ex, errors)
    local errorMsg;

    if breakOnError then 
        Error(msg);
    else 
        errorMsg := Concatenation(msg, "\n Called with arguments:\n");
        for arg in args do 
            Append(errorMsg, Concatenation(String(arg),"\n\n"));
        od;
        Add(errors, errorMsg);
    fi;
end;

MatObjTest_CallFunc := function(f, args, breakOnError, errors)
    local catch;
    if breakOnError then 
        return CallFuncList(f, args);
    else
        catch := MatObjTest_CallAndCatchError(f, args);
        if catch[1][1] then 
            return catch[1][2];
        else 
            MatObjTest_AppendErrorFail(f, args, catch, errors);
            return fail;
        fi;
    fi;
end;