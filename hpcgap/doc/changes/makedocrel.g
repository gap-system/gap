##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##

Read( "makedocreldata.g" );

SetGapDocLaTeXOptions("nocolor", rec(Maintitlesize :=
"\\fontsize{36}{38}\\selectfont"));

MakeGAPDocDoc( GAPInfo.ManualDataChanges.pathtodoc,
               GAPInfo.ManualDataChanges.main,
               GAPInfo.ManualDataChanges.files,
               GAPInfo.ManualDataChanges.bookname,
               GAPInfo.ManualDataChanges.pathtoroot,
               "MathJax" );;
               
Exec ("mv -f manual.pdf manual-bw.pdf");

SetGapDocLaTeXOptions("color", rec(Maintitlesize :=
"\\fontsize{36}{38}\\selectfont"));

MakeGAPDocDoc( GAPInfo.ManualDataChanges.pathtodoc,
               GAPInfo.ManualDataChanges.main,
               GAPInfo.ManualDataChanges.files,
               GAPInfo.ManualDataChanges.bookname,
               GAPInfo.ManualDataChanges.pathtoroot,
               "MathJax" );;

GAPDocManualLabFromSixFile( "changes", "manual.six" );;

CopyHTMLStyleFiles(".");

QUIT;

#############################################################################
##
#E

