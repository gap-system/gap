#############################################################################
##
#W  thread1.g                    GAP library                 Reimer Behrends
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file provides the necessary thread initialization code code needed
##  early in GAP's initialization process. The rest can be found in thread.g.
##


# Convenience aliases

IsLockable := IsShared;
BIND_GLOBAL("ApplicationRegion", 30000);
BIND_GLOBAL("LibraryRegion", 20000);
BIND_GLOBAL("KernelRegion", 10000);
BIND_GLOBAL("InternalRegion", 0);

ShareObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE(arg[1], arg[2], ApplicationRegion);
  else
    return SHARE(arg[1], fail, ApplicationRegion);
  fi;
end;

ShareLibraryObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE(arg[1], arg[2], LibraryRegion);
  else
    return SHARE(arg[1], fail, LibraryRegion);
  fi;
end;

ShareKernelObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE(arg[1], arg[2], KernelRegion);
  else
    return SHARE(arg[1], fail, KernelRegion);
  fi;
end;

ShareInternalObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE(arg[1], arg[2], InternalRegion);
  else
    return SHARE(arg[1], fail, InternalRegion);
  fi;
end;

ShareSingleObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE_NORECURSE(arg[1], arg[2], ApplicationRegion);
  else
    return SHARE_NORECURSE(arg[1], fail, ApplicationRegion);
  fi;
end;

ShareSingleLibraryObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE_NORECURSE(arg[1], arg[2], LibraryRegion);
  else
    return SHARE_NORECURSE(arg[1], fail, LibraryRegion);
  fi;
end;

ShareSingleKernelObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE_NORECURSE(arg[1], arg[2], KernelRegion);
  else
    return SHARE_NORECURSE(arg[1], fail, KernelRegion);
  fi;
end;

ShareSingleInternalObj := function(arg)
  if IsBound(arg[2]) then
    return SHARE_NORECURSE(arg[1], arg[2], InternalRegion);
  else
    return SHARE_NORECURSE(arg[1], fail, InternalRegion);
  fi;
end;

MigrateObj := MIGRATE;
MigrateSingleObj := MIGRATE_NORECURSE;
AdoptObj := ADOPT;
AdoptSingleObj := ADOPT_NORECURSE;
CopyRegion := CLONE_REACHABLE;
RegionSubObjects := REACHABLE;

NewRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], ApplicationRegion);
  else
    return NEW_REGION(fail, ApplicationRegion);
  fi;
end;

NewLibraryRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], LibraryRegion);
  else
    return NEW_REGION(fail, LibraryRegion);
  fi;
end;

NewKernelRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], KernelRegion);
  else
    return NEW_REGION(fail, KernelRegion);
  fi;
end;

NewInternalRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], InternalRegion);
  else
    return NEW_REGION(fail, InternalRegion);
  fi;
end;

ShareAutoReadObj := function(obj)
  SHARE(obj, fail, InternalRegion);
  SetAutoLockRegion(obj, true);
  return obj;
end;

AutoReadLock := function(obj)
  SetAutoLockRegion(obj, true);
  return obj;
end;

NewAutoReadRegion := function(arg)
  local region;
  if LEN_LIST(arg) = 0 then
    region := NewRegion();
  else
    region := NewRegion(arg[1]);
  fi;
  SetAutoLockRegion(region, true);
  return region;
end;

LockAndMigrateObj := function(obj, target)
  local lock;
  if IsShared(target) and not HaveWriteAccess(target) then
    lock := LOCK(target);
    MIGRATE(obj, target);
    UNLOCK(lock);
  else
    MIGRATE(obj, target);
  fi;
  return obj;
end;

LockAndAdoptObj := function(obj)
  local lock;
  if IsShared(obj) and not HaveWriteAccess(obj) then
    lock := LOCK(obj);
    ADOPT(obj);
    UNLOCK(lock);
  else
    ADOPT(obj);
  fi;
  return obj;
end;

IncorporateObj := function(target, index, value)
  atomic value do
    if IS_PLIST_REP(target) then
      target[index] := MigrateObj(value, target);
    elif IS_REC(target) then
      target.(index) := MigrateObj(value, target);
    else
      Error("IncorporateObj: target must be plain list or record");
    fi;
  od;
end;

AtomicIncorporateObj := function(target, index, value)
  atomic target, value do
    if IS_PLIST_REP(target) then
      target[index] := MigrateObj(value, target);
    elif IS_REC(target) then
      target.(index) := MigrateObj(value, target);
    else
      Error("IncorporateObj: target must be plain list or record");
    fi;
  od;
end;

CopyFromRegion := CopyRegion;

CopyToRegion := atomic function(readonly obj, target)
  if IsPublic(obj) then
    return obj;
  else
    return MigrateObj(CopyRegion(obj), target);
  fi;
end;

AT_THREAD_EXIT_LIST := 0;
MakeThreadLocal("AT_THREAD_EXIT_LIST");

BIND_GLOBAL("THREAD_EXIT", function()
  local func;
  if AT_THREAD_EXIT_LIST <> 0 then
    for func in AT_THREAD_EXIT_LIST do
      func();
    od;
  fi;
end);

BIND_GLOBAL("AtThreadExit", function(func)
  if AT_THREAD_EXIT_LIST = 0 then
    AT_THREAD_EXIT_LIST := [ func ];
  else
    ADD_LIST(AT_THREAD_EXIT_LIST, func);
  fi;
end);

AT_THREAD_INIT_LIST := MakeWriteOnceAtomic([]);

BIND_GLOBAL("AtThreadInit", function(func)
  ADD_LIST(AT_THREAD_INIT_LIST, func);
end);

BIND_GLOBAL("THREAD_INIT", function()
  local func;
  for func in AT_THREAD_INIT_LIST do
    func();
  od;
end);

MakeThreadLocal("~");

HaveMultiThreadedUI := false;
