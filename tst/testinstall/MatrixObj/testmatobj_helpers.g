MatObjTest_CallAndCatchError := function(f, args)
    local out, res, oldBreakOnError, oldErrorOutput;

    str := "";
    out := OutputTextString(str, true);

    oldBreakOnError := BreakOnError;
    oldErrorOutput := ERROR_OUTPUT;
    BreakOnError := false;
    ERROR_OUTPUT := out;
    #res := CALL_WITH_CATCH(CALL_WITH_STREAM, [out, f, args]);
    res := CALL_WITH_CATCH(f, args);
    BreakOnError := oldBreakOnError;
    ERROR_OUTPUT := oldErrorOutput;
    CloseStream(out);
    #Add(res, str);
    return [res,str];
end;