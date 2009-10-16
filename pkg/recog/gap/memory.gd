#############################################################################
##
##  memory.gd          recog package                      Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Group objects remembering how they were created from the generators.
##
##  $Id: memory.gd,v 1.4 2005/10/11 15:19:33 gap Exp $
##
#############################################################################


DeclareFilter("IsObjWithMemoryRankFilter",100); 

DeclareRepresentation("IsObjWithMemory", 
    IsComponentObjectRep and IsObjWithMemoryRankFilter and
    IsMultiplicativeElementWithInverse, ["slp","n","el"]);

DeclareAttribute("TypeOfObjWithMemory",IsFamily);

DeclareGlobalFunction( "GeneratorsWithMemory" );
DeclareGlobalFunction( "StripMemory" );
DeclareGlobalFunction( "StripStabChain" );
DeclareGlobalFunction( "CopyMemory" );
DeclareGlobalFunction( "GroupWithMemory" );
DeclareGlobalFunction( "SLPOfElm" );
DeclareGlobalFunction( "SLPOfElms" );

DeclareGlobalFunction( "SortFunctionWithMemory" );

