#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

DistTaskData := ShareSpecialObj ( rec ( outstandingMessages := 0,
                        finishing := false ));

########### some lower level functionality
UnblockWorker := function(worker)
  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER,
                                                        worker := worker));
end;

UnblockFetch := function (obj, source, remAddr)
  SendMessage (source, MESSAGE_TYPES.REPLY_OBJ, remAddr, obj);
end;
############


SendTaskWithHandle := atomic function (readonly task, readonly handle, dest)
  local toTempUnblock, ind, i, taskdata, handleWrapper, taskArg, p, toBlock, handleComplete, foo;
  # create a taskdata struct that will be sent to the destination node
  taskdata := rec ( func := String(task.func),
                    args := task.args,
                    async := task.async);
  # create a handle for result and create a wrapper for it
  #handle := GlobalObjHandles.CreateHandle(processId,dest,false,ACCESS_TYPES.READ_WRITE);
  #handle!.localId := HANDLE_OBJ(handle);
  #MyInsertHashTable (GAMap, MakeReadOnlyObj(rec ( pe := handle!.pe, localId := handle!.localId)), handle);
  #atomic task do
  #  task.offloaded := true;
  #  task.result := handle;
  #  task.adopt_result := false;
  #od;
  # send the task to the destination
  #if MPI_DEBUG.TASKS then MPILog(MPI_DEBUG_OUTPUT.TASKS, handle, String(HANDLE_OBJ(task)), " --> ", String(dest)); fi;
  #atomic taskdata.args do
    for taskArg in taskdata.args do
      if RegionOf(taskArg)<>RegionOf(taskdata.args) then
        p := LOCK(taskArg, false);
      fi;
    od;
    SendMessage (dest, MESSAGE_TYPES.SCHEDULE_MSG, handle, taskdata.func, taskdata.args, taskdata.async);
    UNLOCK(p);
  #od;
  atomic TaskStats do
    TaskStats.tasksOffloaded := TaskStats.tasksOffloaded+1;
  od;
  toTempUnblock := TryReceiveChannel (task.blockedWorkers, fail);
  while not IsIdenticalObj(toTempUnblock, fail) do
    SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER,
                                                          worker := toTempUnblock.worker));
    toTempUnblock := TryReceiveChannel (task.blockedWorkers, fail);
  od;
  return handle;
end;

SendTask := function(task, dest)
  local handle;
  handle := GlobalObjHandles.CreateHandle(processId,dest,false,ACCESS_TYPES.READ_WRITE);
  handle!.localId := HANDLE_OBJ(handle);
  MyInsertHashTable (GAMap, MakeReadOnlyObj(rec ( pe := handle!.pe, localId := handle!.localId)), handle);
  atomic task do
    task.offloaded := true;
    task.result := ShareSpecialObj(handle);
    task.adopt_result := false;
  od;
  SendTaskWithHandle (task, handle, dest);
end;
###########

