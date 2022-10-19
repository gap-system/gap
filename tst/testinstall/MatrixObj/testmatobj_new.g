MatObjTest_GenerateExample := function(filter, opt)
    local randomSource, state, inv, dims, dim, doms, dom, customGen, examples;
    
    examples := [];

    if IsBound(opt.randomSource) then 
        randomSource := opt.randomSource;
    else 
        randomSource := GlobalMersenneTwister;
    fi;

    if IsBound(opt.state) then 
        state := opt.state;
    else
        state := State(GlobalMersenneTwister);
    fi;

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
                        Add(examples, [customGen(filter, randomSource, dim[1], dom), dim[2], dom]);
                    fi;
                od;
            od;
        else 
            customGen := opt.useCustomGenerator;
            for dim in dims do 
                for dom in doms do 
                    Add(examples, [customGen(filter, randomSource, dim[1], dim[2], dom), dim[2], dom]);
                od;
            od;
        fi; 
    else 
        if IsBound(opt.invertible) then 
            for dim in dims do 
                for dom in doms do 
                    if dim[1] = dim[2] then 
                        Add(examples, [RandomInvertibleMat(randomSource, dim[1], dom), dim[2], dom]);
                    fi;
                od;
            od;
        else 
            for dim in dims do 
                for dom in doms do 
                    Add(examples, [RandomMat(randomSource, dim[1], dim[2], dom), dim[2], dom]);
                od;
            od;
        fi;
    fi;

    if IsBound(opt.sourceOfTruth) then 
        return List(examples, x -> [NewMatrix(filter, x[3], x[2], x[1]), NewMatrix(opt.sourceOfTruth, x[3], x[2], x[1])]);
    else 
        return List(examples, x -> [NewMatrix(filter, x[3], x[2], x[1]), x[1]]);
    fi;
end;


TestMatrixObj := function()