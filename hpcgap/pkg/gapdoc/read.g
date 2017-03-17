#############################################################################
##
#A  read.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

ReadPackage("GAPDoc", "lib/UnicodeTools.gi");
ReadPackage("GAPDoc", "lib/PrintUtil.gi");
ReadPackage("GAPDoc", "lib/Text.gi");
ReadPackage("GAPDoc", "lib/ComposeXML.gi");
ReadPackage("GAPDoc", "lib/XMLParser.gi");
ReadPackage("GAPDoc", "lib/gapdocdtdinfo.g");
ReadPackage("GAPDoc", "lib/GAPDoc.gi");
ReadPackage("GAPDoc", "lib/BibTeX.gi");
ReadPackage("GAPDoc", "lib/bibxmlextinfo.g");
ReadPackage("GAPDoc", "lib/BibXMLextTools.gi");
ReadPackage("GAPDoc", "lib/GAPDoc2LaTeX.gi");
ReadPackage("GAPDoc", "lib/GAPDoc2Text.gi");
ReadPackage("GAPDoc", "lib/TextThemes.g");
ReadPackage("GAPDoc", "lib/GAPDoc2HTML.gi");
ReadPackage("GAPDoc", "lib/Examples.gi");

# Finally the handler functions for GAP's help system:
ReadPackage("GAPDoc", "lib/HelpBookHandler.g");
