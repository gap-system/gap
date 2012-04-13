##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##

Read( "makedocreldata.g" );

SetGapDocLaTeXOptions("nocolor", rec(Maintitlesize :=
"\\fontsize{36}{38}\\selectfont"));

MakeGAPDocDoc( GAPInfo.ManualDataRef.pathtodoc,
               GAPInfo.ManualDataRef.main,
               GAPInfo.ManualDataRef.files,
               GAPInfo.ManualDataRef.bookname,
               GAPInfo.ManualDataRef.pathtoroot,
               "MathJax" );;
               
Exec ("mv -f manual.pdf manual-bw.pdf");

SetGapDocLaTeXOptions("color", rec(Maintitlesize :=
"\\fontsize{36}{38}\\selectfont"));

MakeGAPDocDoc( GAPInfo.ManualDataRef.pathtodoc,
               GAPInfo.ManualDataRef.main,
               GAPInfo.ManualDataRef.files,
               GAPInfo.ManualDataRef.bookname,
               GAPInfo.ManualDataRef.pathtoroot,
               "MathJax" );;

GAPDocManualLabFromSixFile( "ref", "manual.six" );;

CopyHTMLStyleFiles(".");


#############################################################################
##
#E

