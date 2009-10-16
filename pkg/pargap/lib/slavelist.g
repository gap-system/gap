#############################################################################
####
##
#W  slavelist.g             ParGAP Package                     Gene Cooperman
##
##  Slave Listener definitions.
##
#H  @(#)$Id: slavelist.g,v 1.10 2001/11/17 12:17:04 gap Exp $
##
#Y  Copyright (C) 1999-2001  Gene Cooperman
#Y    See included file, COPYING, for conditions for copying
##
Revision.pargap_slavelist_g :=
    "@(#)$Id: slavelist.g,v 1.10 2001/11/17 12:17:04 gap Exp $";

#Requires:  streams.c:LastReadValue

#This file creates Slave Listener utilities.  An MPI process with
#  rank different from 0 goes into a:  Recv() - Eval() - Send() loop,
#  receiving commands from master and sending results back.
#A command can be either a GAP object or a string.
#  Since a GAP object as an argument to SendMsg() will usually be
#  evaluated locally before being sent, sending a string is more useful.
#  Strings are evaluated on the remote process.  See examples in comments.
#As with all of GAP/MPI, you must first have a procgroup file
#  in the current directory, and you must then call the gapmpi.sh script.

#The slave listener utilities defined are:

# SendMsg( command[, dest[, tag]] )
# RecvMsg( [dest] )
# SendRecvMsg( command[, dest[, tag]] )
# BroadcastMsg( command )
#   [Executes on slaves only.  SlaveListeners do not return a value]
# ParReset() # Try this to re-sync master and slaves
# FlushAllMsgs()
# PingSlave( slave ) # -1 means all slaves
# ParEval( stringCmd ): Evaluate on all processes
#   [like BroadcastMsg(), but ParEval() also executes on master
#    and also returns a value]
# ParCallFuncList( func, list );
# PrintToString( object [, ...] )
#   [ A useful idiom is:  ParEval( PrintToString( "foo := ", foo ) );
#     Note that PrintToString("abc") => "abc"  ( similar to Print() ) ]
# ReadEvalFromString( string )
# ParRead( filename ): Read file on all processes
# ParList( fnc, list ): Like List(), but faster due to use of slaves
# ParBindGlobal( gvar, value ); Like GAP
# ParDeclareGlobalVariable( string ); Like GAP; Also clears def. of string
# ParDeclareGlobalFunction( string ); Like GAP; Also clears def. of string
# ParInstallValue( string_or_gvar, fnc ); 
#               If string, first clears def. of string; else like GAP
# ParInstallGlobalFunction( string_or_gvar, fnc ); 
#               If string, first clears def. of string; else like GAP
# ProbeMsg([source]): Probe source and block (default=MPI_ANY_SOURCE)
#			return true when message is available
# ProbeMsgNonBlocking([source]): Probe if msg pending at source (default=MPI_ANY_SOURCE)
#			return true or false immediately
#NOTE that GetLastMsgSource() and GetLastMsgTag(), defined below, are
#  available to interrogate source and tag of pending msg
#Utilities inherited from MPI and UNIX:
# MPI_Comm_rank():  unique integer rank for each process
# MPI_Comm_size():  number of MPI processes
# GetLastMsgSource(): Source of last message received OR probed
# GetLastMsgTag():  Source of last message received OR probed.
#			Tags are an MPI concept.  You can safely ignore them.
# IsMaster():  Boolean; true if executed on master;  else false
# UNIX_Chdir(string): UNIX chdir(dir):  change directory
# UNIX_DirectoryCurrent():  Returns current directory as string
# UNIX_Alarm(seconds):  UNIX alarm syscall: kill process in sec seconds;
#                         returns seconds until death from previous call
#			  Put this in .gaprc to prevent runaway processes.
# UNIX_Nice(priority): UNIX setpriority syscall (nice in shell):
#			 Lower priority to new value between 19 (lowest
#			 priority) and -20 (highest priority, reserved for root)
# UNIX_LimitRss(bytes): UNIX setrlimit syscall (limit or ulimit in shell):
#			  Limit Resident Set Size (RSS or RAM usage) to bytes;
#			  Process uses more RAM if remaining RAM is unused.
#                         Returns previous RSS limit.
#			  Some UNIX dialects may always set it to all of RAM.

