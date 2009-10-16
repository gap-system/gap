#############################################################################
##
#W  GAPDoc2Text.gd                 GAPDoc                        Frank Lübeck
##
#H  @(#)$Id: GAPDoc2Text.gd,v 1.2 2007/02/20 16:56:27 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2Text.g{d,i}  contain  a  conversion program  which
##  produces from a  GAPDoc XML-document a text version  for viewing the
##  document on screen (GAP online help).
##  

DeclareGlobalVariable("GAPDoc2TextProcs");

DeclareGlobalFunction("GAPDoc2Text");

DeclareGlobalFunction("GAPDoc2TextPrintTextFiles");

# Just use this variable, will be really assigned in the .gi file.
GAPDocTextTheme := 0;


