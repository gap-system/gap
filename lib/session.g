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
##  This file contains GAP functions which define the structure of a GAP session
##  SESSION is called from init.g or from POST_RESTORE depending on whether
##  this is a normal startup or startup from saved workspace
##


OnGAPPromptHook := fail; # set some values to suppress warning
SaveOnExitFile := fail;

InstallAtExit( function()
    if not QUITTING and IsBound(SaveOnExitFile)  and
       IsString(SaveOnExitFile) then
        SaveWorkspace(SaveOnExitFile);
    fi;
end);

BIND_GLOBAL("PROGRAM_CLEAN_UP", function()
    local f, funcs;
    if IsBound( GAPInfo.AtExitFuncs ) and IsList( GAPInfo.AtExitFuncs ) then
        if IsHPCGAP then
            funcs := FromAtomicList(GAPInfo.AtExitFuncs);
        else
            funcs := GAPInfo.AtExitFuncs;
        fi;
        while not IsEmpty(funcs) do
            f := Remove(funcs);
            if IsFunction(f) then
                CALL_WITH_CATCH(f,[]);
            fi;
        od;
    fi;
end);

BIND_GLOBAL("SESSION",
    function()
    local   prompt;

    if GAPInfo.CommandLineOptions.q then
        prompt := "";
    else
        prompt := "gap> ";
    fi;

    SHELL( GetBottomLVars(), # in global context
        false, # no return
        false, # no return  obj
        3,     # set last, last2 and last3 each command
        true,  # set time after each command
        prompt,
        function()
            if IsBound(OnGAPPromptHook) and IsFunction(OnGAPPromptHook) then
                OnGAPPromptHook();
            else
                return;
            fi;
        end,
        "*stdin*",
        "*stdout*",
        true);

    BreakOnError := false;
end);


BindGlobal("POST_RESTORE", function()
    local   f;
    for f in GAPInfo.PostRestoreFuncs do
        if IsFunction(f) then
            f();
        fi;
    od;
    if not GAPInfo.CommandLineOptions.norepl then
        SESSION();
    fi;
    PROGRAM_CLEAN_UP();
end);

if IsHPCGAP then

    BIND_GLOBAL("THREAD_SESSION",
        function()
        local   f, prompt;

        if GAPInfo.CommandLineOptions.q then
            prompt := "";
        else
            prompt := "gap> ";
        fi;

        SHELL( GetBottomLVars(), # in global context
            false, # no return
            false, # no return  obj
            3,     # set last, last2 and last3 each command
            true,  # set time after each command
            prompt,
            function()
                if IsBound(OnGAPPromptHook) and IsFunction(OnGAPPromptHook) then
                    OnGAPPromptHook();
                else
                    return;
                fi;
            end,
            "*defin*",
            "*defout*",
            true);

        BreakOnError := false;
    end);



    DEFAULT_INPUT_STREAM := function()
        if CurrentThread() = 0 then
            return "*stdin*";
        else
            return InputTextNone();
        fi;
    end;

    DEFAULT_OUTPUT_STREAM := function()
        return "*stdout*";
    end;

fi;
