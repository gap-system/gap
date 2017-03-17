#############################################################################
##
#W  gapmacro2gapdoc.g                                           Thomas Breuer
##
##  The GAP code in this file was used to translate some manuals of
##  GAP packages and the main GAP manuals from the `gapmacro.tex' format
##  to GAPDoc format.
##
##  The idea behind the code was that corresponding structures in the two
##  formats can be transformed automatically into each other,
##  and that a working GAPDoc version can be produced with some changes by
##  hand after this automatic part.
##  This code does not take care of all the subtleties of the `gapmacro.tex'
##  format,
##  and of course a lot of GAPDoc features cannot be used by the result of an
##  automatic translation.
##  (Of course, one can extend the ``translation rules'' if one wants.
##  However, the question is whether this is worth the effort.)
##
##  What is *NOT* handled:
##  - Labels used in cross-references must not contain linebreaks and
##    additional whitespace; LaTeX has no problem in these cases, but the
##    HTML converter has.
##    (And also for `grep' it is much easier to look for exact matches;
##    one reason of the bad format is the --in my eyes stupid-- idea to use
##    ``right-justified'' paragraphs in documentation source files.)
##  - `\>' and `\)' lines are not handled correctly (the <ManSection> element
##    is created but no <Description> etc.); indeed the code was written for
##    the situation that the documentation of variables can be found in the
##    code files not in the documentation files.
##  - The documented subtleties concerning \index, \atindex, \indexit,
##    and also the \null magic for suppressing index entries were simply
##    ignored.
##  - The conversion translates text enclosed in singlequotes into
##    <C> elements (and some keywords into <K> elements).
##    Filenames should better be translated into <F> elements,
##    and names of documented GAP variables should better be translated into
##    proper references, using <Ref> elements.
##    Part of this can be translated automatically as soon as proper
##    GAPDoc format has been obtained; but note that in the case of
##    cross-references, usually the formulations must anyhow be adjusted
##    by hand.
##  - <Var> elements denoting info classes should better be turned into
##    <InfoClass> elements.
##  - Comment lines should perhaps be left unchanged,
##    but the replacements are applied also there.
##    is replaced by `<M>...</M>'.)
##  - Function declarations marked with `#F' are not translated correctly
##    when a declaration requires several lines starting with `#F';
##    this happens when there are a long function name and many arguments.
##  - `\FileHeader' constructs are not handled properly;
##    not really a problem since there are not too many of them.
##  - Complicated strings such as `..."..."...' are not handled properly,
##    here we get a <Ref> element; again this is rare and thus harmless.
##  - There are more line breaks than necessary in several situations
##    (and on the other hand missing newlines at file ends).
##  - In several situations, the old manuals mixed up arguments <...> and
##    math mode $...$ --these errors become apparent now and should be fixed.
##  - Lists are translated into <List> elements;
##    <Enum> should be used in several cases.
##  - Some replacements could be added, such as "<A></A>" -> "&tlt;&tgt;"
##    or "\medskip" -> "<P/>" or "{\copyright}" -> "&copyright;" or
##    "{\ss}" -> "ß" or "\accent127", "\'e", "\'o", "\'a", "\'u", "\'A"
##    (with or without braces) to an umlaut or accented character
##    (:digraph in vi).
##
##  These are the proposed steps for translating a manual.
##  
##  1. By hand:
##     Copy the old style `doc/manual.six' file to `doc/manual.six.old'
##     (Note that processing the GAPDoc format manual will create
##     `doc/manual.six' but in GAPDoc format, which is not supported by
##     the functions for switching to GAPDoc.)
##  
##  2. By hand:
##     Create a new main file `main.xml' that will replace
##     the old main file `manual.tex'.
##     (I.e., add entities, and translate
##     \BeginningOfBook{...} -> <Book Name="...">
##     \TitlePage -> <TitlePage>
##     \FrontMatter -> <Bibliography>
##     for chapters: \Input -> <#Include>
##     etc.)
##  
##  3. By hand:
##     Create `makedocrel.g' that will replace `buildman.config'.
##     (Copy it from an existing package that uses GAPDoc;
##     the call to `MakeGAPDocDoc' is the main ingredient.)
##  
##  4. Semi-automatically:
##     Create `doc/*.xml' files from the corresponding `doc/*.msk' files,
##     by calling the function `TranslateMSK2XML' for each `doc/*.msk' file.
## 
##  5. Semi-automatically:
##     Create `lib/*.g*.new' files corresponding to `lib/*.g*' files,
##     by calling the function `TranslateLib2XML' for each relevant
##     `lib/*.g*' file (i.e., a file in `lib' that contains parts of the
##     documentation; these files are listed in `buildman.config').
##     The code in the old and the new file should be unchanged,
##     just the documentation is rewritten.
##     (Test this!)
## 
##  6. Read the file `makedocrel.g', in order to process the documentation
##     with GAPDoc, and correct the errors reported by GAPDoc.
##     (Since the main manuals were translated, GAPDoc was improved a lot
##     w.r.t. debugging, so this should be much easier than it was at the
##     beginning of 2007.)
## 
##  7. By hand:
##     Edit the new files, in order to
##     - improve formulations around <Ref .../>
##       (i.e., replace specifications "Sect" vs. "Func" etc.,
##       change the text where appropriate),
##     - reformat the paragraphs,
##     - fix places that were not handled optimally.
##     Check for `???' in html files, which indicate broken references.
## 
##  8. By hand:
##     Start using GAPDoc's facilities:
##     - insert "Where" in <Cite ... />,
##     - distinguish LaTex/HTML/text objects where appropriate,
##     - introduce math mode in section headers where appropriate,
##     - change the bibliography to the XML based format,
##     - introduce subsections (beyond <ManSection>) for structuring purposes,
##     - ...
## 
##  9. By hand:
##     - Convince yourself that GAP code was not changed by the conversions.
##     - Convince yourself that nothing from the old version of the manual
##       is missing in the GAPDoc version.
##     - Check for `\' characters in the GAPDoc files,
##       they may be relics from TeX markup.
##     - Check for paragraph separators <P/> (too many/missing)
##     - Remove `buildman.config', `doc/manual.six.old',
##       and the `doc/*.msk' files.
##     - Rename the `lib/*.g*.new' files to `lib/*.g*'.
##     - Adjust the `Makefile' if applicable.
##


