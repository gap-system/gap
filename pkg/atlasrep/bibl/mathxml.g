#############################################################################
##
#W  mathxml.g            GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: mathxml.g,v 1.3 2008/08/20 15:48:22 gap Exp $
##
#Y  Copyright (C)  2008,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some utilities for checking and improving math mode
##  pieces in GAPDoc manuals and BibXMLext format bibliographies.
##
Revision.( "atlasrep/bibl/mathxml_g" ) :=
    "@(#)$Id: mathxml.g,v 1.3 2008/08/20 15:48:22 gap Exp $";


#############################################################################
##
##  1. Check `TextM'.
##
##  This utility is intended to confirm that the function `TextM' does
##  what it is expected to do.
##


#############################################################################
##
#F  CheckTextMForManual( <pathtodoc>, <main>, <files> )
##
##  The arguments are the first three arguments of `MakeGAPDocDoc'
##  and are assumed to describe a GAPDoc document.
##  The return value is a list of pairs `[ <elm>, <tr> ]',
##  where <elm> runs over the `<M>' and `<Math>' elements in the document,
##
CheckTextMForManual:= function( pathtodoc, main, files )
    local doc, tree, melms, i, res;

    doc:= ComposedDocument( "GAPDoc", pathtodoc, main, files, true );
    tree:= ParseTreeXMLString( doc[1], doc[2] );
    melms:= List( Set( List( XMLElements( tree, [ "M", "Math" ] ),
                             x -> StringXMLElement( x )[1] ) ),
                  x -> [ x, TextM( x ) ] );
    return Filtered( melms, x -> x[1] <> x[2] );
end;


#############################################################################
##
#F  CheckTextMForFiles( <files>, <all> )
##
##  The return value is a list of pairs `[ <elm>, <tr> ]',
##  where <elm> runs over the `<M>' and `<Math>' elements in the files in the
##  list <files>,
##  and <tr> is the translation of <elm> by `TextM'.
##
##  If <all> is `true' then all `<M>' and `<Math>' elements are considered,
##  otherwise only those `<M>' and `<Math>' elements for which <tr> differs
##  from <elm>.
##
CheckTextMForFiles:= function( files, all )
    local entitydict, melms, file;

    entitydict:= rec( ndash:= "--",
                      nbsp:= " ",
                    );
    melms:= [];
    for file in files do
      UniteSet( melms,
                List( Set( List( XMLElements( ParseTreeXMLFile( file,
                                                                entitydict ),
                                              [ "M", "Math" ] ),
                                 x -> StringXMLElement( x )[1] ) ),
                      x -> [ x, TextM( x ) ] ) );
    od;
    if all <> true then
      melms:= Filtered( melms, x -> x[1] <> x[2] );
    fi;

    return melms;
end;


#############################################################################
##
##  2. Compute heuristic improvements of `<M>' and `<Math>' elements
##
##  Take `<M>' and `<Math>' elements in GAPDoc and in BibXMLext format
##  documents, and compute improved versions by
##  - normalizing whitespace around \LaTeX macros and brackets,
##  - normalizing (single and double) curly brackets, and
##  - proposing the choice of <M> or <Math>.
##


#############################################################################
##
#F  TreeOfString( <str> )
##
##  takes a string <str> and returns a list representing its bracket
##  structure w.r.t. '{' and '}'.
##
TreeOfString:= function( str )
  local pos, tree, counter, startpos;

  pos:= Position( str, '{' );
  if pos = fail then
    return [ str ];
  elif pos = 1 then
    tree:= [];
  else
    tree:= [ str{ [ 1 .. pos-1 ] } ];
  fi;
  counter:= 0;
  startpos:= pos + 1;
  repeat
    if   str[ pos ] = '{' then
      counter:= counter + 1;
    elif str[ pos ] = '}' then
      counter:= counter - 1;
    fi;
    pos:= pos + 1;
  until counter = 0;
  Add( tree, TreeOfString( str{ [ startpos .. pos-2 ] } ) );
  str:= str{ [ pos .. Length( str ) ] };
  if not IsEmpty( str ) then
    Append( tree, TreeOfString( str ) );
  fi;
  return tree;
end;


