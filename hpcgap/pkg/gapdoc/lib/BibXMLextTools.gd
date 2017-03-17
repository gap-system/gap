#############################################################################
##
#W  BibXMLextTools.gd             GAPDoc                         Frank Lübeck
##
##
#Y  Copyright (C)  2006,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibXMLextTools.g{d,i} contain utility functions for dealing
##  with bibliography data in the BibXMLext format. The corresponding DTD
##  is in ../bibxmlext.dtd. 
##  

# these are utilities to help to translate BibTeX entries to BibXMLext entries
DeclareGlobalFunction("TemplateBibXML");
DeclareGlobalFunction("StringBibAsXMLext");
DeclareGlobalFunction("WriteBibXMLextFile");


# parsing BibXMLext strings and files
DeclareGlobalFunction("ParseBibXMLextString");
DeclareGlobalFunction("ParseBibXMLextFiles");

# tranforming parse trees to records and strings
BindGlobal("RECBIBXMLHNDLR", rec());
DeclareGlobalFunction("BuildRecBibXMLEntry");
DeclareGlobalFunction("ContentBuildRecBibXMLEntry");
DeclareGlobalFunction("AddHandlerBuildRecBibXMLEntry");
DeclareGlobalFunction("RecBibXMLEntry");
BindGlobal("STRINGBIBXMLHDLR", rec());
DeclareGlobalFunction("StringBibXMLEntry");

# utilities
DeclareGlobalFunction("SortKeyRecBib");
DeclareGlobalVariable("HeuristicTranslationsLaTeX2XML");

