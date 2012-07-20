Revision.tasks_g := "2011-05-12 16:37:00 +0000";

BLOCK_TYPES := AtomicRecord ( rec ( 
                     BLOCKED_WORKER := 1,
                     BLOCKED_FETCH := 2) );

TASK_MANAGER_REQUESTS := AtomicRecord ( rec (
                              BLOCK_ME := 1,
                              RESUME_IDLE_WORKER := 2,
                              RESUME_BLOCKED_WORKER := 3,
                              RESUME_SUSPENDED_WORKER := 4,
                              SUSPEND_ME := 5,
                              FINISH := 6,
                              CULL_IDLE_WORKERS := 7,
                              FINISH_WORKER := 8,
                              STEAL := 9,
                              NO_WORK := 10,
                              UNSUCC_STEAL := 11,
                              GOT_TASK := 12) );

FetchTaskResult := function()
end;

ProcessBlockedFetch := function()
end;

SendSteal := function()
end;

FinishProcesses := function()
end;

SetImportedTaskResult := function()
end;

Tasks := AtomicRecord( rec ( Initial := 1 ,    # initial number of worker threads
                 ReportErrors := true,
                 WorkerPool := CreateChannel(),                # pool of idle workers                 
                 TaskManagerRequests := CreateChannel(),       # task manager requests
                 WorkerSuspensionRequests := CreateChannel(),  # suspend requests from task manager
                 doStealing := false));                        # do work stealing



TaskData := ShareObj( rec(
                    TaskPool := [],                               # task pool (list)
                    inputChannels := [],              
                    TaskPoolLen := 0,         # length of a task pool     
                    Running := 0));

TaskStats := ShareObj ( rec ( tasksCreated := 0,
                     tasksStolen := 0,
                     tasksExecuted := 0,
                     tasksOffloaded := 0 ) );


# Task manager is a special thread that manages the workers
# (starts, blocks, suspends and resumes workers).
DeclareGlobalVariable ("TaskManager");
MakeReadWriteGVar("TaskManager");

GetWorkerInputChannel := function (worker)
  atomic readonly TaskData do
    return TaskData.inputChannels[worker];
  od;
end;

RunningTasks := function()
  atomic readonly TaskData do
    return TaskData.Running;
  od;
end;

Tasks.TaskPoolLength := function()
  atomic readonly TaskData do
    return TaskData.TaskPoolLen;
  od;
end;

