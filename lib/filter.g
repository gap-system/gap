#############################################################################
##
#W  filter.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with filters.
##
Revision.filter_g :=
    "@(#)$Id$";


#############################################################################
##

#V  FILTERS . . . . . . . . . . . . . . . . . . . . . . . list of all filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
FILTERS := [];


#############################################################################
##
#V  RANK_FILTERS  . . . . . . . . . . . . . . . . list of all rank of filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
RANK_FILTERS := [];


#############################################################################
##
#V  INFO_FILTERS  . . . . . . . . . . . . . . . information about all filters
##
##  <INFO_FILTERS> is a lists   containing at position <i> information  about
##  the  <i>.th   filter.  This information   is stored  as  number  with the
##  following meanings:
##
##   0 = no additional information
##   1 = category kernel
##   2 = category
##   3 = representation kernel
##   4 = representation
##   5 = attribute kernel
##   6 = attribute
##   7 = property kernel
##   8 = tester of 7
##   9 = property
##  10 = tester of 9
##
INFO_FILTERS := [];

FNUM_CATS := [ 1, 2 ];
FNUM_REPS := [ 3, 4 ];
FNUM_ATTS := [ 5, 6 ];
FNUM_PROS := [ 7, 9 ];
FNUM_TPRS := [ 8, 10 ];


#############################################################################
##

#F  Setter( <filter> )  . . . . . . . . . . . . . . . .  setter of a <filter>
##
Setter := SETTER_FILTER;


#############################################################################
##
#F  Tester( <filter> )  . . . . . . . . . . . . . . . .  tester of a <filter>
##
Tester := TESTER_FILTER;


#############################################################################
##
#F  NewFilter( <name> [,<rank>] ) . . . . . . . . . . . . create a new filter
##
NewFilter := function( arg )
    local   name,  rank,  filter;

    if LEN_LIST(arg) = 2  then
        name := arg[1];
        rank := arg[2];
    else
        name := arg[1];
        rank := 1;
    fi;
    filter := NEW_FILTER( name );
    FILTERS[FLAG1_FILTER(filter)] := filter;
    RANK_FILTERS[FLAG1_FILTER(filter)] := 1;
    INFO_FILTERS[FLAG1_FILTER(filter)] := 0;

    return filter;
   
end;


#############################################################################
##
#F  NamesFilter( <flags> )  . . . . . list of names of the filters in <flags>
##
NamesFilter := function( flags )
    local  bn,  i;

    if IS_FUNCTION(flags)  then
        flags := FLAGS_FILTER(flags);
    fi;
    if IS_LIST(flags)  then
        bn := SHALLOW_COPY_OBJ(flags);
    else
        bn := SHALLOW_COPY_OBJ(TRUES_FLAGS(flags));
    fi;
    for i  in  [ 1 .. LEN_LIST(bn) ]  do
        if not IsBound(FILTERS[ bn[i] ])  then
            bn[i] := STRING_INT( bn[i] );
        else
            bn[i] := NAME_FUNCTION(FILTERS[ bn[i] ]);
        fi;
    od;
    return bn;

end;


#############################################################################
##
#F  RankFilter( <filter> )  . . . . . . . . . . . . . . . .  rank of a filter
##
##  Compute the rank including the hidden implications.
##
WITH_HIDDEN_IMPS_FLAGS := "2b defined";

RANK_FILTER := function( filter )
    local   rank,  flags,  i;

    rank  := 0;
    flags := FLAGS_FILTER(filter);
    for i  in TRUES_FLAGS(WITH_HIDDEN_IMPS_FLAGS(flags))  do
        if IsBound(RANK_FILTERS[i])  then
            rank := rank + RANK_FILTERS[i];
        else
            rank := rank + 1;
        fi;
    od;
    return rank;
end;

RankFilter := RANK_FILTER;

RANK_FILTER_STORE := function( filter )
    local   hash,  rank;

    hash := HASH_FLAGS( FLAGS_FILTER( filter ) );
    rank := RANK_FILTER( filter );
    ADD_LIST( RANK_FILTER_LIST, hash );
    ADD_LIST( RANK_FILTER_LIST, rank );
    return rank;

end;

RANK_FILTER_COMPLETION := function( filter )
    local   hash;

    hash := HASH_FLAGS( FLAGS_FILTER( filter ) );
    if hash <> RANK_FILTER_LIST[RANK_FILTER_COUNT]  then
        Error( "corrupted completion file" );
    fi;
    RANK_FILTER_COUNT := RANK_FILTER_COUNT+2;
    return RANK_FILTER_LIST[RANK_FILTER_COUNT-1];

end;


#############################################################################
##

#E  filter.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
