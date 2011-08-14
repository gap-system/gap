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

Revision.thread1_g :=
  "@(#)$Id: thread1.g,v 4.50 2010/04/10 14:20:00 gap Exp $";


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
RegionOf := DataSpace;

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

NewRegion := function()
  return RegionOf(ShareObj([]));
end;
