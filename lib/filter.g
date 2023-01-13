#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler, Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with filters.
##

#############################################################################
##
#V  FILTERS . . . . . . . . . . . . . . . . . . . . . . . list of all filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  elementary filter with number <i> resp. its rank. Note that and-filters
##  are not elementary and hence not contained in this list.
##
BIND_GLOBAL( "FILTERS", [] );
if IsHPCGAP then
    LockAndMigrateObj(FILTERS, FILTER_REGION);
fi;


#############################################################################
##
#V  RANK_FILTERS  . . . . . . . . . . . . . . . . list of all rank of filters
##
##  <FILTERS>  and  <RANK_FILTERS> are  lists containing at position <i>  the
##  filter with number <i> resp.  its rank.
##
BIND_GLOBAL( "RANK_FILTERS", [] );
if IsHPCGAP then
    LockAndMigrateObj(RANK_FILTERS, FILTER_REGION);
fi;


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
##   5 = attribute tester kernel
##   6 = attribute tester
##   7 = property kernel
##   8 = tester of 7
##   9 = property
##  10 = tester of 9
##
BIND_GLOBAL( "INFO_FILTERS", [] );
if IsHPCGAP then
    LockAndMigrateObj(INFO_FILTERS, FILTER_REGION);
fi;

BIND_CONSTANT( "FNUM_CAT_KERN", 1 );
BIND_CONSTANT( "FNUM_CAT", 2 );
BIND_CONSTANT( "FNUM_REP_KERN", 3 );
BIND_CONSTANT( "FNUM_REP", 4 );
BIND_CONSTANT( "FNUM_ATTR_KERN", 5 );
BIND_CONSTANT( "FNUM_ATTR", 6 );
BIND_CONSTANT( "FNUM_PROP_KERN", 7 );
BIND_CONSTANT( "FNUM_PROP", 9 );
BIND_CONSTANT( "FNUM_TPR_KERN", 8 );
BIND_CONSTANT( "FNUM_TPR", 10 );

BIND_GLOBAL( "FNUM_CATS", MakeImmutable([ FNUM_CAT_KERN, FNUM_CAT ]) );
BIND_GLOBAL( "FNUM_REPS", MakeImmutable([ FNUM_REP_KERN, FNUM_REP ]) );
BIND_GLOBAL( "FNUM_ATTS", MakeImmutable([ FNUM_ATTR_KERN, FNUM_ATTR ]) );
BIND_GLOBAL( "FNUM_PROS", MakeImmutable([ FNUM_PROP_KERN, FNUM_PROP ]) );
BIND_GLOBAL( "FNUM_TPRS", MakeImmutable([ FNUM_TPR_KERN, FNUM_TPR ]) );

BIND_GLOBAL( "FNUM_CATS_AND_REPS",
                MakeImmutable([ FNUM_CAT_KERN, FNUM_CAT,
                                FNUM_REP_KERN, FNUM_REP ]) );


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
#F  InstallTrueMethodNewFilter( <tofilt>, <from> )
##
##  If <from> is a new filter then  it cannot occur in  the cache.  Therefore
##  we do not flush the cache.  <from> should a basic  filter not an `and' of
##  from. This should only be used in the file "type.g".
##
BIND_GLOBAL( "InstallTrueMethodNewFilter", function ( tofilt, from )
    local   imp, found, imp2;

    # Check that no filter implies `IsMutable'.
    # (If this would be allowed then `Immutable' would be able
    # to create paradoxical objects.)
    if     IS_SUBSET_FLAGS( FLAGS_FILTER( tofilt ),
                        FLAGS_FILTER( IS_MUTABLE_OBJ ) )
       and not IS_IDENTICAL_OBJ( from, IS_MUTABLE_OBJ ) then
      Error( "filter <from> must not imply `IsMutable'" );
    fi;

    # If 'tofilt' equals 'IsObject' then do nothing.
    if IS_IDENTICAL_OBJ( tofilt, IS_OBJECT ) then
      return;
    fi;

    # Apply the available implications from 'tofilt and from' to 'tofilt'.
    imp := [];
    imp[1] := WITH_IMPS_FLAGS( AND_FLAGS( FLAGS_FILTER( tofilt ),
                                          FLAGS_FILTER( from ) ) );
    imp[2] := FLAGS_FILTER( from );

    atomic IMPLICATIONS_SIMPLE do
      # Extend available implications by the new one if applicable.
      found:= false;
      for imp2 in IMPLICATIONS_SIMPLE do
        if IS_SUBSET_FLAGS( imp2[2], imp[2] )
           or IS_SUBSET_FLAGS( imp2[1], imp[2] ) then
          imp2[1]:= AND_FLAGS( imp2[1], imp[1] );
          if IS_EQUAL_FLAGS( imp2[2], imp[2] ) then
            found:= true;
          fi;
        fi;
      od;
      for imp2 in IMPLICATIONS_COMPOSED do
        if IS_SUBSET_FLAGS( imp2[2], imp[2] )
           or IS_SUBSET_FLAGS( imp2[1], imp[2] ) then
          imp2[1]:= AND_FLAGS( imp2[1], imp[1] );
          if IS_EQUAL_FLAGS( imp2[2], imp[2] ) then
            found:= true;
          fi;
        fi;
      od;

      if not found then
        # Extend the list of implications.
        if IsHPCGAP then
          MIGRATE_RAW(imp, IMPLICATIONS_SIMPLE);
        fi;
        if IS_AND_FILTER(from) then
          ADD_LIST( IMPLICATIONS_COMPOSED, imp );
        else
          IMPLICATIONS_SIMPLE[ TRUES_FLAGS( imp[2] )[1] ]:= imp;
        fi;
      fi;
    od;
    if not GAPInfo.CommandLineOptions.N then
      InstallHiddenTrueMethod( tofilt, from );
    fi;
end );


