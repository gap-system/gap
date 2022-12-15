#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

ParEval := function( command )
  local result, i, msg;

  msg := Concatenation(IO_Pickle(processId), IO_Pickle(MESSAGE_TYPES.EVAL_MSG), command);
  for i in [0..commSize-1] do
    if i<>processId then
      MPI_Send(msg, i, MESSAGE_TYPES.EVAL_MSG);
    fi;
  od;

  result := ReadEvalFromString( PrintToString (command) );

  if result = NO_RET_VAL then return; fi;
  return result;
end;


ParDeclareGlobalFunction := function( name )
  if IsBoundGlobal(name) then
    ParEval( PrintToString("MakeReadWriteGVar(\"",name,"\")") );
    ParEval( PrintToString("if IsBoundGlobal(\"",name,"\") then UnbindGlobal(\"",name,"\"); fi;") );
  fi;
  ParEval( Concatenation("DeclareGlobalFunction(\"", name, "\")") );
end;


ParInstallGlobalFunction := function (name, f)
  if IsString(name) then
    ParDeclareGlobalFunction( name );
  else
    name := NAME_FUNC(name);
  fi;
  ParEval("__tmp__ := InfoLevel(InfoWarning)");
  ParEval("SetInfoLevel(InfoWarning,0)");
  ParEval( PrintToString("InstallGlobalFunction(",name,",",f,")" ));
  ParEval("SetInfoLevel(InfoWarning,__tmp__)");
end;
