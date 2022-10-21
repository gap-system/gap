MatObjTest_CallAndCatchError := function(f, args)
    local out, res, oldBreakOnError, oldErrorOutput, str;

    str := "";
    out := OutputTextString(str, true);

    oldBreakOnError := BreakOnError;
    oldErrorOutput := ERROR_OUTPUT;
    MakeReadWriteGlobal("ERROR_OUTPUT");
    ERROR_OUTPUT := out;
    BreakOnError := false;
    res := CALL_WITH_CATCH(f, args);
    BreakOnError := oldBreakOnError;
    ERROR_OUTPUT := oldErrorOutput;
    MakeReadOnlyGlobal("ERROR_OUTPUT");
    CloseStream(out);
    return [res,str];
end;

MatObjTest_AppendErrorFail := function(f, args, catch, errors, ex)
    local errorMsg, arg;

    errorMsg := Concatenation("The function ", NameFunction(f), " failed with Error Message:\n", catch[2], "\n Called with arguments:\n");
    for arg in args do 
        if IsMatrixObj(arg) then 
            Append(errorMsg, Concatenation( "NewMatrix( ",
            NameFunction( ex.filter ), ", ",
            String( ex.baseDomain ), ", ",
            String( ex.nrCols ), ", ",
            String( ex.mat ), " )", "\n\n"));
        else 
            Append(errorMsg, Concatenation(String(arg), "\n\n"));
        fi;
    od;
    Add(errors, errorMsg);
end;

MatObjTest_HandleErrorWrongResult := function(msg, args, breakOnError, ex, errors)
    local errorMsg, arg;

    if breakOnError then 
        Error(msg);
    else 
        errorMsg := Concatenation(msg, "\n Called with arguments:\n");
        for arg in args do 
            if IsMatrixObj(arg) then 
                Append(errorMsg, Concatenation( "NewMatrix( ",
                NameFunction( ex.filter ), ", ",
                String( ex.baseDomain ), ", ",
                String( ex.nrCols ), ", ",
                String( ex.mat ), " )", "\n\n"));
            else 
                Append(errorMsg, Concatenation(String(arg), "\n\n"));
            fi;
        od;
        Add(errors, errorMsg);
    fi;
end;

MatObjTest_CallFunc := function(f, args, breakOnError, errors, ex)
    local catch;
    #if f = ConstructingFilter then 
    #    Error();
    #fi;
    if breakOnError then 
        return CallFuncList(f, args);
    else
        catch := MatObjTest_CallAndCatchError(f, args);
        if catch[1][1] then 
            if IsBound(catch[1][2]) then 
                return catch[1][2];
            else 
                return;
            fi;
        else 
            MatObjTest_AppendErrorFail(f, args, catch, errors, ex);
            return fail;
        fi;
    fi;
end;

MatObjTest_GenerateExample := function(filter, opt)
    local inv, dims, dim, doms, dom, customGen, examples;
    
    examples := [];

    if IsBound(opt.dimensions) then 
        dims := opt.dimensions;
    else 
        dims := [[2,2],[3,3],[2,5],[5,5],[1,3],[4,1],[6,2]];
    fi;

    if IsBound(opt.domains) then 
        doms := opt.domains;
    else
        doms := [Integers, Rationals, GF(2), GF(5), GF(49)];
    fi;

    if IsBound(opt.useCustomGenerator) then 
        if IsBound(opt.invertible) then
            customGen := opt.invertible;
            for dim in dims do 
                for dom in doms do 
                    if dim[1] = dim[2] then 
                        Add(examples, [customGen(filter, opt.randomSource, dim[1], dom), dim[1], dim[2], dom]);
                    fi;
                od;
            od;
        else 
            customGen := opt.useCustomGenerator;
            for dim in dims do 
                for dom in doms do 
                    Add(examples, [customGen(filter, opt.randomSource, dim[1], dim[2], dom), dim[1], dim[2], dom]);
                od;
            od;
        fi; 
    else 
        if IsBound(opt.invertible) then 
            for dim in dims do 
                for dom in doms do 
                    if dim[1] = dim[2] then 
                        Add(examples, [RandomInvertibleMat(opt.randomSource, dim[1], dom), dim[1], dim[2], dom]);
                    fi;
                od;
            od;
        else 
            for dim in dims do 
                for dom in doms do 
                    Add(examples, [RandomMat(opt.randomSource, dim[1], dim[2], dom), dim[1], dim[2], dom]);
                od;
            od;
        fi;
    fi;

    if IsBound(opt.sourceOfTruth) then 
        return List(examples, x-> 
            rec(matObj := NewMatrix(filter, x[4], x[3], x[1]),
            filter := filter,
            baseDomain := x[4],
            nrCols := x[3],
            nrRows := x[2],
            mat := x[1],
            sourceOfTruth := NewMatrix(opt.sourceOfTruth, x[4], x[3], x[1]))
            );
        #return List(examples, x -> [NewMatrix(filter, x[3], x[2], x[1]), NewMatrix(opt.sourceOfTruth, x[3], x[2], x[1])]);
    else 
        return List(examples, x-> 
            rec(matObj := NewMatrix(filter, x[4], x[3], x[1]),
            filter := filter,
            baseDomain := x[4],
            nrCols := x[3],
            nrRows := x[2],
            mat := x[1],
            sourceOfTruth := x[1])
        );
        #return List(examples, x -> [NewMatrix(filter, x[3], x[2], x[1]), x[1]]);
    fi;
