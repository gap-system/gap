#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

MessageManagerData := rec ( finishing := false,
                            outgoingMessages := 0,
                            processesToFinish := 0);

ProcessFinish := function()
  local i;
  if processId=0 then
    for i in [1..commSize-1] do
      SendMessage (i, MESSAGE_TYPES.FINISH);
    od;
  else
    SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH, worker := 0 ) );
  fi;
  atomic DistTaskData do
    DistTaskData.finishing := true;
  od;
end;

ProcessStopManagers := function()
  local i;
  if processId = 0 then
    for i in [1..commSize-1] do
      SendMessage (i, MESSAGE_TYPES.STOP_MANAGERS);
    od;
    SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH, worker := 0 ) );
  else
    SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH, worker := 0 ) );
  fi;
end;

ProcessMessage := function (message)
  local task, taskdata, outMessage, i, tmp, source, handle, data, l1, toUnblock, msg, res;

  source := message.source;
  if message.type = MESSAGE_TYPES.EVAL_MSG then
    ReadEvalFromString(message.content);
    return false;
  elif message.type = MESSAGE_TYPES.SCHEDULE_MSG then
    ProcessScheduleMsg (message);
    return false;
  elif message.type = MESSAGE_TYPES.STEAL_MSG then
    ProcessSteal (message, source);
    return false;
  elif message.type = MESSAGE_TYPES.STOP_STEALING_MSG then
    Tasks.doStealing := false;
    Tasks.stealingStopped := true;
    PrintTaskManStats();
    return false;
  elif message.type = MESSAGE_TYPES.FINISH then
    ProcessFinish();
    return true;
  elif message.type = MESSAGE_TYPES.STOP_MANAGERS then
    ProcessStopManagers();
    return false;
  #elif message.type = MESSAGE_TYPES.REMOTE_PUSH_OBJ_MSG then
    #ProcessRemotePushObj(message);
    #return false;
  #elif message.type = MESSAGE_TYPES.PROCESS_FINISHED then
    #atomic readwrite DistTaskData do
      #DistTaskData.processesToFinish := DistTaskData.processesToFinish-1;
    #od;
  #elif message.type = MESSAGE_TYPES.REMOTE_COPY_OBJ_MSG then
    #ProcessRemoteCopyObj(message);
    #return false;
  #elif message.type = MESSAGE_TYPES.ACK_MSG then
    #ProcessAckMsg(message);
    #return false;
  elif message.type = MESSAGE_TYPES.GET_OBJ_MSG then
    ProcessGetObjMsg(message);
    return false;
  elif message.type = MESSAGE_TYPES.OBJ_MSG then
    ProcessObjMsg(message);
    return false;
  #elif message.type = MESSAGE_TYPES.FETCH_OBJ then
    #ProcessFetchObj(message);
    #return false;
  #elif message.type = MESSAGE_TYPES.REPLY_OBJ then
    #ProcessReplyObj(message);
    #return false;
  elif message.type = MESSAGE_TYPES.GLOBAL_OBJ_HANDLE_MSG then
    ProcessGlobalObjHandleMsg (message);
    return false;
  elif message.type = MESSAGE_TYPES.SET_BY_HANDLE_MSG then
    ProcessSetByHandleMsg (message);
    return false;
  elif message.type = MESSAGE_TYPES.CHANGE_GLOBAL_COUNT_MSG then
    ProcessChangeGlobalCountMsg (message);
    return false;
  else
    Error ("Unknown message type ", message.type, "\n");
    return true;
  fi;
end;

MessageManagerFunc := function()
  local finished, msg;
  finished := false;
  while not finished do
    #MPI_Probe();
    msg := GetMessage();
    #Print (MSTime(), " :: ", processId, " got a new message of type ", msg.type, " from ", msg.source, "\n");
    finished := ProcessMessage(msg);
    #if MPI_Probe() then
    #  msg := GetMessage();
    #  finished := ProcessMessage(msg);
    #fi;
  od;

end;

StopManagers := function()
  if processId <> 0 then
    Error("StopManagers can only be called from process 0!\n");
  else
    SendMessage (processId, MESSAGE_TYPES.STOP_MANAGERS);
  fi;

end;

FinishProcesses := function ()
  SendMessage (processId, MESSAGE_TYPES.FINISH);
end;

#ParFinish := function ()
#  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH, worker := 0 ));
#  WaitThread(TaskManager);
#  WaitThread(MessageManager);
#  MPI_Finalize();
#end;
