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
#F  RankFilter( <filter> )  . . . . . . . . . . . . . . . .  rank of a filter
##
##  Compute the rank including the hidden implications.
##

BIND_GLOBAL( "RankFilter", function( filter )
    local   rank,  flags,  i;

    rank  := 0;
    if IS_FUNCTION(filter)  then
        flags := FLAGS_FILTER(filter);
    else
        flags := filter;
    fi;
    for i  in TRUES_FLAGS(WITH_HIDDEN_IMPS_FLAGS(flags))  do
        if IsBound(RANK_FILTERS[i])  then
            rank := rank + RANK_FILTERS[i];
        else
            rank := rank + 1;
        fi;
    od;
    return rank;
end );

#############################################################################
##
#E  filter1.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
