#
# Tests for functions defined in src/threadapi.c
#
#@local t, t2, region, ch, f, sem, b, sv, old_state, tmp, tmp2
#
#@if IsHPCGAP
gap> START_TEST("kernel/threadapi.tst");

#
# threads
#
gap> CreateThread();
Error, CreateThread: Needs at least one function argument
gap> CreateThread(1);
Error, CreateThread: Needs at least one function argument
gap> CreateThread(x->x);
Error, CreateThread: <func> expects 1 arguments, but got 0
gap> WaitThread(fail);
Error, WaitThread: <thread> must be a thread object (not the value 'fail')
gap> KillThread(fail);
Error, KillThread: <thread> must be a thread object or an integer between 0 an\
d MAX_THREADS - 1 (not the value 'fail')
gap> InterruptThread(fail, fail);
Error, InterruptThread: <thread> must be a thread object or an integer between\
 0 and MAX_THREADS - 1 (not the value 'fail')

#
gap> SetInterruptHandler(fail, fail);
Error, SetInterruptHandler: <handler> must be an integer between 0 and 100 (no\
t the value 'fail')
gap> SetInterruptHandler(0, 0);
Error, SetInterruptHandler: <func> must be a parameterless function or 'fail' \
(not the integer 0)
gap> SetInterruptHandler(0, {a,b}->fail);
Error, SetInterruptHandler: <func> must be a parameterless function or 'fail' \
(not a function)

#
gap> PauseThread(fail);
Error, PauseThread: <thread> must be a thread object or an integer between 0 a\
nd MAX_THREADS - 1 (not the value 'fail')
gap> ResumeThread(fail);
Error, ResumeThread: <thread> must be a thread object or an integer between 0 \
and MAX_THREADS - 1 (not the value 'fail')

# gap> t := CreateThread(function() MicroSleep(100); end);;
# gap> PauseThread(t);
# gap> ResumeThread(t);
# gap> WaitThread(t); # FIXME: sometimes deadlocks

#
# gap> t := CreateThread(function() MicroSleep(100); end);;
# gap> InterruptThread(t, 17);
# gap> WaitThread(t); # FIXME: crashes in pthread_join

#
# gap> t := CreateThread(function() MicroSleep(100); end);;
# gap> KillThread(t);
# gap> WaitThread(t);

#
# region
#
gap> NEW_REGION(0, fail);
Error, NEW_REGION: <name> must be a string or fail (not the integer 0)
gap> NEW_REGION(fail, fail);
Error, NEW_REGION: <prec> must be a small integer (not the value 'fail')
gap> region := NEW_REGION(fail, 23);;
gap> region := NEW_REGION("test region", 42);
<region: test region>
gap> REGION_PRECEDENCE(region);
42
gap> RegionOf(fail);
<region: public region>
gap> RegionOf(region);
<region: test region>
gap> SetRegionName(fail, fail);
Error, SetRegionName: Cannot change name of the public region
gap> SetRegionName(region, "new name");
gap> region;
<region: new name>
gap> ClearRegionName(fail);
Error, ClearRegionName: Cannot change name of the public region
gap> ClearRegionName(region);
gap> RegionName(fail);
"public region"
gap> RegionName(region);
fail

#
# hash locks
#
# FIXME: any way to test (let alone: sensible use) hashlocks?
# gap> f:=function(x) HASH_LOCK(x); HASH_UNLOCK(x); end;;
# gap> f([]); # FIXME: crashes in some situations??
# gap> HASH_SYNCHRONIZED([], function() end);
# gap> HASH_SYNCHRONIZED_SHARED([], function() end);

#
gap> CREATOR_OF(fail);
fail

#
gap> DISABLE_GUARDS(1/2);
Error, DISABLE_GUARDS: <flag> must be a boolean or a small integer (not a rati\
onal)
gap> DISABLE_GUARDS(true);
gap> DISABLE_GUARDS(false);
gap> DISABLE_GUARDS(0);

#
gap> WITH_TARGET_REGION(fail, fail);
Error, WITH_TARGET_REGION: <func> must be a function (not the value 'fail')
gap> WITH_TARGET_REGION(fail, {}->0);
Error, WITH_TARGET_REGION: Requires write access to target region

