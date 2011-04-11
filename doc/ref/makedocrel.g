##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##
LoadPackage( "GAPDoc" );

LoadPackage( "ctbllib" );
LoadPackage( "Browse" );

Read( "makedocreldata.g" );

MakeGAPDocDoc( GAPInfo.ManualDataRef.pathtodoc,
               GAPInfo.ManualDataRef.main,
               GAPInfo.ManualDataRef.files,
               GAPInfo.ManualDataRef.bookname,
               GAPInfo.ManualDataRef.pathtoroot,
               "MathJax" );;

GAPDocManualLabFromSixFile( "ref", "manual.six" );;

Exec( "cp ../manual.css ." );


#############################################################################
##
#E