# Note that command can be a string or GAP object, but a GAP object
#  argument to SendMsg(), etc., will be evaluated locally first.
#  Also, a string allows passing of multiple commands.

# Examples [Assumes two slaves in procgroup file]:
#    myfnc := function() return 42; end;
#    BroadcastMsg( PrintToString( "myfnc := ", myfnc ) );
#    SendMsg( "a:=45; 3+4", 1 );
#    SendMsg( "a", 2 );
#    RecvMsg( 2 );
#    RecvMsg();
#    squares := ParList( [1..100], x->x^2 );
#    ParRead( "/home/gene/.gaprc" );
# Also, for a simple problem, execute:    MSexample();

#============================================================
# Test send and receive between slaves before getting serious
# Also, slave will try to change current directory to match master.

#Does this work in GAP-4.1?  Anyway, we check this in lib/init.g now.
# if not IsBound(MPI_Initialized) then quit;

# The gapmpi.c kernel function, UNIX_MakeString can be used instead.
MakeString := function( len )
  local i, x;
  x := [];
  for i in [1..len] do
    x[i] := ' ';
  od;
  ConvertToStringRep(x); # Needed to convert to compact C string.
  return x;
end;

# This is needed to obtain the absolute pathname of the current directory
UNIX_DirectoryCurrent := function()
  local paths, pwd, string, stream;
  paths := DirectoriesSystemPrograms();
  pwd := Filename( paths, "pwd" );
  string := "";
  stream := OutputTextString(string,true);
  Process( DirectoryCurrent(), pwd, InputTextNone(), stream, [] );
  CloseStream(stream);
  # string contains string with trailing newline
  if string[Length(string)] = '\n' then
    Unbind(string[Length(string)]);
  fi;
  return string;
end;

# Slave tells master his hostname and his UNIX process ID (pid)
# Master tells slave his home directory here.
# The master can send the slave a SIGINT signal directly.
if IsBoundGlobal("hostname") then
  Print("MPI already running.  Will not re-initialize.\n");
else
  masterHostname := UNIX_Hostname();
  hostname := [];
  pid := [];
  if MPI_Comm_rank() <> 0 then
    Print("\nSlave ", MPI_Comm_rank(), " (", UNIX_Hostname(),
          ") reporting.\n\n");
    MPI_Send( UNIX_Hostname(), 0 );
    MPI_Send( String(UNIX_Getpid()), 0 );
    MPI_Probe();
    msg := MPI_Recv( UNIX_MakeString( MPI_Get_count() ), MPI_Get_source() );
    # THIS NEXT LINE IS A COMPLETE HACK.  WHERE DOES THE '\n' COME FROM?
    if  msg[Length(msg)] = '\n' then msg[Length(msg)] := CHAR_INT(0); fi;
    IsString(msg);
    if not UNIX_Chdir( msg ) then
      Print( "Slave ", MPI_Comm_rank(), " was not able to change directory.\n");
      Print( "  Using home directory.\n\n" );
    fi;
  else
    Print("\nMaster here.  Will try to reach slaves.\n\n");
    for slave in [1..MPI_Comm_size() - 1] do
       MPI_Probe();
       Print( "\nReceiving from slave ", MPI_Get_source(), "\n\n");
       hostname[ MPI_Get_source() ] :=
         MPI_Recv( UNIX_MakeString( MPI_Get_count() ), MPI_Get_source() );
       MPI_Probe( MPI_Get_source() );
       pid[ MPI_Get_source() ] :=
         MPI_Recv( UNIX_MakeString( MPI_Get_count() ), MPI_Get_source() );
       MPI_Send( UNIX_DirectoryCurrent(), MPI_Get_source() );
    od;
  fi;
fi;

#==========================================================================
# Utilities for messages, read-eval-print loop issues

NO_RET_VAL := "<no_return_val>";
# Avoid "unbound global variable" in parsing ReadEvalFromString.
#   All because LastReadValue is read-only.  What a pain.  :-)
if IsReadOnlyGlobal("LastReadValue") then
  MakeReadWriteGVar("LastReadValue");
  LastReadValue := NO_RET_VAL;
  MakeReadOnlyGVar("LastReadValue");
else
  LastReadValue := NO_RET_VAL;
fi;

