#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

CreateBlockedFetch := atomic function (readonly handle, sourceId, storeObj, pullObj)
  local blockedFetch;
  blockedFetch := rec ( type := REQUEST_TYPES.BLOCKED_FETCH,
                        pe := sourceId, storeObj := storeObj, pullObj := pullObj );
  if not IsBound (handle!.control.blockedOnHandle) then
    handle!.control.blockedOnHandle := MigrateObj ([], handle);
  fi;
  Add (handle!.control.blockedOnHandle, MigrateObj (blockedFetch, handle));
end;

# GLOBAL_OBJ_HANDLE_MSG is a message containing a handle, sent when a node
# executes SendHandle function.
# The format of the message is
# *************************
# * GLOBAL_OBJ_HANDLE_MSG *
# * --------------------- *
# * handle                * -- handle being sent
# * --------------------- *
# * name                  * -- name of the global variable to which the handle is
# * --------------------- *    assigned
# *************************

SendGlobalObjHandleMsg := atomic function (readonly handle, target, name)
  # todo : should be SendMessage (target, MESSAGE_TYPES.GLOBAL_OBJ_HANDLE_MSG, handle, name);
  #        (once we implement pickling/unpickling of handles)
  local hanRep;
  hanRep := [ handle!.pe, handle!.owner, handle!.localId, handle!.control.immediate, handle!.control.accessType ];
  SendMessage (target, MESSAGE_TYPES.GLOBAL_OBJ_HANDLE_MSG, hanRep, name);
end;

ProcessGlobalObjHandleMsg := function (message)
  local res, handle, hanRep, name, pe, localId,
        immediate, accessType, owner;
  hanRep := message.content[1];
  if IsBound(message.content[2]) then
    name := message.content[2];
  else
    name := fail;
  fi;
  pe := hanRep[1];
  owner := hanRep[2];
  localId := hanRep[3];
  immediate := hanRep[4];
  accessType := hanRep[5];
  atomic readwrite GAMap do
    if pe<>processId then
      handle := MyLookupHashTable (GAMap, rec (pe := pe, localId := localId));
    else
      handle := OBJ_HANDLE(localId);
    fi;
    if IsIdenticalObj(handle, fail) then
      handle := GlobalObjHandles.CreateHandleFromMsg (pe,
                        owner,
                        localId,
                        immediate,
                        accessType);
      if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.GA_MAP, handle, String(HANDLE_OBJ(handle))); fi;
      ShareSpecialObj(handle);
      MyInsertHashTable(GAMap,
              MakeReadOnlyObj (rec ( pe := pe, localId := localId )),
                                        handle);
    fi;
    if not IsIdenticalObj(name, fail) then
      if not IsBound(name) then
        BindGlobal(name, handle);
        MakeReadOnlyGVar(name);
      else
        MakeReadWriteGVar(name);
        BindGlobal(name, handle);
        MakeReadOnlyGVar(name);
      fi;
    fi;
  od;
  return handle;
end;

# SET_BY_HANDLE_MSG is a message that is sent when a node does
# SetByHandle or SetByHandleList.
# The format of the message is
# *********************
# * SET_BY_HANDLE_MSG *
# * ----------------- *
# * globalAddrPE      * -- global address pe
# * ----------------- *
# * globalAddrLocalId * -- global address local id
# * ------------------*
# * value             * -- value to set the object of a handle to
# * ----------------- *
# * index             * -- index of the list to which handle points to
# *********************    (in the case of SeyByHandleList)

SendSetByHandleMsg := atomic function (readonly handle, value)
  SendMessage (handle!.pe, MESSAGE_TYPES.SET_BY_HANDLE_MSG, handle!.pe, handle!.localId, value);
end;

SendSetByHandleListMsg := atomic function (readonly handle, ind, value)
  SendMessage (handle!.pe, MESSAGE_TYPES.SET_BY_HANDLE_MSG, handle!.pe, handle!.localId, value, ind);
end;