#############################################################################
##
##  Set some global defaults ...
##

##  ... for package manuals
MY_DOC_DIR:= "doc/";;
CHAPLABELPREFIX:= "";;
SECTLABELPREFIX:= "";;
XMLDIR:= "doc/";;
LIBDIR:= "gap/";;  # or "lib"

##  ... for the main manuals
# MY_DOC_DIR:= "";;
# CHAPLABELPREFIX:= "chap:";;  # (if cross-references are not an issue)
# SECTLABELPREFIX:= "sect:";;  # (if cross-references are not an issue)
# XMLDIR:= "";;
# LIBDIR:= "libnew/";;  # for the reference manual only


#############################################################################
##
##  Define the utilities.
##

GetTagged:= function( arg )
    local str, leftright, avoid_newline, left, right, pos, pos2, res;

	str := arg[1];
	leftright := arg[2];
	if Length(arg) >= 3 then
	  avoid_newline := arg[3];
	else
	  avoid_newline := false;
	fi;
    left:= leftright[1];
    right:= leftright[2];

    pos := 0;
    repeat
      pos:= PositionSublist( str, left, pos );
      if pos = fail then
        return fail;
      fi;
      pos2:= PositionSublist( str, right, pos );
      if pos2 = fail then
        return fail;
      fi;
      res :=
           [ leftright,
             str{ [ 1 .. pos-1 ] },
             str{ [ pos+Length( left ) .. pos2-1 ] },
             str{ [ pos2+ Length( right ) .. Length( str ) ] },
           ];
    until not (avoid_newline and '\n' in res[3]);
    return res;
end;;

KeepInsideUnchanged:= [
    [ [ "\\beginitems", "\\enditems" ] ],
    [ [ "\\beginlist", "\\endlist" ] ],
    [ [ "\\beginexample", "\\endexample" ], [ "<Example><![CDATA[", "]]></Example>" ] ],
    [ [ "\\begintt", "\\endtt" ], [ "<Log><![CDATA[", "]]></Log>" ] ],
    [ [ "\\URL{", "}" ], [ "<URL>", "</URL>" ] ],
  ];;

NormalizedCommentLines:= function( str )
    local normal, newstr, cand;

    normal:= "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    str:= Concatenation( "\n", str, "\n" );
    newstr:= "";
    repeat
      cand:= GetTagged( str, [ "\n<!-- %%%%", "%%%% -->\n" ] );
      if IsList( cand ) then
        if ForAll( cand[3], x -> x = '%' ) then
          Append( newstr,
                  Concatenation( cand[2], "\n<!-- %%%%", normal, "%%%% -->" ) );
        else
          Append( newstr,
                  Concatenation( cand[2], "\n<!-- %%%%", cand[3], "%%%% -->" ) );
        fi;
        str:= Concatenation( "\n", cand[4] );
      fi;
    until cand = fail;
    Append( newstr, str );

    # Cut off the newlines inserted above.
    return newstr{ [ 2 .. Length( newstr ) - 1 ] };
end;

SplitMSKFile:= function( str )
    local parts, cand, min, take;

    parts:= [];

    repeat
      cand:= Filtered( List( KeepInsideUnchanged,
                             x -> GetTagged( str, x[1] ) ), IsList );
      if not IsEmpty( cand ) then
        min:= Minimum( List( cand, x -> Length( x[2] ) ) );
        take:= First( cand, x -> Length( x[2] ) = min );
        Add( parts, rec( type:= "text", text:= take[2] ) );
        Add( parts, rec( type:= take[1], text:= take[3] ) );
        str:= take[4];
      else
        Add( parts, rec( type:= "text", text:= str ) );
        str:= "";
      fi;
    until str = "";

    return parts;
