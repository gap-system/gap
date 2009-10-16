#############################################################################
##
#W  GAPDoc.gd                    GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: GAPDoc.gd,v 1.6 2007/09/25 09:30:35 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files GAPDoc.g{d,i} contain some utilities for trees returned by
##  ParseTreeXMLString applied to a GAPDoc document.
##  

DeclareGlobalFunction("CheckAndCleanGapDocTree");
DeclareGlobalFunction("AddParagraphNumbersGapDocTree");
DeclareGlobalFunction("AddPageNumbersToSix");
DeclareGlobalFunction("PrintSixFile");
DeclareGlobalFunction("PrintGAPDocElementTemplates");
DeclareGlobalFunction("TextM");

##  <#GAPDoc Label="InfoGAPDoc">
##  <ManSection >
##  <InfoClass Name="InfoGAPDoc" />
##  <Description>
##  The default level of this info class is 1. The converter functions
##  for &GAPDoc; documents are then 
##  printing some information. You can suppress this by setting the 
##  level of <Ref InfoClass="InfoGAPDoc"/> to 0. With level 2 there
##  may be some more information for debugging purposes.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# Info class with default level 1
BindGlobal("InfoGAPDoc", NewInfoClass("InfoGAPDoc"));
SetInfoLevel(InfoGAPDoc, 1);
if CompareVersionNumbers(GAPInfo.Version, "4.dev") then
  SetInfoHandler(InfoGAPDoc, function(cl, lev, l)
    CallFuncList(Print, l);
  end);
fi;

##  <#GAPDoc Label="GAPDocLanguage">
##  <ManSection >
##  <Heading>Using &GAPDoc; with other languages</Heading>
##  <Var Name="GAPDocTexts" />
##  <Func Name="SetGAPDocLanguage" Arg="[lang]" />
##  <Returns>Nothing.</Returns>
##  <Description>
##  The converter functions produce some language dependend text, for example 
##  headings like <C>"Abstract"</C>, <C>"References"</C> or navigation links
##  like <C>"Next Chapter"</C>. The default strings are stored in the record
##  <C>GAPDocTexts.english</C>. To use &GAPDoc; with another language
##  <A>lang</A> provide a translation <C>GAPDocTexts.(<A>lang</A>)</C> (in 
##  <C>UTF-8</C> encoding) and
##  set it with <Ref Func="SetGAPDocLanguage"/>. The default for <A>lang</A>
##  is <C>"english"</C>.<P/>
##  Furthermore, make sure that &LaTeX; supports your language, maybe use the
##  <C>babel</C> package, and for languages with non-latin1 characters use
##  the "utf8" option, see <Ref Func="GAPDoc2LaTeX"/> and <Ref
##  Func="SetGapDocLaTeXOptions"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalVariable("GAPDocTexts");
DeclareGlobalFunction("SetGapDocLanguage");
