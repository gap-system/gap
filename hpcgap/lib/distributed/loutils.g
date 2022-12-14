#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

NO_RET_VAL := "<no_return_val>";

#set the MPI process id
DeclareGlobalVariable("processId");
MakeReadWriteGVar("processId");
processId := MPI_Comm_rank();
MakeReadOnlyGVar("processId");

#set the comm size
DeclareGlobalVariable("commSize");
MakeReadWriteGVar("commSize");
commSize := MPI_Comm_size();
MakeReadOnlyGVar("commSize");

BindGlobal ("MPI_DEBUG", rec (
        HANDLE_CREATION := false,
                              GA_MAP := false,
                              OBJECT_TRANSFER := false,
                              TASKS := false));
MakeReadOnlyObj(MPI_DEBUG);

BindGlobal ("MPI_DEBUG_OUTPUT", MakeReadOnlyObj ( rec (
        HANDLE_CREATION := 1,
                                   GA_MAP := 2,
                                   CHANGE_COUNT := 3,
                                   HANDLE_DELETION := 4,
                                   OBJECT_TRANSFER := 5,
                                   TASKS := 6,
                                   LOCAL_TASKS := 7)));

MSTime := function()
  local t;
  t := CurrentTime();
  return (t.tv_sec * 1000000 + t.tv_usec * 1.0)/1000000;
end;

MPILog := function(arg)
  local debugType, msg, handle;
  debugType := arg[1];
  msg := Concatenation("(", String(MSTime()), ",", String(processId), ") :: ");
  if debugType = MPI_DEBUG_OUTPUT.HANDLE_CREATION then
    handle := arg[2];
    msg := Concatenation (msg, " (", String(handle!.pe), ",", String(handle!.localId), ",", String(handle!.owner), ") created");
  elif debugType = MPI_DEBUG_OUTPUT.GA_MAP then
    handle := arg[2];
    msg := Concatenation (msg, " (", String(handle!.pe), ",", String(handle!.localId), ",", String(handle!.owner), ") [l:",
                   arg[3], "] => GA map");
  elif debugType = MPI_DEBUG_OUTPUT.CHANGE_COUNT then
    handle := arg[2];
    msg := Concatenation (msg, " (", String(handle!.pe), ",", String(handle!.localId), ",", String(handle!.owner), ") => new count (L=",
                   String(handle!.control.localCount), ",G:", String(handle!.control.globalCount), ")");
  elif debugType = MPI_DEBUG_OUTPUT.HANDLE_DELETION then
    handle := arg[2];
    msg := Concatenation (msg, " (", String(handle!.pe), ",", String(handle!.localId), ",", String(handle!.owner), ") deleted");
  elif debugType = MPI_DEBUG_OUTPUT.OBJECT_TRANSFER then
    handle := arg[2];
    msg := Concatenation (msg, " handle (", String(handle!.pe), ",", String(handle!.localId), ",", String(handle!.owner), ") ", Concatenation(arg{[3..Length(arg)]}));
  elif debugType = MPI_DEBUG_OUTPUT.TASKS then
    handle := arg[2];
    msg := Concatenation (msg, " handle (", String(handle!.pe), ",",  String(handle!.localId), ",", String (handle!.owner), ") : T(", arg[3], ") ",
                   Concatenation (arg{[4..Length(arg)]}));
  elif debugType = MPI_DEBUG_OUTPUT.LOCAL_TASKS then
    msg := Concatenation (msg, " T( ", arg[2], ") ", Concatenation (arg{[3..Length(arg)]}));
  fi;

  msg := Concatenation (msg, "\n");
  Print (msg);
end;

if IsReadOnlyGlobal("LastReadValue") then
  MakeReadWriteGVar("LastReadValue");
  LastReadValue := NO_RET_VAL;
  MakeReadOnlyGVar("LastReadValue");
else
  LastReadValue := NO_RET_VAL;
fi;

## utils for evaluating string expressions
PrintToString := function( arg )
  local str, output, obj;
  str := "";
  output := OutputTextString( str, true ); # true means do as append
  # Would PrintTo -> AppendTo be necessary if "true"->"false" above?
  for obj in arg do
    PrintTo(output, obj);
  od;
  CloseStream(output);
  # With gap4b5 (and gap4b4?), GAP objects have '\0' in print representation
  # This removes them.
  obj := CHAR_INT(0);  # In GAP, CHAR_INT(INT_CHAR('\0')) = '0', not '\0'
  str := Filtered(str, x->x<>obj);
  #if str[Length(str)] <> '\n' then str[Length(str)+1] := '\n'; fi;
  str[Length(str)+1] := obj;
  return str;
end;

ReadEvalFromString := function(str)
  local i, j;
  if not IsString(str) then
    Error("string argument required");
  fi;
  # The issue is that GAP printing to streams produces "\n\0" sequences.
  # Also, Read( InputTestString( str ) ); wants to see ';'
  if Length(str) = 0 then
    Error("Reading and evaluating null string");
  fi;
  i := CHAR_INT(0);     # In GAP, CHAR_INT(INT_CHAR('\0')) = '0', not '\0'
  str := Filtered(str, x->x<>i);
  if str[Length(str)] <> ';' and str[Length(str)-1] <> ';' then
    str[Length(str)+1] := ';';
  fi;
  if IsReadOnlyGlobal("LastReadValue") then
    MakeReadWriteGVar("LastReadValue");
    LastReadValue := NO_RET_VAL;
    MakeReadOnlyGVar("LastReadValue");
  else
    LastReadValue := NO_RET_VAL;
  fi;
  Read( InputTextString( str ) ); # Read() does ReadEval in GAP
  # If variable, last, is used, GAP complains about unbound global variable
  #  or  Variable: 'last' must have an assigned value; during execution
  # UNIX_Last() was a C routine to do the same.  GAP doesn't see use of last.
  if not IsBoundGlobal("LastReadValue") then
    return NO_RET_VAL;  # Unfortunately, Read() seems to unbind LastReadValue
    #   when there was no return value.
    return "<exception or interrupt>";
  fi;
  return LastReadValue;
end;

MyLookupHashTable := function (table, key)
  local keys, i, values, p, res;
  res := fail;
  atomic readonly table do
    keys := table[1];
    values := table[2];

    for i in [1..Length(keys)] do
      if keys[i] = key then
        res := values[i];
        break;
      fi;
    od;
  od;
  return res;
end;

MyInsertHashTable := function (table, key, value)
  local keys, i, values, p;
  atomic readwrite table do
    keys := table[1];
    values := table[2];
    if IsIdenticalObj(MyLookupHashTable (table, key),fail) then
      keys[Length(keys)+1] := key;
      values[Length(values)+1] := value;
    else
      i := 1;
      while keys[i] <> key do
        i := i+1;
      od;
      values[i] := value;
    fi;
  od;
end;

MyDeleteHashTable := function (table, key)
  local keys, i, values;
   atomic readonly table do
    keys := table[1];
    values := table[2];
    for i in [1..Length(keys)] do
      if keys[i] = key then
        Unbind(keys[i]);
        Unbind(values[i]);
        break;
      fi;
    od;
  od;
end;
