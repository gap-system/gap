#############################################################################
##
#W  options.gi                     GAP library                      Steve Linton
##
#H  @(#)$Id: options.gi,v 4.7 2010/02/23 15:13:21 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##

Revision.options_gi :=
    "@(#)$Id: options.gi,v 4.7 2010/02/23 15:13:21 gap Exp $";


##
## Initially the stack is empty -- we mutate the object bound to it, but
## don't replace it, so we can make it Read Only
##

SetTLDefault(ThreadVar, "OptionsStack", [ ]);

#############################################################################
##
#F  PushOptions( <options record> )                           set new options
##
##  This is a function, not an operation, so we need to check our arguments
##


InstallGlobalFunction( PushOptions,
   function(opts)
    local merged, field, len;
    if not IsRecord(opts) then
        Error("Usage: PushOptions( <opts> )");
    fi;
    len := Length(ThreadVar.OptionsStack);
    if len > 0 then
        merged := ShallowCopy(ThreadVar.OptionsStack[len]);
        for field in RecNames(opts) do
            merged.(field) := opts.(field);
        od;
    else
        merged := ShallowCopy(opts);
    fi;
        
    Add(ThreadVar.OptionsStack,merged);
    Info(InfoOptions,1, "Pushing ",opts);
end);



#############################################################################
##
#F  PopOptions( )                                              remove options
##
InstallGlobalFunction( PopOptions,
        function()
    if Length(ThreadVar.OptionsStack)=0 then
      Info(InfoWarning,1,"Options stack is already empty");
    else
      Unbind(ThreadVar.OptionsStack[Length(ThreadVar.OptionsStack)]);
      Info(InfoOptions, 1, "Popping");
    fi;
end);

#############################################################################
##
#F  ResetOptionsStack( )                                   remove all options
##
InstallGlobalFunction( ResetOptionsStack,
        function()
    if Length(ThreadVar.OptionsStack)=0 then
      Info(InfoWarning,1,"Options stack is already empty");
    else
      repeat
        PopOptions();
      until IsEmpty(ThreadVar.OptionsStack);
    fi;
end);

#############################################################################
##
#F  OnQuit( )                                   currently removes all options
##
Unbind(OnQuit);         # OnQuit is called from the kernel so we take great
BIND_GLOBAL( "OnQuit",  # care to ensure it always has a definition. - GG
        function()
    if not IsEmpty(ThreadVar.OptionsStack) then
      repeat
        PopOptions();
      until IsEmpty(ThreadVar.OptionsStack);
      Info(InfoWarning,1,"Options stack has been reset");
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
    len := Length(ThreadVar.OptionsStack);
    if len = 0 then
        Info(InfoOptions,1,
             "Seeking option ",tag," found nothing");
        return fail;
    else
        top := ThreadVar.OptionsStack[len];
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
    Print(ThreadVar.OptionsStack,"\n"); end);
