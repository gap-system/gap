#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton, Hans Ulrich Besche, Max Neuenhoeffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file defines some functions associated with method selection,
##  which do not need to be compiled by default. More performance critical
##  functions are implemented in the kernel.
##

# gaplint: disable=analyse-lvars

##  This is a dirty hack, because this function is defined only later:
ApplicableMethod := fail;
##  See below for the other part of it!


#############################################################################
##
#F  HANDLE_METHOD_NOT_FOUND( <information> ) . . . raise the method not
##
##  <ManSection>
##  <Func Name="HANDLE_METHOD_NOT_FOUND" Arg='information'/>
##
##  <Description>
##                                              found error
##  <P/>
##  <A>information</A> is a plain record passed by the kernel when no
##  method is found. Components so far defined are:
##  <P/>
##  .Operation --     the operation called
##  .Arguments --     the arguments as a plain (immutable) list
##  .isVerbose --     if the operation was being traced
##  .isConstructor -- if the operation is a constructor
##  .Precedence --    the "precedence" of the method sought 0 for
##                    first choice, 1 after one TryNextMethod(), etc.
##  </Description>
##  </ManSection>
##
HANDLE_METHOD_NOT_FOUND := function ( INF )
  local no_method_found, linebreak, ShowArguments, ShowArgument, ShowDetails, ShowMethods,
             ShowOtherMethods, argument_index;


#############################################################################
##
#F  ShowArguments( )  . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
##  <#GAPDoc Label="ShowArguments">
##  <ManSection>
##  <Func Name="ShowArguments" Arg=''/>
##
##  <Description>
##  This function is only available within a break loop caused by a <Q>No
##  Method Found</Q>-error. It prints as a list the arguments of the operation
##  call for which no method was found.
##  <!-- %%  <C>ShowArguments</C> can -->
##  <!-- %%  be called with any number of arguments. They are ignored. -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
ShowArguments := function( arg )
    Print( INF.Arguments, "\n" );
end;

#############################################################################
##
#F  ShowArgument(<nr>)  . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
##  <#GAPDoc Label="ShowArgument">
##  <ManSection>
##  <Func Name="ShowArgument" Arg='nr'/>
##
##  <Description>
##  This function is only available within a break loop caused by a <Q>No
##  Method Found</Q>-error.
##  It prints the <A>nr</A>-th arguments of the operation call
##  for which no method was found.
##  <Ref Func="ShowArgument"/> needs exactly one
##  argument which is an integer between 0 and the number of arguments the
##  operation was called with.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
ShowArgument := function( arg )
  if LENGTH(arg) <> 1 or not IS_INT(arg[1]) or arg[1] <= 0
     or arg[1] > LENGTH(INF.Arguments) then
    Print( "Usage: `ShowArgument( <nr> )' where <nr> is an integer between ",
           1," and ",LENGTH(INF.Arguments),"\n");
  else
    Print( INF.Arguments[arg[1]], "\n" );
  fi;
end;

#############################################################################
##
#F  ShowDetails( )  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
##  <#GAPDoc Label="ShowDetails">
##  <ManSection>
##  <Func Name="ShowDetails" Arg=''/>
##
##  <Description>
##  This function is only available within a break loop caused by a <Q>No
##  Method Found</Q>-error. It prints the details of this error: The
##  operation, the number of arguments, a flag which indicates whether the
##  operation is being traced, a flag which indicates whether the
##  operation is a constructor method, and the number of methods that
##  refused to apply by calling <Ref Func="TryNextMethod"/>.
##  The last number is called <C>Choice</C> and is printed as an ordinal.
##  So if exactly <M>k</M> methods were found but called
##  <Ref Func="TryNextMethod"/> and there were no more methods
##  it says <C>Choice: </C><M>k</M><C>th</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  %%  `ShowDetails' can be called with any number of
##  %%  arguments. They are ignored.
##
ShowDetails := function( arg )
  Print( "--------------------------------------------\n");
  Print( "Information about a `No method found'-error:\n");
  Print( "--------------------------------------------\n");
  Print( "Operation           : ", NAME_FUNC( INF.Operation ), "\n" );
  Print( "Number of Arguments : ", LENGTH( INF.Arguments ), "\n" );
  Print( "Operation traced    : ", INF.isVerbose, "\n" );
  Print( "IsConstructor       : ", INF.isConstructor, "\n" );
  Print( "Choice              : ", Ordinal(INF.Precedence+1), "\n" );
end;

