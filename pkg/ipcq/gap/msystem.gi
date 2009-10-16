############################################################################
##
#W  msystem.gi                  ipcq package                    Bettina Eick    
##

#############################################################################
##
#F MSystem( Q, avoid )
##
## avoid is a record with entries .pcrels and .fprels. Both can be either
## true or lists of indices (independently). If one of the entries is true,
## then the corresponding tails are avoided. If the entry is a list, then 
## it refers to the indices of those tails which should be avoided.
##
MSystem := function( Q, avoid )
    local M;

    M := rec();

    # enter numbers of tails
    M.nrpct := Length( Q.pcenum );
    M.nrfpt := Length( Q.imgs );
    M.nrtails := M.nrpct + M.nrfpt;

    # enter avoided tails
    M.avoid := [];
    if IsBound( avoid.pcrels ) and avoid.pcrels = true then
        Append( M.avoid, [1..M.nrpct] );
    elif IsBound( avoid.pcrels ) and IsList( avoid.pcrels ) then
        Append( M.avoid, avoid.pcrels );
    fi;
    if IsBound( avoid.fprels ) and avoid.fprels = true then
        Append( M.avoid, M.nrpct + [1..M.nrfpt] );
    elif IsBound( avoid.fprels ) and IsList( avoid.fprels ) then
        Append( M.avoid, M.nrpct + avoid.fprels );
    fi;
    M.avoid := Set( M.avoid );
    M.used := Difference( [1..M.nrtails], M.avoid );

    # check splitting
    M.split := IsSubset( M.avoid, [1..M.nrpct] );

    # get the dimensions of M
    M.rows := Length( M.used );
    M.cols := 0;
    M.tails := List( M.used, x -> [] );

    # this is it
    return M;
end;

MSystemByWords := function( Q, avoid, field )
    local M;
    M := MSystem( Q, avoid );
    M.field := field;
    M.gens := Q.pcgens;
    M.invs := List( M.gens, x -> x^-1 );
    M.word := true;
    return M;
end;

MSystemByMats := function( Q, avoid, field, mats )
    local M, e;
    M := MSystem( Q, avoid );
    M.field := field;
    M.gens := mats;
    M.invs := List( M.gens, x -> x^-1 );
    M.word := false;
    return M;
end;

#############################################################################
##
#F AddToMSystem( M, tail )
##
AddToMSystem := function( M, tail )
    local i;
    M.cols := M.cols + 1;
    for i in [1..M.rows] do
        if IsBound( tail[i] ) then
            M.tails[i][M.cols] := StructuralCopy( tail[i] );
        else
            M.tails[i][M.cols] := [];
        fi;
    od;
end;

#############################################################################
##
#F AddTailPair( M, t1, t2 )
##
AddTailPair := function( M, t1, t2  )
    local t, i;

    # the trivial case
    if t1 = t2 then return false; fi;

    # subtract t1 - t2 into t1
    SubtractTails( t1, t2, M.word );

    # get rid of trivial entries
    if M.word then
        for i in [1..Length(t1)] do
            if IsBound( t1[i] ) then
                t1[i] := Filtered( t1[i], x -> x[1] <> 0 );
                if Length( t1[i] ) = 0 then Unbind( t1[i] ); fi;
            fi;
        od;
    fi;

    # add it to the system
    if Length( t1 ) > 0 then
        AddToMSystem( M, t1 );
        return true;
    else
        return false;
    fi;
end;


