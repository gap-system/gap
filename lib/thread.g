#############################################################################
##
#W  thread.g                    GAP library                  Reimer Behrends
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
DeclareFilter("IsAtomicList", IsObject and IsInternalRep);
DeclareFilter("IsAtomicRecord", IsObject and IsInternalRep);
DeclareFilter("IsThreadLocalRecord", IsObject and IsInternalRep);

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
    MakeReadOnly(obj);
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

DeclareAttribute( "RecNames", IsAtomicRecord);
InstallMethod( RecNames,
    "for an atomic record in internal representation",
    [ IsAtomicRecord and IsInternalRep],
    REC_NAMES );

if IsBound(ZmqSocket) then
  ReadLib("zmq.g");
fi;

CreateThread(function()
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
end);

DeclareOperation("LockCountersEnable", [ IsRegion ]);
DeclareOperation("LockCountersDisable", [ IsRegion ]);
DeclareOperation("LockCountersReset", [ IsRegion ]);
DeclareOperation("LockCountersRead", [ IsRegion ]);

InstallMethod(LockCountersEnable,
        "for a region",
        [ IsRegion ],
        REGION_COUNTERS_ENABLE );

InstallMethod(LockCountersDisable,
        "for a region",
        [ IsRegion ],
        REGION_COUNTERS_DISABLE);

InstallMethod(LockCountersReset,
        "for a region",
        [ IsRegion ],
        REGION_COUNTERS_RESET);

InstallMethod(LockCountersRead,
        "for a region",
        [ IsRegion ],
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