#############################################################################
##
#F  ShowMethods( [<verbosity>] )  . . . . . . . . . . . . . . . . . . . . . .
##
##  <#GAPDoc Label="ShowMethods">
##  <ManSection>
##  <Func Name="ShowMethods" Arg='[verbosity]'/>
##
##  <Description>
##  This function is only available within a break loop caused by a <Q>No
##  Method Found</Q>-error. It prints an overview about the installed methods
##  for those arguments the operation was called with (using
##  <Ref Sect="sect:ApplicableMethod"/>. The verbosity can be
##  controlled by the optional integer parameter <A>verbosity</A>. The default
##  is 2, which lists all applicable methods. With verbosity 1
##  <Ref Func="ShowMethods"/> only shows the number of installed methods and the
##  methods matching, which can only be those that were already called but
##  refused to work by calling <Ref Func="TryNextMethod"/>.
##  With verbosity 3 not only
##  all installed methods but also the reasons why they do not match are
##  displayed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
ShowMethods := function( arg )
  local verbosity;
  if LENGTH(arg) <> 1 or not IS_INT(arg[1]) then
    verbosity := 2;
  elif arg[1] < 1 then
    verbosity := 1;
  else
    verbosity := arg[1];
  fi;
  ApplicableMethod( INF.Operation, INF.Arguments, verbosity, "all" );
end;

#############################################################################
##
#F  ShowOtherMethods( [<verbosity>] ) . . . . . . . . . . . . . . . . . . . .
##
##  <#GAPDoc Label="ShowOtherMethods">
##  <ManSection>
##  <Func Name="ShowOtherMethods" Arg='[verbosity]'/>
##
##  <Description>
##  This function is only available within a break loop caused by a <Q>No
##  Method Found</Q>-error. It prints an overview about the installed methods
##  for a different number of arguments than the number of arguments the
##  operation was called with (using <Ref Sect="sect:ApplicableMethod"/>.
##  The verbosity can be controlled by the optional
##  integer parameter <A>verbosity</A>. The default is 1 which lists only the
##  number of applicable methods.
##  With verbosity 2 <Ref Func="ShowOtherMethods"/> lists
##  all installed methods and with verbosity 3 also the reasons, why they
##  are not applicable.
##  Calling <Ref Func="ShowOtherMethods"/> with verbosity 3 in this
##  function will normally not make any sense, because the different
##  numbers of arguments are simulated by supplying the corresponding
##  number of ones, for which normally no reasonable methods will be
##  installed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
ShowOtherMethods := function( arg )
  local verbosity, i, l, args;
  if LENGTH(arg) <> 1 or not IS_INT(arg[1]) then
    verbosity := 1;
  elif arg[1] < 1 then
    verbosity := 1;
  else
    verbosity := arg[1];
  fi;
  l := [0..6];
  args := [];
  for i in l do
    if i <> LENGTH( INF.Arguments ) then
      ApplicableMethod( INF.Operation, args, verbosity, "all" );
      Print( "\n" );
    fi;
    ADD_LIST(args,1);
  od;
end;

# Remember, we are in the function `HANDLE_METHOD_NOT_FOUND'!

  no_method_found := "";
  APPEND_LIST(no_method_found,
        "no method found! For debugging hints type ?Recovery from NoMethodFound\n" );

  APPEND_LIST(no_method_found, "Error, no ");
  APPEND_LIST(no_method_found,Ordinal(INF.Precedence+1));
  APPEND_LIST(no_method_found," choice method found for `");
  APPEND_LIST(no_method_found,NAME_FUNC(INF.Operation));
  APPEND_LIST(no_method_found,"' on ");
  APPEND_LIST(no_method_found,STRING_INT(LENGTH(INF.Arguments)));
  APPEND_LIST(no_method_found," arguments");

  linebreak := true;
  for argument_index in [ 1 .. LENGTH(INF.Arguments) ] do
    if INF.Arguments[argument_index] = fail then
      if linebreak then
        APPEND_LIST(no_method_found, "\n");
        linebreak := false;
      fi;
      APPEND_LIST(no_method_found, "The ");
      APPEND_LIST(no_method_found, Ordinal(argument_index));
      APPEND_LIST(no_method_found, " argument is 'fail' which might point to an earlier problem\n" );
    fi;
  od;
  ErrorNoReturn(no_method_found);
end;

## This is the other part of the above mentioned dirty trick:
Unbind( ApplicableMethod );


#############################################################################
##
#F  NONAVAILABLE_SHOW_FUNC( ) . . . . . . . . . . . . . . . . . . . . . . . .
##
##  <ManSection>
##  <Func Name="NONAVAILABLE_SHOW_FUNC" Arg=''/>
##
##  <Description>
##  This is an excuse if the user tries to call the <C>Show...</C> functions
##  without a NoMethodFound-error.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "NONAVAILABLE_SHOW_FUNC", function( arg )
    Error( "this function is only available after a 'no method found'-Error" );
end );

# The following comes in handy also for command line completion:
BIND_GLOBAL( "ShowArguments", NONAVAILABLE_SHOW_FUNC );
BIND_GLOBAL( "ShowArgument", NONAVAILABLE_SHOW_FUNC );
BIND_GLOBAL( "ShowDetails", NONAVAILABLE_SHOW_FUNC );
BIND_GLOBAL( "ShowMethods", NONAVAILABLE_SHOW_FUNC );
BIND_GLOBAL( "ShowOtherMethods", NONAVAILABLE_SHOW_FUNC );
