#############################################################################
##
#W  bibutils.g           GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: bibutils.g,v 1.1 2008/06/16 17:30:41 gap Exp $
##
#Y  Copyright (C)  2008,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some utilities for creating HTML bibliographies from
##  BibXMLext format bibliographies.
##
Revision.( "atlasrep/bibl/bibutils_g" ) :=
    "@(#)$Id: bibutils.g,v 1.1 2008/06/16 17:30:41 gap Exp $";


#############################################################################
##
#F  CheckBibFiles( <srcfiles>, <ignorefields> )
##
##  <srcfiles> must be a list of BibXMLext files.
##
##  The following properties are checked:
##  - Does each entry of the type "incollection" or "inproceedings" have
##    a "crossref" field?  (It may be missing.)
##  - Does each "crossref" entry point to an existing entry?
##  - Are the "Label" values unique in the sense that duplicates
##    are essentially equal?
##    (The entries may differ in the fields in the list <ignorefields>.)
##
BindGlobal( "CheckBibFiles", function( srcfiles, ignorefields )
    local entries, srcfile, bib, keys, entry, nams, cand, nams2, labels;

    entries:= [];

    for srcfile in srcfiles do
      bib:= ParseBibXMLextString( StringFile( srcfile ) );
      Append( entries, List( bib.entries,
                         x -> RecBibXMLEntry( x, "BibTeX", bib.strings ) ) );
    od;

    keys:= [];
    for entry in entries do
      if entry.Label in keys then
        # Check that all entries with the same label are essentially equal.
        nams:= Difference( RecNames( entry ), ignorefields );
        for cand in Filtered( entries,
                              x -> x.Label = entry.Label and x <> entry ) do
          nams2:= Difference( RecNames( cand ), ignorefields );
          if   not IsSubset( nams, nams2 ) then
            Print( "#E  key ", entry.Label, " multiply defined:\n",
                   "#E  addit. components ", Difference( nams2, nams ), "\n" );
          fi;
          if not IsSubset( nams2, nams ) then
            Print( "#E  key ", entry.Label, " multiply defined:\n",
                   "#E  missing components ", Difference( nams, nams2 ), "\n" );
          fi;
          nams2:= Filtered( Intersection( nams, nams2 ),
                            x -> entry.( x ) <> cand.( x ) );
          if not IsEmpty( nams2 ) then
            Print( "#E  key ", entry.Label, " multiply defined:\n",
                   "#E  different components ", nams2, "\n" );
          fi;
        od;
      fi;
      AddSet( keys, entry.Label );
    od;

    for entry in entries do
      if entry.Type in [ "incollection", "inproceedings" ] then
        if not IsBound( entry.crossref ) then
          Print( "#I  missing crossref field in ", entry.Label, "\n" );
        fi;
      elif IsBound( entry.crossref ) then
        Print( "#E  why crossref field in ", entry.Label,
               " (type ", entry.Type, ")?\n" );
      fi;

      if IsBound( entry.crossref ) then
        if entry.crossref in keys then
          if not IsBound( entry.booktitle ) and
             not IsBound( entry.note ) then
            # Where shall the HTML link be placed?
            Print( "#E  crossref problem: neither booktitle nor note in ",
                   entry.Label, "\n" );
          fi;
        else
          Print( "#E  no target for crossref. ", entry.crossref, "\n" );
        fi;
      fi;

      if IsAlphaChar( entry.Label[ Length( entry.Label ) ] ) then
        if entry.Label{ [ 1 .. Length( entry.Label )-1 ] } in keys then
          Print( "#E  labels ", entry.Label, " and ",
                 entry.Label{ [ 1 .. Length( entry.Label )-1 ] }, "\n" );
        fi;
      fi;
    od;
    end );


