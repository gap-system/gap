#############################################################################
##
#W  info.gi                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This package sets up a GAP level prototype of the new Info messages
##  system, parts of which will eventually have to be moved into
##  the kernel
##  
##  Informational messages are controlled by the user setting desired
##  levels of verbosity for InfoClasses. A set of InfoClasses is an
##  InfoSelector, and classes and selectors may be built up with \+
#N  I wanted to use \or, but this isn't at operation
##  
##  An message is associated with a selector and a level and is
##  printed when the desired level for any of the classes in the selector
##  equals or exceeds  the level of the message
##
#N  There may be a case for doing this without using method selection at all
#N  as it could then be installed earlier in library loading
#N
##
##  This file is the implementation  part of that package
##
Revision.info_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsInfoClassListRep(<obj>)                       length one positional rep
##                              
##  An InfoClass is represented as a length one positional object with
##  a positive integer in ic![1]. No other representations are 
##  anticipated
##

DeclareRepresentation("IsInfoClassListRep", IsPositionalObjectRep,[]);

#############################################################################
##
#V  InfoData                 record of private stuff
#V  InfoData.CurrentLevels   the current desired verbosity levels set by user
#V  InfoData.ClassNames          names of all info classes, used for printing
##
##  these are both lists, and should have the same length, which defines the
##  number of Info classes that exist
##

if not IsBound(InfoData) then

    BIND_GLOBAL( "InfoData", rec() );
    InfoData.CurrentLevels := [];
    InfoData.ClassNames := [];
fi;


#############################################################################
##
#F  InfoData.InfoClass( <num> )               make a number into an InfoClass
##

InfoData.InfoClass :=  function(num)
    if num < 1 or num > Length(InfoData.CurrentLevels) then
        Error("Bad info class number -- this is a bug");
    fi;
    return Objectify(NewType(InfoClassFamily,IsInfoClassListRep),
                   [num]);
end;

#############################################################################
##
#M  NewInfoClass( <name> )                              make a new Info Class  
##
##  This is how Info Classes should be obtained
##
#N  Is there any reason to make this an Operation?
##

InstallMethod(NewInfoClass, true, [IsString], 0,
        function(name)
    local pos;
    
    # if we are rereading and this class already exists then 
    # do not make a new class
    if REREADING then
        pos := Position(InfoData.ClassNames,name);
        if pos <> fail then
            return InfoData.InfoClass(pos);
        fi;
    fi;
    
    Add(InfoData.CurrentLevels,0);
    Add(InfoData.ClassNames,name);
    return InfoData.InfoClass(Length(InfoData.CurrentLevels));
end);


#############################################################################
##
#F  DeclareInfoClass( <name> )
##
InstallGlobalFunction( DeclareInfoClass, function( name )
    BIND_GLOBAL( name, NewInfoClass( name ) );
end );


#############################################################################
##
#M  Basic methods for Info Classes: =, < (so that we can make Sets),
##                                  PrintObj
##

InstallMethod(\=,
    "for two info classes",
    IsIdenticalObj, [IsInfoClassListRep, IsInfoClassListRep], 0,
        function(ic1,ic2)
    return ic1![1] = ic2![1];
end);

InstallMethod(\<,
    "for two info classes",
    IsIdenticalObj, [IsInfoClassListRep, IsInfoClassListRep], 0,
        function(ic1,ic2)
    return ic1![1] < ic2![1];
end);

InstallMethod(PrintObj,
    "for an info class",
    true, [IsInfoClassListRep], 0,
        function(ic)
    Print(InfoData.ClassNames[ic![1]]);
end);

#############################################################################
##
#M  <info class> + <info class>
#M  <info selector> + <info class>
#M  <info class> + <info selector>
#M  <info selector> + <info selector
##
##  Used to build up InfoSelectors, these are essentially just taking unions
##

InstallOtherMethod(\+,
    "for two info classes",
    IsIdenticalObj, [IsInfoClass, IsInfoClass], 0,
        function(ic1,ic2)
    return Set([ic1,ic2]);
end);

