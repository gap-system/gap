#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

HaveMultiThreadedUI := true;

ENTER_NAMESPACE("ConsoleUI");

ControlThread@ := false;
MakeThreadLocal("ControlThread@");
MakeThreadLocal("MyOutputPrefix@");

MakeThreadLocal("ThreadInfo@");
MakeThreadLocal("InputStream@");
MakeThreadLocal("OutputStream@");

ProgramShutdown@ := StartHandShake();

ActiveThread@ := -1;
NumShellThreads@ := 1;
NeedPrompt@ := true;
DelayedPrompt@ := Immutable("");

ThreadControlChannel@ := fail;
ThreadInputChannel@ := fail;
WaitForThread@ := fail;
ThreadObject@ := fail;
OutputHistory@ := fail;
OutputHistoryIncompleteLine@ := fail;
OutputPrefix@ := fail;
OutputPrefixRaw@ := fail;
ThreadName@ := fail;
ThreadNameToID@ := fail;
Prompt@ := fail;
ShowBackgroundOutput@ := fail;
ShownOutput@ := fail;
PendingOutput@ := fail;
BindGlobal("Region@", ShareSpecialObj("ConsoleUI"));

BindGlobal("InitThreadTables@", function()
  ThreadControlChannel@ConsoleUI := [];
  ThreadInputChannel@ConsoleUI := [];
  WaitForThread@ConsoleUI := [];
  ThreadObject@ConsoleUI := [];
  OutputHistory@ConsoleUI := [];
  OutputHistoryIncompleteLine@ConsoleUI := [];
  OutputPrefix@ConsoleUI := [];
  OutputPrefixRaw@ConsoleUI := [];
  ThreadName@ConsoleUI := [];
  ThreadNameToID@ConsoleUI := rec();
  Prompt@ConsoleUI := [];
  ShowBackgroundOutput@ConsoleUI := [];
  ShownOutput@ConsoleUI := [];
  PendingOutput@ConsoleUI := [];
end);

DefaultShowBackgroundOutput@ := false;
OutputHistoryLength@ := 100;
DefaultOutputPrefix@ := MakeImmutable("[%name%] ");
DefaultPrompt@ := MakeImmutable("[%name%] gap> ");

#V ControlChannel@ - channel to send commands to the main thread
#V OutputChannel@ - channel to send output/commands to the output thread
#V InputChannel@ - channel to receive input from the input thread
#V PromptChannel@ - channel to send prompts to the input thread

BindGlobal("ControlChannel@", CreateChannel(10000));
BindGlobal("OutputChannel@", CreateChannel(10000));
BindGlobal("InputChannel@", CreateChannel(10000));
BindGlobal("PromptChannel@", CreateChannel(10000));

# define constants for the main control channel

BindGlobal("REGISTER_THREAD@", 0);
BindGlobal("UNREGISTER_THREAD@", 1);
BindGlobal("HAVE_OUTPUT@", 2);
BindGlobal("HAVE_INPUT@", 3);
BindGlobal("EXPECT_INPUT@", 4);

BindGlobal("ThreadID@", function()
  return ThreadID(CurrentThread()) + 1;
end);

BindGlobal("SubstituteVariables@", function(string, threadid)
  local result;
  result := ReplacedString(string, "%id%", String(threadid-1));
  result := ReplacedString(result, "%name%", ThreadName@[threadid]);
  return result;
end);

BindGlobal("Debug@", function(arg)
  local text, value;
  text := "<# ";
  for value in arg do
    Append(text, String(value));
  od;
  Append(text, "#>\n");
  WRITE_STRING_FILE_NC(2, text);
end);

BindGlobal("SystemMessage@", function(arg)
  local text, value;
  text := "--- ";
  for value in arg do
    Append(text, String(value));
  od;
  Add(text, '\n');
  SendChannel(OutputChannel@, [ -1, "", text ] );
end);

BindGlobal("FindThread@", function(id)
  if IS_INT(id) then
    if IsBound(ThreadName@[id+1]) then
      return id+1;
    else
      return fail;
    fi;
  fi;
  if IsBound(ThreadNameToID@.(id)) then
    return ThreadNameToID@.(id);
  fi;
  id := SMALLINT_STR(id);
  if id <> fail and id >= 0 and IsBound(ThreadName@[id+1]) then
    return id+1;
  fi;
  return fail;
end);

BindGlobal("SendControl@", function(type, data)
  SendChannel(ControlChannel@, MakeReadOnlyObj([ type, ThreadID@(), data ]) );
end);

