f := function (x)
  local i;
  for i in [1..x] do
    Factorial(i);
  od;
  return 1;
end;

t1 := RunTask (f, 100);
t2 := RunTask (f, 200);
t3 := RunTask (f, 1);
# test 1 -- ScheduleTask where arguments are tasks that are not yet completed tasks
t4 := ScheduleTask ([t1,t2], f, 150);
# test 2 -- ScheduleTask where some of the arguments are completed tasks
Sleep(1);
t5 := ScheduleTask ([t2,t3], f, 150);

Print(TaskResult(t1)+TaskResult(t2)+TaskResult(t3)+TaskResult(t4)+TaskResult(t5),"\n");

