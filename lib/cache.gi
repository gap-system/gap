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
    local boundvals, original, uniqueobj, options, r;

    # This is an object which cannot exist anywhere else
    uniqueobj := "";

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

    original := AtomicList(options.defaults);
    
    boundvals := MakeWriteOnceAtomic(AtomicList(original));

    if options.flush then
        InstallMethod(FlushCaches, [],
            function()
                boundvals := MakeWriteOnceAtomic(AtomicList(original));
                TryNextMethod();
            end);
    fi;

    return function(val)
        local v, boundcpy;
        if not IsPosInt(val) then
            return options.errorHandler(val);
        fi;
        # Make a copy of the reference to boundvals, in case the cache
        # is flushed, which will causes boundvals to be bound to a new list.
        boundcpy := boundvals;
        v := GetWithDefault(boundcpy, val, uniqueobj);
        if IsIdenticalObj(v, uniqueobj) then
            # As the list is WriteOnceAtomic, if two threads call
            # func(val) at the same time they will still return the
            # same value (the first assigned to the list).
            boundcpy[val] := func(val);
            v := boundcpy[val];
        fi;
        return v;
    end;
end);
