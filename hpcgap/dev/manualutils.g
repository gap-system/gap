#############################################################################
##
##  This file contains some tools for improving GAPDoc manuals
##


#############################################################################
##
#V  GAPInfo.keywords:= [
##
#T introduce this GAPInfo component in lib,
#T and show it in the language chapter instead of an explicit list!
##
GAPInfo.keywords:= [
    "and", "do", "elif", "else", "end", "fi", "for", "function", "if", "in",
    "local", "mod", "not", "od", "or", "repeat", "return", "then", "until",
    "while", "quit", "QUIT", "break", "rec", "continue", "false", "true",
    "IsBound", "Unbind", "TryNextMethod", "Info", "Assert", "SaveWorkspace",
    "fail",
  ];;


#############################################################################
##
#F  AdjustFunction( str )
##
##  a utility that might become unnecessary in the future ...
##
AdjustFunction:= function( str )
  local str1utf8, offs, off, i, c;

  # the .start and .stop positions are wrt. to the UTF-8 recoded input
  str1utf8 := Encode(Unicode(str[1], "latin1"), "UTF-8");
  # caching offset every 1000 characters
  offs := [ 0 ];
#T TB: added a 0
  off := 0;
  for i in [1..Length(str1utf8)] do
    c := INT_CHAR(str1utf8[i]);
    if c > 127 and c < 192 then
      off := off + 1;
    fi;
    if i mod 1000 = 0 then
      Add(offs,off);
    fi;
  od;

  return function(pos)
    local res, c, i;
    res := offs[(pos - (pos mod 1000))/1000 + 1];
    for i in [pos - (pos mod 1000) + 1..pos] do
      c := INT_CHAR(str1utf8[i]);
      if c > 127 and c < 192 then
        res := res + 1;
      fi;
    od;
    return pos - res;
  end;
end;


#############################################################################
##
#F  PrintInfoAboutManualChapters( <pathtodoc>, <main>, <files>, <chapnrs> )
##
##  The first three arguments are the same as for MakeGAPDocDoc.
##  The fourth argument is a chapter number or a list of chapter numbers
##  or the string <C>"all"</C>.
##
#T Deal also with the case that the document has no chapters!
#T (i.e. do not collect chapterwise)
##
PrintInfoAboutManualChapters:= function( pathtodoc, main, files, chapnrs )
    local str, xmltree, booktitle, elms, adjust, chapnr, chapter, heading,
          start, chaptstr, Celms, allc, allcandref, pos, pos2, entry, new,
          pos3, pos4, documented, undocumented, keywords, triple;

    # Create the XML tree.
    str:= ComposedDocument( "GAPDoc", Directory( pathtodoc ),
                            main, files, true );;
    xmltree := ParseTreeXMLString( str[1], str[2] );;
    booktitle:= GetTextXMLTree( XMLElements( xmltree, "Title" )[1] );

    # Fetch the string with the contents of the chapter(s) in question.
    elms:= XMLElements( xmltree, "Chapter" );;
    if IsPosInt( chapnrs ) then
      chapnrs:= [ chapnrs ];
    elif chapnrs = "all" then
      chapnrs:= [ 1 .. Length( elms ) ];
    elif not IsPositionsList( chapnrs ) then
      Error( "<chapnrs> must be a chapter number or a list of chapter numbers" );
    fi;

    Print( booktitle, "\n" );

    # Adjust the .start and .stop positions.
    adjust:= AdjustFunction( str );

    for chapnr in chapnrs do
      chapter:= elms[ chapnr ];;
      heading:= GetTextXMLTree( XMLElements( chapter, "Heading" )[1] );
      start:= adjust( chapter.start );
      chaptstr:= str[1]{ [ start .. adjust( chapter.stop ) ] };;

      Print( "\nChapter ", chapnr, ": ", heading, "\n" );

      # Compute all <C> elements in the given chapter, and their positions.
      Celms:= XMLElements( chapter, "C" );;

      # Special case (where the XML tree does not help us):
      # A <C> element followed by a <Ref> element with the same contents
      # (not too far away) should be replaced by the <Ref> element,
      # together with a reformulation of the text.
      # This is likely to occur in manuals that were translated from the
      # `gapmacro.tex' format.
      allc:= [];
      allcandref:= [];
      pos:= PositionSublist( chaptstr, "<C>" );
      while not pos = fail do
        # Deal with the next <C> element.
        pos2:= PositionSublist( chaptstr, "</C>", pos );
        entry:= chaptstr{ [ pos+3 .. pos2-1 ] };
        new:= [ entry, OriginalPositionDocument( str[2], pos + start - 1 ) ];
        Add( allc, new );

        # Check whether the contents of the next reference is the same.
        pos3:= PositionSublist( chaptstr, "<Ref", pos );
        if pos3 <> fail then
          pos4:= PositionSublist( chaptstr, "/>", pos3 );
          if PositionSublist( chaptstr{ [ pos3 .. pos4 ] },
                              Concatenation( "\"", entry, "\"" ) ) <> fail then
            Add( new, chaptstr{ [ pos3 .. pos4 + 1 ] } );
            Add( allcandref, new );
          fi;
        fi;

        pos:= PositionSublist( chaptstr, "<C>", pos2 );
      od;
      if not IsEmpty( allcandref ) then
        Print( "\nduplicate contents for cross-references: ",
               "(total ", Length( allcandref ), ")\n" );
        for entry in allcandref do
          Print( "  ", entry[1], ":\n    file ", entry[2][1], ", line ",
                 entry[2][2], ",\n    later cited as ", entry[3], "\n" );
        od;
      fi;

      # Compute the subset of <C> elements whose contents are identifiers of
      # *documented* GAP variables,
      # and which should probably (but not necessarily!) be replaced by
      # the corresponding <Ref> elements.
