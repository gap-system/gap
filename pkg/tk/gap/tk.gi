#############################################################################
##
#W  tk.gi                  Tk share package                   Max Neunhoeffer
##
#H  @(#)$Id: tk.gi,v 1.9 2003/08/15 14:39:40 gap Exp $
##
#Y  Copyright 2001,       Max Neunhoeffer,              Aachen,       Germany
##
##  Package to connect GAP to Tcl/Tk.
##

Revision.pkg_tk_gap_tk_gi :=
    "@(#)$Id: tk.gi,v 1.9 2003/08/15 14:39:40 gap Exp $";


#############################################################################
##
#R  A representation for our widgets:
##
DeclareRepresentation("IsTkWidget",IsComponentObjectRep,
   ["name","type","parent"],
   IsTkObj);
##
#R  And one for items in a canvas:
##
DeclareRepresentation("IsTkItem",IsComponentObjectRep,
   ["name","type","parent"],
   IsTkObj);


#############################################################################
##
#V  A few global variables for this package:
##
InstallValue(TkVars,rec());
##
##  A serial number for graphic objects. The list wrapper is to be able
##  to change this afterwards:
##
TkVars.SerialNr := 1;
##
##  A list for all callbacks and a list for its arguments:
##
TkVars.Callbacks := [];
TkVars.CbArgs := [];
##
##  The stream to the wish windowing shell. Again in a list to be able to
##  change it afterwards:
##
TkVars.Stream := fail;
##
##  The return code of the last call to Tk:
##  Note that the last error message as a string is in the global
##  writable variable `TkError':
##
TkVars.ErrorCode := 0;
##
##  A buffer for our stream handler function which is installed in
##  `OnCharReadHook':
##
TkVars.StreamHandlerBuffer := "";
##
##  For TkProcessEvents:
##
TkVars.Done := false;
##
##  The following flag controls, whether we execute events or just save
##  them:
##
TkVars.ExecuteEvents := true;
##
##  If ExecuteEvents is false, we collect events here:
##
TkVars.EventQueue := [];


############################################################################
##
##  From here on the variables are public:
##
##  Plain text of last error message from Tk:
##
TkError := "";
##
##  Global variable holding the object for the Tk root window, if
##  already initialized:
##
TkRootWindow := fail;
##
##  The list of possible widget types:
##
InstallValue(TkPossibleWidgetTypes,
  Set([ "frame", "toplevel", "label", "button", "checkbutton", "radiobutton",
    "message", "listbox", "scrollbar", "scale", "entry", "menu", "menubutton",
    "canvas", "text" ]));
##
##  The list of possible item types:
##
InstallValue(TkPossibleItemTypes,
  Set([ "arc", "bitmap", "image", "line", "oval", "polygon", "rectangle",
    "text", "window" ]));


#############################################################################
##
##  Some helper functions:
##
##  Searches for a substring:
InstallGlobalFunction(TkSubStringPos,
function(st,sub)
  local i,j;
  i := 1;
  while i < Length(st) do
    if st[i] = sub[1] then
      j := 1;
      while i+j <= Length(st) and 1+j <= Length(sub) and st[i+j] = sub[1+j] do
        j := j + 1;
      od;
      if 1+j > Length(sub) then
        return i;
      fi;
    fi;
    i := i + 1;
  od;
  return fail;
end);

## Makes a command string from a record:
InstallGlobalFunction(TkRecToStr,
function(r)
  local com,n,st;
  com := "";

  for n in RecNames(r) do
    Append(com," -");
    if n = "In" then    # this is an exception!
      Append(com,"in");
    else
      Append(com,n);
    fi;
    Append(com," ");
    st := String(r.(n));
    if Position(st,' ') <> fail or Position(st,'\t') <> fail or
       Position(st,'[') <> fail or Position(st,']') <> fail or
       Position(st,'\"') <> fail or Position(st,'\'') <> fail or
       Position(st,'{') <> fail or Position(st,'}') <> fail or
       st = "" then
      Append(com,TkQuote(st));
    else
      Append(com,st);
    fi;
  od;

  return com;
end);

# Strictly internal used to handle certain record components:
InstallGlobalFunction(TkComToStr,
function(o,command,commandargs,text)
  local com,p;

  com := Concatenation(" ",text," ");
  if IsString(command) then
    # First substitute "!NAME!":
    p := TkSubStringPos(command,"!NAME!");
    if p <> fail then
      Append(com,command{[1..p-1]});
      Append(com,o!.name);
      Append(com,command{[p+6..Length(command)]});
    else
      Append(com,command);
    fi;
  else
    Append(com,"{ puts \"callb ");
    Append(com,String(Length(TkVars.Callbacks)+1));
    Append(com,"\" }");
    Add(TkVars.Callbacks,command);
    Add(TkVars.CbArgs,commandargs);
    Add(o!.callbacks,Length(TkVars.Callbacks));
  fi;
  return com;
end);

