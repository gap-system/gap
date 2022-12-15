#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

# placeholder for helper functions that we don't want to expose
GlobalObjHandles := AtomicRecord ( rec () );

# the map of handles to the objects that the pe owns. used to prevent garbage collection
# of handles and its associated objects
HandlesMap := ShareSpecialObj ([ [], [] ]);

# the map of global addresses to local addresses. used for handles that reside on
# other nodes
GAMap := ShareSpecialObj ( [ [], [] ] );

# the map of tasks to the handles that will hold their results
TaskResultHandles := ShareSpecialObj ( [ [], [] ]);

# the list of handles that a thread has opened.
# used for testing whether the thread has access to a handle it is trying to use
MyHandles := [ [], [] ];
MakeThreadLocal("MyHandles");

# access types for handles. basically, just a list of constants
BindGlobal ("ACCESS_TYPES", MakeReadOnlyObj ( rec (
        READ_ONLY := 1,
        READ_WRITE := 2,
        VOLATILE := 3 )));

# types of non-blocking requests with handles
BindGlobal ("REQUEST_TYPES", MakeReadOnlyObj( rec (
        GET_OBJ := 1,
        CLONE_OBJ := 2,
        PULL_OBJ := 3,
        BLOCKED_FETCH := 4,
        PUSH_OBJ := 5,
        COPY_OBJ := 6,
        ACK := 7)));

DeclareRepresentation( "IsGlobalObjectHandleRep",
                       IsNonAtomicComponentObjectRep,
        ["pe", "localId", "owner", "accessType", "immediate", "obj", "control"] );

GlobalObjectHandleDefaultType :=
  NewType( GlobalObjectHandlesFamily,
           IsGlobalObjectHandleRep and IsGlobalObjectHandle);

InstallMethod (ViewObj, "for global object handles",
        [IsGlobalObjectHandleRep and IsGlobalObjectHandle],
        function (obj)
  local accessType;
  if obj!.control.accessType = ACCESS_TYPES.READ_ONLY then
    accessType := "ro";
  elif obj!.control.accessType = ACCESS_TYPES.READ_WRITE then
    accessType := "rw";
  else
    accessType := "vol";
  fi;
  Print ("< PE=", obj!.pe,", ID=",obj!.localId,", OW=", obj!.owner, ", AC=",accessType,">\n");
  Print ("<control data : REQ=", obj!.control.requested, ", HO=", obj!.control.haveObject, ", BL=",
         obj!.control.blockedOnHandle, ", LC=",obj!.control.localCount,
         ", GC=",obj!.control.globalCount,">\n");
end);


DoPushObj := fail;
ReadLib ("distributed/globalobject_messages.g");
ReadLib ("distributed/globalobject_io.g");

#################################################################################
# functions that deal with requests (created via calls to <...>NonBlocking
# functions)
InstallGlobalFunction (RequestCompleted, atomic function (readonly request)
  return request.completed;
end);

InstallGlobalFunction (WaitRequest, function (request)
  local p;
  p := LOCK (request);
  if request.completed then
    return;
  else
    if not IsBound(request.blockedOnRequest) then
      request.blockedOnRequest := MigrateObj ([], request);
    fi;
    Add (request.blockedOnRequest, threadId);
    UNLOCK(p);
    Tasks.BlockWorkerThread();
  fi;
end);

InstallGlobalFunction (WaitRequests, function (arg)
  local req;
  for req in arg do
    WaitRequest(req);
  od;
end);

InstallGlobalFunction (GetRequestObj, function (request)
  local p;
  p := LOCK(request);
  if request.completed then
    return request.obj;
  else
    UNLOCK(p);
    WaitRequest (request);
    atomic readonly request do
      return request.obj;
    od;
  fi;
end);
#############################################################################

# Some trivial functions to get some handle info
InstallGlobalFunction (GetHandlePE, atomic function( readonly handle )
    return handle!.pe;
end);

InstallGlobalFunction (GetHandleAccessType, atomic function ( readonly handle )
  return handle!.accessType;
end);

GlobalObjHandles.HaveAccessCheck := function(handle)
  local res;
  res := MyLookupHashTable(MyHandles, HANDLE_OBJ(handle));
  if IsIdenticalObj(res, fail) then
    Error ("Trying to access handle that is not opened from thread ", threadId, " on PE ", processId, "\n");
  fi;
end;

