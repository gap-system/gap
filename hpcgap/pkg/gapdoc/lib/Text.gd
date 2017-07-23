#############################################################################
##
#W  Text.gd                      GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files Text.g{d,i}  contain some utilities for  dealing with text
##  strings.
##  

##  some character lists
DeclareGlobalVariable("WHITESPACE");
DeclareGlobalVariable("CAPITALLETTERS");
DeclareGlobalVariable("SMALLLETTERS");
DeclareGlobalVariable("LETTERS");
DeclareGlobalVariable("HEXDIGITS");
DeclareGlobalVariable("DIGITS");
DeclareGlobalVariable("BOXCHARS");

##  record containing ANSI terminal text attributes
DeclareGlobalVariable("TextAttr");

##  some utility functions for strings
DeclareGlobalFunction("PositionLinenumber");
DeclareGlobalFunction("NumberOfLines");
DeclareGlobalFunction("RepeatedString");
DeclareGlobalFunction("RepeatedUTF8String");
DeclareGlobalFunction("PositionMatchingDelimiter");
DeclareGlobalFunction("SubstitutionSublist");
DeclareGlobalFunction("NumberDigits");
DeclareGlobalFunction("DigitsNumber");
DeclareGlobalFunction("LabelInt");
DeclareGlobalFunction("Base64String");
DeclareGlobalFunction("StringBase64");
DeclareGlobalFunction("StripBeginEnd");
DeclareGlobalFunction("WrapTextAttribute");
DeclareGlobalFunction("FormatParagraph");
DeclareGlobalFunction("StripEscapeSequences");
DeclareGlobalFunction("SubstituteEscapeSequences");
DeclareGlobalFunction("WordsString");
DeclareGlobalFunction("CrcText");