InstallOtherMethod(\+,
    "for info class and info selector",
    true, [IsInfoClass, IsInfoSelector], 0,
        function(ic,is)
    return Union(is,[ic]);
end);

InstallOtherMethod(\+,
    "for info selector and info class",
    true, [IsInfoSelector, IsInfoClass], 0,
        function(is,ic)
    return Union(is,[ic]);
end);

InstallOtherMethod(\+,
    "for two info selectors",
    IsIdenticalObj, [IsInfoSelector, IsInfoSelector], 0,
        function(is1,is2)
    return Union(is1,is2);
end);

#############################################################################
##
#M  SetInfoLevel( <class>, <level>)   set desired verbosity level for a class  
##

InfoData.handler := function(ic,lev)
    InfoData.CurrentLevels[ic![1]] := lev;
end;

InstallMethod(SetInfoLevel, true, 
        [IsInfoClass and IsInfoClassListRep, IsPosInt], 0,
        InfoData.handler);

InstallMethod(SetInfoLevel, true, 
        [IsInfoClass and IsInfoClassListRep, IsZeroCyc], 0,
        InfoData.handler);

Unbind(InfoData.handler);

#############################################################################
##
#F  SetAllInfoLevels(  <level>)   set desired verbosity level for all classes
##

BIND_GLOBAL( "SetAllInfoLevels", function( level )
    local i;
    for i in [1..Length(InfoData.CurrentLevels)] do
        InfoData.CurrentLevels[i] := level;
    od;
end );
                                     

#############################################################################
##
#M  InfoLevel( <class> )              get desired verbosity level for a class  
##

InstallMethod(InfoLevel, true, 
        [IsInfoClass and IsInfoClassListRep], 0,
        function(ic)
    return InfoData.CurrentLevels[ic![1]];
end);

#############################################################################
##
#F  InfoDecision( <selector>, <level>) .  decide whether a message is printed
##
##  This is called by the kernel
##

BIND_GLOBAL( "InfoDecision", function(selectors, level)
    local usage;
    usage := "Usage : InfoDecision(<selectors>, <level>)";
    if IsInfoClass(selectors) then
        selectors := [selectors];
    fi;
    if not IsInfoSelector(selectors) 
       or not IsInt(level)
       or level <= 0
    then
        Error(usage);
    fi;
    
    # Now decide what to do and then do it, 
    # note that we 'or' the classes together
    
    return ForAny(selectors, ic -> InfoLevel(ic) >= level);
end );
    
#############################################################################
##
#F  InfoDoPrint( arglist )  . . . . . . . . . . . . . . Print an info message
##
##  This is called by the kernel to actually produce the message
##

BIND_GLOBAL( "InfoDoPrint", function(arglist)
    Print("#I  ");
    CallFuncList(Print, arglist);
    Print("\n");
end );


##
## Former GAP Info function, now replaced by the keyword Info.
##
###Info := function(arg)
##    local usage;
##   
##    # Check and unpack the arguments
##   usage := "Usage : Info(<selectors>, <level>, <data>...)";
##    if Length(arg) < 2 then
##        Error(usage);
##    fi;
##    if InfoDecision(arg[1], arg[2]) then
##        InfoDoPrint(arg{[3..Length(arg)]});
##    fi;
##end;


#N  Probably this file should also define InfoClasses for a range of purposes
#N  which cut across files


#############################################################################
##
#V  InfoDebug
##
if not IsBound(InfoDebug) then
    DeclareInfoClass( "InfoDebug" );
fi;


#############################################################################
##
#V  InfoMethodSelection
##
if not IsBound(InfoMethodSelection) then
    DeclareInfoClass( "InfoMethodSelection" );
fi;


#############################################################################
##
#V  InfoTiming
##
if not IsBound(InfoTiming) then
    DeclareInfoClass( "InfoTiming" );
fi;

#############################################################################
##
#V  InfoWarning
##
##  This info class has a default level of 1. Warnings can be switched
##  off by setting its level to zero
##
if not IsBound(InfoWarning) then
    DeclareInfoClass( "InfoWarning" );
    SetInfoLevel( InfoWarning, 1 );
fi;

        
#############################################################################
##

#E  info.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



