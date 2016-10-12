
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
##  <Index>Timeouts</Index>
##  <ManSection>
##  <Func Name="CallWithTimeout" Arg='timeout, func, .....'/>
##  <Func Name="CallWithTimeoutList" Arg='timeout, func, arglist'/>
##
##  <Description>
##    <C>CallWithTimeout</C> and <C>CallWithTimeoutList</C> support calling a function
##  with a limit on the CPU time it can consume. <P/>
##
##  This functionality may not be available on all systems and you should check 
##  <Ref Var="GAPInfo.TimeoutsSupported"/> before using this functionality.<P/>
##
##  <C>CallWithTimeout</C> is variadic. 
##  Its third and subsequent arguments, if any, are the arguments passed to <A>func</A>.
##  <C>CallWithTimeoutList</C> in contrast takes exactly three arguments, of which the third is a list
##  (possibly empty) or arguments to pass to <A>func</A>. <P/>
##
##  If the call completes within the allotted time and returns a value, the result of 
##  <C>CallWithTimeout[List]</C> is a length 1 list containing that value. <P/>
##  
##  If the call completes within the allotted time and returns no value, the result of 
##  <C>CallWithTimeout[List]</C> is an empty list.<P/>
##
##  If the call does not complete within the timeout, the result of <C>CallWithTimeout[List]</C>
##  is <K>fail</K>. In this case, just as if you had <C>quit</C> from a break loop, there is some
##  risk that internal data structures in &GAP; may have been left in an inconsistent state, and you 
##  should proceed with caution.<P/>
##
##  The timer is suspended during execution of a break loop and abandoned when you quit from a break loop.<P/>
##
##  Timeouts may not be nested. That is, during execution of <C>CallWithTimeout(<A>timeout</A>,<A>func</A>,...)</C>,
##  <A>func</A> (or functions it calls) may not call <C>CallWithTimeout</C> or <C>CallWithTimeoutList</C>. 
##  This restriction may be lifted on at least some systems in future releases. It is 
##  permitted to use <C>CallWithTimeout</C> or <C>CallWithTimeoutList</C> from within a break loop, even if a
##  suspended timeout exists, although there is limit on the depth of such nesting.<P/>
##
##  The limit <A>timeout</A> is specified as a record. At present the following components are recognised
##  <C>nanoseconds</C>, <C>microseconds</C>, <C>milliseconds</C>, <C>seconds</C>, 
##  <C>minutes</C>, <C>hours</C>, <C>days</C> and <C>weeks</C>. Any of these 
##  components which is present should be bound to a positive integer, rational or float and the times
##  represented are totalled to give the actual timeout. As a shorthand, a single positive 
##  integers may be supplied, and is taken as a number of microseconds.
##  Further components are permitted and ignored, to allow for future functionality.<P/>
##
##  The precision of the timeouts is not guaranteed, and there is a system dependent upper limit on the timeout 
##  which is typically about 8 years on 32 bit systems and about 30 billion years on 64 bit systems. Timeouts longer
##  than this will be reduced to this limit. On Windows systems, timing is based on elapsed time, not CPU time
##  because the necessary POSIX CPU timing API is not supported.<P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareGlobalFunction("CallWithTimeout");
DeclareGlobalFunction("CallWithTimeoutList");