#
# channels
#
gap> CreateChannel(fail);
Error, CreateChannel: Argument must be capacity of the channel
gap> CreateChannel(0);
Error, CreateChannel: Capacity must be positive
gap> DestroyChannel(fail);
Error, DestroyChannel: <channel> must be a channel (not the value 'fail')
gap> TallyChannel(fail);
Error, TallyChannel: <channel> must be a channel (not the value 'fail')
gap> SendChannel(fail, fail);
Error, SendChannel: <channel> must be a channel (not the value 'fail')
gap> TransmitChannel(fail, fail);
Error, TransmitChannel: <channel> must be a channel (not the value 'fail')
gap> MultiSendChannel(fail, fail);
Error, MultiSendChannel: <channel> must be a channel (not the value 'fail')
gap> MultiTransmitChannel(fail, fail);
Error, MultiTransmitChannel: <channel> must be a channel (not the value 'fail'\
)
gap> TryMultiSendChannel(fail, fail);
Error, TryMultiSendChannel: <channel> must be a channel (not the value 'fail')
gap> TryMultiTransmitChannel(fail, fail);
Error, TryMultiTransmitChannel: <channel> must be a channel (not the value 'fa\
il')
gap> TrySendChannel(fail, fail);
Error, TrySendChannel: <channel> must be a channel (not the value 'fail')
gap> TryTransmitChannel(fail, fail);
Error, TryTransmitChannel: <channel> must be a channel (not the value 'fail')
gap> ReceiveAnyChannel(fail);
Error, ReceiveAnyChannel: Argument list must be channels
gap> ReceiveAnyChannel([]);
Error, ReceiveAnyChannel: Argument list must be channels
gap> ReceiveAnyChannelWithIndex(fail);
Error, ReceiveAnyChannelWithIndex: Argument list must be channels
gap> ReceiveAnyChannelWithIndex([]);
Error, ReceiveAnyChannelWithIndex: Argument list must be channels
gap> MultiReceiveChannel(fail, fail);
Error, MultiReceiveChannel: <channel> must be a channel (not the value 'fail')
gap> InspectChannel(fail);
Error, InspectChannel: <channel> must be a channel (not the value 'fail')
gap> TryReceiveChannel(fail, fail);
Error, TryReceiveChannel: <channel> must be a channel (not the value 'fail')

#
# semaphores
#
gap> CreateSemaphore(fail);
Error, CreateSemaphore: Argument must be initial count
gap> CreateSemaphore(-1);
Error, CreateSemaphore: Initial count must be non-negative
gap> CreateSemaphore(fail, fail);
Error, CreateSemaphore: Function takes up to two arguments
gap> SignalSemaphore(fail);
Error, SignalSemaphore: <semaphore> must be a semaphore (not the value 'fail')
gap> WaitSemaphore(fail);
Error, WaitSemaphore: <semaphore> must be a semaphore (not the value 'fail')
gap> TryWaitSemaphore(fail);
Error, TryWaitSemaphore: <semaphore> must be a semaphore (not the value 'fail'\
)

#
gap> sem := CreateSemaphore(0);
<semaphore with count = 0>
gap> TryWaitSemaphore(sem);
false
gap> SignalSemaphore(sem);
gap> sem;
<semaphore with count = 1>
gap> TryWaitSemaphore(sem);
true
gap> sem;
<semaphore with count = 0>

#
# barriers
#
gap> b := CreateBarrier();
<barrier with 0 of 0 threads arrived>
gap> StartBarrier(fail, fail);
Error, StartBarrier: <barrier> must be a barrier (not the value 'fail')
gap> StartBarrier(b, fail);
Error, StartBarrier: <count> must be a small integer (not the value 'fail')
gap> WaitBarrier(fail);
Error, WaitBarrier: <barrier> must be a barrier (not the value 'fail')

#
gap> StartBarrier(b, 2);
gap> b;
<barrier with 0 of 2 threads arrived>
gap> tmp:=false;;
gap> t:=CreateThread(function() WaitBarrier(b); repeat MicroSleep(10); until tmp; end);;
gap> WaitBarrier(b);
gap> tmp:=true;;
gap> WaitThread(t);
gap> b;
<barrier with 0 of 0 threads arrived>

#
# sync vars
#
gap> sv := CreateSyncVar();
<uninitialized syncvar>
gap> SyncWrite(fail, fail);
Error, SyncWrite: <syncvar> must be a synchronization variable (not the value \
'fail')
gap> SyncWrite(sv, 42);
gap> sv;
<initialized syncvar>
gap> SyncWrite(sv, 23);
Error, SyncWrite: Variable already has a value
gap> SyncTryWrite(fail, fail);
Error, SyncTryWrite: <syncvar> must be a synchronization variable (not the val\
ue 'fail')
gap> SyncTryWrite(sv, 666);
false
gap> SyncRead(fail);
Error, SyncRead: <syncvar> must be a synchronization variable (not the value '\
fail')
gap> SyncRead(sv);
42
gap> SyncIsBound(fail);
Error, SyncIsBound: <syncvar> must be a synchronization variable (not the valu\
e 'fail')
gap> SyncIsBound(sv);
true

#
gap> sv := CreateSyncVar();
<uninitialized syncvar>
gap> SyncTryWrite(sv, 1984);
true
gap> SyncTryWrite(sv, 0);
false
gap> SyncRead(sv);
1984

#
# locks
#
gap> IS_LOCKED(fail);
0
gap> LOCK();
0
gap> LOCK(fail);
0
gap> DO_LOCK();
0
gap> DO_LOCK(fail);
0
gap> WRITE_LOCK(fail);
0
gap> WRITE_LOCK(fail);
0
gap> READ_LOCK(fail);
0
gap> READ_LOCK(fail);
0
gap> TRYLOCK();
0
gap> TRYLOCK(fail);
fail
gap> UNLOCK(fail);
Error, UNLOCK: <sp> must be a non-negative small integer (not the value 'fail'\
)
gap> CURRENT_LOCKS();
[  ]

