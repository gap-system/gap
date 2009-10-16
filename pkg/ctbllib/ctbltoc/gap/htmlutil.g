##############################################################################
##
#W  htmlutil.g                                                   Thomas Breuer
##
#H  @(#)$Id: htmlutil.g,v 1.16 2008/09/24 09:26:37 gap Exp $
##
#Y  Copyright  (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains utility functions used to create HTML files using
##  {\GAP}.
##  These functions are used for the Web pages on decomposition matrices and
##  for the Web pages on {\GAP} character tables.
##


##############################################################################
##
#V  HTMLDataDirectory
#V  HTMLDataDirectoryLocal
#V  HTMLCompareMark
##
Print( "#I  The current value of HTMLDataDirectory is\n",
       "#I  ", HTMLDataDirectory, ",\n",
       "#I  the current value of HTMLDataDirectoryLocal is\n",
       "#I  ", HTMLDataDirectoryLocal, ".\n",
       "#I  If you want to change this then call `Directory'\n",
       "#I  with the desired directory path.\n" );

HTMLCompareMark := "File created automatically by GAP on ";


##############################################################################
##
#V  HTMLGlobals
##
HTMLGlobals := rec(
    leq := "&#8804;",
    ast := "&#8727;",
    sub := [ "<sub>", "</sub>" ],
    super := [ "<sup>", "</sup>" ],
    center:= [ "<center>", "</center>" ],
#   bold := [ "<strong>", "</strong>" ],
    bold := [ "", "" ],
    dot := ".",
    splitdot := ":",
    times := " &times; ",
    xi := "&#958;"
    );


##############################################################################
##
#V  LaTeXGlobals
##
LaTeXGlobals := rec(
    leq := "\\leq",
    ast := "\\ast",
    sub := [ "_{", "}" ],
    super := [ "^{", "}" ],
    center:= [ "\n\\begin{center}\n", "\n\\end{center}\n" ],
#   bold := [ "\\textbf{", "}" ],
    bold := [ "", "" ],
    dot := ".",
    splitdot := ":",
    times := " \\times ",
    xi := "\\xi"
    );


##############################################################################
##
#F  MarkupFactoredNumber( <n>, <record> )
#F  HTMLFactoredNumber( <n> )
#F  LaTeXFactoredNumber( <n> )
##
MarkupFactoredNumber := function( n, record )
    local str, pair;

    if not IsPosInt( n ) then
      Error( "<n> must be a positive integer" );
    elif n = 1 then
      return "1";
    fi;

    str:= "";

    # Loop over the prime factors and the corresponding exponents.
    for pair in Collected( Factors( n ) ) do
      Append( str, String( pair[1] ) );
      if 1 < pair[2] then
        Append( str, record.super[1] );
        Append( str, String( pair[2] ) );
        Append( str, record.super[2] );
      fi;
      Append( str, " " );
    od;
    Unbind( str[ Length( str ) ] );

    # Return the result.
    return str;
end;

HTMLFactoredNumber := ( n -> MarkupFactoredNumber( n, HTMLGlobals ) );

LaTeXFactoredNumber := ( n -> MarkupFactoredNumber( n, LaTeXGlobals ) );


