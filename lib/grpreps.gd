#############################################################################
##
#W  grpreps.gd                  GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grpreps_gd :=
    "@(#)$Id$";

#############################################################################
##
#O  AbsolutIrreducibleModules( <G>, <F>, <dim> )
##
DeclareOperation( 
     "AbsolutIrreducibleModules",
     [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  IrreducibleModules( <G>, <F>, <dim> )
##
DeclareOperation( 
     "IrreducibleModules",
     [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  RegularModule( <G>, <F> )
##
DeclareOperation( 
     "RegularModule",
     [ IsGroup, IsField ] );

#############################################################################
DeclareGlobalFunction( "RegularModuleByGens" );
