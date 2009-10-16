#############################################################################
####
##
#W  masslave.g              ParGAP Package                     Gene Cooperman
##
##  Master Slave definitions.
##
#H  @(#)$Id: masslave.g,v 1.8 2001/11/17 12:17:04 gap Exp $
##
#Y  Copyright (C) 1999-2001  Gene Cooperman
#Y    See included file, COPYING, for conditions for copying
##
Revision.pargap_masslave_g :=
    "@(#)$Id: masslave.g,v 1.8 2001/11/17 12:17:04 gap Exp $";

# Provides:  MasterSlave(), IsUpToDate(), ParTrace (default value is true),
#            ParInstallTOPCGlobalFunction(),
#            MasterSlavePendingTaskInputs() [ to assist checkpointing ]
#            MasterSlaveStats() [ to diagnose where time is spent ]
# Requires application functions:  SubmitTaskInput(), DoTask(), 
#                                  CheckTaskResult(), UpdateSharedData()
# Requires from slavelist.g: SendMsg(), RecvMsg(), BroadcastMsg(),
#         ReadEvalFromString(), SENDRECV_TAG, MASTER_SLAVE_QUIT_TAG,
#         BROADCAST_TAG, MASTER_SLAVE_PING_TAG, PING_TAG

# External functions:
DeclareGlobalFunction("MasterSlave");
DeclareGlobalFunction("IsUpToDate");
# DeclareGlobalFunction("CONTINUATION_ACTION"); # synonym for CONTINUATION
DeclareGlobalFunction("CONTINUATION");
ParTrace := true;
# Variables set to statistics on master and slaves
MStime := 0; MSnrTasks := 0; MSnrUpdates := 0; MSnrRedos := 0;

# Internal functions;  Don't call them.  GAP needs these declarations.
DeclareGlobalFunction("TOPCmaster");
DeclareGlobalFunction("TOPCslave");
MScontinuation := 0;
lastUpdateTag := -1;
DeclareGlobalFunction("NextTag");
DeclareGlobalFunction("TOPCmasterInit");
DeclareGlobalFunction("TOPCslaveInit");
DeclareGlobalFunction("TOPCmasterSendTaskInput");
DeclareGlobalFunction("TOPCmasterRecvTaskOutput");
DeclareGlobalFunction("InitSlaveArray");
DeclareGlobalFunction("IsSlaveArrayEmpty");
DeclareGlobalFunction("IsSlaveArrayFull");
# Probably records make more sense for this part.
DeclareGlobalFunction("MakeSlaveArraySlot"); #w/ input, tag
DeclareGlobalFunction("ExistsSlaveArraySlot");
DeclareGlobalFunction("RemoveSlaveArraySlot");
DeclareGlobalFunction("SlaveArrayTag");
DeclareGlobalFunction("UpdateSlaveArrayTag");
DeclareGlobalFunction("SlaveArrayInput");
DeclareGlobalFunction("SlaveArrayOutput");
DeclareGlobalFunction("SetSlaveArrayOutput");
DeclareGlobalFunction("MasterSlaveTaskTimes");
DeclareGlobalFunction("MasterSlavePendingTaskInputs");
DeclareGlobalFunction("MasterSlaveDeadSlave");
DeclareGlobalFunction("MasterSlaveStats");

#============================================================
#Example:

