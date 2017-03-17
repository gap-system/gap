#############################################################################
##
#A  makedocrel.g                          GAPDoc                 Frank Lübeck
##  
##  
##  Rebuild the  whole documentation, provided sufficiently  good (pdf)LaTeX
##  is  available.   This  version  produces  relative   paths  to  external
##  documents, which is ok for the package in standard location.
##  

#SetInfoLevel(InfoGAPDoc,4);
#SetGapDocLaTeXOptions("pdf","color", "latin1"); 
relpath := "../../..";
# main
Print("\n========== converting main documentation for GAPDoc ==============\n");
maintree := MakeGAPDocDoc("doc", "gapdoc", ["../lib/BibTeX.gi", 
"../lib/BibTeX.gd", "../lib/BibXMLextTools.gi", "../lib/UnicodeTools.gi", 
"../lib/ComposeXML.gi", "../lib/GAPDoc2HTML.gi", "../lib/GAPDoc.gd",
"../lib/GAPDoc.gi", "../lib/GAPDoc2LaTeX.gi", "../lib/GAPDoc2Text.gi", 
"../lib/PrintUtil.gi", "../lib/Text.gi", "../lib/XMLParser.gi", 
"../lib/Examples.gi", "../lib/TextThemes.g", "../lib/HelpBookHandler.g",
"../lib/XMLParser.gd", "../lib/Make.g" ], "GAPDoc", relpath, "MathJax");

CopyHTMLStyleFiles("doc");

# now load it (for cross reference in example)
Print("\n========== converting example document for GAPDoc ================\n");
HELP_ADD_BOOK("GAPDoc", "Package for Preparing GAP Documentation",
                DirectoriesPackageLibrary("gapdoc","doc")[1]);

# example
exampletree := 
      MakeGAPDocDoc("example", "example", [], "GAPDocExample", relpath,
      "MathJax");
CopyHTMLStyleFiles("example");

# from first chapter
Print("\n========== converting small example from introduction ============\n");
3kp1tree := MakeGAPDocDoc("3k+1", "3k+1", [], "ThreeKPlusOne", relpath,
            "MathJax");
CopyHTMLStyleFiles("3k+1");

# .lab files for references from main manual
GAPDocManualLab("GAPDoc");