ProcessSetByHandleMsg := function (message)
  local res, obj, handle, forwardPE, ind, p, pe, localId;
  pe := message.content[1];
  localId := message.content[2];
  obj := message.content[3];
  if IsBound(message.content[4]) then
    ind := message.content[4];
  fi;
  if processId = pe then
    handle := OBJ_HANDLE(localId);
  else
    handle := MyLookupHashTable (GAMap, rec ( pe := pe, localId := localId ));
  fi;
  atomic readwrite handle do
    if handle!.owner = processId then
      if handle!.control.immediate then
        handle!.obj[1] := obj;
      elif IsBound(ind) then
        if not IsThreadLocal(handle!.obj) then
          p := LOCK(handle!.obj);
        fi;
        if not IsList(handle!.obj) then
          Error ("SetByHandleList called for non-list object\n");
        fi;
        handle!.obj[ind] := obj;
      else
        handle!.obj := ShareSpecialObj(obj);
      fi;
    else
      forwardPE := handle!.owner;
      if IsBound(ind) then
        SendMessage (forwardPE, MESSAGE_TYPES.SET_BY_HANDLE_MSG, forwardPE, localId, obj, ind);
      else
        SendMessage (forwardPE, MESSAGE_TYPES.SET_BY_HANDLE_MSG, forwardPE, localId, obj);
      fi;
    fi;
  od;
end;

# CHANGE_GLOBAL_COUNT_MSG is a message that is sent when global count
# for a handle needs to be changed (e.g. when handles are destroyed)
# Format of the message is
# ***************************
# * CHANGE_GLOBAL_COUNT_MSG *
# * ----------------------- *
# * globalAddrPE            * -- global address pe
# * ----------------------- *
# * globalAddrLocalId       * -- global address local id
# * ----------------------- *
# * destLocalAddr           * -- local address of a handle on the
# * ----------------------- *    destination node
# * increment               * -- integer increment of global count
# ***************************

SendChangeGlobalCountMsg := atomic function (target, readonly handle, increment)
  SendMessage (target, MESSAGE_TYPES.CHANGE_GLOBAL_COUNT_MSG, handle!.pe, handle!.localId, increment);
end;

ProcessChangeGlobalCountMsg := function (message)
  local pe, localId, handle, inc;
  pe := message.content[1];
  localId := message.content[2];
  if pe = processId then
    handle := OBJ_HANDLE(localId);
  else
    handle := MyLookupHashTable (GAMap, rec ( pe := pe, localId := localId ));
  fi;
  inc := message.content[3];
  GlobalObjHandles.ChangeCount (handle, true, inc);
end;

# GET_OBJ_MSG is the message that is sent when an object needs to be
# fetched/read from a remote node (GetHandleObj, RemotePullObj, RemoteCloneObj)
# Format of the message is
# *********************
# * GET_OBJ_MSG tag   *
# * ----------------  *
# * sourceId          * -- id of the source node that sent the message
# * ----------------  *
# * globalAddrPE      * -- global address PE
# * ----------------  *
# * globalAddrLocalId * -- global address local id
# * ----------------  *
# * storeObj          * -- true if the received object needs to be stored in handle
# * ----------------  *    (RemoteCloneObj, RemotePullObj)
# * pullObj           * -- true if the object needs to be pulled from the remote node
# *********************    (RemotePullObj)

SendGetObjMsg := atomic function (readonly handle, storeObj, pullObj)
  SendMessage (handle!.owner, MESSAGE_TYPES.GET_OBJ_MSG,
          processId, handle!.pe, handle!.localId, storeObj, pullObj);
end;

# auxiliary functions that deal with creation of blocked fetches and
# processing of the queue of blocked requests on a handle
UnblockWaitingThreads := function (request)
  local thread;
  for thread in request.blockedOnRequest do
    SendChannel (Tasks.TaskManagerRequests,
            rec ( worker := thread, type := TASK_MANAGER_REQUESTS.RESUME_BLOCKED_WORKER));
  od;
end;

DoSendObj := fail;

InstallGlobalFunction(ProcessHandleBlockedQueue, atomic function (readwrite handle, obj)
  local toRemove, thread, queue;
  queue := handle!.control.blockedOnHandle;
  handle!.control.blockedOnHandle := MigrateObj ([], handle);
  for toRemove in queue do
    if MPI_DEBUG.OBJECT_TRANSFER then
      if toRemove.pullObj then
        MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ->-> ", String(toRemove.pe), " - ");
      elif toRemove.storeObj then
        MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ++ ", String(toRemove.pe), " - ");
      else
        MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ", String(toRemove.pe)," @@ - ");
      fi;
    fi;
    if toRemove.pe = processId then
      toRemove.obj := obj;
      toRemove.completed := true;
      if IsBound(toRemove.blockedOnRequest) then UnblockWaitingThreads(toRemove); fi;
    else
      DoSendObj (toRemove.pe, toRemove.storeObj, toRemove.pullObj, handle);
    fi;
  od;
end);

