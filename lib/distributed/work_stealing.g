DistTaskData := ShareObj ( rec ( outstandingMessages := 0,
                        finishing := false ));

ImportedTasks := ShareObj ([ [], [] ]);

#IsGlobalObjectHandle := function(foobar)
#  return false;
#end;

########### some lower level functionality
UnblockWorker := function(worker)
  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER, 
                                                        worker := worker));
end;

UnblockFetch := function (obj, source, remAddr)
  SendMessage (source, MESSAGE_TYPES.REPLY_OBJ, remAddr, obj);
end;
############


## We may need a function like this, but could name it differently
SendTask := function (task, dest)
  local ind, i, taskdata, handle, handleWrapper, taskArg, p, toBlock, handleComplete;
  # create a taskdata struct that will be sent to the destination node
  atomic readonly task do
    taskdata := rec ( func := task.func,
                      args := task.args,
                      async := task.async);
  od;
  # create a handle for result and create a wrapper for it
  handle := GlobalObjHandles.CreateHandle(dest,dest,false,ACCESS_TYPES.READ_WRITE);
  handle!.localId := HANDLE_OBJ(handle);
  MyInsertHashTable (GAMap, MakeReadOnly(rec ( pe := handle!.pe, localId := handle!.localId)), handle);
  atomic task do
    task.offloaded := true;
    task.result := handle;
    task.adopt_result := false;
  od;
  # send the task to the destination
  atomic taskdata.args do
    for taskArg in taskdata.args do
      if RegionOf(taskArg)<>RegionOf(taskdata.args) then
        p := LOCK(taskArg, false);
      fi;
    od;
    SendMessage (dest, MESSAGE_TYPES.SCHEDULE_MSG, handle, taskdata);
    UNLOCK(p);
  od;
  ShareObj(handle);
  atomic TaskStats do
    TaskStats.tasksOffloaded := TaskStats.tasksOffloaded+1;
  od;
end;
###########

ProcessScheduleMsg := function(message)
  local source, taskdata, taskDataList, handle, task, taskArg, argHandleWrapper, argHandle, p;
  source := message.source;
  handle := message.content[1];
  ShareObj(handle);
  taskdata := message.content[2];
  # create a list of task arguments to be passed to CreateTask function
  taskDataList := [taskdata.func];
  for taskArg in taskdata.args do
    if IsGlobalObjectHandle(taskArg) then
      ShareObj(taskArg);
    fi;
    Add (taskDataList, taskArg);
  od;
  # create a task
  task := ShareObj(CreateTask (taskDataList));
  atomic TaskStats do
    TaskStats.tasksCreated := TaskStats.tasksCreated-1;
  od;
  # set a handle for the task result
  atomic readwrite task do
    task.result := handle;
  od;
  # notify the task manager that we got task
  # SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.GOT_TASK, worker := 0));
  # finally, execute task
  ExecuteTask(task);
  atomic TaskStats do
    TaskStats.tasksStolen := TaskStats.tasksStolen+1;
  od;
end;

FetchTaskResult := function(task)
  local handle, res;
  #  Print ("Fetching task result\n");
  atomic readonly task do
    handle := task.result;
  od;
  #FetchObj(handle);
  #atomic readonly handle, readwrite task do
  #  res := task.result!.obj;
  #  task.result := res;
  #  task.complete := true;
  #od;
  #Print ("Ended fetching\n");
end;



SetImportedTaskResult := function (task, result)
  #local handleAddr, handle, handleWrapper, blockedRequest;
  #handleAddr := MyLookupHashTable(ImportedTasks, HANDLE_OBJ(task));
  #if IsIdenticalObj(handleAddr,fail) then
    #return;
  #else
   # handle := OBJ_HANDLE(handleAddr);
    #atomic handle do
     # if not IsGlobalObjectHandle(handle) then
      #  Error ("Something's wrong!\n");
      #fi;
      #handle!.obj := result;
    #od;
    #handleWrapper := MyLookupHashTable (HandlesMap, handleAddr);
    #atomic readonly handleWrapper do
     # for blockedRequest in handleWrapper.blockedOnObject do
      #  UnblockFetch(result, blockedRequest.source, blockedRequest.localAddr);
      #od;
    #od;
  #fi;
end;
###########

########### load balancing functions
SendSteal :=  function()
  #local target,myId, size;
  
 # atomic readonly DistTaskData do
 #   if DistTaskData.finishing then
 #     return;
 #   fi;
 # od;
 # 
 # myId := MPI_Comm_rank();
 # size := MPI_Comm_size();
 # repeat
 #   target := Random([0..size-1]);
 # until target<>myId;
 # SendMessage (target, MESSAGE_TYPES.STEAL_MSG, myId, 1);
end;

ProcessSteal := function (msg, source)
  #local age, newTarget, myId, orig, task;
  
 # atomic readonly DistTaskData do
  #  if DistTaskData.finishing then
 #     return;
 #   fi;
 # od;
  
 # orig := msg.content[1];
 # age := msg.content[2];
 # myId := MPI_Comm_rank();

 # if orig=myId then
 #   SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.UNSUCC_STEAL, worker := 0 ));
 #   return;  
 # fi;
  
 # atomic TaskPoolData do
 #   if TaskPoolData.TaskPoolLen>1 then
 #     task := TaskPoolData.TaskPool[TaskPoolData.TaskPoolLen];
 #     TaskPoolData.TaskPoolLen := TaskPoolData.TaskPoolLen-1;
 #   fi;
 # od;
  
 # if IsBound(task) then
 #   SendTask(task,source);
 # else
 #   if MPI_Comm_size()>3 and age<MPI_Comm_size() then
  #    repeat
  #      newTarget := Random ([0..MPI_Comm_size()-1]);
  #    until newTarget<>myId and newTarget<>source and newTarget<>orig;
  #    SendMessage (newTarget, MESSAGE_TYPES.STEAL_MSG, orig, age+1);
  #  elif MPI_Comm_size()=3 then
  #    if source<>orig then
  #      SendMessage (orig, MESSAGE_TYPES.STEAL_MSG, orig, age);
  #    else
  #      repeat
  #        newTarget := Random ([0..MPI_Comm_size()-1]);
  #      until newTarget<>myId and newTarget<>source;
  #    fi;
  #  else
  #    SendMessage (source, MESSAGE_TYPES.STEAL_MSG, orig, age);
  #  fi;
  #fi;
end;



StartStealing := function()
#  ParEval("Tasks.doStealing:=true");
end;

StopStealing := function()
#  ParEval("Tasks.doStealing:=false");
end;
###########

               
  