#T how to propose the type of the reference (and possible labels)?
      documented:= Filtered( Celms,
                       x -> IsString( x.content[1].content ) and
                            IsDocumentedVariable( x.content[1].content ) );
#T change IsDocumentedVariable to check for IsString?
      if not IsEmpty( documented ) then
        Print( "\ndocumented variables (?) mentioned in <C> elements: ",
               "(total ", Length( documented ), ")\n" );
        for entry in documented do
          pos:= OriginalPositionDocument( str[2], adjust( entry.start ) );
          Print( "  ", entry.content[1].content, ":\n    file ", pos[1],
                 ", line ", pos[2], "\n" );
        od;
      fi;

      # Compute the subset of <C> elements whose contents are identifiers of
      # existing but *undocumented* variables;
      # probably (but not necessarily!) either these elements should be avoided
      # or the corresponding variable should become documented.
      undocumented:= Filtered( Celms,
                       x -> IsString( x.content[1].content ) and
                            IsBoundGlobal( x.content[1].content ) and
                            not IsDocumentedVariable( x.content[1].content ) );
      if not IsEmpty( undocumented ) then
        Print( "\nundocumented variables (?) mentioned in <C> elements: ",
               "(total ", Length( undocumented ), ")\n" );
        for entry in undocumented do
          pos:= OriginalPositionDocument( str[2], adjust( entry.start ) );
          Print( "  ", entry.content[1].content, ":\n    file ", pos[1],
                 ", line ", pos[2], "\n" );
        od;
      fi;
    
      # Compute the subset of <C> elements whose contents are keywords,
      # and which should probably (but not necessarily!) be replaced by
      # the corresponding <K> elements.
      keywords:= Filtered( Celms,
                       x -> IsString( x.content[1].content ) and
                            x.content[1].content in GAPInfo.keywords );
      if not IsEmpty( keywords ) then
        Print( "\nkeywords (?) mentioned in <C> elements: ",
               "(total ", Length( keywords ), ")\n" );
        for entry in keywords do
          pos:= OriginalPositionDocument( str[2], adjust( entry.start ) );
          Print( "  ", entry.content[1].content, ":\n    file ", pos[1],
                 ", line ", pos[2], "\n" );
        od;
      fi;
    
    od;
