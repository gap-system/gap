# Simple consistency checker functions
#
# `BuildCRCTable()' will create a file `lib/crctable.g' that the function
# `CheckSystemConsistency()' will check. Both this file and `lib/crctable.g'
# would have to be part of a release/bugfix.

FilenameFromRevisionEntry:=function(s)
local f,i;
  if '/' in s then
    # package
    s:=Concatenation("../pkg/",s);
  elif s[Length(s)] in "ch" then
    s:=Concatenation("../src/",s);
  fi;
  s:=ReplacedString(s,"_",".");
  for i in ["","../grp/","../small/","../trans/","../prim/"] do
    f:=Filename(DirectoriesLibrary(),Concatenation(i,s));
    if f<>fail then
      return f;
    fi;
  od;
  return fail;
end;

BuildCRCTable:=function()
local t,i,f;
  Print("#W  This is not a user function !\n\n\n");
  t:=[];
  for i in RecFields(Revision) do
    f:=FilenameFromRevisionEntry(i);
    if f<>fail then
      Add(t,[i,CrcFile(f)]);
    else
      Print("File ",i," not found -- ignoring\n");
    fi;
  od;
  t:=rec(version:= GAPInfo.Version,
         kernel:= GAPInfo.KernelVersion,
	 crc:=t);
  f:=Concatenation(GAP_ROOT_PATHS[1],"lib/crctable.g");
  PrintTo(f,"CRCTABLE:=\n",t,";\n");
end;

CRCTABLE:=fail;
CheckSystemConsistency:=function()
local f, ok, i;
  f:=Filename(DirectoriesLibrary(),"crctable.g");
  Read(f);
  ok:= GAPInfo.Version = CRCTABLE.version and
       GAPInfo.KernelVersion = CRCTABLE.kernel;
  for i in CRCTABLE.crc do
    f:=FilenameFromRevisionEntry(i[1]);
    if f<>fail then
      if i[2]<>CrcFile(f) then
	Error("File `",i[1],"' has an inconsistent CRC number\n");
	ok:=false;
      fi;
    else
      Print("File ",i[1], " missing\n",
            "Ignore this if not the whole system is installed\n");
    fi;
  od;
  if ok then
    Print( "\n\nYour system verifies consistently as version ",
           GAPInfo.Version, "\n");
  else
    Error("Your system is inconsistent\n");
  fi;
end;

