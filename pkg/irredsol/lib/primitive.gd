############################################################################
##
##  primitive.gd                 IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: primitive.gd,v 1.2 2005/02/14 12:26:23 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#F  IrreducibleMatrixGroupPrimitiveSolvableGroup(<G>)
#F  IrreducibleMatrixGroupPrimitiveSolvableGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("IrreducibleMatrixGroupPrimitiveSolvableGroup");
DeclareGlobalFunction ("IrreducibleMatrixGroupPrimitiveSolvableGroupNC");


############################################################################
##
#F  PrimitivePcGroupIrreducibleMatrixGroup(<G>)
#F  PrimitivePcGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("PrimitivePcGroupIrreducibleMatrixGroup");
DeclareGlobalFunction ("PrimitivePcGroupIrreducibleMatrixGroupNC");


############################################################################
##
#F  PrimitivePermutationGroupIrreducibleMatrixGroup(<G>)
#F  PrimitivePermutationGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("PrimitivePermutationGroupIrreducibleMatrixGroup");
DeclareGlobalFunction ("PrimitivePermutationGroupIrreducibleMatrixGroupNC");


############################################################################
##
#F  DoIteratorPrimitiveSolvableGroups(<convert_func>, <arg_list>)
##
##  generic constructor function for an iterator of all primitive solvable groups
##  which can construct permutation groups or pc groups (or other types of groups),
##  depending on convert_func
##  
DeclareGlobalFunction("DoIteratorPrimitiveSolvableGroups");


###########################################################################
##
#F  IteratorPrimitivePcGroups(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("IteratorPrimitivePcGroups");


###########################################################################
##
#F  AllPrimitivePcGroups(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("AllPrimitivePcGroups");


###########################################################################
##
#F  OnePrimitivePcGroup(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("OnePrimitivePcGroup");



###########################################################################
##
#F  IteratorPrimitiveSolvablePermutationGroups(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("IteratorPrimitiveSolvablePermutationGroups");


###########################################################################
##
#F  AllPrimitiveSolvablePermutationGroups(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("AllPrimitiveSolvablePermutationGroups");


###########################################################################
##
#F  OnePrimitiveSolvablePermutationGroup(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("OnePrimitiveSolvablePermutationGroup");



###########################################################################
##
#F  IdPrimitiveSolvableGroup(<grp>)
#F  IdPrimitiveSolvableGroupNC(<grp>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("IdPrimitiveSolvableGroup");
DeclareGlobalFunction ("IdPrimitiveSolvableGroupNC");


############################################################################
##
#E
##
