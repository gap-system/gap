#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

TaskStats := ShareObj ( rec (tasksCreated := 0,
                     tasksStolen := 0,
                     tasksExecuted := 0,
                     tasksOffloaded := 0));

BindGlobal ("BLOCK_TYPES", MakeReadOnlyObj( rec (
        BLOCKED_FETCH := 1,
        BLOCKED_WORKER := 2 )));

BindGlobal ("TASK_MANAGER_REQUESTS", MakeReadOnlyObj (rec (
        BLOCK_ME := 1,
        RESUME_IDLE_WORKER := 2,
        RESUME_BLOCKED_WORKER := 3,
        RESUME_SUSPENDED_WORKER := 4,
        SUSPEND_ME := 5,
        FINISH := 6,
        CULL_IDLE_WORKERS := 7,
        FINISH_WORKER := 8,
                            START_WORKERS := 9,
                            STEAL := 10,
                            NO_WORK := 11,
                            UNSUCC_STEAL := 12,
                            GOT_TASK := 13)));
#        TRY_UNBLOCK_TASK := 10,


DeclareGlobalFunction("ProcessHandleBlockedQueue");
DeclareGlobalFunction("SendSteal");

Tasks := AtomicRecord( rec ( Initial := GAPInfo.KernelInfo.NUM_CPUS ,    # initial number of worker threads
                 ReportErrors := true,
                 FirstTask := true,
                 WorkerPool := CreateChannel(),                # pool of idle workers
                 TaskManagerRequests := CreateChannel(),       # task manager requests
                 WorkerSuspensionRequests := CreateChannel(),  # suspend requests from task manager
                 InputChannels := AtomicList ([]),             # list of worker input channels
                 doStealing := false,
                 stealingStopped := false));



TaskPoolData := ShareSpecialObj( rec(
                        TaskPool := [],                               # task pool (list)
                        TaskPoolLen := 0 ));         # length of a task pool

MakeThreadLocal("threadId");

#ReadLib ("logging.g");

TaskStats := ShareSpecialObj ( rec (tasksCreated := 0,
	tasksStolen := 0,
	tasksExecuted := 0,
  tasksOffloaded := 0));

# Task manager is a special thread that supervises the workers
# (starts, blocks, suspends and resumes workers).
DeclareGlobalVariable ("TaskManager");
MakeReadWriteGVar("TaskManager");
DeclareGlobalVariable ("mainThreadChannels");
MakeReadWriteGVar("mainThreadChannels");


PrintTaskManStats := function()
  atomic readonly TaskStats do
    Print ("-----------------\n");
    Print ("Task Manager ", processId, ":\n");
    Print ("Tasks stolen : ", TaskStats.tasksStolen, "\n");
    Print ("Tasks executed : ", TaskStats.tasksExecuted, "\n");
    Print ("Tasks offloaded : ", TaskStats.tasksOffloaded, "\n");
    Print ("-----------------\n");
  od;
end;

GetWorkerInputChannel := function (worker)
  while true do
    if IsBound(Tasks.InputChannels[worker+1]) then
      return Tasks.InputChannels[worker+1];
    fi;
  od;
end;

SubObjectRegions := function(obj)
  local result, objs, subobj;
  result := OBJ_SET();
  objs := CLONE_DELIMITED(obj);
  for subobj in objs do
    if IsRegion(subobj) then
      ADD_OBJ_SET(result, subobj);
    fi;
  od;
  return OBJ_SET_VALUES(result);
end;

