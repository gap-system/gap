#############################################################################
##
#W  filter.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file deals with filters. Some speed-critical functions are in 
##  filter1.g, which is compiled
##
Revision.filter_g :=
    "@(#)$Id$";

#############################################################################
##
#V  "forward declarations that will be picked up in filter1.g
##

HIDDEN_IMPS := fail;
IMPLICATIONS := fail;
CLEAR_HIDDEN_IMP_CACHE := fail;
CLEAR_IMP_CACHE := fail;



#############################################################################
##
#V  FILTERS . . . . . . . . . . . . . . . . . . . . . . . list of all filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
BIND_GLOBAL( "FILTERS", [] );


#############################################################################
##
#V  RANK_FILTERS  . . . . . . . . . . . . . . . . list of all rank of filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
BIND_GLOBAL( "RANK_FILTERS", [] );


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
BIND_GLOBAL( "INFO_FILTERS", [] );

BIND_GLOBAL( "FNUM_CATS", [ 1,  2 ] );
BIND_GLOBAL( "FNUM_REPS", [ 3,  4 ] );
BIND_GLOBAL( "FNUM_ATTS", [ 5,  6 ] );
BIND_GLOBAL( "FNUM_PROS", [ 7,  9 ] );
BIND_GLOBAL( "FNUM_TPRS", [ 8, 10 ] );


#############################################################################
##
#V  IMM_FLAGS
##
##  is a flag list.
##  For the filters in `FILTERS{ TRUES_FLAGS( IMM_FLAGS ) }',
##  no immediate method is installed.
##  (The installation of immediate methods changes `IMM_FLAGS'.)
##
IMM_FLAGS := FLAGS_FILTER( IS_OBJECT );
#T EMPTY_FLAGS not yet defined !


#############################################################################
##

#F  Setter( <filter> )  . . . . . . . . . . . . . . . .  setter of a <filter>
##
BIND_GLOBAL( "Setter", SETTER_FILTER );


#############################################################################
##
#F  Tester( <filter> )  . . . . . . . . . . . . . . . .  tester of a <filter>
##
BIND_GLOBAL( "Tester", TESTER_FILTER );



#############################################################################
##
#F  InstallHiddenTrueMethod( <filter>, <filters> )
##
BIND_GLOBAL( "InstallHiddenTrueMethod", function ( filter, filters )
    local   imp;

    imp := [];
    imp[1] := FLAGS_FILTER( filter );
    imp[2] := FLAGS_FILTER( filters );
    ADD_LIST( HIDDEN_IMPS, imp );
end );




#############################################################################
##
#F  InstallTrueMethodNewFilter( <to>, <from> )
##
##  If <from> is a new filter then  it cannot occur in  the cache.  Therefore
##  we do not flush the cache.  <from> should a basic  filter not an `and' of
##  from. This should only be used in the file "type.g".
##
BIND_GLOBAL( "InstallTrueMethodNewFilter", function ( tofilt, from )
    local   imp;

    # Check that no filter implies `IsMutable'.
    # (If this would be allowed then `Immutable' would be able
    # to create paradoxical objects.)
    if     IS_SUBSET_FLAGS( FLAGS_FILTER( tofilt ),
                        FLAGS_FILTER( IS_MUTABLE_OBJ ) )
       and not IS_IDENTICAL_OBJ( from, IS_MUTABLE_OBJ ) then
      Error( "filter <from> must not imply `IsMutable'" );
    fi;

    imp := [];
    imp[1] := FLAGS_FILTER( tofilt );
    imp[2] := FLAGS_FILTER( from );
    ADD_LIST( IMPLICATIONS, imp );
    InstallHiddenTrueMethod( tofilt, from );
end );


#############################################################################
##
#F  InstallTrueMethod( <to>, <from> )
##
BIND_GLOBAL( "InstallTrueMethod", function ( tofilt, from )

    InstallTrueMethodNewFilter( tofilt, from );

    # clear the caches because we do not know if filter <from> is new
    CLEAR_HIDDEN_IMP_CACHE( from );
    CLEAR_IMP_CACHE();
end );


#############################################################################
##
#F  NewFilter( <name>[, <rank>] ) . . . . . . . . . . . . create a new filter
#F  NewFilter( <name>, <implied>[, <rank>] )  . . . . . . create a new filter
##
BIND_GLOBAL( "NewFilter", function( arg )
    local   name,  implied,  rank,  filter;

    if LEN_LIST( arg ) = 3  then
      name    := arg[1];
      implied := arg[2];
      rank    := arg[3];
    elif LEN_LIST( arg ) = 2  then
      if IS_INT( arg[2] ) then
        name    := arg[1];
        implied := 0;
        rank    := arg[2];
      else
        name    := arg[1];
        implied := arg[2];
        rank    := 1;
      fi;
    else
      name    := arg[1];
      implied := 0;
      rank    := 1;
    fi;

    # Create the filter.
    filter := NEW_FILTER( name );
    if implied <> 0 then
      InstallTrueMethodNewFilter( implied, filter );
    fi;

    # Do some administrational work.
    FILTERS[ FLAG1_FILTER( filter ) ] := filter;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( filter ) );
    RANK_FILTERS[ FLAG1_FILTER( filter ) ] := rank;
    INFO_FILTERS[ FLAG1_FILTER( filter ) ] := 0;

    # Return the filter.
    return filter;
end );


#############################################################################
##
#F  DeclareFilter( <name> [,<rank>] )
##
BIND_GLOBAL( "DeclareFilter", function( arg )
    BIND_GLOBAL( arg[1], CALL_FUNC_LIST( NewFilter, arg ) );
end );


#############################################################################
##
#F  NamesFilter( <flags> )  . . . . . list of names of the filters in <flags>
##
BIND_GLOBAL( "NamesFilter", function( flags )
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
            bn[i] := NAME_FUNC(FILTERS[ bn[i] ]);
        fi;
    od;
    return bn;

end );



#############################################################################
##
#F  IsFilter( <x> )
##
##  function to test whether <x> is a filter.
##  (This is *not* a filter itself!.)
##
BIND_GLOBAL( "IsFilter",
    x -> IS_OPERATION( x ) and ( FLAG1_FILTER( x ) <> 0 or x in FILTERS ) );


## Global Rank declarations

#############################################################################
##
#V  SUM_FLAGS
##
##  Is an ``infinity'' value for method installations. It is more than can
##  be reached by any filter arrangement.
BIND_GLOBAL( "SUM_FLAGS", 2000 );


#############################################################################
##
#V  GETTER_FLAGS
##
##  is the flag value used for the installation of the system getter.
BIND_GLOBAL( "GETTER_FLAGS", 2*SUM_FLAGS );


#############################################################################
##
#V  NICE_FLAGS
##
##  is the rank of `IsHandledByNiceMonomorphism'.
BIND_GLOBAL("NICE_FLAGS",QUO_INT(SUM_FLAGS,10));


#############################################################################
##
#E