# helper function for creating handles
GlobalObjHandles.CreateHandle := function (arg)
  local pe, owner, immediate, accessType, obj, handle, control;
  pe := arg[1];
  owner := arg[2];
  immediate := arg[3];
  accessType := arg[4];
  control := rec ( accessType := accessType,
                   immediate := immediate,
                   requested := false,
                   haveObject := false,
                   globalCount := 0,
                   localCount := 0,
                   blockedOnHandle := [],
                   complete := true);
  handle := Objectify( GlobalObjectHandleDefaultType,
                    rec ( pe := pe, owner := owner, control := control ));
  if IsBound(arg[5]) then
    obj := arg[5];
    control.haveObject := true;
    if immediate then
      handle!.obj := [obj];
    else
      handle!.obj := obj;
    fi;
    if accessType = ACCESS_TYPES.READ_ONLY then
      if not IsReadOnlyObj(obj) then
        atomic readwrite obj do
          MakeReadOnlyObj(obj);
        od;
      fi;
    fi;
  fi;
  return handle;
end;

GlobalObjHandles.CreateHandleFromMsg := function (pe, owner, localId, immediate, accessType)
  local handle;
  handle := GlobalObjHandles.CreateHandle (pe, owner, immediate, accessType);
  handle!.localId := localId;
  return handle;
end;

InstallGlobalFunction (CreateHandleFromObj, function (arg)
  local objToStore, handle, obj, accessType, immediate;

  obj := arg[1];
  if Length(arg)>1 then
    accessType := arg[2];
  else
    accessType := ACCESS_TYPES.READ_ONLY;
  fi;
  if HANDLE_OBJ(obj) mod 4 = 0 then
    immediate := false;
  else
    immediate := true;
  fi;

  if immediate or (not IsThreadLocal(obj)) then
    objToStore := obj;
  else
    objToStore := ShareSpecialObj(obj);
  fi;

  handle := GlobalObjHandles.CreateHandle (processId,
                    processId,
                    immediate,
                    accessType,
                    objToStore);
  handle!.localId := HANDLE_OBJ(handle);
  atomic readwrite GAMap do
    if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.GA_MAP, handle, String(HANDLE_OBJ(handle))); fi;
    MyInsertHashTable(GAMap, MakeReadOnlyObj(rec ( pe := processId, localId := handle!.localId )), handle);
  od;
  if MPI_DEBUG.HANDLE_CREATION then MPILog(MPI_DEBUG_OUTPUT.HANDLE_CREATION, handle); fi;
  ShareSpecialObj(handle);
  return handle;

end);

InstallGlobalFunction (CreateTaskResultHandle, function (task)
  local handle;
  handle := GlobalObjHandles.CreateHandle(processId, processId, false, ACCESS_TYPES.READ_WRITE);
  ShareSpecialObj (handle);
  atomic readwrite handle do
    handle!.localId := HANDLE_OBJ(handle);
  od;
  atomic readwrite task do
    task.result := handle;
  od;
  atomic readwrite HandlesMap do
    MyInsertHashTable (TaskResultHandles, HANDLE_OBJ(handle), handle);
  od;

  return handle;
end);

GlobalObjHandles.GetLocalCount := atomic function (readonly handle)
  return handle!.control.localCount;
end;

GlobalObjHandles.GetGlobalCount := atomic function (readonly handle)
  return handle!.control.globalCount;
end;


GlobalObjHandles.ChangeCount := atomic function (readwrite handle, global, inc)
  local pe;

  if not global then
    handle!.control.localCount := handle!.control.localCount+inc;
    if handle!.control.localCount<0 then
      Error ("Invalid change of local count for a handle!\n");
    else
      return handle!.control.localCount;
    fi;
    if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.CHANGE_COUNT, handle); fi;
  else
    pe := handle!.pe;
    if pe = processId then
      handle!.control.globalCount := handle!.control.globalCount+inc;
      if handle!.control.globalCount<0 then
        Error ("Invalid change of global count for a handle");
      else
        return handle!.control.globalCount;
      fi;
      if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.CHANGE_COUNT, handle); fi;
    else
      SendChangeGlobalCountMsg (pe, handle, inc);
      return -1;
    fi;
  fi;
end;

GlobalObjHandles.IncreaseGlobalCount := function (handle)
  return GlobalObjHandles.ChangeCount(handle, true, 1);
end;

GlobalObjHandles.DecreaseGlobalCount := function (handle)
  return GlobalObjHandles.ChangeCount(handle, true, -1);
end;

GlobalObjHandles.IncreaseLocalCount := function (handle)
  return GlobalObjHandles.ChangeCount(handle, false, 1);
end;

GlobalObjHandles.DecreaseLocalCount := function (handle)
  return GlobalObjHandles.ChangeCount(handle, false, -1);
end;