BindGlobal("RegisterThread@", function()
  SendControl@(REGISTER_THREAD@, ThreadInfo@);
end);

BindGlobal("UnregisterThread@", function(is_shell)
  SendControl@(UNREGISTER_THREAD@, is_shell);
end);

BindGlobal("UnregisterBackgroundThread@", function()
  SendControl@(UNREGISTER_THREAD@, false);
end);


BindGlobal("ChannelInputStream@", function(channel)
  return InputTextCustom(channel, function(channel)
    Print("\c");
    SendControl@(EXPECT_INPUT@, CPROMPT());
    return ReceiveChannel(channel);
  end, ReturnTrue);
end);

BindGlobal("ChannelOutputStream@", function()
  local result;
  result := OutputTextCustom([ ], function(state, string)
    SendControl@(HAVE_OUTPUT@, ShallowCopy(string));
  end, ReturnTrue);
  result!.formatting := true;
  return result;
end);

BindGlobal("DirectChannelOutputStream@", function()
  MyOutputPrefix@ := "<";
  Append(MyOutputPrefix@, String(ThreadID@()));
  Append(MyOutputPrefix@, "> ");
  return OutputTextCustom(OutputChannel@, function(channel, string)
    SendChannel(channel,
      [ ThreadID@(), MyOutputPrefix@, ShallowCopy(string) ] );
  end, ReturnTrue);
end);


BindGlobal("NewThreadInfo@", function()
  return AtomicRecord(rec(
    InputChannel := CreateChannel(),
    ControlChannel := CreateChannel(),
    ThreadID := ThreadID@(),
    ThreadObject := CurrentThread(),
  ));
end);

BindGlobal("SetupDefaultStreams@", function()
  UnbindGlobal("DEFAULT_INPUT_STREAM");
  BindGlobal("DEFAULT_INPUT_STREAM", function()
    if not IsBound(InputStream@) then
      if ControlThread@ <> false then
        InputStream@ := InputTextNone();
      else
        if not IsBound(ThreadInfo@) then
          ThreadInfo@ := NewThreadInfo@();
          RegisterThread@();
          AtThreadExit(UnregisterBackgroundThread@);
        fi;
        InputStream@ :=
          ChannelInputStream@(ThreadInfo@.InputChannel);
      fi;
    fi;
    return InputStream@;
  end);

  UnbindGlobal("DEFAULT_OUTPUT_STREAM");
  BindGlobal("DEFAULT_OUTPUT_STREAM", function()
    if not IsBound(OutputStream@) then
      if ControlThread@ then
        OutputStream@ := DirectChannelOutputStream@();
      else
        if not IsBound(ThreadInfo@) then
          ThreadInfo@ := NewThreadInfo@();
          RegisterThread@();
          AtThreadExit(UnregisterBackgroundThread@);
        fi;
        OutputStream@ :=
          ChannelOutputStream@();
      fi;
    fi;
    return OutputStream@;
  end);
end);

BindGlobal("ThreadExit@", function()
  if IsBound(OutputStream@) then
    CloseStream(OutputStream@);
  fi;
  if IsBound(InputStream@) then
    CloseStream(InputStream@);
  fi;
end);

BindGlobal("CompleteThreadRegistration@", function(threadinfo, waitfor)
  local threadid;
  threadid := threadinfo.ThreadID;
  ThreadControlChannel@[threadid] := threadinfo.ControlChannel;
  ThreadInputChannel@[threadid] := threadinfo.InputChannel;
  if not IsBound(ThreadName@[threadid]) then
    ThreadName@[threadid] := Immutable(String(threadid-1));
  fi;
  WaitForThread@[threadid] := waitfor;
  ThreadObject@[threadid] := threadinfo.ThreadObject;
  if not IsBound(OutputHistory@[threadid]) then
    OutputHistory@[threadid] := "";
    OutputHistoryIncompleteLine@[threadid] := false;
    ShownOutput@[threadid] := 0;
    PendingOutput@[threadid] := false;
  fi;
  ShowBackgroundOutput@[threadid] := DefaultShowBackgroundOutput@;
  Prompt@[threadid] := SubstituteVariables@(DefaultPrompt@, threadid);
  OutputPrefixRaw@[threadid] := DefaultOutputPrefix@;
  OutputPrefix@[threadid] :=
    SubstituteVariables@(DefaultOutputPrefix@, threadid);
end);

