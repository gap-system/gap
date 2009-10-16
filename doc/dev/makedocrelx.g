##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##  
##  $Id: makedocrelx.g,v 1.2 2006/05/08 17:43:46 gap Exp $
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
".."
# probably don't need the versions with MathML or tth-converted math formulae
##  , 
##  "MathML", 
##  "Tth"
);

# file for cross references from gapmacro.tex- manuals
# TODO: adjust to work for a main book
#     GAPDocManualLab("Development");

QUIT;

