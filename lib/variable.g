#############################################################################
##
#W  variable.g                  GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the functions for the special handling of those global
##  variables in {\GAP} library files that are *not* functions;
##  they are declared with `DeclareGlobalVariable' and initialized with
##  `InstallGlobal' resp.~`InstallFlushableGlobal'.
##
##  For the global functions in the {\GAP} libraray, see `oper.g'.
##
Revision.variable_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsToBeDefinedObj. . . . . . . .  represenation of "to be defined" objects
##
DeclareCategory( "IsToBeDefinedObj", IsObject );


#############################################################################
##
#V  ToBeDefinedObjFamily  . . . . . . . . . family of "to be defined" objects
##
BIND_GLOBAL( "ToBeDefinedObjFamily",
    NewFamily( "ToBeDefinedObjFamily", IsToBeDefinedObj ) );


#############################################################################
##
#V  ToBeDefinedObjType  . . . . . . . . . . . type of "to be defined" objects
##
BIND_GLOBAL( "ToBeDefinedObjType", NewType(
    ToBeDefinedObjFamily, IsPositionalObjectRep ) );


#############################################################################
##
#F  NewToBeDefinedObj() . . . . . . . . . create a new "to be defined" object
##
BIND_GLOBAL( "NewToBeDefinedObj", function(name)
    return Objectify( ToBeDefinedObjType, [name] );
end );



#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . . . .  print "to be defined" object
##
InstallMethod( PrintObj,
    "for 'to be defined' objects",
    true,
    [ IsToBeDefinedObj ],
    0,

function(obj)
    Print( "<< ",obj![1]," to be defined>>" );
end );


#############################################################################
##
#O  FlushCaches( ) . . . . . . . . . . . . . . . . . . . . . Clear all caches
##
##  `FlushCaches()' will clear all clearable internal caches defined by
##  `InstallFlushableValue'.
##  These caches hold objects like finite fields once created and are used
##  to speed up computations as well as to avoid creating unique objects
##  several times, so `FlushCaches' is thought for debugging purposes.
##
##  All methods for `FlushCaches' must be installed that they clear the
##  cache and then return on `TryNextMethod', thus one call to `FlushCaches'
##  allows to run all methods.
##
DeclareOperation( "FlushCaches", [] );
# This method is just that one method is callable. It is installed first, so
# it will be last in line.
InstallMethod(FlushCaches,"return method",true,[],0,function()end);


#############################################################################
##
#F  DeclareGlobalVariable( <name>, <description> )
##
##  `DeclareGlobalVariable' creates a new global variable named by the
##  string <name>.
##  The second argumant <description> must be a string that describes the
##  meaning of the global variable.
##  Values can be assigned to the new variable with `InstallGlobal' or
##  `InstallFlushableGlobal'.
##
BIND_GLOBAL( "DeclareGlobalVariable", function( arg )
    BIND_GLOBAL( arg[1], NewToBeDefinedObj(arg[1]) );
end );


#############################################################################
##
#F  InstallValue( <gvar>, <value> )
#F  InstallFlushableValue( <gvar>, <value> )
##
##  `InstallValue' assigns the value <value> to the global variable <gvar>.
##  `InstallFlushableValue' does the same but additionally provides that
##  each call of `FlushCaches' will assign a structural copy of <value>
##  to <gvar>.
##  `InstallFlushableValue' works only if <value> is a list.
##
##  Using `DeclareGlobalVariable' and `InstallFlushableValue' has several
##  advantages, compared to simple assignments.
##  1. The initial value must be written down only once in the file;
##     this is an argument in particular for the variable `Primes2'.
##  2. The implementation of `FlushCaches' is not prescribed,
##     at least it is hidden in the function `InstallFlushableValue'.
##  3. It is possible to access the `#V' global variables from within GAP,
##     perhaps separately for each package;
##     Note that the assignments of other global variables via
##     `DeclareOperation', `DeclareProperty' etc. would admit this already.
#T     (This would raise the question whether also immutable `#V' variables
#T     shall be defined via a function call.)
##
##  (Note that `InstallFlushableValue' makes sense only for *mutable*
##  global variables.)
##
BIND_GLOBAL( "InstallValue", CLONE_OBJ );

BIND_GLOBAL( "InstallFlushableValue", function( gvar, value )
    local initval;

    if not IS_LIST( value ) then
      Error( "<value> must be a list" );
    fi;

    # Make a structural copy of the initial value.
    initval:= DEEP_COPY_OBJ( value );
    
    
    # Initialize the variable.
    CLONE_OBJ( gvar, value );

    # Install the method to flush the cache.
    InstallMethod( FlushCaches,
        true,
        [], 0,
        function()
            local i;
            for i in [ 1 .. LEN_LIST( gvar ) ] do
              Unbind( gvar[i] );
            od;
            for i in [ 1 .. LEN_LIST( initval ) ] do
              if IsBound( initval[i] ) then
                gvar[i]:= DEEP_COPY_OBJ( initval[i] );
              fi;
            od;
            TryNextMethod();
        end );
end );


#############################################################################
##

#E  variable.g 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here

