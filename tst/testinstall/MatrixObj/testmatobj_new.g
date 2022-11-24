# the option customGenerator is supposed to be a function that expects as
# arguments a filter, a randomSource, nrRows, nrCols and a domain. It must
# return a classical GAP matrix. 

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
            NameFunction( ConstructingFilter(ex.MatObj) ), ", ",
            String( BaseDomain(ex.MatObj) ), ", ",
            String( NumberColumns(ex.MatObj) ), ", ",
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
                NameFunction( ConstructingFilter(ex.MatObj) ), ", ",
                String( BaseDomain(ex.MatObj) ), ", ",
                String( NumberColumns(ex.MatObj) ), ", ",
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
 
    result := [];

    for ex in examples do 
        Add(result, rec(matObj := NewMatrix(filter, ex[4], ex[3], ex[1]),
            #filter := filter,
            mat := ex[1],
            sourceOfTruth := getSourceOfTruth(x)));
        if BaseDomain(Last(result).matObj) <> ex[4] or NumberRows(Last(result).matObj) <> ex[2] or NumberColumns(Last(result).matObj) <> ex[3] or ConstructingFilter(Last(result).matObj) <> filter then 
            ErrorNoReturn(Concatenation("Error while generating examples. In a case with NrRows = ", String(ex[2], " NrCols = ", String(ex[3]), " domain = ", String(ex[4]), "and filter := ", String(filter), " NumberRows, NumberColumns, BaseDomain or ConstructingFilter does not work.")));
        fi;
    od;

    return result;
end;

# This is a concrete test function. It gets an example and should test the
# function it specifies in its identifier. Here the function tests MatElm that
# is element access.
MatObjTest_TestMatElm := function(ex)
    local col, row, elm;

    for row in [1..NrRows(ex.matobj)] do
        for col in [1..NrCols(ex.matobj)] do
            elm := ex.matobj[row, col];
            if elm <> ex.sourceOfTruth[row,col] then
                return false;
            fi; 
        od;
    od;

    return true;
end;

MatObjTest_TestSetMatElm := function(ex_in)
    local col, row, elm, mat;

    ex := ShallowCopy(ex_in);
    mat := ex.matObj;
    elm := Zero(BaseDomain(mat));
    ex.sourceOfTruth[row, col] := elm;
    ex.mat[row, col] := elm;

    for row in [1..NrRows(ex.matObj)] do
        for col in [1..NrCols(ex.matObj)] do
            ex.matObj[row,col] := elm;
            ex.sourceOfTruth[row,col] := elm;
            if ex.matObj[row,col] <> ex.sourceOfTruth[row,col] then
                return false;
            fi; 
        od;
    od;

    return true;
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

    if not IsBound(opt.isImmutable) then 
        opt.isImmutable := false;
    fi;

    examples := MatObjTest_GenerateExample(filter, opt);

    # here the test function is called on all appropriate examples. Note, if
    # needed the list examples can be regenerated with the desired options at
    # any time. The test function 'MatObjTest_TestMatElm' is called using the
    # wrapper function 'MatObjTest_CallFunc' in order to catch errors and print
    # appropriate error messages if 'opt.breakOnError' is set to 'true' or add
    # them to the list 'errors' otherwise. 'MatObjTest_CallFunc' returns
    # whatever the called function returns. In this case this should be either
    # 'true' or 'false'. In the latter case the test encountered a wrong result.
    # In order to provide a corresponding message the function
    # 'MatObjTest_HandleWrongResult' should be called.
    for ex in examples do
        if MatObjTest_CallFunc(MatObjTest_TestMatElm, [ex], opt.breakOnError, errors, ex) = false then 
            MatObjTest_HandleErrorWrongResult("MatElm", [ex.matObj], opt.breakOnError, ex, errors);
        fi;
    od; 

    # here belong tests that require the matrix object to be mutable
    if not IsBound(opt.isImmutable) then
        if MatObjTest_CallFunc(MatObjTest_TestSetMatElm, [ex], opt.breakOnError, errors, ex) = false then 
            MatObjTest_HandleErrorWrongResult("SetMatElm", [ex.matObj], opt.breakOnError, ex, errors);
        fi; 
    fi;

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
