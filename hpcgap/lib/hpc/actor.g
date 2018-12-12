#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

CURRENT_ACTOR := rec();
MakeThreadLocal("CURRENT_ACTOR");

BindGlobal("ACTOR_HANDLER", function(actor_state, func)
  return function(arg)
    local queue;
    queue := actor_state.queue;
    # Because arg is known to be thread-local, CopyRegion()
    # will perform a structural copy of only arguments in
    # the same region; similarly, MigrateObj() will only
    # migrate objects in the same (thread-local) region.
    atomic queue do
      Add(queue, MakeReadOnlySingleObj(rec(
        func := func,
        args := MigrateObj(CopyRegion(arg), queue)
      )) );
    od;
    SignalSemaphore(actor_state.semaphore);
  end;
end);

BIND_GLOBAL("ACTOR_LOOP", function(actor_state)
  local msg, handlers, sem, queue;
  CURRENT_ACTOR := actor_state;
  handlers := actor_state.handlers;
  sem := actor_state.semaphore;
  queue := actor_state.queue;
  if IsBound(handlers._Init) then
    handlers._Init();
  fi;
  while true do
    atomic queue do
      if Length(queue) > 0 then
        msg := Remove(queue, 1);
        msg.args := AdoptObj(msg.args);
      else
        msg := fail;
      fi;
    od;
    if msg = fail then
      WaitSemaphore(sem);
    else
      CALL_FUNC_LIST(msg.func, AdoptObj(msg.args));
      if actor_state.terminated then
        if IsBound(handlers._AtExit) then
          handlers._AtExit();
        fi;
        CURRENT_ACTOR := rec();
        return;
      fi;
    fi;
  od;
end);

BindGlobal("StartActor", function(handlers)
  local wrapped_handlers, name, actor_state;
  wrapped_handlers := rec();
  actor_state := rec(
    handlers := handlers,
    queue := ShareInternalObj([]),
    semaphore := CreateSemaphore(0),
    terminated := false
  );
  for name in REC_NAMES(handlers) do
    if name[1] <> '_' then
      wrapped_handlers.(name) := ACTOR_HANDLER(actor_state, handlers.(name));
    else
      wrapped_handlers.(name) := handlers.(name);
    fi;
  od;
  MakeImmutable(wrapped_handlers);
  RunAsyncTask(ACTOR_LOOP, actor_state);
  return wrapped_handlers;
end);

BindGlobal("ExitActor", function()
  CURRENT_ACTOR.terminated := true;
end);