#############################################################################
##
#F  BibEntries( <srcfile> )
##
BindGlobal( "BibEntries", function( srcfile )
    local str, ReplacementsXML2HTML, pair, bib, entries, entry;

    # Read the BibXMLext file, translate characters.
    str:= StringFile( srcfile );

    # The following translations are thought only for a HTML version
ReplacementsXML2HTML:= [
#T How to deal with hyphenation hints?
      [ "\\thinspace", " " ],
      [ "``", "\"" ],   # better already in XML file?
      [ "''", "\"" ],   # better already in XML file?
#T problem: choice of the symbols in question is language dependent
      [ "\\subseteq", " &#8838; " ],
#T o.k.?
      [ "\\;", " " ],
      [ "\\,", "" ],
      [ "\\!", "" ],
      [ "\\lt", "<" ],
#T can \lt appear? (does not in Atlas bibl.)
      [ "\\cdprime", "\"" ],
# The following could be removed if decapitalizing is restricted to TITLE. 
# (Then remove the curly brackets from the XML file!)
      [ "{A}achen", "Aachen" ], #  in SERIES, ADDRESS
      [ "Lehrstuhl {D}", "Lehrstuhl D" ], #  in SCHOOL
      [ "{RWTH-A}", "RWTH-A" ], #  in SCHOOL
# The following occur only in the GAP bibliography.
      [ "<C><M>\\sf{GAP}</M></C>", "<Wrap Name=\"Package\">GAP</Wrap>" ],
      [ "<C><C>\\sf GAP</C></C>", "<Wrap Name=\"Package\">GAP</Wrap>" ],
      [ "<C>\\sf GAP</C>", "<Wrap Name=\"Package\">GAP</Wrap>" ],
];    
#T similar functionality is needed also for a text version
#T and for an ASCII version (for Browse, cf. app/gapbibl.g)

    for pair in ReplacementsXML2HTML do
      str:= ReplacedString( str, pair[1], pair[2] );
    od;

    # Get the entries.
    bib:= ParseBibXMLextString( str );
    entries:= List( bib.entries,
                    x -> RecBibXMLEntry( x, "HTML", bib.strings ) );
#                                        rec( namefirstlast:= true ) ) );
    for entry in entries do
      entry.printedkey:= entry.Label;
    od;

    return entries;
    end );


#############################################################################
##
#F  PartOfHTMLBibliography( entries, crossreflabels, usedlabels )
##
BindGlobal( "PartOfHTMLBibliography",
    function( entries, crossreflabels, usedlabels )
    local labels, entry, text, id;

    # Warn if duplicate labels occur.
    labels:= [];
    for entry in entries do
      if entry.Label in labels then
        Print( "#I  duplicate label ", entry.Label, "\n" );
      fi;
      AddSet( labels, entry.Label );
    od;

    # Sort the entries.
    SortParallel( List( entries,
                    BibliographySporadicSimple.sortKeyFunction ), entries );

    # Create the result string.
    text:= "";
    for entry in entries do
      if IsBound( entry.crossref ) then
        if entry.crossref in crossreflabels then
          # Prepare a link.
          id:= ReplacedString( entry.crossref, "'", "dash" );
          if IsBound( entry.booktitle ) then
            entry.booktitle:= Concatenation( "<a href=\"#",
                                       id, "\">", entry.booktitle, "</a>" );
          elif IsBound( entry.note ) then
            entry.note:= Concatenation( "<a href=\"#",
                                       id, "\">", entry.note, "</a>" );
          else
            Print( "#I  crossref problem: neither booktitle nor note in ",
                   entry.Label, "\n" );
          fi;
        else
          Print( "#I  no target for crossref. ", entry.crossref, "\n" );
        fi;
      fi;
      if not entry.Label in usedlabels then
        # Provide an anchor (actually used only for cross-referenced entries).
        id:= ReplacedString( entry.Label, "'", "dash" );
        Append( text, Concatenation( "<p><a id=\"", id,
                        "\" name=\"", id, "\"></a></p>\n" ) );
        Add( usedlabels, entry.Label );
      fi;
      # Add the entry itself.
      Append( text, StringBibAsHTML( entry, false ) );
    od;

    return text;
    end );


