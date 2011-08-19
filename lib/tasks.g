Revision.tasks_g := "2011-05-12 16:37:00 +0000";

Tasks := AtomicRecord( rec(
  Initial := 0,
  ReportErrors := true,
  Pool := CreateChannel(),
  Running := AtomicList(1, 0) ));

RunningTasks := function()
  return Tasks.Running[1];
end;

Tasks.Worker := function(channels)
  local i, taskdata, result;
  while true do
    taskdata := ReceiveChannel(channels.toworker);
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
    if taskdata.detached then
      CALL_WITH_CATCH(taskdata.func, taskdata.args);
      SendChannel(Tasks.Pool, channels);
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
      SendChannel(channels.fromworker,
	rec(value := result, channels := channels));
    fi;
    ATOMIC_ADDITION(Tasks.Running, 1, -1);
  od;
end;

Tasks.StartNewWorkerThread := function()
  local toworker, fromworker, channels;
  toworker := CreateChannel(1);
  fromworker := CreateChannel(1);
  channels := rec(toworker := toworker, fromworker := fromworker);
  MakeReadOnly(channels);
  CreateThread(Tasks.Worker, channels);
  return channels;
end;

Tasks.Initialize := function()
  local i;
  for i in [1..Tasks.Initial] do
    SendChannel(Tasks.Pool, Tasks.StartNewWorkerThread());
  od;
end;

Tasks.CreateTask := function(arglist)
  local i, channels, task, request, args, adopt, adopted, ds,p;
  channels := TryReceiveChannel(Tasks.Pool, fail);
  if IsIdenticalObj(channels, fail) then
    channels := Tasks.StartNewWorkerThread();
  fi;
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
  request := rec( channels := channels,
    func := arglist[1], args := args, adopt := adopt);
  task :=rec(
    channel := channels.fromworker,
    request := request,
    complete := false,
    started := false,
    detached := false,
    result := fail);
  return task;
end;

CullIdleTasks := function()
  local ch, channels;
  channels := MultiReceiveChannel(Tasks.Pool, 1024);
  for ch in channels do
    SendChannel(ch.toworker, fail);
    WaitThread(ReceiveChannel(ch.fromworker));
  od;
end;

ExecuteTask := function(task)
  if not task.started then
    task.request.detached := task.detached;
    SendChannel(task.request.channels.toworker, task.request);
    ATOMIC_ADDITION(Tasks.Running, 1, 1);
    task.started := true;
    Unbind(task.request);
  fi;
  return task;
end;

RunTask := function(arg)
  local task;
  task := Tasks.CreateTask(arg);
  ExecuteTask(task);
  return task;
end;

RunDetachedTask := function(arg)
  local task;
  task := Tasks.CreateTask(arg);
  task.detached := true;
  ExecuteTask(task);
  return task;
end;

DetachTask := function(task)
  if task.started then
    Error("Cannot detach a running task");
  fi;
  task.detached := true;
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
  return rec( started := true, complete := true, detached := false,
    result := result );
end;

DelayTask := function(arg)
  local task;
  return Tasks.CreateTask(arg);
end;

WaitTask := function(arg)
  local task, taskresult;
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;
  for task in arg do
    if task.detached then
      Error("Cannot wait for a detached task");
    fi;
  od;
  for task in arg do
    if not task.started then
      ExecuteTask(task);
    fi;
  od;
  for task in arg do
    if not task.complete then
      taskresult := ReceiveChannel(task.channel);
      task.result := taskresult.value;
      task.complete := true;
      SendChannel(Tasks.Pool, taskresult.channels);
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
    if task.detached then
      Error("Cannot wait for a detached task");
    fi;
  od;
  for task in arg do
    if not task.started then
      ExecuteTask(task);
    fi;
  od;
  for i in [1..len] do
    if arg[i].complete then
      return i;
    fi;
  od;
  channels := List(arg, task -> task.channel);
  taskresult := ReceiveAnyChannel(channels);
  ch := taskresult.channels.fromworker;
  SendChannel(Tasks.Pool, taskresult.channels);
  for i in [1..Length(channels)] do
    if ch = channels[i] then
      arg[i].result := taskresult.value;
      arg[i].complete := true;
      return i;
    fi;
  od;
end;

TaskResult := function(task)
  local taskresult;
  if task.detached then
    Error("Cannot obtain the result of a detached task");
  fi;
  if not task.started then
    ExecuteTask(task);
  fi;
  if not task.complete then
    taskresult := ReceiveChannel(task.channel);
    task.result := taskresult.value;
    task.complete := true;
    SendChannel(Tasks.Pool, taskresult.channels);
  fi;
  return task.result;
end;

TaskStarted := function(task)
  return task.started;
end;

TaskFinished := function(task)
  return task.complete or Length(InspectChannel(task.channel)) > 0;
end;

TaskDetached := function(task)
  return task.detached;
end;

Tasks.Initialize();
