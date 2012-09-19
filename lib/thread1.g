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

ShareObj := SHARE;
ShareSingleObj := SHARE_NORECURSE;
MigrateObj := MIGRATE;
MigrateSingleObj := MIGRATE_NORECURSE;
AdoptObj := ADOPT;
AdoptSingleObj := ADOPT_NORECURSE;
CopyRegion := CLONE_REACHABLE;
RegionSubObjects := REACHABLE;

ShareAutoReadObj := function(obj)
  SHARE(obj);
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

CopyFromRegion := CopyRegion;

CopyToRegion := atomic function(readonly obj, target)
  if IsPublic(obj) then
    return obj;
  else
    return MigrateObj(CopyRegion(obj), target);
  fi;
end;

MakeThreadLocal("~");

HaveMultiThreadedUI := false;