# Function executed by each worker thread
Tasks.Worker := function(channels)
  local taskdata, result, toUnblock, resume,
        suspend, unSuspend, p, task, i;

  #Tracing.InitWorkerLog();
  Tasks.InputChannels[ThreadID(CurrentThread())+1] := channels.toworker;
  threadId := ThreadID(CurrentThread());

  while true do
    Unbind (task);
    while not IsBound(task) do
      suspend := TryReceiveChannel (Tasks.WorkerSuspensionRequests, fail);
      if not IsIdenticalObj (suspend, fail) then
        #Tracing.TraceWorkerSuspended();
        SendChannel (Tasks.TaskManagerRequests, rec ( worker:= threadId,
                                                               type := TASK_MANAGER_REQUESTS.SUSPEND_ME));

        unSuspend := ReceiveChannel (channels.toworker);
        if unSuspend=TASK_MANAGER_REQUESTS.FINISH then
          #Tracing.Close();
          SendChannel (Tasks.TaskManagerRequests, rec ( worker := CurrentThread(),
                                                                  type := TASK_MANAGER_REQUESTS.FINISH_WORKER));
          return;
        fi;
      fi;


      p := LOCK(TaskPoolData);
      if IsIdenticalObj (p,fail) then
         Error("Failed to obtain lock for TaskPoolData inside Worker function\n");
      fi;
      if TaskPoolData.TaskPoolLen>0 then
        task := TaskPoolData.TaskPool[TaskPoolData.TaskPoolLen];
        Unbind (TaskPoolData.TaskPool[TaskPoolData.TaskPoolLen]);
        TaskPoolData.TaskPoolLen := TaskPoolData.TaskPoolLen-1;
        #Tracing.TraceWorkerGotTask();
        UNLOCK(p);
      else
        UNLOCK(p);
        SendChannel (Tasks.WorkerPool, channels);
        SendChannel (Tasks.TaskManagerRequests, rec ( worker := threadId,
                                                                type := TASK_MANAGER_REQUESTS.NO_WORK));
        resume := ReceiveChannel (channels.toworker);
        if resume=TASK_MANAGER_REQUESTS.FINISH then
          #Tracing.Close();
          SendChannel (Tasks.TaskManagerRequests (rec ( type := TASK_MANAGER_REQUESTS.FINISH_WORKER,
          	worker := threadId)));
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
      if MPI_DEBUG.TASKS then
        MPILog(MPI_DEBUG_OUTPUT.LOCAL_TASKS, String(HANDLE_OBJ(task)), " EX");
      fi;
    od;


    atomic TaskStats do
      TaskStats.tasksExecuted := TaskStats.tasksExecuted+1;
    od;

    if IsString(taskdata.func) then
      taskdata.func := VALUE_GLOBAL(taskdata.func);
    fi;


    if taskdata.async then
      CALL_WITH_CATCH(taskdata.func, taskdata.args);
    else
      result := CALL_WITH_CATCH(taskdata.func, taskdata.args);
      #Tracing.TraceTaskFinished();
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
        if IsBound(task.result) and not IsThreadLocal(task.result) then
          p := LOCK(task.result);
        fi;
        if IsBound(task.result) and IsGlobalObjectHandle(task.result) then
          ShareSpecialObj(result);
          task.result!.obj := result;
          #MigrateObj(result,task);
          task.result!.control.haveObject := true;
          ProcessHandleBlockedQueue(task.result, result);
          UNLOCK(p);
        else
          if IsThreadLocal(result) then
            task.result := MigrateObj (result, task);
            task.adopt_result := true;
          else
            task.result := result;
            task.adopt_result := false;
            #SetImportedTaskResult(task,result);
          fi;
        fi;
        #if IsBound(task.waitingOnMe) then
        #  SendChannel (Tasks.TaskManagerRequests, rec (
        #          type := TASK_MANAGER_REQUESTS.TRY_UNBLOCK_TASK,
        #                          worker := threadId,
        #                          tasks := task.waitingOnMe));
        #fi;
        while true do
          toUnblock := TryReceiveChannel (task.blockedWorkers, fail);
          if IsIdenticalObj (toUnblock, fail) then
            break;
          else
            SendChannel (Tasks.TaskManagerRequests, rec ( type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER,
                                                                  worker := toUnblock.worker));
          fi;
        od;
      od;
    fi;

  od;
end;

