ReadGapRoot("demo/unittest.g");

TestPrefix("Concurrent Method Dispatch");

TestEqual(TaskResult(RunTask(x->SortedList(x), [3,2,1])), [1,2,3], "Sorting");
TestEqual(TaskResult(RunTask(x->Factorial(x), 99)), Factorial(99), "Factorial");
TestReportAndExit();