#############################################################################
##
#F  SuspendMethodReordering( )
#F  ResumeMethodReordering( )
#F  ResetMethodReordering( )
##
##  <#GAPDoc Label="MethodReordering">
##  <ManSection>
##  <Func Name="SuspendMethodReordering" Arg=""/>
##  <Func Name="ResumeMethodReordering" Arg=""/>
##  <Func Name="ResetMethodReordering" Arg=""/>
##
##  <Description>
##  These functions control whether the method reordering process described
##  in <Ref Func="InstallTrueMethod"/> is invoked or not. Since this process
##  can be comparatively time-consuming, it is usually suspended when a lot
##  of implications are due to be installed, for instance when loading the
##  library, or a package. This is done by calling
##  <Ref Func="SuspendMethodReordering"/> once the installations are done,
##  <Ref Func="ResumeMethodReordering"/> should be called. These pairs of calls
##  can be nested. When the outermost pair is complete, method reordering
##  takes place and is enabled in <Ref Func="InstallTrueMethod"/> thereafter.
##
##  <Ref Func="ResetMethodReordering"/> effectively exits all nested suspensions,
##  resuming reordering immediately. This function is mainly provided for
##  error recovery and similar purposes and is called on quitting from a
##  break loop.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

#
# This function will be defined in oper.g
#
RECALCULATE_ALL_METHOD_RANKS := fail;

REORDER_METHODS_SUSPENSION_LEVEL := 1;

BIND_GLOBAL( "SuspendMethodReordering", function()
    REORDER_METHODS_SUSPENSION_LEVEL := REORDER_METHODS_SUSPENSION_LEVEL + 1;
end);


BIND_GLOBAL( "ResumeMethodReordering", function()
    if REORDER_METHODS_SUSPENSION_LEVEL > 0 then
        REORDER_METHODS_SUSPENSION_LEVEL := REORDER_METHODS_SUSPENSION_LEVEL - 1;
    fi;
    if REORDER_METHODS_SUSPENSION_LEVEL <= 0 then
        RECALCULATE_ALL_METHOD_RANKS();
    fi;
end);

BIND_GLOBAL( "ResetMethodReordering", function()
    REORDER_METHODS_SUSPENSION_LEVEL := 0;
    RECALCULATE_ALL_METHOD_RANKS();
end);


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
##  <C>IsGroup and IsCyclic</C> whose type gets created after the
##  installation of the implication will also be in the filter
##  <Ref Prop="IsCommutative"/>.
##  In particular, it may happen that an object which existed already before
##  the installation of the implication lies in <C>IsGroup and IsCyclic</C>
##  but not in <Ref Prop="IsCommutative"/>.
##  Thus it is advisable to install all implications between filters
##  before one starts creating (types of) objects lying in these filters.
##  <P/>
##  Adding logical implications can change the rank of filters (see
##  <Ref Func="RankFilter"/>) and consequently the rank, and so choice of
##  methods for operations (see <Ref Sect="Applicable Methods and Method Selection"/>).
##  By default <Ref Func="InstallTrueMethod"/> adjusts the method selection
##  data structures to take care of this,
##  but this process can be time-consuming,
##  so functions <Ref Func="SuspendMethodReordering"/> and
##  <Ref Func="ResumeMethodReordering"/> are provided to allow control of this process.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallTrueMethod", function ( tofilt, from )
    local fromflags, i;

    # Check whether 'tofilt' involves or implies representations.
    fromflags:= TRUES_FLAGS( WITH_IMPS_FLAGS( FLAGS_FILTER( from ) ) );
    for i in TRUES_FLAGS( WITH_IMPS_FLAGS( FLAGS_FILTER( tofilt ) ) ) do
      if INFO_FILTERS[i] = FNUM_REP_KERN or INFO_FILTERS[i] = FNUM_REP then
        # This is allowed only if 'from' already implies filter 'i'.
        if not i in fromflags then
          Error( "<tofilt> must not involve new representation filters" );
        fi;
      fi;
    od;

    InstallTrueMethodNewFilter( tofilt, from );

    # clear the caches because we do not know if filter <from> is new
    CLEAR_HIDDEN_IMP_CACHE( from );
    CLEAR_IMP_CACHE();

    # maybe rerank methods to take account of new implication
    if REORDER_METHODS_SUSPENSION_LEVEL = 0 then
        RECALCULATE_ALL_METHOD_RANKS();
    fi;