#
# misc
#
gap> REFINE_TYPE(fail);
fail
gap> MAKE_PUBLIC(fail);
fail
gap> MAKE_PUBLIC_NORECURSE(fail);
Error, MAKE_PUBLIC_NORECURSE: Thread does not have exclusive access to objects
gap> #MAKE_PUBLIC_NORECURSE(1);  # FIXME: crashes
gap> FORCE_MAKE_PUBLIC(fail);
fail
gap> FORCE_MAKE_PUBLIC(0);
Error, FORCE_MAKE_PUBLIC: Argument is a small integer or finite-field element

#
gap> SHARE_NORECURSE(fail, fail, fail);
Error, SHARE_NORECURSE: <prec> must be a small integer (not the value 'fail')
gap> ADOPT_NORECURSE(fail);
Error, ADOPT_NORECURSE: Thread does not have exclusive access to objects
gap> MIGRATE_NORECURSE(fail, fail);
Error, MIGRATE_NORECURSE: Thread does not have exclusive access to target regi\
on

#
gap> REACHABLE(42);
[  ]
gap> CLONE_REACHABLE(42);
42
gap> CLONE_DELIMITED(42);
42

#
gap> SHARE(fail, fail, fail);
Error, SHARE: <prec> must be a small integer (not the value 'fail')
gap> SHARE_RAW(fail, fail, fail);
Error, SHARE_RAW: <prec> must be a small integer (not the value 'fail')
gap> ADOPT(fail);
fail
gap> MIGRATE(fail, fail);
Error, MIGRATE: Thread does not have exclusive access to target region
gap> MIGRATE_RAW(fail, fail);
Error, MIGRATE_RAW: Thread does not have exclusive access to target region

#
gap> MakeThreadLocal(fail);
Error, MakeThreadLocal: <var> must be a variable name (not the value 'fail')
gap> MakeThreadLocal("foo bar dummy name");
gap> MakeReadOnlyObj(fail);
fail
gap> MakeReadOnlyRaw(fail);
fail
gap> MakeReadOnlySingleObj(fail);
fail
gap> IsReadOnlyObj(fail);
false

#gap> ENABLE_AUTO_RETYPING(); # FIXME: disabled because there is no way to turn this off again

#
gap> ORDERED_READ(42);
42
gap> ORDERED_WRITE(42);
42

#
gap> DEFAULT_SIGINT_HANDLER();
gap> DEFAULT_SIGVTALRM_HANDLER();
gap> DEFAULT_SIGWINCH_HANDLER();
gap> SIGWAIT(fail);
Error, SIGWAIT: Argument must be a record
gap> PERIODIC_CHECK(fail, fail);
Error, PERIODIC_CHECK: <count> must be a non-negative small integer (not the v\
alue 'fail')
gap> PERIODIC_CHECK(1, fail);
Error, PERIODIC_CHECK: <func> must be a function (not the value 'fail')

#
gap> region := 0;
0
gap> REGION_COUNTERS_ENABLE(region);
Error, REGION_COUNTERS_ENABLE: Cannot enable counters for this region
gap> REGION_COUNTERS_DISABLE(region);
Error, REGION_COUNTERS_DISABLE: Cannot disable counters for this region
gap> REGION_COUNTERS_GET_STATE(region);
Error, REGION_COUNTERS_GET_STATE: Cannot get counters for this region
gap> REGION_COUNTERS_GET(region);
Error, REGION_COUNTERS_GET: Cannot get counters for this region
gap> REGION_COUNTERS_RESET(region);
Error, REGION_COUNTERS_RESET: Cannot reset counters for this region
gap> region := NEW_REGION("yet another test region", 17);
<region: yet another test region>
gap> REGION_COUNTERS_ENABLE(region);
gap> REGION_COUNTERS_DISABLE(region);
gap> REGION_COUNTERS_GET_STATE(region);
0
gap> REGION_COUNTERS_GET(region);
[ 0, 0 ]
gap> REGION_COUNTERS_RESET(region);

#
gap> old_state := THREAD_COUNTERS_GET_STATE();;
gap> THREAD_COUNTERS_ENABLE();
gap> THREAD_COUNTERS_GET_STATE();
1
gap> THREAD_COUNTERS_DISABLE();
gap> THREAD_COUNTERS_GET_STATE();
0
gap> THREAD_COUNTERS_RESET();
gap> THREAD_COUNTERS_GET();
[ 0, 0 ]
gap> if old_state = 1 then THREAD_COUNTERS_ENABLE(); else THREAD_COUNTERS_DISABLE(); fi;

#
gap> STOP_TEST("kernel/threadapi.tst", 1);
#@fi
