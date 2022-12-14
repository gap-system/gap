#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

MPISendLock := ShareObj ( rec ( dummy := 0 ) );

MakeReadWriteGVar("MESSAGE_TYPES");
MESSAGE_TYPES := MakeReadOnlyObj ( rec (
                         # global objects/handles messages
                         GLOBAL_OBJ_HANDLE_MSG := 1500,
                         SET_BY_HANDLE_MSG := 1501,
                         CHANGE_GLOBAL_COUNT_MSG := 1502,
                         GET_OBJ_MSG := 1503,
                         ACK_MSG := 1504,
                         OBJ_MSG := 1505,
                         # load balancing
                         STEAL_MSG := 1600,
                         SCHEDULE_MSG := 1601,
                         STOP_STEALING_MSG := 1602,
                         # distributed objects
                         DIST_OBJ_ACK := 1,
                         DIST_OBJ_RETURN_READ := 2,
                         UPDATE_DIST_OBJ := 3,
                         READ_DIST_OBJ := 4,
                         FETCH_DIST_OBJ := 5,
                         SCHEDULE := 6,
                         FISH := 7,
                         CREATE_DIST_OBJ := 8,
                         CHANGE_GLOBAL_COUNT := 9,
                         INC_GLOBAL_COUNT := 10,
                         GLOBAL_OBJ_HANDLE := 11,
                         SET_BY_HANDLE := 12,
                         FETCH_TASK_RESULT := 13,
                         REPLY_WITH_RESULT := 14,
                         EVAL := 100,
                         EVAL_RES := 101,
                         EVAL_MSG := 1003,
                         FINISH := 1004,
                         PROCESS_FINISHED := 1005,
                                        ACK := 1007,
                                        STOP_MANAGERS := 1012
                         ));
MakeReadOnlyGVar("MESSAGE_TYPES");


#ProcessCreateDistributedObjectMsg := function (input, source, dummyObj)
#    local msg, name, stringCmd, obj, replyMsg,
#          localRemoteRef, weight, remoteLocalAddr;
#
#    msg := UnpickleMsg (input);
#    remoteLocalAddr := msg[1];
#    name := msg[2];
#    weight := msg[3];
#    stringCmd := Concatenation (name, " := ", CreateDistributedObjectStrCommand(dummyObj, name));
#    ReadEvalFromString(stringCmd);
#    obj := LastReadValue;
#    localRemoteRef := Globalise (obj);
#    SetRemoteReferenceWeight (localRemoteRef, weight);
#    replyMsg := Concatenation (IO_Pickle(remoteLocalAddr),
#                        PackRemoteReference(localRemoteRef));
#    MPI_Send (replyMsg, source, MESSAGE_TYPES.DIST_OBJ_ACK);
#end;

#ProcessAckCreateDistributedObjectMsg := function (input)
#    local msg, localAddr, remRef, localObj, res;
#
#    msg := UnpickleMsg(input);
#    localAddr := msg[1];
#    localObj := OBJ_HANDLE(localAddr);
#    remRef := RemoteReference (msg[2],msg[3],msg[4]);
#    res := AckCreateDistributedObject (localObj, remRef);
#    return res;
#end;

#ProcessReadDistributedObjectMsg := function (input, source)
#    local msgList, retList, obj, retLocalAddress, retMsg;
#
#    msgList := UnpickleMsg (input);
#    retList := [];
#    obj := OBJ_HANDLE(msgList[1]);
#    retLocalAddress := msgList[2];
#    retList := ReadDistributedObject (obj, msgList{[3..Length(msgList)]});
#    retMsg := Concatenation(IO_Pickle(retLocalAddress), IO_Pickle(retList));
#    MPI_Send (retMsg, source, MESSAGE_TYPES.DIST_OBJ_RETURN_READ);
#end;

#ProcessFetchDistributedObjectMsg := function (input, source)
#    local msgList, retList, obj, retLocalAddress, retMsg,
#          retRemoteReference;

#    msgList := UnpickleMsg (input);
#    retList := [];
#    obj := OBJ_HANDLE(msgList[1]);
#    retRemoteReference := RemoteReference(msgList[2],msgList[3],msgList[4]);
#    retList := ReadDistributedObject (obj, msgList{[5..Length(msgList)]});
#    retMsg := Concatenation (IO_Pickle(msgList[3]), IO_Pickle(retList));
#    MPI_Send (retMsg, source, MESSAGE_TYPES.DIST_OBJ_RETURN_READ);
#    UpdateDistributedObjectWithRemoteReference (obj, msgList{[5..Length(msgList)]}, retRemoteReference);
#end;

#ProcessUpdateDistributedObjectMsg := function (input, source)
#    local msgList, localAddr, localObj;
#    msgList := UnpickleMsg (input);
#    localAddr := msgList[1];
#    localObj := OBJ_HANDLE(localAddr);
#    UpdateDistributedObject (localObj, msgList{[2..Length(msgList)]});
#end;

#SendCreateDistributedObjectMsg := function (msg, dest)
#    MPI_Send (msg, dest, MESSAGE_TYPES.CREATE_DIST_OBJ);
#end;


#SendUpdateDistributedObjectMsg := function (msg, dest)
#    MPI_Send (msg, dest, MESSAGE_TYPES.UPDATE_DIST_OBJ);
#end;

#SendReadDistributedObjectMsg := function (msg, dest)
#    MPI_Send (msg, dest, MESSAGE_TYPES.READ_DIST_OBJ);
#end;

#SendFetchDistributedObjectMsg := function (msg, dest)
#    MPI_Send (msg, dest, MESSAGE_TYPES.FETCH_DIST_OBJ);
#end;

#SendDecreaseGlobalCountMsg := function (target, localAddr)
#  SendMessage (target, MESSAGE_TYPES.DEC_GLOBAL_COUNT, localAddr);
#end;

#SendIncreaseGlobalCountMsg := function (target, localAddr)
#  SendMessage (target, MESSAGE_TYPES.INC_GLOBAL_COUNT, localAddr);
#end;

#SendGlobalObjectHandleMsg := function (localAddr, name, access, target)
#  SendMessage (target, MESSAGE_TYPES.GLOBAL_OBJECT_HANDLE, localAddr, name, access);
#end;
#
#ProcessGlobalObjectHandleMsg := function (msg, source)
#    local res;
#    res := UnpickleMsg(msg);
#    CreateGlobalObjectHandle (source, res[1], res[2], res[3]);
#end;

#SendSetByHandleMsg := function (localAddrOfHandle, value, target)
#  SendMessage (target, MESSAGE_TYPES.SET_BY_HANDLE, localAddrOfHandle, value);
#end;

#ProcessSetByHandleMsg := function (msg)
#    local res;
#    res := UnpickleMsg(msg);
#    SetByHandle (OBJ_HANDLE(res[1]),res[2]);
#end;
