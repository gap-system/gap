#############################################################################
##
#W  cache.gi                     GAP library                 Chris Jefferson
##
##
#Y  Copyright (C) 2017 University of St Andrews, Scotland
##
##  This file defines various types of caching data structures
##
##  Note that this file is read very early in GAP's startup, so we cannot
##  make MemoizePosIntFunction a method and use method dispatch, or other
##  bits of nice GAP functionality.
##

InstallGlobalFunction(MemoizePosIntFunction,
function(func, extra...)
    local boundvals, original, options, r;

    options := rec(
        defaults := [],
        flush := true,
        errorHandler := function(x)
            ErrorNoReturn("<val> must be a positive integer");
        end);

    if LEN_LIST(extra) > 0 then
        for r in REC_NAMES(extra[1]) do
            if IsBound(options.(r)) then
                options.(r) := extra[1].(r);
            else
                ErrorNoReturn("Invalid option: ", r);
            fi;
        od;
    fi;

    original := ShallowCopy(options.defaults);
    
    boundvals := ShallowCopy(original);

    if options.flush then
        InstallMethod(FlushCaches, [],
            function()
                boundvals := ShallowCopy(original);
                TryNextMethod();
            end);
    fi;

    return function(val)
        if not IsPosInt(val) then
            return options.errorHandler(val);
        fi;
        return BindOnceExpr(boundvals, val, {} -> func(val));
    end;
end);
