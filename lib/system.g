#############################################################################
##
#W  system.g                   GAP Library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains functions that are architecture dependent.
##
Revision.system_g :=
    "@(#)$Id$";

#############################################################################
##
##  identifier that will recognize the Windows and the Mac version
##
BIND_GLOBAL("WINDOWS_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("win"));
BIND_GLOBAL("MACINTOSH_68K_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("MC68020-motorola-macos-mwerksc"));
BIND_GLOBAL("MACINTOSH_PPC_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("PPC-motorola-macos-mwerksc"));

#T the following functions eventually should be more clever. This however
#T will require kernel support and thus is something for later.  AH

#############################################################################
##
#F  ARCH_IS_MAC()
##
##  tests whether {\GAP} is running on a Macintosh under MacOS
BIND_GLOBAL("ARCH_IS_MAC",function()
  return GAP_ARCHITECTURE=MACINTOSH_68K_ARCHITECTURE
      or GAP_ARCHITECTURE=MACINTOSH_PPC_ARCHITECTURE;
end);

#############################################################################
##
#F  ARCH_IS_WINDOWS()
##
##  tests whether {\GAP} is running on a Windows system.
BIND_GLOBAL("ARCH_IS_WINDOWS",function()
local l;
  l:=LEN_LIST(GAP_ARCHITECTURE);
  if l<9 then return false;fi; # trap some unixes with increadibly short
                               # string name
  return GAP_ARCHITECTURE{[l-6..l-4]}=WINDOWS_ARCHITECTURE;
end);

#############################################################################
##
#F  ARCH_IS_UNIX()
##
##  tests whether {\GAP} is running on a UNIX system.
BIND_GLOBAL("ARCH_IS_UNIX",function()
  return not (ARCH_IS_MAC() or ARCH_IS_WINDOWS());
end);

#############################################################################
##
#V  OBJLEN, DOUBLE_OBJLEN
##
##  `OBJLEN' is the number of bytes used for one `Obj' variable.
MAKE_READ_WRITE_GLOBAL("OBJLEN");
OBJLEN := 4;
# are we a 64 (or more) bit system?
while TNUM_OBJ(2^((OBJLEN-1)*8))=TNUM_OBJ(2^((OBJLEN+1)*8)) do
  OBJLEN := OBJLEN+4;
od;
MAKE_READ_ONLY_GLOBAL("OBJLEN");
BIND_GLOBAL("DOUBLE_OBJLEN",2*OBJLEN);


