#############################################################################
##
#F  LieAlgDBBuildManual()
##

LieAlgDBBuildManual:=function()
        local path;

        path:=Concatenation(
               GAPInfo.PackagesInfo.("liealgdb")[1].InstallationPath,"/doc/");

        MakeGAPDocDoc(path, "manual", 
                [ "families.xml", "appsolv.xml", "appnonsolv.xml" ],
                "LieAlgDB" );  
end;



#############################################################################
##
#F  LieAlgDBBuildManualHTML()
##

LieAlgDBBuildManualHTML:=function()
        local path, str, r, h;

        path:=Concatenation(
               GAPInfo.PackagesInfo.("liealgdb")[1].InstallationPath,"/doc/");

  
        str:=ComposedXMLString( path, "manual.xml", [] );

        r := ParseTreeXMLString( str );
        CheckAndCleanGapDocTree( r );

        h := GAPDoc2HTML( r, path );
        GAPDoc2HTMLPrintHTMLFiles( h, path );
end;