#############################################################################
##
#F  StringOfTree( <tree> )
##
##  turns the list returned by `TreeOfString' into a string.
##
StringOfTree:= function( tree )
  local result, entry;

  result:= "";
  for entry in tree do
    if IsString( entry ) then
      Append( result, entry );
    else
      Append( result, "{" );
      Append( result, StringOfTree( entry ) );
      Append( result, "}" );
    fi;
  od;
  return result;
end;


#############################################################################
##
#V  MacrosToForceMElement
##
##  This is used for forcing <M> instead of <Math> although not all \LaTeX
##  macros in the string in question are handled by `TextM'.
##  (The macros in this list are then handled by removing the backslash.)
##
MacrosToForceMElement:= [ "\\sqrt", "\\vert", "\\rm", "\\bf", "\\germ",
                          "\\in", "\\textrm", "\\hat", "\\tilde" ];
#T extend by \pi, \lambda, \Omega, ...


#############################################################################
##
#F  MathElementProposal( <str>, <force_M> )
##
##  Let <str> be a string that occurs as the contents of an <M> or <Math>
##  element.
##  `MathElementProposal' returns a pair `[ <newstr>, <macros> ]' where
##  <newstr> is a str describing the same contents in a nicer way
##  and <macros> is a list of LaTeX macros that occur in <str> (and <newstr>)
##  and that are neither treated specially by `TextM' nor contained in
##  <force_M> (i.e., marked as to be handled best by removing the initial
##  backslash).
##
MathElementProposal:= function( str, force_M )
  local force_single_brackets, addwhitespace, tree, nonM, macros,
        macros2, teststring, ends, bracketnumber, i, cont, res, no,
        postprocess, pair;

  # The macros \{ and \} do not count for the bracket structure.
  # Replace them here and reinsert them in the end.
  str:= ReplacedString( str, "\\{", "OBRACE" );
  str:= ReplacedString( str, "\\}", "CBRACE" );

  # Force single brackets instead of double brackets in cases where the
  # markup will simply be removed for HTML and text version.
  force_single_brackets:= Filtered( RecNames( TEXTMTRANSLATIONS ),
                                    x -> TEXTMTRANSLATIONS.( x ) = "" );
  force_single_brackets:= List( force_single_brackets,
                                x -> Concatenation( "\\", x ) );

  # Insert whitespace behind certain macros treated by `TextM'.
  # (This is necessary if an available bracket gets removed.)
  addwhitespace:= List( [
    "ldots", "mid", "cdot", "ast", "geq", "leq", "neq", "pmod", "bmod",
    "equiv", "rightarrow", "hookrightarrow", "to", "longrightarrow",
    "Rightarrow", "Longrightarrow", "Leftarrow", "iff", "mapsto",
    "leftarrow", "setminus", "times", ], x -> Concatenation( "\\", x ) );

  # Normalize whitespace, analyze the bracket structure.
  str:= NormalizedWhitespace( ReplacedString( str, "\\\n", "" ) );
  tree:= TreeOfString( str );

  # Compute whether all markup is covered by `TextM' replacements.
  nonM:= [];
  macros:= RecNames( TEXTMTRANSLATIONS );
  macros2:= [ ",", ";", "!", "prime" ];

  # Identify macros not covered by `TextM',
  # add whitespace before backslashes, except at the first character.
  teststring:= function( cont )
    local newcont, pos, pos2, cand;

    newcont:= "";
    pos:= Position( cont, '\\' );
    while pos <> fail do
      Append( newcont, cont{ [ 1 .. pos-1 ] } );
      pos2:= pos+1;
      while pos2 <= Length( cont ) and cont[ pos2 ] in LETTERS do
        pos2:= pos2 + 1;
      od;
      while pos2 <= Length( cont ) and cont{[pos+1 .. pos2]} in macros2 do
        pos2:= pos2 + 1;
      od;
      cand:= cont{ [ pos+1 .. pos2-1 ] };
      if not cand in macros then
        # We have found a LaTeX macro not treated specially in <M>.
        AddSet( nonM, Concatenation( "\\", cand ) );
      fi;
      if not cand in macros2 then
        # Insert whitespace before the backslash.
        Add( newcont, ' ' );
      fi;
      Add( newcont, '\\' );
      Append( newcont, cand );
      if cand in addwhitespace then
        # Insert whitespace behind the macro.
        Add( newcont, ' ' );
      fi;
      cont:= cont{ [ pos2 .. Length( cont ) ] };
      pos:= Position( cont, '\\' );
    od;
    Append( newcont, cont );

    # (Do not normalize whitespace, because of leading and trailing blanks!)
    return newcont;
  end;

  ends:= function( obj, sub )
    return IsString( obj ) and Length( obj ) >= Length( sub )
           and obj{ Length( obj ) + [ 1 - Length( sub ) .. 0 ] } = sub;
  end;

  # number of brackets proposed around the i-th entry in tree,
  # where string is the proposed contents
  bracketnumber:= function( tree, i, string )
    local forcedoublebrackets, substring;

    # We need a double bracket after `\sqrt', `\hat', `\widehat', and .
    forcedoublebrackets:= [ "\\sqrt", "\\hat", "\\widehat", "\\tilde" ];

    if   1 < i and ForAny( forcedoublebrackets,
                           x -> ends( tree[ i-1 ], x ) ) then
      # We need a double bracket.
      return 2;
    elif 1 < i and ( ends( tree[ i-1 ], "\\textrm" ) ) then
      # We need no double bracket after `\textrm'.
      return 1;
    elif 1 < i and ( ends( tree[i-1], "_" ) or ends( tree[i-1], "^" ) )
               and Length( string ) = 1 then
      # No bracket is needed at all.
      return 0;
    elif 1 < i and ( ends( tree[i-1], "_" ) or ends( tree[i-1], "^" ) )
               and WidthUTF8String( string ) = 1 then
      # Take one bracket.
      return 1;
    elif IsString( string ) and 1 < Length( string )
         and string[1] = '(' and string[ Length( string ) ] = ')' then
      # No double bracket is needed if the string is enclosed in ().
      return 1;
    elif string{ [ 2 .. Length( string ) ] } in macros
         and string[1] = '\\' then
      # We do not need a double bracket around a single macro that is going
      # to be replaced by one character (or by nothing) in `TextM', e.g. \ast.
      # We need a double bracket if the `TextM' result is at least two
      # characters long.
      if Length( TEXTMTRANSLATIONS.( string{ [ 2 .. Length( string ) ] } ) )
         <= 1 then
        return 1;
      else
        return 2;
      fi;
    fi;

    # Remove markup that will become invisible.
    for substring in force_single_brackets do
      string:= ReplacedString( string, substring, "" );
    od;
    if ForAll( string, x -> IsAlphaChar(x) or IsDigitChar(x) or x = ' ' ) then
      # A single bracket suffices.
      return 1;
    else
      # We need a double bracket.
      return 2;
    fi;
  end;

  for i in [ 1 .. Length( tree ) ] do
    cont:= tree[i];
    if IsString( cont ) then
      res:= teststring( cont );
      tree[i]:= res;
    elif IsString( cont[1] ) and Length( cont ) = 1 then
      # There is a single bracket around a string.
      # (Here we have to strip the leading and trailing whitespace.)
      res:= NormalizedWhitespace( teststring( cont[1] ) );
      no:= bracketnumber( tree, i, res );
      if   no = 2 then
        # Replace the single bracket by a double bracket.
        tree[i]:= [ [ res ] ];
      elif no = 0 then
        # No bracket is needed at all, but add whitespace behind.
        tree[i]:= Concatenation( res, " " );
      else
        # Keep the single bracket.
        tree[i]:= [ res ];
      fi;
    elif not IsString( cont[1] ) and IsString( cont[1][1] )
         and Length( cont ) = 1 and Length( cont[1] ) = 1 then
      # There is a double bracket around a string.
      res:= teststring( cont[1][1] );
      no:= bracketnumber( tree, i, res );
      if   no = 2 then
        # Keep the double bracket.
        tree[i]:= [ [ res ] ];
      elif no = 0 then
        # No bracket is needed at all, but add whitespace.
        tree[i]:= Concatenation( res, " " );
      else
        # Replace the double bracket by a single bracket.
        tree[i]:= [ res ];
      fi;
    else
      # There is a bracket with more complicated contents, recurse.
      if Length( cont ) > 1 then
        # Turn the single bracket into a double bracket.
        res:= MathElementProposal( StringOfTree( cont ), force_M );
        tree[i]:= [ [ res[1] ] ];
        Append( nonM, res[2] );
      else
        # Keep the double bracket.
        res:= MathElementProposal( StringOfTree( cont[1] ), force_M );
        tree[i]:= [ [ res[1] ] ];
        Append( nonM, res[2] );
      fi;
    fi;
  od;

  # Implode the string, perform postprocessing.
  str:= StringOfTree( tree );
  postprocess:= [
    [ "( ", "(" ],
    [ " )", ")" ],
    [ " ^", "^" ],
    [ "^ ", "^" ],
    [ " _", "_" ],
    [ "_ ", "_" ],
    [ "\\ldots ,", "\\ldots," ],
    [ "=", " = " ],
    [ "\\not =", "\\not=" ],
    [ ": =", ":=" ],
    [ "| \\", "|\\" ],
# note: use \mid if you want symmetric space around!
    [ "{ \\", "{\\" ],
    [ "{ {", "{{" ],
    [ "} }", "}}" ],
    [ "OBRACE", "\\{" ],
    [ "CBRACE", "\\}" ],
  ];
  for pair in postprocess do
    str:= ReplacedString( str, pair[1], pair[2] );
  od;
  NormalizeWhitespace( str );

  return [ str, Difference( nonM, force_M ) ];