#T perhaps return all the computed information?
end;


#############################################################################
##
#F  OverviewOfChaptersForProofreadingForm( <pathtodoc>, <main>, <files> )
##
##  This function creates a ``form'' that lists the chapters of a manual
##  and lines to be filled out after proofreading.
##  (See for example the file `dev/manualchapters'.)
##
##  The arguments are the same as the first three arguments of MakeGAPDocDoc.
##
OverviewOfChaptersForProofreadingForm:= function( pathtodoc, main, files )
    local str, xmltree, elms, filecontents, adjust, i, where;

    str:= ComposedDocument( "GAPDoc", Directory( pathtodoc ),
                            main, files, true );
    xmltree:= ParseTreeXMLString( str[1], str[2] );
    elms:= List( XMLElements( xmltree, "Chapter" ), 
                 x -> XMLElements( x, [ "Heading" ] )[1] );
    filecontents:= "";

    # adjust the .start and .stop positions.
    adjust:= AdjustFunction( str );

    for i in [ 1 .. Length( elms ) ] do
      where:= OriginalPositionDocument( str[2], adjust( elms[i].start ) );
      Append( filecontents, Concatenation(
        RepeatedString( "%", 76 ),
        "\n% Chapter ", String( i ), ": ", GetTextXMLTree( elms[i] ),
        "\n% File: ", where[1], " (line ", String(where[2]), ")",
        "\n% Who:",
        "\n% Started:",
        "\n% Finished:",
        "\n% Comments:\n" ) );
    od;

    return filecontents;
end;


#############################################################################
##
##  The following functions have been used for moving <Example> elements
##  into ``their'' <ManSection> elements.
##


#############################################################################
##
#F  ChainedExamples( <pathtodoc>, <main>, <files> )
##
##  finds all <Example> or <Log> elements that follow such elements;
##  these can likely be joined.
##  (In very old manuals, page breaks were ``suggested'' to LaTeX in
##  ``appropriate'' places by cutting a longer example into pieces.)
##
ChainedExamples:= function( pathtodoc, main, files )
    local str, pairs, allx, pair, pos, pos2, entry, new, intermed;

    # Create the XML tree.
    str:= ComposedDocument( "GAPDoc", Directory( pathtodoc ),
                            main, files, true );;

    pairs:= [ [ "</Example>", "<Example>" ],
              [ "</Example>", "<Log>" ],
              [ "</Log>", "<Example>" ],
              [ "</Log>", "<Log>" ],
            ];

    allx:= [];
    for pair in pairs do

      pos:= PositionSublist( str[1], pair[1] );
      while not pos = fail do
        pos2:= PositionSublist( str[1], pair[2], pos );
        if pos2 <> fail then
          entry:= str[1]{ [ pos .. pos2 + Length( pair[2] ) - 1 ] };
          intermed:= str[1]{ [ pos + Length( pair[1] ) .. pos2 - 1 ] };
          intermed:= ReplacedString( intermed, "\n", "" );
          intermed:= ReplacedString( intermed, " ", "" );
          intermed:= ReplacedString( intermed, "<P/>", "" );
          if IsEmpty( intermed ) then
            # Do NOT use AdjustFunction here!
            new:= [ entry, OriginalPositionDocument( str[2], pos ) ];
            Add( allx, new );
          fi;
          pos:= PositionSublist( str[1], pair[1], pos2 );
        else
          pos:= fail;
        fi;
      od;
    od;

    return allx;
end;