InstallGlobalFunction (Destroy, atomic function (readwrite handle)
  local localCount, globalCount;

  localCount := GlobalObjHandles.GetLocalCount(handle);
  globalCount := GlobalObjHandles.GetGlobalCount(handle);

  if localCount<>0 then
    Error("Cannot destroy handle in use on local node\n");
  elif handle!.pe<>processId then
    SendChangeGlobalCountMsg(handle!.pe, handle, -1);
  elif globalCount<>0 then
    Error("Cannot destroy handle referenced from other nodes\n");
  fi;

  if MPI_DEBUG.HANDLE_CREATION then MPILog(MPI_DEBUG_OUTPUT.HANDLE_DELETION, handle); fi;
  atomic HandlesMap do
    MyDeleteHashTable (HandlesMap, handle);
  od;
end);

InstallGlobalFunction (Open, function (globalObjHandle)
  MyInsertHashTable (MyHandles, HANDLE_OBJ(globalObjHandle), 1);
  return GlobalObjHandles.IncreaseLocalCount (globalObjHandle);
end);

InstallGlobalFunction (Close, function (globalObjHandle)
  GlobalObjHandles.HaveAccessCheck(globalObjHandle);
  return GlobalObjHandles.DecreaseLocalCount (globalObjHandle);
end);

# todo : fix GetHandleObjNonBlocking so that it doesn't store the object
#        into the handle, but rather only into the request. GetHandleObj also need
#        to be fixed in this way
InstallGlobalFunction (GetHandleObjNonBlocking, atomic function (readwrite handle)
  local objCopy, request;

  GlobalObjHandles.HaveAccessCheck(handle);
  request := rec ( completed := false, type := REQUEST_TYPES.GET_OBJ, pe := processId, pullObj := false, storeObj := false);
  if not handle!.control.haveObject then
    if handle!.owner = processId then
      if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " obj under eval |"); fi;
      Add (handle!.control.blockedOnHandle, MigrateObj(request, handle));
      return request;
    fi;
    if not handle!.control.requested then
      if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " @@ ", String(handle!.owner)); fi;
      SendGetObjMsg (handle, false, false);
      handle!.control.requested := true;
    fi;
    if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " @@ ", String(handle!.owner), " | "); fi;
    Add (handle!.control.blockedOnHandle, MigrateObj(request, handle));
    return request;
  fi;
  request.completed := true;
  if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " get obj local **"); fi;
  atomic readonly handle!.obj do
    if handle!.control.immediate then
      request.obj := handle!.obj[1];
    else
      request.obj := handle!.obj;
    fi;
  od;
  AdoptObj(request);
  return request;
end);

InstallGlobalFunction (GetHandleObj, function (handle)
  local request;
  request := GetHandleObjNonBlocking(handle);
  WaitRequest(request);
  atomic readwrite request do
    AdoptObj(request);
  od;
  #atomic readwrite request.obj do
    #AdoptObj(request.obj);
  #od;
  return request.obj;
end);

InstallGlobalFunction (SendHandle, atomic function (readwrite handle, pe)
  GlobalObjHandles.HaveAccessCheck(handle);
  GlobalObjHandles.IncreaseGlobalCount(handle);
  SendGlobalObjHandleMsg (handle, pe);
end);

InstallGlobalFunction (SendAndAssignHandle, atomic function (readwrite handle, pe, name)
  GlobalObjHandles.HaveAccessCheck(handle);
  GlobalObjHandles.IncreaseGlobalCount(handle);
  SendGlobalObjHandleMsg (handle, pe, name);
end);

InstallGlobalFunction (SetHandleObj, function (handle, obj)
  local localCount, p;
  GlobalObjHandles.HaveAccessCheck(handle);
  p := LOCK(handle, true);
  if handle!.control.accessType = ACCESS_TYPES.READ_ONLY then
    Error("Cannot change object of a READ_ONLY handle\n");
  fi;
  if handle!.control.haveObject then
    if handle!.control.immediate then
      handle!.obj[1] := obj;
    else
      handle!.obj := obj;
    fi;
  else
    SendSetByHandleMsg (handle, obj);
  fi;
end);

InstallGlobalFunction (SetHandleObjList, function (handle, ind, obj)
  local localCount, p, q, list;
  GlobalObjHandles.HaveAccessCheck(handle);
  q := LOCK(handle, true);
  if handle!.control.accessType = ACCESS_TYPES.READ_ONLY then
    Error("Cannot change object of a READ_ONLY handle\n");
  fi;
  if handle!.control.haveObject then
    list := handle!.obj;
    if not IsThreadLocal(list) then
      p := LOCK(list);
    fi;
    if not IsList(list) then
      Error ("Calling SetHandleObjList for a handle whose object is not list\n");
    fi;
    list[ind] := obj;
  else
    SendSetByHandleListMsg (handle, ind, obj);
  fi;
end);

