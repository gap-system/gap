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
##  This file provides the necessary thread initialization code code needed
##  early in GAP's initialization process. The rest can be found in thread.g.
##


# Convenience aliases

IsLockable := IsShared;
BIND_GLOBAL("REGION_APP_PREC", 30000);
BIND_GLOBAL("REGION_LIBRARY_PREC", 20000);
BIND_GLOBAL("REGION_KERNEL_PREC", 10000);
BIND_GLOBAL("REGION_INTERNAL_PREC", 0);
BIND_GLOBAL("REGION_NO_PREC", -1);

BIND_GLOBAL("RegionPrecedence", REGION_PRECEDENCE);

ShareObjWithPrecedence := function(args, precedence)
  local name, adj;
  if precedence > 0 and LEN_LIST(args) > 1 and IS_INT(args[LEN_LIST(args)]) then
    adj := REM_LIST(args);
    if adj < -1000 or adj > 1000 then
      Error("Precedence adjustment must be between -1000 and 1000");
      adj := 0;
    fi;
    precedence := precedence + adj;
  fi;
  if IsBound(args[2]) then
    name := args[2];
    if not HaveReadAccess(name) then
      Error("Cannot access region name");
      name := fail;
    fi;
    name := IMMUTABLE_COPY_OBJ(name);
    return SHARE(args[1], name, precedence);
  else
    return SHARE(args[1], fail, precedence);
  fi;
end;

ShareObj := function(arg)
  return ShareObjWithPrecedence(arg, REGION_APP_PREC);
end;

ShareUserObj := function(arg)
  return ShareObjWithPrecedence(arg, REGION_APP_PREC);
end;

ShareLibraryObj := function(arg)
  return ShareObjWithPrecedence(arg, REGION_LIBRARY_PREC);
end;

ShareKernelObj := function(arg)
  return ShareObjWithPrecedence(arg, REGION_KERNEL_PREC);
end;

ShareInternalObj := function(arg)
  return ShareObjWithPrecedence(arg, REGION_INTERNAL_PREC);
end;

ShareSpecialObj := function(arg)
  return ShareObjWithPrecedence(arg, REGION_NO_PREC);
end;

ShareSingleObjWithPrecedence := function(args, precedence)
  local name, adj;
  if precedence > 0 and LEN_LIST(args) > 1 and IS_INT(args[LEN_LIST(args)]) then
    adj := REM_LIST(args);
    if adj < -1000 or adj > 1000 then
      Error("Precedence adjustment must be between -1000 and 1000");
      adj := 0;
    fi;
    precedence := precedence + adj;
  fi;
  if IsBound(args[2]) then
    name := args[2];
    if not HaveReadAccess(name) then
      Error("Cannot access region name");
    fi;
    name := IMMUTABLE_COPY_OBJ(name);
    return SHARE_NORECURSE(args[1], name, precedence);
  else
    return SHARE_NORECURSE(args[1], fail, precedence);
  fi;
end;

ShareSingleObj := function(arg)
  return ShareSingleObjWithPrecedence(arg, REGION_APP_PREC);
end;

ShareSingleLibraryObj := function(arg)
  return ShareSingleObjWithPrecedence(arg, REGION_LIBRARY_PREC);
end;

ShareSingleKernelObj := function(arg)
  return ShareSingleObjWithPrecedence(arg, REGION_KERNEL_PREC);
end;

ShareSingleInternalObj := function(arg)
  return ShareSingleObjWithPrecedence(arg, REGION_INTERNAL_PREC);
end;

ShareSingleSpecialObj := function(arg)
  return ShareSingleObjWithPrecedence(arg, REGION_NO_PREC);
end;

MigrateObj := MIGRATE;
MigrateSingleObj := MIGRATE_NORECURSE;
AdoptObj := ADOPT;
AdoptSingleObj := ADOPT_NORECURSE;
CopyRegion := CLONE_REACHABLE;
RegionSubObjects := REACHABLE;

NewRegionWithPrecedence := function(args, precedence)
  local adj;
  if precedence > 0 and LEN_LIST(args) > 0 and IS_INT(args[LEN_LIST(args)]) then
    adj := REM_LIST(args);
    if adj < -1000 or adj > 1000 then
      Error("Precedence adjustment must be between -1000 and 1000");
      adj := 0;
    fi;
    precedence := precedence + adj;
  fi;
  if IsBound(args[1]) then
    return NEW_REGION(args[1], precedence);
  else
    return NEW_REGION(fail, precedence);
  fi;
end;

NewRegion := function(arg)
  return NewRegionWithPrecedence(arg, REGION_APP_PREC);
end;

NewLibraryRegion := function(arg)
  return NewRegionWithPrecedence(arg, REGION_LIBRARY_PREC);
end;

NewKernelRegion := function(arg)
  return NewRegionWithPrecedence(arg, REGION_KERNEL_PREC);
end;

NewInternalRegion := function(arg)
  return NewRegionWithPrecedence(arg, REGION_INTERNAL_PREC);
end;

NewSpecialRegion := function(arg)
  return NewRegionWithPrecedence(arg, REGION_NO_PREC);
end;

LockAndMigrateObj := function(obj, target)
  if IsShared(target) and not HaveWriteAccess(target) then
    atomic target do
      MIGRATE(obj, target);
    od;
  else
    MIGRATE(obj, target);
  fi;
  return obj;
end;

LockAndAdoptObj := function(obj)
  local lock;
  if IsShared(obj) and not HaveWriteAccess(obj) then
    lock := WRITE_LOCK(obj);
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
MakeThreadLocal("last");
MakeThreadLocal("last2");
MakeThreadLocal("last3");
MakeThreadLocal("time");


HaveMultiThreadedUI := false;