# Put quotes around string:
#InstallGlobalFunction(TkQuote,
#function(st)
#  st := SubstitutionSublist(st,"}","\\}");
#  st := SubstitutionSublist(st,"{","\\{");
#  return Concatenation("{",st,"}");
#end);

# Put quotes around string:
InstallGlobalFunction(TkQuote,
function(st)
  local stnew,c;
  stnew := "{";
  for c in st do
      if st = '}' then Append(stnew,"\\}");
      elif st = '{' then Append(stnew,"\\{");
      else Add(stnew,c);
      fi;
  od;
  Add(stnew,'}');
  return stnew;
end);


############################################################################
##
##  Functions used to communicate with Tk:
##
############################################################################
##
#F  TkReadLine( ) . . . . . . . . . . . . . . . . . . .  read a line from Tk
##
##  Tries to read from the stream to the wish process. If the process
##  died, `fail' is returned and everything is closed. Note that from
##  then on all graphic objects are no longer available! Otherwise
##  we read until a full line is there. End of line character(s) are
##  discarded and a string with the line is returned. If lines with
##  event information is read, they are processed immediately and another
##  line is read.
##
InstallGlobalFunction(TkReadLine,
function()
  local reply,   # here we collect the reply
        line,    # here we read a chunk
        fdsin;   # for UNIXSelect
  repeat
    reply := "";
    fdsin := [FileDescriptorOfStream(TkVars.Stream)];
    repeat
      UNIXSelect(fdsin,[],[],fail,fail);
      if IsEndOfStream(TkVars.Stream) then
        TkShutdown();
        Info(TkInfo,2,"The wish process has died!");
        TkError := "The wish process has died!";
        return fail;
      fi;
      line := ReadLine(TkVars.Stream);
      #Print("Check: line: ",line,"\n");
      Append(reply,line);
    until Length(reply) > 0 and reply[Length(reply)] = '\n';
    if Length(reply) > 1 and reply[Length(reply)-1] = '\r' then
      reply := reply{[1..Length(reply)-2]};
    else
      reply := reply{[1..Length(reply)-1]};
    fi;

    # Just for debugging: 
    #Print("TkReadline:",reply,"\n");
    # Is this an event?
    if Length(reply) >= 6 and 
       (reply{[1..6]} = "callb " or reply{[1..6]} = "event ") then
      TkProcessEvent(reply);
      reply := fail;   # this means: nothing so far!
    fi;
  until reply <> fail;
  return reply;
end);


############################################################################
##
#F  TkProcessEvent( <e> ) . . . . . . . . . . . . . . . . . process an event
##
##  An `event' is something that happened via the graphical interface. This
##  leads to a callback of some GAP function. The one argument <e> is a
##  string which is converted to a record for the handler function.
##
InstallGlobalFunction(TkProcessEvent,
function(e)
  local nr,p,q,ev,l;

  if not(TkVars.ExecuteEvents) then
    Add(TkVars.EventQueue,e);
    return;
  fi;

  TkVars.ExecuteEvents := false;

  # First the case of a `command' of some button or so:
  if e{[1..6]} = "callb " then
    nr := Int(e{[7..Length(e)]});
    if nr <> fail and IsBound(TkVars.Callbacks[nr]) then
      CallFuncList(TkVars.Callbacks[nr],TkVars.CbArgs[nr]);
    fi;
  # Now an event from some `bind' call:
  elif e{[1..6]} = "event " then
    q := 6; p := Position(e,',',q);
    nr := Int(e{[q+1..p-1]});    # The number of the callback
    q := p; p := Position(e,',',q);
    ev := rec();
    ev.serial := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.above  := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.button := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.count  := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.detail := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.focus  := e{[q+1..p-1]} = "1"; q := p; p := Position(e,',',q);
    ev.height := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.keycode := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.mode   := e{[q+1..p-1]} = "1"; q := p; p := Position(e,',',q);
    ev.override_redirect := e{[q+1..p-1]} = "1"; q := p; p := Position(e,',',q);
    ev.place  := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.state  := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.time   := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.width  := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.x      := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.y      := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.ascii  := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.border_width := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.delta  := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.send_event := e{[q+1..p-1]} = "1"; q := p; p := Position(e,',',q);
    ev.keysym := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.keysumnum := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.root   := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.subwindow := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.type   := Int(e{[q+1..p-1]}); q := p; p := Position(e,',',q);
    ev.window := e{[q+1..p-1]}; q := p; p := Position(e,',',q);
    ev.xroot  := Int(e{[q+1..p-1]}); q := p; p := Length(e)+1;
    ev.yroot  := Int(e{[q+1..p-1]});
    if IsBound(TkVars.Callbacks[nr]) then
      l := [ev];
      Append(l,TkVars.CbArgs[nr]);
      CallFuncList(TkVars.Callbacks[nr],l);
    fi;
  fi;

  TkVars.ExecuteEvents := true;

end);


