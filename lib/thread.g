#############################################################################
##
#W  thread.g                    GAP library                  Reimer Behrends
##
#H  @(#)$Id: thread.g,v 4.50 2010/04/10 14:20:00 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This is a minimal file to provide type information for the new types
##  provided by thread primitives.
##

Revision.thread_g :=
  "@(#)$Id: thread.g,v 4.50 2010/04/10 14:20:00 gap Exp $";


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

AT_THREAD_EXIT_LIST := 0;
MakeThreadLocal("AT_THREAD_EXIT_LIST");

BindGlobal("THREAD_EXIT", function()
  local func;
  if AT_THREAD_EXIT_LIST <> 0 then
    for func in AT_THREAD_EXIT_LIST do
      func();
    od;
  fi;
end);

BindGlobal("AtThreadExit", function(func)
  if AT_THREAD_EXIT_LIST = 0 then
    AT_THREAD_EXIT_LIST := [ func ];
  else
    Add(AT_THREAD_EXIT_LIST, func);
  fi;
end);

BindGlobal("StartHandShake", CreateSyncVar);

BindGlobal("AcknowledgeHandShake", function(syncvar, obj)
  if (IsThreadLocal(obj)) then
    MakeReadOnly(obj);
  fi;
  SyncWrite(syncvar, obj);
  return obj;
end);

BindGlobal("CompleteHandShake", SyncRead);

BindGlobal("FindGVarHolding", function(val)
  local s;
  for s in IDENTS_GVAR() do
    if IsBoundGlobal(s) and IsIdenticalObj(ValueGlobal(s), val) then
      return s;
    fi;
  od;
  return fail;
end);

LAST_INTERRUPT := ShareObj(rec(id := 0));

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

DISABLE_GUARDS := false;
