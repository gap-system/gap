#############################################################################
##
#W  error.g                    GAP library                 Steve Linton
##
##
#Y  Copyright (C) 2007 The GAP Group
##
##  Error handling, break loop, etc. Now in GAP
##


CallAndInstallPostRestore( function()
    ASS_GVAR( "ERROR_COUNT", 0 );
    ASS_GVAR( "ErrorLevel", 0 );
    if IsHPCGAP then
      MakeThreadLocal("ErrorLevel");
    fi;
    ASS_GVAR( "QUITTING", false );
end);


#############################################################################
##
#F  OnQuit( )                                   currently removes all options
##
Unbind(OnQuit);         # OnQuit is called from the kernel so we take great
BIND_GLOBAL( "OnQuit",  # care to ensure it always has a definition. - GG
        function()
    if not IsEmpty(OptionsStack) then
      repeat
        PopOptions();
      until IsEmpty(OptionsStack);
      Info(InfoWarning,1,"Options stack has been reset");
    fi;
end);


BIND_GLOBAL("AncestorLVars", function(lv, depth)
    local i;
    for i in [1..depth] do
        lv := ParentLVars(lv);
    od;
    return lv;
end);

ErrorLVars := fail;

BIND_GLOBAL("WHERE", function( context, depth, outercontext)
    local   bottom,  lastcontext,  f;
    if depth <= 0 then
        return;
    fi;
    bottom := GetBottomLVars();
    lastcontext := outercontext;
    while depth > 0  and context <> bottom do
        PRINT_CURRENT_STATEMENT("*errout*", context);
        PrintTo("*errout*", " called from\n");
        lastcontext := context;
        context := ParentLVars(context);
        depth := depth-1;
    od;
    if depth = 0 then 
        PrintTo("*errout*", "...  ");
    else
        f := ContentsLVars(lastcontext).func;
        PrintTo("*errout*", "<function \"",NAME_FUNC(f)
              ,"\">( <arguments> )\n called from read-eval loop ");
    fi;
end);


BIND_GLOBAL("Where", function(arg)
    local   depth;
    if LEN_LIST(arg) = 0 then
        depth := 5;
    else
        depth := arg[1];
    fi;
    
    if ErrorLVars = fail or ErrorLVars = GetBottomLVars() then
        PrintTo("*errout*", "not in any function ");
    else
        WHERE(ParentLVars(ErrorLVars),depth, ErrorLVars);
    fi;
    PrintTo("*errout*", "at ",INPUT_FILENAME(),":",INPUT_LINENUMBER(),"\n");
end);

OnBreak := Where;

#OnBreak := function() 
#    if IsLVarsBag(ErrorLVars) then
#        if ErrorLVars <> BottomLVars then
#            WHERE(ParentLVars(ErrorLVars),5); 
#        else
#            Print("<function><argume
#    else
#        WHERE(ParentLVars(GetCurrentLVars()),5);
#   fi;
#end;

BIND_GLOBAL("ErrorCount", function()
    return ERROR_COUNT;
end);


#
# ErrorInner(context, justQuit, mayReturnVoid, mayReturnObj, lateMessage, .....)
# 
#

Unbind(ErrorInner);

