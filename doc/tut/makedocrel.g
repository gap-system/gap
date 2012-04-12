##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##

Read( "makedocreldata.g" );

SetGapDocLaTeXOptions("nocolor");

MakeGAPDocDoc( GAPInfo.ManualDataTut.pathtodoc,
               GAPInfo.ManualDataTut.main,
               GAPInfo.ManualDataTut.files,
               GAPInfo.ManualDataTut.bookname,
               GAPInfo.ManualDataTut.pathtoroot,
               "MathJax" );;

Exec ("mv -f manual.pdf manual-bw.pdf");

SetGapDocLaTeXOptions("color");

MakeGAPDocDoc( GAPInfo.ManualDataTut.pathtodoc,
               GAPInfo.ManualDataTut.main,
               GAPInfo.ManualDataTut.files,
               GAPInfo.ManualDataTut.bookname,
               GAPInfo.ManualDataTut.pathtoroot,
               "MathJax" );;

GAPDocManualLabFromSixFile( "tut", "manual.six" );;

CopyHTMLStyleFiles(".");

#############################################################################
##
#E

