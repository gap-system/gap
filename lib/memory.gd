#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Max Neunhöffer, Ákos Seress.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Group objects remembering how they were created from the generators.
##
#############################################################################


DeclareFilter("IsObjWithMemoryRankFilter",100);

DeclareRepresentation("IsObjWithMemory",
    IsComponentObjectRep and IsObjWithMemoryRankFilter and
    IsMultiplicativeElementWithInverse, ["slp","n","el"]);

DeclareAttribute("TypeOfObjWithMemory",IsFamily);

DeclareGlobalFunction( "GeneratorsWithMemory" );
DeclareOperation( "StripMemory", [IsObject] );
DeclareOperation( "ForgetMemory", [IsObject] );
DeclareGlobalFunction( "StripStabChain" );
DeclareGlobalFunction( "CopyMemory" );
DeclareGlobalFunction( "GroupWithMemory" );
DeclareGlobalFunction( "SLPOfElm" );
DeclareGlobalFunction( "SLPOfElms" );

DeclareGlobalFunction( "SortFunctionWithMemory" );