ReadEvalFromString := function(str)
  local i, j;
  if not IsString(str)
    then Error("string argument required"); fi;
  # The issue is that GAP printing to streams produces "\n\0" sequences.
  # Also, Read( InputTestString( str ) ); wants to see ';'
  if Length(str) = 0 then Error("Reading and evaluating null string"); fi;
  i := CHAR_INT(0);  # In GAP, CHAR_INT(INT_CHAR('\0')) = '0', not '\0'
  str := Filtered(str, x->x<>i);
  if str[Length(str)] <> ';' and str[Length(str)-1] <> ';' then
    str[Length(str)+1] := ';';
  fi;
  if IsReadOnlyGlobal("LastReadValue") then
    MakeReadWriteGVar("LastReadValue");
    LastReadValue := NO_RET_VAL;
    MakeReadOnlyGVar("LastReadValue");
  else
    LastReadValue := NO_RET_VAL;
  fi;
  Read( InputTextString( str ) ); # Read() does ReadEval in GAP
  # If variable, last, is used, GAP complains about unbound global variable
  #  or  Variable: 'last' must have an assigned value; during execution
  # UNIX_Last() was a C routine to do the same.  GAP doesn't see use of last.
  if not IsBoundGlobal("LastReadValue") then
    return NO_RET_VAL;  # Unfortunately, Read() seems to unbind LastReadValue
			#   when there was no return value.
    return "<exception or interrupt>";
  fi;
  return LastReadValue;
end;

# Converts object to string representation
PrintToString := function( arg )
  local str, output, obj;
  str := "";
  output := OutputTextString( str, true ); # true means do as append
  # Would PrintTo -> AppendTo be necessary if "true"->"false" above?
  for obj in arg do
    PrintTo(output, obj);
  od;
  CloseStream(output);
  # With gap4b5 (and gap4b4?), GAP objects have '\0' in print representation
  # This removes them.
  obj := CHAR_INT(0);  # In GAP, CHAR_INT(INT_CHAR('\0')) = '0', not '\0'
  str := Filtered(str, x->x<>obj);
  if str[Length(str)] <> '\n' then str[Length(str)+1] := '\n'; fi;
  str[Length(str)+1] := obj;
  return str;
end;

# This isn't needed, but it illustrates what's possible.
ReadEvalPrint := function(command)
  local result;
  result := ReadEvalFromString( command );
  return PrintToString( result );
end;

# if not IsBound( DeclareGlobalFunction ) then
#   DeclareGlobalFunction := "NOT_DEFINED";
# fi;
# MyDeclareGlobalFunction := function( strname )
#   if DeclareGlobalFunction <> "NOT_DEFINED" then  # if GAP-4.x ...
#     # What is the GAP 4.x way to declare functions, use them, and then define
#     # ReadEvalFromString( PrintToString( "DeclareGlobalFunction(\"",
#     #				       strname, "\");" ) );
#     ReadEvalFromString( PrintToString( strname, " := ReturnTrue;" ) );
#   else                    # else GAP-4 beta 3
#     ReadEvalFromString( PrintToString( strname, " := NewOperationArgs(\"",
# 				       strname, "\");" ) );
#   fi;
# end;

#Declare it now for InterruptSlave()
DeclareGlobalFunction("RecvStringMsg");

InterruptSlave := function( slave )
  if MPI_Comm_rank() <> 0 then
    Error("InterruptSlave() can only be called from master.");
  fi;
  if not slave in [1..MPI_Comm_size()-1] then
    Error("Slave ", slave, " does not exist.");
  fi;
  if hostname[slave] = masterHostname then
    Exec("kill -2", pid[slave]);
  else
    Exec("rsh", hostname[slave], "kill -2", pid[slave]);
  fi;
  # Throw away additional messages. (Not guaranteed:  possible race condition.)
  while MPI_Iprobe( slave ) do RecvStringMsg( slave ); od;
end;

#========================================================================
# Primitives for talking to slave listener.

# enumeration of special tags starts here;
CURR_SPEC_TAG := 10000;
NextSpecTag := function()
   CURR_SPEC_TAG := CURR_SPEC_TAG+1;
   return CURR_SPEC_TAG;
