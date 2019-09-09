#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file contains rotines for turning teaching mode on and off.
##

TEACHMODE:=fail;

BindGlobal("TeachingMode",function(arg)
local s;
  if Length(arg)>0 then
    if arg[1]=true and TEACHMODE=fail then
      RereadLib("teachmod.g"); # reread because we are redefining things
    fi;
    TEACHMODE:=arg[1]=true;
  fi;
  if TEACHMODE=true then
    s:="ON";
  else
    s:="OFF";
  fi;
  Info(InfoWarning,1,"Teaching mode is turned ",s);
end);

