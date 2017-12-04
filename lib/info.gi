#############################################################################
##
#W  info.gi                     GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  A message is associated with a selector and a level and is
##  printed when the desired level for any of the classes in the selector
##  equals or exceeds  the level of the message
##
#N  There may be a case for doing this without using method selection at all
#N  as it could then be installed earlier in library loading
#N
##
##  This file is the implementation  part of that package
##


#############################################################################
##
#R  IsInfoClassListRep(<obj>)                       length one positional rep
##                              
##  An InfoClass is represented as a positional object with the following
##  members:
##
##  INFODATA_NUM            an integer identifying the class
##  INFODATA_CURRENTLEVEL   a positive integer
##  INFODATA_CLASSNAME      a string
##  INFODATA_HANDLER        optional, handler function taking three arguments
##  INFODATA_OUTPUT         optional, output stream

DeclareRepresentation("IsInfoClassListRep", IsAtomicPositionalObjectRep,[]);

# A list of all created InfoClassListReps
INFO_CLASSES := [];

# InfoData is unused, but we keep it for now, to avoid warnings in GAPDoc.
# TODO: remove InfoData
InfoData := rec();

if IsHPCGAP then
    ShareInternalObj(INFO_CLASSES);
fi;

InstallGlobalFunction( "SetDefaultInfoOutput", function( out )
  if IsBound(DefaultInfoOutput) then
    MakeReadWriteGlobal("DefaultInfoOutput");
  fi;
  DefaultInfoOutput := out;
  MakeReadOnlyGlobal("DefaultInfoOutput");
end);

InstallGlobalFunction( "DefaultInfoHandler", function( infoclass, level, list )
  local out, fun, s;
  out := InfoOutput(infoclass);
  if out = "*Print*" then
    if IsBoundGlobal( "PrintFormattedString" ) then
      fun := function(s)
        if (IsString(s) and Length(s) > 0 or IsStringRep(s)) and
          #XXX this is a temporary hack, we would need a
          # IsInstalledGlobal instead of IsBoundGlobal here
                 NARG_FUNC(ValueGlobal("PrintFormattedString")) <> -1 then
          ValueGlobal( "PrintFormattedString" )(s);
        else
          Print(s);
        fi;
      end;
    else
      fun := Print;
    fi;
    fun("#I  ");
    for s in list do
      fun(s);
    od;
    fun("\n");
  else
    AppendTo(out, "#I  ");
    for s in list do
      AppendTo(out, s);
    od;
    AppendTo(out, "\n");
  fi;
end);


#############################################################################
##
#M  NewInfoClass( <name> )                              make a new Info Class  
##
##  This is how Info Classes should be obtained
##

InstallMethod(NewInfoClass, true, [IsString], 0,
        function(name)
    local pos, ic;
    
    atomic readwrite INFO_CLASSES do
        # if we are rereading and this class already exists then 
        # do not make a new class
        if REREADING then
            pos := First(INFO_CLASSES, x -> x![INFODATA_CLASSNAME] = name);
            if pos <> fail then
                return INFO_CLASSES[pos];
            fi;
        fi;
        
        pos := Length(INFO_CLASSES) + 1;
        # make sure to always allocate a length big enough, even for the optional
        # members, because in HPC-GAP, positional objects cannot be resized
        ic := FixedAtomicList(5);
        ic[INFODATA_CURRENTLEVEL] := 0;
        ic[INFODATA_CLASSNAME] := Immutable(name);
        ic[INFODATA_NUM] := pos;
        ic := Objectify(NewType(InfoClassFamily,IsInfoClassListRep), ic);
        INFO_CLASSES[pos] := ic;
        return ic;
    od;
end);


#############################################################################
##
#F  DeclareInfoClass( <name> )
##
InstallGlobalFunction( DeclareInfoClass, function( name )
    if not ISBOUND_GLOBAL( name ) then
      BIND_GLOBAL( name, NewInfoClass( name ) );
    elif not IsInfoClass( VALUE_GLOBAL( name ) ) then
      Error( "value of `",name,"' is already bound and not an info class" );
    fi;
end );

