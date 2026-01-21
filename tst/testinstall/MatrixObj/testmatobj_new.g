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

# This function requires a filter defining a matrix object and a record of
# options and generates a list of examples for tests according to the provided 
# options. 
# Examples are records with three entries:
# matObj: The generated matrix object that is to be tested
# mat: The corresponding calssical GAP matrix (i.e. matrix as list of rows as
# lists)
# sourceOfTruth: Either again the classical GAP matrix or another matrix object
# to test against 
# MatObjTest_GenerateExample accepts several options as attributes of the opt 
# record.
# randomSource: This is set to GlobalMersenneTwister by default. If it is bound
#   then it must be bound to a valid GAP random source and is passed to
#    functions generating random matrices which accept a random source.
# state: If unbound this is set to the current state of the default random
#   source. This options should only be used if no randomSource is set. Then one
#   can provide a valid state of the GlobalMersenneTwister and it is set to this
#   state before examples are generated. This option is intended to make
#   reproduction of problems easier.
# dimensions: A list of tuples defining dimensions for matrices. By default this
#   is set to [[1,1],[2,2],[3,3],[2,5],[5,5],[1,3],[4,1],[6,2]]. 
# domains: A list of domains in which matrices should be generated. By default
#   this is set to [Integers, Rationals, GF(2), GF(5), GF(49)].
# cases: A list of triples specifying the number of rows, number of columns and
#   domain of a matrix. By default this is unbound. However, if bound the 
#   options domains and dimensions are ignored and instead for each case in 
#   cases an example is generated.
# sourceOfTruthFilter: When performing tests GAP needs some way of telling what
#   results are correct. That is it needs some kind of way to tell whats true 
#   and whats not. A source of truth is therefore something telling GAP whats 
#   true. Here this option can be set to a filter defining a matrix object. Then
#   together with the matrix objetcs which are to be tested the matrix object
#   specified as sourceOfTruthFilter is generated as well so the test code can access 
#   it and comapre results. If this option is unbound then classical GAP 
#   matrices are used.
# customGenerator: By default random examples are generated using RandomMat or 
#   RandomInvertibleMat. However, depending on the matrix object not all 
#   matrices generated are valid. Consider for example a matrix object type for
#   diagonal matrices. If necessary one can set this option to a function wich
#   accepts as arguments a filter, a randomSource, an integer which specifies 
#   the number of rows, an integer which specifies the number of columns and a 
#   domain. It must generate a classical GAP matrix from which a valid matrix 
#   object of the specified filter (which is the filter of the type that is 
#   tested) can be generated using NewMatrix. The generated matrix must have 
#   the specified number of rows and columns and its entries must lie in the 
#   specified domain. A second option is to bound this option to anything. In 
#   this case the option invertible must be bound to a function accepting as 
#   arguments a filter, a random source, an integer specifying the number of 
#   rows and a domain. This function must generate classical GAP matrices which 
#   are invertible, have the specified number of rows and entries in the 
#   specified domain. 
# invertible: By default this option is left unbound. If it is unbound any
#   random matrices are generated. If it is bound then only invertible matrices
# are generated. This option changes its behaviour depending on whether
# customGenerator is bound. If customGenerator is bound then invertible must be
# set to a function as explained above. If custom generator is unbound and
# invertible is then matrices are generated using RandomInvertibleMat.
# Thus there are four cases:
#   opt.customGenerator and invertible are unbound:
#       matrices are generated using RandomMat 
#    opt.customGenerator is unbound but opt.invertible is bound:
#       matrices are generated using RandomInvertibleMat
#    opt.customGenerator is bound but opt.invertible is not:
#       opt.customGenerator is used to generate matrices and therefore must be 
#       bound to a function accordingly
#    opt.customGenerator is bound and opt.invertible is bound:
#       opt.invertible is used to generate matrices and therefore must be bound 
#       to a function accordingly

MatObjTest_GenerateExample := function(filter, opt_in)
    local inv, dims, dim, doms, dom, generator, examples, ex, getSourceOfTruth, result, _case, cases, opt, matObj;
    
    examples := [];
    opt := ShallowCopy(opt_in);

    if not IsBound(opt.cases) then 
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

        if IsBound(opt.invertible) then 
            doms := Filtered(doms, IsField);
        fi;

        cases := [];

        for dim in dims do
            for dom in doms do 
                Add(cases, [dim[1],dim[2],dom]);
            od;
        od;
    else 
        cases := opt.cases;
    fi;

    # set generator to use provided customGenerators if applicable
    if IsBound(opt.customGenerator) then 
        if IsBound(opt.invertible) then 
            # use a small wrapper to call the generator, note that this will
            # generate invertible nxn matrices where n is the number of rows,
            # i.e. the number of columns is simply ignored 
            generator := function(filter, randomSource, nrRows, nrCols, dom) return opt.invertible(filter, randomSource, nrRows, dom); end;
        else 
            # here a wrapper is unnecessary since the customGenerator must have
            # the signature we use below
            generator := opt.customGenerator;
        fi;
    else 
        if IsBound(opt.invertible) then 
            generator := function(filter, randomSource, nrRows, nrCols, dom) return RandomInvertibleMat(randomSource, nrRows, dom); end;
        else 
            generator := function(filter, randomSource, nrRows, nrCols, dom) return RandomMat(randomSource, nrRows, nrCols, dom); end;
        fi;
    fi;
    
    for _case in cases do 
        Add(examples, [generator(filter, opt.randomSource, _case[1], _case[2], _case[3]), _case[1], _case[2], _case[3]]);
    od;

    if IsBound(opt.sourceOfTruthFilter) then 
        getSourceOfTruth := x -> NewMatrix(opt.sourceOfTruthFilter, x[4], x[3], x[1]);
    else 
        getSourceOfTruth := x -> x[1];
    fi;
 
    result := [];

    for ex in examples do
        matObj := NewMatrix(filter, ex[4], ex[3], ex[1]);
        Add(result, rec(matObj := matObj,
            mat := ex[1],
            sourceOfTruth := getSourceOfTruth(ex)));
        if BaseDomain(Last(result).matObj) <> ex[4] or NumberRows(Last(result).matObj) <> ex[2] or NumberColumns(Last(result).matObj) <> ex[3] or ConstructingFilter(Last(result).matObj) <> filter then
            ErrorNoReturn("while generating examples. In a case with\nNrRows = ", ex[2], "\nNrCols = ", ex[3], "\ndomain = ", ex[4], "\nfilter := ", filter, "\nNumberRows, NumberColumns, BaseDomain or ConstructingFilter does not work.\n");
        fi;
    od;

    return result;
