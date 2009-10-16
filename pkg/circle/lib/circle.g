#############################################################################
##
#W  circle.g                The CIRCLE package            Alexander Konovalov
##                                                          Panagiotis Soules
##
#H  $Id: circle.g,v 1.2 2007/02/06 15:19:04 alexk Exp $
##
##  This file contains service functions to build the documentation
##
#############################################################################


#############################################################################
##
##  CIRCLEBuildManual()
##
CIRCLEBuildManual:=function()
local circle_path, circle_main, circle_files, circle_bookname;
circle_path:=Concatenation(
               GAPInfo.PackagesInfo.("circle")[1].InstallationPath,"/doc/");
circle_main:="manual.xml";
circle_files:=[];
circle_bookname:="Circle";
MakeGAPDocDoc(circle_path, circle_main, circle_files, circle_bookname);  
end;


#############################################################################
##
##  CIRCLEBuildManualHTML()
##
CIRCLEBuildManualHTML:=function()
local circle_path, circle_main, circle_files, str, r, h;
circle_path:=Concatenation(
               GAPInfo.PackagesInfo.("circle")[1].InstallationPath,"/doc/");
circle_main:="manual.xml";
circle_files:=[];
str:=ComposedXMLString(circle_path, circle_main, circle_files);
r:=ParseTreeXMLString(str);
CheckAndCleanGapDocTree(r);
h:=GAPDoc2HTML(r, circle_path);
GAPDoc2HTMLPrintHTMLFiles(h, circle_path);
end;


#############################################################################
##
#E
##