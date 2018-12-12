#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

BIND_GLOBAL("ORIGINAL_VIEW_OBJ", ViewObj);

BindGlobal("ViewSharedObj", function(obj)
  local l;
  l := TRYLOCK(obj);
  ORIGINAL_VIEW_OBJ(obj);
  if l <> fail then
    UNLOCK(l);
  fi;
end);

BindGlobal("ViewShared", function(obj)
  ViewSharedObj(obj);
  Print("\n");
end);

BindGlobal("UNSAFE_VIEW_OBJ", function(obj)
  local copy;
  DISABLE_GUARDS(2);
  copy := DEEP_COPY_OBJ(obj);
  DISABLE_GUARDS(0);
  ORIGINAL_VIEW_OBJ(copy);
end);

BindGlobal("UNSAFE_VIEW", function(obj)
  UNSAFE_VIEW_OBJ(obj);
  Print("\n");
end);