############################################################################
##
#F  TkProcessQueue( <cmd> ) . . . . . . . . . . . . . process pending events
##
##  Must be called with TkVars.ExecuteEvents = true!
##  
InstallGlobalFunction(TkProcessQueue,
function()
  local e,l;
  while Length(TkVars.EventQueue) > 0 do
    e := TkVars.EventQueue[1];
    l := TkVars.EventQueue;
    l{[1..Length(l)-1]} := l{[2..Length(l)]};
    Unbind(l[Length(l)]);
    TkProcessEvent(e);
  od;
end);


############################################################################
##
#F  TkCmd( <cmd> ) . . . . . . . . . . . . . . . . . .  send a command to Tk
##
##  Sends the string <cmd> to Tk. Handles errors nicely. Waits for the
##  answer, and sets `TkVars.ErrorCode' and `TkError':
##
InstallGlobalFunction(TkCmd,
function(cmd)
  local reply,saveExecuteEvents;

  saveExecuteEvents := TkVars.ExecuteEvents;
  TkVars.ExecuteEvents := false;

  cmd := Concatenation("catch { ",cmd," } GAPTkError");
  WriteLine(TkVars.Stream,cmd);
  reply := TkReadLine();
  if reply = fail then
    return fail;   # the wish process died
  fi;
  
  # We want the output in GAPTkError:
  WriteLine(TkVars.Stream,"puts $GAPTkError");
  if reply = "0" then
    reply := TkReadLine();
  else
    # Here we have to return an error:
    TkVars.ErrorCode := Int(reply);
    reply := TkReadLine();    # get the error message
    if reply <> fail then
      TkError := reply;
      Info(TkInfo,2,TkError);
    fi;
    reply := fail;
  fi;

  TkVars.ExecuteEvents := saveExecuteEvents;
  if TkVars.ExecuteEvents then
    TkProcessQueue();
  fi;

  return reply;
end);


############################################################################
##
#F  TkStreamHandler( <a> ) . . . . . . . . . . . . . . . handle stream input
##
##  This is installed as a handler for the CharReadHook. It is called during
##  reading of the GAP command line if the stream sends something. We mainly
##  want to process events and call callbacks.
##
InstallGlobalFunction(TkStreamHandler,
function(a)
  local text,line,p;

  if IsEndOfStream(TkVars.Stream) then
    # the wish process has died!
    TkShutdown();
    Info(TkInfo,2,"The wish process has died!");
    return;
  fi;

  # we call `ReadLine' once and append:
  text := TkVars.StreamHandlerBuffer;
  line := ReadLine(TkVars.Stream);
  if line <> fail then
    Append(text,line);
  fi;
  #Print("Got:",line,"\n");

  # if we have a full line, we process the event:
  p := Position(text,'\n');
  while p <> fail do
    if p > 2 and text[p-1] = '\r' then   # For M$-People!
      line := text{[1..p-2]};
    else
      line := text{[1..p-1]};
    fi;
    text := text{[p+1..Length(text)]};  # this is still to be processed
    # Just for debugging: Print("TkStreamHandler:",line,"\n");
    # We ignore lines that cannot be an event:
    if Length(line) >= 6 then 
      TkProcessEvent(line); 
    fi;
    p := Position(text,'\n');
  od;

  # store for the next round:
  TkVars.StreamHandlerBuffer := text;   # for the next round!

  # do events that might have come up:
  if TkVars.ExecuteEvents then
    TkProcessQueue();
  fi;
end);


############################################################################
##
##  Functions to be called by the user of this package:
##
############################################################################


############################################################################
##
#F  TkInit( ) . . . . . . . . . . . . . . . . . . .  initialize wish process
##
##  The wish process is started, and all data structures are initialized.
##  The user can call this but does not have to, because it is called
##  automatically from all other functions if not yet done.
##  Returns `true' on success or if already initizalized and `fail'
##  otherwise.
##
InstallGlobalFunction(TkInit,
function()
  local wishname;
  
  if TkVars.Stream <> fail then
    return true;
  fi;
  
  wishname := Filename(DirectoriesSystemPrograms(),"wish");
  if wishname = fail then
    Info(TkInfo,1,"The wish executable was not found!");
    TkError := "The wish executable was not found!";
    return fail;
  fi;
  TkVars.Stream := InputOutputLocalProcess(DirectoryCurrent(),wishname,[]);
  if TkVars.Stream = fail then
    Info(TkInfo,1,"The wish process could not be launched!");
    TkError := "The wish process could not be launched!";
    return fail;
  fi;
  
  WriteLine(TkVars.Stream,"set tcl_prompt1 { }");
  TkReadLine();
  WriteLine(TkVars.Stream,"set tcl_prompt2 { }");
  TkReadLine();
  
  InstallCharReadHookFunc(TkVars.Stream,"r",TkStreamHandler);
  
  TkRootWindow := rec(name := ".", type := "root", parent := fail, 
                      callbacks := [] );
  Objectify(NewType(TkObjFamily,IsTkObj and IsLiving and IsTkWidget),
            TkRootWindow);
  
  # Withdraw main top level window:
  Tk("wm state",TkRootWindow,"withdrawn");

  return true;
end);