end;


#############################################################################
##
##  3. Apply the heuristics to files or package manuals
##


#############################################################################
##
#F  StringWithImprovedMathElements( <str>, <force_M> )
##
##  Let <str> be a string containing a part of a file in BibXMLext
##  format (see ``The BibXMLext Format'' in the `gapdoc' manual),
##  and <force_M> be a list as used as an argument of `MathElementProposal'.
##
##  The return value is the string obtained by applying the changes listed
##  by `MathElementProposal'.
##
StringWithImprovedMathElements:= function( str, force_M )
  local newstr, pos1, pos2, pos, tags, cand, res;

  newstr:= "";
  pos1:= PositionSublist( str, "<M>" );
  pos2:= PositionSublist( str, "<Math>" );
  while pos1 <> fail or pos2 <> fail do
    if pos1 <> fail then
      if pos2 <> fail then
        pos:= Minimum( pos1, pos2 );
        if pos = pos1 then
          tags:= [ "<M>", "</M>" ];
        else
          tags:= [ "<Math>", "</Math>" ];
        fi;
        pos2:= PositionSublist( str, tags[2], pos );
        cand:= str{ [ pos + Length( tags[1] ) .. pos2-1 ] };
        Append( newstr, str{ [ 1 .. pos - 1 ] } );
        str:= str{ [ pos2+Length( tags[2] ) .. Length( str ) ] };
        res:= MathElementProposal( cand, force_M );
        if IsEmpty( res[2] ) then
          Append( newstr, Concatenation( "<M>", res[1], "</M>" ) );
        else
          Append( newstr, Concatenation( "<Math>", res[1], "</Math>" ) );
        fi;
      else
        pos:= pos1;
        pos2:= PositionSublist( str, "</M>", pos );
        cand:= str{ [ pos + Length( "<M>" ) .. pos2-1 ] };
        Append( newstr, str{ [ 1 .. pos - 1 ] } );
        str:= str{ [ pos2+Length( "</M>" ) .. Length( str ) ] };
        res:= MathElementProposal( cand, force_M );
        if IsEmpty( res[2] ) then
          Append( newstr, Concatenation( "<M>", res[1], "</M>" ) );
        else
          Append( newstr, Concatenation( "<Math>", res[1], "</Math>" ) );
        fi;
      fi;
    elif pos2 <> fail then
      pos:= pos2;
      pos2:= PositionSublist( str, "</Math>", pos );
      cand:= str{ [ pos + Length( "<Math>" ) .. pos2-1 ] };
      Append( newstr, str{ [ 1 .. pos - 1 ] } );
      str:= str{ [ pos2+Length( "</Math>" ) .. Length( str ) ] };
      res:= MathElementProposal( cand, force_M );
      if IsEmpty( res[2] ) then
        Append( newstr, Concatenation( "<M>", res[1], "</M>" ) );
      else
        Append( newstr, Concatenation( "<Math>", res[1], "</Math>" ) );
      fi;
    fi;
    pos1:= PositionSublist( str, "<M>" );
    pos2:= PositionSublist( str, "<Math>" );
  od;
  Append( newstr, str );

  return newstr;
