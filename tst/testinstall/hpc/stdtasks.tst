#@if IsHPCGAP
gap> START_TEST("stdtasks.tst");

#
gap> task := RunTask(x -> SortedList(x), [3,2,1]);;
gap> WaitTask(task);
gap> TaskResult(task);
[ 1, 2, 3 ]

#
gap> task := RunTask(x -> SortedList(x), [3,2,1]);;
gap> TaskResult(task);
[ 1, 2, 3 ]

#
gap> task1 := RunTask(Product, [1..5000]);;
gap> task2 := RunTask(Product, [5001..10000]);;
gap> TaskResult(task1) * TaskResult(task2) = Factorial(10000);
true

#
gap> task1 := DelayTask(Product, [1..5000]);;
gap> task2 := DelayTask(Product, [5001..10000]);;
gap> WaitTask(task1, task2);
gap> TaskResult(task1) * TaskResult(task2) = Factorial(10000);
true

#
gap> task := ImmediateTask(x -> SortedList(x), [3,2,1]);;
gap> TaskResult(task);
[ 1, 2, 3 ]

#
gap> t1 := RunTask(x->x*x, 3);;
gap> t2 := RunTask(x->x*x, 4);;
gap> t := ScheduleTask([t1, t2], function()
>           return TaskResult(t1) + TaskResult(t2);
>    end);;
gap> TaskResult(t);
25

#
gap> task1 := DelayTask(SortedList, [3,2,1]);;
gap> task2 := DelayTask(SortedList, [2^15, 2^15-1 .. 1]);;
gap> WaitAnyTask(task1, task2) in [1, 2];
true
gap> WaitTasks(task1, task2);
gap> TaskResult(task1);
[ 1, 2, 3 ]
gap> TaskResult(task2) = [1..2^15];
true

#
gap> task1 := DelayTask(MicroSleep, 10000);;
gap> task2 := DelayTask(MicroSleep, 50000);;
gap> WaitAnyTask(task1, task2) in [1,2];
true
gap> WaitTasks(task1, task2);
gap> WaitAnyTask(task1, task2);
1
gap> task1 := DelayTask(MicroSleep, 50000);;
gap> task2 := DelayTask(MicroSleep, 10000);;
gap> WaitAnyTask(task1, task2) in [1,2];
true
gap> WaitTasks(task1, task2);
gap> WaitAnyTask(task1, task2);
1

#
gap> task := RunTask(function()
>      while true do
>        OnTaskCancellation(function() return 314; end);
>      od;
>    end);;
gap> CancelTask(task);
gap> TaskResult(task);
314

#
gap> m := NewMilestone();;
gap> IsMilestoneAchieved(m);
false
gap> AchieveMilestone(m);
gap> IsMilestoneAchieved(m);
true

#
gap> m := NewMilestone([1,2]);;
gap> ContributeToMilestone(m, 1);
gap> IsMilestoneAchieved(m);
false
gap> ContributeToMilestone(m, 2);
gap> IsMilestoneAchieved(m);
true

#
gap> STOP_TEST( "stdtasks.tst", 1 );
#@fi
