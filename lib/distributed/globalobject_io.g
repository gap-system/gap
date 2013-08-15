InstallMethod ( IO_Pickle, "for global object handle",
        [ IsFile, IsGlobalObjectHandle ],
        atomic function (f,readonly han)
  if IO_Write (f, "GLOH") = fail then return IO_Error; fi;
  if IO_Pickle(f, han!.pe) = IO_Error then return IO_Error; fi;
  if IO_Pickle(f, han!.owner) = IO_Error then return IO_Error; fi;
  if IO_Pickle(f, han!.localId) = IO_Error then return IO_Error; fi;
  if IO_Pickle(f, han!.control.immediate) = IO_Error then return IO_Error; fi;
  if IO_Pickle(f, han!.control.accessType) = IO_Error then return IO_Error; fi;
  if IO_Pickle(f, han!.control.globalCount) = IO_Error then return IO_Error; fi;
  return IO_OK;
end);

IO_Unpicklers.GLOH :=
  function(f)
  local handle, pe, owner, localId, immediate, accessType, globalCount;
  pe := IO_Unpickle(f);
  owner := IO_Unpickle(f);
  localId := IO_Unpickle(f);
  immediate := IO_Unpickle(f);
  accessType := IO_Unpickle(f);
  globalCount := IO_Unpickle(f);
  handle := GlobalObjHandles.CreateHandleFromMsg
            (pe, owner, localId, immediate, accessType);
  handle!.globalCount := globalCount;
  return handle;
end;

InstallSerializer ("GloObH", [IsGlobalObjectHandle],
        atomic function(readonly handle)
  return [0, "GlObH", handle!.pe, handle!.owner, handle!.localId, handle!.control.immediate,
          handle!.control.accessType,handle!.control.globalCount];
end);

InstallDeserializer ("GlObH", function (pe, owner, localId, immediate, accessType, globalCount)
  local handle;
  handle := GlobalObjHandles.CreateHandleFromMsg
            (pe, owner, localId, immediate, accessType);
  handle!.globalCount := globalCount;
  return handle;
end);
