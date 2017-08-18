##
##  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
##  Copyright (C) 2002 The GAP Group
##
##  This software is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#############################################################################
##
#V  IdOfFilter
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
##  returns <C>true</C> has an ID, only elementary filters do.
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
             name -> PositionProperty(FILTERS, f -> NAME_FUNC(f) = name) );

#############################################################################
##
#V  FilterByName
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
             name -> First(FILTERS, f -> NAME_FUNC(f) = name) );
