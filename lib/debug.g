#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Max Neunhöffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains some global variables and functions to support
##  debugging of functions in GAP. See `etc/vim/debugvim.txt' for details.
##  As of now this is not automatically loaded and there is no documentation
##  apart from the above file. There is no support for other editors
##  than vim.
##

BindGlobal( "DEBUG", rec() );
DEBUG.debugvim_txt:= Filename( DirectoriesLibrary( "etc/vim" ), "debugvim.txt" );
DEBUG.debug_vim:= Filename( DirectoriesLibrary( "etc/vim" ), "debug.vim" );
DEBUG.LIST := [];
DEBUG.EDITORS := [ rec(
    name := "Vim",
    command := "vim",
    args := [ Concatenation("+map <f12> :split ", DEBUG.debugvim_txt, "<cr>"),
              Concatenation("+source ", DEBUG.debug_vim ),
              "+let @a=\"###\"" ] ) ];
DEBUG.EDITOR := DEBUG.EDITORS[1];
DEBUG.CURRENT_FUNC := fail;
DEBUG.FUNCTION := function() return 0; end;

Debug := function(arg)
  local execpath,f,i,l,name,oldversion,t;

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
    if f < 1 or f > Length(DEBUG.LIST) or not(IsBound(DEBUG.LIST[f])) then
      Print("Error: Do not know debugged function number ",f,".\n");
      return;
    fi;
    i := f;
    f := DEBUG.LIST[i].func;
  elif IsOperation( f ) or not(IsFunction(f)) then
    Print("Usage: Debug( <func>[, <name>] );\n");
    Print("       where <func> is a function but not an operation,\n");
    Print("       and   <name> is a string.\n");
    return;
  else

    # find function in the list of debugged functions:
    i := 1;
    while i <= Length(DEBUG.LIST) and
          (not(IsBound(DEBUG.LIST[i])) or DEBUG.LIST[i].func <> f) do
      i := i + 1;
    od;
    # now i can be Length(DEBUG.LIST)+1
  fi;

  if Length(arg) > 1 then
    if not(IsString(name)) then
      Print("Usage: Debug( <func>[, <name>] );\n");
      Print("       where <func> is a function but not an operation,\n");
      Print("       and   <name> is a string.\n");
      return;
    fi;
    name := arg[2];
  else
    name := NAME_FUNC(f);
  fi;

  # Now ask the user to make debugging changes:
  t := TmpName();
  PrintTo(t,"# Type F12 for help!\nDEBUG.FUNCTION:=\n",f,";\n");

  # The following is necessary to preserve the old version:
  if i > Length(DEBUG.LIST) then
    Read(t);
    oldversion := DEBUG.FUNCTION;
  fi;

  # Call the editor:
  execpath := Filename(DirectoriesSystemPrograms(),DEBUG.EDITOR.command);
  l:= List( DEBUG.EDITOR.args, x -> ReplacedString( x, "###", String( i ) ) );
  Add(l,t);   # append the temporary filename
  Process(DirectoryCurrent(),execpath,InputTextUser(),OutputTextUser(),l);
  Read(t);

  # Now copy this new version into the function:
  MakeReadWriteGVar("REREADING");
  REREADING := true;
  if i > Length(DEBUG.LIST) then
    INSTALL_GLOBAL_FUNCTION(oldversion,f);     # save the old version
  fi;
  INSTALL_GLOBAL_FUNCTION(f,DEBUG.FUNCTION);
  REREADING := false;
  MakeReadOnlyGVar("REREADING");

  # Now store what we did:
  if i > Length(DEBUG.LIST) then
    Add(DEBUG.LIST,rec(func := f,old := oldversion,name := name,count := 1));
    # i is now equal to Length(DEBUG.LIST)
  fi;

  Print("This is debug function #",i,".\n");
end;

DebugFind := function(f)
  local nr;

  if IsFunction(f) then
    # find function among debugged functions:
    nr := 1;
    while nr <= Length(DEBUG.LIST) and
          (not(IsBound(DEBUG.LIST[nr])) or
           not(IsIdenticalObj(DEBUG.LIST[nr].func,f))) do
      nr := nr + 1;
    od;
    if nr > Length(DEBUG.LIST) then
      Print("Error: This function is not debugged.\n");
      return fail;
    fi;
    return nr;
  elif IsInt(f) then
    if IsBound(DEBUG.LIST[f]) then
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
  INSTALL_GLOBAL_FUNCTION(DEBUG.LIST[nr].func,DEBUG.LIST[nr].old);
  REREADING := false;
  MakeReadOnlyGVar("REREADING");
  Unbind(DEBUG.LIST[nr]);

  # Inform user:
  Print("Undebugging function #",nr,".\n");
end;

ShowDebug := function()
  local i;
  Print("Debug functions:\n");
  for i in [1..Length(DEBUG.LIST)] do
    Print("  ",String(i,2),": ");
    if IsBound(DEBUG.LIST[i]) then
      Print(DEBUG.LIST[i].name,"\n");
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

  DEBUG.LIST[nr].count := count;
end;
