#############################################################################
##
#W  threads.tst               GAP tests                       Chris Jefferson
##
##
#Y  Copyright (C) 2017
##
gap> START_TEST("threads.tst");
gap> f := function(val) local x; MicroSleep(10); x := val; MicroSleep(10); return x; end;;
gap> l := List([1..10000], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = [1..10000];
true
gap> a := AtomicList([0]);
[ 0 ]
gap> f := function(val) local x; MicroSleep(10); a[val] := val; MicroSleep(10); return val; end;;
gap> l := List([1..10000], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = [1..10000];
true
gap> ForAll([1..10000], i -> a[i] = i);
true
gap> a := FixedAtomicList(10000, 0);;
gap> f := function(val) local x; MicroSleep(10); a[val] := val; MicroSleep(10); return val; end;;
gap> l := List([1..10000], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = [1..10000];
true
gap> ForAll([1..10000], i -> a[i] = i);
true
gap> a := FixedAtomicList(2, 0);;
gap> a[2] := -50005000;;
gap> f := function(val)
> MicroSleep(10); ATOMIC_ADDITION(a, 1, val);
> MicroSleep(10); ATOMIC_ADDITION(a, 2, val);
> end;;
gap> l := List([1..10000], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = List([1..10000], x -> fail);
true
gap> a;
[ 50005000, 0 ]
gap> a := [0, -50005000];;
gap> ShareSpecialObj(a);;
gap> f := function(q)
> local val;
> MicroSleep(10); atomic readwrite a do val := a[1]; a[1] := val + q; od;
> MicroSleep(10); atomic readwrite a do val := a[2]; a[2] := val + q; od;
> end;;
gap> l := List([1..10000], x -> RunTask(f, x));;
gap> ret := List(l, TaskResult);;
gap> ret = List([1..10000], x -> fail);
true
gap> atomic readwrite a do Print(a,"\n"); od;
[ 50005000, 0 ]
gap> STOP_TEST( "threads.tst", 1 );
#############################################################################
##
#E

