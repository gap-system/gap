##  This GAP program creates the documentation.
##  It needs the GAPDoc package, latex, pdflatex, mkindex and dvips.
##

Read( "makedocreldata.g" );

MakeGAPDocDoc( GAPInfo.ManualDataDev.pathtodoc,
               GAPInfo.ManualDataDev.main,
               GAPInfo.ManualDataDev.files,
               GAPInfo.ManualDataDev.bookname,
               GAPInfo.ManualDataDev.pathtoroot,
               "MathJax" );

CopyHTMLStyleFiles(".");

#############################################################################
##
#E