DoSendObj := atomic function (sourceId, storeObj, pullObj, readwrite handle)
  if handle!.control.haveObject then
    atomic readonly handle!.obj do
      if processId = sourceId then
        if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " local request"); fi;
        ProcessHandleBlockedQueue (handle, handle!.obj);
      else
        if MPI_DEBUG.OBJECT_TRANSFER then
          if pullObj then
            MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ->-> (", String(sourceId), ") --> ", String(sourceId));
          elif storeObj then
            MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ++ (", String(sourceId), ") --> ", String(sourceId));
          else
            MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ", String(sourceId), " @@ --> ", String(sourceId));
          fi;
        fi;
        SendMessage (sourceId, MESSAGE_TYPES.OBJ_MSG,
                handle!.pe,
                handle!.localId,
                handle!.obj,                 # object
                storeObj,
                pullObj,
                handle!.owner,
                handle!.control.immediate,
                handle!.control.accessType,
                handle!.control.globalCount);
      fi;
    od;
    if pullObj then
      if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " new owner"); fi;
      handle!.owner := sourceId;
      Unbind(handle!.obj);
      handle!.control.haveObject := false;
    fi;
  else
    if handle!.owner = processId then        # object under evaluation
      if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " | (obj under eval)"); fi;
      CreateBlockedFetch (handle, sourceId, storeObj, pullObj);
    else                                  # object resides somewhere else
      if MPI_DEBUG.OBJECT_TRANSFER then
        if pullObj then
          MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ->-> (", String(sourceId), ") ==> ", String(handle!.owner));
        elif storeObj then
          MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ++ (", String(sourceId), ") ==> ", String(handle!.owner));
        else
          MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " ", sourceId, " @@ ==> ", String(handle!.owner));
        fi;
      fi;
      SendMessage (handle!.owner, MESSAGE_TYPES.GET_OBJ_MSG, sourceId, handle!.pe, handle!.localId,
              storeObj, pullObj);
    fi;
  fi;
end;


ProcessGetObjMsg := function (message)
  local sourceId, pe, localId, handle, storeObj, pullObj, request;
  sourceId := message.content[1];
  pe := message.content[2];
  localId := message.content[3];
  storeObj := message.content[4];
  pullObj := message.content[5];
  handle := MyLookupHashTable (GAMap, rec ( pe := pe, localId := localId));
  if IsIdenticalObj(handle,fail) then
    Error ("Node ", processId, " does not have handle for (", pe, ",", localId, ")\n");
  fi;
  atomic readwrite handle do
    DoSendObj(sourceId, storeObj, pullObj, handle);
  od;
end;

# i don't think we need ack messages any more, yes?
# ACK_MSG is a message that is sent when an object is migrated from one
# node to the other (using RemotePushObj or RemotePullObj), and when the
# owner of that object needs to change.
# Format of the message is
# *******************
# * ACK_MSG         *
# * --------------- *
# * destLocalAddr   * -- local address of a handle on the
# * --------------- *    destination node (node that receives the message)
# * sourceId        * -- id of the node
# * --------------- *
# * sourceLocalAddr * -- local address of a handle on the source node
# *******************

#ProcessAckMsg := function (message)
#  local remoteId, remoteLocalAddr, myLocalAddr, handle;
#  myLocalAddr := message.content[1];
#  remoteId := message.content[2];
#  remoteLocalAddr := message.content[3];
#  handle := OBJ_HANDLE(myLocalAddr);
#  atomic readwrite handle do
#    handle!.pe := remoteId;
#    handle!.localAddr := remoteLocalAddr;
#    PrintKY10 3AQ (processId, " is updating the local addr of ", HANDLE_OBJ(handle), " to ", remoteLocalAddr, "\n");
#    handle!.control.complete := true;
#    if not IsEmpty(handle!.control.blockedOnHandle) then
#      ProcessHandleBlockedQueue(handle, fail);
#    fi;
#  od;
#  # q : do we need to insert the newly received (pe,addr) pair into GAMap?
#end;


