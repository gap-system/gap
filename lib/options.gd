#############################################################################
##
#W  options.gd                     GAP library                   Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
#1
##  {\GAP} Supports a global Options system. This is intended as a
##  way for the user to provide guidance to various algorithms that
##  might be used in a computation. Such guidance should not change
##  mathematically the specification of the computation to be
##  performed, although it may change the algorithm used. A typical
##  example is the selection of a strategy for the Todd-Coxeter coset
##  enumeration procedure. An example of something not suited to the
##  options mechanism is the imposition of exponent laws in the
##  $p$-Quotient algorithm.
##
##  The basis of this system is a global stack of records. All the
##  entries of each record are thought of as options settings, and the 
##  effective setting of an option is given by the topmost record
##  in which the relevant field is bound.
##
##  The reason for the choice of a stack is the intended pattern of use:
##
##  \begintt
##  PushOptions( rec( <stuff> ) );
##  DoSomething( <args> );
##  PopOptions();
##  \endtt
##
##  This can be abbreviated, to `DoSomething( <args> : <stuff> );' with
##  a small additional abbreviation of <stuff> permitted. See
##  "ref:function call with options" for details. The full form
##  can be used where the same options are to run across several
##  calls, or where the `DoSomething' procedure is actually a binary
##  operation, or other function with special syntax. 
##
##  At some time, an options predicate or something of the kind may
##  be added to method selection.
##
##  An alternative to this system is the use of additional optional
##  arguments in procedure calls. This is not felt to be adequate
##  because many procedure calls might cause, for example, a coset
##  enumeration and each would need to make provision for the
##  possibility of extra arguments. In this system the options are
##  pushed when the user-level procedure is called, and remain in
##  effect (unless altered) for all procedures called by it.
##
##
Revision.options_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  PushOptions( <options record> )                           set new options
##
##  This function pushes a record of options onto the global option
##  stack. Note that `PushOption(rec(<opt> := fail))' has the effect of
##  resetting option <opt>, since an option that has never been set
##  has the value `fail' returned by `ValueOptions'.
##
##  Note that there is no check for misspelt or undefined options.

DeclareGlobalFunction( "PushOptions");

#############################################################################
##
#F  PopOptions( )                                              remove options
##
##  This function removes the top-most options record from the options stack.
##
DeclareGlobalFunction( "PopOptions");

#############################################################################
##
#F  ResetOptionsStack( )                                   remove all options
##
##  unbinds (i.e. removes) all the options records from the options stack.
##
##  *Note:*
##  `ResetOptionsStack' should *not* be used within a function. Its  intended
##  use is to clean up the options stack in  the  event  that  the  user  has
##  `quit' from a `break'  loop,  so  leaving  a  stack  of  no-longer-needed
##  options (see~"quit").
##
DeclareGlobalFunction( "ResetOptionsStack");

#############################################################################
##
#F  ValueOption( <opt> )                                       access options
##
##  This function is the main method of accessing the Options Stack;
##  <opt> should be the name of an option, i.e.~a string. A 
##  function which makes decisions which might be affected by options should
##  examine the result of `ValueOption( <opt> )'. If <opt> has never
##  been set then `fail' is returned.
##

DeclareGlobalFunction( "ValueOption");

#############################################################################
##
#F  DisplayOptionsStack( )                          display the options stack
##
##  This function prints a human-readable display of the complete
##  options stack.
##  
##

DeclareGlobalFunction( "DisplayOptionsStack");

#############################################################################
##
#V  InfoOptions                                        info class for options
##
##  This info class can be used to enable messages about options being 
##  changed (level 1) or accessed (level 2).
##

DeclareInfoClass("InfoOptions");

#############################################################################
##
#E  options.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
