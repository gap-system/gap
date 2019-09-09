#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This package sets up a mechanism for diagnostic assertions at GAP
##  level. 
##  
##  These tests are controlled by a single global assertion level settable 
##  and readable by user functions SetAssertionLevel( <level> ) and 
##  AssertionLevel(). 
##  
##  The actual format of the check is Assert( <level>, <test> [, <message> ])
##  which is equivalent to either:
##
##      if AssertionLevel() >= <level> and <test> then
##          Error("Assertion <test> failed");
##      fi;
##
##  or
##
##      if AssertionLevel() >= <level> and <test> then
##          Print( <message> );
##      fi;
##
##  depending on the number of arguments.
##
##  Assert is a keyword implemented in the kernel
##
##  This file is the declarations part of that package
##

#############################################################################
##
#F  SetAssertionLevel() . . . . . . . .  sets the level of assertion checking
#F  AssertionLevel()  . . . . .  gets the current level of assertion checking
##
DeclareGlobalFunction("SetAssertionLevel");
DeclareGlobalFunction("AssertionLevel");
