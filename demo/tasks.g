InitialTasks := 4;
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

RunTask := function(arg)
  local i, channels, task, taskdata, args, adopt, adopted, ds;
  channels := TryReceiveChannel(TaskPool, fail);
  if IsIdenticalObj(channels, fail) then
    channels := StartNewWorkerThread();
  fi;
  args := arg{[2..Length(arg)]};
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
  taskdata := rec( channels := channels,
    func := arg[1], args := args, adopt := adopt);
  SendChannel(channels.toworker, taskdata);
  task :=rec(
    channel := channels.fromworker,
    complete := false,
    result := fail);
  return task;
end;

WaitTask := function(arg)
  local task, taskresult;
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
  local i, taskresult, channels, ch;
  for i in [1..Length(arg)] do
    if arg[i].complete then
      return i;
    fi;
  od;
  channels := List(arg, task -> task.channel);
  taskresult := ReceiveAnyChannel(channels);
  ch := taskresult.channels.fromworker;
  SendChannel(TaskPool, taskresult.channels);
  for i in [1..Length(channels)] do
    if ch = channels[i].channel then
      arg[i].result := taskresult.value;
      arg[i].complete := true;
      return i;
    fi;
  od;
end;

TaskResult := function(task)
  local taskresult;
  if not task.complete then
    taskresult := ReceiveChannel(task.channel);
    task.result := taskresult.value;
    task.complete := true;
    SendChannel(TaskPool, taskresult.channels);
  fi;
  return task.result;
end;

InitializeTasks();
