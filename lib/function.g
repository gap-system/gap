#############################################################################
##
#W  function.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file deals with functions.
##
Revision.function_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsFunction( <obj> )	. . . . . . . . . . . . . . . . category of functions
##
DeclareCategoryKernel( "IsFunction",
    IS_OBJECT,
    IS_FUNCTION );


#############################################################################
##
#C  IsOperation( <obj> )  . . . . . . . . . . . . . .  category of operations
##
DeclareCategoryKernel( "IsOperation",
    IS_FUNCTION,
    IS_OPERATION );


#############################################################################
##

#V  FunctionsFamily . . . . . . . . . . . . . . . . . . . family of functions
##
BIND_GLOBAL( "FunctionsFamily", NewFamily( "FunctionsFamily", IsFunction ) );


#############################################################################
##
#V  TYPE_FUNCTION . . . . . . . . . . . . . . . . . . . .  type of a function
##
BIND_GLOBAL( "TYPE_FUNCTION", NewType( FunctionsFamily,
                          IsFunction and IsInternalRep ) );


#############################################################################
##
#F  TYPE_OPERATION  . . . . . . . . . . . . . . . . . . . type of a operation
##
BIND_GLOBAL( "TYPE_OPERATION",
    NewType( FunctionsFamily,
             IsFunction and IsOperation and IsInternalRep ) );


#############################################################################
##

#F  NameFunction( <func> )  . . . . . . . . . . . . . . .  name of a function
##
##  If objects simulate functions this must become an operation.
##
BIND_GLOBAL( "NameFunction", NAME_FUNC );


#############################################################################
##
#F  CallFuncList( <func>, <args> )  . . . . . . . . . . . . . call a function
##
##  If objects simulate functions this must become an operation.
##
UNBIND_GLOBAL("CallFuncList"); # was declared 2b defined
BIND_GLOBAL( "CallFuncList", CALL_FUNC_LIST );


#############################################################################
##
#F  ReturnTrue( ... ) . . . . . . . . . . . . . . . . . . . . . . always true
##
BIND_GLOBAL( "ReturnTrue", RETURN_TRUE );


#############################################################################
##
#F  ReturnFalse( ... )  . . . . . . . . . . . . . . . . . . . .  always false
##
BIND_GLOBAL( "ReturnFalse", RETURN_FALSE );


#############################################################################
##
#F  ReturnFail( ... ) . . . . . . . . . . . . . . . . . . . . . . always fail
##
BIND_GLOBAL( "ReturnFail", RETURN_FAIL );


#############################################################################
##
#F  IdFunc( <obj> ) . . . . . . . . . . . . . . . . . . . . . .  return <obj>
##
BIND_GLOBAL( "IdFunc", ID_FUNC );


#############################################################################
##
#M  ViewObj( <func> ) . . . . . . . . . . . . . . . . . . . . . . view method
##

InstallMethod( ViewObj, "for a function", true, [IsFunction], 0,
        function ( func )
    local nams, i;
    Print("function( ");
    nams := NAMS_FUNC(func);
    if nams = fail then
        Print( "<",NARG_FUNC(func)," unnamed arguments>" );
    elif LEN_LIST(nams) > 0 then
        Print(nams[1]);
        for i in [2..LEN_LIST(nams)] do
            Print(", ",nams[i]);
        od;
    fi;
    Print(" ) ... end");
end);
        

#############################################################################
##

#E  function.g	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
