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
## Default stream for error messages.
ERROR_OUTPUT := "*errout*";

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
        PRINT_CURRENT_STATEMENT(ERROR_OUTPUT, context);
        PrintTo(ERROR_OUTPUT, " called from\n");
        lastcontext := context;
        context := ParentLVars(context);
        depth := depth-1;
    od;
    if depth = 0 then 
        PrintTo(ERROR_OUTPUT, "...  ");
    else
        f := ContentsLVars(lastcontext).func;
        PrintTo(ERROR_OUTPUT, "<function \"",NAME_FUNC(f)
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
        PrintTo(ERROR_OUTPUT, "not in any function ");
    else
        WHERE(ParentLVars(ErrorLVars),depth, ErrorLVars);
    fi;
    PrintTo(ERROR_OUTPUT, "at ",INPUT_FILENAME(),":",INPUT_LINENUMBER(),"\n");
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
            printEarlyMessage, printEarlyTraceback, lastErrorStream,
            shellOut, shellIn;

    context := arg[1].context;
    if not IsLVarsBag(context) then
        PrintTo(ERROR_OUTPUT, "ErrorInner:   option context must be a local variables bag\n");
        LEAVE_ALL_NAMESPACES();
        JUMP_TO_CATCH(1);
    fi; 
        
    if IsBound(arg[1].justQuit) then
        justQuit := arg[1].justQuit;
        if not justQuit in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option justQuit must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        justQuit := false;
    fi;
        
    if IsBound(arg[1].mayReturnVoid) then
        mayReturnVoid := arg[1].mayReturnVoid;
        if not mayReturnVoid in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option mayReturnVoid must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        mayReturnVoid := false;
    fi;
        
    if IsBound(arg[1].mayReturnObj) then
        mayReturnObj := arg[1].mayReturnObj;
        if not mayReturnObj in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option mayReturnObj must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        mayReturnObj := false;
    fi;
     
    if IsBound(arg[1].printThisStatement) then
        printThisStatement := arg[1].printThisStatement;
        if not printThisStatement in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option printThisStatement must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        printThisStatement := true;
    fi;
        
    if IsBound(arg[1].lateMessage) then
        lateMessage := arg[1].lateMessage;
        if not lateMessage in [false, true] and not IsString(lateMessage) then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option lateMessage must be a string or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        lateMessage := "";
    fi;
        
    earlyMessage := arg[2];
    if Length(arg) <> 2 then
        PrintTo(ERROR_OUTPUT, "ErrorInner: new format takes exactly two arguments\n");
        LEAVE_ALL_NAMESPACES();
        JUMP_TO_CATCH(1);
    fi;

    # Local functions that print the user feedback.
    printEarlyMessage := function(stream)
        PrintTo(stream, "Error, ");
        # earlyMessage usually contains information about what went wrong.
        for x in earlyMessage do
            PrintTo(stream, x);
        od;
    end;

    printEarlyTraceback := function(stream)
        local location;
        if printThisStatement then
            if context <> GetBottomLVars() then
                PrintTo(stream, " in\n  ");
                PRINT_CURRENT_STATEMENT(stream, context);
                PrintTo(stream, " called from ");
            fi;
        else
            location := CURRENT_STATEMENT_LOCATION(context);
            if location <> fail then
              PrintTo(stream, " at ", location[1], ":", location[2]);
            fi;
            PrintTo(stream, " called from");
        fi;
        PrintTo(ERROR_OUTPUT, "\n");
    end;

    ErrorLevel := ErrorLevel+1;
    ERROR_COUNT := ERROR_COUNT+1;
    errorLVars := ErrorLVars;
    ErrorLVars := context;
    # Do we want to skip the break loop?
    # BreakOnError is initialized by the `-T` command line flag in init.g
    if QUITTING or not BreakOnError then
        # If we skip the break loop, the standard behaviour is to print only
        # the earlyMessage. If SilentNonInteractiveErrors is true we do not
        # print any messages. If AlwaysPrintTracebackOnError is true we also
        # call OnBreak(), which by default prints the traceback.
        # SilentNonInteractiveErrors superseeds AlwaysPrintTracebackOnError.
        # It is used by HPC-GAP to e.g. suppress error messages in worker
        # threads.
        if not SilentNonInteractiveErrors then
            printEarlyMessage(ERROR_OUTPUT);
            if AlwaysPrintTracebackOnError then
                printEarlyTraceback(ERROR_OUTPUT);
                if IsBound(OnBreak) and IsFunction(OnBreak) then
                    OnBreak();
                fi;
            else
                PrintTo(ERROR_OUTPUT, "\n");
            fi;
        fi;
        if IsHPCGAP then
            # In HPC-GAP we want to access error messages encountered in
            # tasks via TaskError. To this end we store the error message
            # in the thread local variable LastErrorMessage.
            LastErrorMessage := "";
            lastErrorStream := OutputTextString(LastErrorMessage, true);
            printEarlyMessage(lastErrorStream);
            if AlwaysPrintTracebackOnError then
                printEarlyTraceback(lastErrorStream);
                # FIXME: Also make HPCGAP work with OnBreak().
                # If AlwaysPrintTracebackOnError is true, the output of
                # OnBreak() should also be put into LastErrorMessage.
                # To do this there needs to be a way to put its output
                # into lastErrorStream.
                # OnBreak() is documented to not take any arguments.
                # One could work around that if there were e.g. a GAP error
                # stream which all error functions print to.
            fi;
            CloseStream(lastErrorStream);
            MakeImmutable(LastErrorMessage);
        fi;
        ErrorLevel := ErrorLevel-1;
        ErrorLVars := errorLVars;
        if ErrorLevel = 0 then LEAVE_ALL_NAMESPACES(); fi;
        JUMP_TO_CATCH(0);
    fi;

    printEarlyMessage(ERROR_OUTPUT);
    printEarlyTraceback(ERROR_OUTPUT);

    if SHOULD_QUIT_ON_BREAK() then
        # Again, the default is to not print the rest of the traceback.
        # If AlwaysPrintTracebackOnError is true we do so anyways.
        if AlwaysPrintTracebackOnError
            and IsBound(OnBreak) and IsFunction(OnBreak) then
            OnBreak();
        fi;
        FORCE_QUIT_GAP(1);
    fi;

    # OnBreak() is set to Where() by default, which prints the traceback.
    if IsBound(OnBreak) and IsFunction(OnBreak) then
        OnBreak();
    fi;

    # Now print lateMessage and OnBreakMessage a la "press return; to .."
    if IsString(lateMessage) then
        PrintTo(ERROR_OUTPUT, lateMessage,"\n");
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
