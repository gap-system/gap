#############################################################################
##
#W  grpreps.gd                  GAP library                      Bettina Eick
##
Revision.grpreps_gd :=
    "@(#)$Id:";

#############################################################################
##
#O  AbsolutIrreducibleModules( <G>, <F>, <dim> )
##
AbsolutIrreducibleModules := NewOperation( 
     "AbsolutIrreducibleModules",
     [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  IrreducibleModules( <G>, <F>, <dim> )
##
IrreducibleModules := NewOperation( 
     "IrreducibleModules",
     [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  RegularModule( <G>, <F> )
##
RegularModule := NewOperation( 
     "RegularModule",
     [ IsGroup, IsField ] );

#############################################################################
RegularModuleByGens := NewOperationArgs( "RegularModuleByGens" );