ProcessScheduleMsg := function(message)
  local source, taskdata, taskDataList, handle, task, taskArg, argHandleWrapper, argHandle, p, maybeHandle;
  source := message.source;
  handle := message.content[1];
  MyInsertHashTable (GAMap, MakeReadOnlyObj(rec ( pe := handle!.pe, localId := handle!.localId )), handle);
  if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.GA_MAP, handle, String(HANDLE_OBJ(handle))); fi;
  ShareSpecialObj(handle);
  taskdata := rec (func := message.content[2],
                   args := message.content[3],
                   async := message.content[4]);
  # create a list of task arguments to be passed to CreateTask function
  taskDataList := [taskdata.func];
  for taskArg in taskdata.args do
    if IsGlobalObjectHandle(taskArg) then
      maybeHandle := MyLookupHashTable(GAMap, rec ( pe := taskArg!.pe, localId := taskArg!.localId ));
      if IsIdenticalObj(fail, maybeHandle) then
        MyInsertHashTable (GAMap, MakeReadOnlyObj(rec ( pe := taskArg!.pe, localId := taskArg!.localId )), taskArg);
        if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.GA_MAP, handle, String(HANDLE_OBJ(handle))); fi;
        ShareSpecialObj(taskArg);
        Add (taskDataList, taskArg);
      else
        Add (taskDataList, maybeHandle);
      fi;
    else
      Add (taskDataList, taskArg);
    fi;
  od;
  # create a task
  task := ShareSpecialObj(CreateTask (taskDataList));
  atomic TaskStats do
    TaskStats.tasksCreated := TaskStats.tasksCreated-1;
  od;
  # set a handle for the task result
  atomic readwrite task do
    task.result := handle;
  od;
  # notify the task manager that we got task
  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.GOT_TASK, worker := 0));
  # finally, execute task
  if MPI_DEBUG.TASKS then
    atomic readonly handle do
      MPILog(MPI_DEBUG_OUTPUT.TASKS, handle, String(HANDLE_OBJ(task)), " R");
    od;
  fi;
  ExecuteTask(task);
  atomic TaskStats do
    TaskStats.tasksStolen := TaskStats.tasksStolen+1;
  od;
end;

########### load balancing functions
InstallGlobalFunction(SendSteal, function()
  local target;
 # atomic readonly DistTaskData do
 #   if DistTaskData.finishing then
 #     return;
 #   fi;
 # od;
 #
  repeat
    target := Random([0..commSize-1]);
  until target<>processId;
  SendMessage (target, MESSAGE_TYPES.STEAL_MSG, processId, 1);
end);

ProcessSteal := function (msg, source)
  local age, newTarget, myId, orig, task, handle;
  # atomic readonly DistTaskData do
  #  if DistTaskData.finishing then
  #     return;
  #   fi;
  # od;
  orig := msg.content[1];
  age := msg.content[2];
  if Tasks.stealingStopped then
    return;
  elif not Tasks.doStealing then
    Tasks.doStealing := true;
  fi;
  if orig=processId then
    SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.UNSUCC_STEAL, worker := 0 ));
    return;
  fi;
  atomic TaskPoolData do
    if TaskPoolData.TaskPoolLen>1 then
      task := TaskPoolData.TaskPool[TaskPoolData.TaskPoolLen];
      atomic task do
        handle := GlobalObjHandles.CreateHandle(processId,orig,false,ACCESS_TYPES.READ_WRITE);
        handle!.localId := HANDLE_OBJ(handle);
        MyInsertHashTable (GAMap, MakeReadOnlyObj(rec ( pe := handle!.pe, localId := handle!.localId)), handle);
        task.offloaded := true;
        task.result := ShareSpecialObj(handle);
        SendTaskWithHandle(task, handle, orig);
        task.adopt_result := false;
      od;
      TaskPoolData.TaskPoolLen := TaskPoolData.TaskPoolLen-1;
    fi;
  od;
  if not IsBound(task) then
    if commSize>3 and age<commSize then
      repeat
        newTarget := Random ([0..commSize-1]);
      until newTarget<>processId and newTarget<>source and newTarget<>orig;
      SendMessage (newTarget, MESSAGE_TYPES.STEAL_MSG, orig, age+1);
    elif commSize=3 then
      if source<>orig then
        SendMessage (orig, MESSAGE_TYPES.STEAL_MSG, orig, age);
      else
        repeat
          newTarget := Random ([0..commSize-1]);
        until newTarget<>processId and newTarget<>source;
      fi;
    else
      SendMessage (source, MESSAGE_TYPES.STEAL_MSG, orig, age);
    fi;
   fi;
end;



StartStealing := function()
  Tasks.doStealing:=true;
  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.START_WORKERS, worker := 0, noWorkers := Tasks.Initial));
end;

StopStealing := function()
  local i;
  Tasks.doStealing:=false;
  Tasks.stealingStopped := true;
  for i in [0..commSize-1] do
    if i<>processId then
      SendMessage (i, MESSAGE_TYPES.STOP_STEALING_MSG);
    fi;
  od;
end;
###########




