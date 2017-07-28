#############################################################################
##
#W  ComposeXML.gi                GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
## The files ComposeXML.gi/.gd contain a function which allows to construct
## a GAPDoc-XML document from several source files.
##  

DeclareGlobalFunction("ComposedDocument");
# for compatibility
DeclareGlobalFunction("ComposedXMLString");
DeclareGlobalFunction("OriginalPositionDocument");

# helper function for paths of files
DeclareGlobalFunction("FilenameGAP");
