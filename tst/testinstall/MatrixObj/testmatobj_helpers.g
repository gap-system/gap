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