NO_ACTION :=-1; NOTASK :=-1; # dummy values to avoid "Unbound global var error"
DeclareGlobalFunction("MSList");
MakeReadWriteGVar("MSList");
MSexample := function()
  Print("Defining new function using MasterSlave():   MSList(list, fnc)\n");
  MSList := function(list, fnc)
    local i, result, SubmitTaskInput, DoTask, CheckTaskResult, UpdateSharedData;
    result := [];
    i := 0;
    SubmitTaskInput := function()
      if i < Length(list) then i := i+1; return i;
      else return NOTASK;
      fi;
    end;
    DoTask := i -> fnc(list[i]);   # Apply fnc above.
    CheckTaskResult := function(input, output)
      result[input] := output;
      return NO_ACTION;
    end;
    UpdateSharedData := function(input, output); end;
    MasterSlave( SubmitTaskInput, DoTask, CheckTaskResult, UpdateSharedData );
    return result;
  end;
  Print("Now you can execute, for example:\n",
        "     BroadcastMsg( PrintToString(\"MSList := \", MSList) );\n",
        "     ParEval( \"MSList( [10..20], x->x^2 )\" );\n",
        "Or else you can define and then execute:\n",
        "     ParList := function(list,fnc)\n",
        "       return ParCallFuncList( MSList, [list, fnc] );\n",
        "     end;\n",
        "     ParList([10..20],x->x^2);\n",
        "(Note the current value of:  ParTrace := ", ParTrace, "; )\n",
        "You can also examine the code of MSList() by typing Print(MSList);\n" );
end;
UnbindGlobal("NO_ACTION"); UnbindGlobal("NOTASK");

#============================================================
# Primary External Functions

#enumerate constants
BindGlobal("NO_ACTION", Immutable(["NO_ACTION"]));
BindGlobal("REDO", Immutable(["REDO_ACTION"])); 
BindGlobal("UPDATE", Immutable(["UPDATE_ACTION"]));
BindGlobal("CONTINUE", Immutable(["CONTINUATION_ACTION()"]));
BindGlobal("REDO_ACTION", REDO);
BindGlobal("UPDATE_ACTION", UPDATE);
BindGlobal("UPDATE_ENVIRONMENT", UPDATE); #Backward compatibility
BindGlobal("UPDATE_SHARED_DATA", UPDATE); #The new preferred name
# NOTASK, DEAD_TASK must be unique GAP objects as tested by IsIdenticalObj()
BindGlobal("NOTASK", Immutable(["NOTASK"]));
BindGlobal("DEAD_TASK", Immutable(["DEAD_TASK"]));
# "TOPC_TASK_AGGLOM" must be unique GAP string as tested by operator, =
BindGlobal("TOPC_TASK_AGGLOM", Immutable("TOPC_TASK_AGGLOM"));

IsMasterSlaveMode := false;  # Allow IsUpToDate(), etc., to interrogate this.

InstallGlobalFunction(MasterSlave,
function( arg )
  local time, SubmitTaskInput, DoTask, CheckTaskResult, UpdateSharedData,
        taskAgglom, lastIsMasterSlaveMode;
  SubmitTaskInput := arg[1]; DoTask := arg[2]; CheckTaskResult := arg[3];
  if IsBound(arg[4]) then UpdateSharedData := arg[4];
  else UpdateSharedData := Error; fi;
  if IsBound(arg[5]) then taskAgglom := arg[5];
  else taskAgglom := 0; fi; # default: Don't aglomerate tasks
  time := Runtime(); MSnrTasks := 0; MSnrUpdates := 0; MSnrRedos := 0;

  lastIsMasterSlaveMode := IsMasterSlaveMode;
  IsMasterSlaveMode := true;
  if MPI_Comm_rank() = 0 then
    TOPCmaster(SubmitTaskInput, CheckTaskResult, UpdateSharedData, taskAgglom);
  else
    TOPCslave(DoTask, UpdateSharedData);
  fi;
  IsMasterSlaveMode := lastIsMasterSlaveMode;
  MStime := Runtime() - time;
end);

InstallGlobalFunction(IsUpToDate, function()
  if IsMasterSlaveMode then
    return SlaveArrayTag( MPI_Get_source() ) > lastUpdateTag
           # or tag marker turned over
           or lastUpdateTag - SlaveArrayTag( MPI_Get_source() ) >
             SENDRECV_TAG / 2;
  else return true; fi;
end);

InstallGlobalFunction( CONTINUATION, function( taskInput )
  MScontinuation := taskInput;
  return CONTINUE;
end);
# synonym for CONTINUATION
DeclareSynonym( "CONTINUATION_ACTION", CONTINUATION);

#============================================================
#Internal functions for MasterSlave

