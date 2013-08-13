TaskStats := ShareObj ( rec (tasksCreated := 0,
	tasksStolen := 0,
	tasksExecuted := 0,
	tasksOffloaded := 0));


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
########### task sending and receiving functions
#SendTask := function (task, dest)
 # local ind, i, taskdata, handle, handleWrapper, taskArg, p, toBlock, handleComplete;
  # create a taskdata struct that will be sent to the destination node
  #atomic readonly task do
   # taskdata := rec ( func := task.func,
    #                  args := task.args,
     #                 async := task.async);
  #od;
  # check whether there are any incomplete handles in the list of task arguments.
  # if there are, we need to wait for them
  #ind := 1;
  #while true do 
  #  p := LOCK(taskdata.args, false);
   # if ind>Length(taskdata.args) then
    #  break;
    #fi;
    #taskArg := taskdata.args[ind];
    #UNLOCK(p);
    #p := LOCK(taskArg, false);
    #if IsGlobalObjectHandle(taskArg) then
    #  UNLOCK(p);
    #  handleWrapper := MyLookupHashTable(HandlesMap, HANDLE_OBJ(taskArg));
    #  atomic readwrite handleWrapper do
    #    toBlock := false;
    #    if not handleWrapper.complete then
    #      toBlock := true;
    #      if ThreadID(CurrentThread())<>0 then
    #        Add(handleWrapper.blockedOnHandle, MigrateObj (rec ( type := BLOCK_TYPES.BLOCKED_WORKER, 
    #                                                         worker := ThreadID(CurrentThread())), handleWrapper));
    #      fi;
    #    fi;
    #  od;
    #  if toBlock then
    #    if ThreadID(CurrentThread())<>0 then
    #      Tasks.BlockWorkerThread();
    #    else
     #     while true do
      #      for i in [1..100] do od;
       #     atomic readonly handleWrapper do
        #      handleComplete := handleWrapper.complete;
         #   od;
          #  if handleComplete then
            #  break;
           # fi;
          #od;
        #fi;
      #fi;
    #else
     # UNLOCK(p);
    #fi;
    #ind := ind+1;
  #od;
  # create a handle for result and create a wrapper for it
  #handle := GlobalObjHandles.CreateHandle(dest,0,"",false,fail);
  #handleWrapper := ShareObj(rec ( handle := handle, requested := false, complete := false, 
   #                        blockedOnHandle := [], blockedOnObject := [], globalCount := 0, localCount := 1));
  #atomic readonly handleWrapper do
   # MyInsertHashTable (HandlesMap, HANDLE_OBJ(handle), handleWrapper);
  #od;
  #atomic task do
   # task.offloaded := true;
    #task.result := handle;
  #od;
  # send the task to the destination
 # atomic taskdata.args do
  #  for taskArg in taskdata.args do
   #   if RegionOf(taskArg)<>RegionOf(taskdata.args) then
    #    p := LOCK(taskArg, false);
     # fi;
    #od;
    #SendMessage (dest, MESSAGE_TYPES.SCHEDULE_MSG, HANDLE_OBJ(handle), taskdata);
    #UNLOCK(p);
  #od;
  #atomic TaskStats do
   # TaskStats.tasksOffloaded := TaskStats.tasksOffloaded+1;
  #od;
#end;
###########

SendTask := function (task, dest)
  local argument, ind, i, taskdata, handle, handleWrapper, 
        taskArg, p, q, toBlock, handleComplete;
  # create a taskdata struct that will be sent to the destination node
  atomic readonly task do
    taskdata := rec ( func := task.func,
                      args := task.args,
                      async := task.async);
  od;
  # check whether there are any incomplete handles in the list of task arguments.
  # if there are, we need to wait for them
  q := LOCK(taskdata.args);
  for argument in taskdata.args do
    if not IsThreadLocal(argument) then
      p := LOCK(argument);
    fi;
    if IsGlobalObjectHandle(argument) then
      if not argument!.control.complete then
        Add (argument!.control.blockedOnHandle, threadId);
        UNLOCK(p);
        UNLOCK(q);
        Tasks.BlockWorkerThread();
      else
        UNLOCK(p);
      fi;
    fi;
  od;
  UNLOCK(q);
  # create a handle for result and create a wrapper for it
  handle := GlobalObjHandles.CreateHandle(dest,false,ACCESS_TYPES.READ_WRITE,fail,false);
  ShareObj(handle);
  atomic readwrite handle do
    handle!.control.complete := false;
    handle!.localAddr := fail;
  od;
  MyInsertHashTable (HandlesMap, HANDLE_OBJ(handle), handle);
  # set task as offloaded and set its result to be the newly created handle
  atomic task do
    task.offloaded := true;
    task.result := handle;
  od;
  # send the task to the destination
  atomic taskdata.args do
    for taskArg in taskdata.args do
      if RegionOf(taskArg)<>RegionOf(taskdata.args) then
        p := LOCK(taskArg, false);
      fi;
    od;
    SendMessage (dest, MESSAGE_TYPES.SCHEDULE_MSG, HANDLE_OBJ(handle), taskdata);
    UNLOCK(p);
  od;
  atomic TaskStats do
    TaskStats.tasksOffloaded := TaskStats.tasksOffloaded+1;
  od;
  return handle;
end;
                      
ProcessSchedule := function(message)
  local source, remAddr, taskdata, taskDataList, handle, task, taskArg, argHandleWrapper, argHandle, p;
  # format of the message : [ remAddr,taskdata ]
  # where remAddr is the address on the source node of the handle for the task result
  source := message.source;
  remAddr := message.content[1];
  taskdata := message.content[2];
  # create a list of task arguments to be passed to CreateTask function
  taskDataList := [taskdata.func];
  for taskArg in taskdata.args do
    if IsGlobalObjectHandle(taskArg) then
      handle := MyLookupHashTable (GAMap, rec ( pe := taskArg!.pe, localAddr := taskArg!.localAddr ));
      if IsIdenticalObj (handle, fail) then
        ShareObj(taskArg);
        atomic readonly taskArg do
          MyInsertHashTable (GAMap, rec ( pe := taskArg!.pe, localAddr := taskArg!.localAddr), taskArg);
        od;
      else
        taskArg := handle;
      fi;
    fi;
    Add (taskDataList, taskArg);
  od;
  # create a task
  task := ShareObj(Tasks.CreateTask (taskDataList));
  atomic TaskStats do
    TaskStats.tasksCreated := TaskStats.tasksCreated-1;
  od;
  # create a handle for the task result
  handle := CreateTaskResultHandle (task);
  #atomic readwrite task do   # now done inside CreateTaskResultHandle
    #task.result := handle;
  #od;
  # send the handle for the task result to the source pe
  SendMessage (source, MESSAGE_TYPES.ACK_MSG, remAddr, processId, HANDLE_OBJ(handle));
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

               
  