#############################################################################
##
#F  SetInfoHandler( <class>, <handler> )
##
InstallGlobalFunction( SetInfoHandler, function(class, handler)
    class![INFODATA_HANDLER] := handler;
end);

#############################################################################
##
#F  SetInfoOutput( <class>, <handler> )
##
InstallGlobalFunction( SetInfoOutput, function(class, out)
  class![INFODATA_OUTPUT] := out;
end);

InstallGlobalFunction( UnbindInfoOutput, function(class)
  Unbind(class![INFODATA_OUTPUT]);
end);

InstallGlobalFunction( InfoOutput, function(class)
  if IsBound(class![INFODATA_OUTPUT]) then
    return class![INFODATA_OUTPUT];
  else
    return DefaultInfoOutput;
  fi;
end);

#############################################################################
##
#M  Basic methods for Info Classes: =, < (so that we can make Sets),
##                                  PrintObj
##

InstallMethod(\=,
    "for two info classes",
    IsIdenticalObj, [IsInfoClassListRep, IsInfoClassListRep], 0,
        function(ic1,ic2)
    return ic1![INFODATA_NUM] = ic2![INFODATA_NUM];
end);

InstallMethod(\<,
    "for two info classes",
    IsIdenticalObj, [IsInfoClassListRep, IsInfoClassListRep], 0,
        function(ic1,ic2)
    return ic1![INFODATA_NUM] < ic2![INFODATA_NUM];
end);

InstallMethod(PrintObj,
    "for an info class",
    true, [IsInfoClassListRep], 0,
        function(ic)
    Print(ic![INFODATA_CLASSNAME]);
end);

#############################################################################
##
#M  <info class> + <info class>
#M  <info selector> + <info class>
#M  <info class> + <info selector>
#M  <info selector> + <info selector>
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
    true, [IsInfoClass, IsInfoSelector], 20,
        function(ic,is)
    return Union(is,[ic]);
end);

InstallOtherMethod(\+,
    "for info selector and info class",
    true, [IsInfoSelector, IsInfoClass], 20,
        function(is,ic)
    return Union(is,[ic]);
end);

InstallOtherMethod(\+,
    "for two info selectors",
    IsIdenticalObj, [IsInfoSelector, IsInfoSelector], 20,
        function(is1,is2)
    return Union(is1,is2);
end);

#############################################################################
##
#M  SetInfoLevel( <class>, <level>)   set desired verbosity level for a class  
##

INFODATA_DEFAULT_HANDLER := function(ic,lev)
    ic![INFODATA_CURRENTLEVEL] := lev;
end;

InstallMethod(SetInfoLevel, true, 
        [IsInfoClass and IsInfoClassListRep, IsPosInt], 0,
        INFODATA_DEFAULT_HANDLER);

InstallMethod(SetInfoLevel, true, 
        [IsInfoClass and IsInfoClassListRep, IsZeroCyc], 0,
        INFODATA_DEFAULT_HANDLER);

Unbind(INFODATA_DEFAULT_HANDLER);

#############################################################################
##
#F  SetAllInfoLevels(  <level>)   set desired verbosity level for all classes
##

BIND_GLOBAL( "SetAllInfoLevels", function( level )
    local infoclass;
    atomic readwrite INFO_CLASSES do
        for infoclass in INFO_CLASSES do
            SetInfoLevel(infoclass, level);
        od;
    od;
end );


#############################################################################
##
#M  InfoLevel( <class> )              get desired verbosity level for a class  
##

InstallMethod(InfoLevel, true, 
        [IsInfoClass and IsInfoClassListRep], 0,
        function(ic)
    return ic![INFODATA_CURRENTLEVEL];
end);

#############################################################################
##
#F  InfoDecision( <selector>, <level>) .  decide whether a message is printed
##
##  The kernel skips this function for the case of an IsInfoClassListRep,
##  where ret will be False.
##

