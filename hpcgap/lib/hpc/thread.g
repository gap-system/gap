#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Reimer Behrends.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Types and threading primitives for shared memory concurrency.
##


BindGlobal("ThreadFamily", NewFamily("ThreadFamily", IsObject));
BindGlobal("SynchronizationFamily",
    NewFamily("SynchronizationFamily", IsObject));
BindGlobal("AtomicFamily", NewFamily("AtomicFamily", IsObject));
BindGlobal("RegionFamily", NewFamily("DataSpaceFamily", IsObject));

DeclareFilter("IsThread", IsObject and IsInternalRep);
DeclareFilter("IsSemaphore", IsObject and IsInternalRep);
DeclareFilter("IsChannel", IsObject and IsInternalRep);
DeclareFilter("IsBarrier", IsObject and IsInternalRep);
DeclareFilter("IsSyncVar", IsObject and IsInternalRep);
DeclareFilter("IsRegion", IsObject and IsInternalRep);
DeclareFilter("IsAtomicList", IsList and IsInternalRep);
DeclareFilter("IsAtomicRecord", IsRecord and IsInternalRep);
DeclareFilter("IsThreadLocalRecord", IsRecord and IsInternalRep);

BindGlobal("TYPE_THREAD", NewType(ThreadFamily, IsThread));
BindGlobal("TYPE_SEMAPHORE", NewType(SynchronizationFamily, IsSemaphore));
BindGlobal("TYPE_CHANNEL", NewType(SynchronizationFamily, IsChannel));
BindGlobal("TYPE_BARRIER", NewType(SynchronizationFamily, IsBarrier));
BindGlobal("TYPE_SYNCVAR", NewType(SynchronizationFamily, IsSyncVar));
BindGlobal("TYPE_REGION", NewType(RegionFamily, IsRegion));
BindGlobal("TYPE_ALIST", NewType(AtomicFamily, IsAtomicList));
BindGlobal("TYPE_AREC", NewType(AtomicFamily, IsAtomicRecord));
BindGlobal("TYPE_TLREC", NewType(AtomicFamily, IsThreadLocalRecord));

BindGlobal("StartHandShake", CreateSyncVar);

BindGlobal("AcknowledgeHandShake", function(syncvar, obj)
  if (IsThreadLocal(obj)) then
    MakeReadOnlyObj(obj);
  fi;
  SyncWrite(syncvar, obj);
  return obj;
end);

BindGlobal("CompleteHandShake", SyncRead);

BindGlobal("FindAllGVarsHolding", function(val)
  local s, result;
  result := [];
  for s in IDENTS_GVAR() do
    if IsBoundGlobal(s) and IsIdenticalObj(ValueGlobal(s), val) then
      Add(result, s);
    fi;
  od;
  return result;
end);

BindGlobal("FindGVarHolding", function(val)
  local s;
  for s in IDENTS_GVAR() do
    if IsBoundGlobal(s) and IsIdenticalObj(ValueGlobal(s), val) then
      return s;
    fi;
  od;
  return fail;
end);

LAST_INTERRUPT := ShareSpecialObj(rec(id := 0));

BindGlobal("NewInterruptID", function()
  atomic LAST_INTERRUPT do
    if LAST_INTERRUPT.id >= MAX_INTERRUPT then
      Error("Too many different interrupt handlers");
    fi;
    LAST_INTERRUPT.id := LAST_INTERRUPT.id + 1;
    return LAST_INTERRUPT.id;
  od;
end);

BindGlobal("InstallHPCGAPSignalHandling", function()
  if not IsBound(SignalHandlerThread) then
    BindGlobal("SignalHandlerThread", CreateThread(function()
      local handlers;
      handlers := rec(
        SIGINT := DEFAULT_SIGINT_HANDLER,
        SIGCHLD := DEFAULT_SIGCHLD_HANDLER,
        SIGVTALRM := DEFAULT_SIGVTALRM_HANDLER,
        SIGWINCH := DEFAULT_SIGWINCH_HANDLER
      );
      while true do
        SIGWAIT(handlers);
      od;
    end));
  fi;
end);

if IsHPCGAP and not SINGLE_THREAD_STARTUP() then
  InstallHPCGAPSignalHandling();
fi;

#
# LockCounters are per region and per thread counters
# that count how many times a read or write lock
# has been acquired successfully and how many times
# a lock has ben contended.
#
# for regions this means the region lock, for threads
# any lock that the thread might have tried to acquire
#

# Note that these are defined for IsObject, but really
# apply to the region in which the object is located
DeclareOperation("LockCountersEnable", [ IsObject ]);
DeclareOperation("LockCountersDisable", [ IsObject ]);
DeclareOperation("LockCountersReset", [ IsObject ]);
DeclareOperation("LockCountersRead", [ IsObject ]);

InstallMethod(LockCountersEnable,
        "for an object",
        [ IsObject ],
        REGION_COUNTERS_ENABLE );

InstallMethod(LockCountersDisable,
        "for an object",
        [ IsObject ],
        REGION_COUNTERS_DISABLE);

InstallMethod(LockCountersReset,
        "for an object",
        [ IsObject ],
        REGION_COUNTERS_RESET);

InstallMethod(LockCountersRead,
        "for an object",
        [ IsObject ],
  function(r)
    local res;
    res := REGION_COUNTERS_GET(r);
    return rec( count_lock := res[1], count_contended := res[2] );
  end);

DeclareOperation("LockCountersEnable", [ ] );
DeclareOperation("LockCountersDisable", [ ]);
DeclareOperation("LockCountersReset", [ ]);
DeclareOperation("LockCountersRead", [ ]);


InstallMethod(LockCountersEnable,
        "for the current thread",
        [ ],
        THREAD_COUNTERS_ENABLE );

InstallMethod(LockCountersDisable,
        "for the current thread",
        [ ],
        THREAD_COUNTERS_DISABLE);

InstallMethod(LockCountersReset,
        "for the current thread",
        [ ],
        THREAD_COUNTERS_RESET);

InstallMethod(LockCountersRead,
        "for the current thread",
        [ ],
  function()
    local res;

    res := THREAD_COUNTERS_GET();

    return rec( count_lock := res[1], count_contended := res[2] );
  end);