# Function executed by each worker thread
Tasks.Worker := function(channels)
  local taskdata, result, toUnblock, resume,
        suspend, unSuspend, p, task, i;
  
  while true do
    Unbind (task);
    while not IsBound(task) do
      suspend := TryReceiveChannel (Tasks.WorkerSuspensionRequests, fail);
      if not IsIdenticalObj (suspend, fail) then
        SendChannel (Tasks.TaskManagerRequests, rec ( worker:= ThreadID(CurrentThread()),
                                                               type := TASK_MANAGER_REQUESTS.SUSPEND_ME));
        unSuspend := ReceiveChannel (channels.toworker);
        if unSuspend=TASK_MANAGER_REQUESTS.FINISH then
          SendChannel (Tasks.TaskManagerRequests, rec ( worker := CurrentThread(),
                                                                  type := TASK_MANAGER_REQUESTS.FINISH_WORKER));
          return;
        fi;
      fi;
      resume := TryReceiveChannel (channels.toworker, fail);
      if not IsIdenticalObj (resume, fail) then
        SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH_WORKER, worker := CurrentThread()));
        return;
      fi;
      
      p := LOCK(TaskData);
      if IsIdenticalObj (p,fail) then
         Error("Failed to obtain lock for TaskData inside Worker function\n");
      fi;
      if TaskData.TaskPoolLen>0 then
        task := TaskData.TaskPool[TaskData.TaskPoolLen];
        Unbind (TaskData.TaskPool[TaskData.TaskPoolLen]);
        TaskData.TaskPoolLen := TaskData.TaskPoolLen-1;
        TaskData.Running := TaskData.Running+1;
        UNLOCK(p);
      else
        UNLOCK(p);
        SendChannel (Tasks.WorkerPool, channels);
        if Tasks.doStealing then
          SendChannel (Tasks.TaskManagerRequests, rec ( worker := ThreadID(CurrentThread()),
                                                                  type := TASK_MANAGER_REQUESTS.NO_WORK));
        fi;
        resume := ReceiveChannel (channels.toworker);
        if resume=TASK_MANAGER_REQUESTS.FINISH then
          SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH_WORKER, worker := CurrentThread()));
          return;
        fi;
      fi;
    od;
    
    atomic task do 
      task.started := true;
      for i in [1..Length(task.adopt)] do
        if task.adopt[i] then
          atomic readwrite task.args[i] do
            ADOPT(task.args[i]);
          od;
        fi;
      od;
      taskdata := rec (func := ADOPT(task.func), 
                       args := CLONE_REACHABLE(task.args),
                       async := ADOPT(task.async));                       
    od;
    
    atomic TaskStats do
      TaskStats.tasksExecuted := TaskStats.tasksExecuted+1;
    od;
    
    if taskdata.async then
      CALL_WITH_CATCH(taskdata.func, taskdata.args);
    else
      
      result := CALL_WITH_CATCH(taskdata.func, taskdata.args);
      if Length(result) = 1 or not result[1] then
        if Length(result) > 1 and Tasks.ReportErrors then
          Print("Task Error: ", result[2], "\n");
        fi;
        result := fail;
      else
        result := result[2];
      fi;
      
      atomic task do
        task.complete := true;
        task.result := MigrateObj (result, task);
        SetImportedTaskResult(task,result);
        while true do
          toUnblock := TryReceiveChannel (task.blockedWorkers, fail);
          if IsIdenticalObj (toUnblock, fail) then
            break;
          else
            if toUnblock.type = BLOCK_TYPES.BLOCKED_WORKER then
              SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER, 
                                                                    worker := toUnblock.worker));
            else
              ProcessBlockedFetch (task, toUnblock);
            fi;
          fi;
        od;
      od;
    fi;
    
    atomic TaskData do
      TaskData.Running := TaskData.Running-1;
    od;
    
  od;
end;

# Function called when worker blocks on the result of a task.
Tasks.BlockWorkerThread := function()
  local resume;

  if ThreadID(CurrentThread())<>0 then
    SendChannel (Tasks.TaskManagerRequests, rec (worker := ThreadID(CurrentThread()), type := TASK_MANAGER_REQUESTS.BLOCK_ME));
    resume := ReceiveChannel (GetWorkerInputChannel(ThreadID(CurrentThread())));
    if resume<>TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER then
      Error("Error while worker is waiting to resume\n");
    fi;
  else
    Error("Cannot block main thread\n");
    # ToDo : Not really...if we are not the main PE, that it is perfectly ok to block
    # the main thread
  fi;
end;

# Starts a new worker (called by task manager).
Tasks.StartNewWorkerThread := function()
  local toworker, fromworker, channels, worker;
  toworker := CreateChannel(1);
  fromworker := CreateChannel(1);
  channels := rec(toworker := toworker, fromworker := fromworker);
  MakeReadOnly(channels);
  worker := CreateThread(Tasks.Worker, channels);
  atomic TaskData do 
    TaskData.inputChannels[ThreadID(worker)] := channels.toworker;
  od;
  return worker;
end;

# Tasks.Initialize just fires off the task manager.
Tasks.Initialize := function()
  local i;
  #TaskManager := CreateThread(Tasks.TaskManagerFunc);
  TaskManager := fail;
  #MakeReadOnlyGVar ("TaskManager");
end;