end;

RewriteText:= function( str )
    local replacements, pair, replacementpairs,
          avoid_newline,
          newstr, cand, i, filename,
          prefix, len, cont;

    replacements:= [
        [ "\\<=", "&tlt;=" ],
        [ "`*'", "VERBATIMSTAR" ],
        [ "\\.", "." ],
        [ "<>", "&tlt;&tgt;" ],
      ];

    for pair in replacements do
      str:= ReplacedString( str, pair[1], pair[2] );
    od;

    # remove the path part from FileHeader parts
    repeat
      cand:= GetTagged( str, [ "\\FileHeader", "}" ] );
      if IsList( cand ) then
        newstr:= "";
        Append( newstr, cand[2] );
        Append( newstr, "\\FILEHEADER" );
        if '/' in cand[3] then
          filename:= SplitString( cand[3], "/" );
          prefix:= SplitString( cand[3], "{" )[1];
          Append( newstr, prefix );
          Append( newstr, "{" );
          Append( newstr, filename[ Length( filename ) ] );
        else
          Append( newstr, cand[3] );
        fi;
        Append( newstr, cand[1][2] );
        str:= Concatenation( newstr, cand[4] );
      fi;
    until cand = fail;
    str:= ReplacedString( str, "\\FILEHEADER", "\\FileHeader" );

    replacementpairs:= [
        [ [ "<", ">" ], [ "<A>", "</A>" ] ],
        [ [ "$$", "$$" ], [ "<Display>", "</Display>" ] ],
        [ [ "$", "$" ], [ "<M>", "</M>" ] ],
        [ [ "*", "*" ], [ "<E>", "</E>" ] ],
        [ [ "``", "''" ], [ "<Q>", "</Q>" ] ],
        [ [ "`\\\"", "\\\"'" ], [ "<C><DQUOTE/>", "<DQUOTE/></C>" ] ],
        [ [ "`\"", "\"'" ], [ "<C><DQUOTE/>", "<DQUOTE/></C>" ] ],
        [ [ "\\\"", "\\\"" ], [ "<DQUOTE/>", "<DQUOTE/>" ] ],
        [ [ "`", "'" ], [ "<C>", "</C>" ] ],
        [ [ "\"", "\"" ], [ "<Ref ???=<DQUOTE/>", "<DQUOTE/>/>" ] ],
        [ [ "%", "\n" ], [ "<!-- %", " -->\n" ] ],
        [ [ "\\Chapter{", "}" ], [ Concatenation( "<Chapter Label=<DQUOTE/>", CHAPLABELPREFIX ),
                                   "<DQUOTE/>>\n<Heading>", "</Heading>" ]  ],
        [ [ "\\PreliminaryChapter{", "}" ], [ Concatenation( "<Chapter Label=<DQUOTE/>", CHAPLABELPREFIX ),
                                   "<DQUOTE/>>\n<Heading>", " (preliminary)</Heading>" ]  ],
        [ [ "\\Section{", "}" ], [ Concatenation( "<Section Label=<DQUOTE/>", SECTLABELPREFIX ),
                                   "<DQUOTE/>>\n<Heading>", "</Heading>" ] ],
        [ [ "\\cite{", "}" ], [ "<Cite Key=<DQUOTE/>", "<DQUOTE/>/>" ] ],
        [ [ "\\atindex{", "}{" ], [ "<Index>", "</Index>\\IGNORE{" ] ],
        [ [ "\\IGNORE{", "}" ], [ "<!-- ", " -->" ] ],
        [ [ "\\index{", "}" ], [ "<Index>", "</Index>" ] ],
        [ [ "\\indextt{", "}" ], [ "<Index Key=\"", "\"><C>", "</C></Index>" ] ],

        [ [ "\n\\>", " A\n" ], [ "\n<ManSection>\n<Attr Name=!",
                 "/>\n</ManSection><!-- MOVE DOWN TO THE END -->\n" ], true ],
        [ [ "\n\\>", " P\n" ], [ "\n<ManSection>\n<Prop Name=!",
                 "/>\n</ManSection><!-- MOVE DOWN TO THE END -->\n" ], true ],
        [ [ "\n\\>", " F\n" ], [ "\n<ManSection>\n<Func Name=!",
                 "/>\n</ManSection><!-- MOVE DOWN TO THE END -->\n" ], true ],
        [ [ "\n\\>", " O\n" ], [ "\n<ManSection>\n<Oper Name=!",
                 "/>\n</ManSection><!-- MOVE DOWN TO THE END -->\n" ], true ],
        [ [ "\n\\><C>", "</C> V\n" ], [ "\n<ManSection>\n<Var Name=\"",
                 "\"/>\n</ManSection><!-- MOVE DOWN TO THE END -->\n" ], true ],
        [ [ "\n\\><C>", "</C> I\n" ], [ "\n<ManSection>\n<InfoClass Name=\"",
                 "\"/>\n</ManSection><!-- MOVE DOWN TO THE END -->\n" ], true ],
        [ [ "<Attr Name=!", "(" ], [ "<Attr Name=\"", "\" Arg=!" ], true ],
        [ [ "<Prop Name=!", "(" ], [ "<Prop Name=\"", "\" Arg=!" ], true ],
        [ [ "<Func Name=!", "(" ], [ "<Func Name=\"", "\" Arg=!" ], true ],
        [ [ "<Oper Name=!", "(" ], [ "<Oper Name=\"", "\" Arg=!" ], true ],
        [ [ "Arg=!", ")" ], [ "Arg=§", "$" ], true ],

        [ [ "\\){\\kernttindent}", "\n" ], [ "&nbsp;&nbsp;<C>", "</C>\n" ] ],

        [ [ "\\package{", "}" ], [ "<Package>", "</Package>" ] ],
        [ [ "\\FileHeader", "}" ], [ "<#Include Label=<DQUOTE/>", "}<DQUOTE/>>" ] ],
        [ [ "\\Declaration{", "}" ], [ "<#Include Label=<DQUOTE/>", "<DQUOTE/>>" ] ],
        [ [ "\\Mailto{", "}" ], [ "<Email>", "</Email>" ] ],
        [ [ "\n#T", "\n" ], [ "\n<!--", "-->\n" ] ],
      ]; 

    for pair in replacementpairs do
      newstr:= "";
      repeat
        avoid_newline := false;
        if IsBound(pair[3]) then avoid_newline := pair[3]; fi;
        cand:= GetTagged( str, pair[1], avoid_newline );
        if IsList( cand ) then
          Append( newstr, Concatenation( cand[2], pair[2][1] ) );
          for i in [ 2 .. Length( pair[2] ) ] do
            Append( newstr, cand[3] );
            Append( newstr, pair[2][i] );
          od;
          str:= cand[4];
          # Admit one character overlap.
          len:= Length( newstr );
          if len <> 0 then
            str:= Concatenation( [ newstr[ len ] ], str );
            Unbind( newstr[ len ] );
          fi;
        fi;
      until cand = fail;
      str:= Concatenation( newstr, str );
    od;

    # Strip markup inside `Arg="..."'.
    newstr:= "";
    repeat
      cand:= GetTagged( str, [ "Arg=§", "$" ] );
      if IsList( cand ) then
        Append( newstr, Concatenation( cand[2], "Arg=\"" ) );
        cont:= ReplacedString( cand[3], "<A>", "" );
        cont:= ReplacedString( cont, "</A>", "" );
        Append( newstr, NormalizedWhitespace( cont ) );
        Append( newstr, "\"" );
        str:= cand[4];
        # Admit one character overlap.
        len:= Length( newstr );
        if len <> 0 then
          str:= Concatenation( [ newstr[ len ] ], str );
          Unbind( newstr[ len ] );
        fi;
      fi;
    until cand = fail;
    str:= Concatenation( newstr, str );

    replacements:= [
        [ "<DQUOTE/>", "\"" ],
        [ "{\\GAP}", "&GAP;" ],
        [ "{\\ATLAS}", "&ATLAS;" ],
        [ "{\\MeatAxe}", "&MeatAxe;" ],
        [ "{\\TeX}", "&TeX;" ],
        [ "{\\Polenta}", "&Polenta;" ],
        [ "\\F", "\\mathbb{F}" ],
        [ "\\N", "&NN;" ],
        [ "\\Z", "&ZZ;" ],
        [ "\\Q", "&QQ;" ],
        [ "\\R", "&RR;" ],
        [ "\\C", "&CC;" ],
        [ "~", "&nbsp;" ],
        [ "\n\n", "\n<P/>\n" ],
        [ "{\\accent127 u}", "ü" ],
        [ "{\\accent127 o}", "ö" ],
        [ "{\\accent127 a}", "ä" ],
        [ "VERBATIMSTAR", "<C>*</C>" ],
        [ "<C>true</C>", "<K>true</K>" ],
        [ "<C>false</C>", "<K>false</K>" ],
        [ "<C>fail</C>", "<K>fail</K>" ],
        [ "<C>quit</C>", "<K>quit</K>" ],
        [ "<C>for</C>", "<K>for</K>" ],
        [ "<C>while</C>", "<K>while</K>" ],
    #   [ "%\n", "\n" ],
      ]; 

    for pair in replacements do
      str:= ReplacedString( str, pair[1], pair[2] );
    od;

    return str;
