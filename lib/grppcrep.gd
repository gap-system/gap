#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

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