##############################################################################
##
#F  ParseGroupName( <name>, <global> )
##
##  Let <name> be a string describing a group structure,
##  and <global> be one of `HTMLGlobals', `LaTeXGlobals'.
##  This function first turns <name> into a tree describing the hierarchy
##  given by brackets,
##  then splits the strings that occur in this tree at
##  the following characters.
##  `x' (for direct product),
##  `.' and `:' (for product and semidirect product, respectively),
##  `_' (for an index to be written as a subscript),
##  `^' (for an exponent),
##  where the weakest binding is treated first.
##  Then the strings that occur in the resulting tree are converted:
##  numbers following a capital letter are turned into subscripts,
##  and the characters `+', `-' are turned into superscripts.
##  Finally, this tree is imploded into a string, where the characters at
##  which the input was split are replaced by the relevant entries of
##  <globals>.
##
ParseGroupName:= function( name, global )
  local extractbrackets, split, convertstring, convertatoms, concatenate,
        result, i;

  extractbrackets:= function( str )
    local tree, brackets, pos, minpos, b, closeb, closepos, open;

    tree:= [];
    brackets:= [ "([{", ")]}" ];
    while str <> "" do
      pos:= List( brackets[1], b -> Position( str, b ) );
      minpos:= Minimum( pos );
      if minpos <> fail then
        b:= str[ minpos ];
        closeb:= brackets[2][ Position( brackets[1], b ) ];
        closepos:= minpos+1;
        open:= 0;
        while closepos <= Length( str )
              and ( str[ closepos ] <> closeb or open <> 0 ) do
          if   str[ closepos ] = b then
            open:= open+1;
          elif str[ closepos ] = closeb then
            open:= open-1;
          fi;
          closepos:= closepos + 1;
        od;
        if closepos > Length( str ) then
          return fail;
        fi;
        Append( tree,
             [ str{ [ 1 .. minpos-1 ] },
               rec( op:= b,
                    contents:= extractbrackets( str{ [ minpos+1
                                   .. closepos-1 ] } ) ) ] );
        str:= str{ [ closepos+1 .. Length( str ) ] };
      else
        Add( tree, str );
        str:= "";
      fi;
    od;
    return tree;
  end;

  split:= function( tree )
    local i, splitchar, found, entry, pos;

    tree:= ShallowCopy( tree );
    for i in [ 1 .. Length( tree ) ] do
      entry:= tree[i];
      if IsRecord( tree[i] ) then
        if IsBound( entry.contents ) then
          tree[i]:= rec( op:= entry.op, contents:= split( entry.contents ) );
        else
          tree[i]:= rec( op:= entry.op, left:= split( entry.left ),
                             right:= split( entry.right ) );
        fi;
      fi;
    od;

    for splitchar in "x.:_^" do  # weakest binding first!
      for i in [ 1 .. Length( tree ) ] do
        entry:= tree[i];
        if IsString( entry ) then
          pos:= Position( entry, splitchar );
          if pos <> fail then
            return [ rec( op:= splitchar,
                        left:= split( Concatenation( tree{ [ 1 .. i-1 ] },
                               [ entry{ [ 1 .. pos-1 ] } ] ) ),
                        right:= split( Concatenation( [ entry{ [ pos+1
                                   .. Length( entry ) ] } ],
                                   tree{ [ i+1 .. Length( tree ) ] } ) ) ) ];
          fi;
        fi;
      od;
    od;
    return tree;
  end;

#T If we want to replace `"L2(4)"' and not `"L2"' then
#T first we have to implode locally, in order to get "(4)";
#T this is done by hte following function.
#T Afterwards, we have to implode locally the two parts in question.
  # concatenatenumberbrackets:= function( tree )
  #     local i;
  #
  #     for i in [ 1 .. Length( tree ) ] do
  #       if IsRecord( tree[i] ) then
  #         if   tree[i].op = '^' and Length( tree[i].left ) = 1
  #                               and Length( tree[i].right ) = 1
  #                               and IsString( tree[i].left[1] )
  #                               and Int( tree[i].left[1] ) <> fail
  #                               and IsString( tree[i].right[1] )
  #                               and Int( tree[i].right[1] ) <> fail then
  #           tree[i]:= Concatenation( tree[i].left[1], global.super[1],
  #                                    tree[i].right[1], global.super[2] );
  #         elif tree[i].op = '_' and Length( tree[i].left ) = 1
  #                               and Length( tree[i].right ) = 1
  #                               and IsString( tree[i].left[1] )
  #                               and Int( tree[i].left[1] ) <> fail
  #                               and IsString( tree[i].right[1] )
  #                               and Int( tree[i].right[1] ) <> fail then
  #           tree[i]:= Concatenation( tree[i].left[1], global.sub[1],
  #                                    tree[i].right[1], global.sub[2] );
  #         elif tree[i].op = '(' and Length( tree[i].contents ) = 1
  #                               and IsString( tree[i].contents[1] )
  #                               and Int( tree[i].contents[1] ) <> fail then
  #           tree[i]:= Concatenation( "(", tree[i].contents[1], ")" );
  #         elif IsBound( tree[i].contents ) then
  #           concatenatenumberbrackets( tree[i].contents );
  #         else
  #           concatenatenumberbrackets( tree[i].left );
  #           concatenatenumberbrackets( tree[i].right );
  #         fi;
  #       fi;
  #     od;
  #
  #     return tree;
  # end;

  convertstring:= function( str )
    local digits, letters, lower, special, pos, len, string, dig;

    digits  := "0123456789";
    letters := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    lower   := "abcdefghijklmnopqrstuvwxyz";

    # translate special cases
    special:= TransposedMat( [
       [ "McL", Concatenation( global.bold[1], "M", global.super[1], "c",
                               global.super[2], "L", global.bold[2] ) ],
       [ "F3+", Concatenation( global.bold[1], "F", global.bold[2],
                               global.sub[1], "3+", global.sub[2] ) ],
       [ "2E6", Concatenation( global.super[1], "2", global.super[2],
                               global.bold[1], "E", global.bold[2],
                               global.sub[1], "6", global.sub[2] ) ],
       [ "2F4", Concatenation( global.super[1], "2", global.super[2],
                               global.bold[1], "F", global.bold[2],
                               global.sub[1], "4", global.sub[2] ) ],
       [ "3D4", Concatenation( global.super[1], "3", global.super[2],
                               global.bold[1], "D", global.bold[2],
                               global.sub[1], "4", global.sub[2] ) ],
       [ "Isoclinic", "Isoclinic" ],  # prevent from being set in boldface
       ] );
    pos:= Position( special[1], str );
    if pos <> fail then
      return special[2][ pos ];
    fi;

    # general heuristics
    pos:= 1;
    len:= Length( str );
    string:= "";

    # initial digits become superscripts if an uppercase letter follows
