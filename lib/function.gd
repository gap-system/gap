
#############################################################################
##
#W  function.gd                GAP library                     Steve Linton
##
##
#Y  Copyright (C) 2015 The GAP Group
##
##  This file contains the declarations of the functions and operations
##  relating to functions and function-calling which are not so basic
##  that they need to be in function.g
##


#############################################################################
##
#F  CallWithTimeout( <timeout>, <func>[, <arg1>[, <arg2>....]] )  
##         . . call a function with a time limit
#F  CallWithTimeoutList( <timeout>, <func>, <arglist> )  
##
##  <#GAPDoc Label="CallWithTimeout">
##  <ManSection>
##  <Func Name="CallWithTimeout" Arg='timeout, func, .....'/>
##  <Func Name="CallWithTimeoutList" Arg='timeout, func, args'/>
##
##  <Description>
##    CallWithTimeout and CallWithTimeoutList support calling a function
##  with a limit on the CPU time it can consume. 
##
##  If the call completes within the allotted time and returns a value, the result of 
##  CallWithTimeout[List] is a length 1 list containing that value. 
##  
##  If the call completes within the allotted time and returns no value, the result of 
##  CallWithTimeout[List] is an empty list.
##
##  If the call does not complete within the timeout, the result of CallWithTimeout[List]
## is fail.
##
##  The timer is suspended during execution of a break loop and abandoned when you quit from a break loop.
##
## CallWithTimeout is variadic. 
##  Its third and subsequent arguments if any are the arguments if any passed to <func>
##  CallWithTimeoutList in contract takes exactly three arguments, of which the third is a list
##  (possibly empty) or arguments to pass to <func>. 
## 
##  The limit <timeout> is specified as a record. At present the following components are recognised
##  nanoseconds, microseconds, milliseconds, seconds, minutes, hours, days and weeks. Any of these 
##  components which is present should be bound to a positive integer, rational or float and the times
##  represented are totalled.
##
##  Further components are permitted and ignored, to allow for future functionality.
##
##  As a shorthand, a single positive integers may be supplied, and is taken as a number of microseconds
##
##  The precision of the timeouts is not guaranteed, and there is a system dependent upper limit on the timeout 
##  which is typically about 8 years on 32 bit systems and about 30 billion years on 64 bit systems. Timeouts longer
##  than this will be silently ignored. 
##

DeclareGlobalFunction("CallWithTimeout");
DeclareGlobalFunction("CallWithTimeoutList");