end;


#############################################################################
##
#F  InfoAboutMathElementsInManual( <pathtodoc>, <main>, <files> )
##
##  The arguments are the first three arguments of `MakeGAPDocDoc'.
##  The returned value is a record that can be shown with
##  `StringInfoAboutMathElementsInManual'.
##
InfoAboutMathElementsInManual:= function( pathtodoc, main, files )
    local doc, tree, melms, unchangedM, unchangedMath, changedM, changedMath,
          melm, melmpos, pos, prop;

    doc:= ComposedDocument( "GAPDoc", pathtodoc, main, files, true );
    tree:= ParseTreeXMLString( doc[1], doc[2] );;
    melms:= List( XMLElements( tree, [ "M", "Math", "Display" ] ),
                  x -> [ StringXMLElement( x )[1],
                         NormalizedWhitespace( GetTextXMLTree( x ) ) ] );
    melms:= DuplicateFreeList( melms );

    unchangedM:= [];
    unchangedMath:= [];
    changedM:= [];
    changedMath:= [];

    for melm in melms do
      melmpos:= [];
      # Find the positions of this element in the source files.
      pos:= PositionSublist( doc[1], melm[1] );
      while pos <> fail do
        Add( melmpos, OriginalPositionDocument( doc[2], pos ) );
        pos:= PositionSublist( doc[1], melm[1], pos );
      od;

      # Try to improve the contents.
      prop:= MathElementProposal( melm[2], MacrosToForceMElement );
      if prop[1] = melm[2] then
        if IsEmpty( prop[2] ) then
          Add( unchangedM, rec( elm:= [ melm[2] ], pos:= melmpos ) );
        else
          Add( unchangedMath, rec( elm:= prop, pos:= melmpos ) );
        fi;
      else
        if IsEmpty( prop[2] ) then
          Add( changedM, rec( elm:= [ melm[2], prop[1] ], pos:= melmpos ) );
        else
          Add( changedMath, rec( elm:= [ melm[2], prop[1], prop[2] ],
                                 pos:= melmpos ) );
        fi;
      fi;
    od;

    return rec( changedMath:= changedMath,
                unchangedMath:= unchangedMath,
                changedM:= changedM,
                unchangedM:= unchangedM );