BindGlobal("TOPCnumSlaves", MPI_Comm_size()-1);
if IsMaster() then BindGlobal("TaskAgglomIndex", 1);
else TaskAgglomIndex := 1;
fi;
currTag := -1;  # Effectively declare it ReadWrite here

InstallGlobalFunction( TOPCmaster,
 function( SubmitTaskInput, CheckTaskResult, UpdateSharedData, taskAgglomCount )
  local lastInput, slave;

  TOPCmasterInit();

  while true do
    # First priority is to update environment (minimize task dependencies)
    while MPI_Iprobe() do
      TOPCmasterRecvTaskOutput( CheckTaskResult, UpdateSharedData );
    od;

    # Now generate new tasks for empty slots
    lastInput := TOPCmasterSendTaskInput( SubmitTaskInput, taskAgglomCount );

    # See if we're done, and break out of while loop, if so.
    if IsIdenticalObj(lastInput, NOTASK) and IsSlaveArrayEmpty() then
      # Incrementing currTag is harmless, since we're leaving
      if NextTag() = 1 then
        Print("Warning:  First task of MasterSlave() was NOTASK.\n");
      fi;
      for slave in [1..TOPCnumSlaves] do
        SendMsg( false, slave, MASTER_SLAVE_QUIT_TAG );
      od;
      break;
    fi;

    # IsSlaveArrayEmpty() is false and TaskInput's already sent;
    #   wait to receive TaskOutput
    TOPCmasterRecvTaskOutput( CheckTaskResult, UpdateSharedData );
  od;
end);

InstallGlobalFunction( TOPCslave, function( DoTask, UpdateSharedData )
  local msg, output, IncrTaskAgglomIndex;

  TOPCslaveInit();

  IncrTaskAgglomIndex := function(output)
      TaskAgglomIndex := TaskAgglomIndex+1; return output;
  end;

  while true do
    msg := RecvMsg();
    if MPI_Get_tag() = BROADCAST_TAG then # then an update
      MSnrUpdates := MSnrUpdates + 1;
      UpdateSharedData( msg[1], msg[2] );
    elif MPI_Get_tag() = MASTER_SLAVE_QUIT_TAG or MPI_Get_tag() = QUIT_TAG then
      break;
    elif MPI_Get_tag() = MASTER_SLAVE_PING_TAG then
      SendMsg( false, false, MASTER_SLAVE_PING_TAG );
    else
      MSnrTasks := MSnrTasks + 1;  # This includes new task and REDO
      TaskAgglomIndex := 1;
      if IsList(msg) and msg[1] = TOPC_TASK_AGGLOM then
        output := List(msg[2], inp->IncrTaskAgglomIndex(DoTask(inp)));
      else output := DoTask( msg );
      fi;
      TaskAgglomIndex := 1;
      SendMsg( output, 0);  # destination 0 is master
    fi;
  od;
end);

PrintAgglom := function( input )
  if IsList(input) and input[1] = "TOPC_TASK_AGGLOM" then
    Print("(AGGLOM_TASK): "); ViewObj(input[2]);
  else Print(" "); ViewObj(input);
  fi;
end;
TOPCtraceInput := function( input, slave )
  if IsIdenticalObj(input, NOTASK) then Print("master: NOTASK\n");
  else Print("master -> ", slave, ": "); PrintAgglom(input); Print("\n");
  fi;
end;
TOPCtraceOutput := function( output, slave )
  Print(slave, " -> master: "); ViewObj(output); Print("\n");
end;
TOPCtraceAction := function( action, slave )
  if not IsMasterSlaveMode then Print(action, "\n"); # For SeqMasterSlave()
  elif IsIdenticalObj( action, REDO ) then
    Print("REDO: master -> ", slave, ":");
    PrintAgglom(SlaveArrayInput(slave));
    Print("\n");
  elif IsIdenticalObj( action, UPDATE ) then
    Print("UPDATE: [");
    PrintAgglom(SlaveArrayInput(slave)); Print(", ");
    ViewObj( SlaveArrayOutput(slave) );
    Print(" ]\n");
  elif IsIdenticalObj( action, CONTINUE ) then
    Print("CONTINUATION(): \n");
  fi;