#T no, must have been treated above ...
    dig:= "";
    while pos <= len and str[ pos ] in digits do
      Add( dig, str[ pos ] );
      pos:= pos + 1;
    od;

    # copy letter part
    if pos <= len and str[ pos ] in letters then
      if not IsEmpty( dig ) then
        Append( string, dig );
      fi;
      Append( string, global.bold[1] );

      while pos <= len and str[ pos ] in letters do
        Add( string, str[ pos ] );
        pos:= pos + 1;
      od;
      Append( string, global.bold[2] );
    else
      Append( string, dig );
    fi;

    # following digits become subscripts
    if pos <= len and str[ pos ] in digits then
      Append( string, global.sub[1] );
      while pos <= len and str[ pos ] in digits do
        Add( string, str[ pos ] );
        pos:= pos + 1;
      od;
      Append( string, global.sub[2] );
    fi;

    # A following '+' or '-' becomes a superscript if it is the last letter.
    # (except for `"F3+"' but this has been handled above ...)
    if pos = len and str[ pos ] in "+-" then
      Append( string, global.super[1] );
      Add( string, str[ pos ] );
      pos:= pos + 1;
      Append( string, global.super[2] );
    fi;

    # In the tail, just take care of subscripts.
    while pos <= len do
      if str[ pos ] <> '_' then
        Add( string, str[ pos ] );
        pos:= pos + 1;
      else
#T this does not occur
        pos:= pos + 1;
        Append( string, global.sub[1] );
        while pos <= len and str[ pos ] in digits do
          Add( string, str[ pos ] );
          pos:= pos + 1;
        od;
        Append( string, global.sub[2] );
      fi;
    od;

    # a hack:
    if IsBound( string[1] ) and string[1] = '^' then
      string:= Concatenation( "{}", string );
    fi;

    return string;
  end;

  convertatoms:= function( tree )
    local i, entry;

    for i in [ 1 .. Length( tree ) ] do
      entry:= tree[i];
      if IsString( entry ) then
        tree[i]:= convertstring( tree[i] );
      elif IsBound( entry.contents ) then
        convertatoms( entry.contents );
      else
        convertatoms( entry.left );
        convertatoms( entry.right );
      fi;
    od;
    return tree;
  end;

  # Concatenate the translated parts.
  concatenate:= function( tree )
    local result, entry, right;

    result:= [];
    for entry in tree do
      if IsString( entry ) then
        Add( result, entry );
      elif IsBound( entry.contents ) then
        if   entry.op = '(' then
          Add( result,
               Concatenation( "(", concatenate( entry.contents ), ")" ) );
        elif entry.op = '[' then
          Add( result,
               Concatenation( "[", concatenate( entry.contents ), "]" ) );
        elif entry.op = '{' then
          Add( result,
               Concatenation( "{", concatenate( entry.contents ), "}" ) );
        fi;
      else
        if   entry.op = '^' then
          # Deal with superscripts
          # (remove brackets around the superscripts if they are unique).
          right:= concatenate( entry.right );
          if Length( right ) > 0 and right[1] = '('
                                 and right[ Length( right ) ] = ')'
                                 and Number( right, x -> x = '(' ) = 1 then
            right:= right{ [ 2 .. Length( right ) - 1 ] };
          fi;
          Add( result, Concatenation( concatenate( entry.left ),
                           global.super[1], right, global.super[2] ) );
        elif entry.op = '_' then
          # Deal with subscripts
          # (remove brackets around the subscripts if they are unique).
          right:= concatenate( entry.right );
          if Length( right ) > 0 and
                ( ( right[1] = '{' and right[ Length( right ) ] = '}'
                                   and Number( right, x -> x = '{' ) = 1 )
                or ( right[1] = '(' and right[ Length( right ) ] = ')'
                              and Number( right, x -> x = '(' ) = 1 ) ) then
            right:= right{ [ 2 .. Length( right ) - 1 ] };
          fi;
          Add( result, Concatenation( concatenate( entry.left ),
                           global.sub[1], right, global.sub[2] ) );
        elif entry.op = 'x' then
          Add( result, Concatenation( concatenate( entry.left ),
                           global.times, concatenate( entry.right ) ) );
        elif entry.op = '.' then
          Add( result, Concatenation( concatenate( entry.left ),
                           global.dot, concatenate( entry.right ) ) );
        elif entry.op = ':' then
          Add( result, Concatenation( concatenate( entry.left ),
                           global.splitdot, concatenate( entry.right ) ) );
        fi;
      fi;
    od;
    return Concatenation( result );
  end;

  result:= concatenate( convertatoms( split( extractbrackets( name ) ) ) );

  for i in [ 1 .. 3 ] do
    result:= ReplacedString( result,
                 Concatenation( ".2<sub>", String( i ), "'</sub>" ),
                 Concatenation( ".2<sub>", String( i ), "</sub>'" ) );
  od;

  return result;
