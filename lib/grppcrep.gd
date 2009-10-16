#############################################################################
##
#W  grppcrep.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.grppcrep_gd :=
    "@(#)$Id: grppcrep.gd,v 4.5 2002/04/15 10:04:52 sal Exp $";

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

