DeclareGlobalVariable("t10");
MakeReadWriteGVar("t10");

payload := function (x)
  local i;
  for i in [1..x] do
    Factorial(i);
  od;
  return 1;
end;

f := function()
  local t;
  t := ScheduleTask ([t10], function () return 1; end);
  return TaskResult(t)+1;
end;

###### ScheduleTask with only tasks as arguments ######
t1 := RunTask (payload, 100);
t2 := RunTask (payload, 200);
t3 := RunTask (payload, 1);
# test 1 -- ScheduleTask where arguments are tasks that are not yet completed tasks
t4 := ScheduleTask ([t1,t2], payload, 150);
Print("TaskResult(t4)=",TaskResult(t4),"\n");
# test 2 -- ScheduleTask where some of the arguments are completed tasks
t5 := ScheduleTask ([t2,t3], payload, 150);
Print("TaskResult(t5)=",TaskResult(t5),"\n");
# test 3 -- ScheduleTask with dependancies
t6 := ScheduleTask ([t1,t4], function () return TaskResult(t1)+TaskResult(t4); end);
# test 4 -- ScheduleTask, where arguments are tasks created using ScheduleTask
t7 := RunTask (payload,100);
t8 := ScheduleTask ( [t7], payload, 200);
t9 := ScheduleTask ( [t8,t1], payload, 200);
# test 5 -- Tasks created from two different tasks waiting for the task created from third task (!)
t10 := RunTask (payload, 500);
t11 := ScheduleTask ([t10], payload, 100);
t12 := RunTask (f);
Print ("TaskResult(t12)=",TaskResult(t12),"\n");

##### ScheduleTask with milestones #####
# test 1 -- ScheduleTask that waits on the simplest possible milestone
Print ("ScheduleTask with Milestones\n");
m := NewMilestone([1]);
tm1 := ScheduleTask ([m],payload, 100);
ContributeToMilestone(m,1);
Print ("TaskResult(tm1)=",TaskResult(tm1),"\n");
m2 := NewMilestone([1,2,3]);
RunTask (function() ContributeToMilestone(m2,1); end);
RunTask (function() ContributeToMilestone(m2,2); end);
ContributeToMilestone(m2,3);
tm2 := ScheduleTask([m2,t11], payload, 120);
Print ("TaskResult(tm2)=", TaskResult(tm2), "\n");