end;;


RewriteItems:= function( str )
    local newstr, pos;

    Add( str, '\n' );
    newstr:= "";
    repeat
      pos:= PositionSublist( str, "&" );
      if pos <> fail then
        Append( newstr, Concatenation( "<Mark>",
                            RewriteText( str{ [ 2 .. pos-1 ] } ),
                            "</Mark>\n<Item>\n" ) );
        str:= str{ [ pos+1 .. Length( str ) ] };
        pos:= PositionSublist( str, "\n\n" );
        if pos <> fail then
          Append( newstr, RewriteText( str{ [ 2 .. pos-1 ] } ) );
          Append( newstr, "\n</Item>\n" );
          str:= str{ [ pos+1 .. Length( str ) ] };
        fi;
      fi;
    until pos = fail;

    return Concatenation( "<List>\n", newstr, "</List>", str );
end;;


RewriteList:= function( str )
    local replacementpairs, newstr, pair, cand, i, pos;

    replacementpairs:= [
        [ [ "\\item{", "}" ], [ "</Item>\n<Mark>", "</Mark>\n<Item>\n" ] ],
      ];

    newstr:= "";
    for pair in replacementpairs do
      repeat
        cand:= GetTagged( str, pair[1] );
        if IsList( cand ) then
          while 0 < Length( cand[2] ) and cand[2][ Length( cand[2] ) ] = '\n' do
            Unbind( cand[2][ Length( cand[2] ) ] );
          od;
          Append( newstr, Concatenation( RewriteText( cand[2] ), "\n",
                                         pair[2][1] ) );
          for i in [ 2 .. Length( pair[2] ) ] do
            Append( newstr, RewriteText( cand[3] ) );
            Append( newstr, pair[2][i] );
          od;
          str:= cand[4];
        fi;
      until cand = fail;
    od;
    str:= Concatenation( newstr, RewriteText( str ) );

    pos:= PositionSublist( str, "</Item>\n" );
    if pos <> fail then
      str:= Concatenation( str{ [ pos+7 .. Length( str ) ] }, "</Item>" );
    fi;
    return Concatenation( "<List>", str, "\n</List>" );