end;



##############################################################################
##
#F  DecMatName( <gapname>, \"LaTeX\" )
#F  DecMatName( <gapname>, \"HTML\" )
##
##  Let <gapname> be the name of a character table from the {\ATLAS} of Finite
##  Groups.
##  `DecMatName' returns the string describing <gapname> with the proper
##  subscripts and superscripts.
##
DecMatName := function( gapname, mode )
    local globals;

    if   mode = "LaTeX" then
      globals:= LaTeXGlobals;
    elif mode = "HTML" then
      globals:= HTMLGlobals;
    fi;

    return ParseGroupName( gapname, globals );
end;


##############################################################################
##
#F  HTMLHeader( <titlestring>, <stylesheetpath>, <commonheading>, <heading> )
##
##  For three strings <titlestring>, <commonheading>, and <heading>,
##  `HTMLHeader' returns the string that prints as follows.
##  \begintt
##  <?xml version="1.0" encoding="UTF-8"?>
##  
##  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
##           "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
##  
##  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
##  <head>
##  <title>
##  <titlestring>
##  </title>
##  <link rel="stylesheet" type="text/css" href="<stylesheetpath>" />
##  </head>
##  <body>
##  <h5 class="pleft"><span class="Heading">
##  <commonheading>
##  </span></h5>
##  <h3 class="pcenter"><span class="Heading">
##  <heading>
##  </span></h3>
##  \endtt
##
HTMLHeader := function( titlestring, stylesheetpath, commonheading, heading )
    local str;

    str:= "";

    # Append the document type stuff.
    Append( str, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n" );
    Append( str, "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n" );
    Append( str, "         \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\n" );
    Append( str, "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n" );

    # Append the head part, which contains the title.
    Append( str, "<head>\n" );
    Append( str, "<title>\n" );
    Append( str, titlestring );
    Append( str, "\n</title>\n" );
#     "<meta http-equiv=\"content-type\" content=\"text/html; ",
#     "charset=UTF-8\" />\n",
#     "<meta name=\"generator\" content=\"GAPDoc2HTML\" />\n",
    Append( str, "<link rel=\"stylesheet\" type=\"text/css\" href=\"" );
    Append( str, stylesheetpath );
    Append( str, "\" />\n" );
    Append( str, "</head>\n" );

    # Append the body begin, with font specifications.
    Append( str, "<body>\n" );
    Append( str, "<h5 class=\"pleft\"><span class=\"Heading\">" );
    Append( str, commonheading );
    Append( str, "\n</span></h5>\n" );
    Append( str, "<h3 class=\"pcenter\"><span class=\"Heading\">" );
    Append( str, heading );
    Append( str, "\n</span></h3>\n" );

    # Return the result.
    return str;
end;


##############################################################################
##
#F  HTMLFooter( <footertext> )
##
##  Let <datestr> be a string describing the current date,
##  as is returned by `CurrentDateTimeString'.
##  `HTMLFooter' returns the string that prints as follows.
##  \begintt
##
##  <hr/>
##  <p class="foot">File created by GAP on <datestr>.</p>
##
##  </body>
##  </html>
##  \endtt
##
HTMLFooter := function( )
    local date, pos, str;

    date:= CurrentDateTimeString();
    pos:= Position( date, ',' );
    if pos <> fail then
      date:= date{ [ 1 .. pos-1 ] };
    fi;
    str:= "";

    # Append a horizontal line.
    Append( str, "\n<hr/>\n" );

    # Append the line about the file creation.
    Append( str, "<p class=\"foot\">" );
    Append( str, HTMLCompareMark );
    Append( str, date );
    Append( str, ".</p>\n\n" );

    # Append the closing brackets.
    Append( str, "</body>\n" );
    Append( str, "</html>\n" );

    # Return the result.
    return str;
end;


##############################################################################
##
#F  PrintToIfChanged( <filename>, <str> );
##
##  Let <filename> be a filename, and <str> a string.
##  If no file with name <filename> exists or if the contents of the file
##  with name <filename> is different from <str>, up to the ``last changed''
##  line, <str> is printed to the file.
##  Otherwise nothing is done.
#T use this feature also in the decomposition matrices database!
##
PrintToIfChanged := function( filename, str )
    local mark, filenameweb, filenamelocal, oldfile, contents, pos, diffstr,
          diff, out, tmpfile;

    mark:= HTMLCompareMark;

    # Check whether the file exists in the web directory.
    filenameweb:= Filename( HTMLDataDirectory, filename );
    if IsExistingFile( filenameweb ) then

      # Check whether the contents of the file differs from `str'.
      oldfile:= filenameweb;
      contents:= StringFile( filenameweb );
      pos:= PositionSublist( contents, mark );
      if    pos <> fail
         and pos = PositionSublist( str, mark )
         and contents{ [ 1 .. pos-1 ] } = str{ [ 1 .. pos-1 ] } then
        return Concatenation( "unchanged (web server): ", filenameweb );
      fi;

    fi;

    # Check whether the file exists in the local directory.
    filenamelocal:= Filename( HTMLDataDirectoryLocal, filename );
    if IsExistingFile( filenamelocal ) then

      # Check whether the contents of the file differs from `str'.
      oldfile:= filenamelocal;
      contents:= StringFile( filenamelocal );
      pos:= PositionSublist( contents, mark );
      if    pos <> fail
         and pos = PositionSublist( str, mark )
         and contents{ [ 1 .. pos-1 ] } = str{ [ 1 .. pos-1 ] } then
        return Concatenation( "unchanged (local): ", filenamelocal );
      fi;

    fi;

    # The file does not yet exist or the info has changed,
    # so print a new file, and produce a `diff' string if applicable.
    diffstr:= "";
    if IsBound( oldfile ) then
      diffstr:= "\n";
      diff:= Filename( DirectoriesSystemPrograms(), "diff" );
      if diff <> fail and IsExecutableFile( diff ) then
        out:= OutputTextString( diffstr, true );
        SetPrintFormattingStatus( out, false );
        tmpfile:= TmpName();
        FileString( tmpfile, str );
        Process( DirectoryCurrent(), diff, InputTextNone(), out,
                 [ oldfile, tmpfile ] );
        CloseStream( out );
        RemoveFile( tmpfile );
      fi;
    fi;
    FileString( filenamelocal, str );
    return Concatenation( "replaced (local): ", filenamelocal, diffstr );
end;


##############################################################################
##
#F  HTMLStandardTable( <header>, <matrix>, <class>, <alignmentclasses> )
##
#T what about <th> elements?
##
HTMLStandardTable := function( header, matrix, class, alignmentclasses )
    local str, i, ncols, row;

    str:= Concatenation( "<table class=\"", class, "\">\n" );
    if IsList( header ) and not IsEmpty( header ) then
      Append( str, "<tr class=\"firstrow\">\n" );
      for i in [ 1 .. Length( header ) ] do
        Append( str, "<th class=\"" );
        Append( str, alignmentclasses[i] );
        Append( str, "\">" );
        if IsEmpty( header[i] ) then
          Append( str, "&nbsp;" );
        else
          Append( str, header[i] );
        fi;
        Append( str, "</th>\n" );
      od;
      Append( str, "</tr>\n" );
    fi;
    ncols:= Maximum( List( matrix, Length ) );
    for row in matrix do
      Append( str, "<tr>\n" );
      for i in [ 1 .. ncols ] do
        Append( str, "<td class=\"" );
        Append( str, alignmentclasses[i] );
        Append( str, "\">" );
        if not IsBound( row[i] ) or row[i] = "" then
          Append( str, "&nbsp;" );
        else
          Append( str, row[i] );
        fi;
        Append( str, "</td>\n" );
      od;
      Append( str, "</tr>\n" );
    od;
    Append( str, "</table>\n" );

    return str;
end;


##############################################################################
##
#E

