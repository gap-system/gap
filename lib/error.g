#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
ERROR_OUTPUT := MakeImmutable("*errout*");

#############################################################################
##
#F  OnQuit( )
##
Unbind(OnQuit);
BIND_GLOBAL( "OnQuit", function()
    if not IsEmpty(OptionsStack) then
      repeat
        PopOptions();
      until IsEmpty(OptionsStack);
      Info(InfoWarning,1,"Options stack has been reset");
    fi;
    if IsBound(ResetMethodReordering) and IsFunction(ResetMethodReordering) then
        ResetMethodReordering();
    fi;
    if REREADING = true then
        MakeReadWriteGlobal("REREADING");
        REREADING := false;
        MakeReadOnlyGlobal("REREADING");
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

# In this method the line hint changes in every PrintTo are balanced, because at the moment
# PrintTo(ERROR_OUTPUT,...) resets the indentation level every time it is called.
# If/when this is fixed, the indentation in this function could be simplified
BIND_GLOBAL("PRETTY_PRINT_VARS", function(context)
    local vars, i, argcount, val;
    vars := ContentsLVars(context);
    if not IsRecord(vars) then
        return;
    fi;

    argcount := ABS_RAT(NumberArgumentsFunction(vars.func));
    PrintTo(ERROR_OUTPUT, "\>\>\n\<\<arguments:");
    if argcount = 0 then
        PrintTo(ERROR_OUTPUT, " <none>");
    else
        for i in [1..argcount] do
            if IsBound(vars.values[i]) then
                val := vars.values[i];
            else
                val := "<unassigned>";
            fi;
            PrintTo(ERROR_OUTPUT, "\>\>\>\>\n", vars.names[i], " :=\>\> ", val, "\<\<\<\<\<\<");
        od;
    fi;

    PrintTo(ERROR_OUTPUT, "\>\>\n\<\<local variables:");
    if argcount = Length(vars.names) then
        PrintTo(ERROR_OUTPUT, " <none>");
    else
        for i in [argcount+1..Length(vars.names)] do
            if IsBound(vars.values[i]) then
                val := vars.values[i];
            else
                val := "<unassigned>";
            fi;
            PrintTo(ERROR_OUTPUT, "\>\>\>\>\n", vars.names[i], " :=\>\> ", val, "\<\<\<\<\<\<");
        od;
    fi;
    PrintTo(ERROR_OUTPUT,"\n");
end);

BIND_GLOBAL("WHERE", function(depth, context, showlocals)
    local bottom, lastcontext, f;
    if depth <= 0 then
        return;
    fi;
    bottom := GetBottomLVars();
    lastcontext := context;
    context := ParentLVars(context);
    while depth > 0  and context <> bottom do
        PRINT_CURRENT_STATEMENT(ERROR_OUTPUT, context);
        if showlocals then
            PRETTY_PRINT_VARS(context);
        fi;

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


BIND_GLOBAL("WHERE_INTERNAL", function(depth, showlocals)
    if ErrorLVars = fail or ErrorLVars = GetBottomLVars() then
        PrintTo(ERROR_OUTPUT, "not in any function ");
    else
        WHERE(depth, ErrorLVars, showlocals);
    fi;
    PrintTo(ERROR_OUTPUT, "at ", INPUT_FILENAME(), ":", INPUT_LINENUMBER(), "\n");
end);

BIND_GLOBAL("WhereWithVars", function(arg)
    local   depth;
    if LEN_LIST(arg) = 0 then
        depth := 5;
    else
        depth := arg[1];
    fi;

    WHERE_INTERNAL(depth, true);
end);

BIND_GLOBAL("Where", function(arg)
    local   depth;
    if LEN_LIST(arg) = 0 then
        depth := 5;
    else
        depth := arg[1];
    fi;

    WHERE_INTERNAL(depth, false);
end);


OnBreak := Where;

BIND_GLOBAL("ErrorCount", function()
    return ERROR_COUNT;
end);


#
#
#
Unbind(ErrorInner);
BIND_GLOBAL("ErrorInner", function(options, earlyMessage)
    local   context, mayReturnVoid,  mayReturnObj,  lateMessage,
            x,  prompt,  res, errorLVars, justQuit, printThisStatement,
            printEarlyMessage, printEarlyTraceback, lastErrorStream;

    context := options.context;
    if not IsLVarsBag(context) then
        PrintTo(ERROR_OUTPUT, "ErrorInner:   option context must be a local variables bag\n");
        LEAVE_ALL_NAMESPACES();
        JUMP_TO_CATCH(1);
    fi;

    if IsBound(options.justQuit) then
        justQuit := options.justQuit;
        if not justQuit in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option justQuit must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        justQuit := false;
    fi;

    if IsBound(options.mayReturnVoid) then
        mayReturnVoid := options.mayReturnVoid;
        if not mayReturnVoid in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option mayReturnVoid must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        mayReturnVoid := false;
    fi;

    if IsBound(options.mayReturnObj) then
        mayReturnObj := options.mayReturnObj;
        if not mayReturnObj in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option mayReturnObj must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        mayReturnObj := false;
    fi;

    if IsBound(options.printThisStatement) then
        printThisStatement := options.printThisStatement;
        if not printThisStatement in [false, true] then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option printThisStatement must be true or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        printThisStatement := true;
    fi;

    if IsBound(options.lateMessage) then
        lateMessage := options.lateMessage;
        if not lateMessage in [false, true] and not IsString(lateMessage) then
            PrintTo(ERROR_OUTPUT, "ErrorInner: option lateMessage must be a string or false\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
    else
        lateMessage := "";
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
        # SilentNonInteractiveErrors supersedes AlwaysPrintTracebackOnError.
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
        ForceQuitGap(1);
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
    if not justQuit then
        res := SHELL(context,mayReturnVoid,mayReturnObj,true,prompt,false);
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

BIND_GLOBAL("Error", function(arg)
    ErrorInner(
        rec(
            context := ParentLVars(GetCurrentLVars()),
            mayReturnVoid := true,
            lateMessage := true,
            printThisStatement := false,
        ),
        arg);
end);

Unbind(ErrorNoReturn);

BIND_GLOBAL("ErrorNoReturn", function(arg)
    ErrorInner(
        rec(
            context := ParentLVars(GetCurrentLVars()),
            mayReturnVoid := false,
            mayReturnObj := false,
            lateMessage := "type 'quit;' to quit to outer loop",
            printThisStatement := false,
        ),
        arg);
end);
