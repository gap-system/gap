#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Chris Jefferson.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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

InstallGlobalFunction(GET_FROM_SORTED_CACHE,
function(cache, key, maker)
    local pos, val;

    # Check whether this has been stored already.
    atomic readonly cache do
      pos:= POSITION_SORTED_LIST( cache[1], key );
      if pos <= Length( cache[1] ) and cache[1][pos] = key then
        return cache[2][ pos ];
      fi;
    od;

    # Compute new value.
    val := maker();

    # Store the value. Need to recompute pos as the maker function may have
    # changed the cache, eg. by recursively calling itself (resp. its "parent
    # function", the one containing the call to GET_FROM_SORTED_CACHE)
    atomic readwrite cache do
      pos:= POSITION_SORTED_LIST( cache[1], key );
      if pos <= Length( cache[1] ) and cache[1][pos] = key then
        # oops, something else computed the value in the meantime;
        # so use that instead
        val:= cache[2][ pos ];
      else
        Add( cache[1], Immutable( key ), pos );
        Add( cache[2], val, pos );
      fi;
    od;

    # Return the value.
    return val;
end);