BIND_GLOBAL("ErrorInner",
        function( arg )
    local   context, mayReturnVoid,  mayReturnObj,  lateMessage,  earlyMessage,  
            x,  prompt,  res, errorLVars, justQuit, printThisStatement,
            location, lastErrorStream, shellOut, shellIn;

	context := arg[1].context;
    if not IsLVarsBag(context) then
        PrintTo("*errout*", "ErrorInner:   option context must be a local variables bag\n");
        LEAVE_ALL_NAMESPACES();
        JUMP_TO_CATCH(1);
    fi; 
        
    if IsBound(arg[1].justQuit) then
        justQuit := arg[1].justQuit;
        if not justQuit in [false, true] then
            PrintTo("*errout*", "ErrorInner: option justQuit must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        justQuit := false;
    fi;
        
    if IsBound(arg[1].mayReturnVoid) then
        mayReturnVoid := arg[1].mayReturnVoid;
        if not mayReturnVoid in [false, true] then
            PrintTo("*errout*", "ErrorInner: option mayReturnVoid must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        mayReturnVoid := false;
    fi;
        
    if IsBound(arg[1].mayReturnObj) then
        mayReturnObj := arg[1].mayReturnObj;
        if not mayReturnObj in [false, true] then
            PrintTo("*errout*", "ErrorInner: option mayReturnObj must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        mayReturnObj := false;
    fi;
     
    if IsBound(arg[1].printThisStatement) then
        printThisStatement := arg[1].printThisStatement;
        if not printThisStatement in [false, true] then
            PrintTo("*errout*", "ErrorInner: option printThisStatement must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        printThisStatement := true;
    fi;
        
    if IsBound(arg[1].lateMessage) then
        lateMessage := arg[1].lateMessage;
        if not lateMessage in [false, true] and not IsString(lateMessage) then
            PrintTo("*errout*", "ErrorInner: option lateMessage must be a string or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        lateMessage := "";
    fi;
        
    earlyMessage := arg[2];
    if Length(arg) <> 2 then
        PrintTo("*errout*", "ErrorInner: new format takes exactly two arguments\n");
        LEAVE_ALL_NAMESPACES();
        JUMP_TO_CATCH(1);
    fi;
        
    ErrorLevel := ErrorLevel+1;
    ERROR_COUNT := ERROR_COUNT+1;
    errorLVars := ErrorLVars;
    ErrorLVars := context;
    # BreakOnError is defined by the `-T` command line flag in init.g
    if QUITTING or not BreakOnError then
        if not SilentErrors then
            PrintTo("*errout*", "Error, ");
            for x in earlyMessage do
                PrintTo("*errout*", x);
            od;
            PrintTo("*errout*", "\n");
        fi;
        if IsHPCGAP then
            LastErrorMessage := "";
            lastErrorStream := OutputTextString(LastErrorMessage, true);
            for x in earlyMessage do
                PrintTo(lastErrorStream, x);
            od;
            CloseStream(lastErrorStream);
            MakeImmutable(LastErrorMessage);
        fi;
        ErrorLevel := ErrorLevel-1;
        ErrorLVars := errorLVars;
        if ErrorLevel = 0 then LEAVE_ALL_NAMESPACES(); fi;
        JUMP_TO_CATCH(0);
    fi;
    PrintTo("*errout*", "Error, ");
    for x in earlyMessage do
        PrintTo("*errout*", x);
    od;
    if printThisStatement then 
        if context <> GetBottomLVars() then
            PrintTo("*errout*", " in\n  ");
            PRINT_CURRENT_STATEMENT("*errout*", context);
            PrintTo("*errout*", " called from \n");
        else
            PrintTo("*errout*", "\n");
        fi;
    else
        location := CURRENT_STATEMENT_LOCATION(context);
        if location <> fail then
          PrintTo("*errout*", " at ", location[1], ":", location[2]);
        fi;
        PrintTo("*errout*", " called from\n");
    fi;

    if SHOULD_QUIT_ON_BREAK() then
        FORCE_QUIT_GAP(1);
    fi;

    if IsBound(OnBreak) and IsFunction(OnBreak) then
        OnBreak();
    fi;
    if IsString(lateMessage) then
        PrintTo("*errout*", lateMessage,"\n");
    elif lateMessage then
        if IsBound(OnBreakMessage) and IsFunction(OnBreakMessage) then
            OnBreakMessage();
        fi;
    fi;
    if ErrorLevel > 1 then
        prompt := Concatenation("brk_",String(ErrorLevel),"> ");
    else
        prompt := "brk> ";
    fi;
    shellOut := "*errout*";
    shellIn := "*errin*";
    if IsHPCGAP then
        if HaveMultiThreadedUI then
            shellOut := "*defout*";
            shellIn := "*defin*";
        fi;
    fi;
    if not justQuit then
        res := SHELL(context,mayReturnVoid,mayReturnObj,3,false,prompt,false,shellIn,shellOut,false);
    else
        res := fail;
    fi;
    ErrorLevel := ErrorLevel-1;
    ErrorLVars := errorLVars;
    if res = fail then
        if IsBound(OnQuit) and IsFunction(OnQuit) then
            OnQuit();
        fi;
	if ErrorLevel = 0 then LEAVE_ALL_NAMESPACES(); fi;
        if not justQuit then
	   # dont try and do anything else after this before the longjump 	
            SetUserHasQuit(1);	
        fi;
        JUMP_TO_CATCH(3);
    fi;
    if Length(res) > 0 then
        return res[1];
    else
        return;
    fi;
end);

Unbind(Error);

BIND_GLOBAL("Error",
        function(arg)
    ErrorInner(rec( context := ParentLVars(GetCurrentLVars()),
                               mayReturnVoid := true,
                               lateMessage := true,
                               printThisStatement := false),
                               arg);
end);

Unbind(ErrorNoReturn);

BIND_GLOBAL("ErrorNoReturn",
       function ( arg )
    ErrorInner( rec(
         context := ParentLVars( GetCurrentLVars(  ) ),
         mayReturnVoid := false, mayReturnObj := false,
         lateMessage := "type 'quit;' to quit to outer loop",
         printThisStatement := false), arg);
end);
