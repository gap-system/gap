#############################################################################
##
#W  threads.tst               GAP tests                       Chris Jefferson
##
##
##
#Y  Copyright (C) 2017
##
gap> START_TEST("threads.tst");
gap> if IsHPCGAP or ARCH_IS_WINDOWS() then tasks := 100; else tasks := 10; fi;;
gap> taskssum := (tasks*(tasks+1))/2;;
gap> f := function(val) local x; MicroSleep(tasks*100); x := val; MicroSleep(tasks*100); return x; end;;
gap> l := List([1..tasks], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = [1..tasks];
true
gap> a := AtomicList([0]);
[ 0 ]
gap> f := function(val) local x; MicroSleep(tasks*100); a[val] := val; MicroSleep(tasks*100); return val; end;;
gap> l := List([1..tasks], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = [1..tasks];
true
gap> ForAll([1..tasks], i -> a[i] = i);
true
gap> a := FixedAtomicList(tasks, 0);;
gap> f := function(val) local x; MicroSleep(tasks*100); a[val] := val; MicroSleep(tasks*100); return val; end;;
gap> l := List([1..tasks], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = [1..tasks];
true
gap> ForAll([1..tasks], i -> a[i] = i);
true
gap> a := FixedAtomicList(2, 0);;
gap> a[2] := -taskssum;;
gap> f := function(val)
> MicroSleep(val * 100); ATOMIC_ADDITION(a, 1, val);
> MicroSleep(val * 5000); ATOMIC_ADDITION(a, 2, val);
> end;;
gap> l := List([1..tasks], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = List([1..tasks], x -> fail);
true
gap> a[1] = taskssum and a[2] = 0;
true
gap> a := [0, -taskssum];;
gap> ShareSpecialObj(a);;
gap> f := function(q)
> local val;
> MicroSleep(q * 100); atomic readwrite a do val := a[1]; a[1] := val + q; od;
> MicroSleep(q * 1000); atomic readwrite a do val := a[2]; a[2] := val + q; od;
> end;;
gap> l := List([1..tasks], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = List([1..tasks], x -> fail);
true
gap> atomic readwrite a do Print(a = [taskssum,0],"\n"); od;
true
gap> STOP_TEST( "threads.tst", 1 );
#############################################################################
##
#E

