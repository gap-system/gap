#############################################################################
##
#W  session.g                    GAP library                 Steve Linton
##
#H  @(#)$Id: session.g,v 4.4 2007/12/18 15:54:49 sal Exp $
##
#Y  Copyright (C) 2007 The GAP Group
##
##  This file contains GAP functions which define the structure of a GAP session
##  SESSION is called from init.g or from POST_RESTORE depending on whether 
##  this is a normal startup or startup from saved workspace
##
Revision.session_g :=
    "@(#)$Id: session.g,v 4.4 2007/12/18 15:54:49 sal Exp $";


OnGAPPromptHook := fail; # set some values to suppress warning
SaveOnExitFile := fail;
AT_EXIT_FUNCS := [];

ADD_LIST(AT_EXIT_FUNCS, function()
    if not QUITTING and IsBound(SaveOnExitFile)  and
       IsString(SaveOnExitFile) then
        SaveWorkspace(SaveOnExitFile);
    fi;   
end);

BIND_GLOBAL("SESSION", 
    function()
    local   f, prompt;
    
    if GAPInfo.CommandLineOptions.q or 
       (IsBound(GAPInfo.CommandLineOptionsRestore) and GAPInfo.CommandLineOptionsRestore.q) then
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
    if IsBound(AT_EXIT_FUNCS) and IsList(AT_EXIT_FUNCS) then
        for f in AT_EXIT_FUNCS do
            if IsFunction(f) then
                CALL_WITH_CATCH(f,[]);        # really should be CALL_WITH_CATCH here
            fi;
        od;
    fi;
    
end);


BindGlobal("POST_RESTORE", function()
    local   f;
    for f in POST_RESTORE_FUNCS do
        if IsFunction(f) then
            f();
        fi;
    od;
    SESSION();
end);


    
