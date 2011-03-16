Read("demo/tasks.g");
FibCache := AtomicList(1024, -1);

DoTask := function(func, arg)
  if RunningTasks() > 4 then
    return ImmediateTask(func, arg);
  else
    return RunTask(func, arg);
  fi;
end;

fib := function(n)
  local task1, task2, result;
  if n <= 1 then
    return 1;
  elif FibCache[n] > 0 then
    return FibCache[n];
  else
    task1 := DoTask(fib, n-2);
    task2 := DoTask(fib, n-1);
    result := TaskResult(task1) + TaskResult(task2);
    FibCache[n] := result;
    return result;
  fi;
end;