end;


InstallGlobalFunction(TOPCmasterSendTaskInput,
function( SubmitTaskInput, taskAgglomCount )
  local slave, input, count, inputAgglom;
  for slave in [1..TOPCnumSlaves] do
    inputAgglom := [];
    if not ExistsSlaveArraySlot(slave) then

      if MSnrTasks > TOPCnumSlaves and MSnrTasks mod TOPCnumSlaves = 0 then
        MasterSlaveDeadSlave();
      fi;

      count := 0;
      repeat
        input := SubmitTaskInput();
        count := count + 1;
        if IsIdenticalObj(input, NOTASK) then break; fi;
        if ForAny([NO_ACTION,REDO,UPDATE,CONTINUE], x->IsIdenticalObj(input,x))
          then Error("SubmitTaskInput() returned the action, ", input[1],
                     ", instead of NOTASK or task.");
        fi;
        Add( inputAgglom, input );
      until IsIdenticalObj(input, NOTASK) or count >= taskAgglomCount;

      if Length(inputAgglom) = 1 and taskAgglomCount <= 0 then
        inputAgglom := input; # default user setting for taskAgglomCount
      elif Length(inputAgglom) = 0 then break; # then input is NOTASK
      else inputAgglom := [ TOPC_TASK_AGGLOM, inputAgglom ];
      fi;

      MSnrTasks := MSnrTasks + 1;
      MakeSlaveArraySlot( slave, inputAgglom );
      if ParTrace then TOPCtraceInput( inputAgglom, slave ); fi;
      SendMsg( inputAgglom, slave, SlaveArrayTag(slave) ); 
    fi;
  od;
  # Caller wants to know if last input was NOTASK
  return input;
end);

InstallGlobalFunction(TOPCmasterRecvTaskOutput,
 function( CheckTaskResult, UpdateSharedData )
  local output, action, slave;
  output := RecvMsg();
  slave := MPI_Get_source();
  if ParTrace then TOPCtraceOutput( output, slave ); fi;

  SetSlaveArrayOutput( slave, output );
  if IsList(SlaveArrayInput(slave))
     and SlaveArrayInput(slave)[1] = TOPC_TASK_AGGLOM then
    action := CheckTaskResult( SlaveArrayInput(slave)[2], output );
  else action := CheckTaskResult( SlaveArrayInput(slave), output );
  fi;
  if ParTrace then TOPCtraceAction( action, slave ); fi;

  if IsIdenticalObj( action, NO_ACTION ) then
    RemoveSlaveArraySlot( slave );
  elif IsIdenticalObj( action, REDO ) then
    MSnrRedos := MSnrRedos + 1;
    UpdateSlaveArrayTag(slave);
    SendMsg( SlaveArrayInput(slave), slave, SlaveArrayTag(slave) );
  elif IsIdenticalObj( action, UPDATE ) then
    MSnrUpdates := MSnrUpdates + 1;
    # Slave seeing broadcast tag will assume UpdateSharedData()
    if IsList(SlaveArrayInput(slave))
       and SlaveArrayInput(slave)[1] = TOPC_TASK_AGGLOM then
      BroadcastMsg( [SlaveArrayInput( slave )[2], output] );
      UpdateSharedData( SlaveArrayInput(slave)[2], output );
    else
      BroadcastMsg( [SlaveArrayInput( slave ), output] );
      UpdateSharedData( SlaveArrayInput(slave), output );
    fi;
    lastUpdateTag := currTag;
    RemoveSlaveArraySlot( slave );
  elif IsIdenticalObj( action, CONTINUE ) then
    # CheckTaskResult() must have returned CONTINUATION(), which
    #   sets MScontinuation, and then returns CONTINUE
    UpdateSlaveArrayTag(slave);
    SendMsg( MScontinuation, slave, SlaveArrayTag(slave) );
  else Error("MasterSlave:  CheckTaskResult returned invalid action: ", action);
  fi;
end);

