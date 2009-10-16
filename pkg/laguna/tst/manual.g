#############################################################################
##  
#W  manual.g                 The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  $Id: manual.g,v 1.2 2006/07/11 10:34:00 alexk Exp $
##
#############################################################################
#
# This file contains a function LAGUNATestManual() that tests all examples
# from xml-files of package documentation, and prints differences in the form
# (for example)
# + (Z(2)^0)*(2,3)+(Z(2)^0)*(1,2)+(Z(2)^0)*(1,2,3)+(Z(2)^0)*(1,3)
# - (Z(2)^0)*(1,2,3)+(Z(2)^0)*(1,3,2)+(Z(2)^0)*(1,3)
# where "+" denotes actual output and "-" denotes the output in the manual.
#
# This file is a developer tool, and it will not be included in the official
# LAGUNA release. Also, it uses the file "lib/Examples.g" from the GAPDoc
# development version. So, to test Wedderga under the GAP4 release, you must
# copy these two files in appropriate places in the release branch.
#
# The final message in the form
# + GAP4stones: 0
# - GAP4stones: fail
# should be ingnored.

ReadPackage("GAPDoc","lib/Examples.g");
SizeScreen( [ 80 , ] );

#############################################################################
##
##  LAGUNATestManual()
##
LAGUNATestManual:=function()
local path, TstPkgExamples; 

TstPkgExamples := function ( path, main, files )
  local  str, r, examples, temp_dir, file, otf;
 
  str := ComposedXMLString( path, 
                            Concatenation( main, ".xml" ), 
			    files );
  r := ParseTreeXMLString( str );
  
  examples := Concatenation( 
    "gap> START_TEST( \"Test by GapDoc\" );\n",
    TstExamples( r ),
    "\ngap> STOP_TEST( \"test\", 10000 );\n",
    "Test by GapDoc\nGAP4stones: fail\n" );
  
  temp_dir := DirectoryTemporary( "gapdoc" );
  file := Filename( temp_dir, "testfile" );
  otf := OutputTextFile( file, true );
  SetPrintFormattingStatus( otf, false );
  AppendTo( otf, examples );
  CloseStream( otf );
  
  ReadTest( file );
  
  RemoveFile( file );
  RemoveFile( temp_dir![1] );
  end;

SetInfoLevel( LAGInfo, 1 );
SizeScreen( [ 80 , ] ); 
path:=DirectoriesPackageLibrary("laguna","doc");   
Info(LAGInfo, 1, "Test of ", path );
TstPkgExamples(path,"manual",[ ] );
SetInfoLevel( LAGInfo, 1 );       
end;


#############################################################################
##
#E
##