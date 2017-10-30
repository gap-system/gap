#############################################################################
##
#W  filter.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schönert
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with filters.
##

#############################################################################
##
#V  FILTERS . . . . . . . . . . . . . . . . . . . . . . . list of all filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
BIND_GLOBAL( "FILTERS", LockAndMigrateObj([], FILTER_REGION) );


#############################################################################
##
#V  RANK_FILTERS  . . . . . . . . . . . . . . . . list of all rank of filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
BIND_GLOBAL( "RANK_FILTERS", LockAndMigrateObj([], FILTER_REGION) );


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
BIND_GLOBAL( "INFO_FILTERS", LockAndMigrateObj([], FILTER_REGION) );

BIND_GLOBAL( "FNUM_CATS", MakeImmutable([ 1,  2 ]) );
BIND_GLOBAL( "FNUM_REPS", MakeImmutable([ 3,  4 ]) );
BIND_GLOBAL( "FNUM_ATTS", MakeImmutable([ 5,  6 ]) );
BIND_GLOBAL( "FNUM_PROS", MakeImmutable([ 7,  9 ]) );
BIND_GLOBAL( "FNUM_TPRS", MakeImmutable([ 8, 10 ]) );


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

    atomic IMPLICATIONS do
    imp := [];
    imp[1] := FLAGS_FILTER( tofilt );
    imp[2] := FLAGS_FILTER( from );
    MIGRATE_RAW(imp, IMPLICATIONS);
    ADD_LIST( IMPLICATIONS, imp );
    od;
    InstallHiddenTrueMethod( tofilt, from );
end );


#############################################################################
##
#F  InstallTrueMethod( <newfil>, <filt> )
##
##  <#GAPDoc Label="InstallTrueMethod">
##  <ManSection>
##  <Func Name="InstallTrueMethod" Arg="newfil, filt"/>
##
##  <Description>
##  It may happen that a filter <A>newfil</A> shall be implied by another
##  filter <A>filt</A>, which is usually a meet of other properties,
##  or the meet of some properties and some categories.
##  Such a logical implication can be installed as an <Q>immediate method</Q>
##  for <A>newfil</A> that requires <A>filt</A> and that always returns
##  <K>true</K>.
##  (This should not be mixed up with the methods installed via
##  <Ref Func="InstallImmediateMethod"/>, which have to be called at runtime
##  for the actual objects.)
##  <P/>
##  <Ref Func="InstallTrueMethod"/> has the effect that <A>newfil</A> becomes
##  an implied filter of <A>filt</A>,
##  see&nbsp;<Ref Sect="Filters"/>.
##  <P/>
##  For example, each cyclic group is abelian,
##  each finite vector space is finite dimensional,
##  and each division ring is integral.
##  The first of these implications is installed as follows.
##  <P/>
##  <Log><![CDATA[
##  InstallTrueMethod( IsCommutative, IsGroup and IsCyclic );
##  ]]></Log>
##  <P/>
##  Contrary to the immediate methods installed with
##  <Ref Func="InstallImmediateMethod"/>, logical implications cannot be
##  switched off.
##  This means that after the above implication has been installed,
##  one can rely on the fact that every object in the filter
##  <C>IsGroup and IsCyclic</C> will also be in the filter
##  <Ref Func="IsCommutative"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallTrueMethod", function ( tofilt, from )

    InstallTrueMethodNewFilter( tofilt, from );

    # clear the caches because we do not know if filter <from> is new
    CLEAR_HIDDEN_IMP_CACHE( from );
    CLEAR_IMP_CACHE();
end );


#############################################################################
##
#F  NewFilter( <name>[, <implied>][, <rank>] )  . . . . . create a new filter
##
##  <#GAPDoc Label="NewFilter">
##  <ManSection>
##  <Func Name="NewFilter" Arg="name[, rank]"/>
##
##  <Description>
##  <Ref Func="NewFilter"/> returns a simple filter with name <A>name</A>
##  (see&nbsp;<Ref Sect="Other Filters"/>).
##  The optional second argument <A>rank</A> denotes the incremental rank
##  (see&nbsp;<Ref Sect="Filters"/>) of the filter,
##  the default value is 1.
##  <P/>
##  The default value of the new simple filter for each object is
##  <K>false</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
    atomic FILTER_REGION do
    FILTERS[ FLAG1_FILTER( filter ) ] := filter;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( filter ) );
    RANK_FILTERS[ FLAG1_FILTER( filter ) ] := rank;
    INFO_FILTERS[ FLAG1_FILTER( filter ) ] := 0;
    od;

    # Return the filter.
    return filter;
end );


#############################################################################
##
#F  DeclareFilter( <name>[, <implied>][, <rank>] )
##
##  <#GAPDoc Label="DeclareFilter">
##  <ManSection>
##  <Func Name="DeclareFilter" Arg="name[, rank]"/>
##
##  <Description>
##  does the same as <Ref Func="NewFilter"/>
##  and additionally makes the variable <A>name</A> read-only.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
    atomic readonly FILTER_REGION do
    for i  in  [ 1 .. LEN_LIST(bn) ]  do
        if not IsBound(FILTERS[ bn[i] ])  then
            bn[i] := STRING_INT( bn[i] );
        else
            bn[i] := NAME_FUNC(FILTERS[ bn[i] ]);
        fi;
    od;
    od;
    return bn;

end );



#############################################################################
##
#F  IsFilter( <x> )
##
##  function to test whether <x> is a filter.
##  (This is *not* a filter itself!.)
##  We handle IsObject as a special case, as it is equal to ReturnTrue,
##  as all objects satisfy IsObject!
##
BIND_GLOBAL( "IS_FILTER_ATOMIC", function(x)
    atomic readonly FILTER_REGION do
       return x in FILTERS;
    od;
end);

BIND_GLOBAL( "IsFilter",
    x -> IS_IDENTICAL_OBJ(x, IS_OBJECT)
         or ( IS_OPERATION( x )
              and ( (FLAG1_FILTER( x ) <> 0 and FLAGS_FILTER(x) <> false)
                    or IS_FILTER_ATOMIC(x) ) ) );


## Global Rank declarations

#############################################################################
##
#V  SUM_FLAGS
##
##  Is an ``infinity'' value for method installations. It is more than can
##  be reached by any filter arrangement.
BIND_GLOBAL( "SUM_FLAGS", 10000 );


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
BIND_GLOBAL("NICE_FLAGS",QUO_INT(SUM_FLAGS,30));


#############################################################################
##
#V  CANONICAL_BASIS_FLAGS
##
##  is the incremental rank used for `Basis' methods that delegate to
##  `CanonicalBasis'.
##
BIND_GLOBAL( "CANONICAL_BASIS_FLAGS", QUO_INT(SUM_FLAGS,5) );


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
    atomic readwrite FILTER_REGION do
    for i  in TRUES_FLAGS(WITH_HIDDEN_IMPS_FLAGS(flags))  do
        if IsBound(RANK_FILTERS[i])  then
            rank := rank + RANK_FILTERS[i];
        else
            rank := rank + 1;
        fi;
    od;
    return rank;
    od;
end );


#############################################################################
##
#E