BindGlobal("StartInteractiveThread@", function()
  local handshake, threadinfo;
  handshake := StartHandShake();
  NumShellThreads@ := NumShellThreads@ + 1;
  CreateThread(function(handshake)
    local threadinfo;
    threadinfo := NewThreadInfo@();
    ThreadInfo@ := threadinfo;
    AcknowledgeHandShake(handshake, threadinfo);
    AtThreadExit(ThreadExit@);
    SESSION();
    UnregisterThread@(true);
  end, handshake);
  threadinfo := CompleteHandShake(handshake);
  CompleteThreadRegistration@(threadinfo, true);
  return threadinfo;
end);

BindGlobal("CullHistory@", function(threadid)
  local newlines, pos, history;
  history := OutputHistory@[threadid];
  newlines := FIND_ALL_IN_STRING(history, "\n");
  if 2 * Length(newlines) >= OutputHistoryLength@ * 3 then
    pos := newlines[Length(newlines)-OutputHistoryLength@]+1;
    OutputHistory@[threadid] :=
      history{[pos..Length(history)]};
  fi;
end);

BindGlobal("OutputContext@", function(lines, thread)
  local history, incomplete, newlines, from;
  history := OutputHistory@[thread];
  incomplete := OutputHistoryIncompleteLine@[thread];
  if incomplete then lines := lines - 1; fi;
  newlines := FIND_ALL_IN_STRING(history, "\n");
  if Length(newlines) > lines then
    from := newlines[Length(newlines)-lines]+1;
    if from > ShownOutput@[thread] then
      from := ShownOutput@[thread];
    fi;
    history := history{[from..Length(history)]};
  else
    history := ShallowCopy(history);
  fi;
  return ReplacedString(history, "\r", "");
end);

BindGlobal("PrintContext@", function(lines, thread)
  local history;
  history := OutputContext@(lines, thread);
  SendChannel(OutputChannel@, [ thread, OutputPrefix@[thread], history ]);
end);

BindGlobal("AddOutput@", function(threadid, text, is_prompt, deferred)
  local incomplete_line, history;
  text := ShallowCopy(text);
  NORMALIZE_NEWLINES(text);
  if is_prompt then
    Add(text, '\r');
  fi;
  MakeImmutable(text);
  incomplete_line := not EndsWith(text, "\n");
  history := OutputHistory@[threadid];
  Append(history, text);
  OutputHistoryIncompleteLine@[threadid] := incomplete_line;
  if not deferred then
    if threadid = ActiveThread@ or ShowBackgroundOutput@[threadid] then
      SendChannel(OutputChannel@,
        [ threadid, OutputPrefix@[threadid], text ] );
      CullHistory@(threadid);
      ShownOutput@[threadid] := Length(history);
      PendingOutput@[threadid] := false;
    else
      PendingOutput@[threadid] := true;
    fi;
  fi;
end);

BindGlobal("AddOutputCommand@", function(threadid, text)
  local history;
  if StartsWith(text, "!") and OutputHistoryIncompleteLine@[threadid] then
    DelayedPrompt@ := OutputContext@(1, threadid);
  fi;
  text := ShallowCopy(text);
  if not EndsWith(text, "\n") then
    Add(text, '\n');
  fi;
  history := OutputHistory@[threadid];
  Append(history, text);
  if threadid = ActiveThread@ then
    if OutputHistoryIncompleteLine@[threadid] then
      SendChannel(OutputChannel@,
        [ threadid, OutputPrefix@[threadid], 0 ]);
    fi;
    OutputHistoryIncompleteLine@[threadid] := false;
    CullHistory@(threadid);
    ShownOutput@[threadid] := Length(history);
    PendingOutput@[threadid] := false;
  fi;
end);

BindGlobal("WritePrompt@", function()
  if NeedPrompt@ then
    if OutputHistoryIncompleteLine@[ActiveThread@] then
      PrintContext@(1, ActiveThread@);
      DelayedPrompt@ := "";
      NeedPrompt@ := false;
    elif DelayedPrompt@ <> "" then
      AddOutput@(ActiveThread@, DelayedPrompt@, true, false);
      DelayedPrompt@ := "";
      NeedPrompt@ := false;
    fi;
  fi;
end);

BindGlobal("SwitchToThread@", function(thread)
  local history, shown;
  if DelayedPrompt@ <> "" then
    AddOutput@(ActiveThread@, DelayedPrompt@, true, true);
    DelayedPrompt@ := "";
  fi;
  ActiveThread@ := thread;
  SystemMessage@("Switching to thread ", thread-1);
  shown := ShownOutput@[thread];
  history := OutputHistory@[thread];
  if shown <> Length(history) then
    SendChannel(OutputChannel@,
      [ thread, OutputPrefix@[thread],
        history{[shown+1..Length(history)]} ] );
    CullHistory@(thread);
    ShownOutput@[thread] := Length(history);
    NeedPrompt@ := false;
  fi;
end);

