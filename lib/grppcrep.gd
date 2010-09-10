#############################################################################
##
#W  grppcrep.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.grppcrep_gd :=
    "@(#)$Id: grppcrep.gd,v 4.6 2010/02/23 15:13:07 gap Exp $";

#############################################################################
## some module stuff
DeclareGlobalFunction( "BlownUpModule" );
DeclareGlobalFunction( "ConjugatedModule" );
DeclareGlobalFunction( "GaloisConjugates" );
DeclareGlobalFunction( "TrivialModule" );
DeclareGlobalFunction( "InducedModule" );
DeclareGlobalFunction( "InducedModuleByFieldReduction");
DeclareGlobalFunction( "ExtensionsOfModule" );

#############################################################################
## equivalence test
DeclareGlobalFunction( "FpOfModules" );
DeclareGlobalFunction( "EquivalenceType" );
DeclareGlobalFunction( "IsEquivalentByFp" );

#############################################################################
## computation of abs/irred modules
DeclareGlobalFunction( "InitAbsAndIrredModules" );
DeclareGlobalFunction( "LiftAbsAndIrredModules" );
DeclareGlobalFunction( "AbsAndIrredModules" );

