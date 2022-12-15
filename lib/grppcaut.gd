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

DeclareGlobalFunction("SpaceAndOrbitStabilizer");

#############################################################################
##
#P IsFrattiniFree
##
DeclareProperty( "IsFrattiniFree", IsGroup );


DeclareGlobalFunction("AutomorphismGroupNilpotentGroup");
DeclareGlobalFunction("AutomorphismGroupSolvableGroup");
DeclareGlobalFunction("AutomorphismGroupFrattFreeGroup");

#############################################################################
##
#I InfoAutGrp
##
DeclareInfoClass( "InfoAutGrp" );
DeclareInfoClass( "InfoMatOrb" );
DeclareInfoClass( "InfoOverGr" );

if not IsBound( CHOP ) then CHOP := false; fi;