BindGlobal("CommandTable@", DictionaryByList(true));
BindGlobal("AliasTable@", DictionaryByList(true));
atomic Region@ do
  MigrateObj(CommandTable@, Region@);
  MigrateObj(AliasTable@, Region@);
od;

BindGlobal("GetArg@", function(string)
  local arg, ch, i;
  while Length(string) > 0 and (string[1] = ' ' or string[1] = '\t') do
    Remove(string, 1);
  od;
  i := 1;
  while i <= Length(string) do
    ch := string[i];
    if ch = ' ' or ch = '\t' then
      arg := string{[1..i-1]};
      while i <= Length(string) do
        ch := string[i];
        if ch <> ' ' and ch <> '\t' then
          return [arg, string{[i..Length(string)]}];
        fi;
        i := i + 1;
      od;
      return [arg, ""];
    fi;
    i := i + 1;
  od;
  return [string, ""];
end);

DeclareGlobalFunction("RunCommand@");
DeclareGlobalFunction("RunCommandQuietly@");

BindGlobal("NameThread@", function(threadid, name)
  if IsBound(ThreadNameToID@.(name)) then
    SystemMessage@("The name '", name, "' is already in use by thread ",
      ThreadNameToID@.(name)-1);
    return;
  fi;
  if IsBound(ThreadName@[threadid]) then
    Unbind(ThreadNameToID@.(ThreadName@[threadid]));
  fi;
  ThreadName@[threadid] := Immutable(ShallowCopy(name));
  ThreadNameToID@.(name) := threadid;
  OutputPrefix@[threadid] :=
    SubstituteVariables@(OutputPrefixRaw@[threadid], threadid);
  SystemMessage@("Renamed thread ", threadid-1, " as ", name);
end);

BindGlobal("CommandShell@", function(line)
  local threadinfo;
  threadinfo := StartInteractiveThread@();
  if line <> "" then
    NameThread@(threadinfo.ThreadID, line);
  fi;
  SwitchToThread@(threadinfo.ThreadID);
end);

BindGlobal("CommandFork@", function(line)
  local threadinfo;
  threadinfo := StartInteractiveThread@();
  if line <> "" then
    NameThread@(threadinfo.ThreadID, line);
  fi;
  SystemMessage@("Created new thread ", threadinfo.ThreadID-1);
end);

BindGlobal("CommandList@", function(line)
  local threadid, pending;
  for threadid in [1..Length(ThreadName@)] do
    if IsBound(ThreadName@[threadid]) then
      pending := "";
      if PendingOutput@[threadid] then
        pending := " (pending output)";
      fi;
      SystemMessage@("Thread ", ThreadName@[threadid],
        " [", threadid-1, "]", pending);
    fi;
  od;
end);

BindGlobal("CommandName@", function(line)
  local values, thread;
  values := GetArg@(line);
  thread := FindThread@(values[1]);
  if thread = fail then
    SystemMessage@("Unknown thread ", values[1]);
    return;
  fi;
  NameThread@(thread, values[2]);
end);

BindGlobal("CommandInfo@", function(line)
  local thread;
  thread := FindThread@(line);
  if thread = fail then
    SystemMessage@("Unknown thread ", line);
    return;
  fi;
end);

BindGlobal("ThreadNumFromString@", function(str)
  local i;
  if str = "" then
    return fail;
  else
    for i in [1..Length(str)] do
      if str[i] < '0' or str[i] > '9' then
        return fail;
      fi;
    od;
    return SMALLINT_STR(str);
  fi;
end);

BindGlobal("CommandKill@", function(line)
  local thread;
  thread := ThreadNumFromString@(line);
  if thread = fail then
    SystemMessage@("Unknown thread ", line);
    return;
  elif thread = ActiveThread@ - 1 then
    SystemMessage@("Cannot kill active thread");
    return;
  fi;
  KillThread(thread);
end);

BindGlobal("CommandPause@", function(line)
  local thread;
  thread := ThreadNumFromString@(line);
  if thread = fail then
    SystemMessage@("Unknown thread ", line);
    return;
  fi;
  PauseThread(thread);
end);

