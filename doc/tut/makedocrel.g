##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##
LoadPackage( "GAPDoc" );

Read( "makedocreldata.g" );

MakeGAPDocDoc( GAPInfo.ManualDataTut.pathtodoc,
               GAPInfo.ManualDataTut.main,
               GAPInfo.ManualDataTut.files,
               GAPInfo.ManualDataTut.bookname,
               GAPInfo.ManualDataTut.pathtoroot,
               "MathJax" );;

GAPDocManualLabFromSixFile( "tut", "manual.six" );;

Exec( "cp ../manual.css ." );


#############################################################################
##
#E