# OBJ_MSG is a message containing an object, which is sent when the object is
# requested from a remote node (GetHandleObj, RemotePullObj, RemoteCloneObj) or
# when the object is copied from the source to the destination node
# (RemoteCopyObj, RemotePushObj).
# In the comments below, 'sender node' is the node that sent the OBJ_MSG message,
# and 'receiver node' is the node that is processing it.
# The message is of the form
# ************************
# * OBJ_MSG tag          *
# * -------------------- *
# * globalAddrPE         * -- global address PE
# * -------------------- *
# * globalAddressLocalId * -- global address local id
# * -------------------- *
# * obj                  * -- object being transferred
# * -------------------- *
# * storeObj             * -- true or false, depending on whether the object needs to
# * -------------------- *    be stored in the dest node (false for GetHandleObj)
# * objPushed            * -- true if object is pushed from the source node (using
# * -------------------- *    RemotePushObj or RemotePullObj), false otherwise
# * owner                * -- owner of the object (relevant when a handle for the
# * -------------------- *    object needs to be created on the receiver)
# * immediate            * -- true if handle is immediate (relevant when a handle
# * -------------------- *    for the object needs to be created on the receiver)
# * accessType           * -- access type of a handle (relevant when a handle for the
# * -------------------- *    object needs to be created on the receiver)
# * globalCount          * -- global count of a handle (relevant when a handle for the
# ************************    object needs to be created on the receiver)

ProcessObjMsg := function (message)
  local pe, localId, obj, handle, id, thread, blocked, pushed,
        immediate, accessType, objPushed,
        storeObject, globalCount, sourceLocalAddr, owner;

  pe := message.content[1];
  localId := message.content[2];
  obj := ShareSpecialObj(message.content[3]);
  storeObject := message.content[4];
  objPushed := message.content[5];
  handle := MyLookupHashTable( GAMap, rec ( pe := pe, localId := localId ));
  if IsIdenticalObj(handle, fail) then
    owner := message.content[6];
    immediate := message.content[7];
    accessType := message.content[8];
    handle := GlobalObjHandles.CreateHandleFromMsg (pe,
                        owner,
                        localId,
                        immediate,
                        accessType);
    atomic readwrite GAMap do
      MyInsertHashTable (GAMap, rec ( pe := pe, localId := localId ), handle );
      if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.GA_MAP, handle, String(HANDLE_OBJ(handle))); fi;
    od;
    ShareSpecialObj(handle);
  fi;
  atomic readwrite handle do
    immediate := handle!.control.immediate;
    if not immediate then
      ShareSpecialObj(obj);
      handle!.obj := obj;
    else
      handle!.obj := [];
      handle!.obj[1] := obj;
      #MigrateObj (handle!.obj, handle);
      atomic readonly obj do
        MigrateObj (obj, handle);
      od;
    fi;
    if storeObject then
      handle!.control.haveObject := true;
    fi;
  od;
  ProcessHandleBlockedQueue (handle, obj);
  # debug stuff
  atomic readonly handle do
    if MPI_DEBUG.OBJECT_TRANSFER then
      if objPushed then
        MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " obj (", String(message.source), ",->->,M)");
      elif storeObject then
        MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " obj (", String(message.source), ",++,M)");
      else
        MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " obj (", String(message.source), ",@@,X)");
      fi;
    fi;
  od;
  if objPushed then
    globalCount := message.content[9];
    atomic readwrite handle do
      handle!.control.globalCount := handle!.control.globalCount + globalCount + 1;
      if MPI_DEBUG.GA_MAP then MPILog(MPI_DEBUG_OUTPUT.CHANGE_COUNT, handle); fi;
      handle!.owner := processId;
      if MPI_DEBUG.OBJECT_TRANSFER then MPILog(MPI_DEBUG_OUTPUT.OBJECT_TRANSFER, handle, " new owner"); fi;
      atomic readwrite HandlesMap do
        MyInsertHashTable (HandlesMap, HANDLE_OBJ(handle), handle);
      od;
    od;
  fi;
end;
