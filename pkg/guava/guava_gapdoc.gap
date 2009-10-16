############################################################
#
# commands to create GUAVA documentation using GAPDoc
#
###########################################################


##LogTo("/home/wdj/gapfiles/codes/guava1.99/guava_gapdoc.log");

path := Directory("/home/wdj/gapfiles/codes/guava2/doc");
main:="guava.xml"; 
files:=[];
bookname:="guava";
#str := ComposedXMLString(path, main, files);;
#r := ParseTreeXMLString(str);; 
######### with break here is there is an xml compiling error #########
#CheckAndCleanGapDocTree(r);
#l := GAPDoc2LaTeX(r);;
#FileString(Filename(path, Concatenation(bookname, ".tex")), l);
MakeGAPDocDoc( path, main, files, bookname);