############################################################################
##
#F  TkShutdown( ) . . . . . . . . . . . . . . . . .  shuts down wish process
##
##  This shuts down the wish process and all data structures in the package.
##  Returns `true'.
##
InstallGlobalFunction(TkShutdown,
function()
  if TkVars.Stream = fail then
    return true;
  fi;

  UnInstallCharReadHookFunc(TkVars.Stream,TkStreamHandler);
  CloseStream(TkVars.Stream);
  TkVars.Stream := fail;
  TkRootWindow := fail;
  TkVars.Callbacks := [];
  TkVars.CbArgs := [];
  TkVars.StreamHandlerBuffer := "";
  return true;
end);


############################################################################
##
#F  Tk( <arg1>, ... ) . . . . . . . . . . . . .  send a command to Tk easily
##
##  This function is used to send an arbitrary command to Tk. All
##  arguments are converted to strings and concatenated with spaces in
##  between. A record is converted to a string of options, that is each
##  bound entry is put into the string with a `-' in front and followed
##  by its value as a string. For all other objects we call `String'.
##  This works in particular for `TkWidget's and `TkItem's. Do not use
##  this to create `TkWidget's and `TkItem's. Use the corresponding
##  contructor functions instead! Returns the result Tk sends back.
##  
InstallGlobalFunction(Tk,
function(arg)
  local a,com,i,reply,commandargs,topobj;

  # Do we have to startup wish?
  if TkVars.Stream = fail then
    if TkInit() = fail then
      return fail;
    fi;
  fi;

  # See to top obj:
  if Length(arg) >= 1 and (IsTkWidget(arg[1]) or IsTkItem(arg[1])) then
    topobj := arg[1];
  else
    topobj := TkRootWindow;
  fi;

  com := "";
  for a in arg do
    if com <> "" then Append(com," "); fi;
    if IsString(a) then
      Append(com,a);
    elif IsRecord(a) then 
      # We handle some components differently:
      if IsBound(a.args) then      # Arguments to a callback
        commandargs := a.args;
        if not(IsList(commandargs)) then
          commandargs := [commandargs];
        fi;
        Unbind(a.args);
      else
        commandargs := [];
      fi;
      if IsBound(a.command) then   # A callback!
        Append(com,TkComToStr(topobj,a.command,commandargs,"-command"));
        Unbind(a.command);
      fi;
      if IsBound(a.xscrollcommand) then   # A callback!
        Append(com,TkComToStr(topobj,a.xscrollcommand,[],
               "-xscrollcommand"));
        Unbind(a.xscrollcommand);
      fi;
      if IsBound(a.yscrollcommand) then   # A callback!
        Append(com,TkComToStr(topobj,a.yscrollcommand,[],
               "-yscrollcommand"));
        Unbind(a.yscrollcommand);
      fi;

      Append(com,TkRecToStr(a));
    else
      Append(com,String(a));
    fi;
  od;
  reply := TkCmd(com);
  if reply = fail then
    return fail;
  else
    i := Int(reply);
    if i <> fail then
      return i;
    else
      return reply;
    fi;
  fi;
end);


