#############################################################################
##
#W  grppcrep.gd                 GAP library                      Bettina Eick
##
Revision.grppcrep_gd :=
    "@(#)$Id$";

#############################################################################
## some module stuff
BlownUpModule := NewOperationArgs( "BlownUpModule" );
ConjugatedModule := NewOperationArgs( "ConjugatedModule" );
GaloisConjugates := NewOperationArgs( "GaloisConjugates" );
TrivialModule := NewOperationArgs( "TrivialModule" );
InducedModule := NewOperationArgs( "InducedModule" );
InducedModuleByFieldReduction 
              := NewOperationArgs( "InducedModuleByFieldReduction");
ExtensionsOfModule := NewOperationArgs( "ExtensionsOfModule" );

#############################################################################
## equivalence test
FpOfModules := NewOperationArgs( "FpOfModules" );
EquivalenceType := NewOperationArgs( "EquivalenceType" );
IsEquivalentByFp := NewOperationArgs( "IsEquivalentByFp" );

#############################################################################
## computation of abs/irred modules
InitAbsAndIrredModules := NewOperationArgs( "InitAbsAndIrredModules" );
LiftAbsAndIrredModules := NewOperationArgs( "LiftAbsAndIrredModules" );
AbsAndIrredModules := NewOperationArgs( "AbsAndIrredModules" );

