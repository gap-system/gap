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
