#############################################################################
##
##  memory.gd          recog package                      Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Group objects remembering how they were created from the generators.
##
#############################################################################

Revision.memory_gd :=
  "@(#)$Id: memory.gd,v 1.2 2006/08/19 13:06:26 gap Exp $";

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