# Creates a task without binding it to a worker
Tasks.CreateTask := function(arglist)
  local i, channels, task, request, args, adopt, adopted, ds,p,
        addToTaskPool, q;

  args := arglist{[2..Length(arglist)]};
  adopt := AtomicList([]);
  adopted := false;
  for i in [1..Length(args)] do
    if IsThreadLocal(args[i]) then
      adopt[i] := true;
      if not adopted then
        args[i] := SHARE(CLONE_REACHABLE(args[i]));
        ds := RegionOf(args[i]);
        p := LOCK(args[i]);
        adopted := true;
      else
        args[i] := MIGRATE(CLONE_REACHABLE(args[i]), ds);
      fi;
    else
      adopt[i] := false;
    fi;
  od;
  if adopted then
    UNLOCK(p);
  fi;
  
  task :=  ShareObj (rec (
                   func := arglist[1],
                   args := args,
                   adopt := adopt,
                   async := false,
                   complete := false,
                   started := false,
                   async := false,
                   offloaded := false,
                   blockedWorkers := CreateChannel(),
                   ));
  
  atomic TaskStats do
    TaskStats.tasksCreated := TaskStats.tasksCreated+1;
  od;
  
  return task;
end;

# Gracefully kill idle tasks.
CullIdleTasks := function()
  local ch, channels;
  channels := MultiReceiveChannel(Tasks.WorkerPool, 1024);
  for ch in channels do
    SendChannel(ch.toworker, TASK_MANAGER_REQUESTS.FINISH);
    WaitThread(ReceiveChannel(ch.fromworker));
  od;

  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.CULL_IDLE_WORKERS, 
                                                        worker := ThreadID(CurrentThread())));
end;

ExecuteTask:= atomic function(readwrite task)
  local channels, t, taskdata, worker;
  
  task.started := true;
  task.completed := false;

  atomic TaskData do
    TaskData.TaskPoolLen := TaskData.TaskPoolLen+1;
    TaskData.TaskPool[Tasks.TaskPoolLength()] := task;
  od;
  
  worker := TryReceiveChannel (Tasks.WorkerPool, fail);
  if IsNotIdenticalObj (worker, fail) then
    SendChannel (worker.toworker, TASK_MANAGER_REQUESTS.RESUME_IDLE_WORKER);
  fi;

  return task;
end;

RunTask:= function(arg)
  local task;
  task := Tasks.CreateTask(arg);
  ExecuteTask(task);
  return task;
end;

RunAsyncTask := function(arg)
  local task;
  task := Tasks.CreateTask(arg);
  task.async := true;
  ExecuteTask(task);
  return task;
end;

MakeTaskAsync := function(task)
  if task.started then
    Error("Cannot make a running task asynchronous");
  fi;
  task.async := true;
end;

ImmediateTask := function(arg)
  local result, task;
  result := CALL_WITH_CATCH(arg[1], arg{[2..Length(arg)]});
  if Length(result) = 1 or not result[1] then
    if Length(result) > 1 and Tasks.ReportErrors then
      Print("Task Error: ", result[2], "\n");
    fi;
    result := fail;
  else
    result := result[2];
  fi;
  task := ShareObj (rec( started := true, complete := true, async := false,
                  result := result, adopt_result := false ));
  return task;
end;

DelayTask := function(arg)
  local task;
  return Tasks.CreateTask(arg);
end;

WaitTask := function(arg)
  local task, taskresult, i, p;
  
  atomic readonly arg[1] do
    if Length(arg) = 1 and IsList(arg[1]) then
      arg := arg[1];
    fi;
  od;
  
  for task in arg do
    atomic readonly task do 
      if task.async then
        Error("Cannot wait for a asynchronous task");
      fi;
    od;
  od;
  for task in arg do
    atomic readonly task do
      if (not task.complete) and (not task.started) and (not task.offloaded) then
        ExecuteTask(task);
      fi;
    od;
  od;
  for task in arg do
    p := LOCK(false, task);
    if IsIdenticalObj (p, fail) then
      Error("Could not obtain lock in WaitTask\n");
    fi;
    
    if not task.complete then
      if task.offloaded then
        UNLOCK(p);
        FetchTaskResult(task); # blocking will happen inside of this function
        return;
      fi;
      if ThreadID(CurrentThread())<>0 then
        SendChannel (task.blockedWorkers, rec (type := BLOCK_TYPES.BLOCKED_WORKER, worker := ThreadID(CurrentThread())));
        UNLOCK(p);
        Tasks.BlockWorkerThread();
      else
        #Print ("Waiting for ", HANDLE_OBJ(task), "\n");
        while true do 
          UNLOCK(p);
          for i in [1..1000] do od;
          LOCK(false, task);
          if task.complete then 
            #Print ("Restarting\n");
            break;
          fi;
        od;
        UNLOCK(p);
      fi;
    else
      UNLOCK(p);
    fi;
  od;

