Revision.tasks_g := "2011-05-12 16:37:00 +0000";

BLOCK_REQ := 1;
RESUME_REQ := 2;
SUSPEND_REQ := 3;

Tasks := AtomicRecord( rec(
                 Initial := 4,                                 # number of worker threads (workers) 
                 ReportErrors := true,   
                 WorkerPool := CreateChannel(),                # pool of idle workers
                 SuspendedWorkerPool := CreateChannel(),       # pool of suspended (idle) workers
                 TaskPool := [],                               # task pool (list)
                 TaskManagerRequests := CreateChannel(),       # task manager requests
                 WorkerSuspensionRequests := CreateChannel(),  # suspend requests from task manager
                 inputChannels := AtomicList([]),              # input channels for workers (used in
                                                               # taskmanager to communicate with workers)
                 TaskPoolLen := FixedAtomicList(1, 0),         # length of a task pool     
                 Running := FixedAtomicList(1, 0)));           # number of workers running tasks

# Task manager is a special thread that manages the workers
# (starts, blocks, suspends and resumes workers).
DeclareGlobalVariable ("TaskManager");
MakeReadWriteGVar("TaskManager");

GetWorkerInputChannel := function (worker)
  return Tasks.inputChannels[ThreadID(worker)];
end;

RunningTasks := function()
  return Tasks.Running[1];
end;

Tasks.TaskPoolLength := function()
  return Tasks.TaskPoolLen[1];
end;

# VJ : These seem necessary, but maybe I am doing something wrong
ShareObj (Tasks.TaskPool);
atomic Tasks.TaskPool do 
  MigrateObj (Tasks.TaskPoolLen, Tasks.TaskPool);
  MigrateObj (Tasks.WorkerPool, Tasks.TaskPool);
  MigrateObj (Tasks.SuspendedWorkerPool, Tasks.TaskPool);
od;

# Called by workers to obtain work
Tasks.GetWork := function(channels)
  local task, taskdata;
  
  # First, try to grab a task from the task pool
  atomic Tasks.TaskPool do
    if Tasks.TaskPoolLength()>0 then 
      task := Tasks.TaskPool[Tasks.TaskPoolLength()];
      Unbind (Tasks.TaskPool[Tasks.TaskPoolLength()]);
      ATOMIC_ADDITION(Tasks.TaskPoolLen, 1, -1);
    fi;
  od;
  if IsBound(task) then # We grabbed something
    task.channel := channels.fromworker;
    task.postChannel := channels.toworker;
    taskdata := task.request;
    
    # VJ: This is probably needed, but I left it out for paranoia
    # Unbind (task.request);
    atomic taskdata do 
      ADOPT(taskdata);
    od;
    taskdata.task := task;
    taskdata.channels := channels;
    ATOMIC_ADDITION (Tasks.Running, 1, 1);
  else
    # Nothing in the task pool
    # Advertise in a worker task pool that we are free,
    # then block waiting for work
    SendChannel (Tasks.WorkerPool, channels);
    taskdata := ReceiveChannel(channels.toworker);
  fi;
  
  return taskdata;
  
end;

      
# Function executed by each worker thread
Tasks.Worker := function(channels)
  local i, taskdata, result, waiting, toUnblock, resume,
        suspend;
  
  while true do

    # First, peek whether there are any suspension requests from the the task manager.
    # If there are, this means that there are more active workers than needed, so some
    # of them need to be suspended. We grab a request, and go to idle (suspend) mode
    suspend := TryReceiveChannel (Tasks.WorkerSuspensionRequests, fail);
    if IsNotIdenticalObj (suspend, fail) then
      # We got the suspension request. Inform the task manager that we are going to suspend
      SendChannel (Tasks.TaskManagerRequests, rec ( thread:= CurrentThread(), resumeChannel := channels.toworker, type := SUSPEND_REQ));
      resume := ReceiveChannel (channels.toworker);
      if resume<>SUSPEND_REQ then 
        Error("Wrong signal received while waiting to be re-activated\n");
      fi;
    fi;
    
    # Previously, here we had
    # taskdata := ReceiveChannel(channels.toworker);
    # Now, we don't necessarily do blocking receive on the input channel any more.
    # Insted, we call GetWork, where we either steal a task from the task queue
    # or (if the task pool is empty) do blocking receive on the input channel
    # and wait for some work to be assigned to us
    taskdata := Tasks.GetWork(channels);
    
    # If we got fail, it means CullIdleTasks was called...terminate
    if IsIdenticalObj(taskdata, fail) then
      SendChannel(channels.fromworker, CurrentThread());
      return;
    fi;
    
    for i in [1..Length(taskdata.adopt)] do
      if taskdata.adopt[i] then
        atomic readwrite taskdata.args[i] do
          ADOPT(taskdata.args[i]);
        od;
      fi;
    od;
    
    if taskdata.async then
      CALL_WITH_CATCH(taskdata.func, taskdata.args);
      # Not needed anymore : SendChannel(Tasks.WorkerPool, channels);
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
      
      # Previously, at this point we would do
      # SendChannel(channels.fromworker,
      #       rec(value := result, channels := channels));
      # Now, we store the task result in taskdata.task.result,
      # and we go back to the beginning of the loop to grab some more work
      atomic readwrite taskdata.task do
        taskdata.task.result := result;
        taskdata.task.complete := true;
        # Check whether some workers are waiting for the result of this task.
        while true do
          toUnblock := TryReceiveChannel (taskdata.task.blockedWorkers, fail);
          if IsIdenticalObj(toUnblock, fail) then
            # No more workers waiting for the result of this task. Proceed.
            break;
          else
            # There is a worker waiting for the result of this task. Inform the task manager that this
            # worker needs to be unblocked.
            SendChannel (Tasks.TaskManagerRequests, rec ( thread := toUnblock, type := RESUME_REQ));
          fi;
        od;
      od;
      
    fi;
    
    ATOMIC_ADDITION(Tasks.Running, 1, -1);
  od;