end;;


TranslateText:= function( instr )
    local str, entry, tags;

    str:= "";
    for entry in SplitMSKFile( instr ) do
      if entry.type = "text" then
        # Rewrite only the `text' parts.
        Append( str, RewriteText( entry.text ) );
      else
        tags:= First( KeepInsideUnchanged, x -> x[1] = entry.type );
        if Length( tags ) = 2 then
          Append( str, tags[2][1] );
          Append( str, entry.text );
          Append( str, tags[2][2] );
        elif tags = [ [ "\\beginitems", "\\enditems" ] ] then
          Append( str, RewriteItems( entry.text ) );
        elif tags = [ [ "\\beginlist", "\\endlist" ] ] then
          Append( str, RewriteList( entry.text ) );
        else
          Error( "unknown tags: ", tags );
        fi;
      fi;
    od;
    return NormalizedCommentLines( str );
end;


############################################################################

SplitLibFile:= function( filename )
    local str, parts, lines, pos, partlines, code, line;

    str:= StringFile( filename );

    parts:= [];
    lines:= SplitString( str, "\n" );
    pos:= 1;
    partlines:= [];
    code:= ( lines[1][1] <> '#' );
    for line in lines do
      if ( code and line <> "" and line[1] = '#' ) or
         ( not code and ( line = "" or line[1] <> '#' ) ) then
        Add( parts, rec( code:= code,
          text:= JoinStringsWithSeparator( partlines, "\n" ) ) );
        partlines:= [ line ];
        code:= not code;
      else
        Add( partlines, line );
      fi; 
    od;
    return parts;
end;

TranslatedIndentedText:= function( str )
    local replacementpairs, newstr, pair, cand, i;

    str:= Concatenation( "\n", str, "\n" );

    # turn `#T' lines into comments
    replacementpairs:= [
        [ [ "\n#T", "\n" ], [ "\n##  #T", "\n" ] ],
      ];
    for pair in replacementpairs do
      repeat
        cand:= GetTagged( str, pair[1] );
        if IsList( cand ) then
          newstr:= "";
          Append( newstr, cand[2] );
          Append( newstr, pair[2][1] );
          for i in [ 2 .. Length( pair[2] ) ] do
            Append( newstr, cand[3] );
            Append( newstr, pair[2][i] ); 
          od;
          str:= Concatenation( newstr, cand[4] );
        fi; 
      until cand = fail;
    od;

    # de-indent
    str:= ReplacedString( str, "\n##  ", "\n" );
    str:= ReplacedString( str, "\n## \n", "\n\n" );
    str:= ReplacedString( str, "\n##\n", "\n\n" );
    
    # translate
    str:= str{ [ 2 .. Length( str )-1 ] };
    str:= Concatenation( "\n", TranslateText( str ), "\n" );

    # re-indent
    str:= str{ [ 2 .. Length( str )-1 ] };
    str:= ReplacedString( str, "\n", "\n##  " );
    Add( str, '\n' );
    str:= ReplacedString( str, "\n##  \n", "\n##\n" );
    return str;
end;


