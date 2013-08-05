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

# Global variable to show that we're using HPCGAP.

BIND_GLOBAL("HPCGAP", true);


# Convenience aliases

IsLockable := IsShared;
BIND_GLOBAL("REGION_APP_PREC", 30000);
BIND_GLOBAL("REGION_LIBRARY_PREC", 20000);
BIND_GLOBAL("REGION_KERNEL_PREC", 10000);
BIND_GLOBAL("REGION_INTERNAL_PREC", 0);
BIND_GLOBAL("REGION_NO_PREC", -1);

ShareObjWithPriority := function(arg, priority)
  local name;
  if IsBound(arg[2]) then
    name := arg[2];
    if not HaveReadAccess(name) then
      Error("Cannot access region name");
    fi;
    name := IMMUTABLE_COPY_OBJ(name);
    return SHARE(arg[1], name, priority);
  else
    return SHARE(arg[1], fail, priority);
  fi;
end;

ShareObj := function(arg)
  return ShareObjWithPriority(arg, REGION_APP_PREC);
end;

ShareLibraryObj := function(arg)
  return ShareObjWithPriority(arg, REGION_LIBRARY_PREC);
end;

ShareKernelObj := function(arg)
  return ShareObjWithPriority(arg, REGION_KERNEL_PREC);
end;

ShareInternalObj := function(arg)
  return ShareObjWithPriority(arg, REGION_INTERNAL_PREC);
end;

ShareSpecialObj := function(arg)
  return ShareObjWithPriority(arg, REGION_NO_PREC);
end;

ShareSingleObjWithPriority := function(arg, priority)
  local name;
  if IsBound(arg[2]) then
    name := arg[2];
    if not HaveReadAccess(name) then
      Error("Cannot access region name");
    fi;
    name := IMMUTABLE_COPY_OBJ(name);
    return SHARE_NORECURSE(arg[1], name, priority);
  else
    return SHARE_NORECURSE(arg[1], fail, priority);
  fi;
end;

ShareSingleObj := function(arg)
  return ShareSingleObjWithPriority(arg, REGION_APP_PREC);
end;

ShareSingleLibraryObj := function(arg)
  return ShareSingleObjWithPriority(arg, REGION_LIBRARY_PREC);
end;

ShareSingleKernelObj := function(arg)
  return ShareSingleObjWithPriority(arg, REGION_KERNEL_PREC);
end;

ShareSingleInternalObj := function(arg)
  return ShareSingleObjWithPriority(arg, REGION_INTERNAL_PREC);
end;

ShareSingleSpecialObj := function(arg)
  return ShareSingleObjWithPriority(arg, REGION_NO_PREC);
end;

MigrateObj := MIGRATE;
MigrateSingleObj := MIGRATE_NORECURSE;
AdoptObj := ADOPT;
AdoptSingleObj := ADOPT_NORECURSE;
CopyRegion := CLONE_REACHABLE;
RegionSubObjects := REACHABLE;

NewRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], REGION_APP_PREC);
  else
    return NEW_REGION(fail, REGION_APP_PREC);
  fi;
end;

NewLibraryRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], REGION_LIBRARY_PREC);
  else
    return NEW_REGION(fail, REGION_LIBRARY_PREC);
  fi;
end;

NewKernelRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], REGION_KERNEL_PREC);
  else
    return NEW_REGION(fail, REGION_KERNEL_PREC);
  fi;
end;

NewInternalRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], REGION_INTERNAL_PREC);
  else
    return NEW_REGION(fail, REGION_INTERNAL_PREC);
  fi;
end;

NewSpecialRegion := function(arg)
  if IsBound(arg[1]) then
    return NEW_REGION(arg[1], REGION_NO_PREC);
  else
    return NEW_REGION(fail, REGION_NO_PREC);
  fi;
end;

ShareAutoReadObj := function(obj)
  SHARE(obj, fail, REGION_INTERNAL_PREC);
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