end;
SENDRECV_TAG := NextSpecTag();
PING_TAG := NextSpecTag();
SLAVEREPLY_TAG := NextSpecTag(); # Order is important; See SlaveListener();
QUIT_TAG := NextSpecTag();
BROADCAST_TAG := NextSpecTag();
MASTER_SLAVE_PING_TAG := NextSpecTag();
MASTER_SLAVE_QUIT_TAG := NextSpecTag();

SendMsg := function( arg )
  local command, dest, tag;
  command := arg[1]; dest := 1; tag := 1;
  if MPI_Comm_rank() > 0 then dest := 0; fi;
  if Length(arg) > 1 then dest := arg[2]; fi;
  if Length(arg) > 2 then tag := arg[3]; fi;
  # ParGAP calls this with large tags.  Only user should not.
  # if tag < 1 or tag > 1000 then
  #     Error("SendMsg: tag = ", tag, "; must be in range [1..1000]");
  # fi;
  if not IsInt(dest) or
      (not dest in [1..MPI_Comm_size() - 1] and 0 = MPI_Comm_rank() ) then
    Error("SendMsg: Invalid dest: ", dest);
  fi;
  MPI_Send( PrintToString(command), dest, tag );
end;

BroadcastMsg := function( command )
  local dest;
  if MPI_Comm_rank() <> 0 then
    Error("BroadcastMsg() should be called on master, only.");
  fi;
  for dest in [1..MPI_Comm_size() - 1] do
    SendMsg( command, dest, BROADCAST_TAG );
  od;
end;

InstallGlobalFunction(RecvStringMsg, function( arg )
  local buffer, source;
  source := MPI_ANY_TAG;
  if Length(arg) > 0 then source := arg[1]; fi;
  MPI_Probe( source );
  # MPI_Get_count() assumes type MPI_CHAR
  # GAP's NEW_STRING() creates an extra byte at end with '\0' automatically.
  buffer := UNIX_MakeString( MPI_Get_count() );
  # Note MPI_ANY_SOURCE is bug if second message arrives after MPI_Get_count()
  return MPI_Recv( buffer, MPI_Get_source() );
end);

RecvMsg := function( arg )
  local source, str;
  source := MPI_ANY_SOURCE;
  if Length(arg) > 0 then source := arg[1]; fi;
  if source <> MPI_ANY_SOURCE
     and ( not IsInt(source) or 
      (not source in [1..MPI_Comm_size() - 1] and 0 = MPI_Comm_rank() ) ) then
    Error("RecvMsg: Invalid source: ", source);
  fi;
  str := RecvStringMsg( source );
  if Length(str) > 0 then
    return ReadEvalFromString( str );
  else return fail; # This happens when slave receives interrupt
  fi;
end;

SendRecvMsg := function( arg )
  local command, dest, tag;
  command := arg[1]; dest := 1; tag := SENDRECV_TAG;
  if Length(arg) > 1 then dest := arg[2]; fi;
  if Length(arg) > 2 then tag := arg[3]; fi;
  SendMsg( command, dest, tag );
  return RecvMsg( dest, SENDRECV_TAG );
end;

#======================================================================
# GAP Utilities for parallel programming

#Aliases for MPI functions that the user might prefer:
ProbeMsg := MPI_Probe;
ProbeMsgNonBlocking := MPI_Iprobe;
GetLastMsgTag := MPI_Get_tag; # Functional interface to status.tag
GetLastMsgSource := MPI_Get_source; # Functional interface to status.source
IsMaster := function() return MPI_Comm_rank() = 0; end;

#Declare it now for ParReset()
DeclareGlobalFunction("PingSlave");
DeclareGlobalFunction("FlushAllMsgs");

ParReset := function()
  local count, slave;
  count := FlushAllMsgs();
  for slave in [1..MPI_Comm_size()-1] do
    SendMsg( false, slave, PING_TAG );
  od;
  Print("... resetting ...\n");
  for slave in [1..10000000] do od;  # timing loop
  # This assumes there's time for slave to reply before we probe.
  for slave in [1..MPI_Comm_size()-1] do
    if MPI_Iprobe(slave) then
      RecvStringMsg(slave);  # don't evaluate, just throw away
    else
      InterruptSlave( slave );
    fi;
  od;
  # PARANOID:  clean up just in case.
  FlushAllMsgs();
  PingSlave( -1 );  # -1 means all slaves
  return count;
end;

