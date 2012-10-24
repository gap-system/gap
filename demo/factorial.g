Read("demo/bench.g");

DeclareGlobalFunction("SeqFactorial");

InstallGlobalFunction("SeqFactorial", function ( n );
  if n=0 then 
    return 1;
  else 
    return n * SeqFactorial(n-1);
  fi;
end); 


FactorialByTasks := function ( n , k)
  local  pr, parbound;
  if n < 0  then
    Error( "<n> must be nonnegative" );
  fi;
  parbound := QuoInt(n,k);
  pr := function ( l, i, j )
    local bound, len, res, l2, t1, t2, k;
    bound := 30;
    len := j + 1 - i;
    if len < bound  then
      res := 1;
      for k  in [ i .. j ]  do
        res := res * l[k];
      od;
      return res;
    fi;
    l2 := QuoInt( len, 2 );
    if len > parbound then
      t1 := RunTask(pr, l, i, i+l2);
      t2 := RunTask(pr, l, i+l2+1, j);
      return TaskResult(t1) * TaskResult(t2);
    else
      return pr(l, i, i+l2) * pr(l, i+l2+1, j);
    fi;
  end;
  return pr( [ 1 .. n ], 1, n );
end; 

#m := SeqFactorial(0);
#Print(m);
m := 1;
#t := Bench (do m:=Factorial(10000000); od);
#Display(t);
StartLogging();
t := Bench (do m := FactorialByTasks(10000000,100); od);
CullIdleTasks();
Display(t);
StopLogging();

