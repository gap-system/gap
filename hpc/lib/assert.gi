#############################################################################
##
#W  assert.gi                   GAP library                      Steve Linton
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
##  We store this level in the "unpublished" global variable 
##  CurrentAssertionLevel
##
##  Assert itself is implemented in the kernel, see the scanner, reader, 
##  intrprtr, coder and stats packages
##  
##  This file is the GAP level implementation part of that package
##

#############################################################################
##
#V  CurrentAssertionLevel . . . . . . . . . . the level of assertion checking
#V  SetAssertionLevel() . . . . . . . .  sets the level of assertion checking
#V  AssertionLevel()  . . . . .  gets the current level of assertion checking
##
##
CurrentAssertionLevel := 0;

InstallGlobalFunction( SetAssertionLevel,  function( level )
    if IsInt(level) and level >= 0 then
        CurrentAssertionLevel := level;
    else
        Error("Usage SetAssertionLevel( <level> )");
    fi;
end );

InstallGlobalFunction( AssertionLevel, function()
    return CurrentAssertionLevel;
end );

        
#############################################################################
##
#E  assert.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

        

