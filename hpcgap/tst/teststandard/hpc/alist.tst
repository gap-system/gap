#############################################################################
##
#W  alist.tst               GAP tests                       Chris Jefferson
##
##
##
#Y  Copyright (C) 2017
##
gap> START_TEST("alist.tst");
gap> if IsBound(HPCGAP) and not ARCH_IS_WINDOWS() then tasks := 100; else tasks := 10; fi;;
gap> taskssum := (tasks*(tasks+1))/2;;
gap> a := AtomicList([1,1,1,1]);
gap> f := function(job)
> local check;
> check := false;
> while check = false do
>   check := COMPARE_AND_SWAP(a, job[1], job[2], job[3]);
> od;
> return true;
> end;;
gap> joblist := [];;
gap> for j in [1..4] do for i in [1..tasks] do Add(joblist, [j, i, i+1]); od; od;
gap> results := List(joblist, x -> RunTask(f, x));
gap> ForAll(results, TaskResult);
true
gap> ForAll([1..4], x -> a[x] = tasks + 1);
true
gap> a := AtomicList([]);
gap> binder := function(val)
> local i, j, count;
> count := 0;
> while true do
>  for j in [1..4] do
>    if ATOMIC_BIND(a, j, val) then
>      count := count + 1;
>      if count = tasks then
>        return true;
>      fi;
>    fi;
>  od;
> od;
> end;;
gap> unbinder := function(val)
> local i, j, count;
> count := 0;
> while true do
>  for j in [1..4] do
>    if ATOMIC_UNBIND(a, j, val) then
>      count := count + 1;
>      if count = tasks then
>        return true;
>      fi;
>    fi;
>  od;
> od;
> end;
gap> tasklist := [RunTask(binder, 1), RunTask(binder, 2),
>              RunTask(unbinder, 1), RunTask(unbinder, 2)];;
gap> List(tasklist, TaskResult);
[ true, true, true, true ]
gap> a;
[ ,,, ]


gap> STOP_TEST( "alist.tst", 1 );
#############################################################################
##
#E

