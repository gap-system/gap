InitialTasks := 0;
TaskPool := CreateChannel();

TaskWorker := function(channels)
  local i, taskdata, result;
  while true do
    taskdata := ReceiveChannel(channels.toworker);
    if IsIdenticalObj(taskdata, fail) then
      return;
    fi;
    for i in [1..Length(taskdata.adopt)] do
      if taskdata.adopt[i] then
	atomic readwrite taskdata.args[i] do
          ADOPT(taskdata.args[i]);
	od;
      fi;
    od;
    result := CallFuncList(taskdata.func, taskdata.args);
    SendChannel(channels.fromworker,
      rec(value := result, channels := channels));
  od;
end;

StartNewWorkerThread := function()
  local toworker, fromworker, channels;
  toworker := CreateChannel(1);
  fromworker := CreateChannel(1);
  channels := rec(toworker := toworker, fromworker := fromworker);
  Freeze(channels);
  CreateThread(TaskWorker, channels);
  return channels;
end;

InitializeTasks := function()
  local i;
  for i in [1..InitialTasks] do
    SendChannel(TaskPool, StartNewWorkerThread());
  od;
end;

CreateTask := function(arglist)
  local i, channels, task, request, args, adopt, adopted, ds;
  channels := TryReceiveChannel(TaskPool, fail);
  if IsIdenticalObj(channels, fail) then
    channels := StartNewWorkerThread();
  fi;
  args := arglist{[2..Length(arglist)]};
  adopt := [];
  adopted := false;
  for i in [1..Length(args)] do
    if IsThreadLocal(args[i]) then
      adopt[i] := true;
      if not adopted then
        args[i] := SHARE(CLONE_REACHABLE(args[i]));
	ds := DataSpace(args[i]);
	adopted := true;
      else
        args[i] := MIGRATE(CLONE_REACHABLE(args[i]), ds);
      fi;
    else
      adopt[i] := false;
    fi;
  od;
  request := rec( channels := channels,
    func := arglist[1], args := args, adopt := adopt);
  task :=rec(
    channel := channels.fromworker,
    request := request,
    complete := false,
    running := false,
    result := fail);
  return task;
end;

ExecuteTask := function(task)
  if not task.running then
    SendChannel(task.request.channels.toworker, task.request);
    task.running := true;
    Unbind(task.request);
  fi;
  return task;
end;

RunTask := function(arg)
  local task;
  task := CreateTask(arg);
  ExecuteTask(task);
  return task;
end;

DelayTask := function(arg)
  local task;
  return CreateTask(arg);
end;

WaitTask := function(arg)
  local task, taskresult;
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;
  for task in arg do
    if not task.running then
      ExecuteTask(task);
    fi;
  od;
  for task in arg do
    if not task.complete then
      taskresult := ReceiveChannel(task.channel);
      task.result := taskresult.value;
      task.complete := true;
      SendChannel(TaskPool, taskresult.channels);
    fi;
  od;
end;

WaitTasks := WaitTask;

WaitAnyTask := function(arg)
  local i, len, taskresult, channels, ch;
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;
  len := Length(arg);
  for i in [1..len] do
    if not arg[i].running then
      ExecuteTask(arg[i]);
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
  SendChannel(TaskPool, taskresult.channels);
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
  if not task.running then
    ExecuteTask(task);
  fi;
  if not task.complete then
    taskresult := ReceiveChannel(task.channel);
    task.result := taskresult.value;
    task.complete := true;
    SendChannel(TaskPool, taskresult.channels);
  fi;
  return task.result;
end;

TaskFinished := function(task)
  return task.complete or Length(InspectChannel(task.channel)) > 0;
end;

InitializeTasks();
