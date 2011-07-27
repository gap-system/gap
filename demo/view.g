BIND_GLOBAL("ORIGINAL_VIEW_OBJ", ViewObj);

ViewSharedObj := function(obj)
  local l;
  l := TRYLOCK(obj);
  ORIGINAL_VIEW_OBJ(obj);
  if l <> fail then
    UNLOCK(l);
  fi;
end;

CustomView := ViewSharedObj;