end;


#############################################################################
##
#F  StringInfoAboutMathElementsInManual( <arec>, <chan>, <kind> )
##
##  returns a string (intended to be shown in a pager) that collects the
##  information for the types <chan> (one of `"changed"', `"unchanged"')
##  and <kind> (one of `"Math"', `"M"') from the record <arec> that has been
##  computed with `InfoAboutMathElementsInManual'.
##
StringInfoAboutMathElementsInManual:= function( arec, chan, kind )
    local str, r, src;

    if   not chan in [ "changed", "unchanged" ] then
      Error( "!" );
    elif not kind in [ "Math", "M" ] then
      Error( "!" );
    fi;

    str:= Concatenation( chan, " <", kind, "> elements:\n" );
    if chan = "changed" then
      for r in arec.( Concatenation( chan, kind ) ) do
        Append( str,
            Concatenation( "'", r.elm[1], "' -> '", r.elm[2], "'\n" ) );
        if IsEmpty( r.pos ) then
          Append( str,
              Concatenation( "  (not found in the source, ",
                             "perhaps due to an entity replacement)\n" ) );
        fi;
        for src in r.pos do
          Append( str,
              Concatenation( "  ", src[1], ", line ", String( src[2] ),
                             "\n" ) );
        od;
      od;
    else
      for r in arec.( Concatenation( chan, kind ) ) do
        Append( str,
            Concatenation( "'", r.elm[1], "'\n" ) );
        if IsEmpty( r.pos ) then
          Append( str,
              Concatenation( "  (not found in the source, ",
                             "perhaps due to an entity replacement)\n" ) );
        fi;
        for src in r.pos do
          Append( str,
              Concatenation( "  ", src[1], ", line ", String( src[2] ),
                             "\n" ) );
        od;
      od;
    fi;

    return str;
end;


#########################################################################
##
#E

