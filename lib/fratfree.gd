#############################################################################
##
#W  frattfree.gd                GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.fratfree_gd :=
    "@(#)$Id$:";

#############################################################################
##
#I Info
##
DeclareInfoClass( "InfoFFConst" );

#############################################################################
##
#A Projections
##
DeclareAttribute( "Projections", IsGroup );

DeclareGlobalFunction("RunSubdirectProductInfo");
DeclareGlobalFunction("IsConjugateMatGroup");
DeclareGlobalFunction("IsFaithfulModule");
DeclareGlobalFunction("IrreducibleSubgroupsOfGL");
DeclareGlobalFunction("SemiSimpleGroups");
DeclareGlobalFunction("Uncollected");
DeclareGlobalFunction("SocleComplementAbelianSocle");
DeclareGlobalFunction("NonInnerGroups");
DeclareGlobalFunction("FittingFreeGroupsBySocleAndSize");
#T DeclareGlobalFunction("MySplitExtensionSolvable");
#T up to now no function is installed
#T DeclareGlobalFunction("MySplitExtensionNonSolvable");
#T up to now no function is installed
#T DeclareGlobalFunction("FrattiniFreeGroups");
#T up to now no function is installed
#T DeclareGlobalFunction("FrattiniFreeSolvableGroupsBySize");
#T up to now no function is installed