InstallGlobalFunction (RemoteCopyObj, atomic function (readwrite handle, pe)
  GlobalObjHandles.HaveAccessCheck(handle);
  GlobalObjHandles.IncreaseGlobalCount(handle);
  if handle!.control.accessType = ACCESS_TYPES.READ_WRITE then
    Error ("Cannot call RemoteCopyObj on READ_WRITE handle!\n");
  fi;
  atomic readonly handle!.obj do
    DoSendObj (pe, true, false, handle);
  od;
end);

# this is a bid dodgy...what if object is under evaluation or something?
DoPushObj := function (handle, request)
  if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ->-> ", String(request.pe)); fi;
  if not handle!.control.haveObject then
    if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ->-> (", String(request.pe),
            ") ==> ", String(handle!.owner)); fi;
    SendMessage (handle!.owner, MESSAGE_TYPES.GET_OBJ_MSG,
            request.pe, handle!.pe, handle!.localId, true, true);
    request.completed := true;
  else
    atomic readonly handle!.obj do
      SendMessage (request.pe, MESSAGE_TYPES.OBJ_MSG,
              handle!.pe,
              handle!.localId,
              handle!.obj,             # object
              true,                   # store object?
              true,                   # object is being pushed?
              handle!.owner,
              handle!.control.immediate,       # handle immediate
              handle!.control.accessType,      # handle access type
              handle!.control.globalCount);    # handle global count
    od;
    request.completed := true;
  fi;

  handle!.control.haveObject := false;
  handle!.owner := request.pe;
  Unbind(handle!.obj);
  return request;
end;

InstallGlobalFunction (RemotePushObjNonBlocking, atomic function (readwrite handle, pe)
  local p, request;
  GlobalObjHandles.HaveAccessCheck(handle);
  request := rec (completed := false, type := REQUEST_TYPES.PUSH_OBJ, pe := pe, pullObj := true, storeObj := true);
  DoPushObj(handle, request);
  return request;
end);

InstallGlobalFunction (RemotePushObj, function (handle, pe)
  local request;
  GlobalObjHandles.HaveAccessCheck(handle);
  request := RemotePushObjNonBlocking(handle, pe);
  WaitRequest(request);
  if not IsThreadLocal(request) then
    atomic readwrite request do
      AdoptObj(request);
    od;
  fi;
end);

InstallGlobalFunction (RemoteCloneObjNonBlocking, atomic function (readwrite handle)
  local objCopy, request;
  GlobalObjHandles.HaveAccessCheck(handle);
  request := rec ( completed := false, type := REQUEST_TYPES.CLONE_OBJ, pe := processId, pullObj := false, storeObj := true );
  if not handle!.control.haveObject then
    if not handle!.control.requested then
      SendGetObjMsg (handle, true, false);
    fi;
    Add (handle!.control.blockedOnHandle, MigrateObj(request, handle));
    return request;
  fi;
  request!.control.completed := true;
  if not IsThreadLocal(request) then
    atomic readwrite request do
      AdoptObj(request);
    od;
  fi;
  return request;
end);

InstallGlobalFunction (RemoteCloneObj, function(handle)
  local request;
  GlobalObjHandles.HaveAccessCheck(handle);
  request := RemoteCloneObjNonBlocking(handle);
  WaitRequest(request);
  if not IsThreadLocal(request) then
    atomic readwrite request do
      AdoptObj(request);
    od;
  fi;
end);

InstallGlobalFunction (RemotePullObjNonBlocking, atomic function (readwrite handle)
  local objCopy, request;
  GlobalObjHandles.HaveAccessCheck(handle);
  request := rec ( completed := false, type := REQUEST_TYPES.PULL_OBJ, pe := processId, storeObj := true, pullObj := true );
  if not handle!.control.haveObject then
    if not handle!.control.requested then
      SendGetObjMsg (handle, true, true);
    fi;
    Add (handle!.control.blockedOnHandle, MigrateObj(request, handle));
    return request;
  fi;
  request.completed := true;
  if not IsThreadLocal(request) then
    atomic readwrite request do
      AdoptObj(request);
    od;
  fi;
  return request;
end);

InstallGlobalFunction (RemotePullObj, function(handle)
  local request;
  GlobalObjHandles.HaveAccessCheck(handle);
  request := RemotePullObjNonBlocking(handle);
  WaitRequest(request);
  if not IsThreadLocal(request) then
    atomic readwrite request do
      AdoptObj(request);
    od;
  fi;
end);
