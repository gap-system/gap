BIND_GLOBAL("ORIGINAL_VIEW_OBJ", ViewObj);

ViewSharedObj := function(obj)
  local copy;
  DISABLE_GUARDS := true;
  copy := DEEP_COPY_OBJ(obj);
  DISABLE_GUARDS := false;
  ORIGINAL_VIEW_OBJ(copy);
end;

CustomView := ViewSharedObj;