############################################################################
##
#F  TkProcessEvents( done )  . . . . . .  processes events until some signal
##
##  This function processes events and callbacks until one of these events
##  sets the global variable TkVars.Done to true. Then it returns. This is
##  useful if an application wants to suspend itself until something 
##  happens without using up CPU time.
##  The argument <done> is the init value for TkVars.Done. If done=true
##  then this function only processes events which are there.
##  This function explicitly sets TkVars.ExecuteEvents to true beforehand
##  and restores it afterwards!
##
InstallGlobalFunction(TkProcessEvents,
function(done)
  local reply,   # here we collect the reply
        line,    # here we read a chunk
        fdsin,   # for UNIXSelect
        saveExecuteEvents;

  saveExecuteEvents := TkVars.ExecuteEvents;
  TkVars.ExecuteEvents := true;

  TkVars.Done := done;

  repeat

    # first proceed with events already received:
    TkProcessQueue();

    reply := "";
    fdsin := [FileDescriptorOfStream(TkVars.Stream)];
    repeat
      UNIXSelect(fdsin,[],[],fail,fail);
      if IsEndOfStream(TkVars.Stream) then
        TkShutdown();
        Info(TkInfo,2,"The wish process has died!");
        TkError := "The wish process has died!";
        return fail;
      fi;
      line := ReadLine(TkVars.Stream);
      #Print("Line:",line,"\n");
      Append(reply,line);
    until Length(reply) > 0 and reply[Length(reply)] = '\n';
    if Length(reply) > 1 and reply[Length(reply)-1] = '\r' then
      reply := reply{[1..Length(reply)-2]};
    else
      reply := reply{[1..Length(reply)-1]};
    fi;

    # Is this an event?
    if Length(reply) >= 6 and 
       (reply{[1..6]} = "callb " or reply{[1..6]} = "event ") then
      TkProcessEvent(reply);
      reply := fail;   # this means: nothing so far!
    fi;
  until TkVars.Done = true;

  TkVars.ExecuteEvents := saveExecuteEvents;

  return true;
end);


############################################################################
##
#F  TkValue( <cmd> ) . . . . . . . . . . . . . . . . . . ask a value from Tk
##
##  Sends the string <cmd> to Tk. Puts a "puts" before it and returns the
##  value which is printed out. Handles errors nicely. Waits for the
##  answer, and sets `TkVars.ErrorCode' and `TkError':
##
InstallGlobalFunction(TkValue,
function(arg)
  local reply,value,saveExecuteEvents,com,a;

  # Do we have to start up wish?
  if TkVars.Stream = fail then
    if TkInit() = fail then
      return fail;
    fi;
  fi;

  saveExecuteEvents := TkVars.ExecuteEvents;
  TkVars.ExecuteEvents := false;

  com := "";
  for a in arg do
    if com <> "" then Append(com," "); fi;
    if IsString(a) then
      Append(com,a);
    elif IsRecord(a) then 
      # We handle some components differently:
      Append(com,TkRecToStr(a));
    else
      Append(com,String(a));
    fi;
  od;
  com := Concatenation("catch { puts ",com," } GAPTkError");
  WriteLine(TkVars.Stream,com);
  value := TkReadLine();
  if value = fail then
    return fail;   # the wish process died
  fi;
  reply := TkReadLine();
  if reply = fail then
    return fail;   # the wish process died
  fi;
  
  # We want the output in TkError:
  if reply <> "0" then
    # Here we have to return an error:
    WriteLine(TkVars.Stream,"puts $GAPTkError");
    TkVars.ErrorCode := Int(reply);
    reply := TkReadLine();    # get the error message
    if reply <> fail then
      TkError := reply;
      Info(TkInfo,2,TkError);
    fi;

    value := fail;
  fi;

  TkVars.ExecuteEvents := saveExecuteEvents;
  if TkVars.ExecuteEvents then
    TkProcessQueue();
  fi;

  return value;
end);