RewriteNonCodePart:= function( str, filename )
    local i, pos, newstr, startpos, found, name, min, pos2, pos3, pos4,
          declstr, args, filenameprefix;

    pos:= PositionSublist( filename, ".gd" );
    if pos <> fail then
      filenameprefix:= filename{ [ 1 .. pos-1 ] };
    else
      filenameprefix:= filename;
    fi;
    filenameprefix:= SplitString( filenameprefix, "/" );
    filenameprefix:= filenameprefix[ Length( filenameprefix ) ];

    # Deal with ``FileHeader'' texts (supported are only numbers up to 100).
    for i in Reversed( [ 1 .. 100 ] ) do
      pos:= PositionSublist( str, Concatenation( "\n#", String( i ) ) );
      if pos <> fail then
        newstr:= str{ [ 1 .. pos ] };
        Append( newstr, Concatenation( "##  <#GAPDoc Label=\"[", String( i ),
                                       "]{", filenameprefix, "}\">\n" ) );
        pos:= Position( str, '\n', pos );
        Append( newstr,
            TranslatedIndentedText( str{ [ pos+1 .. Length( str ) ] } ) );
        Append( newstr, "##  <#/GAPDoc>\n" );
        return newstr;
      fi;
    od;

    newstr:= "";
    startpos:= 0;
    found:= false;
    repeat

      # Deal with '#F', '#O', '#A', '#P', '#V', #C, #R.
#T what about #M? and how is `DeclareFilter' marked?
      pos:= [ [ "Func", PositionSublist( str, "\n#F ", startpos ) ],
              [ "Oper", PositionSublist( str, "\n#O ", startpos ) ],
              [ "Attr", PositionSublist( str, "\n#A ", startpos ) ],
              [ "Prop", PositionSublist( str, "\n#P ", startpos ) ],
              [ "Var",  PositionSublist( str, "\n#V ", startpos ) ],

              [ "Category",  PositionSublist( str, "\n#C ", startpos ) ],
              [ "Representation",  PositionSublist( str, "\n#R ", startpos ) ],
            ];
      pos:= Filtered( pos, x -> x[2] <> fail );
      if not IsEmpty( pos ) then
        found:= true;
        min:= Minimum( List( pos, x -> x[2] ) );
        pos:= First( pos, x -> x[2] = min );
        if pos[1] = "Var" then
          # The case '#V' is special because no arguments appear.
          pos2:= PositionSublist( str, "\n", pos[2] );
          Append( newstr, str{ [ startpos+1 .. pos2-1 ] } );
          name:= str{ [ pos[2]+5 .. pos2-1 ] };
          if not IsBound( declstr ) then
            declstr:= Concatenation(
              "\n##\n",
              "##  <#GAPDoc Label=\"", name, "\">\n",
              "##  <ManSection>\n" );
          fi;  
          Append( declstr, Concatenation(
              "##  <Var Name=\"", name, "\"/>\n" ) );
          startpos:= pos2-1;
        elif pos[1] in [ "Category", "Representation" ] then
          # The cases '#C' and '#R' translate into 'Type' attributes.
          pos2:= PositionSublist( str, ")\n", pos[2] );
          if pos2 = fail or pos2 < Position( str, '\n' ) then
            # treat this like '#V' (no arguments)
            pos2:= PositionSublist( str, "\n", pos[2] );
            Append( newstr, str{ [ startpos+1 .. pos2-1 ] } );
            name:= str{ [ pos[2]+5 .. pos2-1 ] };
            if not IsBound( declstr ) then
              declstr:= Concatenation(
                "\n##\n",
                "##  <#GAPDoc Label=\"", name, "\">\n",
                "##  <ManSection>\n" );
            fi;
            Append( declstr, Concatenation(
                "##  <Filt Name=\"", name, "\"/>\n",
                "\" Arg='",
                "obj",
                "' Type='",
                pos[1],
                "'/>\n" ) );
            startpos:= pos2-1;
          else
            pos3:= PositionSublist( str, "(", pos[2] );
            Append( newstr, str{ [ startpos+1 .. pos2 ] } );
            name:= str{ [ pos[2]+5 .. pos3-1 ] };
            args:= ReplacedString( str{ [ pos3+1 .. pos2-1 ] }, "<", "" );
            args:= ReplacedString( args, ">", "" );
            args:= ReplacedString( args, "##", "" );
            if not IsBound( declstr ) then
              declstr:= Concatenation(
                "\n##\n",
                "##  <#GAPDoc Label=\"", name, "\">\n",
                "##  <ManSection>\n" );
            fi;
            Append( declstr, Concatenation(
                "##  <Filt Name=\"", name,
                "\" Arg='",
                NormalizedWhitespace( args ),
                "' Type='",
                pos[1],
                "'/>\n" ) );
            startpos:= pos2;
          fi;
        else
          pos3:= PositionSublist( str, "(", pos[2] );
          if pos3 = fail or pos3 < Position( str, '\n' ) then
            # treat this like '#V' (no arguments)
            pos2:= PositionSublist( str, "\n", pos[2] );
            Append( newstr, str{ [ startpos+1 .. pos2-1 ] } );
            name:= str{ [ pos[2]+5 .. pos2-1 ] };
            if not IsBound( declstr ) then
              declstr:= Concatenation(
                "\n##\n",
                "##  <#GAPDoc Label=\"", name, "\">\n",
                "##  <ManSection>\n" );
            fi;
            Append( declstr, Concatenation(
                "##  <", pos[1], " Name=\"", name, "\"/>\n",
                "\" Arg='",
                "obj",
                "'/>\n" ) );
            startpos:= pos2-1;
          else
            pos2:= PositionSublist( str, ")", pos[2] );
            pos4:= PositionSublist( str, "\n", pos2 );
            Append( newstr, str{ [ startpos+1 .. pos4 ] } );
            name:= str{ [ pos[2]+5 .. pos3-1 ] };
            args:= ReplacedString( str{ [ pos3+1 .. pos2-1 ] }, "<", "" );
            args:= ReplacedString( args, ">", "" );
            args:= ReplacedString( args, "##", "" );
            if not IsBound( declstr ) then
              declstr:= Concatenation(
                "\n##\n",
                "##  <#GAPDoc Label=\"", name, "\">\n",
                "##  <ManSection>\n" );
            fi;
            Append( declstr, Concatenation(
                "##  <", pos[1], " Name=\"", name,
                "\" Arg='",
                NormalizedWhitespace( args ), "'/>\n" ) );
            startpos:= pos2;
          fi;
        fi;
      fi;
    until IsEmpty( pos );
    if found then
      Append( newstr, declstr );
      Append( newstr, "##\n##  <Description>" );
      Append( newstr,
          TranslatedIndentedText( str{ [ pos2+1 .. Length( str ) ] } ) );
      Append( newstr, "##  </Description>\n" );
      Append( newstr, "##  </ManSection>\n" );
      Append( newstr, "##  <#/GAPDoc>\n##" );
      return newstr;
    fi;

    # In other cases (e.g., if '#W' is contained) do nothing.
    return str;