# finds the following occurrences in the ref. manual:
# 
# [ [ "</Example>\n<P/>\n<Example>", [ "./mloop.xml", 231 ] ],     # done
#   [ "</Example>\n<P/>\n<Example>", [ "./streams.xml", 131 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./word.xml", 117 ] ],      # done
#   [ "</Example>\n<P/>\n<Example>", [ "./groups.xml", 395 ] ],    # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grpoper.xml", 146 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./pcgs.xml", 113 ] ],      # done
#   [ "</Example>\n<P/>\n<Example>", [ "./pcgs.xml", 622 ] ],      # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grppc.xml", 364 ] ],     # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grppc.xml", 416 ] ],     # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grpprod.xml", 101 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grpprod.xml", 116 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grpprod.xml", 137 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grpprod.xml", 144 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grplib.xml", 622 ] ],    # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grplib.xml", 633 ] ],    # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grplib.xml", 645 ] ],    # done
#   [ "</Example>\n<P/>\n<Example>", [ "./grplib.xml", 655 ] ],    # done
#   [ "</Example>\n<P/>\n<Example>", [ "./algebra.xml", 320 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./algebra.xml", 331 ] ],   # done
#   [ "</Example>\n<P/>\n<Example>", [ "./ctbl.xml", 1241 ] ],     # done
#   [ "</Example>\n<P/>\n<Example>", [ "./ctbl.xml", 1275 ] ],     # done
#   [ "</Example>\n<P/>\n<Log>", [ "./mloop.xml", 423 ] ], 
#   [ "</Log>\n<P/>\n<Example>", [ "./lists.xml", 708 ] ], 
#   [ "</Log>\n<P/>\n<Example>", [ "./grplib.xml", 673 ] ], 
#   [ "</Log>\n<P/>\n<Log>", [ "./../../lib/process.gd", 82 ] ],   # done
#   [ "</Log>\n<P/>\n<Log>", [ "./../../lib/process.gd", 89 ] ] ]  # done


#############################################################################
##
#F  InfoForMovingExamples( <pathtodoc>, <main>, <files> )
##
##  collects the positions and the contents of those <Example> elements
##  which follow immediately a "</ManSection>"
##  (separated from this string at most by whitespace, line breaks, "</P>").
##
InfoForMovingExamples:= function( pathtodoc, main, files )
    local str, xmltree, removals, additions, count, pos, pos2, intermed,
          found, pos0, pos3, entry, filepos1, filepos2;

    # Create the XML tree.
    str:= ComposedDocument( "GAPDoc", Directory( pathtodoc ),
                            main, files, true );;
    xmltree := ParseTreeXMLString( str[1], str[2] );;

    removals:= [];
    additions:= [];
    count:= 0;
    pos:= PositionSublist( str[1], "</ManSection>" );
    while not pos = fail do
      pos2:= PositionSublist( str[1], "<Example>", pos );
      if pos2 <> fail then
        intermed:= str[1]{ [ pos + Length( "</ManSection>" ) .. pos2 - 1 ] };
        intermed:= ReplacedString( intermed, "\n", "" );
        intermed:= ReplacedString( intermed, " ", "" );
        intermed:= ReplacedString( intermed, "<P/>", "" );
        if IsEmpty( intermed ) then
          found:= false;
          for pos0 in [ pos-1, pos-2 .. 1 ] do
            if str[1]{ [ pos0 .. pos0 + Length( "</Description>" ) - 1 ] }
                     = "</Description>" then
              found:= true;
              intermed:= str[1]{ [ pos0 + Length( "</Description>" )
                                   .. pos - 1 ] };
              intermed:= ReplacedString( intermed, "\n", "" );
              intermed:= ReplacedString( intermed, " ", "" );
              intermed:= ReplacedString( intermed, "<P/>", "" );
              if not IsEmpty( intermed ) then
                Error( "no </Description></ManSection>\n" );
              else
                count:= count+1;
              fi;
              break;
            fi;
          od;
          if not found then
            Error( "no </Description> at all\n" );
          fi;

          # Mark this <Example> element for a move!
          pos3:= PositionSublist( str[1], "</Example>", pos2 );
          entry:= str[1]{ [ pos2 .. pos3 + Length( "</Example>" ) ] };
          # ``Add entry (4) which stems from file (3)
          # before the line (2) in the given file (1).''
          Add( additions, Concatenation(
                              OriginalPositionDocument( str[2], pos0 ),
                              [ OriginalPositionDocument( str[2], pos2 )[1] ],
                              [ entry ] ) );
          # ``Remove the lines in the given range [ (2) .. (3) ]
          # from the given file (1).''
          filepos1:= OriginalPositionDocument( str[2], pos2 );
          filepos2:= OriginalPositionDocument( str[2], pos3
                        + Length( "</Example>" ) );
          if filepos1[1] <> filepos2[1] then
            Error( "example split over several files" );
          fi;
          Add( removals, [ filepos1[1], filepos1[2], filepos2[2] ] );
        fi;
      fi;
      pos:= PositionSublist( str[1], "</ManSection>", pos );
    od;

    return rec( removals:= removals,
                additions:= additions,
                count:= count );
