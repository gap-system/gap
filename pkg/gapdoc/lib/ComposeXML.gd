#############################################################################
##
#W  ComposeXML.gi                GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: ComposeXML.gd,v 1.4 2007/02/20 16:56:27 gap Exp $
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