end;


################
    # The following code is copied from `lib/helpbase.gi':
    # read the manual.six file
    # read the first non-empty line to find out the handler for the corresp.
    # manual format (no explicit format implies the "default" handler)
    getdata:= function( six )
      local stream, line, handler;

      if six = fail then
        return fail;
      fi;
      stream := InputTextFile(six);
      line := "";
      while Length(line) = 0 do
        line := ReadLine(stream);
        if line=fail then
          CloseStream(stream);
          return fail;
        fi;
        line := NormalizedWhitespace(line);
      od;
      if Length(line)>10 and line{[1..10]}="#SIXFORMAT" then
        handler := line{[12..Length(line)]};
        NormalizeWhitespace(handler);
      else
        handler := "default";
        RewindStream(stream);
      fi;
      # give up if handler functions are not (yet) loaded
      if not IsBound(HELP_BOOK_HANDLER.(handler)) then
        return fail;
      fi;

      # Compute the label lines, ignore index entries.
      return HELP_BOOK_HANDLER.( handler ).ReadSix( stream );
    end;
################

ReplaceReferences:= function( str )
    local pkgentries, gapdocentries, maindocdir, mainentries, dir, file,
          newstr, pos, pos2, pos3,
          pos4, pos5, bookid, bookname, entries, contents, entry;

    if not IsExistingFile(
               Concatenation( [ MY_DOC_DIR, "manual.six.old" ] ) ) then
      Error( "please copy .../manual.six to .../manual.six.old" );
    fi;
    pkgentries:= getdata( Concatenation( [ MY_DOC_DIR, "manual.six.old" ] ) ).entries;
    gapdocentries:= getdata( Filename( DirectoriesPackageLibrary( "gapdoc",
                                           "doc" ), "manual.six" ) ).entries;
    maindocdir:= DirectoriesLibrary( "doc" );
    mainentries:= rec();
    for dir in [ "ref", "tut", "ext", "prg" ] do
      # Prefer the manual.six.old file (old format) if it is available,
      # currently references using GAPDoc's index files cannot be resolved!
      file:= Filename( maindocdir, Concatenation( dir, "/manual.six.old" ) );
      if file = fail then
        file:= Filename( maindocdir, Concatenation( dir, "/manual.six" ) );
      fi;
      if file <> fail then
        mainentries.( dir ):= getdata( file ).entries;
      fi;
    od;
    newstr:= "";
    repeat
      pos:= PositionSublist( str, "<Ref ???=" );
      if pos <> fail then
        Append( newstr, str{ [ 1 .. pos-1 ] } );
        pos2:= Position( str, '\"', pos );
        pos3:= Position( str, '\"', pos2 );
        pos4:= PositionSublist( str, "/>", pos3 );
        pos5:= Position( str, ':', pos+10 );
        bookid:= "";
        if pos5 <> fail then
          bookid:= str{ [ pos+10 .. pos5-1 ] };
        fi;
        if bookid in RecNames( mainentries ) then
          bookname:= Concatenation( " BookName=\"", bookid, "\"" );
          entries:= mainentries.( bookid );
          pos2:= pos2+4;
        elif bookid = "gapdoc" then
          bookname:= " BookName=\"gapdoc\"";
          entries:= gapdocentries;
          pos2:= pos2+7;
