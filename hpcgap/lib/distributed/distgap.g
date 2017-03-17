ReadLib("distributed/globalobject.gd");
ReadLib("distributed/loutils.g");
ReadLib("distributed/locomm.g");
ReadLib("distributed/hicomm.g");
ReadLib("distributed/collective.g");
ReadLib("distributed/dist_tasks.g");
ReadLib("distributed/globalobject.gi");
ReadLib("distributed/work_stealing.g");
ReadLib("distributed/messageman.g");

MakeReadWriteGVar("MessageManager");
MessageManager := CreateThread(MessageManagerFunc);
MakeReadOnlyGVar("MessageManager");
