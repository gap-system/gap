#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

DeclareCategory ("IsGlobalObjectHandle", IsObject );

GlobalObjectHandlesFamily := NewFamily( "GlobalObjectHandlesFamily" );

DeclareGlobalFunction ("RequestCompleted");
DeclareGlobalFunction ("WaitRequest");
DeclareGlobalFunction ("WaitRequests");
DeclareGlobalFunction ("GetRequestObj");

DeclareGlobalFunction ( "GetHandlePE" );
DeclareGlobalFunction ( "GetHandleAccessType" );
DeclareGlobalFunction ( "CreateHandleFromObj" );
DeclareGlobalFunction ( "CreateTaskResultHandle" );
DeclareGlobalFunction ( "Open" );
DeclareGlobalFunction ( "Close" );
DeclareGlobalFunction ( "Destroy" );
DeclareGlobalFunction ( "GetHandleObj" );
DeclareGlobalFunction ( "GetHandleObjNonBlocking" );
DeclareGlobalFunction ( "SendHandle" );
DeclareGlobalFunction ( "SendAndAssignHandle");
DeclareGlobalFunction ( "SetHandleObj" );
DeclareGlobalFunction ( "SetHandleObjList" );
DeclareGlobalFunction ( "RemoteCopyObj" );
DeclareGlobalFunction ( "RemotePushObjNonBlocking" );
DeclareGlobalFunction ( "RemotePushObj" );
DeclareGlobalFunction ( "RemoteCloneObj" );
DeclareGlobalFunction ( "RemoteCloneObjNonBlocking" );
DeclareGlobalFunction ( "RemotePullObj" );
DeclareGlobalFunction ( "RemotePullObjNonBlocking" );
