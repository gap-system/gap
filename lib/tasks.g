Revision.tasks_g := "2011-05-12 16:37:00 +0000";

BLOCK_ME := 1;
RESUME_IDLE_WORKER := 2;
RESUME_BLOCKED_WORKER := 3;
RESUME_SUSPENDED_WORKER := 4;
SUSPEND_ME := 5;
FINISH := 6;
CULL_IDLE_WORKERS := 7;
FINISH_WORKER := 8;

Tasks := AtomicRecord( rec ( Initial := 4 ,    # initial number of worker threads
                 ReportErrors := true,
                 WorkerPool := CreateChannel(),                # pool of idle workers                 
                 TaskManagerRequests := CreateChannel(),       # task manager requests
                 WorkerSuspensionRequests := CreateChannel()));  # suspend requests from task manager

TaskData := ShareObj( rec(
                    TaskPool := [],                               # task pool (list)
                    inputChannels := [],              
                    TaskPoolLen := 0,         # length of a task pool     
                    Running := 0));

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
                                                               type := SUSPEND_ME));
        unSuspend := ReceiveChannel (channels.toworker);
        if unSuspend=FINISH then
          SendChannel (Tasks.TaskManagerRequests, rec ( worker := CurrentThread(),
                                                                  type := FINISH_WORKER));
          return;
        fi;
      fi;
      
      p := LOCK(TaskData, true);
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
        resume := ReceiveChannel (channels.toworker);
        if resume=FINISH then
          SendChannel (channels.fromworker, CurrentThread());
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
                       args := ADOPT(task.args),
                       async := ADOPT(task.async));                       
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
        while true do
          toUnblock := TryReceiveChannel (task.blockedWorkers, fail);
          if IsIdenticalObj (toUnblock, fail) then
            break;
          else
            SendChannel (Tasks.TaskManagerRequests, rec ( type := RESUME_BLOCKED_WORKER, 
                                                                  worker := toUnblock));
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
    SendChannel (Tasks.TaskManagerRequests, rec (worker := ThreadID(CurrentThread()), type := BLOCK_ME));
    resume := ReceiveChannel (GetWorkerInputChannel(ThreadID(CurrentThread())));
    if resume<>RESUME_BLOCKED_WORKER then
      Error("Error while worker is waiting to resume\n");
    fi;
  else
    Error("Cannot block main thread\n");
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
  TaskManager := CreateThread(Tasks.TaskManagerFunc);
  MakeReadOnlyGVar ("TaskManager");
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
        p := LOCK(args[i],true);
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
                   blockedWorkers := CreateChannel(),
                   ));
  
  return task;
end;

# Gracefully kill idle tasks.
CullIdleTasks := function()
  local ch, channels;
  channels := MultiReceiveChannel(Tasks.WorkerPool, 1024);
  for ch in channels do
    SendChannel(ch.toworker, FINISH);
    WaitThread(ReceiveChannel(ch.fromworker));
  od;

  SendChannel (Tasks.TaskManagerRequests, rec ( type := CULL_IDLE_WORKERS, 
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
    SendChannel (worker.toworker, RESUME_IDLE_WORKER);
  fi;

  return task;
end;

RunTask := function(arg)
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
                  result := result ));
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
      if (not task.complete) and (not task.started) then
        ExecuteTask(task);
      fi;
    od;
  od;
  for task in arg do
    p := LOCK(task,false);
    if IsIdenticalObj (p, fail) then
      Error("Could not obtain lock in WaitTask\n");
    fi;
    
    if not task.complete then
      if ThreadID(CurrentThread())<>0 then
        SendChannel (task.blockedWorkers, ThreadID(CurrentThread()));
        UNLOCK(p);
        Tasks.BlockWorkerThread();
      else
        while true do 
          UNLOCK(p);
          for i in [1..1000] do od;
          LOCK(task,false);
          if task.complete then 
            break;
          fi;
        od;
      fi;
    else
      UNLOCK(p);
    fi;
  od;

end;

WaitTasks := WaitTask;

WaitAnyTask := function(arg)
  local i, len, task, taskresult, channels, ch;
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;
  len := Length(arg);
  for task in arg do
    if task.async then
      Error("Cannot wait for a async task");
    fi;
  od;
  for task in arg do
    if not task.started then
      ExecuteTask(task);
    fi;
  od;

  while true do 
    for i in [1..len] do
      if arg[i].complete then
        return i;
      fi;
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
    
    if not task.started then
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
    taskresult :=  CLONE_REACHABLE(task.result);
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

# Function executed by a task manager
Tasks.TaskManagerFunc := function()
  local i, worker, activeWorkers, request, requestType,
        suspendedWorkers, taskToFinish, toUnblock,
        totalTasks, blockedWorkersChannel, taskMap, blockedWorkers,
        suspendedWorkersList, toResume;
  
  activeWorkers := 0;
  blockedWorkers := 0;
  suspendedWorkers := 0;
  suspendedWorkersList := [];
  
  for i in [1..Tasks.Initial] do 
    worker := Tasks.StartNewWorkerThread();
    activeWorkers := activeWorkers+1;
  od;
  
  while true do
    request := ReceiveChannel (Tasks.TaskManagerRequests);
    worker := request.worker;
    requestType := request.type;
    
    if requestType = BLOCK_ME then # request to block a worker
      activeWorkers := activeWorkers-1;
      blockedWorkers := blockedWorkers+1;
      if activeWorkers<Tasks.Initial then
        if suspendedWorkers>0 then
          toResume := Remove (suspendedWorkersList);
          suspendedWorkers := suspendedWorkers-1;
          SendChannel (GetWorkerInputChannel(toResume), RESUME_SUSPENDED_WORKER);
        else
          Tasks.StartNewWorkerThread();
        fi;
        activeWorkers := activeWorkers+1;
      fi;
    elif requestType = RESUME_BLOCKED_WORKER then # request to unblock a worker
      activeWorkers := activeWorkers+1;
      blockedWorkers := blockedWorkers-1;
      if activeWorkers>Tasks.Initial then
        SendChannel (Tasks.WorkerSuspensionRequests, true);
      fi;
      SendChannel (GetWorkerInputChannel(worker), RESUME_BLOCKED_WORKER);
    elif requestType = SUSPEND_ME then
      activeWorkers := activeWorkers-1;
      if suspendedWorkers>Tasks.Initial then
        KillThread(worker);
      else
        suspendedWorkers := suspendedWorkers+1;
        Add (suspendedWorkersList, worker);
      fi;
    elif requestType = CULL_IDLE_WORKERS then
      while not IsEmpty(suspendedWorkersList) do
        worker := Remove(suspendedWorkersList);
        suspendedWorkers := suspendedWorkers-1;
        SendChannel (GetWorkerInputChannel(worker), FINISH);
      od;
    elif requestType = FINISH_WORKER then
      Print ("FINISH_WORKER");
      WaitThread(worker);
    fi;
  od;
end;
    
Tasks.Initialize();