#============================================================
#Initialize master and slave before doing work

# Ping all slaves: see if they're alive, in MasterSlave mode; InitSlaveArray()
InstallGlobalFunction(TOPCmasterInit, function()
  local slave;
  for slave in [1..TOPCnumSlaves] do
    SendMsg( false, slave, PING_TAG );
    SendMsg( false, slave, MASTER_SLAVE_PING_TAG );
  od;
  for slave in [1..TOPCnumSlaves] do
    MPI_Probe(slave);   # We'll get some reply, unless slave is totally sick.
    if MPI_Get_tag() = PING_TAG then
      RecvMsg(slave);
      Error("Slave ", MPI_Get_source(), " not in MasterSlave mode.\n\n");
    elif MPI_Get_tag() = MASTER_SLAVE_PING_TAG then
      RecvMsg(slave);
    else Error("MasterSlave() begun while messages for",
               "  master are pending.\n",
               "You can type:  FlushAllMsgs()  and re-start.\n\n");
      # Ideally:  MPI_Irecv("",slave,PING_TAG);
      #   MPI_Irecv("",slave,MASTER_SLAVE_PING_TAG);
      #   in this case, but MPINU not defined well enough to handle that.
      # Does the MPI standard call that an error?
    fi;
  od;
  InitSlaveArray();
end);

# Look for and reply to initial ping from master
InstallGlobalFunction(TOPCslaveInit, function()
  RecvMsg( 0 );
  if MPI_Get_tag() <> PING_TAG then
    Error("Expected ping: rank ", MPI_Comm_rank() );
  fi;
  RecvMsg( 0 );  # MASTER_SLAVE_PING_TAG, in case last was a coincidence.
  if MPI_Get_tag() = MASTER_SLAVE_PING_TAG then
    SendMsg( false, 0, MASTER_SLAVE_PING_TAG );
  else
    Error("Did not receive MasterSlave ping: rank ", MPI_Comm_rank() );
  fi;
end);

#============================================================
# Data Structures and Utils for record keeping about slaves and pending tasks
# NOTE:  slaveArray, numSlaveArraySlots, slaveTaskTime are private;
#        They are accessed and modified only in this section.

currTag := 0;
lastUpdateTag := -1;
slaveArray := [];
slaveTaskTime := [];
slaveTaskTimeFactor := 2;
numSlaveArraySlots := 0;

InstallGlobalFunction(NextTag, function()
   currTag := currTag+1;
   if currTag >= SENDRECV_TAG then currTag := 1; fi;
   return currTag;
end);
InstallGlobalFunction(InitSlaveArray, function()
  local i;
  numSlaveArraySlots := 0;
  slaveArray := [];
  currTag := 0;
  lastUpdateTag := -1; # Initially guarantee:  IsUpToDate() = true
  slaveTaskTime := List([1..TOPCnumSlaves], x->rec(num:=0, total:=0, max:=0));
end);

# Hide slaveArray data structure
# Could use records:
#      rec(tag:=NextTag(),input:=taskInput,output:=taskOutput)
# and   slaveArray[slave].tag, etc.
# but maybe    SlaveArrayTag(slave)   is just as clear?
InstallGlobalFunction(IsSlaveArrayEmpty, function()
  return numSlaveArraySlots = 0; end);
InstallGlobalFunction(IsSlaveArrayFull, function()
   return ( numSlaveArraySlots = TOPCnumSlaves );
end);
InstallGlobalFunction(SlaveArrayTag, slave -> slaveArray[slave].tag);
InstallGlobalFunction(UpdateSlaveArrayTag,
  function( slave ) slaveArray[slave].tag := NextTag(); end);
