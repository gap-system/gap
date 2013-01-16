StopFunc := function()
  OnTaskCancellation(ReturnFail);
end;

SieveFactor := function(n)
  local c, i, j, k, sieve, result;
  n := AbsoluteValue(n);
  if n <= 3 then
    return [ n ];
  fi;
  k := Int(Sqrt(n*1.0));
  sieve := BlistList([1..k], [1..k]);
  result := [];
  c := 0;
  for i in [2..Length(sieve)] do
    if n = 1 then
      return result;
    fi;
    if sieve[i] then
      while n mod i = 0 do
        Add(result, i);
	n := n / i;
      od;
      j := i * i;
      if n = 1 or j >= n then
        if n > 1 then
	  Add(result, n);
	fi;
	return result;
      fi;
      k := Int(Sqrt(n*1.0));
      while j <= k do
	PERIODIC_CHECK(1, StopFunc);
        sieve[k] := false;
	j := j + i;
      od;
    fi;
  od;
  if n > 1 then
    Add(result, n);
  fi;
  return result;
end;

# Specialized faster version of RootInt(n,2) from integer.gi

SqrtNat := function(n)
  local r, s;
  if n <= 1 then
    return n;
  fi;
  r := n;
  s := 2^(QuoInt(LogInt(n, 2), 2)+1)-1;
  while s < r do
    r := s;
    s := QuoInt(n + r*r, 2*r);
  od;
  if r * r = n then
    return r;
  else
    return fail;
  fi;
end;

FermatFactor2 := function(n)
  local a, b, sqrt, i;
  a := Int(Ceil(Sqrt(n*1.0)));
  b := a * a - n;
  i := 0;
  while true do
    PERIODIC_CHECK(1, StopFunc);
    i := i + 1;
    sqrt := SqrtNat(b);
    if IsInt(sqrt) then
      return [ a - sqrt, a + sqrt ];
    fi;
    a := a + 1;
    b := a * a - n;
  od;
end;

FermatFactorRec := function(n)
  local result, f;
  result := [];
  if n = 1 then
    return result;
  fi;
  f := FermatFactor2(n);
  if f[1] = 1 then
    Add(result, f[2]);
    return result;
  fi;
  Append(result, FermatFactorRec(f[1]));
  Append(result, FermatFactorRec(f[2]));
  return result;
end;

FermatFactor := function(n)
  local result;
  if n <= 3 then
    return [ n ];
  fi;
  result := [];
  while n mod 2 = 0 do
    Add(result, 2);
    n := n / 2;
  od;
  Append(result, FermatFactorRec(n));
  Sort(result);
  return result;
end;

ParallelFactor := function(n)
  local task, tasks, which, funcs;
  funcs := [SieveFactor, FermatFactor];
  tasks := List(funcs, f->RunTask(f, n));
  which := WaitAnyTask(tasks);
  for task in tasks do
    # It is safe to cancel a completed task.
    CancelTask(task);
    WaitTask(task);
  od;
  Print(TaskResult(tasks[which]), " (", NAME_FUNC(funcs[which]), ")\n");
end;

Print("Factoring 2^44-1 -> \c");
ParallelFactor(2^44-1);
Print("Factoring 2^44+1 -> \c");
ParallelFactor(2^44+1);
