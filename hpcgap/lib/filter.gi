#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#F  IdOfFilter
##
##  <#GAPDoc Label="IdOfFilter">
##  <ManSection>
##  <Func Name="IdOfFilter" Arg="filter"/>
##  <Func Name="IdOfFilterByName" Arg="name"/>
##
##  <Description>
##  finds the id of the filter <A>filter</A>, or the id of the filter
##  with name <A>name</A> respectively.
##  The id of a filter is equal to the
##  position of this filter in the global FILTERS list.
##  <P/>
##  Note that not every <C>filter</C> for which <C>IsFilter(filter)</C>
##  returns <K>true</K> has an ID, only elementary filters do.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Note that the filter ID is stored in FLAG1_FILTER for most filters,
##  testers have the ID stored in FLAG2_FILTER, so the code below is
##  more efficient than just iterating over the FILTERS list.
##
##
BIND_GLOBAL( "IdOfFilter",
function(filter)
    local fid;
    atomic readonly FILTER_REGION do
        fid := FLAG1_FILTER(filter);
        if fid > 0 and FILTERS[fid] = filter then
            return fid;
        fi;
        fid := FLAG2_FILTER(filter);
        if fid > 0 and FILTERS[fid] = filter then
            return fid;
        fi;
    od;
    return fail;
end);

BIND_GLOBAL( "IdOfFilterByName",
function(name)
    atomic readonly FILTER_REGION do
        return PositionProperty(FILTERS, f -> NAME_FUNC(f) = name);
    od;
end);

#############################################################################
##
#F  FilterByName
##
##  <#GAPDoc Label="FilterByName">
##  <ManSection>
##  <Func Name="FilterByName" Arg="name"/>
##
##  <Description>
##  finds the filter with name <A>name</A> in the global FILTERS list. This
##  is useful to find filters that were created but not bound to a global
##  variable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "FilterByName",
function(name)
    atomic readonly FILTER_REGION do
        return First(FILTERS, f -> NAME_FUNC(f) = name);
    od;
end);

#############################################################################
##
#F  IS_IMPLIED_BY
##
##  <#GAPDoc Label="IS_IMPLIED_BY">
##  <ManSection>
##  <Func Name="IS_IMPLIED_BY" Arg="filt, prefilt"/>
##
##  <Description>
##  Return true if the flags or filter <A>filt</A> is implied by <A>prefilt</A>,
##  which can be either a filter, a flags object, or a type
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "IS_IMPLIED_BY",
function (filt, prefilt)
    local flags, preflags;

    if IsFilter(filt) then
        flags := FLAGS_FILTER(filt);
    else
        flags := filt;
    fi;

    if IsType(prefilt) then
        preflags := FlagsType(prefilt);
    elif IsFilter(prefilt) then
        preflags := FLAGS_FILTER(prefilt);
    else
        preflags := prefilt;
    fi;
    preflags := WITH_IMPS_FLAGS(preflags);

    return IS_SUBSET_FLAGS(preflags, flags);
end );
