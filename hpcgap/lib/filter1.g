#############################################################################
##
#W  filter1.g                    GAP library                     Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Speed-critical code moved from filter.g so that it can be
##  statically compiled
##

#############################################################################
##
#F  WITH_HIDDEN_IMPS_FLAGS( <flags> )
##

WITH_HIDDEN_IMPS_FLAGS_COUNT      := 0;
WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS := 0;
WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT  := 0;




#############################################################################
##
#F  WITH_IMPS_FLAGS( <flags> )
##

IMPLICATIONS := ShareSpecialObj([]);
WITH_IMPS_FLAGS_CACHE      := LockAndMigrateObj([], IMPLICATIONS);
WITH_IMPS_FLAGS_COUNT      := 0;
WITH_IMPS_FLAGS_CACHE_HIT  := 0;
WITH_IMPS_FLAGS_CACHE_MISS := 0;

Unbind(CLEAR_IMP_CACHE);
BIND_GLOBAL( "CLEAR_IMP_CACHE", function()
    local lock;
    lock := WRITE_LOCK(IMPLICATIONS);
    WITH_IMPS_FLAGS_CACHE := MigrateObj([], IMPLICATIONS);
    UNLOCK(lock);
end );


BIND_GLOBAL( "WITH_IMPS_FLAGS", function ( flags )
    local   with,  changed,  imp,  hash,  hash2,  i,  lock;

    hash := HASH_FLAGS(flags) mod 11001;
    lock := WRITE_LOCK(IMPLICATIONS);
    for i  in [ 0 .. 3 ]  do
        hash2 := 2 * ((hash+31*i) mod 11001) + 1;
        if IsBound(WITH_IMPS_FLAGS_CACHE[hash2])  then
            if IS_IDENTICAL_OBJ(WITH_IMPS_FLAGS_CACHE[hash2],flags) then
                WITH_IMPS_FLAGS_CACHE_HIT := WITH_IMPS_FLAGS_CACHE_HIT + 1;
                with := WITH_IMPS_FLAGS_CACHE[hash2+1];
                UNLOCK(lock);
                return with;
            fi;
        else
            break;
        fi;
    od;
    if i = 3  then
        WITH_IMPS_FLAGS_COUNT := ( WITH_IMPS_FLAGS_COUNT + 1 ) mod 4;
        i := WITH_IMPS_FLAGS_COUNT;
        hash2 := 2*((hash+31*i) mod 11001) + 1;
    fi;

    WITH_IMPS_FLAGS_CACHE_MISS := WITH_IMPS_FLAGS_CACHE_MISS + 1;
    with := flags;
    changed := true;
    while changed  do
        changed := false;
        for imp in IMPLICATIONS  do
            if        IS_SUBSET_FLAGS( with, imp[2] )
              and not IS_SUBSET_FLAGS( with, imp[1] )
            then
                with := AND_FLAGS( with, imp[1] );
                changed := true;
            fi;
        od;
    od;

    WITH_IMPS_FLAGS_CACHE[hash2  ] := flags;
    WITH_IMPS_FLAGS_CACHE[hash2+1] := with;
    UNLOCK(lock);
    return with;
end );

#############################################################################
##
#F  RankFilter( <filter> )  . . . . . . . . . . . . . . . .  rank of a filter
##
##  Compute the rank including the hidden implications.
##

BIND_GLOBAL( "RankFilter", function( filter )
    local   rank,  flags,  i, lock;

    rank  := 0;
    if IS_FUNCTION(filter)  then
        flags := FLAGS_FILTER(filter);
    else
        flags := filter;
    fi;
    lock := WRITE_LOCK(FILTER_REGION);
    for i  in TRUES_FLAGS(WITH_HIDDEN_IMPS_FLAGS(flags))  do
        if IsBound(RANK_FILTERS[i])  then
            rank := rank + RANK_FILTERS[i];
        else
            rank := rank + 1;
        fi;
    od;
    UNLOCK(lock);
    return rank;
end );

#############################################################################
##
#E  filter1.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