end;

MatObjTest_TestBaseDomain := function(ex, opt, errors)
    local domain;

    domain := MatObjTest_CallFunc(BaseDomain,[ex.matObj], opt.breakOnError, errors, ex);

    if domain <> fail then
        if domain <> ex.baseDomain then
            MatObjTest_HandleErrorWrongResult("BaseDomain", [ex.matObj], opt.breakOnError, ex, errors);
        fi;
    fi;
end;

MatObjTest_TestNrRows := function(ex, opt, errors)
    local nrRows;

    nrRows := MatObjTest_CallFunc(NrRows, [ex.matObj], opt.breakOnError, errors, ex);

    if nrRows <> fail then
        if nrRows <> ex.nrRows then
            MatObjTest_HandleErrorWrongResult("NrRows", [ex.matObj], opt.breakOnError, ex, errors);
        fi;
    fi; 
end;

MatObjTest_TestNrCols := function(ex, opt, errors)
    local nrCols;

    nrCols := MatObjTest_CallFunc(NrCols, [ex.matObj], opt.breakOnError, errors, ex);
    
    if nrCols <> fail then
        if nrCols <> ex.nrCols then
            MatObjTest_HandleErrorWrongResult("NrCols", [ex.matObj], opt.breakOnError, ex, errors);
        fi;
    fi; 
end;

MatObjTest_TestMatElm := function(ex, opt, errors)
    local col, row, elm;

    col := ex.nrCols;
    row := ex.nrRows;
    elm := MatObjTest_CallFunc(MatElm, [ex.matObj, row, col], opt.breakOnError, errors, ex);

    if elm <> fail then
        if elm <> ex.sourceOfTruth[row,col] then
            MatObjTest_HandleErrorWrongResult("MatElm", [ex.matObj, row, col], opt.breakOnError, ex, errors);
        fi;
    fi;
end;

MatObjTest_TestSetMatElm := function(ex, opt, errors)
    local col, row, elm;

    col := ex.nrCols;
    row := ex.nrRows;
    elm := Zero(ex.baseDomain);
    ex.sourceOfTruth[row, col] := elm;
    ex.mat[row, col] := elm;
    MatObjTest_CallFunc(SetMatElm, [ex.matObj, row, col, elm], opt.breakOnError, errors, ex);

    if ex.matObj[row, col] <> ex.sourceOfTruth[row, col] then
        MatObjTest_HandleErrorWrongResult("SetMatElm", [ex.matObj, row, col, elm], opt.breakOnError, ex, errors);
    fi;
end;

MatObjTest_TestConstructingFilter := function(ex, opt, errors)
    local filter;
    #Error("before CallFunc");
    filter := MatObjTest_CallFunc(ConstructingFilter, [ex.matObj], opt.breakOnError, errors, ex);
    #Error("made it past CallFunc");
    if filter <> fail then
        if filter <> ex.filter then
            MatObjTest_HandleErrorWrongResult("ConstructingFilter", [ex.matObj], opt.breakOnError, ex, errors);
        fi;
    fi;
end;


TestMatrixObj := function(filter, opt)
    local errors, examples, ex;

    errors := [];

    if not IsBound(opt.randomSource) then
        opt.randomSource := GlobalMersenneTwister;
    fi;

    if not IsBound(opt.state) then 
        opt.state := State(GlobalMersenneTwister);
    fi;

    if not IsBound(opt.forbidInv) then
        opt.forbidInv := false;
    fi;

    if not IsBound(opt.breakOnError) then
        opt.breakOnError := false;
    fi;

    examples := MatObjTest_GenerateExample(filter, opt);

    for ex in examples do
        MatObjTest_TestBaseDomain(ex, opt, errors);
    od;

    for ex in examples do
        MatObjTest_TestNrRows(ex, opt, errors);
    od; 

    for ex in examples do
        MatObjTest_TestNrCols(ex, opt, errors);
    od; 

    for ex in examples do
        MatObjTest_TestMatElm(ex, opt, errors);
    od; 

    for ex in examples do
        MatObjTest_TestSetMatElm(ex, opt, errors);
    od; 

    for ex in examples do
        MatObjTest_TestConstructingFilter(ex, opt, errors);
    od;

    #TODO other tests

    if not opt.forbidInv then
        opt.invertible := true;
        examples := MatObjTest_GenerateExample(filter, opt);

        for ex in examples do
            #TestInverse(ex);
        od;

        #Other tests were you need invertible matrices
    fi;

    return errors;
end;