end );


#############################################################################
##
#F  NewFilter( <name>[, <implied>][, <rank>] )  . . . . . create a new filter
##
##  <#GAPDoc Label="NewFilter">
##  <ManSection>
##  <Func Name="NewFilter" Arg="name[, implied][, rank]"/>
##
##  <Description>
##  <Ref Func="NewFilter"/> returns a simple filter with name <A>name</A>
##  (see&nbsp;<Ref Sect="Other Filters"/>).
##  <P/>
##  The optional argument <A>implied</A>, if given, must be a filter,
##  meaning that for each object in the new filter, also <A>implied</A>
##  will be set.
##  Note that resetting the new filter with <Ref Func="ResetFilterObj"/>
##  does <E>not</E> reset <A>implied</A>.
##  If the new filter is intended to be set or reset manually for existing
##  objects then the argument <A>implied</A> will cause trouble;
##  if the filter is not intended to be set or reset manually then perhaps
##  calling <Ref Func="NewCategory"/> is more appropriate than
##  calling <Ref Func="NewFilter"/>.
##  <P/>
##  The optional argument <A>rank</A> denotes the incremental rank
##  (see&nbsp;<Ref Sect="Filters"/>) of the filter,
##  the default value is 1.
##  <P/>
##  The default value of the new simple filter for each object is
##  <K>false</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "REGISTER_FILTER", function( filter, id, rank, info )
    atomic FILTER_REGION do
      FILTERS[id] := filter;
      IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( filter ) );
      RANK_FILTERS[id] := rank;
      INFO_FILTERS[id] := info;
    od;
end );

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

    # Do some administrational work.
    REGISTER_FILTER( filter, FLAG1_FILTER( filter ), rank, 0 );

    if implied <> 0 then
      InstallTrueMethodNewFilter( implied, filter );
    fi;

    # Return the filter.
    return filter;
end );


#############################################################################
##
#F  DeclareFilter( <name>[, <implied>][, <rank>] )
##
##  <#GAPDoc Label="DeclareFilter">
##  <ManSection>
##  <Func Name="DeclareFilter" Arg="name[, implied][, rank]"/>
##
##  <Description>
##  does the same as <Ref Func="NewFilter"/> and then binds
##  the result to the global variable <A>name</A>. The variable
##  must previously be writable, and is made read-only by this function.
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
#F  IS_ELEMENTARY_FILTER( <x> )
##
##  function to test whether <x> is an elementary filter.
##
BIND_GLOBAL( "IS_ELEMENTARY_FILTER", function(x)
    atomic readonly FILTER_REGION do
       return x in FILTERS;
    od;
end);


#############################################################################
##
#F  IsFilter( <x> )
##
##  function to test whether <x> is a filter.
##  (This is *not* a filter itself!.)
##  We handle IsObject as a special case, as it is equal to ReturnTrue,
##  as all objects satisfy IsObject!
##
BIND_GLOBAL( "IsFilter", IS_FILTER );


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
    local   rank,  flags,  all,  i;

    rank  := 0;
    if IS_FUNCTION(filter)  then
        flags := FLAGS_FILTER(filter);
    else
        flags := filter;
    fi;
    if not GAPInfo.CommandLineOptions.N then
      all := WITH_HIDDEN_IMPS_FLAGS(flags);
    else
      all := WITH_IMPS_FLAGS(flags);
    fi;
    atomic readonly FILTER_REGION do
      for i  in TRUES_FLAGS(all)  do
          rank := rank + RANK_FILTERS[i];
      od;
    od;
    return rank;
end );
