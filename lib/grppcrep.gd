#############################################################################
##
#W  grppcrep.gd                 GAP library                      Bettina Eick
##
Revision.grppcrep_gd :=
    "@(#)$Id$";

#############################################################################
##
#O  AbsolutIrreducibleModules( <G>, <F>, <dim> )
##
AbsolutIrreducibleModules := NewOperation( 
     "AbsolutIrreducibleModules",
     [ IsGroup and IsPcgsComputable, IsField and IsFinite, IsInt ] );

#############################################################################
##
#O  IrreducibleModules( <G>, <F>, <dim> )
##
IrreducibleModules := NewOperation( 
     "IrreducibleModules",
     [ IsGroup and IsPcgsComputable, IsField and IsFinite, IsInt ] );

#############################################################################
##
#O  RegularModule( <G>, <F> )
##
RegularModule := NewOperation( 
     "RegularModule",
     [ IsGroup and IsPcgsComputable, IsField ] );

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