InstallGlobalFunction(SlaveArrayInput, slave -> slaveArray[slave].input);
InstallGlobalFunction(SlaveArrayOutput, slave -> slaveArray[slave].output);
InstallGlobalFunction(SetSlaveArrayOutput, function( slave, taskOutput )
  local realtime, deltaTime;
  slaveArray[slave].output := taskOutput;

  realtime := UNIX_Realtime();
  deltaTime := realtime - slaveArray[slave].time;
  slaveTaskTime[slave].num :=  slaveTaskTime[slave].num+1;
  slaveTaskTime[slave].total :=  slaveTaskTime[slave].total + deltaTime;
  slaveTaskTime[slave].max := Maximum(slaveTaskTime[slave].max, deltaTime);
  slaveArray[slave].time := realtime;
end);
InstallGlobalFunction(MakeSlaveArraySlot, function( slave, taskInput )
  numSlaveArraySlots := numSlaveArraySlots + 1;
  slaveArray[slave] :=
    rec(tag := NextTag(), time := UNIX_Realtime(), input := taskInput);
end);
InstallGlobalFunction(ExistsSlaveArraySlot,
  slave -> IsBound(slaveArray[slave]));
InstallGlobalFunction(RemoveSlaveArraySlot, function( slave )
  numSlaveArraySlots := numSlaveArraySlots - 1;
  Unbind(slaveArray[slave]);
end);
InstallGlobalFunction(MasterSlaveTaskTimes, function()
  local realtime;
  realtime := UNIX_Realtime();
  if MPI_Comm_rank() <> 0 then
    Error("MasterSlavePendingTaskInputs() can only be called on master.");
  fi;
  return [List(slaveTaskTime, x->x.max),List(slaveArray, x->realtime-x.time)];
end);
InstallGlobalFunction(MasterSlaveDeadSlave, function()
  local max1, max2, pos1, pos2, deltas, realtime;
  if Length(slaveArray) = 0 then return; fi;
  realtime := UNIX_Realtime();
  max2 := Maximum(List(slaveTaskTime, x->x.max));
  pos2 := Position( List(slaveArray, x->realtime-x.time), max2 );
  deltas := List(slaveArray, x->realtime-x.time);
  Sort(deltas);
  if Length(deltas)>1 then max2 := Maximum(max2, deltas[Length(deltas)-1]); fi;
  max1 := deltas[Length(deltas)];
  pos1 := Position( List(slaveArray, x->realtime-x.time), max1 );
  if max1 > slaveTaskTimeFactor and max1 > 30
     and slaveTaskTime[pos2].total > 60 then
    Print("SLAVE ",pos1," SEEMS DEAD!!\n");
  fi;
end);
# To diagnose where time is spent in applications
InstallGlobalFunction(MasterSlaveStats, function()
  Apply(slaveTaskTime,
        function(x) x.ave_ms := QuoInt(x.total*1000,x.num); return x; end);
  return([rec(MStime:=MStime, MSnrTasks := MSnrTasks,
              MSnrUpdates := MSnrUpdates, MSnrRedos := MSnrRedos),
          slaveTaskTime]);
end);
#Documented to help application writer to do checkpointing.
InstallGlobalFunction(MasterSlavePendingTaskInputs, function()
  if MPI_Comm_rank() <> 0 then
    Error("MasterSlavePendingTaskInputs() can only be called on master.");
  fi;
  return List(slaveArray, x->x.input);
end);

#============================================================
# Convenience function for applications to use MasterSlave

ParInstallTOPCGlobalFunction := function( name, fnc )
  if not IsMaster() then return; fi;
  if IsString(name) then
    ParDeclareGlobalFunction( name );
  else
    name := NAME_FUNC(name);
  fi;
  # Define slave version of "name"
  BroadcastMsg( PrintToString("InstallGlobalFunction(",name,",",fnc,")" ));
  # Define master version of "name"
  InstallGlobalFunction( ReadEvalFromString(name),
    function( arg ) 
      BroadcastMsg( PrintToString( "CallFuncList(",name,",",arg,")") );
      return CallFuncList(fnc,arg);
    end );
end;

TaskInputIterator := function( collection )
  local iter;
  iter := Iterator( collection );
  return function()
           if IsDoneIterator(iter) then return NOTASK;
           else return NextIterator(iter);
           fi;
         end;
end;