BindGlobal("CommandResume@", function(line)
  local thread;
  thread := ThreadNumFromString@(line);
  if thread = fail then
    SystemMessage@("Unknown thread ", line);
    return;
  fi;
  ResumeThread(thread);
end);

BindGlobal("CommandBreak@", function(line)
  local thread;
  if line = "" then
    thread := ActiveThread@-1;
  else
    thread := ThreadNumFromString@(line);
  fi;
  if thread = fail then
    SystemMessage@("Unknown thread ", line);
    return;
  fi;
  InterruptThread(thread, 0);
end);


BindGlobal("CommandHide@", function(line)
  local thread;
  if line = "*" then
    DefaultShowBackgroundOutput@ := false;
  elif line = "" then
    ShowBackgroundOutput@[ActiveThread@] := false;
  else
    thread := FindThread@(line);
    if thread = fail then
      SystemMessage@("Unknown thread ", line);
      return;
    fi;
    ShowBackgroundOutput@[thread] := false;
  fi;
end);

BindGlobal("CommandWatch@", function(line)
  local thread;
  if line = "*" then
    DefaultShowBackgroundOutput@ := true;
  elif line = "" then
    ShowBackgroundOutput@[ActiveThread@] := true;
  else
    thread := FindThread@(line);
    if thread = fail then
      SystemMessage@("Unknown thread ", line);
      return;
    fi;
    ShowBackgroundOutput@[thread] := true;
  fi;
end);

BindGlobal("CommandKeep@", function(line)
  local ch;
  line := NormalizedWhitespace(line);
  for ch in line do
    if ch < '0' or ch > '9' then
      SystemMessage@("Non-numeric argument");
      return;
    fi;
  od;
  OutputHistoryLength@ := SMALLINT_STR(line);
end);

BindGlobal("CommandPrompt@", function(line)
  local values, thread;
  values := GetArg@(line);
  if values[1] = "*" then
    DefaultPrompt@ := values[2];
    SystemMessage@("New default prompt: ", values[2]);
  else
    thread := FindThread@(line);
    if thread = fail then
      SystemMessage@("Unknown thread ", line);
      return;
    fi;
    Prompt@[thread] := SubstituteVariables@(values[2], thread);
    SystemMessage@("New prompt for thread ", values[1], ": ", values[2]);
  fi;
end);

BindGlobal("CommandPrefix@", function(line)
  local values, thread;
  values := GetArg@(line);
  if values[1] = "*" then
    DefaultOutputPrefix@ := values[2];
    SystemMessage@("New default output prefix: ", values[2]);
  else
    thread := FindThread@(line);
    if thread = fail then
      SystemMessage@("Unknown thread ", line);
      return;
    fi;
    OutputPrefixRaw@[thread] := values[2];
    OutputPrefix@[thread] := SubstituteVariables@(values[2], thread);
    SystemMessage@("New output prefix for thread ", values[1], ": ", values[2]);
  fi;
end);

BindGlobal("CommandSelect@", function(line)
  local thread;
  thread := FindThread@(line);
  if thread = fail then
    SystemMessage@("Unknown thread ", line);
  else
    if thread = ActiveThread@ then
      SystemMessage@(line, " is already the active thread");
    else
      SwitchToThread@(thread);
    fi;
  fi;
end);

BindGlobal("CommandNext@", function(line)
  local i;
  i := ActiveThread@+1;
  while i <> ActiveThread@ do
   if i > Length(ThreadName@) then
     i := 1;
   fi;
   if i <> ActiveThread@ then
     if IsBound(ThreadName@[i]) then
       SwitchToThread@(i);
       return;
     fi;
   fi;
   i := i + 1;
  od;
  SystemMessage@("There is only one running thread");
end);

BindGlobal("CommandPrevious@", function(line)
  local i;
  i := ActiveThread@-1;
  while i <> ActiveThread@ do
   if i < 1 then
     i := Length(ThreadName@);
   fi;
   if i <> ActiveThread@ then
     if IsBound(ThreadName@[i]) then
       SwitchToThread@(i);
       return;
     fi;
   fi;
   i := i - 1;
  od;
  SystemMessage@("There is only one running thread");
end);