#############################################################################
##
#F  AddHandlersBibliography()
##
BindGlobal( "AddHandlersBibliography", function()
    local tr;

    tr:= HeuristicTranslationsLaTeX2XML.TranslationOfOnePair;

    # Adjust LaTeX markup inside math mode.
    AddHandlerBuildRecBibXMLEntry( "M", "HTML",
      function( entry, elt, default, strings, opts )
      local  res;

      RECBIBXMLHNDLR.recode := false;
      res := ContentBuildRecBibXMLEntry( entry, elt, default, strings, opts );
      # first my replacements
      res := SubstitutionSublist( res, "&", "&amp;" );
      res := SubstitutionSublist( res, "<", "&lt;" );
      res:= tr( res, "{\\bf ", "}", "<b>", "</b>" );
      res:= tr( res, "{\\bf\n", "}", "<b>", "</b>" );
      # now apply TextM
      res:= TextM( res );
      # now the old replacements
      RECBIBXMLHNDLR.recode := true;

      return res;
    end );

    # The <intref> element is translated into a link inside the same file.
    AddHandlerBuildRecBibXMLEntry( "Wrap:IntRef", "HTML",
      function( entry, r, restype, strings, options )
      local rr, res;

      rr:= RecBibXMLEntry( entry );
      if IsBound( rr.intref ) then
        res:= Concatenation( "<a href=\"#", rr.intref, "\">",
                ContentBuildRecBibXMLEntry(
                  entry, r, restype, strings, options ), "</a>" );
        res:= tr( res, "{\\bf ", "}", "<b>", "</b>" );
        res:= tr( res, "{\\bf\n", "}", "<b>", "</b>" );
      else
        res:= ContentBuildRecBibXMLEntry(
                  entry, r, restype, strings, options );
      fi;
      return res;
    end );

    # The <Bib_...> elements are used to process complete references
    # that are embedded in <title> ans <note> elements.
    AddHandlerBuildRecBibXMLEntry( "Wrap:Bib_journal", "HTML",
      function( entry, r, restype, strings, options )
      return Concatenation( "<span class='Bib_journal'>",
                 ContentBuildRecBibXMLEntry(
                     entry, r, restype, strings, options ), "</span>" );
    end );

    AddHandlerBuildRecBibXMLEntry( "Wrap:Bib_volume", "HTML",
      function( entry, r, restype, strings, options )
      return Concatenation( "<em class='Bib_volume'>",
                 ContentBuildRecBibXMLEntry(
                     entry, r, restype, strings, options ), "</em>" );
    end );

    AddHandlerBuildRecBibXMLEntry( "Wrap:Bib_year", "HTML",
      function( entry, r, restype, strings, options )
      return Concatenation( "<span class='Bib_year'>",
                 ContentBuildRecBibXMLEntry(
                     entry, r, restype, strings, options ), "</span>" );
    end );

    AddHandlerBuildRecBibXMLEntry( "Wrap:Bib_number", "HTML",
      function( entry, r, restype, strings, options )
      return Concatenation( "<span class='Bib_number'>",
                 ContentBuildRecBibXMLEntry(
                     entry, r, restype, strings, options ), "</span>" );
    end );

    AddHandlerBuildRecBibXMLEntry( "Wrap:Bib_pages", "HTML",
      function( entry, r, restype, strings, options )
      return Concatenation( "<span class='Bib_pages'>",
                 ContentBuildRecBibXMLEntry(
                     entry, r, restype, strings, options ), "</span>" );
    end );
end );