#T better identify arbitrary other books (prefix until `:'),
#T keep a list of entries lists,
#T and load package `manual.six' files on demand
        else
          bookname:= "";
          entries:= pkgentries;
        fi;

        contents:= LowercaseString( str{ [ pos2+1 .. pos3-1 ] } );
        contents:= ReplacedString( contents, "#", " " );
        contents:= NormalizedWhitespace( contents );
        entry:= First( entries, x -> x[2] = contents );
        if entry = fail then
          # Leave the entry unchanged.
          Append( newstr, str{ [ pos .. pos4+1 ] } );
Print( "unidentified reference:\n", str{ [ pos .. pos4+1 ] }, "\n" );
        else
#T this assumes that the `manual.six' file is in *old* format
#T (which is already not true for `gapdoc') ...
          Append( newstr, "<Ref " );
          if   entry[3] = "C" then
            Append( newstr, Concatenation( "Chap=\"", CHAPLABELPREFIX ) );
          elif entry[3] = "S" then
            Append( newstr, Concatenation( "Sect=\"", SECTLABELPREFIX ) );
          elif entry[3] = "F" then
            Append( newstr, "Func=\"" );
          else
            Append( newstr, "????=\"" );
Print( "unidentified reference:\n", str{ [ pos2+1 .. pos3-1 ] }, "\n" );
          fi;
          Append( newstr, str{ [ pos2+1 .. pos3-1 ] } );
          Append( newstr, "\"" );
          Append( newstr, bookname );
          Append( newstr, "/>" );
        fi;
        pos:= pos4+2;
        str:= str{ [ pos .. Length( str ) ] };
      fi;
    until pos = fail;
    Append( newstr, str );
    return newstr;
end;


TranslateMSK2XML:= function( filename )
    local str, pos, normal, size, target;

    str:= TranslateText( StringFile( filename ) );

    # heuristics: add section and chapter ends
    pos:= PositionSublist( str, "<Section" );
    if pos <> fail then
      str:= Concatenation( str{[1..pos]},
                ReplacedString( str{[pos+1..Length(str)]}, "<Section",
                    "</Section>\n<Section" ),
                "</Section>\n" );
    fi;
    Append( str, "</Chapter>\n\n" );

    # Move '</Section>' to a better place.
    normal:= "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    str:= ReplacedString( str,
        Concatenation( "\n<!-- %%%%", normal, "%%%% -->\n</Section>" ),
        Concatenation( "\n</Section>\n\n\n<!-- %%%%", normal, "%%%% -->" ) );

    # Remove '<P/>' immediately following '</Heading>'.
    str:= ReplacedString( str, "</Heading>\n<P/>", "</Heading>\n" );

    # Replace identified references.
    str:= ReplaceReferences( str );

# # Replace unidentified references.
# str:= ReplacedString( str, "????", "Func" );
# str:= ReplacedString( str, "???", "Func" );

    # Print the result to a file.
    size:= SizeScreen();
    SizeScreen( [ 500 ] );
    target:= ReplacedString( filename, ".msk", ".xml" );
    if target = filename then
      target:= ReplacedString( filename, ".tex", ".xml" );
    fi;
    if target = filename then
      target:= Concatenation( filename, ".xml" );
    fi;
target:= SplitString( target, "/" );
target:= Concatenation( XMLDIR, target[ Length( target ) ] );
    PrintTo( target, str );
    SizeScreen( size );
end;


TranslateLib2XML:= function( filename )
    local str, entry, size, target;
 
    str:= "";
    for entry in SplitLibFile( filename ) do
      if str <> "" then
        Append( str, "\n" );
      fi;
      if entry.code then
        Append( str, entry.text );
      else
        Append( str, RewriteNonCodePart( entry.text, filename ) );
      fi;
    od;

    # Replace identified references.
    str:= ReplaceReferences( str );

# # Replace unidentified references.
# str:= ReplacedString( str, "????", "Func" );
# str:= ReplacedString( str, "???", "Func" );

    # Print the result to a file.
    size:= SizeScreen();
    SizeScreen( [ 500 ] );
target:= Concatenation( filename, ".new" );
target:= SplitString( target, "/" );
target:= Concatenation( LIBDIR, target[ Length( target ) ] );
    PrintTo( target, str );
    SizeScreen( size );
end;


Postprocess:= function( filename )
    local str, newstr, cand;

    str:= StringFile( filename );
    newstr:= "";
    repeat
      cand:= GetTagged( str, [ "<Description>", "\n" ] );
      if IsList( cand ) then
        Append( newstr,
                Concatenation( cand[2], "<Description>\n" ) );
        str:= cand[4];
      fi;
    until cand = fail;
    str:= Concatenation( newstr, str );
    str:= ReplacedString( str,
              "##\n##  </Description>",
              "##  </Description>" );
    str:= ReplacedString( str,
              "##  <Description>\n##  <P/>",
              "##  <Description>" );
    PrintTo( filename{ [ 1 .. Length( filename ) - 4 ] }, str );
end;


#############################################################################
##
#E

