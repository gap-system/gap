#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

BindGlobal ("TASK_MANAGER_REQUESTS", MakeReadOnlyObj (rec (
        BLOCK_ME := 1,
        RESUME_IDLE_WORKER := 2,
        RESUME_BLOCKED_WORKER := 3,
        RESUME_SUSPENDED_WORKER := 4,
        SUSPEND_ME := 5,
        FINISH := 6,
        CULL_IDLE_WORKERS := 7,
        FINISH_WORKER := 8,
        START_WORKERS := 9)));

Tasks := AtomicRecord( rec ( #Initial := GAPInfo.KernelInfo.NUM_CPUS ,    # initial number of worker threads
                 Initial := 1,
                 ReportErrors := true,
                 FirstTask := true,
                 WorkerPool := CreateChannel(),                # pool of idle workers
                 TaskManagerRequests := CreateChannel(),       # task manager requests
                 WorkerSuspensionRequests := CreateChannel(),
                 InputChannels := AtomicList([])));  # suspend requests from task manager

TaskData := ShareSpecialObj( rec(
                    TaskPool := [],                               # task pool (list)
                    TaskPoolLen := 0,         # length of a task pool
                    Running := 0));

# Task manager is a special thread that manages the workers
# (starts, blocks, suspends and resumes workers).
DeclareGlobalVariable ("TaskManager");
MakeReadWriteGVar("TaskManager");
DeclareGlobalVariable ("mainThreadChannels");
MakeReadWriteGVar("mainThreadChannels");
MakeThreadLocal("threadId");

GetWorkerInputChannel := function (worker)
  local toReturn;
  while true do
    if IsBound(Tasks.InputChannels[worker+1]) then
      toReturn := Tasks.InputChannels[worker+1];
      break;
    fi;
  od;
  return toReturn;
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

  Tasks.InputChannels[ThreadID(CurrentThread())+1] := channels.toworker;
  threadId := ThreadID(CurrentThread());

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

      p := WRITE_LOCK(TaskData);
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
        if resume=TASK_MANAGER_REQUESTS.FINISH then
          SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.FINISH_WORKER, worker := ThreadID(CurrentThread())));
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
        if IsThreadLocal(result) then
          task.result := MigrateObj (result, task);
          task.adopt_result := true;
        else
          task.result := result;
          task.adopt_result := false;
        fi;
        while true do
          toUnblock := TryReceiveChannel (task.blockedWorkers, fail);
          if IsIdenticalObj (toUnblock, fail) then
            break;
          else
            SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER,
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
  if not IsBound(Tasks.InputChannels[ThreadID(CurrentThread())+1]) then
    Tasks.InputChannels[ThreadID(CurrentThread())+1] := CreateChannel(1);
  fi;
  SendChannel (Tasks.TaskManagerRequests, rec (worker := ThreadID(CurrentThread()), type := TASK_MANAGER_REQUESTS.BLOCK_ME));
  resume := ReceiveChannel (GetWorkerInputChannel(ThreadID(CurrentThread())));
  if resume<>TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER then
    Error("Error while worker is waiting to resume\n");
  fi;
end;

# Starts a new worker (called by task manager).
Tasks.StartNewWorkerThread := function()
  local toworker, fromworker, channels, worker;
  toworker := CreateChannel(1);
  fromworker := CreateChannel(1);
  channels := rec(toworker := toworker, fromworker := fromworker);
  MakeReadOnlyObj(channels);
  worker := CreateThread(Tasks.Worker, channels);
  return worker;
end;

# Tasks.Initialize just fires off the task manager.
Tasks.Initialize := function()
  threadId := 0;
  TaskManager := CreateThread(Tasks.TaskManagerFunc);
  MakeReadOnlyGVar ("TaskManager");
  mainThreadChannels := rec ( toworker := CreateChannel(1),
                              fromworker := CreateChannel(1));
  MakeReadOnlyGVar("mainThreadChannels");
  Tasks.InputChannels[1] := mainThreadChannels.toworker;
end;

# Creates a task without binding it to a worker
Tasks.CreateTask := function(arglist)
  local i, task, args, adopt, adopted, ds,p;

  args := arglist{[2..Length(arglist)]};
  adopt := AtomicList([]);
  adopted := false;
  for i in [1..Length(args)] do
    if IsThreadLocal(args[i]) then
      adopt[i] := true;
      if not adopted then
        args[i] := ShareSpecialObj(CLONE_REACHABLE(args[i]));
        ds := RegionOf(args[i]);
        p := WRITE_LOCK(args[i]);
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

  task :=  ShareSpecialObj (rec (
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
    SendChannel(ch.toworker, TASK_MANAGER_REQUESTS.FINISH);
    WaitThread(ReceiveChannel(ch.fromworker));
  od;

  SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.CULL_IDLE_WORKERS,
                                                        worker := ThreadID(CurrentThread())));