end;

WaitTasks := WaitTask;

WaitAnyTask := function(arg)
  local i, len, task, taskresult, channels, ch;
  
  atomic arg[1] do
    if Length(arg) = 1 and IsList(arg[1]) then
      arg := arg[1];
    fi;
  od;
  
  len := Length(arg);
  
  for task in arg do
    LOCK (task, false);
    if task.async then
      UNLOCK(task);
      Error("Cannot wait for a async task");
    fi;
    if not task.started then
      UNLOCK(task);
      ExecuteTask(task);
    fi;
  od;
  
  while true do 
    for i in [1..len] do
      atomic readonly arg[i] do 
        if arg[i].complete then
          return i;
        fi;
      od;
    od;
  od;
  
end;

TaskResult := function(task)
  local taskresult, toExecute, toWait;
  
  toExecute := false;
  toWait := false;

  
  atomic readonly task do
    if task.async then
      Error("Cannot obtain the result of a asynchronous task");
    fi;
    
    if (not task.started) and (not IsBound(task.offloaded)) then
      toExecute := true;
    elif not task.complete then
      toWait := true;
    fi;
  od;
  
  if toExecute then 
    ExecuteTask(task);
  elif toWait then
    WaitTask(task);
  fi;
  
  atomic readonly task do
    if RegionOf(task.result)<>RegionOf(task) then
      atomic readonly task.result do
        taskresult :=  CLONE_REACHABLE(task.result);
      od;
    else
      taskresult :=  CLONE_REACHABLE(task.result);
    fi;
  od;
  
  return taskresult;
  
end;

TaskStarted := atomic function(readonly task)
  return task.started;
end;

TaskFinished := atomic function(readonly task)
  return task.complete;
end;

TaskIsAsync := function(task)
  return task.async;
end;

MicroSeconds := function()
  local t;
  t := CurrentTime();
  return t.tv_sec * 1000000 + t.tv_usec;
end;

PrintTaskManStats := function()
  if IsBoundGlobal("MPI_Initialized") then
    if MPI_Comm_size()>1 then
      Print ("--- Task Manager ", MPI_Comm_rank(), " ---\n");
    fi;
  else
    Print("--- Task Manager ---\n");
  fi;
  atomic readonly TaskStats do
    Print ("**Tasks created : ", TaskStats.tasksCreated, "\n");
    Print ("**Tasks executed : ", TaskStats.tasksExecuted, "\n");
    Print ("**Tasks offloaded : ", TaskStats.tasksOffloaded, "\n");
    Print ("**Tasks imported : ", TaskStats.tasksStolen, "\n");
  od;
end;