BindGlobal("CommandReplay@", function(line)
  local values, num, thread, history, newlines;
  values := GetArg@(line);
  num := SMALLINT_STR(values[1]);
  if num = 0 then
    num := 20;
  fi;
  if num > OutputHistoryLength@ then
    num := OutputHistoryLength@;
  fi;
  SystemMessage@("Last ", num, " lines of output");
  if values[2] = "" then
    thread := ActiveThread@;
  else
    thread := FindThread@(values[2]);
    if thread = fail then
      SystemMessage@("Unknown thread ", values[2]);
      return;
    fi;
  fi;
  history := ShallowCopy(OutputHistory@[thread]);
  if not EndsWith(history, "\n") and not EndsWith(history, "\r") then
    Add(history, '\n');
  fi;
  history := ReplacedString(history, "\r", "");
  newlines := FIND_ALL_IN_STRING(history, "\n");
  if num < Length(newlines) then
    history :=
      history{[newlines[Length(newlines)-num]+1 .. Length(history)]};
  fi;
  SendChannel(OutputChannel@,
    [ thread, OutputPrefix@[thread], history ] );
end);

BindGlobal("CommandSource@", function(line)
  local file, command;
  file := InputTextFile(line);
  if file = fail then
    SystemMessage@("Could not open ", line);
  else
    while true do
      command := ReadLine(file);
      if command = fail then
        CloseStream(file);
        return;
      fi;
      command := Chomp(command);
      if not StartsWith(command, "#") then
        while StartsWith(command, " ") or StartsWith(command, "\t") do
          command := command{[2..Length(command)]};
        od;
        RunCommandQuietly@(command);
      fi;
    od;
  fi;
end);

BindGlobal("CommandAlias@", function(line)
  local values, alias, header;
  atomic Region@ do
    values := GetArg@(line);
    if values[1] = "" then
      header := false;
      for alias in SortedList(ListKeyEnumerator(AliasTable@)) do
        if not header then
          SystemMessage@("Aliases:");
          header := true;
        fi;
        SystemMessage@("  ", alias, " = ",
          LookupDictionary(AliasTable@, alias));
      od;
      if not header then
        SystemMessage@("No aliases have been defined.");
      fi;
    elif values[2] = "" then
      if KnowsDictionary(AliasTable@, values[1]) then
        SystemMessage@("Alias: ", values[1], " = ",
          LookupDictionary(AliasTable@, values[1]));
      else
        SystemMessage@("Unknown alias: ", values[1]);
      fi;
    else
      RemoveDictionary(AliasTable@, values[1]);
      WITH_TARGET_REGION(AliasTable@, function()
        AddDictionary(AliasTable@, values[1], MakeImmutable(values[2]));
      end);
      SystemMessage@("Alias: ", values[1], " = ", values[2]);
    fi;
  od;
end);

BindGlobal("CommandUnalias@", function(line)
  local alias;
  atomic Region@ do
    if KnowsDictionary(AliasTable@, line) then
      alias := LookupDictionary(AliasTable@, line);
      RemoveDictionary(AliasTable@, line);
      SystemMessage@("Removed alias: ", line, " = ", alias);
    else
      SystemMessage@("Unknown alias: ", line);
    fi;
  od;
end);

BindGlobal("CommandEval@", function(line)
  EvalString(line);
end);

BindGlobal("CommandRun@", function(line)
  local func, values;
  values := GetArg@(line);
  if not IsBoundGlobal(values[1]) then
    SystemMessage@("No such function: ", values[1]);
  else
    func := ValueGlobal(values[1]);
    if not IsFunction(func) then
      SystemMessage@("Not a function: ", values[1]);
    else
      func(values[2]);
    fi;
  fi;
end);

BindGlobal("CommandQUIT@", function(line)
  TERMINAL_CLOSE();
  ForceQuitGap();
end);

BindGlobal("InitializeCommands@", function()
  local commands, keyvalue;
  commands := MakeImmutable([
    [ "shell", CommandShell@ ],
    [ "fork", CommandFork@ ],
    [ "list", CommandList@ ],
    [ "name", CommandName@ ],
    [ "info", CommandInfo@ ],
    [ "hide", CommandHide@ ],
    [ "watch", CommandWatch@ ],
    [ "keep", CommandKeep@ ],
    [ "kill", CommandKill@ ],
    [ "break", CommandBreak@ ],
    [ "pause", CommandPause@ ],
    [ "resume", CommandResume@ ],
    [ "prefix", CommandPrefix@ ],
    [ "select", CommandSelect@ ],
    [ "next", CommandNext@ ],
    [ "previous", CommandPrevious@ ],
    [ "replay", CommandReplay@ ],
    [ "source", CommandSource@ ],
    [ "alias", CommandAlias@ ],
    [ "unalias", CommandUnalias@ ],
    [ "eval", CommandEval@ ],
    [ "run", CommandRun@ ],
    [ "QUIT", CommandQUIT@ ],
  ]);
  for keyvalue in commands do
    AddDictionary(CommandTable@, keyvalue[1], keyvalue[2]);
  od;
end);

