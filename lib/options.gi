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



##
## Initially the stack is empty -- we mutate the object bound to it, but
## don't replace it, so we can make it Read Only
##

if IsHPCGAP then
    BindThreadLocal("OptionsStack", [ ]);
else
    OptionsStack := [];
fi;

MakeReadOnlyGlobal("OptionsStack");

#############################################################################
##
#F  PushOptions( <options_record> )                           set new options
##
##  This is a function, not an operation, so we need to check our arguments
##


InstallGlobalFunction( PushOptions,
   function(opts)
    local merged, field, len;
    if not IsRecord(opts) then
        Error("Usage: PushOptions( <opts> )");
    fi;
    len := Length(OptionsStack);
    if len > 0 then
        merged := ShallowCopy(OptionsStack[len]);
        for field in RecNames(opts) do
            merged.(field) := opts.(field);
        od;
    else
        merged := ShallowCopy(opts);
    fi;

    Add(OptionsStack,merged);
    Info(InfoOptions,1, "Pushing ",opts);
end);



#############################################################################
##
#F  PopOptions( )                                              remove options
##
InstallGlobalFunction( PopOptions,
        function()
    if Length(OptionsStack)=0 then
      Info(InfoWarning,1,"Options stack is already empty");
    else
      Remove(OptionsStack);
      Info(InfoOptions, 1, "Popping");
    fi;
end);

#############################################################################
##
#F  ResetOptionsStack( )                                   remove all options
##
InstallGlobalFunction( ResetOptionsStack,
        function()
    if Length(OptionsStack)=0 then
      Info(InfoWarning,1,"Options stack is already empty");
    else
      repeat
        PopOptions();
      until IsEmpty(OptionsStack);
    fi;
end);

#############################################################################
##
#F  ValueOption( <opt> )                                       access options
##
##  Basic access function. This could get very slow if the stack gets deep
##  Returns fail if option has never been bound
##

InstallGlobalFunction( ValueOption,
        function(tag)
    local top,len;
    len := Length(OptionsStack);
    if len = 0 then
        Info(InfoOptions,1,
             "Seeking option ",tag," found nothing");
        return fail;
    else
        top := OptionsStack[len];
        if IsBound(top.(tag)) then
            Info(InfoOptions,2,
                 "Seeking option ",tag," found ",top.(tag));
            return top.(tag);
        else
        Info(InfoOptions,1,
             "Seeking option ",tag," found nothing");
        return fail;
        fi;
    fi;
end);

#############################################################################
##
#F  DisplayOptionsStack( )                          display the options stack
##
##  This function prints a human-readable display of all currently set
##  options
##

InstallGlobalFunction( DisplayOptionsStack, function()
    Print(OptionsStack,"\n"); end);
