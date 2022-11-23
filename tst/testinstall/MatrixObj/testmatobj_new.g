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

    # whats printed in the BreakLoop in case of a wrong result could be improved
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
    local inv, dims, dim, doms, dom, generator, examples, ex, getSourceOfTruth, result;
    
    examples := [];

    if IsBound(opt.dimensions) then 
        dims := opt.dimensions;
    else 
        dims := [[1,1],[2,2],[3,3],[2,5],[5,5],[1,3],[4,1],[6,2]];
    fi;

    if IsBound(opt.domains) then 
        doms := opt.domains;
    else
        doms := [Integers, Rationals, GF(2), GF(5), GF(49)];
    fi;

    # set generator to use provided customGenerators if applicable
    if IsBound(opt.useCustomGenerator) then 
        if IsBound(opt.invertible) then 
            # use a small wrapper to call the generator, note that this will
            # generate invertible nxn matrices where n is the number of rows,
            # i.e. the number of columns is simply ignored 
            generator := function(filter, randomSource, nrRows, nrCols, dom) return opt.invertible(filter, randomSource, nrRows, dom); end;
        else 
            # here a wrapper is unnecessary since the customGenerator must have
            # the signature we use below
            generator := opt.useCustomGenerator;
        fi;
    else 
        if IsBound(opt.invertible) then 
            generator := function(filter, randomSource, nrRows, nrCols, dom) return RandomInvertibleMat(randomSource, nrRows, dom); end;
        else 
            generator := function(filter, randomSource, nrRows, nrCols, dom) return RandomMat(randomSource, nrRows, nrCols, dom); end;
        fi;
    fi;

    for dim in dims do
        for dom in doms do 
            Add(examples, [generator(filter, opt.randomSource, dim[1], dim[2], dom), dim[1], dim[2], dom]);
        od;
    od;

    if IsBound(opt.sourceOfTruth) then 
        getSourceOfTruth := x -> NewMatrix(opt.sourceOfTruth, x[4], x[3], x[1]);
    else 
        getSourceOfTruth := x -> x[1];
    fi;

    # if a custom generator was used we do not have to create MatObjs because we
    # already have them
    getMatObj := function(filter, ex)
        if IsMatrixObj(ex[1]) then 
            return ex[1];
        else 
            return NewMatrix(filter, ex[4], ex[3], ex[1]);
        fi;
    end;
 
    result := [];

    for ex in examples do 
        Add(result, rec(matObj := getMatObj(filter, ex),
            filter := filter,
            mat := ex[1],
            sourceOfTruth := getSourceOfTruth(x)));
        if BaseDomain(Last(result).matObj) <> ex[4] or NumberRows(Last(result).matObj) <> ex[2] or NumberColumns(Last(result).matObj) <> ex[3] then 
            ErrorNoReturn(Concatenation("Error while generating examples. In a case with NrRows = ", String(ex[2], " NrCols = ", String(ex[3]), " domain = ", String(ex[4]), " NumberRows, NumberColumns or BaseDomain does not work.")));
        fi;
    od;

    return result;

    #return List(examples, x-> 
        rec(matObj := NewMatrix(filter, x[4], x[3], x[1]),
        filter := filter,
        baseDomain := x[4],
        nrCols := x[3],
        nrRows := x[2],
        mat := x[1],
        sourceOfTruth := getSourceOfTruth(x)));
        #return List(examples, x -> [NewMatrix(filter, x[3], x[2], x[1]), NewMatrix(opt.sourceOfTruth, x[3], x[2], x[1])]);
end;

#MatObjTest_TestBaseDomain := function(ex, opt, errors)
#    local domain;
#
#    domain := MatObjTest_CallFunc(BaseDomain,[ex.matObj], opt.breakOnError, errors, ex);

#    if domain <> fail then
#        if domain <> ex.baseDomain then
#            MatObjTest_HandleErrorWrongResult("BaseDomain", [ex.matObj], opt.breakOnError, ex, errors);
#        fi;
#    fi;
#end;

#MatObjTest_TestNrRows := function(ex, opt, errors)
#    local nrRows;

#    nrRows := MatObjTest_CallFunc(NrRows, [ex.matObj], opt.breakOnError, errors, ex);

#    if nrRows <> fail then
#        if nrRows <> ex.nrRows then
#            MatObjTest_HandleErrorWrongResult("NrRows", [ex.matObj], opt.breakOnError, ex, errors);
#        fi;
#    fi; 
#end;

#MatObjTest_TestNrCols := function(ex, opt, errors)
#    local nrCols;

#    nrCols := MatObjTest_CallFunc(NrCols, [ex.matObj], opt.breakOnError, errors, ex);
    
#    if nrCols <> fail then
#        if nrCols <> ex.nrCols then
#            MatObjTest_HandleErrorWrongResult("NrCols", [ex.matObj], opt.breakOnError, ex, errors);
#        fi;
#    fi; 
#end;

# MatObjTest_CallFunc ausserhalb der TestCases
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


TestMatrixObj := function(filter, optIn)
    local errors, examples, ex;

    errors := [];

    opt := ShallowCopy(optIn);

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