#############################################################################
##
#F  CreateAtlasBibliographyHTML()
##
BindGlobal( "CreateAtlasBibliographyHTML", function()
    local dirs, srcfile1, srcfile2, targetfile, entries1, entries2, headers,
          crossrefs, crossreflabels, text, usedlabels, n, k, rowportions, r,
          i, portion, triple;

    dirs:= DirectoriesPackageLibrary( "atlasrep", "bibl" );
    srcfile1:= Filename( dirs, "Atlas1bib.xml" );
    srcfile2:= Filename( dirs, "Atlas2bib.xml" );
    targetfile:= Filename( dirs[1], "Atlasbib.html" );

    # Read the data.
    entries1:= BibEntries( srcfile1 );
    entries2:= BibEntries( srcfile2 );

    # Fetch the entries used in crossrefs.
    crossrefs:= Filtered( entries2, x -> not IsBound( x.sporsimp ) );
    entries2:= Filtered( entries2, x -> IsBound( x.sporsimp ) );
    crossreflabels:= List( crossrefs, x -> x.Label );

    # Initialize the result.
    text:= HTMLHeader(
             "ATLAS of Finite Groups -- Bibliography",
             "../doc/manual.css",
             Concatenation( "<a href=\"../index.html\">",
                 "GAP Package AtlasRep</a>" ),
             "ATLAS of Finite Groups &mdash; Bibliography" );

    # Append the overview table.
    Append( text, "\n<table class=\"datatable\">\n" );
    Append( text, "<tr>\n<td colspan=\"10\">\n<a href=\"" );
    Append( text, "#biblp243\">Bibliography on p. 243</a></td>\n</tr>\n" );
    headers:= BibliographySporadicSimple.groupnameinfo;
    n:= Length( headers );
    k:= Int( n / 7 );
    rowportions:= List( [ 1 .. k ], x -> [ 1 .. 7 ] + (x-1)*7 );
    if k*7 < n then
      Add( rowportions, [ 1 .. 7 ] + k*7 );
    fi;
    for r in rowportions do
      Append( text, "<tr>\n" );
      for i in r do
        Append( text, "<td class=\"pleft\">" );
        if i <= n then
          Append( text, "<a href=\"#" );
          Append( text, ReplacedString( headers[i][1], "'", "dash" ) );
          Append( text, "\">" );
          Append( text, headers[i][3] );
          Append( text, "</a>" );
        else
          Append( text, " &nbsp; " );
        fi;
        Append( text, "</td>\n" );
      od;
      Append( text, "</tr>\n" );
    od;
    Append( text, "<tr>\n<td colspan=\"10\">\n<a href=\"" );
    Append( text,
      "#crossref\">Cross-referenced Collections</a></td>\n</tr>\n" );
    Append( text, "</table>\n\n" );

    # Append the general part.
    usedlabels:= [];
    Append( text, "<p><a id=\"biblp243\" name=\"biblp243\"></a></p>\n" );
    Append( text,
      "<h4><span class=\"Heading\">Bibliography on p. 243</span></h4>\n\n" );
    Append( text, PartOfHTMLBibliography( entries1, crossreflabels,
                                          usedlabels ) );

    # Append the parts for the individual groups
    for triple in headers do
      portion:= Filtered( entries2, x -> x.sporsimp = triple[1] );
      entries2:= Filtered( entries2, x -> x.sporsimp <> triple[1] );
      if not IsEmpty( portion ) then
        Append( text, "<p><a id=\"" );
        Append( text, ReplacedString( triple[1], "'", "dash" ) );
        Append( text, "\" name=\"" );
        Append( text, ReplacedString( triple[1], "'", "dash" ) );
        Append( text, "\"></a></p>\n\n" );
        Append( text, Concatenation( "<h4><span class=\"Heading\">",
                          triple[2], " ", triple[3], "</span></h4>\n\n" ) );
        Append( text, PartOfHTMLBibliography( portion,
                        crossreflabels, usedlabels ) );
      fi;
    od;
    if not IsEmpty( entries2 ) then
      Error( "not all entries were used" );
    fi;

    # Append the collections' part.
    Append( text, Concatenation(
      "<p><a id=\"crossref\" name=\"crossref\"></a></p>\n\n",
      "<h4><span class=\"Heading\">Cross-referenced Collections",
      "</span></h4>\n" ) );
    Append( text, PartOfHTMLBibliography( crossrefs, [], usedlabels ) );

    # Append the footer.
    Append( text, HTMLFooter() );

    # Store the HTML file.
    FileString( targetfile, text );
    end );