atomic Region@ do
  WITH_TARGET_REGION(CommandTable@, function()
    InitializeCommands@();
  end);
od;

DeclareGlobalFunction("RunCommandWithAliases@"); # Needed for recursion

InstallGlobalFunction("RunCommandWithAliases@", function(string, aliases)
  local values, command, arguments, choices, func, c, recursive;
  values := GetArg@(string);
  command := values[1];
  if Length(command) > 0 and IsDigitChar(command[1]) then
    arguments := command;
    command := "select";
  else
    arguments := values[2];
  fi;
  choices := Set([]);
  # This has to be a read-write lock for now or dynamic retyping of lists
  # will not work and create problems.
  recursive := false;
  atomic Region@ do
    for c in ListKeyEnumerator(CommandTable@) do
      if StartsWith(c, command) then
        AddSet(choices, c);
        func := LookupDictionary(CommandTable@, c);
      fi;
    od;
    for c in ListKeyEnumerator(AliasTable@) do
      if StartsWith(c, command) then
        if c in aliases then
          recursive := true;
        else
          AddSet(choices, c);
          func := LookupDictionary(AliasTable@, c);
        fi;
      fi;
    od;
  od;
  if Length(choices) = 0 then
    if recursive then
      SystemMessage@("Recursive alias: ", command, ".");
    else
      SystemMessage@("No such command: ", command, ".");
    fi;
  elif Length(choices) > 1 then
    SystemMessage@("Ambiguous command: ", command, " (",
      JoinStringsWithSeparator(choices, ", "), ")");
  else
    if IsString(func) then
      AddSet(aliases, choices[1]);
      command := "!";
      Append(command, func);
      if arguments <> "" then
        Add(command, ' ');
        Append(command, arguments);
      fi;
      RunCommandWithAliases@(command, aliases);
      RemoveSet(aliases, choices[1]);
    else
      func(arguments);
    fi;
  fi;
end);

InstallGlobalFunction("RunCommand@", function(string)
  if StartsWith(string, "!") then
    string := string{[2..Length(string)]};
  fi;
  RunCommandWithAliases@(string, Set([]));
  WritePrompt@();
end);

InstallGlobalFunction("RunCommandQuietly@", function(string)
  if StartsWith(string, "!") then
    string := string{[2..Length(string)]};
  fi;
  RunCommandWithAliases@(string, Set([]));
end);

BindGlobal("MainLoop@", function(mainthreadinfo)
  local packet, command, threadid, data;
  ControlThread@ := true;
  InitThreadTables@();
  CompleteThreadRegistration@(mainthreadinfo, false);
  ActiveThread@ := mainthreadinfo.ThreadID;
  OutputPrefix@[ActiveThread@] := "";
  while true do
    packet := ReceiveChannel(ControlChannel@);
    command := packet[1];
    threadid := packet[2];
    data := packet[3];
    if command = HAVE_OUTPUT@ then
      AddOutput@(threadid, data, false, false);
    elif command = HAVE_INPUT@ then
      AddOutputCommand@(ActiveThread@, data);
      NeedPrompt@ := true;
      if StartsWith(data, "!") then
        RunCommand@(Chomp(data));
      else
        if IsBound(ThreadInputChannel@[ActiveThread@]) then
          SendChannel(ThreadInputChannel@[ActiveThread@], data);
        else
          SystemMessage@("Attempting to send input to dead background thread");
        fi;
      fi;
    elif command = EXPECT_INPUT@ then
      AddOutput@(threadid, data, true, false);
    elif command = REGISTER_THREAD@ then
      CompleteThreadRegistration@(data, false);
    elif command = UNREGISTER_THREAD@ then
      if data then
        # shell thread
        NumShellThreads@ := NumShellThreads@ - 1;
        Unbind(ThreadNameToID@.(ThreadName@[threadid]));
        Unbind(ThreadName@[threadid]);
      else
        if OutputHistoryIncompleteLine@[threadid] then
          AddOutput@(threadid, "\n", false, false);
        fi;
        AddOutput@(threadid,
          "### Background thread terminated. ###\n", false, false);
      fi;
      # enable garbage collector to collect channels
      Unbind(ThreadControlChannel@[threadid]);
      Unbind(ThreadInputChannel@[threadid]);
      # Make sure the thread can't be found anymore.
      # wait for any threads we started ourselves
      if WaitForThread@[threadid] then
        WaitThread(ThreadObject@[threadid]);
      fi;
      if NumShellThreads@ = 0 then
        # say goodnight, Gracie
        AcknowledgeHandShake(ProgramShutdown@, true);
        return;
      fi;
      if threadid = ActiveThread@ then
        CommandNext@("");
        WritePrompt@();
      fi;
    else
      # should never get here
    fi;
  od;
end);

