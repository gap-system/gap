#############################################################################
##
#F  AlgAutBuildManual()
##

AlgAutBuildManual:=function()
        local path, main, files, bookname;

        path:=Concatenation(
               GAPInfo.PackagesInfo.("algaut")[1].InstallationPath,"/doc/");

        main:="manual";
        files:=["functions.xml"];
        bookname:="AlgAut";

        MakeGAPDocDoc(path, main, files, 
                bookname);  
end;



#############################################################################
##
#F  AlgAutBuildManualHTML()
##

LieAlgDBBuildManualHTML:=function()
        local path, main, files, str, r, h;

        path:=Concatenation(
               GAPInfo.PackagesInfo.("algaut")[1].InstallationPath,"/doc/");

        main:="manual";
        files:=["functions.xml"];
        str:=ComposedXMLString(path, main, files);

        r := ParseTreeXMLString( str );
        CheckAndCleanGapDocTree( r );

        h := GAPDoc2HTML( r, path );
        GAPDoc2HTMLPrintHTMLFiles( h, path );
end;

