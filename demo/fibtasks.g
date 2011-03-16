Read("demo/tasks.g");
FibCache := AtomicList(1024, -1);

fib := function(n)
  local task1, task2, result;
  if n <= 1 then
    return 1;
  elif FibCache[n] > 0 then
    return FibCache[n];
  else
    task1 := RunTask(fib, n-2);
    task2 := DelayTask(fib, n-1);
    result := TaskResult(task1) + TaskResult(task2);
    FibCache[n] := result;
    return result;
  fi;
end;