end;

ExecuteTask:= atomic function(readwrite task)
  local worker;

  task.started := true;
  task.complete := false;

  atomic TaskData do
    TaskData.TaskPoolLen := TaskData.TaskPoolLen+1;
    TaskData.TaskPool[Tasks.TaskPoolLength()] := task;
  od;

  if (Tasks.FirstTask) then
    Tasks.FirstTask := false;
    SendChannel (Tasks.TaskManagerRequests, rec (type := TASK_MANAGER_REQUESTS.START_WORKERS,
                                                         noWorkers := Tasks.Initial,
                                                         worker := 0)); # worker id is irrelevant in this case
  fi;

  worker := TryReceiveChannel (Tasks.WorkerPool, fail);
  if IsNotIdenticalObj (worker, fail) then
    SendChannel (worker.toworker, TASK_MANAGER_REQUESTS.RESUME_IDLE_WORKER);
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
  atomic task do
    task.async := true;
  od;
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
  task := ShareSpecialObj (rec( started := true, complete := true, async := false,
                  result := result, adopt_result := false ));
  return task;
end;

DelayTask := function(arg)
  return Tasks.CreateTask(arg);
end;

WaitTask := function(arg)
  local task, p;

  atomic readonly arg[1] do
    if Length(arg) = 1 and IsList(arg[1]) then
      arg := arg[1];
    fi;
  od;

  for task in arg do
    atomic readonly task do
      if task.async then
        Error("Cannot wait for an asynchronous task");
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
    p := LOCK(false, task);
    if IsIdenticalObj (p, fail) then
      Error("Could not obtain lock in WaitTask\n");
    fi;

    if not task.complete then
      SendChannel (task.blockedWorkers, ThreadID(CurrentThread()));
      UNLOCK(p);
      Tasks.BlockWorkerThread();
    else
      UNLOCK(p);
    fi;
  od;

end;

WaitTasks := WaitTask;

WaitAnyTask := function(arg)
  local len, task;

  atomic arg[1] do
    if Length(arg) = 1 and IsList(arg[1]) then
      arg := arg[1];
    fi;
  od;

  len := Length(arg);

  for task in arg do
    WRITE_LOCK(task,false);
    if task.async then
      UNLOCK(task);
      Error("Cannot wait for an async task");
    fi;
    if not task.started then
      UNLOCK(task);
      ExecuteTask(task);
    fi;
  od;

  while true do
    for i in [1..len] do
      atomic readonly arg[i].complete do
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
      Error("Cannot obtain the result of an asynchronous task");
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
    if task.adopt_result then
      taskresult :=  CLONE_REACHABLE(task.result);
    else
      taskresult := task.result;
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

# Function executed by a task manager
Tasks.TaskManagerFunc := function()
  local i, worker, request, requestType, toResume, taskman;

  taskman := rec ( activeWorkers := 0,
                   blockedWorkers := 0,
                   suspendedWorkers := 0,
                   suspendedWorkersList := [],
                   allWorkers := []);

  while true do
    request := ReceiveChannel (Tasks.TaskManagerRequests);
    worker := request.worker;
    requestType := request.type;

    if requestType = TASK_MANAGER_REQUESTS.START_WORKERS then
      for i in [1..request.noWorkers] do
        worker := Tasks.StartNewWorkerThread();
        taskman.activeWorkers := taskman.activeWorkers+1;
      od;
    elif requestType = TASK_MANAGER_REQUESTS.BLOCK_ME then # request to block a worker
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
    elif requestType = TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER then # request to unblock a worker
      if worker<>0 then
        taskman.blockedWorkers := taskman.blockedWorkers-1;
        if taskman.activeWorkers>Tasks.Initial then
          SendChannel (Tasks.WorkerSuspensionRequests, true);
        fi;
      fi;
      SendChannel (GetWorkerInputChannel(worker), TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER);
    elif requestType = TASK_MANAGER_REQUESTS.SUSPEND_ME then
      taskman.activeWorkers := taskman.activeWorkers-1;
      if taskman.suspendedWorkers>Tasks.Initial then
        SendChannel (GetWorkerInputChannel(worker), TASK_MANAGER_REQUESTS.FINISH);
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
    elif requestType = TASK_MANAGER_REQUESTS.FINISH_WORKER then
      WaitThread(worker);
    fi;
  od;
end;

Tasks.Initialize();