end;

# Function called when worker blocks on the result of a task.
Tasks.BlockWorkerThread := function()
  local resume;
  # If we are not the main thread, then send a block request to the task manager, and wait for it
  # to inform us that we are unblocked
  if ThreadID(CurrentThread())<>0 then
    SendChannel (Tasks.TaskManagerRequests, rec (thread := CurrentThread(), type := BLOCK_REQ));
  fi;
  resume := ReceiveChannel (GetWorkerInputChannel(CurrentThread()));
  if resume<>RESUME_REQ then
    Error("Error while worker is waiting to resume\n");
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
  Tasks.inputChannels[ThreadID(worker)] := channels.toworker;
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
        addToTaskPool;

  args := arglist{[2..Length(arglist)]};
  adopt := [];
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
  
  # Previously, we had
  # request := rec( channels := channels,
  #                func := arglist[1], args := args, 
  #                adopt := adopt);
  # Now, we don't bind the task to the worker when the task
  # is created, so we cannot assign any channels to the request
  request := rec( func := arglist[1], args := args, 
                  adopt := adopt);
  task :=rec(
             request := request,
             complete := false,
             started := false,
             async := false,
             blockedWorkers := CreateChannel());
  task.request.async := task.async;
  task.request.task := task;
  
  return task;
end;

# Gracefully kill idle tasks.
CullIdleTasks := function()
  local ch, channels;
  channels := MultiReceiveChannel(Tasks.WorkerPool, 1024);
  for ch in channels do
    SendChannel(ch.toworker, fail);
    WaitThread(ReceiveChannel(ch.fromworker));
  od;
end;

# This function now does part of the work that CreateTask did previously.
# It either assigns task to a worker (if there are any free workers), or,
# otherwise, puts the task in the task pool.
ExecuteTask:= function(task)
  local channels, t;
  
  task.started := true;
  
  # Any free worker in the worker pool?
  channels := TryReceiveChannel (Tasks.WorkerPool, fail);

  if IsIdenticalObj (channels, fail) then
    # No free workers. Put the task into the task pool
    atomic Tasks.TaskPool do
      ATOMIC_ADDITION(Tasks.TaskPoolLen, 1, 1);
      MigrateObj (task, Tasks.TaskPool);
      Tasks.TaskPool[Tasks.TaskPoolLength()] := task;
    od;
  else
    # We grabed a free worker. Assign the task to it
    task.request.async := task.async;
    task.request.channels := channels;
    task.channel := channels.fromworker;
    task.postChannel := channels.toworker;
    SendChannel (task.request.channels.toworker, task.request);  
    Unbind(task.request);  
    ATOMIC_ADDITION(Tasks.Running, 1, 1);
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
  local result;
  result := CALL_WITH_CATCH(arg[1], arg{[2..Length(arg)]});
  if Length(result) = 1 or not result[1] then
    if Length(result) > 1 and Tasks.ReportErrors then
      Print("Task Error: ", result[2], "\n");
    fi;
    result := fail;
  else
    result := result[2];
  fi;
  return rec( started := true, complete := true, async := false,
    result := result );
end;

DelayTask := function(arg)
  local task;
  return Tasks.CreateTask(arg);
end;

