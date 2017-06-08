#############################################################################
##
#W  function.gi                GAP library                     Steve Linton
##
##
#Y  Copyright (C) 2015 The GAP Group
##
##  This file contains the implementations of the functions and operations
##  relating to functions and function-calling which are not so basic
##  that they need to be in function.g
##

InstallMethod( ViewString, "for a function", true, [IsFunction], 0,
function(func)
    local  locks, nams, narg, i, isvarg, result;
    result := "";
    isvarg := false;
    locks := LOCKS_FUNC(func);
    if locks <> fail then
        Append(result, "atomic ");
    fi;
    Append(result, "function( ");
    nams := NAMS_FUNC(func);
    narg := NARG_FUNC(func);
    if narg < 0 then
        isvarg := true;
        narg := -narg;
    fi;
    if narg = 1 and nams <> fail and nams[1] = "arg" then
        isvarg := true;
    fi;
    if narg <> 0 then
        if nams = fail then
            Append(result, STRINGIFY("<",narg," unnamed arguments>"));
        else
            if locks <> fail then
                if locks[1] = '\001' then
                    Append(result, "readonly ");
                elif locks[1] = '\002' then
                    Append(result, "readwrite ");
                fi;
            fi;
            Append(result, nams[1]);
            for i in [2..narg] do
                if locks <> fail then
                    if locks[i] = '\001' then
                        Append(result, "readonly ");
                    elif locks[i] = '\002' then
                        Append(result, "readwrite ");
                    fi;
                fi;
                Append(result, STRINGIFY(", ",nams[i]));
            od;
        fi;
        if isvarg then
            Append(result, "...");
        fi;
    fi;
    Append(result, " ) ... end");
    return result;
end);