DefaultCheckTaskResult := function( taskInput, taskOutput )
  if taskOutput = false then return NO_ACTION;
  elif not IsUpToDate() then return REDO_ACTION;
  else return UPDATE_ACTION;
  fi;
end;

DefaultGetTaskOutput := function()
  Error("OBSOLETE:  use `DefaultCheckTaskResult' instead of ",
        "`DefaultGetTaskOutput'\n");
end;

##EXAMPLE:
# InstallTOPCGlobalFunction( "MyParList",
# function( list, fnc )
#   local result, iter;
#   result := [];
#   iter := Iterator(list);
#   MasterSlave( TaskInputIterator( list ),
#                fnc,
#                function(input, output) result[input] := output;
#                                       return NO_ACTION; end,
#                Error  # Should not call UpdateSharedData()
#              );
#   return result;
# end);


#============================================================
# Sequential MasterSlave

SeqMasterSlave :=
  function( arg )
  local SubmitTaskInput, DoTask, CheckTaskResult, UpdateSharedData,
        taskInput, taskOutput, action;
  SubmitTaskInput := arg[1]; DoTask := arg[2]; CheckTaskResult := arg[3];
  if IsBound(arg[4]) then UpdateSharedData := arg[4];
  else UpdateSharedData := Error; fi;
  # ignore optional taskAgglom (arg[5]

  InitSlaveArray();
  while true do
    taskInput := SubmitTaskInput();
    if ParTrace then TOPCtraceInput( taskInput, 1 ); fi;
    if IsIdenticalObj(taskInput, NOTASK) then break; fi;
    repeat
      taskOutput := DoTask( taskInput );
      if ParTrace then TOPCtraceOutput( taskOutput, 1 ); fi;
      action := CheckTaskResult( taskInput, taskOutput );
      if ParTrace then TOPCtraceAction( action, 1 ); fi;
      if action = CONTINUE then taskInput := MScontinuation; fi;
    until action = NO_ACTION or action = UPDATE;
    if IsIdenticalObj( action, UPDATE ) then
      UpdateSharedData( taskInput, taskOutput );
    fi;
  od;
end;


#============================================================
# Experiment with RawMasterSlave
# The idea is that a traditional SubmitTaskInput() is a kind of GAP iterator.
# However, sometimes the original sequential code produces task inputs
#  inside of complicated nested loops.  In such cases, it is difficult
#  to create a corresponding iterator (and co-routines or threads would
#  in fact be the ideal language construct).
#  To get around this, we replace a single call to MasterSlave() by:
# BeginRawMasterSlave( DoTask, CheckTaskResult, UpdateSharedData )
# RawSubmitTaskInput( taskInput )
# EndRawMasterSlave()
# The application can then call RawSubmitTaskInput() repeatedly with the
#   new task inputs, before completing the computation by a call
#   to EndRawMasterSlave()

# We'd need a stack of these, if we want to allow recursion.
rawCheckTaskResult := ReturnFail; # arb. declaration
rawUpdateSharedData := Print;  # arb. declaration

BeginRawMasterSlave := function( DoTask, CheckTaskResult, UpdateSharedData )
  IsMasterSlaveMode := true;
  if MPI_Comm_rank() = 0 then
    TOPCmasterInit();
    rawCheckTaskResult := CheckTaskResult;
    rawUpdateSharedData := UpdateSharedData;
  else
    TOPCslave(DoTask, UpdateSharedData);
  fi;
end;

EndRawMasterSlave := function()
  local slave;
  if MPI_Comm_rank() = 0 then
    while not IsSlaveArrayEmpty() do
      TOPCmasterRecvTaskOutput( rawCheckTaskResult, rawUpdateSharedData );
    od;
    # Incrementing currTag is harmless, since we're leaving
    if NextTag() = 1 then
      Print("Warning:  EndRawMasterSlave:  RawSubmitTaskInput never called.\n");
    fi;
    for slave in [1..TOPCnumSlaves] do
      SendMsg( false, slave, MASTER_SLAVE_QUIT_TAG );
    od;
  fi;
  IsMasterSlaveMode := false;