WaitTask := function(arg)
  local task, taskresult, i;
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;
  for task in arg do
    if task.async then
      Error("Cannot wait for a asynchronous task");
    fi;
  od;
  for task in arg do
    if (not task.complete) and (not task.started) then
      ExecuteTask(task);
    fi;
  od;
  for task in arg do
    if not task.complete then
      # Previously, we would do a blocking receive on the channel of the worker that
      # executed the task:
      #   taskresult := ReceiveChannel(task.channel);
      #   task.result := taskresult.value;
      #   task.complete := true;
      #   SendChannel(Tasks.WorkerPool, taskresult.channels);
      # Not any more. The task might still be in the task pool, so 
      # no channels might be attached to it. We, therefore, cannot
      # retrive its result by receiving from a channel.
      # Instead, we inform the task manager that we are blocking, and wait for it to
      # unblock us (see the code in Tasks.Worker, when a thread finishes computation)
      if ThreadID(CurrentThread())<>0 then 
        SendChannel (task.blockedWorkers, CurrentThread());
        # One more paranoic check to see whether the task completed while we were posting
        # to a blocking pool
        if task.complete then
          # It did, and we got a result. Forget about the previous SendChannel, since the thask is completed,
          # and therefore task.blockedWorkers won't be read from any more.
          break;
        else
          Tasks.BlockWorkerThread();
        fi;
      else
        # The main thread just busy waits for the result (don't really know why, and this
        # case can probably (certainly?) be deleted
        while true do
          if IsBound(task.result) then
            break;
          fi;
          for i in [1..1000] do od;
        od;
      fi;
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
  # <sigh> For now, busy wait until one of the tasks is completed
  # This probably introduces a possible deadlock, and needs to be taken care of
  while true do 
    for i in [1..len] do
      if arg[i].complete then
        return i;
      fi;
    od;
  od;
  # Old code, which may still be reused
  # channels := List(arg, task -> task.channel);
  # taskresult := ReceiveAnyChannel(channels);
  # ch := taskresult.channels.fromworker;
  # SendChannel(Tasks.WorkerPool, taskresult.channels);
  # for i in [1..Length(channels)] do
  #   if ch = channels[i] then
  #     arg[i].result := taskresult.value;
  #     arg[i].complete := true;
  #     return i;
  #   fi;
  # od;
end;

TaskResult := function(task)
  local taskresult;
  if task.async then
    Error("Cannot obtain the result of a asynchronous task");
  fi;
  if (not task.complete) and (not task.started) then
    ExecuteTask(task);
  fi;
  if not task.complete then
    WaitTask(task);
  fi;
  return task.result;
end;

TaskStarted := function(task)
  return task.started;
end;

TaskFinished := function(task)
  return task.complete or Length(InspectChannel(task.channel)) > 0;
end;

TaskIsAsync := function(task)
  return task.async;
end;

# Function executed by a task manager
Tasks.TaskManagerFunc := function()
  local i, worker, activeWorkers, request, requestType,
        suspendedWorkers;
  
  activeWorkers := 0;
  suspendedWorkers := 0;
  
  # At the beginning of computation, fire off Tasks.Initial workers
  for i in [1..Tasks.Initial] do 
    worker := Tasks.StartNewWorkerThread();
    activeWorkers := activeWorkers+1;
  od;
  
  while true do
    request := ReceiveChannel (Tasks.TaskManagerRequests);
    worker := request.thread;
    requestType := request.type;
    
    if requestType = BLOCK_REQ then # request to block a worker
      activeWorkers := activeWorkers-1;
      if activeWorkers<Tasks.Initial then 
        # We don't have enough active workers. Need to resume or start some of them
        if suspendedWorkers>0 then
          # We have suspended (idle) workers. Resume one of them
          worker := ReceiveChannel(Tasks.SuspendedWorkerPool);
          suspendedWorkers := suspendedWorkers-1;
          SendChannel (GetWorkerInputChannel(worker), SUSPEND_REQ); # This will resume the worker
        else
          # No suspended workers. Start another worker.
          worker := Tasks.StartNewWorkerThread();
        fi;
        activeWorkers := activeWorkers+1;
      fi;
    elif requestType = RESUME_REQ then # request to unblock a worker
      activeWorkers := activeWorkers+1;
      if activeWorkers>Tasks.Initial then
        # We have too many active workers. Put a suspension request to the
        # worker suspension pool. Whichever worker reads from this pool will
        # suspend itself
        SendChannel (Tasks.WorkerSuspensionRequests, SUSPEND_REQ);
        activeWorkers := activeWorkers-1;
      fi;
      SendChannel (GetWorkerInputChannel(worker), RESUME_REQ); # This will unblock a worker
    elif requestType = SUSPEND_REQ then # worker informs us that it is suspended
      suspendedWorkers := suspendedWorkers+1;
      if suspendedWorkers>Tasks.Initial then
        # We already have too many suspended workers. Just kill this one.
        KillThread(worker);
      else
        # Add the worker to the suspended workers pool
        SendChannel (Tasks.SuspendedWorkerPool, worker);
      fi;
    fi;
  od;
end;
    
Tasks.Initialize();
