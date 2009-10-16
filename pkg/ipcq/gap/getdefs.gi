#############################################################################
##
#W  getdefs.gi                    ipcq package                   Bettina Eick
##

#############################################################################
##
#F InverseDepth( vec, ignore )
##
InverseDepth := function( vec, ignore )
    local j;
    if IsBool( vec ) then return false; fi;
    for j in Reversed( [1..Length(vec)] ) do
        if not IsBound( ignore[j] ) and vec[j] <> 0 * vec[j] then
            return j;
        fi;
    od;
    return false;
end;

#############################################################################
##
#F NotAll( defs, d )
##
NotAll := function( defs, d )
    return not IsDenseList( defs ) or Length( defs ) < d;
end;

#############################################################################
##
#F GetDefinitions( M, N )
##
GetDefinitions := function( M, N )
    local m, t, d, defs, try, pctails, fptails, optails, i, e, j, deps;

    # some info and set up
    m := Length( N.opers );
    d := Length( N.opers[1] );
    t := Length( N.tails );
    defs := [];

    # first try pctails
    try := true;
    pctails := N.tails{[1..M.first-1]};
    while try and NotAll( defs, d ) do
        try := false;

        # get new deps
        deps := List( pctails, x -> InverseDepth( x, defs ) );

        # add them
        for i in [1..Length(deps)] do
            e := deps[i];
            if not IsBool( e ) and not IsBound( defs[e] ) then 
                defs[e] := i;
                pctails[i] := false; 
                try := true;
            fi;
        od;
    od;

    # next try operation
    try := true;
    optails := StructuralCopy( N.opers );
    while try and NotAll( defs, d ) do
        try := false;

        for j in [1..m] do
            for i in [1..d] do
                if IsBound( defs[i] ) then
                    e := InverseDepth( optails[j][i], defs );
                    if not IsBool( e ) and not IsBound( defs[e] ) then
                        defs[e] := [i, j];
                        optails[j][i] := false;
                        try := true;
                    fi;
                fi;
            od;
        od;
    od;

    # now try fptails
    try := true;
    fptails := N.tails{[M.first..Length(N.tails)]};
    while try and NotAll( defs, d ) do
        try := false;

        # get new deps
        deps := List( fptails, x -> InverseDepth( x, defs ) );

        # add them
        for i in [1..Length(deps)] do
            e := deps[i];
            if not IsBool( e ) and not IsBound( defs[e] ) then
                defs[e] := M.first - 1 + i;
                fptails[i] := false;
                try := true;
            fi;
        od;
    od;

    # finally try operation again
    try := true;
    optails := StructuralCopy( N.opers );
    while try and NotAll( defs, d ) do
        try := false;

        for j in [1..m] do
            for i in [1..d] do
                if IsBound( defs[i] ) then
                    e := InverseDepth( optails[j][i], defs );
                    if not IsBool( e ) and not IsBound( defs[e] ) then
                        defs[e] := [i, j];
                        optails[j][i] := false;
                        try := true;
                    fi;
                fi;
            od;
        od;
    od;

    # rewrite integer defs
    for i in [1..d] do
        if IsInt( defs[i] ) then
            defs[i] := M.used[defs[i]];
        fi;
    od;

    return defs;
end;
