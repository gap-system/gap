#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementations of the functions and operations
##  relating to functions and function-calling which are not so basic
##  that they need to be in function.g
##

InstallMethod( ViewString, "for a function", [IsFunction and IsInternalRep],
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

InstallMethod(Display, "for a function", [IsFunction and IsInternalRep],
function(fun)
    local loc;
    loc := FilenameFunc(fun);
    if loc <> fail and loc <> "stream" and loc <> "*stdin*" and loc <> "*errin*" then
        loc := LocationFunc(fun);
        if loc <> fail then
            Print("# ", loc, "\n");
        fi;
    fi;
    Print(fun, "\n");
end);

InstallMethod(DisplayString, "for a function, using string stream", [IsFunction and IsInternalRep],
function(fun)
    local  s, stream;
    s := "";
    stream := OutputTextString(s, true);
    PrintTo(stream, fun);
    CloseStream(stream);
    Add(s, '\n');
    return MakeImmutable(s);
end);

InstallMethod(String, "for a function, with whitespace reduced", [IsFunction and IsInternalRep],
function(fun)
    local  s, stream;
    s := "";
    stream := OutputTextString(s, true);
    SetPrintFormattingStatus(stream, false);
    PrintTo(stream, fun);
    CloseStream(stream);
    return ReplacedString(s, "\n", " ");
end);

BIND_GLOBAL( "VIEW_STRING_OPERATION",
function ( op )
    return STRINGIFY("<", TypeOfOperation(op),
                     " \"", NAME_FUNC(op), "\">");
end);

BIND_GLOBAL( "PRINT_OPERATION",
function ( op )
    Print(VIEW_STRING_OPERATION(op));
end);

InstallMethod( ViewObj,
    "for an operation",
    [ IsOperation ],
    PRINT_OPERATION );

InstallMethod( ViewString,
    "for an operation",
    [ IsOperation ],
function(op)
    return VIEW_STRING_OPERATION(op);
end);

InstallMethod( SetNameFunction, [IsFunction and IsInternalRep, IS_STRING], SET_NAME_FUNC );

BIND_GLOBAL( "BindingsOfClosure",
function(f)
    local x, r, i;
    x := ENVI_FUNC(f);
    if x = fail then return fail; fi;
    r := rec();
    while x <> GetBottomLVars() do
        x := ContentsLVars(x);
        if x = false then break; fi;
        for i in [1..Length(x.names)] do
            # respect the lookup order
            if not IsBound(r.(x.names[i])) then
                r.(x.names[i]) := x.values[i];
            fi;
        od;
        x := ENVI_FUNC(x.func);
    od;
    return r;
end);
