#############################################################################
##
#W  session.g                    GAP library                 Steve Linton
##
##
#Y  Copyright (C) 2007 The GAP Group
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
    local f;
    if IsBound( GAPInfo.AtExitFuncs ) and IsList( GAPInfo.AtExitFuncs ) then
        for f in GAPInfo.AtExitFuncs do
            if IsFunction(f) then
                CALL_WITH_CATCH(f,[]);        # really should be CALL_WITH_CATCH here
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


BindGlobal("POST_RESTORE", function()
    local   f;
    for f in GAPInfo.PostRestoreFuncs do
        if IsFunction(f) then
            f();
        fi;
    od;
    SESSION();
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

