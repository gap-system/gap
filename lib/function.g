#############################################################################
##
#W  function.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file dealing with functions
##
Revision.function_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsFunction( <obj> )	. . . . . . . . . . . . . . . . category of functions
##
IsFunction := NewCategoryKernel(
    "IsFunction",
    IS_OBJECT,
    IS_FUNCTION );


#############################################################################
##
#C  IsOperation( <obj> )  . . . . . . . . . . . . . .  category of operations
##
IsOperation := NewCategoryKernel(
    "IsOperation",
    IS_FUNCTION,
    IS_OPERATION );


#############################################################################
##

#V  FunctionsFamily . . . . . . . . . . . . . . . . . . . family of functions
##
FunctionsFamily := NewFamily(  "FunctionsFamily", IsFunction );


#############################################################################
##
#V  TYPE_FUNCTION . . . . . . . . . . . . . . . . . . . .  type of a function
##
TYPE_FUNCTION := NewType( FunctionsFamily,
                          IsFunction and IsInternalRep );


#############################################################################
##
#F  TYPE_OPERATION  . . . . . . . . . . . . . . . . . . . type of a operation
##
TYPE_OPERATION := NewType( FunctionsFamily,
                           IsFunction and IsOperation and IsInternalRep );


#############################################################################
##

#F  NameFunction( <func> )  . . . . . . . . . . . . . . .  name of a function
##
##  If objects simulate functions this must become an operation.
##
NameFunction := NAME_FUNC;


#############################################################################
##

#E  function.g	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
