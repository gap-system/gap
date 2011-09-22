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


BindGlobal("SynchronizationFamily",
    NewFamily("SynchronizationFamily", IsObject));
BindGlobal("AtomicFamily", NewFamily("AtomicFamily", IsObject));
BindGlobal("RegionFamily", NewFamily("DataSpaceFamily", IsObject));

DeclareFilter("IsChannel", IsObject);
DeclareFilter("IsBarrier", IsObject);
DeclareFilter("IsSyncVar", IsObject);
DeclareFilter("IsRegion", IsObject);
DeclareFilter("IsAtomicList", IsObject);
DeclareFilter("IsAtomicRecord", IsObject);
DeclareFilter("IsThreadLocalRecord", IsObject);

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