BindGlobal("InputLoop@", function()
  local stdin, line;
  ControlThread@ := true;
  stdin := INPUT_TEXT_FILE("*stdin*");
  while true do
    line := READ_LINE_FILE(stdin);
    if line = fail then
      SendControl@(HAVE_INPUT@, "");
      # Ensure we don't just busy loop
      MicroSleep(10000);
    elif line <> "" then
      SendControl@(HAVE_INPUT@, line);
    fi;
  od;
end);

BindGlobal("OutputLoop@", function()
  local packet, threadid, prefix, text, stdout, newlines,
    eol, last_thread, p, last, line, prompt;
  stdout := OUTPUT_TEXT_FILE("*stdout*", false, false);
  ControlThread@ := true;
  last_thread := false;
  eol := true;
  while true do
    packet := ReceiveChannel(OutputChannel@);
    threadid := packet[1];
    prefix := packet[2];
    text := packet[3];
    # if we switched threads, then we may just have to break lines up
    if threadid <> last_thread and not eol and IsString(text) then
      WRITE_STRING_FILE_NC(stdout, ">>\n");
      eol := true;
    fi;
    last_thread := threadid;
    if not IsString(text) then
      text := "";
      eol := true;
    fi;
    # process text line by line, prefixing each new line
    newlines := FIND_ALL_IN_STRING(text, "\r\n");
    last := 1;
    for p in newlines do
      line := text{[last..p]};
      prompt := text[p] = '\r';
      if prompt then
        line := text{[last..p-1]};
      fi;
      if eol then
        WRITE_STRING_FILE_NC(stdout, prefix);
      fi;
      WRITE_STRING_FILE_NC(stdout, line);
      last := p + 1;
      eol := true;
    od;
    # and any trailing text without a final newline
    if last <= Length(text) then
      p := Length(text);
      line := text{[last..p]};
      prompt := text[p] = '\r';
      if prompt then
        line := text{[last..p-1]};
      fi;
      if eol then
        WRITE_STRING_FILE_NC(stdout, prefix);
      fi;
      WRITE_STRING_FILE_NC(stdout, line);
      eol := false;
    fi;
  od;
end);

BindGlobal("MULTI_SESSION", function()
  SetupDefaultStreams@();
  BindGlobal("InputThreadID@", CreateThread(InputLoop@));
  BindGlobal("OutputThreadID@", CreateThread(OutputLoop@));
  StartHandShake();
  ThreadInfo@ := NewThreadInfo@();
  BindGlobal("ControlThreadID@", CreateThread(MainLoop@, ThreadInfo@));
  SESSION();
  UnregisterThread@(true);
  CompleteHandShake(ProgramShutdown@);
  PROGRAM_CLEAN_UP();
  TERMINAL_CLOSE();
  QuitGap();
end);

BindGlobal("ConsoleUIRegisterCommand", function(name, func)
  atomic Region@ do
    AddDictionary(CommandTable@, name, func);
  od;
end);

BindGlobal("ConsoleUIForegroundThread", function()
  return ActiveThread@-1;
end);

BindGlobal("ConsoleUIForegroundThreadName", function()
  return ThreadName@[ActiveThread@];
end);

BindGlobal("ConsoleUISelectThread", function(thread)
  SwitchToThread@(thread+1);
end);

BindGlobal("ConsoleUIOutputHistory", function(thread, lines)
  if not IsBound(ThreadName@[thread+1]) then
    return fail;
  fi;
  return OutputContext@(lines, thread+1);
end);

BindGlobal("ConsoleUISetOutputHistoryLength", function(lines)
  OutputHistoryLength@ := lines;
end);

BindGlobal("ConsoleUINewSession", function(foreground, name)
  if foreground then
    CommandShell@(name);
  else
    CommandFork@(name);
  fi;
end);

BindGlobal("ConsoleUIRunCommand", function(command)
  RunCommandQuietly@(command);
end);

BindGlobal("ConsoleUIWritePrompt", function()
  WritePrompt@();
end);


LEAVE_NAMESPACE();

