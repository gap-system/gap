ReadGapRoot("demo/unittest.g");

ResetCache := function()
  UNBIND_GLOBAL("FibCache");
  BIND_GLOBAL("FibCache", AtomicList(1024, -1));
  MakeReadWriteGVar("FibCache");
end;

ResetCache();

DivideAndConquer := function(func, args, split)
  if split = 0 then
    return ImmediateTask(func, args, split);
  else
    return RunTask(func, args, split-1);
  fi;
end;

fib_tasks := function(n, split)
  local task1, task2, result;
  if n <= 2 then
    return 1;
  elif FibCache[n] > 0 then
    return FibCache[n];
  else
    task1 := DivideAndConquer(fib_tasks, n-2, split);
    task2 := DivideAndConquer(fib_tasks, n-1, split);
    result := TaskResult(task1) + TaskResult(task2);
    FibCache[n] := result;
    return result;
  fi;
end;

fib := n -> fib_tasks(n, 4);

TestEqual(fib(100), Fibonacci(100), "Concurrent Fibonacci(100) Calculation");
ResetCache();
TestEqual(List([1..100],Fibonacci), List([1..100],fib), "Concurrent Fibonacci Batch Calculation");
TestReportAndExit();