# A more sophisticated version of this would "rsh" a remote process
# and send a SIGINT to the remote slaves to also FlushAllMsgs().
# This also returns how many messages were flushed.
InstallGlobalFunction( FlushAllMsgs, function()
  local count, slave;
  # Do this first, in case a slave is stuck in MasterSlave mode.
  for slave in [1..MPI_Comm_size()-1] do
        SendMsg( false, slave, MASTER_SLAVE_QUIT_TAG );
  od;
  count := 0;
  while MPI_Iprobe() do
    RecvStringMsg();  # don't evaluate, just throw away
    count := count + 1;
  od;
  return count;
end);

InstallGlobalFunction( PingSlave, function( dest )
  if dest = -1 then # then ping all slaves
    for dest in [1..MPI_Comm_size() - 1] do PingSlave( dest ); od;
  else
    SendRecvMsg( false, dest, PING_TAG );
    if MPI_Get_tag() <> PING_TAG then
      Error("Slave ", dest, " not responding.\n");
    fi;
  fi;
  return true;
end);

ParEval := function( command )
  local result;
  BroadcastMsg( command );
  result := ReadEvalFromString( command );
  if result = NO_RET_VAL then return; fi;
  return result;
end;

ParCallFuncList := function( func, list )
  return ParEval( PrintToString( "CallFuncList(", func, ",", list, ")" ) );
end;

#PROBLEM:  NAME_HVAR() defined only at C level, not at GAP level.
# ParBindGlobal := function( gvar, value )
#   ParEval( PrintToString("BindGlobal(",gvar,",",value,")") );
# end;
ParDeclareGlobalVariable := function( name )
  if not IsMaster() then
      Error("ParDeclareGlobalVariable: Function: valid only on master.\n");
  fi;
  if IsBoundGlobal(name) then
      ParEval( PrintToString("MakeReadWriteGVar(\"",name,"\")") );
      ParEval( PrintToString("UnbindGlobal(\"",name,"\")") );
  fi;
  ParEval( PrintToString("DeclareGlobalVariable(\"", name, "\")") );
end;
ParDeclareGlobalFunction := function( name )
  if not IsMaster() then
      Error("ParDeclareGlobalFunction: valid only on master.\n");
  fi;
  if IsBoundGlobal(name) then
      ParEval( PrintToString("MakeReadWriteGVar(\"",name,"\")") );
      ParEval( PrintToString("UnbindGlobal(\"",name,"\")") );
  fi;
  ParEval( PrintToString("DeclareGlobalFunction(\"", name, "\")") );
end;
ParInstallGlobalFunction := function( name, fnc )
    if not IsMaster() then
        Error("ParInstallGlobalFunction: valid only on master.\n");
    fi;
    if IsString(name) then
        ParDeclareGlobalFunction( name );
    else
        name := NAME_FUNC(name);
    fi;
    ParEval("__tmp__ := InfoLevel(InfoWarning)");
    ParEval("SetInfoLevel(InfoWarning,0)");
    ParEval( PrintToString("InstallGlobalFunction(",name,",",fnc,")" ));
    ParEval("SetInfoLevel(InfoWarning,__tmp__)");
end;
#PROBLEM:  NAME_HVAR() defined only at C level, not at GAP level.
ParInstallValue := function( name, fnc )
    if not IsMaster() then
        Error("ParInstallGlobalFunction: valid only on master.\n");
    fi;
    if IsString(name) then
        ParDeclareGlobalVariable( name );
    else
        Error("ParInstallValue implemented only for variable given as string.");
        # name := NAME_HVAR(name);
    fi;
    ParEval( PrintToString("InstallValue(",name,",",fnc,")" ));
end;