end;

# finds total 915 in the ref. manual:
# xml -> xml:  1
# xml -> lib etc.: 914


#############################################################################
##
#F  MoveExamples( <inforec> )
##
##  takes the record computed by `InfoForMovingExamples', moves the
##  examples in question, and writes the modified files back.
##
MoveExamples:= function( inforec )
    local additions, removals, files, work, mark, entry, list, i, currfile,
          toadd, file, join;

    additions:= Reversed( SortedList( inforec.additions ) );
    removals:= SortedList( inforec.removals );

    files:= Set( Concatenation( List( additions, x -> x[1] ),
                                List( removals, x -> x[1] ) ) );
    work:= rec();
    for file in files do
      work.( file ):= SplitString( StringFile( file ), "\n" );
    od;
    mark:= "TOBEDELETED";
    if ForAny( files, x -> mark in work.( x ) ) then
      Error( "choose another mark!" );
    fi;

    # Mark the lines to be removed.
    for entry in removals do
      list:= work.( entry[1] );
      for i in [ entry[2] .. entry[3] ] do
        list[i]:= mark;
      od;
    od;

    # Perform the additions (for each file in reversed order).
    currfile:= "";
    for entry in additions do
      if entry[1] <> currfile then
        currfile:= entry[1];
      fi;
      toadd:= SplitString( entry[4], "\n" );
      if currfile{ Length( currfile ) + [ - 3 .. 0 ] } <> ".xml" and
         entry[3]{ Length( entry[3] ) + [ - 3 .. 0 ] } = ".xml" then
        # We move from an `xml' file to a non-`xml' file, so indent!
        toadd:= List( toadd, x -> Concatenation( "##  ", x ) );
      fi;
      list:= work.( currfile );
      work.( currfile ):= Concatenation( list{ [ 1 .. entry[2] - 1 ] },
                            toadd,
                            list{ [ entry[2] .. Length( list ) ] } );
    od;

    # Perform the removals.
    for file in files do
      work.( file ):= Filtered( work.( file ), x -> x <> mark );
    od;

    # Write the changed files.
    for file in files do
      Add( work.( file ), "" );
      join:= JoinStringsWithSeparator( work.( file ), "\n" );
      FileString( file, join );
    od;
end;


# BEFORE: "<Example>" in doc/ref/*.xml: 1295
# BEFORE: "<Example>" in lib/*:           49
# BEFORE: "<Example>" in grp/*:            0
# BEFORE: "<Example>" in prim/*:           0
# BEFORE: "<Example>" in small/*:          0
# BEFORE: "<Example>" in pkg/tomlib/gap/*: 0

# AFTER:  "<Example>" in doc/ref/*.xml:  381
# AFTER:  "<Example>" in lib/*:          937
# AFTER:  "<Example>" in grp/*:           19
# AFTER:  "<Example>" in prim/*:           2
# AFTER:  "<Example>" in small/*:          1
# AFTER:  "<Example>" in pkg/tomlib/gap/*: 4


#############################################################################
##
#E

