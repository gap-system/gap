#############################################################################
##
#W  debug.g                      GAP library                    Thomas Breuer
#W                                                          & Max Neunhoeffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  2003,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 2003 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2003 The GAP Group
##
##  This file contains some global variables and functions to support
##  debugging of functions in GAP. See etc/debugvim.txt for details.
##  As of now this is not automatically loaded and there is no documentation
##  apart from the above file. There is no support for other editors
##  than vim.
##
Revision.debug_g :=
    "@(#)$Id$";

DEBUG_LIST := [];
DEBUG_EDITORS := [rec(name := "Vim",command := "vim",
  args := [Concatenation("+map <f12> :split ", GAP_ROOT_PATHS[1],
                         "etc/debugvim.txt<cr>"),
           Concatenation("+source ",GAP_ROOT_PATHS[1],"etc/debug.vim"),
           "+let @a=\"###\""])];
DEBUG_EDITOR := DEBUG_EDITORS[1];
DEBUG_CURRENT_FUNC := fail;
DEBUG_FUNCTION := function() return 0; end;

Debug := function(arg)
  local execpath,f,i,j,l,name,oldversion,p,t;
 
  # evaluate arguments:
  if Length(arg) < 1 or Length(arg) > 2 then
    Print("Usage: Debug( <func> [ ,<name> ] );\n");
    Print("       where <func> is a function.\n");
    Print("       and   <name> is a string.\n");
    return;
  fi;
  
  # find the first argument: 
  #   our function (or a number of a previously debugged one)
  f := arg[1];
  if IsInt(f) then
    if f < 1 or f > Length(DEBUG_LIST) or not(IsBound(DEBUG_LIST[f])) then
      Print("Error: Do not know debugged function number ",f,".\n");
      return;
    fi;
    i := f;
    f := DEBUG_LIST[i].func;
  else
    if not(IsFunction(f)) then
      Print("Usage: Debug( <func> [ ,<name> ] );\n");
      Print("       where <func> is a function.\n");
      Print("       and   <name> is a string.\n");
      return;
    fi;
      
    # find function in the list of debugged functions:
    i := 1;
    while i <= Length(DEBUG_LIST) and 
          (not(IsBound(DEBUG_LIST[i])) or DEBUG_LIST[i].func <> f) do
      i := i + 1;
    od;
    # now i can be Length(DEBUG_LIST)+1
  fi;

  if Length(arg) > 1 then
    if not(IsString(name)) then
      Print("Usage: Debug( <func> [ ,<name> ] );\n");
      Print("       where <func> is a function.\n");
      Print("       and   <name> is a string.\n");
      return;
    fi;
    name := arg[2];
  else
    name := NAME_FUNC(f);
  fi;

  # Now ask the user to make debugging changes:
  t := TmpName();
  PrintTo(t,"# Type F12 for help!\nDEBUG_FUNCTION:=\n",f,";\n");

  # The following is necessary to preserve the old version:
  if i > Length(DEBUG_LIST) then
    Read(t);    
    oldversion := DEBUG_FUNCTION;
  fi;

  # Call the editor:
  execpath := Filename(DirectoriesSystemPrograms(),DEBUG_EDITOR.command);
  l := ShallowCopy(DEBUG_EDITOR.args);
  for j in [1..Length(l)] do
    p := PositionSublist(l[j],"###");
    if p <> fail then
      l[j] := Concatenation(l[j]{[1..p-1]},String(i),l[j]{[p+3..Length(l[j])]});
    fi;
  od;
  Add(l,t);   # append the temporary filename
  Process(DirectoryCurrent(),execpath,InputTextUser(),OutputTextUser(),l);
  Read(t);

  # Now copy this new version into the function:
  MakeReadWriteGVar("REREADING");
  REREADING := true;
  if i > Length(DEBUG_LIST) then
    INSTALL_METHOD_ARGS(oldversion,f);     # save the old version
  fi;
  INSTALL_METHOD_ARGS(f,DEBUG_FUNCTION);
  REREADING := false;
  MakeReadOnlyGVar("REREADING");

  # Now store what we did:
  if i > Length(DEBUG_LIST) then
    Add(DEBUG_LIST,rec(func := f,old := oldversion,name := name,count := 1));
    # i is now equal to Length(DEBUG_LIST)
  fi;
  
  Print("This is debug function #",i,".\n");
end;

DebugFind := function(f)
  local nr;

  if IsFunction(f) then
    # find function among debugged functions:
    nr := 1;
    while nr <= Length(DEBUG_LIST) and 
          (not(IsBound(DEBUG_LIST[nr])) or 
           not(IsIdenticalObj(DEBUG_LIST[nr].func,f))) do
      nr := nr + 1;
    od;
    if nr > Length(DEBUG_LIST) then
      Print("Error: This function is not debugged.\n");
      return fail;
    fi;
    return nr;
  elif IsInt(f) then
    if IsBound(DEBUG_LIST[f]) then
      return f;
    else
      Print("Error: Debugged function number ",f," is no longer debugged.\n");
      return fail;
    fi;
  else
    Print("Error: Argument must be a function or an integer.\n");
    return fail;
  fi;
end;

UnDebug := function(f)
  local nr;

  nr := DebugFind(f);
  if nr = fail then
    return;
  fi;

  # Copy the old version into the function:
  MakeReadWriteGVar("REREADING");
  REREADING := true;
  INSTALL_METHOD_ARGS(DEBUG_LIST[nr].func,DEBUG_LIST[nr].old);
  REREADING := false;
  MakeReadOnlyGVar("REREADING");
  Unbind(DEBUG_LIST[nr]);
  
  # Inform user:
  Print("Undebugging function #",nr,".\n");
end;

ShowDebug := function()
  local i;
  Print("Debug functions:\n");
  for i in [1..Length(DEBUG_LIST)] do
    Print("  ",String(i,2),": ");
    if IsBound(DEBUG_LIST[i]) then
      Print(DEBUG_LIST[i].name,"\n");
    else
      Print("No longer used.\n");
    fi;
  od;
end;

SetDebugCount := function(f,count)
  local nr;

  nr := DebugFind(f);
  if nr = fail then
    return;
  fi;

  DEBUG_LIST[nr].count := count;
end;
