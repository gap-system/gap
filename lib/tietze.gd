#############################################################################
##
#W  tietze.gd                  GAP library                     Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.tietze_gd :=
    "@(#)$Id$";


#############################################################################
##
##  Some global symbolic constants.
##

TZ_NUMGENS      :=  1;
TZ_NUMRELS      :=  2;
TZ_TOTAL        :=  3;
TZ_GENERATORS   :=  4;
TZ_INVERSES     :=  5;
TZ_RELATORS     :=  6;
TZ_LENGTHS      :=  7;
TZ_FLAGS        :=  8;
TZ_MODIFIED     := 10;
TZ_NUMREDUNDS   := 11;
TZ_STATUS       := 15;
TZ_LENGTHTIETZE := 20;

TZ_FREEGENS     :=  9;
# TZ_ITERATOR     := 12;

TR_TREELENGTH   :=  3;
TR_PRIMARY      :=  4;
TR_TREENUMS     :=  5;
TR_TREEPOINTERS :=  6;
TR_TREELAST     :=  7;


#############################################################################
##
##  Some global variables.
##

PresentationOps := rec();
TzRecordOps     := rec();

PrintRecIndent  := "  ";

TzOptionNames := [ "eliminationsLimit", "expandLimit", "generatorsLimit",
    "lengthLimit", "loopLimit", "printLevel", "saveLimit",
    "searchSimultaneous" ];


#############################################################################
##
#A  TietzeOrigin( <G> )
##
TietzeOrigin := NewAttribute( "TietzeOrigin", IsSubgroupFpGroup );
SetTietzeOrigin := Setter( TietzeOrigin );
HasTietzeOrigin := Tester( TietzeOrigin );


############################################################################
##
#F  AbstractWordTietzeWord
##
AbstractWordTietzeWord := NewOperationArgs("AbstractWordTietzeWord");


############################################################################
##
#F  AddGenerator
##
AddGenerator := NewOperationArgs("AddGenerator");


############################################################################
##
#F  AddRelator
##
AddRelator := NewOperationArgs("AddRelator");


############################################################################
##
#F  DecodeTree
##
DecodeTree := NewOperationArgs("DecodeTree");


############################################################################
##
#F  FpGroupPresentation
##
FpGroupPresentation := NewOperationArgs("FpGroupPresentation");


############################################################################
##
#F  PresentationFpGroup
##
PresentationFpGroup := NewOperationArgs("PresentationFpGroup");


############################################################################
##
#F  PresentationViaCosetTable
##
PresentationViaCosetTable := NewOperationArgs("PresentationViaCosetTable");


############################################################################
##
#F  RelsViaCosetTable
##
RelsViaCosetTable := NewOperationArgs("RelsViaCosetTable");


############################################################################
##
#F  RemoveRelator
##
RemoveRelator := NewOperationArgs("RemoveRelator");


############################################################################
##
#F  SimplifiedFpGroup
##
SimplifiedFpGroup := NewOperationArgs("SimplifiedFpGroup");


############################################################################
##
#F  TietzeWordAbstractWord
##
TietzeWordAbstractWord := NewOperationArgs("TietzeWordAbstractWord");


############################################################################
##
#F  TzCheckRecord
##
TzCheckRecord := NewOperationArgs("TzCheckRecord");


############################################################################
##
#F  TzEliminate
##
TzEliminate := NewOperationArgs("TzEliminate");


############################################################################
##
#F  TzEliminateFromTree
##
TzEliminateFromTree := NewOperationArgs("TzEliminateFromTree");


############################################################################
##
#F  TzEliminateGen
##
TzEliminateGen := NewOperationArgs("TzEliminateGen");


############################################################################
##
#F  TzEliminateGen1
##
TzEliminateGen1 := NewOperationArgs("TzEliminateGen1");


############################################################################
##
#F  TzEliminateGens
##
TzEliminateGens := NewOperationArgs("TzEliminateGens");


############################################################################
##
#F  TzFindCyclicJoins
##
TzFindCyclicJoins := NewOperationArgs("TzFindCyclicJoins");


############################################################################
##
#F  TzGeneratorExponents
##
TzGeneratorExponents := NewOperationArgs("TzGeneratorExponents");


############################################################################
##
#F  TzGo
##
TzGo := NewOperationArgs("TzGo");


############################################################################
##
#F  TzGoGo
##
TzGoGo := NewOperationArgs("TzGoGo");


############################################################################
##
#F  TzHandleLength1Or2Relators
##
TzHandleLength1Or2Relators :=
    NewOperationArgs("TzHandleLength1Or2Relators");


############################################################################
##
#F  TzInitGeneratorImages
##
TzInitGeneratorImages := NewOperationArgs("TzInitGeneratorImages");


############################################################################
##
#F  TzMostFrequentPairs
##
TzMostFrequentPairs := NewOperationArgs("TzMostFrequentPairs");


############################################################################
##
#F  TzNewGenerator
##
TzNewGenerator := NewOperationArgs("TzNewGenerator");


############################################################################
##
#F  TzPrint
##
TzPrint := NewOperationArgs("TzPrint");


############################################################################
##
#F  TzPrintGeneratorImages
##
TzPrintGeneratorImages := NewOperationArgs("TzPrintGeneratorImages");


############################################################################
##
#F  TzPrintGenerators
##
TzPrintGenerators := NewOperationArgs("TzPrintGenerators");


############################################################################
##
#F  TzPrintLengths
##
TzPrintLengths := NewOperationArgs("TzPrintLengths");


############################################################################
##
#F  TzPrintOptions
##
TzPrintOptions := NewOperationArgs("TzPrintOptions");


############################################################################
##
#F  TzPrintPairs
##
TzPrintPairs := NewOperationArgs("TzPrintPairs");


############################################################################
##
#F  TzPrintPresentation
##
TzPrintPresentation := NewOperationArgs("TzPrintPresentation");


############################################################################
##
#F  TzPrintRelators
##
TzPrintRelators := NewOperationArgs("TzPrintRelators");


############################################################################
##
#F  TzPrintStatus
##
TzPrintStatus := NewOperationArgs("TzPrintStatus");


############################################################################
##
#F  TzRecoverFromFile
##
TzRecoverFromFile := NewOperationArgs("TzRecoverFromFile");


############################################################################
##
#F  TzRelator
##
TzRelator := NewOperationArgs("TzRelator");


############################################################################
##
#F  TzRemoveGenerators
##
TzRemoveGenerators := NewOperationArgs("TzRemoveGenerators");


############################################################################
##
#F  TzSearch
##
TzSearch := NewOperationArgs("TzSearch");


############################################################################
##
#F  TzSearchEqual
##
TzSearchEqual := NewOperationArgs("TzSearchEqual");


############################################################################
##
#F  TzSort
##
TzSort := NewOperationArgs("TzSort");


############################################################################
##
#F  TzSubstitute
##
TzSubstitute := NewOperationArgs("TzSubstitute");


############################################################################
##
#F  TzSubstituteCyclicJoins
##
TzSubstituteCyclicJoins := NewOperationArgs("TzSubstituteCyclicJoins");


############################################################################
##
#F  TzSubstituteWord
##
TzSubstituteWord := NewOperationArgs("TzSubstituteWord");


############################################################################
##
#F  TzUpdateGeneratorImages
##
TzUpdateGeneratorImages := NewOperationArgs("TzUpdateGeneratorImages");


#############################################################################
##
#E  tietze.gd  . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here