# Function executed by a task manager
Tasks.TaskManagerFunc := function()
  local i, worker,  request, requestType,
        taskToFinish, toUnblock,
        totalTasks, blockedWorkersChannel, taskMap,
        toResume, taskman, target, finishing, finishingState;
  
  finishing := false;
  taskman := rec (activeWorkers:= 0,
                  blockedWorkers:=0,
                  suspendedWorkers:=0,
                  suspendedWorkersList:=[],
                  allWorkers:=[],
                  stealing:=false,
                  stealRequests:=0,
                  nextStealingTime:=MicroSeconds());
  
  for i in [1..Tasks.Initial] do 
    worker := Tasks.StartNewWorkerThread();
    Add (taskman.allWorkers, ThreadID(worker));
    taskman.activeWorkers := taskman.activeWorkers+1;
  od;
  
  while true do
    
    if finishing and finishingState.myWorkersToFinish=0 then
      PrintTaskManStats();
      return;
    fi;
    
    if (not Tasks.doStealing) or (not IsBoundGlobal("MPI_Initialized")) or MPI_Comm_size()<2 then
      request := ReceiveChannel (Tasks.TaskManagerRequests);
    else
      if taskman.stealRequests>0 and not taskman.stealing and not finishing then
        if taskman.nextStealingTime>MicroSeconds() then
          request := TryReceiveChannel (Tasks.TaskManagerRequests, fail);
          if IsIdenticalObj (request, fail) then
            continue;
          fi;
        else
          SendSteal();
          taskman.stealing := true;
          continue;
        fi;
      else
        request := ReceiveChannel (Tasks.TaskManagerRequests);
      fi;
    fi;
    
    worker := request.worker;
    requestType := request.type;
    
    if requestType = TASK_MANAGER_REQUESTS.BLOCK_ME then # request to block a worker
      taskman.activeWorkers := taskman.activeWorkers-1;
      taskman.blockedWorkers := taskman.blockedWorkers+1;
      if taskman.activeWorkers<Tasks.Initial then
        if taskman.suspendedWorkers>0 then
          toResume := Remove (taskman.suspendedWorkersList);
          taskman.suspendedWorkers := taskman.suspendedWorkers-1;
          SendChannel (GetWorkerInputChannel(toResume), TASK_MANAGER_REQUESTS.RESUME_SUSPENDED_WORKER);
        else
          worker := Tasks.StartNewWorkerThread();
          Add (taskman.allWorkers, ThreadID(worker));
        fi;
        taskman.activeWorkers := taskman.activeWorkers+1;
      fi;
    elif requestType = TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER then # request to unblock a worker (or a fetch)
      taskman.activeWorkers := taskman.activeWorkers+1;
      taskman.blockedWorkers := taskman.blockedWorkers-1;
      if taskman.activeWorkers>Tasks.Initial then
        SendChannel (Tasks.WorkerSuspensionRequests, true);
      fi;
      SendChannel (GetWorkerInputChannel(worker), TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER);
    elif requestType = TASK_MANAGER_REQUESTS.SUSPEND_ME then
      taskman.activeWorkers := taskman.activeWorkers-1;
      if taskman.suspendedWorkers>Tasks.Initial then
        SendChannel(GetWorkerInputChannel(worker), TASK_MANAGER_REQUESTS.FINISH);
        Remove (taskman.allWorkers, worker);
      else
        taskman.suspendedWorkers := taskman.suspendedWorkers+1;
        Add (taskman.suspendedWorkersList, worker);
      fi;
    elif requestType = TASK_MANAGER_REQUESTS.CULL_IDLE_WORKERS then
      while not IsEmpty(taskman.suspendedWorkersList) do
        worker := Remove(taskman.suspendedWorkersList);
        taskman.suspendedWorkers := taskman.suspendedWorkers-1;
        SendChannel (GetWorkerInputChannel(worker), TASK_MANAGER_REQUESTS.FINISH);
      od;
    elif requestType = TASK_MANAGER_REQUESTS.NO_WORK then
      if IsBoundGlobal("MPI_Initialized") then
        taskman.stealRequests := taskman.stealRequests+1;
      fi;
    elif requestType = TASK_MANAGER_REQUESTS.UNSUCC_STEAL then
      taskman.nextStealingTime := MicroSeconds() + 1000;
      taskman.stealing := false;
    elif requestType = TASK_MANAGER_REQUESTS.GOT_TASK then
      if Tasks.doStealing then
        taskman.stealRequests := taskman.stealRequests-1;
        taskman.stealing := false;
      fi;
    elif requestType = TASK_MANAGER_REQUESTS.FINISH_WORKER then
      WaitThread(worker);
      if finishing then
        finishingState.myWorkersToFinish := finishingState.myWorkersToFinish-1;
      fi;
    elif requestType = TASK_MANAGER_REQUESTS.FINISH then
      finishingState := rec ( myWorkersToFinish := taskman.activeWorkers + taskman.suspendedWorkers );
      if IsBound(MPI_Initialized) and IsBound(MPI_Comm_rank) then
        if MPI_Comm_rank()=0 then
          FinishProcesses ();
        fi;
      fi;
      for i in taskman.allWorkers do
        SendChannel (GetWorkerInputChannel(i), TASK_MANAGER_REQUESTS.FINISH);  
      od;  
      finishing := true;
    fi;
  od;
end;

Tasks.Initialize();
