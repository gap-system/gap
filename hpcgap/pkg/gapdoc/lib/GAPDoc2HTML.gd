#############################################################################
##
#W  GAPDoc2HTML.gd                 GAPDoc                        Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2HTML.g{d,i}  contain  a  conversion program  which
##  produces from a  GAPDoc XML-document an HTML version for reading the
##  document with a Web-browser.
##  
 
DeclareGlobalVariable("GAPDoc2HTMLProcs");

DeclareGlobalFunction("GAPDoc2HTML");

DeclareGlobalFunction("GAPDoc2HTMLPrintHTMLFiles");

DeclareGlobalFunction("CopyHTMLStyleFiles");