############################################################################
##
#F  TkWidget( <arg1>, ... ) . . .  send a command to Tk to create a TkWidget
##
##  This function is used to send a command to Tk that creates a widget.
##  The first argument should be the type of widget and should be one
##  in the list `TkPossibleWidgetTypes'. Otherwise a warning is issued.
##  If the second argument is a `TkWidget' it is considered to be the
##  parent of the new widget. If the second argument is no `TkWidget'
##  or not present at all, then `TkRootWindow' is taken as parent. All
##  other arguments are converted to strings and concatenated with
##  spaces in between. A record is converted to a string of options,
##  that is each bound entry is put into the string with a `-' in front
##  and followed by its value as a string. For all other objects we call
##  `String'. This works in particular for `TkWidget's and `TkItem's.
##  Use this to create `TkWidget's. For `TkItem's use the corresponding
##  contructor function instead! Returns a new `TkWidget' or `fail' in
##  case of an error.
##  
InstallGlobalFunction(TkWidget,
function(arg)
  local com,commandargs,o,parent,r,reply,type,arglist,name;

  # Do we have to start up wish?
  if TkVars.Stream = fail then
    if TkInit() = fail then
      return fail;
    fi;
  fi;

  # process the arguments:
  if Length(arg) < 1 then
    Error("TkWidget: Need at least one argument: type of widget");
    return fail;
  fi;
  if not(IsString(arg[1])) then
    Error("TkWidget: First argument must be a string for the type");
    return fail;
  fi;
  type := arg[1];
  if not(type in TkPossibleWidgetTypes) then
    Info(TkInfo,1,"Warning: Unknown Tk widget type!");
  fi;

  if Length(arg) < 2 or not(IsTkWidget(arg[2])) then
    parent := TkRootWindow;
    arglist := arg{[2..Length(arg)]};
  else
    parent := arg[2];
    arglist := arg{[3..Length(arg)]};
  fi;

  o := rec(type := type,
           parent := parent,
           callbacks := []);
  o.name := ValueOption("tkname");
  if not(IsString(o.name)) or Length(o.name) = 0 then  # this includes "fail"
    o.name := Concatenation(".o",String(TkVars.SerialNr));
    TkVars.SerialNr := TkVars.SerialNr + 1;
  else   # look for the dot in front
    if o.name[1] <> '.' then
      o.name := Concatenation(".",o.name);
    fi;
  fi;
  # Now put the name of the parent in front:
  if o.parent!.name <> "." then
    o.name := Concatenation(o.parent!.name,o.name);
  fi;
  
  # The beginning of the command:
  com := Concatenation(o.type," ",o.name);

  # Now look at all arguments:
  for r in arglist do
    if IsRecord(r) then
      # We handle some components differently:
      if IsBound(r.args) then      # Arguments to a callback
        commandargs := r.args;
        if not(IsList(commandargs)) then
          commandargs := [commandargs];
        fi;
        Unbind(r.args);
      else
        commandargs := [];
      fi;
      if IsBound(r.command) then   # A callback!
        Append(com,TkComToStr(o,r.command,commandargs,"-command"));
        Unbind(r.command);
      fi;
      if IsBound(r.xscrollcommand) then   # A callback!
        Append(com,TkComToStr(o,r.xscrollcommand,[],"-xscrollcommand"));
        Unbind(r.xscrollcommand);
      fi;
      if IsBound(r.yscrollcommand) then   # A callback!
        Append(com,TkComToStr(o,r.yscrollcommand,[],"-yscrollcommand"));
        Unbind(r.yscrollcommand);
      fi;

      Append(com,TkRecToStr(r));
    else
      Append(com," ");
      Append(com,String(r));
    fi;
  od;

  reply := TkCmd(com);
  if reply = fail then 
    return fail;
  else
    Objectify(NewType(TkObjFamily,IsTkObj and IsLiving and IsTkWidget),o);
    return o;
  fi;
end);


############################################################################
##
#F  TkItem( <arg1>, ... ) . . . . .  send a command to Tk to create a TkItem
##
##  This function is used to send a command to Tk that creates an item
##  in a canvas widget. The first argument should be the type of the
##  item and should be one in the list `TkPossibleItemTypes'. Otherwise
##  a warning is issued. The second argument must be a `TkWidget' it
##  is the parent of the new item. All other arguments are converted
##  to strings and concatenated with spaces in between. A record is
##  converted to a string of options, that is each bound entry is put
##  into the string with a `-' in front and followed by its value
##  as a string. For all other objects we call `String'. This works
##  in particular for `TkWidget's and `TkItem's. Use this to create
##  `TkItem's. For `TkWidget's use the corresponding contructor function
##  instead! Returns a new `TkItem' or `fail' in case of an error.
##  
InstallGlobalFunction(TkItem,
function(arg)
  local com,o,parent,r,reply,type,arglist;

  # Do we have to start up wish?
  if TkVars.Stream = fail then
    if TkInit() = fail then
      return fail;
    fi;
  fi;

  # process the arguments:
  if Length(arg) < 2 then
    Error("TkItem: Need at least two arguments: type of item and parent");
    return fail;
  fi;
  if not(IsString(arg[1])) then
    Error("TkItem: First argument must be a string for the type");
    return fail;
  fi;
  type := arg[1];
  if not(type in TkPossibleItemTypes) then
    Info(TkInfo,1,"Warning: Unknown Tk item type!");
  fi;
  parent := arg[2];
  if not(IsTkWidget(parent)) or not(parent!.type = "canvas") then
    Error("TkItem: Second argument must be a canvas widget");
    return fail;
  fi;
  arglist := arg{[3..Length(arg)]};

  o := rec(type := type, parent := parent, callbacks := []);
  
  # The beginning of the command:
  com := Concatenation(String(o.parent)," create ",o.type);

  # Now look at all arguments:
  for r in arglist do
    if IsRecord(r) then
      Append(com,TkRecToStr(r));
    else
      Append(com," ");
      Append(com,String(r));
    fi;
  od;

  reply := TkCmd(com);
  if reply = fail then 
    return fail;
  else
    o.name := reply;
    Objectify(NewType(TkObjFamily,IsTkObj and IsLiving and IsTkItem),o);
    return o;
  fi;
end);