#############################################################################
##
#F  CreateABCBibliographyHTML()
##
BindGlobal( "CreateABCBibliographyHTML", function()
    local dirs, srcfile1, srcfile2, targetfile, entries1, entries2,
          crossreflabels, entry, crossrefs, crossreflabels2, text,
          usedlabels;

    dirs:= DirectoriesPackageLibrary( "atlasrep", "bibl" );
    srcfile1:= Filename( dirs, "ABCbiblbib.xml" );
    srcfile2:= Filename( dirs, "ABCapp2bib.xml" );
    targetfile:= Filename( dirs[1], "ABCbibl.html" );

    # Read the data.
    entries1:= BibEntries( srcfile1 );
    entries2:= BibEntries( srcfile2 );

    # Separate the entries used in crossrefs from the others.
    crossreflabels:= [];
    for entry in Concatenation( entries1, entries2 ) do
      if IsBound( entry.crossref ) then
        AddSet( crossreflabels, entry.crossref );
      fi;
    od;
    crossrefs:= Filtered( entries1, x -> x.Label in crossreflabels );
    crossreflabels2:= Difference( crossreflabels,
                                  List( crossrefs, x -> x.Label ) );
    entries1:= Filtered( entries1, x -> not x.Label in crossreflabels );
    Append( crossrefs, Filtered( entries2, x -> x.Label in crossreflabels2 ) );
    entries2:= Filtered( entries2, x -> not x.Label in crossreflabels );
    crossreflabels:= List( crossrefs, x -> x.Label );

    # Initialize the result.
    text:= HTMLHeader(
             "ATLAS of Brauer Characters -- Bibliography",
             "../doc/manual.css",
             Concatenation( "<a href=\"../index.html\">",
                 "GAP Package AtlasRep</a>" ),
             "ATLAS of Brauer Characters &mdash; Bibliography" );

    # Append the overview table.
    Append( text, "\n<table class=\"datatable\">\n" );
    Append( text, "<tr>\n<td>\n<a href=\"" );
    Append( text,
      "#bibl1\">Bibliography on pp. xv&ndash;xvii</a></td>\n</tr>\n" );
    Append( text, "<tr>\n<td>\n<a href=\"" );
    Append( text,
      "#bibl2\">Bibliography on pp. 311&ndash;327</a></td>\n</tr>\n" );
    Append( text, "<tr>\n<td>\n<a href=\"" );
    Append( text,
      "#crossref\">Cross-referenced Collections</a></td>\n</tr>\n" );
    Append( text, "</table>\n\n" );

    # Append the general part.
    usedlabels:= [];
    Append( text, Concatenation(
      "<p><a id=\"bibl1\" name=\"bibl1\"></a></p>\n",
      "<h4><span class=\"Heading\">Bibliography on pp. xv&ndash;xvii",
      "</span></h4>\n\n" ) );
    Append( text, PartOfHTMLBibliography( entries1, crossreflabels,
                                          usedlabels ) );

    # Append the general part.
    Append( text, Concatenation(
      "<p><a id=\"bibl2\" name=\"bibl2\"></a></p>\n",
      "<h4><span class=\"Heading\">Bibliography on pp. 311&ndash;327",
      "</span></h4>\n\n" ) );
    Append( text, PartOfHTMLBibliography( entries2, crossreflabels,
                                          usedlabels ) );

    # Append the collections' part.
    Append( text, Concatenation(
      "<p><a id=\"crossref\" name=\"crossref\"></a></p>\n",
      "<h4><span class=\"Heading\">Cross-referenced Collections",
      "</span></h4>\n\n" ) );
    Append( text, PartOfHTMLBibliography( crossrefs, [], usedlabels ) );

    # Append the footer.
    Append( text, HTMLFooter() );

    # Store the HTML file.
    FileString( targetfile, text );
    end );


#############################################################################
##
#E