ParList := function( arg )
  local usage, list, fnc, dest, nslaves, delta, range, tmp, tag, ntags, 
        xtag, result;
  usage := "usage: ParList( <list>, <fnc>[, <delta>] )\n";
  if not Length(arg) in [2, 3] then
    Error( "expected 2 or 3 arguments;\n", usage );
  fi;
  list := arg[1];
  fnc  := arg[2];
  if not IsList(list) then
    Error( "argument <list> must be a list;\n", usage );
  fi;
  if not IsFunction(fnc) then
    Error( "argument <fnc> must be a function;\n", usage );
  fi;
  nslaves := MPI_Comm_size() - 1;
  if 3 = Length(arg) then
    delta := arg[3];
    if not IsPosInt(delta) then
      Error( "argument <delta> must be a positive integer;\n", usage );
    fi;
  else
    delta := Length(list) / nslaves;
    if not IsInt(delta) then delta := Int(delta) + 1; fi;
  fi;
  ntags := Length(list) / delta;
  if not IsInt(ntags) then ntags := Int(ntags) + 1; fi;
  for tag in [1..ntags] do
    range := [ delta*(tag-1)+1 .. Minimum(delta*tag, Length(list)) ];
    ParEval( PrintToString( "parListFnc := ", fnc ) );
    dest := tag mod nslaves;
    if dest = 0 then dest := nslaves; fi;
    SendMsg( PrintToString( "List( ", list{ range }, ", parListFnc )" ),
             dest, tag );
  od;
  result := [];
  for xtag in [1..ntags] do
    tmp := RecvMsg();
    tag := MPI_Get_tag();
    range := [ delta*(tag-1)+1 .. Minimum(delta*tag, Length(list)) ];
    result{ range } := tmp;
  od;
  return result;
end;

ParRead := function( file )
  if not IsString(file) then Error("string argument required"); fi;
  ParEval( Concatenation( "Read( \"", file, "\" )" ) );
end;
ParReread := function( file )
  if not IsString(file) then Error("string argument required"); fi;
  ParEval( Concatenation( "Reread( \"", file, "\" )" ) );
end;


#============================================================================
# Basic slave listener functions

SlaveListener := function()
  local result;
  while true do
    result := RecvMsg();
    # On master, gap prompt includes newline, which causes fflush().
    # On slave, we do this part manually to handle SendMsg("Print(3)");
    # Defined in gapmpi.c, but could have been defined:
    #   UNIX_FflushStdout := function() Print([CHAR_INT(3)]); end;
    UNIX_FflushStdout();
    if MPI_Get_tag() = QUIT_TAG then break; fi;
    if MPI_Get_tag() = PING_TAG then result := true; fi;
    # Note that BROADCAST_TAG > SLAVEREPLY_TAG, and so there's no reply.
    if MPI_Get_tag() < SLAVEREPLY_TAG then
      # if it will print with '"' then ...
      # The weird test condition mimics the logic of GAP's Print() command.
      if IsString(result)
          and ( Length(result) > 0 or IS_STRING_REP(result) ) then 
        result := Concatenation("\"", result, "\"");
      else
        result := PrintToString(result);
      fi;
      SendMsg( result, 0, MPI_Get_tag() );
    fi;
    #In GAP 4b3:
    # The statements below don't work.  Apparently, CloseStream() (or even the
    #  fflush() in PrintTo() ) inside ReadEvalPrint()
    #  doesn't take effect until after this statement has completed.
    # MPI_Send( PrintToString(result), 0, MPI_Get_tag() );
    # MPI_Send( ReadEvalPrint( buffer), 0 );
  od;
  return true; # Return anything but fail
end;

CloseSlaveListener := function ()
  local dest;
  if not MPI_Initialized() then return; fi;
  if MPI_Comm_rank() <> 0 then MPI_Finalize(); return; fi;
  ParReset(); # slave should still be alive for this.  QUIT_TAG is later.
  for dest in [1..MPI_Comm_size() - 1] do
    # paranoia:  ParReset() should already have taken us out of MasterSlave.
    SendMsg( false, dest, MASTER_SLAVE_QUIT_TAG ); # in case in MasterSlave
    SendMsg( false, dest, QUIT_TAG );
  od;
  MPI_Finalize();
end;

InstallAtExit( CloseSlaveListener );

#=============================================================================

# This is now done in .../pkg/gapmpi/read.g
# if not IsBound( MasterSlave ) then
#   ReadPkg("gapmpi","lib/masslave.g");
# fi;
# 
# if MPI_Comm_rank() <> 0 then
#   # Call SlaveListener(), and repeat if we catch SIGINT (if we return fail)
#   while fail = UNIX_Catch( SlaveListener, [] ) do
#     # GAP 4b3 wants a non-empty, non-trivial body.
#     # This statement should have no effect, and it can go away in GAP 4.x
#     for i in [1..100] do i := i; od;
#   od;
# fi;

# quit;

#E  slavelist.g . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
