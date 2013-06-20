ENTER_NAMESPACE("ZNODE");

Tickets@ := ShareInternalObj(EmptyPlist(4000), "ZTickets");
FreeTickets@ := LockAndMigrateObj(EmptyPlist(4000), Tickets@);
Outgoing@ := AtomicList([]);
Incoming@ := fail;
HandlerThread@ := fail;
StartHandlerThread@ := fail;

ZAll := `[];
ZSelf := fail;
SelfAsString@ := fail;

ZSetOutgoing := function(node, socket)
  Outgoing@[node+1] := ShareInternalObj(ZmqPushSocket(socket));
end;

ZSetIncoming := function(socket)
  if Incoming@ <> fail then
    Incoming@ := ZmqPullSocket(socket);
    ShareInternalObj(Incoming@);
  else
    Incoming@ := ZmqPullSocket(socket);
    ShareInternalObj(Incoming@);
    StartHandlerThread@();
  fi;
end;

ZSetNodes := function(self, nodes)
  ZSelf := self;
  SelfAsString@ := MakeImmutable(String(self));
  ZAll := Immutable(nodes);
end;

ZDo@ := function(op, nodes, args)
  local node;
  if IS_LIST(nodes) then
    for node in nodes do
      ZDo@(op, node, args);
    od;
  else
    node := nodes;
    if IS_INT(node) and (node = 0 or node in ZAll) then
      atomic Outgoing@[node+1] do
	ZmqSend(Outgoing@[node+1],
	  [SelfAsString@, op, SerializeToNativeString(args)]);
      od;
    fi;
  fi;
end;

ZError := function(node, message)
  ZDo@("Err", node, message);
end;

ZRespond@ := function(node, ticket, result)
  ZDo@("Rcpt", node, [ticket, result]);
end;

Handlers@ := MakeWriteOnceAtomic( rec(
   Err := function(arg)
     Display(arg[1]);
   end,
   Exec := function(arg)
     READ_COMMAND(InputTextString(arg[1]), false);
   end,
   Eval := function(arg)
     local result;
     result := EvalString(arg[1]);
     ZRespond@(arg[3], arg[2], result);
   end,
   Rcpt := function(arg)
     local ticket, result, callback;
     ticket := arg[1];
     result := arg[2];
     atomic Tickets@ do
       callback := Tickets@[ticket];
       Unbind(Tickets@[ticket]);
       Add(FreeTickets@, ticket);
     od;
     callback(result);
   end,
   Bind := function(arg)
     ASS_GVAR(arg[1], arg[2]);
   end,
   Unb := function(arg)
     UNBIND_GLOBAL(arg[1]);
   end,
   Call := function(arg)
     local func;
     if IsBoundGlobal(arg[1]) then
       func := VAL_GVAR(arg[1]);
       CALL_FUNC_LIST(func, arg[2]);
     else
       ZError(arg[3], Concatenation("Function not found: ", arg[1]));
     fi;
   end,
   Query := function(arg)
     local func, result;
     if IsBoundGlobal(arg[1]) then
       func := VAL_GVAR(arg[1]);
       result := CALL_FUNC_LIST(func, arg[2]);
       ZRespond@(arg[4], arg[3], result);
     else
       ZError(arg[4], Concatenation("Function not found: ", arg[1]));
     fi;
   end,
   Async := function(arg)
     local func, args;
     if IsBoundGlobal(arg[1]) then
       func := VAL_GVAR(arg[1]);
       args := arg[2];
       Add(args, func, 1);
       CALL_FUNC_LIST(RunAsyncTask, args);
     else
       ZError(arg[3], Concatenation("Function not found: ", arg[1]));
     fi;
   end,
   Task := function(arg)
     local func, result;
     if IsBoundGlobal(arg[1]) then
       func := VAL_GVAR(arg[1]);
       RunAsyncTask(function(args, replynode, ticket)
	 result := CALL_FUNC_LIST(func, args);
	 ZRespond@(replynode, ticket, result);
       end, arg[2], arg[4], arg[3]);
     else
       ZError(arg[4], Concatenation("Function not found: ", arg[1]));
     fi;
   end,
) );

RegisterCallback@ := function(callback)
  local ticket;
  atomic Tickets@ do
    if Length(FreeTickets@) > 0 then
      ticket := Remove(FreeTickets@);
    else
      ticket := Length(Tickets@)+1;
    fi;
    Tickets@[ticket] := callback;
  od;
  return ticket;
end;

ZExec := function(nodes, cmd)
  ZDo@("Exec", nodes, [ cmd ]);
end;

ZEval := function(nodes, expr, callback)
  local ticket, node;
  if IS_LIST(nodes) then
    for node in nodes do
      ZEval(node, expr, callback);
    od;
  else
    ticket := RegisterCallback@(callback);
    ZDo@("Eval", nodes, [ expr, ticket ]);
  fi;
end;

ZBind := function(nodes, var, expr)
  ZDo@("Bind", nodes, [String(var), expr]);
end;

ZUnbind := function(nodes, var)
  ZDo@("Unb", nodes, [ var ]);
end;

ZCall := function(nodes, func, args)
  ZDo@("Call", nodes, [ func, args ]);
end;

ZQuery := function(nodes, func, args, callback)
  local node, ticket;
  if IS_LIST(nodes) then
    for node in nodes do
      ZQuery(node, func, args, callback);
    od;
  else
    ticket := RegisterCallback@(callback);
    ZDo@("Query", nodes, [ func, args, ticket ]);
  fi;
end;

ZAsync := function(nodes, func, args)
  ZDo@("Task", nodes, [ func, args ]);
end;

ZTask := function(nodes, func, args, callback)
  local node, ticket;
  if IS_LIST(nodes) then
    for node in nodes do
      ZTask(node, func, args, callback);
    od;
  else
    ticket := RegisterCallback@(callback);
    ZDo@("Task", nodes, [ func, args, ticket ]);
  fi;
end;


ZRead := function(nodes, file)
  ZDo@("Call", nodes, ["Read", [ file ] ]);
end;

ZReadGapRoot := function(nodes, file)
  ZDo@("Call", nodes, ["ReadGapRoot", [ file ] ]);
end;

ZResponse := function()
  local response;
  response := CreateSyncVar();
  return `rec(
    put := function(result)
      SyncWrite(response, MakeReadOnly(result));
    end,
    get := -> SyncRead(response),
    test := -> SyncIsBound(response),
  );
end;

StartHandlerThread@ := function()
  HandlerThread@ := CreateThread(function()
    local packet, node, op, args, func;
    while true do
      atomic Incoming@ do
	packet := ZmqReceiveList(Incoming@);
      od;
      node := packet[1];
      op := packet[2];
      args := DeserializeNativeString(packet[3]);
      if IsBound(Handlers@.(op)) then
	func := Handlers@.(op);
	Add(args, Int(node));
	CALL_WITH_CATCH(func, args);
      fi;
    od;
  end);
end;

LEAVE_NAMESPACE();
