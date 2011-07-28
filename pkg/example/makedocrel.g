##  This builds the documentation of the Example package
##  Needs: GAPDoc package, latex, pdflatex, mkindex
##  
LoadPackage( "GAPDoc" );

MakeGAPDocDoc( "doc", "main", [
               ], "Example", "../../.." );;

GAPDocManualLab( "Example" );;

