#############################################################################
##
#W  teachm2.g                GAP library                   Alexander Hulpke
##
##
#Y  Copyright (C) 2008 The GAP Group
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

