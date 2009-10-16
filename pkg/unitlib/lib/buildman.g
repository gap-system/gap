#############################################################################
##  
#W  buildman.g             The UnitLib package            Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: buildman.g,v 1.2 2007/02/06 15:19:04 alexk Exp $
##
#############################################################################


#############################################################################
##
##  UNITLIBBuildManual()
##
UNITLIBBuildManual:=function()
local unitlib_path, unitlib_main, unitlib_files, unitlib_bookname;
unitlib_path:=Concatenation(
               GAPInfo.PackagesInfo.("unitlib")[1].InstallationPath,"/doc/");
unitlib_main:="manual.xml";
unitlib_files:=[];
unitlib_bookname:="UnitLib";
MakeGAPDocDoc(unitlib_path, unitlib_main, unitlib_files, unitlib_bookname);  
end;


#############################################################################
##
##  UNITLIBBuildManualHTML()
##
UNITLIBBuildManualHTML:=function()
local unitlib_path, unitlib_main, unitlib_files, str, r, h;
unitlib_path:=Concatenation(
               GAPInfo.PackagesInfo.("unitlib")[1].InstallationPath,"/doc/");
unitlib_main:="manual.xml";
unitlib_files:=[];
str:=ComposedXMLString(unitlib_path, unitlib_main, unitlib_files);
r:=ParseTreeXMLString(str);
CheckAndCleanGapDocTree(r);
h:=GAPDoc2HTML(r, unitlib_path);
GAPDoc2HTMLPrintHTMLFiles(h, unitlib_path);
end;


#############################################################################
##
#E
##