# Function called when worker blocks on the result of a task.
Tasks.BlockWorkerThread := function()
  local resume;
  #Tracing.TraceWorkerBlocked();
  if not IsBound(Tasks.InputChannels[threadId+1]) then
    Tasks.InputChannels[threadId+1] := CreateChannel(1);
  fi;
  SendChannel (Tasks.TaskManagerRequests, rec (worker := threadId, type := TASK_MANAGER_REQUESTS.BLOCK_ME));
  resume := ReceiveChannel (GetWorkerInputChannel(threadId));
  if resume<>TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER then
    Error("Error while worker is waiting to resume\n");
  fi;
  #Tracing.TraceWorkerResumed();
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
  local i, toworker, fromworker, channels;
  TaskManager := CreateThread(Tasks.TaskManagerFunc);
  MakeReadOnlyGVar ("TaskManager");
  mainThreadChannels := rec ( toworker := CreateChannel(1),
                              fromworker := CreateChannel(1));
  MakeReadOnlyGVar("mainThreadChannels");
  Tasks.InputChannels[1] := mainThreadChannels.toworker;
  threadId := 0;
end;

# Creates a task without binding it to a worker
CreateTask := function(arglist)
  local i, channels, task, request, args, adopt, adopted, ds,p,
        addToTaskPool, q;
  args := arglist{[2..Length(arglist)]};
  adopt := AtomicList([]);
  adopted := false;
  for i in [1..Length(args)] do
    if IsThreadLocal(args[i]) then
      adopt[i] := true;
      if not adopted then
        args[i] := ShareSpecialObj(CLONE_REACHABLE(args[i]));
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
  task :=  ShareSpecialObj (rec (
                   func := arglist[1],
                   args := args,
                   adopt := adopt,
                   async := false,
                   complete := false,
                   started := false,
                   async := false,
                   offloaded := false,
                   blockedWorkers := CreateChannel(),
                   waitingOnMe := ShareSpecialObj([]),
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
                                                        worker := threadId));
end;

ExecuteTask:= atomic function(readwrite task)
  local channels, t, taskdata, worker, tracingTime;

  task.started := true;
  task.complete := false;
  atomic readwrite TaskPoolData do
    TaskPoolData.TaskPoolLen := TaskPoolData.TaskPoolLen+1;
    TaskPoolData.TaskPool[TaskPoolData.TaskPoolLen] := task;
  od;
 # Tracing.TraceTaskCreated();
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

RunTask:= function(arg)
  local task;
  task := CreateTask(arg);
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
        Error("Cannot wait for an asynchronous task");
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
    p := LOCK(task, false);
    if not task.complete then
      SendChannel (task.blockedWorkers, rec (type := BLOCK_TYPES.BLOCKED_WORKER, worker := threadId));
      UNLOCK(p);
      Tasks.BlockWorkerThread();
      atomic task do
        if task.offloaded then
          atomic readwrite task.result do
            Open(task.result);
          od;
          task.result := GetHandleObj(task.result);
        fi;
      od;
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
  local taskresult, toExecute, toWait, toFetch;
  toExecute := false;
  toWait := false;
  toFetch := false;
  atomic readonly task do
    if task.async then
      Error("Cannot obtain the result of an asynchronous task");
    fi;
    if task.offloaded then
      toFetch := true;
    elif not task.started then
      toExecute := true;
    elif not task.complete then
      toWait := true;
    fi;
  od;
  if toExecute then
    ExecuteTask(task);
  elif toWait then
    WaitTask(task);
  elif toFetch then
    atomic readwrite task do
      atomic readwrite task.result do
        Open(task.result);
      od;
      task.result := GetHandleObj(task.result);
    od;
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

## task milestones
#ScheduleTask := function (arg)
#  local task, waitTask;
#  if IsFunction(arg[1]) then
#    task := RunTask(arg);
#  else
#    task := Tasks.CreateTask(arg{[2..Length(arg)]});
#    atomic readwrite task do
#      task.started := true;
#      task.condCount := 0;
#      for waitTask in arg[1] do
#        atomic readonly waitTask do
#          atomic readwrite waitTask.waitingOnMe do
#            if waitTask.complete = false then
#              Add(waitTask.waitingOnMe, task);
#              task.condCount := task.condCount+1;
#            fi;
#          od;
#        od;
#      od;
#      if task.condCount = 0 then
#        ExecuteTask(task);
#      fi;
#    od;
#  fi;
#  return task;
#end;

#NewMilestone := function(contributions)
#  local c;
#  c := Set(contributions);
#  return ShareSpecialObj(rec(
#             achieved := Set([]),
#             targets := Immutable(c),
#             complete := Length(c) = 0,
#             waitingOnMe := ShareSpecialObj([]),
#             ));
#end;

