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
