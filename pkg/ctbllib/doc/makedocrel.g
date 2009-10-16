##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##
LoadPackage("GAPDoc");

pathtodoc:= ".";;
main:= "main.xml";;
bookname:= "CTblLib";;
pathtoroot:= "../../..";;

files:= [
    "../gap4/construc.gd",
    "../gap4/ctadmin.tbd",
    "../gap4/ctblothe.gd",
    "../tst/testinst.g",
    "../dlnames/dlnames.gd",
  ];;

AddHandlerBuildRecBibXMLEntry( "Wrap:Package", "BibTeX",
  function( entry, r, restype, strings, options )
    return Concatenation( "\\textsf{", ContentBuildRecBibXMLEntry(
               entry, r, restype, strings, options ), "}" );
  end );

AddHandlerBuildRecBibXMLEntry( "Wrap:Package", "HTML",
  function( entry, r, restype, strings, options )
    return Concatenation( "<strong class='pkg'>", ContentBuildRecBibXMLEntry(
               entry, r, restype, strings, options ), "</strong>" );
  end );

tree:= MakeGAPDocDoc( pathtodoc, main, files, bookname, pathtoroot );;

GAPDocManualLab( "CTblLib" );;

