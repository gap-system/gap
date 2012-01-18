###########################################################################
##
#W    buildman.g             OpenMath Package           Alexander Konovalov
##                                                      
###########################################################################


ExtractManualExamples:=function( pkgname, main, files )
local path, tst, i, s, name, output;
path:=Directory( 
        Concatenation(PackageInfo(pkgname)[1].InstallationPath, "/doc") );
Print("===============================================================\n");
Print("Extracting manual examples for ", pkgname, " package\n" );
Print("===============================================================\n");
tst:=ManualExamples( path, main, files, "Chapter" );
for i in [ 1 .. Length(tst) ] do 
  Print( "Processing '", pkgname, 
         "' chapter number ", i, " of ", Length(tst), "\c" );
  if Length( tst[i] ) > 0 then
    s := String(i);
    if Length(s)=1 then 
      # works for <100 chapters
      s:=Concatenation("0",s); 
    fi;
    name := Filename( 
              Directory( 
                Concatenation( PackageInfo(pkgname)[1].InstallationPath, 
                               "/tst" ) ), 
                Concatenation( pkgname, s, ".tst" ) );
    output := OutputTextFile( name, false ); # to empty the file first
    SetPrintFormattingStatus( output, false ); # to avoid line breaks
    PrintTo( output, tst[i] );
    CloseStream(output);
    # one superfluous check
    if tst[i] <> StringFile( name ) then
      Error("Saved file does not match original examples string!!!\n");  
    else
      Print(" - OK! \n" );
    fi;
  else
    Print(" - no examples to save! \n" );    
  fi;  
od;
Print("===============================================================\n");
end;

###########################################################################

OPENMATHMANUALFILES:=[ 
"../PackageInfo.g", 
"../gap/omget.gd",
"../gap/omput.gd",
"../gap/test.gd" 
];

###########################################################################
##
##  OPENMATHBuildManual()
##
OPENMATHBuildManual:=function()
local mypath, path, main, files, f, bookname;
mypath := GAPInfo.PackagesInfo.("openmath")[1].InstallationPath;
path:=Concatenation( mypath, "/doc/");
main:="manual.xml";
bookname:="openmath";
MakeGAPDocDoc( path, main, OPENMATHMANUALFILES, bookname );  
CopyHTMLStyleFiles( path );
GAPDocManualLab( "openmath" );; 
ExtractManualExamples( "openmath", main, OPENMATHMANUALFILES);
end;


###########################################################################
##
##  OPENMATHBuildManualForGAP44()
##
OPENMATHBuildManualForGAP44:=function()
local mypath, path, main, files, f, bookname;
mypath := GAPInfo.PackagesInfo.("openmath")[1].InstallationPath;
path:=Concatenation( mypath, "/doc/");
main:="manual.xml";
bookname:="openmath";
MakeGAPDocDoc( path, main, OPENMATHMANUALFILES, bookname );  
GAPDocManualLab( "openmath" );; 
end;


###########################################################################
##
##  OPENMATHBuildManualHTML()
##
OPENMATHBuildManualHTML:=function()
local path, main, files, str, r, h;
path:=Concatenation(
        GAPInfo.PackagesInfo.("openmath")[1].InstallationPath, "/doc/");
main:="manual.xml";
str:=ComposedXMLString( path, main, OPENMATHMANUALFILES );
r:=ParseTreeXMLString( str );
CheckAndCleanGapDocTree( r );
h:=GAPDoc2HTML( r, path );
GAPDoc2HTMLPrintHTMLFiles( h, path );
end;

###########################################################################

OPENMATHBuildManual();

###########################################################################
##
#E
##