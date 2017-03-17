##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##

GAPInfo.ManualDataHPC:= rec(
  pathtodoc:= ".",
  main:= "main.xml",
  bookname:= "hpc",
  pathtoroot:= "../..",

  files:= [
  ],
 );;


SetGapDocLaTeXOptions("nocolor", rec(Maintitlesize :=
"\\fontsize{36}{38}\\selectfont"));

MakeGAPDocDoc( GAPInfo.ManualDataHPC.pathtodoc,
               GAPInfo.ManualDataHPC.main,
               GAPInfo.ManualDataHPC.files,
               GAPInfo.ManualDataHPC.bookname,
               GAPInfo.ManualDataHPC.pathtoroot,
               "MathJax" );;
               
Exec ("mv -f manual.pdf manual-bw.pdf");

SetGapDocLaTeXOptions("color", rec(Maintitlesize :=
"\\fontsize{36}{38}\\selectfont"));

MakeGAPDocDoc( GAPInfo.ManualDataHPC.pathtodoc,
               GAPInfo.ManualDataHPC.main,
               GAPInfo.ManualDataHPC.files,
               GAPInfo.ManualDataHPC.bookname,
               GAPInfo.ManualDataHPC.pathtoroot,
               "MathJax" );;

GAPDocManualLabFromSixFile( "hpc", "manual.six" );;

CopyHTMLStyleFiles(".");


#############################################################################
##
#E

