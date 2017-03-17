##  This GAP program creates the documentation. 
##  It needs the GAPDoc package, latex, pdflatex, mkindex and dvips.
##  

LoadPackage("GAPDoc");

MakeGAPDocDoc(
# main file is in this directory
".", 
"dev", 
[
# list here with relative paths all files which contain source code
# for this manual, see 
#    gap> ?GAPDoc:Distributing a Document into Several Files
], 
# name of book
"Development", 
# relative path to main gap doc-directory
"../.."
);


CopyHTMLStyleFiles(".");

QUIT;

