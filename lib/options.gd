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
##  <#GAPDoc Label="[1]{options}">
##  &GAP; supports a <E>global options system</E>. This is intended as a
##  way for the user to provide guidance to various algorithms that
##  might be used in a computation. Such guidance should not change
##  mathematically the specification of the computation to be
##  performed, although it may change the algorithm used. A typical
##  example is the selection of a strategy for the Todd-Coxeter coset
##  enumeration procedure. An example of something not suited to the
##  options mechanism is the imposition of exponent laws in the
##  <M>p</M>-Quotient algorithm.
##  <P/>
##  The basis of this system is a global stack of records. All the
##  entries of each record are thought of as options settings, and the
##  effective setting of an option is given by the topmost record
##  in which the relevant field is bound.
##  <P/>
##  The reason for the choice of a stack is the intended pattern of use:
##  <P/>
##  <C>PushOptions( rec( <A>stuff</A> ) );</C>
##  <P/>
##  <C>DoSomething( <A>args</A> );</C>
##  <P/>
##  <C>PopOptions();</C>
##  <P/>
##  This can be abbreviated,
##  to <C>DoSomething( <A>args</A> : <A>stuff</A> );</C> with
##  a small additional abbreviation of <A>stuff</A> permitted. See
##  <Ref Subsect="Function Call With Options"/> for details. The full form
##  can be used where the same options are to run across several
##  calls, or where the <C>DoSomething</C> procedure is actually an infix
##  operator, or other function with special syntax.
##  <P/>
##  An alternative to this system is the use of additional optional
##  arguments in procedure calls. This is not felt to be sufficient
##  because many procedure calls might cause, for example, a coset
##  enumeration and each would need to make provision for the
##  possibility of extra arguments. In this system the options are
##  pushed when the user-level procedure is called, and remain in
##  effect (unless altered) for all procedures called by it.
##  <P/>
##  Note that in some places in the system optional records containing
##  options which are valid only for the immediate function or method
##  call are in fact used.
##  <#/GAPDoc>
##


#############################################################################
##
#F  PushOptions( <options_record> )                           set new options
##
##  <#GAPDoc Label="PushOptions">
##  <ManSection>
##  <Func Name="PushOptions" Arg='options_record'/>
##
##  <Description>
##  This function pushes a record of options onto the global option stack.
##  Note that <C>PushOptions( rec( <A>opt</A>:= fail ) )</C> has the effect
##  of resetting the option <A>opt</A>, since an option that has never been
##  set has the value <K>fail</K> returned by <Ref Func="ValueOption"/>.
##  <P/>
##  Note that there is no check for misspelt or undefined options.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PushOptions");


#############################################################################
##
#F  PopOptions( )                                              remove options
##
##  <#GAPDoc Label="PopOptions">
##  <ManSection>
##  <Func Name="PopOptions" Arg=''/>
##
##  <Description>
##  This function removes the top-most options record from the options stack
##  if there is one.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PopOptions");


#############################################################################
##
#F  ResetOptionsStack( )                                   remove all options
##
##  <#GAPDoc Label="ResetOptionsStack">
##  <ManSection>
##  <Func Name="ResetOptionsStack" Arg=''/>
##
##  <Description>
##  unbinds (i.e. removes) all the options records from the options stack.
##  <P/>
##  <E>Note:</E>
##  <Ref Func="ResetOptionsStack"/> should <E>not</E> be used within a
##  function.
##  Its intended use is to clean up the options stack in the event
##  that the user has <K>quit</K> from a <K>break</K> loop,
##  so leaving a stack of no-longer-needed options
##  (see&nbsp;<Ref Subsect="quit"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ResetOptionsStack");


#############################################################################
##
#F  OnQuit( )                                   currently removes all options
##
##  <#GAPDoc Label="OnQuit">
##  <ManSection>
##  <Func Name="OnQuit" Arg=''/>
##
##  <Description>
##  called when a user selects to <C>quit;</C> a break loop entered via
##  execution of <Ref Func="Error"/>.
##  As &GAP; starts up, <Ref Func="OnQuit"/> is defined to do nothing,
##  in case an error is encountered during &GAP; start-up.
##  Later in the loading process we redefine <Ref Func="OnQuit"/> to do a variant of
##  <Ref Func="ResetOptionsStack"/> to ensure the options stack is empty
##  after a user quits an <Ref Func="Error"/>-induced break loop.
##  (<Ref Func="OnQuit"/> differs from <Ref Func="ResetOptionsStack"/>
##  in that it warns when it does something rather than the other way round.)
##  Currently, <Ref Func="OnQuit"/> is not advertised,
##  since exception handling may make it obsolete.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
#Unbind(OnQuit);                    # We don't do this because it would leave
#DeclareGlobalFunction( "OnQuit" ); # us vulnerable to an Error happening
                                    # before OnQuit's definition is installed


#############################################################################
##
#F  ValueOption( <opt> )
##
##  <#GAPDoc Label="ValueOption">
##  <ManSection>
##  <Func Name="ValueOption" Arg='opt'/>
##
##  <Description>
##  This function is a method for accessing the options stack without
##  changing it;
##  <A>opt</A> should be the name of an option, i.e.&nbsp;a string.
##  A function which makes decisions that might be affected by options
##  should examine the result of <Ref Func="ValueOption"/>.
##  If <A>opt</A> is currently not set then <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ValueOption");


#############################################################################
##
#F  DisplayOptionsStack( )                          display the options stack
##
##  <#GAPDoc Label="DisplayOptionsStack">
##  <ManSection>
##  <Func Name="DisplayOptionsStack" Arg=''/>
##
##  <Description>
##  This function prints a human-readable display of the complete
##  options stack.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DisplayOptionsStack");


#############################################################################
##
#V  InfoOptions                                        info class for options
##
##  <#GAPDoc Label="InfoOptions">
##  <ManSection>
##  <InfoClass Name="InfoOptions"/>
##
##  <Description>
##  This info class can be used to enable messages about options being
##  changed (level 1) or accessed (level 2).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoOptions");
