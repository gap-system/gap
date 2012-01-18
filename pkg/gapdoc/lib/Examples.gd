#############################################################################
##
#W  Examples.gd                  GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files Examples.g{d,i} contain functions for extracting and checking
##  GAP examples in GAPDoc manuals.
##  

# old, keep for compatibility
DeclareGlobalFunction("ManualExamplesXMLTree");
DeclareGlobalFunction("ManualExamples");
DeclareGlobalFunction("ReadTestExamplesString");
DeclareGlobalFunction("TestExamplesString");
DeclareGlobalFunction("TestManualExamples");

# new
DeclareGlobalFunction("ExtractExamplesXMLTree");
DeclareGlobalFunction("ExtractExamples");
DeclareGlobalFunction("RunExamples");