############################################################################
##
#F  TkDelete( <TkWidget> ) . . . . . .  destroys a widget or deletes an item
##
##  This function is used to destroy a TkWidget or delete a TkItem within
##  a canvas. All installed events or callbacks are deleted also. This is
##  necessary to free memory within GAP (allocated by the tk package).
##  Note that child objects are *not* deleted within GAP, because they
##  are not stored with an object. However on the Tk side they are of
##  course gone. So please delete all objects bottom up in an object tree!
##
InstallMethod(TkDelete,"for a TkWidget",true,
  [IsTkObj and IsTkWidget and IsLiving],0,
  function(w)
    local i;
    Tk("destroy",w);
    ResetFilterObj(w,IsLiving);
    for i in w!.callbacks do
      if IsBound(TkVars.Callbacks[i]) then
        Unbind(TkVars.Callbacks[i]);
      fi;
      if IsBound(TkVars.CbArgs[i]) then
        Unbind(TkVars.CbArgs[i]);
      fi;
    od;
  end);

InstallMethod(TkDelete,"for a TkItem",true,
  [IsTkObj and IsTkItem and IsLiving],0,
  function(it)
    local i;
    Tk(it!.parent,"delete",it!.name);
    ResetFilterObj(it,IsLiving);
    for i in it!.callbacks do
      if IsBound(TkVars.Callbacks[i]) then
        Unbind(TkVars.Callbacks[i]);
      fi;
      if IsBound(TkVars.CbArgs[i]) then
        Unbind(TkVars.CbArgs[i]);
      fi;
    od;
  end);

############################################################################
##
#F  TkPack( <arg1>, ... ) . . . . . .  see Tk, but put "pack" before command
##
##  The same as `Tk', but puts "pack" before command and returns 1st 
##  argument or `fail'.
##
InstallGlobalFunction(TkPack,
function(arg)
  local l,r;
  if Length(arg) < 1 then
    Error("TkPack: Need at least one argument!");
    return fail;
  fi;
  # The following is for direct calls with the result of a constructor:
  if arg[1] = fail then
    return fail;
  fi;
  # some check:
  if not(IsLiving(arg[1])) then
    Error("TkPack: First argument must be a living TkWidget object!");
    return fail;
  fi;

  l := Concatenation(["pack"],arg);
  r := CallFuncList(Tk,l);
  if r = fail then
    return fail;
  else
    return arg[1];
  fi;
end);
 

############################################################################
##
#F  TkGrid( <arg1>, ... ) . . . . . .  see Tk, but put "grid" before command
##
##  The same as `Tk', but puts "grid" before command and returns 1st 
##  argument or `fail'.
##
InstallGlobalFunction(TkGrid,
function(arg)
  local l,r;
  if Length(arg) < 1 then
    Error("TkGrid: Need at least one argument!");
    return fail;
  fi;
  # The following is for direct calls with the result of a constructor:
  if arg[1] = fail then
    return fail;
  fi;
  # some check:
  if not(IsLiving(arg[1])) then
    Error("TkGrid: First argument must be a living TkWidget object!");
    return fail;
  fi;

  l := Concatenation(["grid"],arg);
  r := CallFuncList(Tk,l);
  if r = fail then
    return fail;
  else
    return arg[1];
  fi;
end);
 

############################################################################
##
#M  TkBind( <arg1>, ... ) . . . . . . . . . . . . . see Tk, but for bindings
##
##  Essentially the same as `Tk', but puts "bind" before command and 
##  organizes callback. Without function an unbind is performed.
##  For TkWidgets.
##
InstallMethod(TkBind,"for a TkWidget, a string, a function, and a list",true,
  [IsTkObj and IsTkWidget and IsLiving, IsString, IsFunction, IsList],0,
  function(o,e,f,l)
  local com,reply;
  com := Concatenation("bind ",String(o)," ",e,
      " { puts \"event ",String(Length(TkVars.Callbacks)+1),
      ",%#,%a,%b,%c,%d,%f,%h,%k,%m,%o,%p,%s,%t,%w,%x,%y,",
      "%A,%B,%D,%E,%K,%N,%R,%S,%T,%W,%X,%Y\" }");
  Add(TkVars.Callbacks,f);
  Add(TkVars.CbArgs,l);
  Add(o!.callbacks,Length(TkVars.Callbacks));
  reply := TkCmd(com);
  if reply = fail then
    return fail;
  else
    return true;
  fi;
end);

# Without arguments:
InstallMethod(TkBind,"for a TkWidget, a string, and a function",true,
  [IsTkObj and IsTkWidget and IsLiving, IsString, IsFunction],0,
  function(o,e,f)
    return TkBind(o,e,f,[]);
  end);

# For Unbind:
InstallMethod(TkBind,"for a TkWidget, and a string",true,
  [IsTkObj and IsTkWidget and IsLiving, IsString],0,
  function(o,e)
  local com,reply;
  com := Concatenation("bind ",String(o)," ",e," \"\"");
  reply := TkCmd(com);
  if reply = fail then
    return fail;
  else
    return true;
  fi;
  end);