end;

#This does same job as TOPCmaster(), previously.
RawSubmitTaskInput := function( arg )
  local taskInput, taskAgglomCount, SubmitTaskInput;

  if MPI_Comm_rank() <> 0 then return; fi;
  if Length(arg) < 1 or Length(arg) > 2 then
    Print("Bad usage: Use:  RawSubmitTaskInput( taskInput[, taskAgglomCount]\n");
  fi;
  taskInput := arg[1];
  if IsBound(arg[2]) then taskAgglomCount := arg[2];
  else taskAgglomCount := 0; fi; # default: Don't aglomerate tasks

  if taskInput = NOTASK and currTag = 0 then
    Print("WARNING:  RawSubmitTaskInput received NOTASK on first call.\n");
  fi;

  SubmitTaskInput := function()
    local tmp;
    tmp := taskInput;
    taskInput := NOTASK;  # With one call, we don't have a second task.
    return tmp;
  end;

  # First priority is to update environment (minimize task dependencies)
  while MPI_Iprobe() or IsSlaveArrayFull() do
    TOPCmasterRecvTaskOutput( rawCheckTaskResult, rawUpdateSharedData );
  od;

  # Now pass taskInput to an empty slot;
  # It's guaranteed to exist since IsSlaveArrayFull() is false.
  # This is a local SubmitTaskInput
  TOPCmasterSendTaskInput( SubmitTaskInput, taskAgglomCount );
end;

RawSetTaskInput := function()
  Error("OBSOLETE:  use `RawSubmitTaskInput' instead of `RawSetTaskInput'\n");
end;

MSexample2 := function()
  MSList := function(list, fnc)
    local i, result, DoTask, CheckTaskResult;
    result := [];
    DoTask := i -> fnc( list[i] );
    CheckTaskResult := function( input, output )
      result[input] := output;
      return NO_ACTION;
    end;

    BeginRawMasterSlave( DoTask, CheckTaskResult, Print );
    for i in [1..Length(list)] do 
      RawSubmitTaskInput(i);
    od;
    EndRawMasterSlave();
  end;
end;

#============================================================
# Experiment with futures:
#   This experiment causes futures to be computed on slaves in parallel.
#   Futures are probably most useful in shared memory, or else
#   remote processes will not see updates to the environment.
#   In distributed memory, a future cannot use any information beyond the
#   initial value of the environment.  In TOP-C terms,
#   it is unclear what should be the environment, and how it should
#   be updated on remote slaves.
#     If a future is purely functional, there's no dependency on any
#   environment, and it's all okay.

futureArray := [];
futureCounter := 0;
# A language modification would create a special type of variable, FUTURE;
#   Such variables would be created by MakeFuture() and evaluated
#   (and converted into variables of ordinary type) by EvaluateFuture()
MakeFuture := function(command)
  futureCounter := futureCounter+1;
  RawSubmitTaskInput( [ futureCounter, command ] );
  return futureCounter;
end;
EvaluateFuture := function(counter)
  local tmp;
  while not IsBound(futureArray[counter]) do
    RawSubmitTaskInput( NOTASK ); # Force RawMasterSlave() to get TaskOutput
  od;
  tmp := futureArray[counter];
  Unbind(futureArray[counter]);
  return tmp;
end;

FutureDoTask := function(command)
  return ReadEvalFromString(command[2]);
end;
FutureCheckTaskResult := function(input,output)
  futureArray[input[1]] := output;
  return NO_ACTION;
end;
BeginFutures := function()
  BeginRawMasterSlave( FutureDoTask, FutureCheckTaskResult, Print );
end;
EndFutures := function() EndRawMasterSlave(); end;

## Old name list
# (|Default|[Rr]aw|Future)GetTaskOutput -> $1DefaultCheckTaskResult
# (|Default|[Rr]aw|Future)UpdateEnvironment -> $1UpdateSharedData
# (|Default|[Rr]aw|Future)SetTaskInput -> $1SubmitTaskInput

#E  masslave.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
