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
function(func, defaults...)
    local boundvals, original, uniqueobj;

    # This is an object which cannot exist anywhere else
    uniqueobj := "";

    if LEN_LIST(defaults) = 0 then
        original := AtomicList([]);
    else
        original := AtomicList(defaults[1]);
    fi;

    boundvals := MakeWriteOnceAtomic(AtomicList(original));

    InstallMethod(FlushCaches, [],
        function()
            boundvals := MakeWriteOnceAtomic(AtomicList(original));
        end);

    return function(val)
        local v, boundcpy;
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
