#############################################################################
##
#W  global.gd                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
Revision.global_gd :=
    "@(#)$Id$";

#############################################################################
##
#O  ValueGlobal ( <name> ) .  . . . . . . . . . . access a global by its name
## 
##  ValueGlobal ( <name> ) returns the value currently bound to the global
##  variable named by the string <name>. An error is raised if no value
##  is currently bound
##

DeclareGlobalFunction("ValueGlobal");


#############################################################################
##
#O  IsBoundGlobal ( <name> ) . . . . . check if a global is bound by its name
## 
##  IsBoundGlobal ( <name> ) returns true if a value currently bound
##  to the global variable named by the string <name> and false otherwise
##


DeclareGlobalFunction("IsBoundGlobal");


#############################################################################
##
#O  UnbindGlobal ( <name> ) . . . . . . . . . .  unbind a global  by its name
## 
##  UnbindGlobal ( <name> ) removes any value currently bound
##  to the global variable named by the string <name>. Nothing is returned
##
##  A warning is given is <name> was not bound
##  The global variable named by <name> must be writable,
##  otherwise an error is raised.
## 

DeclareGlobalFunction("UnbindGlobal");

#############################################################################
##
#O  IsReadOnlyGlobal ( <name> ) . determine if a global variable is read-only
##
##  IsReadOnlyGlobal ( <name> ) returns true if the global variable
##  named by the string <name> is read-only and false otherwise (the default)
##

DeclareGlobalFunction("IsReadOnlyGlobal");

#############################################################################
##
#O  MakeReadOnlyGlobal ( <name> ) . . . . .  make a global variable read-only
##
##  MakeReadOnlyGlobal ( <name> ) marks the global variable named
##  by the string <name> as read-only. 
##
##  A warning is given if <name> has no value bound to it or if it is
##  already read-only
##

DeclareGlobalFunction("MakeReadOnlyGlobal");

#############################################################################
##
#O  MakeReadWriteGlobal ( <name> )  . . . . make a global variable read-write
##
##  MakeReadWriteGlobal ( <name> ) marks the global variable named
##  by the string <name> as read-write
##
## A warning is given if <name> is already read-write
##

DeclareGlobalFunction("MakeReadWriteGlobal");

#############################################################################
##
#O  BindGlobal ( <name>, <val> )  . . . . . . sets a global variable 'safely'
##
##  BindGlobal ( <name>, <val> ) sets the global variable named by
##  the string <name> to the value <val>, provided it was previously
##  unbound, and makes it read-only. This is intended to be the normal
##  way to create and set "official" global variable (such as
##  Operations and Categories)
##
##  An error is given if <name> already had a value bound.
##  

DeclareGlobalFunction("BindGlobal");

#############################################################################
##
#F  TemporaryGlobalVarName ( [<prefix>] )  name of an unbound global variable
##
##  TemporaryGlobalVarName ( [<prefix>] ) returns a string that can be used
##  as the name of a global variable that is not bound at the time when
##  TemporaryGlobalVarName() is called.  The optional argument prefix can
##  specify a string with which the name of the global variable starts.
##

DeclareGlobalFunction("TemporaryGlobalVarName");

#############################################################################
##
#E  global.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



