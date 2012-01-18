##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##
LoadPackage( "GAPDoc" );
SetInfoLevel( InfoGAPDoc, 2 );

# Make cross-references work.
LoadPackage( "ctbllib" );
LoadPackage( "Browse" );

SetGapDocLaTeXOptions( "nocolor", "utf8",
      rec( Maintitlesize := "\\fontsize{50}{55}\\selectfont" ) );
#T change the numbers!

pathtodoc:= ".";
main:= "main.xml";
bookname:= "AtlasRep";
pathtoroot:= "../../..";

files:= [
    "../gap/access.gd",
    "../gap/access.gi",
    "../gap/atlasprm.g",
    "../gap/bbox.gd",
    "../gap/brmindeg.g",
    "../gap/brspor.g",
    "../gap/interfac.gd",
    "../gap/mindeg.gd",
    "../gap/scanmtx.gd",
    "../gap/test.g",
    "../tst/testinst.g",
    "../gap/types.g",
    "../gap/types.gd",
    "../gap/utils.gd",
  ];

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

pathtotst:= "../tst";
tstfilename:= "docxpl.tst";
pkgname:= "AtlasRep";
authors:= [ "Thomas Breuer" ];
copyrightyear:= "2001";
tstheadertext:= "\
This file contains the GAP code of the examples in the package\n\
documentation files.\n\
\n\
In order to run the tests, one starts GAP from the `tst' subdirectory\n\
of the `pkg/atlasrep' directory, and calls `ReadTest( \"docxpl.tst\" );'.\n\
";


tree:= MakeGAPDocDoc( pathtodoc, main, files, bookname, pathtoroot );;
CopyHTMLStyleFiles( pathtodoc );

if IsBound( GAPDocManualLabFromSixFile ) then
  GAPDocManualLabFromSixFile( "AtlasRep", "./manual.six" );
else
  # Do not use GAPDocManualLab, it will read the `manual.six' file
  # of the installed package version, which may be the wrong one.
  Print( "#E  GAPDocManualLabFromSixFile is not available\n" );
fi;

##################################

ExampleFileHeader:= function( filename, pkgname, authors, copyrightyear,
                              text, linelen )
    local free1, free2, str, i;

    free1:= Int( ( linelen - Length( pkgname ) - 14 ) / 2 );
    free2:= linelen - free1 - 14 - Length( pkgname ) - Length( authors[1] );

    str:= RepeatedString( "#", linelen );
    Append( str, "\n##\n#W  " );
    Append( str, filename );
    Append( str, RepeatedString( " ", free1 - Length( filename ) - 4 ) );
    Append( str, "GAP 4 package " );
    Append( str, pkgname );
    Append( str, RepeatedString( " ", free2 ) );
    Append( str, authors[1] );
    for i in [ 2 .. Length( authors ) ] do
      Append( str, "\n#W" );
      Append( str, RepeatedString( " ", linelen - Length( authors[i] ) - 4 ) );
      Append( str, authors[i] );
    od;
    Append( str, "\n##\n#Y  Copyright (C)  " );
    Append( str, String( copyrightyear ) );
    Append( str, ",  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany" );
    Append( str, "\n##\n##  " );
    Append( str, ReplacedString( text, "\n", "\n##  " ) );
    Append( str, "\n\ngap> START_TEST( \"Input file: " );
    Append( str, filename );
    Append( str, "\" );\n\n" );

    return str;
end;

ExampleFileFooter:= function( filename, linelen )
    local str;

    str:= "\n\ngap> STOP_TEST( \"";
    Append( str, filename );
    Append( str, "\", 10000000 );\n\n\n" );
    Append( str, RepeatedString( "#", linelen ) );
    Append( str, "\n##\n#E\n\n" );

    return str;
end;


# create the test file with manual examples
# (for a package: combined for all chapters)
CreateManualExamplesFile:= function( pkgname, authors, copyrightyear, text,
                                     path, main, files, tstpath, tstfilename )
    local linelen, str, r, tstfilenameold;

    linelen:= 77;
    str:= "# This file was created automatically, do not edit!\n";
    Append( str, ExampleFileHeader( tstfilename, pkgname, authors,
                                    copyrightyear, text, linelen ) );
    for r in ManualExamples( path, main, files, "Chapter" ) do
      Append( str, r );
    od;
    Append( str, ExampleFileFooter( tstfilename, linelen ) );

    tstfilename:= Concatenation( tstpath, "/", tstfilename );
    tstfilenameold:= Concatenation( tstfilename, "~" );
    if IsExistingFile( tstfilename ) then
      Exec( Concatenation( "rm -f ", tstfilenameold ) );
      Exec( Concatenation( "mv ", tstfilename, " ", tstfilenameold ) );
    fi;
    FileString( tstfilename, str );
    if IsExistingFile( tstfilenameold ) then
      Print( "#I  differences in `", tstfilename, "':\n" );
      Exec( Concatenation( "diff ", tstfilenameold, " ", tstfilename ) );
    fi;
    Exec( Concatenation( "chmod 444 ", tstfilename ) );
end;


CreateManualExamplesFile( pkgname, authors, copyrightyear, tstheadertext,
                          pathtodoc, main, files, pathtotst, tstfilename );

