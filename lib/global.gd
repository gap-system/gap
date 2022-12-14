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
##
##  This file contains the second stage of the "public" interface to
##  the global variable namespace, allowing globals to be accessed and
##  set by name.
##
##  This is defined in two stages. global.g defines "capitalized" versions
##  of the functions which do not use Info or other niceties and are not
##  set up with InstallGlobalFunction. This can thus be read early, and
##  the functions it defines can be used to define functions used to read
##  more of the library.
##
##  This file and global.gi stages  install the really "public"
##  functions and can be read later (once Info, DeclareGlobalFunction,
##  etc are there)
##
##  All of these functions give a warning if the global variable name
##  contains characters not recognised as part of identifiers by the
##  GAP parser
##

#############################################################################
##
#F  IsValidIdentifier( <str> ) . . .  check if a string is a valid identifier
##
##  <#GAPDoc Label="IsValidIdentifier">
##  <ManSection>
##  <Func Name="IsValidIdentifier" Arg='str'/>
##
##  <Description>
##  returns <K>true</K>  if  the  string  <A>str</A>  would  form  a  valid  identifier
##  consisting of letters,  digits  and  underscores;  otherwise  it  returns
##  <K>false</K>. It does not check whether <A>str</A> contains characters escaped by a
##  backslash <C>\</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IsValidIdentifier");


#############################################################################
##
#F  ValueGlobal( <name> )  .  . . . . . . . . . . access a global by its name
##
##  <ManSection>
##  <Func Name="ValueGlobal" Arg='name'/>
##
##  <Description>
##  ValueGlobal ( <A>name</A> ) returns the value currently bound to the global
##  variable named by the string <A>name</A>. An error is raised if no value
##  is currently bound
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ValueGlobal");


#############################################################################
##
#F  IsBoundGlobal( <name> )  . . . . . check if a global is bound by its name
##
##  <ManSection>
##  <Func Name="IsBoundGlobal" Arg='name'/>
##
##  <Description>
##  IsBoundGlobal ( <A>name</A> ) returns true if a value is currently bound
##  to the global variable named by the string <A>name</A> and false otherwise
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsBoundGlobal");

#############################################################################
##
#F  IsAutoGlobal( <name> )  . . . . . check if a global is automatic
##
##  <ManSection>
##  <Func Name="IsAutoGlobal" Arg='name'/>
##
##  <Description>
##  IsAutoGlobal ( <A>name</A> ) returns true if there is a global variable
##  named <A>name</A>, declared using
##  <Ref Func="DeclareAutoreadableVariables"/>, which has not yet been
##  accessed. This means reading this variable's value will cause code
##  to be executed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsAutoGlobal");

#############################################################################
##
#F  UnbindGlobal( <name> )  . . . . . . . . . .  unbind a global  by its name
##
##  <ManSection>
##  <Func Name="UnbindGlobal" Arg='name'/>
##
##  <Description>
##  UnbindGlobal ( <A>name</A> ) removes any value currently bound
##  to the global variable named by the string <A>name</A>. Nothing is returned
##  <P/>
##  A warning is given if <A>name</A> was not bound
##  The global variable named by <A>name</A> must be writable,
##  otherwise an error is raised.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("UnbindGlobal");


#############################################################################
##
#F  IsReadOnlyGlobal( <name> )  . determine if a global variable is read-only
##
##  <ManSection>
##  <Func Name="IsReadOnlyGlobal" Arg='name'/>
##
##  <Description>
##  IsReadOnlyGlobal ( <A>name</A> ) returns true if the global variable
##  named by the string <A>name</A> is read-only and false otherwise (the default)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsReadOnlyGlobal");

#############################################################################
##
#F  IsConstantGlobal( <name> )  . determine if a global variable is constant
##
##  <ManSection>
##  <Func Name="IsConstantGlobal" Arg='name'/>
##
##  <Description>
##  IsConstantGlobal ( <A>name</A> ) returns true if the global variable
##  named by the string <A>name</A> is constant and false otherwise (the default).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsConstantGlobal");


#############################################################################
##
#F  MakeReadOnlyGlobal( <name> )  . . . . .  make a global variable read-only
##
##  <ManSection>
##  <Func Name="MakeReadOnlyGlobal" Arg='name'/>
##
##  <Description>
##  MakeReadOnlyGlobal ( <A>name</A> ) marks the global variable named
##  by the string <A>name</A> as read-only.
##  <P/>
##  A warning is given if <A>name</A> has no value bound to it or if it is
##  already read-only
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MakeReadOnlyGlobal");


#############################################################################
##
#F  MakeReadWriteGlobal( <name> )   . . . . make a global variable read-write
##
##  <ManSection>
##  <Func Name="MakeReadWriteGlobal" Arg='name'/>
##
##  <Description>
##  MakeReadWriteGlobal ( <A>name</A> ) marks the global variable named
##  by the string <A>name</A> as read-write
##  <P/>
##  A warning is given if <A>name</A> is already read-write
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MakeReadWriteGlobal");


#############################################################################
##
#F  MakeConstantGlobal( <name> )   . . . . .  make a global variable constant
##
##  <#GAPDoc Label="MakeConstantGlobal">
##  <ManSection>
##  <Func Name="MakeConstantGlobal" Arg='name'/>
##
##  <Description>
##  MakeConstantGlobal ( <A>name</A> ) marks the global variable named
##  by the string <A>name</A> as constant. A constant variable can never
##  be reassigned or made read-write again.
##  <P/>
##  A warning is given if <A>name</A> is already constant.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MakeConstantGlobal");


#############################################################################
##
#F  BindGlobal( <name>, <val> )   . . . . . . sets a global variable `safely'
##
##  <#GAPDoc Label="BindGlobal">
##  <ManSection>
##  <Func Name="BindGlobal" Arg='name, val'/>
##  <Func Name="BindConstant" Arg='name, val'/>
##
##  <Description>
##  <Ref Func="BindGlobal"/> and <Ref Func="BindConstant"/> set the global
##  variable named by the string <A>name</A> to the value <A>val</A>,
##  provided that variable is writable. <Ref Func="BindGlobal"/> makes
##  the resulting variable read-only, while <Ref Func="BindConstant"/> makes
##  it constant.
##  If <A>name</A> already had a value, a warning message is printed.
##  <P/>
##  This is intended to be the normal way to create and set <Q>official</Q>
##  global variables (such as operations, filters and constants).
##  <P/>
##  Caution should be exercised in using these functions, especially
##  <Ref Func="UnbindGlobal"/> as unexpected changes
##  in global variables can be very confusing for the user.
##  <P/>
##  <Example><![CDATA[
##  gap> xx := 16;
##  16
##  gap> IsReadOnlyGlobal("xx");
##  false
##  gap> ValueGlobal("xx");
##  16
##  gap> IsBoundGlobal("xx");
##  true
##  gap> BindGlobal("xx",17);
##  #W BIND_GLOBAL: variable `xx' already has a value
##  gap> xx;
##  17
##  gap> IsReadOnlyGlobal("xx");
##  true
##  gap> MakeReadWriteGlobal("xx");
##  gap> Unbind(xx);
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("BindGlobal");
DeclareGlobalFunction("BindConstant");
