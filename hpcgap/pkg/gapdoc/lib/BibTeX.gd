#############################################################################
##
#W  BibTeX.gi                    GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibTeX.g{d,i} contain a parser for BibTeX files and some
##  functions for printing BibTeX entries in different formats.
##  

DeclareGlobalFunction("ParseBibStrings");
DeclareGlobalFunction("ParseBibFiles");
DeclareGlobalFunction("NormalizedNameAndKey");
DeclareGlobalFunction("NormalizeNameAndKey");
DeclareGlobalFunction("WriteBibFile");
DeclareGlobalFunction("StringBibAsBib");
DeclareGlobalFunction("PrintBibAsBib");
DeclareGlobalFunction("StringBibAsText");
DeclareGlobalFunction("PrintBibAsText");
DeclareGlobalFunction("StringBibAsHTML");
DeclareGlobalFunction("PrintBibAsHTML");
DeclareGlobalFunction("SearchMR");
DeclareGlobalFunction("SearchMRBib");
DeclareGlobalFunction("LabelsFromBibTeX");


##  <#GAPDoc Label="InfoBibTools">
##  <ManSection >
##  <InfoClass Name="InfoBibTools" />
##  <Description>
##  The default level of this info class is 1. Functions like <Ref
##  Func="ParseBibFiles"/>, <C>StringBibAs...</C> are then 
##  printing some information. You can suppress it by setting the 
##  level of <Ref InfoClass="InfoBibTools"/> to 0. With level 2 there
##  may be some more information for debugging purposes.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# Info class with default level 1
BindGlobal("InfoBibTools", NewInfoClass("InfoBibTools"));
SetInfoLevel(InfoBibTools, 1);
if CompareVersionNumbers(GAPInfo.Version, "4.dev") then
  SetInfoHandler(InfoBibTools, PlainInfoHandler);
fi;