end;

# This is a concrete test function. It gets an example and should test the
# function it specifies in its identifier. Here the function tests MatElm that
# is element access.
MatObjTest_TestMatElm := function(ex)
    local col, row, elm;

    for row in [1..NrRows(ex.matObj)] do
        for col in [1..NrCols(ex.matObj)] do
            elm := ex.matObj[row, col];
            if elm <> ex.sourceOfTruth[row,col] then
                return false;
            fi; 
        od;
    od;

    return true;
end;

MatObjTest_TestSetMatElm := function(ex_in)
    local col, row, elm, mat, ex;

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

MatObjTest_TestIsIdentityMat := function(ex_in)
    #todo
end;

MatObjTest_TestInverse := function(ex_in)
    local ex, mat, inv;

    ex := ShallowCopy(ex_in);
    mat := ex.matObj;
    inv := mat^(-1);
    if IsIdentityMat(mat*inv) and IsIdentityMat(inv*mat) then 
        return true;
    fi;

    return false;
end;

# This function requires a filter defining a MatrixObject and a record of 
# options. 
# This function runs tests to check whether the specified MatrixObject
# implementation implements required methods and if these and other methods are 
# correct (in the sense that they give correct results for the cases tested 
# here).
# The following options are supported:
# randomSource:
#   See MatObjTest_GenerateExample
# state:
#   See MatObjTest_GenerateExample
# dimensions: 
#   See MatObjTest_GenerateExample
# dimensions_red: A list of tuples defining dimensions for matrices. If not set
#   this is set to [[1,1],[2,2],[3,3],[5,5]]. These dimensions are used to
#   generate examples for more expensive tests. 
# domains:
#   See MatObjTest_GenerateExample
# domains_red:
#   A list of domains in which matrices should be generated. By default
#   this is set to [Integers, Rationals, GF(2), GF(5)]. These domains are used 
#   to generate examples for more expensive tests.
# reduced_cases: 
#   A list of triples defining the number of rows, the number of columns and the
#   domain over which examples are generated. By default this option is unbound.
#   If bound the options dimensions_red and domains_red are ignored and instead
#   the cases specified in reduced_cases are used to generate examples for
#   expensive tests. The reason to use this is that otherwise when specifying
#   domains and dimensions via domains_red and dimensions_red all combinations 
#   of the specified dimensions and domains are used. If tests are very 
#   expensive or just certain combinations should be tested one can use 
#   reduced_cases instead.
# customGenerator:
#   See MatObjTest_GenerateExample
# customInvertibleGenerator:
#   Like customGenerator a function that generates invertible matrices
#   compatible with the specified matrix object. It is used when invertible
#   matrices are required. Default: unbound
# sourceOfTruthFilter:
#   See MatObjTest_GenerateExample
# forbidInv:
#   Boolean set to false by default. If set to true no tests which require
#   invertible matrices are performed. Intended to either skip potentially
#   expensive tests or for implementations not able to store invertible 
#   matrices.
# breakOnError:
#   Boolean set to false by default. If set to true Errors or Wrong results
#   cause a break loop. Otherwise problems are returned as a list of messages.
# isImmutable:
#    Boolean set to false by default. If set to true tests of functions which 
#    change an object and therefore require it to be mutable are skipped. This
#    option is intended for objects which are always immutable. 

TestMatrixObj := function(filter, optIn)
    local errors, examples, ex, opt, nopt;

    errors := [];

    opt := ShallowCopy(optIn);

    # set the randomSource. If the default is used and a state is provided the
    # randomSource is reset to that state.
    if not IsBound(opt.randomSource) then
        opt.randomSource := GlobalMersenneTwister;
        if IsBound(opt.state) then
            Reset(opt.randomSource, opt.state);
        else
            opt.state := State(opt.randomSource);
        fi;
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

    if not IsBound(opt.dimensions_red) then 
        opt.dimensions_red := [[1,1],[2,2],[3,3],[5,5]];
    fi;

    if not IsBound(opt.domains_red) then 
        opt.domains_red := [Integers, Rationals, GF(2), GF(5)];
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
        nopt := ShallowCopy(opt);
        nopt.invertible := true;
        nopt.dimensions := opt.dimensions_red;
        nopt.domains := opt.domains_red;
        #opt.domains := Filtered(opt.domains, IsField);
        examples := MatObjTest_GenerateExample(filter, nopt);

        for ex in examples do
            if MatObjTest_CallFunc(MatObjTest_TestInverse, [ex], opt.breakOnError, errors, ex) = false then
                MatObjTest_HandleErrorWrongResult("Inverse", [ex.matObj], opt.breakOnError, ex, errors);
            fi; 
        od;

        #Other tests were you need invertible matrices
    fi;

    return errors;
end;
