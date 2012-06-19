DeclareFilter("IsZmqSocket", IsObject and IsInternalRep);
BindGlobal("TYPE_ZMQ_SOCKET", NewType(SynchronizationFamily, IsZmqSocket));

BindGlobal("ZmqAttachedSocket", function(type, addrs)
  local socket, addr;
  socket := ZmqSocket(type);
  for addr in addrs do
    if addr <> "" and addr[1] = '+' then
      ZmqConnect(socket, addr{[2..Length(addr)]});
    else
      ZmqBind(socket, addr);
    fi;
  od;
  return socket;
end);

BindGlobal("ZmqPushSocket", function(arg)
  return ZmqAttachedSocket("PUSH", arg);
end);

BindGlobal("ZmqPullSocket", function(arg)
  return ZmqAttachedSocket("PULL", arg);
end);

BindGlobal("ZmqRequestSocket", function(arg)
  return ZmqAttachedSocket("REQ", arg);
end);

BindGlobal("ZmqReplySocket", function(arg)
  return ZmqAttachedSocket("REP", arg);
end);

BindGlobal("ZmqDealerSocket", function(arg)
  return ZmqAttachedSocket("DEALER", arg);
end);

BindGlobal("ZmqRouterSocket", function(arg)
  return ZmqAttachedSocket("ROUTER", arg);
end);

BindGlobal("ZmqPublisherSocket", function(arg)
  return ZmqAttachedSocket("PUB", arg);
end);

BindGlobal("ZmqSubscriberSocket", function(arg)
  return ZmqAttachedSocket("SUB", arg);
end);
