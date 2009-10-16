#############################################################################
##
#W buildman.g              The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
##
#H $Id: buildman.g,v 1.1 2007/04/27 20:08:38 alexk Exp $
##
##  This file contains service functions to build the documentation
##
#############################################################################


#############################################################################
##
##  CONGRUENCEBuildManual()
##
CONGRUENCEBuildManual:=function()
local cong_path, cong_main, cong_files, cong_bookname;
cong_path:=Concatenation(
               GAPInfo.PackagesInfo.("congruence")[1].InstallationPath,"/doc/");
cong_main:="manual.xml";
cong_files:=[];
cong_bookname:="Congruence";
MakeGAPDocDoc(cong_path, cong_main, cong_files, cong_bookname);  
end;


#############################################################################
##
##  CONGRUENCEBuildManualHTML()
##
CONGRUENCEBuildManualHTML:=function()
local cong_path, cong_main, cong_files, str, r, h;
cong_path:=Concatenation(
               GAPInfo.PackagesInfo.("congruence")[1].InstallationPath,"/doc/");
cong_main:="manual.xml";
cong_files:=[];
str:=ComposedXMLString(cong_path, cong_main, cong_files);
r:=ParseTreeXMLString(str);
CheckAndCleanGapDocTree(r);
h:=GAPDoc2HTML(r, cong_path);
GAPDoc2HTMLPrintHTMLFiles(h, cong_path);
end;


#############################################################################
##
#E
##