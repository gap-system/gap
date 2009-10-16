##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##  
LoadPackage( "GAPDoc" );

MakeGAPDocDoc( "doc", "main", [
               ], "Example", "../../.." );;

GAPDocManualLab( "Example" );;

