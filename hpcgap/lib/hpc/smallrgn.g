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
##  This file introduces support for regions for small objects. Multiple
##  small objects can share the same region at the potential cost of
##  increased contention if they are modified a lot, but at reduced memory
##  overhead if they are primarily accessed in a read-only fashion.
##
##  Atomic statements using small regions must not be nested.

BIND_GLOBAL("SMALL_OBJ_REGION_NUM", 256);
BIND_GLOBAL("SMALL_OBJ_REGION_INC", 19);
BIND_GLOBAL("SMALL_OBJ_REGION_LIST",
    MakeWriteOnceAtomic(FixedAtomicList(SMALL_OBJ_REGION_NUM)));

CURRENT_SMALL_OBJ_REGION := 0;
MakeThreadLocal("CURRENT_SMALL_OBJ_REGION");

BIND_GLOBAL("PICK_SMALL_OBJ_REGION", function()
  local region, name;
  if CURRENT_SMALL_OBJ_REGION = 0 then
    CURRENT_SMALL_OBJ_REGION := ThreadID(CurrentThread()) mod
      SMALL_OBJ_REGION_NUM + 1;
  fi;
  region := CURRENT_SMALL_OBJ_REGION;
  CURRENT_SMALL_OBJ_REGION := (region + SMALL_OBJ_REGION_INC - 1)
      mod SMALL_OBJ_REGION_NUM + 1;
  if not IsBound(SMALL_OBJ_REGION_LIST[region]) then
    name := "small region #";
    Append(name, String(region));
    SMALL_OBJ_REGION_LIST[region] := NewSpecialRegion(name);
  fi;
  return SMALL_OBJ_REGION_LIST[region];
end);

BIND_GLOBAL("ShareSmallObj", function(obj)
  local region;
  region := PICK_SMALL_OBJ_REGION();
  atomic region do
    return MigrateObj(obj, region);
  od;
end);

BIND_GLOBAL("ShareSingleSmallObj", function(obj)
  local region;
  region := PICK_SMALL_OBJ_REGION();
  atomic region do
    return MigrateSingleObj(obj, region);
  od;
end);
