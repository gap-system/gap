##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##  
##  $Id: makedoc.g,v 1.1 2005/10/02 21:31:08 gap Exp $
##  
##  Call this with GAP.
##

RequirePackage("GAPDoc");

MakeGAPDocDoc("doc", "recog", [], "recog");

GAPDocManualLab("recog");

quit;

