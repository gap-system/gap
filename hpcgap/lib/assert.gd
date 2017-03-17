#############################################################################
##
#W  assert.gd                   GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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

        
#############################################################################
##
#E  assert.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here  
##

