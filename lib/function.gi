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


#############################################################################
##
#F  CallWithTimeout( <timeout>, <func>[, <arg1>[, <arg2>....]] )  
##         . . call a function with a time limit
#F  CallWithTimeoutList( <timeout>, <func>, <arglist> )  
##
##

InstallGlobalFunction(CallWithTimeout, 
        function( timeout, func, arg... )
    return CallWithTimeoutList(timeout, func, arg);
end );

InstallGlobalFunction("CallWithTimeoutList",
        function(timeout, func, arglist )
    local  process, nano, seconds, microseconds;
    process := function(name, scale)
        local  val;
        if IsBound(timeout.(name)) then
            val := timeout.(name);
            if IsRat(val) or IsFloat(val) then
                nano := nano + Int(val*scale);
            else
                Error("CallWithTimeout[List]: can't understand period of ",val," ",name,". Ignoring.");
            fi;
        fi;
    end;
    if not GAPInfo.TimeoutsSupported then
        Error("Calling with time limits not supported in this GAP installation");
        return fail;
    fi;
    if IsInt(timeout) then
        nano := 1000*timeout;
    else
        if not IsRecord(timeout) then
            Error("CallWithTimeout[List]: timeout must be an integer or record");
            return fail;
        fi;
        nano := 0;
        process("nanoseconds",1);
        process("microseconds",1000);
        process("milliseconds",1000000);
        process("seconds",10^9);
        process("minutes",60*10^9);
        process("hours",3600*10^9);
        process("days",24*3600*10^9);
        process("weeks",7*24*3600*10^9);
    fi;
    if nano < 0 then
        Error("Negative timeout is not permitted");
        return fail;
    fi;
    seconds := QuoInt(nano, 10^9);
    microseconds := QuoInt(nano mod 10^9, 1000);
    if seconds = 0 and microseconds = 0 then
        # zero or tiny timeout. just simulate timeout now
        return fail;
    fi;
    # make sure it's a small int. Cap timeouts at about 8 years on
    # 32 bit systems
    seconds := Minimum(seconds,2^(8*GAPInfo.BytesPerVariable-4)-1);
    return CALL_WITH_TIMEOUT(seconds, microseconds, func, arglist);
end);

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