BIND_GLOBAL( "InfoDecision", function(selectors, level)
    local usage, ret;
    usage := "usage : Info(<selectors>, <level>, ...)";
    if not IsInt(level) or level <= 0 then
        if level = 0 then
            Error("level 0 Info messages are not allowed");
        else
            Error(usage);
        fi;
    fi;

    ret := false;
    
    if IsInfoClass(selectors) then
        ret := InfoLevel(selectors) >= level;
    elif IsInfoSelector(selectors)  then
        # note that we 'or' the classes together
        ret :=  ForAny(selectors, ic -> InfoLevel(ic) >= level);
    else
        Error(usage);
    fi;

    return ret;
end );


#############################################################################
##
#V  InfoDebug
##
##  This info class has a default level of 1.
##  Warnings can be switched off by setting its level to zero.
##
##  The files `lib/oper.g', `lib/oper1.g', `lib/variable.g' contain
##  calls to `INFO_DEBUG' (a plain function delegating to `Print').
##  Here we define the proper info class `InfoDebug',
##  and replace `INFO_DEBUG' by a function that calls `Info'
##  and respects the user defined info level of `InfoDebug'.
##
if not IsBound( InfoDebug ) then
  DeclareInfoClass( "InfoDebug" );
  SetInfoLevel( InfoDebug, 1 );

  MAKE_READ_WRITE_GLOBAL( "INFO_DEBUG" );
  INFO_DEBUG:= function( arg )
    local string, i;

    string:= [];
    for i in [ 2 .. LEN_LIST( arg ) ] do
      APPEND_LIST_INTR( string, arg[i] );
    od;
    Info( InfoDebug, arg[1], string );
  end;
  MAKE_READ_ONLY_GLOBAL( "INFO_DEBUG" );
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
##  This info class has a default level of 1.
##  Warnings can be switched off by setting its level to zero.
##
if not IsBound(InfoWarning) then
    DeclareInfoClass( "InfoWarning" );
    SetInfoLevel( InfoWarning, 1 );
fi;

#############################################################################
##
#V  InfoPerformance
##
##  This info class has a default level of 1. It prints warnings about
##  performance problems when doing things in particularly unsuitable ways.
##  Warnings can be switched off by setting its level to zero
##
DeclareInfoClass( "InfoPerformance" );
SetInfoLevel( InfoPerformance, 1 );

#############################################################################
##
#V  InfoTeaching
##
##  This info class has a default level of 1.
##  Warnings can be switched off by setting its level to zero
##
if not IsBound(InfoTeaching) then
  DeclareInfoClass( "InfoTeaching" );
  if not TEACHING_MODE then
    SetInfoLevel( InfoTeaching, 1 );
  fi;
fi;

LAST_COMPLETIONBAR_STRING:=fail;
LAST_COMPLETIONBAR_VAL:=0;

InstallGlobalFunction(CompletionBar,function(c,a,s,v)
local out,w,w0,i;
  if InfoLevel(c)>=a then
    if not IsRat(v) then
      out:=OutputTextUser();
      PrintTo(out,"\n");
      return;
    fi;
    w0:=SizeScreen()[1];
    w:=Int(v*(w0-Length(s)-5));
    if s=LAST_COMPLETIONBAR_STRING and w=LAST_COMPLETIONBAR_VAL then
      return; # nothing new to say
    fi;
    LAST_COMPLETIONBAR_STRING:=s;
    LAST_COMPLETIONBAR_VAL:=w;
    out:=OutputTextUser();
    v:=w;
    w:=w0;
    for i in [1..w] do
      PrintTo(out,"\r");
    od;
    PrintTo(out,"\c");
    w:=w-Length(s)-5;
    PrintTo(out,s," ");
    for i in [1..w] do
      if v>0 then
        PrintTo(out,"#");
      else
        PrintTo(out," ");
      fi;
      v:=v-1;
    od;
    PrintTo(out,"|\c");
  fi;
end);


#############################################################################
##
#V  InfoObsolete
##
##  This info class has a default level of 0.
##  Warnings can be switched on by setting its level to one.
##
DeclareInfoClass( "InfoObsolete" );
SetInfoLevel(InfoObsolete,0);