#ContributeToMilestone := function(milestone, contribution)
#  local trigger, notify, t;
#  atomic milestone do
#    if not contribution in milestone.targets then
#      Error("ContributeToMilestone: Milestone does not have such a contribution");
#    fi;
#    if milestone.complete then
#      return;
#    fi;
#    AddSet(milestone.achieved, Immutable(contribution));
#    if Length(milestone.achieved) < Length(milestone.targets) then
#      return;
#    fi;
#    milestone.complete := true;
#    atomic readonly milestone.waitingOnMe do
#      SendChannel (Tasks.TaskManagerRequests, rec (
#              type := TASK_MANAGER_REQUESTS.TRY_UNBLOCK_TASK,
#              worker := threadId,
#              tasks := milestone.waitingOnMe ));
#    od;
#  od;
#end;

# Function executed by a task manager
Tasks.TaskManagerFunc := function()
  local i, worker,  request, requestType,
        taskToFinish, toUnblock,
        totalTasks, blockedWorkersChannel, taskMap,
        toResume, taskman, target, finishing, finishingState, t;

  finishing := false;
  taskman := rec (startedWorkers := 0,
                  activeWorkers:= 0,
                  blockedWorkers:=0,
                  suspendedWorkers:=0,
                  suspendedWorkersList:=[],
                  allWorkers:=[],
                  stealing:=false,
                  stealRequests:=0);
#                  nextStealingTime:=MicroSeconds());

  while true do
    if finishing and finishingState.myWorkersToFinish=0 then
      PrintTaskManStats();
      return;
    fi;
    if Tasks.doStealing and taskman.stealRequests>0 and (not taskman.stealing) and (not finishing) then
      SendSteal();
      taskman.stealing := true;
    fi;
    request := ReceiveChannel (Tasks.TaskManagerRequests);

    worker := request.worker;
    requestType := request.type;
    if requestType = TASK_MANAGER_REQUESTS.START_WORKERS then
      if taskman.startedWorkers = 0 then
        for i in [1..request.noWorkers] do
          worker := Tasks.StartNewWorkerThread();
          taskman.activeWorkers := taskman.activeWorkers+1;
          taskman.startedWorkers := taskman.startedWorkers+1;
        od;
      fi;
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
 #   elif requestType = TASK_MANAGER_REQUESTS.TRY_UNBLOCK_TASK then
 #     atomic readonly request.tasks do
 #       for t in request.tasks do
 #         atomic readwrite t do
 #           t.condCount := t.condCount-1;
 #           if t.condCount = 0 then
 #             ExecuteTask(t);
 #           fi;
 #         od;
 #       od;
 #     od;
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
    elif requestType = TASK_MANAGER_REQUESTS.NO_WORK then
      taskman.stealRequests := taskman.stealRequests+1;
    elif requestType = TASK_MANAGER_REQUESTS.UNSUCC_STEAL then
      taskman.stealing := false;
    elif requestType = TASK_MANAGER_REQUESTS.GOT_TASK then
      #if taskman.stealRequests>0 then taskman.stealRequests := taskman.stealRequests-1; fi;
      taskman.stealRequests := 0;
      taskman.stealing := false;
    elif requestType = TASK_MANAGER_REQUESTS.FINISH_WORKER then
      WaitThread(worker);
      if finishing then
        finishingState.myWorkersToFinish := finishingState.myWorkersToFinish-1;
      fi;
    elif requestType = TASK_MANAGER_REQUESTS.FINISH then
      finishingState := rec ( myWorkersToFinish := taskman.activeWorkers + taskman.suspendedWorkers );
      if IsBound(MPI_Initialized) and IsBound(MPI_Comm_rank) then
        if processId=0 then
          SendMessage (processId, MESSAGE_TYPES.FINISH);
        fi;
      fi;
      for i in taskman.allWorkers do
        SendChannel (GetWorkerInputChannel(i), TASK_MANAGER_REQUESTS.FINISH);
      od;
      finishing := true;
    else
      Error("Task manager on ", processId, " received unknown request!\n");
    fi;
  od;
end;

Tasks.Initialize();
