#############################################################################
##
#W  teachm2.g                GAP library                   Alexander Hulpke
##
#H  @(#)$Id: teachm2.g,v 4.4 2010/10/29 09:02:47 gap Exp $
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This  file contains rotines for turning teaching mode on and off.
##
Revision.teachm2_g:=
  "@(#)$Id: teachm2.g,v 4.4 2010/10/29 09:02:47 gap Exp $";

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
    GAPInfo.UserPreferences.IndeterminateNameReuse:= 1;
  else
    s:="OFF";
    GAPInfo.UserPreferences.IndeterminateNameReuse:= 0;
  fi;
  Info(InfoWarning,1,"Teaching mode is turned ",s);
end);