############################################################################
##
#M  TkBind( <arg1>, ... ) . . . . . . . . . . . . . see Tk, but for bindings
##
##  Essentially the same as `Tk', but puts "bind" before command and 
##  organizes callback. Without function an unbind is performed.
##  For TkItems.
##
InstallMethod(TkBind,"for a TkItem, a string, a function, and a list",true,
  [IsTkObj and IsTkItem and IsLiving, IsString, IsFunction, IsList],0,
  function(o,e,f,l)
  local com,reply;
  com := Concatenation(String(o!.parent)," bind ",String(o)," ",e,
      " { puts \"event ",String(Length(TkVars.Callbacks)+1),
      ",%#,%a,%b,%c,%d,%f,%h,%k,%m,%o,%p,%s,%t,%w,%x,%y,",
      "%A,%B,%D,%E,%K,%N,%R,%S,%T,%W,%X,%Y\" }");
  Add(TkVars.Callbacks,f);
  Add(TkVars.CbArgs,l);
  Add(o!.callbacks,Length(TkVars.Callbacks));
  reply := TkCmd(com);
  if reply = fail then
    return fail;
  else
    return true;
  fi;
end);

# Without arguments:
InstallMethod(TkBind,"for a TkItem, a string, and a function",true,
  [IsTkObj and IsTkItem and IsLiving, IsString, IsFunction],0,
  function(o,e,f)
    return TkBind(o,e,f,[]);
  end);

# For Unbind:
InstallMethod(TkBind,"for a TkItem, and a string",true,
  [IsTkObj and IsTkItem and IsLiving, IsString],0,
  function(o,e)
  local com,reply;
  com := Concatenation(String(o!.parent)," bind ",String(o)," ",e," {}");
  reply := TkCmd(com);
  if reply = fail then
    return fail;
  else
    return true;
  fi;
  end);

############################################################################
##
#M  TkLink(<widget>, <scrollbar>, <mode>) . connect a scrollbar and a widget
##
##  Link a widget and a scrollbar. <mode> must be "v" or "vertical" or
##  "h" or "horizontal" and specifies whether the scrollbar handles
##  the y coordinate or the x coordinate of the widget respectively.
##
InstallMethod(TkLink,"for two TkWidget, and a string",true,
  [IsTkObj and IsTkWidget and IsLiving,IsTkObj and IsTkWidget,IsString],0,
  function(w,s,o)
    if not(s!.type) = "scrollbar" then
      Error("Second object must be a scrollbar!");
      return fail;
    fi;
    if not(o = "h" or o = "v" or o = "horizontal" or o = "vertical") then
      Error(
 "Third argument must be \"h\" or \"v\" or \"horizontal\" or \"vertical\"");
      return fail;
    fi;
    if o[1] = 'h' then
      if Tk(s,"configure -command { ",w,"xview }") = fail then 
        return fail; 
      fi;
      if Tk(w,"configure -xscrollcommand { ",s,"set }") = fail then 
        return fail;
      fi;
    else
      if Tk(s,"configure -command { ",w,"yview }") = fail then 
        return fail;
      fi;
      if Tk(w,"configure -yscrollcommand { ",s,"set }") = fail then
        return fail;
      fi;
    fi;
    return true;
  end);


############################################################################
##
##  Some preparations:
##
############################################################################

# Standard things like PrintObj:
InstallMethod(PrintObj,"for a TkWidget",true,
  [IsTkObj and IsTkWidget],0,
  function(o)
    Print("<");
    if not(IsLiving(o)) then
      Print("dead ");
    fi;
    Print("TkWidget type=\"",o!.type,"\" name=\"",o!.name,"\">");
  end);


InstallMethod(PrintObj,"for a TkItem",true,
  [IsTkObj and IsTkItem],0,
  function(o)
    Print("<");
    if not(IsLiving(o)) then
      Print("dead ");
    fi;
    Print("TkItem type=\"",o!.type,"\" name=\"",o!.name,"\" parent=\"",
          o!.parent!.name,"\">");
  end);


InstallMethod(String,"for a TkWidget",true,
  [IsTkObj and IsTkWidget and IsLiving],0,
  function(o)
    return o!.name;
  end);

InstallMethod(String,"for a TkWidget",true,
  [IsTkObj and IsTkWidget],0,
  function(o)
    Error("String: TkWidget object is no longer living!");
    return o!.name;
  end);


InstallMethod(String,"for a TkItem",true,
  [IsTkObj and IsTkItem and IsLiving],0,
  function(o)
    return String(o!.name);
  end);

InstallMethod(String,"for a TkItem",true,
  [IsTkObj and IsTkItem],0,
  function(o)
    Error("String: TkItem object is not longer living!");
    return String(o!.name);
  end);


# Normally show error messages:
SetInfoLevel(TkInfo,1);

