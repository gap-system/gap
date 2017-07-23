#############################################################################
##
#W  UnicodeTools.gd                GAPDoc                     Frank Lübeck
##
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files UnicodeTools.g{d,i} contain utilities for converting text
##  between different encodings. They introduce unicode strings and
##  characters as GAP objects.
##  

# for some recode information and functions for the ISO-8859 character sets
BindGlobal("UNICODE_RECODE", rec());
# more a hack, some unicode characters can be translated to LaTeX with
# this table: this is a set of pairs [ codepoint, LaTeX text ]
DeclareGlobalVariable("LaTeXUnicodeTable");
# similar for simplification to ASCII
DeclareGlobalVariable("SimplifiedUnicodeTable");
# and for translation to lower case
DeclareGlobalVariable("LowercaseUnicodeTable");
# width of unicode characters on terminal
DeclareGlobalVariable("WidthUnicodeTable");

##  declarations of unicode characters and strings as GAP objects
DeclareFilter("IsUnicodeString", IsString and IsHomogeneousList and
                                 IsConstantTimeAccessList);
DeclareFilter("IsUnicodeCharacter", IsInt and IsChar);
BindGlobal("UnicodeStringType", 
              NewType(NewFamily("dummy"), IsPositionalObjectRep and
                                          IsUnicodeString and IsMutable));
BindGlobal("UnicodeCharacterType", 
              NewType(NewFamily("dummy"), IsComponentObjectRep and
                                          IsUnicodeCharacter));
BindGlobal("UNICODECHARCACHE", []);

DeclareOperation("UChar", [IsObject]);
DeclareOperation("UChar", [IsObject, IsObject]);

# create unicode strings, from lists of integers or GAP strings,
# optionally with encoding (default UTF-8)
DeclareOperation("Unicode", [IsObject]);
DeclareOperation("Unicode", [IsObject, IsObject]);
DeclareGlobalFunction("IntListUnicodeString");
UNICODE_RECODE.Decoder := rec();

######  Encoding #########
DeclareOperation("Encode", [IsUnicodeString]);
DeclareOperation("Encode", [IsUnicodeString, IsString]);
UNICODE_RECODE.Encoder := rec();
DeclareGlobalFunction("SimplifiedUnicodeString");
DeclareGlobalFunction("LowercaseUnicodeString");
DeclareGlobalFunction("UppercaseUnicodeString");

###### Utilities for different lengths of UTF-8 encoded GAP strings ########
DeclareGlobalFunction("NrCharsUTF8String");
DeclareGlobalFunction("WidthUTF8String");
DeclareGlobalFunction("InitialSubstringUTF8String");

###### Simplification for sorting and searching #####
DeclareGlobalFunction("LowerASCIIString");
