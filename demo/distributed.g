DeclareGlobalFunction("naiveFib");

ParInstallGlobalFunction("naiveFib", function(x)
  if x<2 then
    return 1;
  else
    return naiveFib(x-1)+naiveFib(x-2);
  fi;
end);

t1 := Tasks.CreateTask ([naiveFib, 20]);
SendTask(t1,1);
Print(TaskResult(t1),"\n");

taskList := [];
resList := [];
l := [20,21,22,23,24];
handle_l := RemoteCopyObj(l,1);
t2 := Tasks.CreateTask ([\x->List(x,naiveFib), l]);
SendTask(t2,1);
t3 := Tasks.CreateTask ([\x->List(x,\y->y*y), l]);
SendTask(t3,1);
t4 := RunTask (\x->naiveFib(x)-42,l[1]);
Print (TaskResult(t2),",",TaskResult(t3),",",TaskResult(t4),"\n");
ParFinish();

