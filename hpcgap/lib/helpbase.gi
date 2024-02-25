#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
## The files helpbase.g{d,i} contain the interface between GAP's online help
## and the actual help books.
##

if IsHPCGAP then
  HELP_REGION:=NewSpecialRegion("HELP_REGION");
else
  HELP_REGION:=fail; # dummy placeholder
fi;

#############################################################################
##
#F  # # # # # internal utility functions dealing with strings  # # # # # # #
##

#############################################################################
##
#F  StringStreamInputTextFile( <filename> ) . . . . . . .
##                 content of file as string stream, all '\r' are removed
##
##  This is useful for text files with text to display, because the files
##  can come with UNIX or DOS/Win line breaks.
##  If this turns out to be of general interest, it can be officially
##  documented.
##
InstallGlobalFunction(StringStreamInputTextFile, function(fname)
  local s;
  s := StringFile(fname);
  if s = fail then
    return s;
  fi;
  RemoveCharacters(s,"\r");
  return InputTextString(s);
end);

#############################################################################
##
#F  IsDocumentedWord( <word>[, false ] ) . . . . . . .  check documentation for
#F  <word> in a search string
##
##  Returns 'true' if <word> appears as word in some search string of the help
##  system. By default this is checked case sensitively. If the optional second
##  argument 'false' is given, the check is case insensitive.
##
##  This utility will first be used in some debug tools showing what is newly
##  installed by loading a package. Can be documented if desired.
##
# avoid warning for vars from GAPDoc package
if not IsBound(StripEscapeSequences) then
  StripEscapeSequences := 0;
fi;

BindGlobal( "IsDocumentedWord", function( arg )
  local inid, word, case, simple, cword, book, matches, a, match;

  inid:= Union( CHARS_DIGITS, CHARS_UALPHA, "_", CHARS_LALPHA );
  word := arg[1];
  if Length( arg ) > 1 and arg[2] = false then
    case:= LowercaseString;
  else
    case:= IdFunc;
  fi;
  simple:= SIMPLE_STRING( word );
  cword:= case( word );
  atomic readwrite HELP_REGION do
  for book in HELP_KNOWN_BOOKS[1] do
    matches:= HELP_GET_MATCHES( [ book ], simple, true );
    for a in Concatenation( matches ) do
      match:= case( StripEscapeSequences( a[1].entries[ a[2] ][1] ) );
      if cword in SplitString( match, "", Difference( match, inid ) ) then
        return true;
      fi;
    od;
  od;
  od; # end atomic
  return false;
end);

#############################################################################
##
##  TRANSATL . . . . . . . . . . list of pairs of different spelling patterns
##
##  One could add more patterns following the following rules:
##  - Each element of `TRANSATL' should be a list of length two.
##  - Do not use capital letters; instead, truncate the first letter
##    of the word if might or might not be capitalised.
##  - Usage of patterns where one of spelling variants is an initial
##    substring of another is permitted.
##  - Modification of these rules (or using the patterns where one of
##    spelling variants is the trailing substring of another) may require
##    changing algorithms used in `FindMultiSpelledHelpEntries' and
##    `HELP_SEARCH_ALTERNATIVES'.

BindGlobal( "TRANSATL", MakeImmutable(
            [ [ "atalogue", "atalog" ],
              [ "olour", "olor" ],
              [ "entre", "enter" ],
              [ "isation", "ization" ],
              [ "ise", "ize" ],
              [ "abeling", "abelling" ],
              [ "olvable", "oluble" ],
              [ "yse", "yze" ],
              [ "roebner", "robner"]] ) );


#############################################################################
##
##  HELP_SEARCH_ALTERNATIVES
##
##  This function is used by HELP_GET_MATCHES to check if the search topic
##  might have different spellings, looking for patterns from `TRANSATL'.
##
##  It returns a list of suggested spellings of a string, for example:
##
##  gap> HELP_SEARCH_ALTERNATIVES("TriangulizeMat");
##  [ "TrianguliseMat", "TriangulizeMat" ]
##  gap> HELP_SEARCH_ALTERNATIVES("CentralizerSolvableGroup");
##  [ "CentraliserSolubleGroup", "CentraliserSolvableGroup",
##    "CentralizerSolubleGroup", "CentralizerSolvableGroup" ]
##
##  This approach may suggest wrong spellings for topics containing the
##  substring "Size" or "size", since it's not possible to detect whether
##  "size" is a part of another word or a word itself (e.g. both spellings
##  "emphasize" and  "emphasise" may be used). However, this only creates
##  a tiny and really neglectible overhead (try e.g. `??SizesCentralisers'
##  or `??Centralizers, Normalizers and Intersections'); however it ensures
##  that help searches may be successful even if they use inconsistent
##  spelling. In practice, we expect that the majority of help searches
##  will match no more than one pattern. One could use the utility function
##  `FindMultiSpelledHelpEntries' below to see that the help system contains
##  about a dozen of entries which contains two occurrences of some patterns,
##  and none with three or more of them.
##
##  In addition, it ensures that the search for system setters and testers
##  such as e.g. ?SetIsMapping and ?HasIsMapping will return corresponding
##  attributes and properties. e.g. IsMapping.
##
BindGlobal( "HELP_SEARCH_ALTERNATIVES", function( topic )
local positions, patterns, pattern, where, what, variant, pos,
      newwhere, newwhat, i, chop, begin, topics, shorttopic, r;

positions:=[];
patterns:=[];

# Loop through all spelling patterns to check if there are any matches.
# Record starting positions and data about matching patterns.
atomic readonly HELP_REGION do

for pattern in TRANSATL do
  # for each pattern we record starting positions and data separately
  # to deal with double matches where one variant is a subset of another
  where := [];
  what := [];
  for variant in pattern do
    pos  := POSITION_SUBSTRING( topic, variant, 0 );
    while pos <> fail do
      Add( where, pos );
      Add( what, rec( start   := pos,
                      finish  := pos+Length(variant)-1,
                      variant := variant,
                      pattern := pattern ) );
      pos := POSITION_SUBSTRING( topic, variant, pos+Length(variant) );
    od;
  od;
  if Length(where) > 0 then # we have at least one match
    # now check if we have a double match ( like in "catalogue" and "catalog" )
    if Length( Set( where ) ) = Length( where ) then
      # no double matches, just store the data (SortParallel will be applied later)
      Append( positions, where );
      Append( patterns, what );
    else
      # we have double match - create the new list, taking only the
      # match with the longer substring
      SortParallel( where, what );
      newwhere:=[ where[1] ];
      newwhat:=[ what[1] ];
      for i in [ 2..Length(where)] do
        if where[i]<>where[i-1] then
          Add(newwhere,where[i]);
          Add(newwhat,what[i]);
        else
          if Length( what[i].variant ) > Length( what[i-1].variant ) then
            newwhat[Length(newwhat)]:=what[i];
          fi;
        fi;
      od;
      Append( positions, newwhere );
      Append( patterns, newwhat );
    fi;
  fi;
od;

if Length(positions) > 0 then # matches found
  # sort data about matches accordingly to their positions in `topic'.
  SortParallel( positions, patterns );

  # Now chop the string 'topic' into a list of lists, each of them either
  # a list of all variants from the respective spelling pattern or just
  # a one-element list with the "glueing" string between two patterns or
  # a pattern and the beginning or end of the string.

  chop:=[];
  begin:=1;
  for i in [1..Length(positions)] do
    Add( chop, [ topic{[begin..patterns[i].start-1 ]} ] );
    Add( chop, patterns[i].pattern );
    begin := Minimum( patterns[i].finish, Length(topic) )+1;
  od;

  if begin <= Length( topic ) then
    Add( chop, [ topic{[begin..Length(topic)]} ] );
  fi;

  # Take the cartesian product of 'chop' and form spelling suggestions
  # as concatenations of its elements.

  topics := List( Cartesian(chop), Concatenation );

else # no matches

  topics := [ topic ];

fi;

r := [];

# This ensures that e.g. `?HasIsMapping` will show `IsMapping` even if only the
# latter is documented. It is guaranteed that the help system will send search
# terms in lowercase. The requirement of the search term to have the length at
# least 5 and do not have a space after "has" or "set" is essential: it prevents
# "set stabiliser", "hash", "sets", "SetX" etc. to be handled in the same way.
for topic in topics do
  if Length(topic) > 4 and topic{[1..3]} in [ "has" , "set" ] and topic[4]<>' ' then
    shorttopic := topic{[4..Length(topic)]};
    Append( r, [ shorttopic,
                 Concatenation( "has", shorttopic),
                 Concatenation( "set", shorttopic) ] );
  else
    Add(r, topic );
  fi;
od;

Sort( r );
return( r );

od; # end atomic

end);


#############################################################################
##
#F  FindMultiSpelledHelpEntries() . . . . . . check documentation for entries
##                             which might have 2 or more different spellings
##
##  This utility may be used in checks of the help system by GAP developers.
##
##  `HELP_GET_MATCHES' uses `HELP_SEARCH_ALTERNATIVES' to look for other possible
##  spellings, e.g. Normaliser/Normalizer, Center/Centre, Solvable/Soluble,
##  Analyse/Analyze, Factorisation/Factorization etc.
##
##  "FindMultiSpelledHelpEntries" reports help entries that contains more
##  than one occurrence of spelling patterns from the `TRANSATL' list.
##  It may falsely report entries containing the substring "Size" or "size",
##  since it's not possible to detect whether "size" is a part of another
##  word or a word itself (e.g. both spellings "emphasize" and  "emphasise"
##  may be used).
##
BindGlobal( "FindMultiSpelledHelpEntries", function( )
local report, pair, word, book, matches, a, match, patterns, i, j, w, pos, nr, hits;
report:=[];
atomic readwrite HELP_REGION do
for pair in TRANSATL do
  word := pair[1];
  for book in HELP_KNOWN_BOOKS[1] do
    matches:= HELP_GET_MATCHES( [ book ], word, false );
    for a in Concatenation( matches ) do
      match:= StripEscapeSequences( a[1].entries[ a[2] ][1] );
      patterns:=[];
      for i in [1..Length(TRANSATL)] do
        patterns[i]:=[];
        for j in [1..Length(TRANSATL[i])] do
          w:=TRANSATL[i][j];
          nr:=0;
          pos := POSITION_SUBSTRING( match, w, 0 );
          while pos <> fail do
            nr:=nr+1;
            pos := POSITION_SUBSTRING( match, w, pos+Length(w) );
          od;
        patterns[i][j]:=nr;
        od;
      od;
      # we just check that there are two or more matches, but in principle
      # we calculated all to distinguish between different cases: different
      # patterns; different spellings of same pattern; same spelling of
      # same pattern appears more than once.
      hits := Sum(Flat(patterns));
      if hits >= 1 then
        AddSet( report, MakeImmutable([ hits, book, match ]) );
      fi;
    od;
  od;
od;
return report;
od; # end atomic
end);

if StripEscapeSequences = 0 then
  Unbind(StripEscapeSequences);
fi;


#############################################################################
##
#F  MATCH_BEGIN( <a>, <b> )
##
##  tries to match beginning of words, where words are separated by single
##  spaces; return `true' or `false'.
##
##  No form of  normalization is applied to  <a> or <b>, so this  should be done
##  before calling MATCH_BEGIN.
##
InstallGlobalFunction(MATCH_BEGIN, atomic function( readonly a, readonly b )
    local p,q;

    if Length(a)=0 and Length(b)=0 then
      return true;
    fi;

##      if 0 = Length(b) or Length(a) < Length(b)  then
    if Length(a) < Length(b)  then
        return false;
    fi;

    p:=Position(b,' ');
    if p=fail then
      return a{[1..Length(b)]} = b;
    else
      q:=Position(a,' ');
      if q=fail then
        q:=Length(a)+1;
      fi;
      # cope with blanks
      return MATCH_BEGIN(a{[1..q-1]},b{[1..p-1]}) and
             MATCH_BEGIN(a{[q+1..Length(a)]},b{[p+1..Length(b)]});
    fi;

end);

# Slight variant: returns -1 on false and number of exact matching
# words on true (>=0). Can be used to rank some matches higher.
InstallGlobalFunction(MATCH_BEGIN_COUNT, function( a, b )
  local p, q, r;

  if Length(a)=0 and Length(b)=0 then
    return 0;
  fi;

  if Length(a) < Length(b)  then
      return -1;
  fi;

  p:=Position(b,' ');
  if p=fail then
    p:=Position(a,' ');
    if p<>fail then
      a:=a{[1..p-1]};
    fi;
    if Length(b)<=Length(a) and a{[1..Length(b)]} = b then
      if Length(a)= Length(b) then
        return 1;
      else
        return 0;
      fi;
    else
      return -1;
    fi;
  else
    q:=Position(a,' ');
    if q=fail then
      q:=Length(a)+1;
    fi;
    # cope with blanks
    if MATCH_BEGIN(a{[1..q-1]},b{[1..p-1]}) then
      r := MATCH_BEGIN_COUNT(a{[q+1..Length(a)]},b{[p+1..Length(b)]});
      if r >= 0 then
        if p = q then
          return 1+r;
        else
          return 0;
        fi;
      else
        return -1;
      fi;
    else
      return -1;
    fi;
  fi;
end);


#############################################################################
##
#F  FILLED_LINE( <left>, <right>, <fill> )
##
##  return string starting with string <left>, a number of characters <fill>
##  and ending with string <right> 6 characters before end of screen.
##
InstallGlobalFunction(FILLED_LINE, function( l, r, f )
    local   w,  n;

    w := SizeScreen()[1] - 8;
    if w < 8  then
        return "";
    fi;
    if w-7 < Length(l)  then
        l := Concatenation( l{[1..w-7]}, "..." );
    fi;
    if w-7 < Length(r)  then
        r := Concatenation( r{[1..w-7]}, "..." );
    fi;
    if w-7 < Length(l) + Length(r)  then
        r := Concatenation( r{[1..w-7-Length(l)]}, "..." );
    fi;

    w := w - Length(l) - Length(r);
    n := ShallowCopy(l);
    Add( n, ' ' );
    while 0 < w  do
        Add( n, f );
        w := w - 1;
    od;
    Add( n, ' ' );
    Append( n, r );

    return n;

end);

InstallGlobalFunction(SIMPLE_STRING, function(str)
  local trans;
  # we simply list here in Position i how character i-1 should be translated
  trans :=Concatenation(
"\000\>\<\c\004\005\006\007\b\t\n\013\014\r\016\017\020\021\022\023\024\025",
"\026\027\030\031\032\033\034\035\036\037 !\000   &\000  *+ -./",
"0123456789: <=>? abcd",
"efghijklmnopqrstuvwxyz[\000]^_\000abcdefghijklmnopqrstuvwxyz{ }~",
"\177\200\201\202",
"\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225",
"\226\227\230\231\232\233\234\235\236\237\240",
"\241\242\244\244\246\246\250\250\251\252\253\254\255\256\257\260\261\262",
"\264\264\265\266\270\270\271\272\276\276\276\276\277aaaaaa",
"aceeeeiiiidnooooo\327ouuuuypsaaaaaaaceeeeiiiidnooooo\367ouuuuypy"
);

  CONV_STRING(str);
  str := trans{List(str, INT_CHAR) + 1};
  # we throw away zero characters (and so backslashes and quotes)
  str := Filtered(str,x->x<>'\000');
  NormalizeWhitespace(str);
  return str;
end);


#############################################################################
##
##  Each book for GAP's help system  has to be initialized by entries in
##  HELP_KNOWN_BOOKS. These contain a short name (a single word), a long
##  name and the directory of the documentation.
##
##  For  the   main  books   of  the  GAP   library  this   is  included
##  here,   for    packages   these   initializations   are    done   by
##  `LoadPackageDocumentation'.
##
##  In the  path for a  help book  there must be   a file `manual.six'. It
##  contains the  indexing information used for  the search of  a topic in
##  the GAP help. The  format of the file is  not prescribed. But if it is
##  different from the current GAP  library documentation format then  the
##  first line must be
##
##  #SIXFORMAT myownformat
##
##  Then a  function HELP_BOOK_HANDLER.myownformat.ReadSix is used to read
##  the rest of the file. (See HELP_BOOK_HANDLER below.)
##
# in first list: normalized names of books
# in second list: for each book a list
#                 [short name, long name,
#                  directory containing the manual.six file]
BindGlobal("HELP_KNOWN_BOOKS", [[],[]]);
if IsHPCGAP then
  LockAndMigrateObj(HELP_KNOWN_BOOKS,HELP_REGION);
fi;

# if book with normalized name is already installed, we overwrite, if dir
# is the same (so short and long can be changed)
# or if short corresponds to an installed "(not loaded)" version,
# else we raise an error
# dir can be given as string relative to GAP's home or as directory object


InstallGlobalFunction(HELP_ADD_BOOK, function( short, long, dir )
  local sortfun, str, hnb, pos;
  # we sort books with main books first and packages alphabetically,
  # (looks a bit lengthy)
atomic readwrite HELP_REGION do
  sortfun := function(a, b)
    local main, pa, pb;
    main := ["tutorial", "reference", "hpc-gap", "development" ];
    pa := Position(main, a);
    pb := Position(main, b);
    if pa <> fail then
      if pb = fail then
        return true;
      else
        return pa <= pb;
      fi;
    else
      if pb <> fail then
        return false;
      else
        return a < b;
      fi;
    fi;
  end;
  str := SIMPLE_STRING(short);
  hnb := HELP_KNOWN_BOOKS;
  # check if we reinstall a known book (with possibly other names)
  pos := First([1..Length(hnb[2])], i-> dir = hnb[2][i][3]);
  if not (Position(hnb[1], str) in [fail, pos]) then
    Info(InfoWarning, 1, "Overwriting already installed help book '",str,"'.");
    Unbind(HELP_BOOKS_INFO.(str));
    pos := Position(hnb[1], str);
  fi;
  if pos = fail then
    # Perhaps we want to replace a "(not loaded)" book by another one.
    pos:= Position( hnb[1], Concatenation( str, " not loaded" ) );
    if pos = fail then
      pos := Length(hnb[1]) + 1;
    else
      Unbind(HELP_BOOKS_INFO.(hnb[1][pos]));
    fi;
  elif IsBound(HELP_BOOKS_INFO.(hnb[1][pos])) then
    # rename help book info if already loaded
    HELP_BOOKS_INFO.(str) := HELP_BOOKS_INFO.(hnb[1][pos]);
    # adjust .bookname
    HELP_BOOKS_INFO.(str).bookname := short;
    Unbind(HELP_BOOKS_INFO.(hnb[1][pos]));
  fi;
  hnb[1][pos] := MigrateObj(str,HELP_REGION);
  hnb[2][pos] := MigrateObj([short, long, dir],HELP_REGION);
  SortParallel(hnb[1], hnb[2], sortfun);
od;   # end atomic
end);


InstallGlobalFunction(HELP_REMOVE_BOOK, function( short )
  local str, pos;

atomic readwrite HELP_REGION do
  str := SIMPLE_STRING(short);
  pos := Position(HELP_KNOWN_BOOKS[1], str);
  if pos = fail then
    Error("Book with normalized name ", str, " is not installed.");
  else
    Remove (HELP_KNOWN_BOOKS[1], pos);
    Remove (HELP_KNOWN_BOOKS[2], pos);
    Unbind (HELP_BOOKS_INFO.(str));
  fi;
od; # end atomic
end);


#############################################################################
##
#V  HELP_BOOK_HANDLER
##
##  We use a record to store handler for different tasks with a help book.
##  The handler  for  the current  library books  is called "default".   A
##  handler is a record with some  functions as components, at least there
##  must be:
##
##  - ReadSix          # reading a BOOK_INFO from a manual.six stream
##  - ShowChapters     # returns text or lines with chapter headers
##  - ShowSections     # same for section headers
##  - SearchMatches    # returns list of numbers referring to entries in
##                     # BOOK_INFO's .entries list
##  - MatchPrevChap    # number of match for "<<" (last in HELP_LAST.BOOK
##  - MatchNextChap    # number of match for ">>"  and HELP_LAST.MATCH)
##  - MatchPrev        # number of match for "<"
##  - MatchNext        # number of match for ">"
##  - HelpData         # returns for given number of entry in .entries the
##                     # corresponding help data for a given format
##                     # (a special format is "ref" for cross references,
##                     # see HELP_BOOK_HANDLER.HelpDataRef below for
##                     # details)
##  The `default' handler functions will be assigned helpdef.g, see there for
##  more details on the interfaces of each of these functions.
##
BindGlobal("HELP_BOOK_HANDLER", AtomicRecord(rec(default:=rec())));
if IsHPCGAP then
  LockAndMigrateObj(HELP_BOOK_HANDLER,HELP_REGION);
fi;

#############################################################################
##
#V  HELP_BOOKS_INFO . . . . . . . . . . . . .  collected info about the books
##
##  The record <HELP_BOOKS_INFO>  contains for each loaded  help book an
##  entry  describing the  information found  in the  "manual.six" file.
##  This information is  stored in a record with at  least the following
##  components, which are used by this generic interface to the help system:
##
##  bookname:
##
##    The short name of the book, e.g. "ref", "matrix", "EDIM".
##
##  entries:
##
##    List of entries for the  search, each entry must  be a list. In  the
##    first position there must be a string which is shown for this match,
##    in case several matches for a topic where found.
##
##  formats: (not necessary ???)
##
##    List of output formats available for this book (like ["text", "url", ..]),
##    this must contain at least "text".
##
##  The  remaining positions  in    the  .entries lists and/or     further
##  components  in  this help  book record  depend  on  the format  of the
##  documentation and the corresponding handler functions.
##
BindGlobal("HELP_BOOKS_INFO", rec());
if IsHPCGAP then
  LockAndMigrateObj(HELP_BOOKS_INFO,HELP_REGION);
fi;

#############################################################################
##
#F  HELP_BOOK_INFO( <book> )  . . . . . . . . . . . . . get info about a book
##
##  Returns  the  corresponding HELP_BOOKS_INFO  entry  or  reads  in  the
##  corresponding manual.six file, if not yet done.
##
##  <book> must be a record, which is just returned, or the short name of a
##  known book.
##
InstallGlobalFunction(HELP_BOOK_INFO, function( book )
  local pos, bnam, path, dirs, six, stream, line, handler;

  # if this is already a record return it
  if IsRecord(book)  then
    return book;
  fi;

atomic readwrite HELP_REGION do

  book := LowercaseString(book);
  pos := Position(HELP_KNOWN_BOOKS[1], book);
  if pos = fail  then
    # try to match beginning
    pos := Filtered(HELP_KNOWN_BOOKS[1], bn-> MATCH_BEGIN(bn, book));
    if Length(pos) = 0 then
      # give up
      return fail;
    else
      pos := Position(HELP_KNOWN_BOOKS[1], pos[1]);
    fi;
  fi;
  # now we have the (short) name of the book
  bnam := HELP_KNOWN_BOOKS[1][pos];

  if IsBound(HELP_BOOKS_INFO.(bnam)) then
    # done
    return HELP_BOOKS_INFO.(bnam);
  fi;

  # get the filename of the "manual.six" file
  path := HELP_KNOWN_BOOKS[2][pos][3];
  if IsDirectory(path) then
    dirs := [path];
  else
    dirs := DirectoriesLibrary( path );
  fi;

  six  := Filename( dirs, "manual.six" );
  if six = fail  then
    # give up
    return fail;
  fi;

  # read the manual.six file
  # read the first non-empty line to find out the handler for the corresponding
  # manual format (no explicit format implies the "default" handler)
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
    Print("\n#W WARNING: No handler for help book `",
          HELP_KNOWN_BOOKS[2][pos][1],
          "' available,\n#W removing this book.\n");
    if handler = "GapDocGAP" then
      Print("#W HINT: Install and load the GAPDoc package, see\n",
            "#W http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc\n");
    fi;
    HELP_KNOWN_BOOKS[1][pos] := Concatenation("XXXX ", bnam, ": THROWN OUT");
    HELP_KNOWN_BOOKS[2][pos][2] := "NOT AVAILABLE (no handler)";
    return fail;
  fi;
  HELP_BOOKS_INFO.(bnam) := MigrateObj(HELP_BOOK_HANDLER.(handler).ReadSix(stream),HELP_REGION);

  # adjust some entries used on the interface level
  HELP_BOOKS_INFO.(bnam).handler := MigrateObj(handler,HELP_REGION);
  HELP_BOOKS_INFO.(bnam).bookname := HELP_KNOWN_BOOKS[2][pos][1];

  # done
  return HELP_BOOKS_INFO.(bnam);
od; # end atomic
end);

#############################################################################
##
##
#F  # # # # # # # # # # generic show functions  # # # # # # # # # # # # # # #
##

#############################################################################
##
##  The central  function for the help  system is, of course,  `HELP' below.
##  Depending on  the search  string it may  trigger different  actions. The
##  functions for these actions are defined first. Many of them delegate the
##  actual work to the handler functions for the available books.
##



#############################################################################
##
#F  HELP_SHOW_BOOKS( ignored... ) . . . . . . . . . . .  show available books
##
InstallGlobalFunction(HELP_SHOW_BOOKS, function( arg )
  local books;
atomic readonly HELP_REGION do

  books := ["             Table of currently available help books",
            FILLED_LINE( "short name for ? commands", "Description", '_')];
  Append(books, List(HELP_KNOWN_BOOKS[2], a-> FILLED_LINE(a[1], a[2], ' ')));
  Pager(books);
  return true;

od; # end atomic
end);

#############################################################################
##
#F  HELP_SHOW_CHAPTERS( <book> )  . . . . . . . . . . . . . show all chapters
##
InstallGlobalFunction(HELP_SHOW_CHAPTERS, function(book)
  local info;
atomic HELP_REGION do
  # delegate to handler
  info := HELP_BOOK_INFO(book);
  if info = fail then
    Print("#W Help: Book ", book, " not found.\n");
  else
    HELP_LAST.BOOK := book;
    HELP_LAST.MATCH := 1;
    Pager(HELP_BOOK_HANDLER.(info.handler).ShowChapters(info));
  fi;
  return true;
od; # end atomic
end);

#############################################################################
##
#F  HELP_SHOW_SECTIONS( <book> )  . . . . . . . . . . . . . show all sections
##
InstallGlobalFunction(HELP_SHOW_SECTIONS, function(book)
  local info;
atomic HELP_REGION do
  # delegate to handler
  info := HELP_BOOK_INFO(book);
  if info = fail then
    Print("#W Help: Book ", book, " not found.\n");
  else
    HELP_LAST.BOOK := book;
    HELP_LAST.MATCH := 1;
    Pager(HELP_BOOK_HANDLER.(info.handler).ShowSections(info));
  fi;
  return true;
od; # end atomic
end);

#############################################################################
##
#F  HELP_PRINT_MATCH( <match> ) . . . . . . the core function which finally
##  gets the data for displaying the help and displays it
##
##  <match> is [book, entrynr]
##
InstallGlobalFunction(HELP_PRINT_MATCH, function(match)
  local book, entrynr, viewer, hv, pos, type, data;
atomic readonly HELP_REGION do
  book := HELP_BOOK_INFO(match[1]);
  entrynr := match[2];
  viewer:= UserPreference("HelpViewers");
  if HELP_LAST.NEXT_VIEWER = false then
    hv := viewer;
  else
    pos := Position( viewer, HELP_LAST.VIEWER );
    if pos = fail then
      hv := viewer;
    else
      hv := viewer{Concatenation([pos+1..Length(viewer)],[1..pos])};
    fi;
    HELP_LAST.NEXT_VIEWER := false;
  fi;
  for viewer in hv do
    # type of data we need now depends on help viewer
    type := HELP_VIEWER_INFO.(viewer).type;
    # get the data via appropriate handler
    data := HELP_BOOK_HANDLER.(book.handler).HelpData(book, entrynr, type);
    if data <> fail then
      # show the data
      HELP_VIEWER_INFO.(viewer).show(data);
      break;
    fi;
    HELP_LAST.VIEWER := viewer;
  od;
  HELP_LAST.BOOK := book;
  HELP_LAST.MATCH := entrynr;
  HELP_LAST.VIEWER := viewer;
  return true;
od; # end atomic
end);

#############################################################################
##
#F  HELP_SHOW_PREV_CHAPTER( <book> ) . . . . . . . . show chapter introduction
##
InstallGlobalFunction(HELP_SHOW_PREV_CHAPTER, function( arg )
  local   info,  match;
  if HELP_LAST.BOOK = 0 then
    Print("Help: no history so far.\n");
    return;
  fi;
  info := HELP_BOOK_INFO(HELP_LAST.BOOK);
  match := HELP_BOOK_HANDLER.(info.handler).MatchPrevChap(info,
                   HELP_LAST.MATCH);
  if match[2] = fail then
    Print("Help:  no match found.\n");
  else
    HELP_PRINT_MATCH(match);
    HELP_LAST.MATCH := match[2];
  fi;
end);

#############################################################################
##
#F  HELP_SHOW_NEXT_CHAPTER( <book> )  . . . . . . . . . . . show next chapter
##
InstallGlobalFunction(HELP_SHOW_NEXT_CHAPTER, function( arg )
  local   info,  match;
  if HELP_LAST.BOOK = 0 then
    Print("Help: no history so far.\n");
    return;
  fi;
  info := HELP_BOOK_INFO(HELP_LAST.BOOK);
  match := HELP_BOOK_HANDLER.(info.handler).MatchNextChap(info,
                   HELP_LAST.MATCH);
  if match[2] = fail then
    Print("Help:  no match found.\n");
  else
    HELP_PRINT_MATCH(match);
    HELP_LAST.MATCH := match[2];
  fi;
end);

#############################################################################
##
#F  HELP_SHOW_PREV( <book> )  . . . . . . . . . . . . . show previous section
##
InstallGlobalFunction(HELP_SHOW_PREV, function( arg )
  local   info,  match;
  if HELP_LAST.BOOK = 0 then
    Print("Help: no history so far.\n");
    return;
  fi;
  info := HELP_BOOK_INFO(HELP_LAST.BOOK);
  match := HELP_BOOK_HANDLER.(info.handler).MatchPrev(info,
                   HELP_LAST.MATCH);
  if match[2] = fail then
    Print("Help:  no match found.\n");
  else
    HELP_PRINT_MATCH(match);
    HELP_LAST.MATCH := match[2];
  fi;
end);

#############################################################################
##
#F  HELP_SHOW_NEXT( <book> )  . . . . . . . . . . . . . . . show next section
##
InstallGlobalFunction(HELP_SHOW_NEXT, function( arg )
  local   info,  match;
  if HELP_LAST.BOOK = 0 then
    Print("Help: no history so far.\n");
    return;
  fi;
  info := HELP_BOOK_INFO(HELP_LAST.BOOK);
  match := HELP_BOOK_HANDLER.(info.handler).MatchNext(info,
                   HELP_LAST.MATCH);
  if match[2] = fail then
    Print("Help:  no match found.\n");
  else
    HELP_PRINT_MATCH(match);
    HELP_LAST.MATCH := match[2];
  fi;
end);

#############################################################################
##
#F  HELP_SHOW_WELCOME( <book> ) . . . . . . . . . . . .  show welcome message
##
InstallGlobalFunction(HELP_SHOW_WELCOME, function( book )
    local   lines;

    lines := [
"    Welcome to GAP 4\n",
" Try '?tutorial: The Help system' (without quotes) for an introduction to",
" the help system.\n",
" '?chapters' and '?sections' will display tables of contents."
    ];
    Pager(lines);
    return true;
end);


#############################################################################
##
#F  HELP_GET_MATCHES( <book>, <topic>, <frombegin> )  . . .  search through
#F  the books
##
##  This function returns a list of two lists [exact, match] and these lists
##  consist of  pairs [book,  entrynumber], where  book is  a help  book and
##  entrynumber is the number of a  match in book.entries. As the names say,
##  the  first list  "exact"  contains  the exact  matches  and "match"  the
##  remaining ones.
##
InstallGlobalFunction(HELP_GET_MATCHES, function( books, topic, frombegin )
  local exact, match, em, b, x, topics, getsecnum;
atomic readwrite HELP_REGION do

  # First we try to produce some suggestions for possible different spellings
  # (see the global variable 'TRANSATL' for the list of spelling patterns).
  if topic = "size" then # "size" is a notable exception (lowercase is guaranteed)
    topics:=[ topic ];
  else
    topics:=HELP_SEARCH_ALTERNATIVES( topic );
  fi;

  # <exact> and <match> contain the topics matching
  exact := [];
  match := [];

  if IsString(books) or IsRecord(books) then
    books := [books];
  fi;

  # collect the matches (by number)
  books := List(books, HELP_BOOK_INFO);
  for b in books do
    for topic in topics do
      # now delegate the work to the handler functions
      if b<>fail then
        em := HELP_BOOK_HANDLER.(b.handler).SearchMatches(b, topic, frombegin);
        for x in em[1] do
          Add(exact, [b, x]);
        od;
        for x in em[2] do
          Add(match, [b, x]);
        od;
      fi;
    od;
  od;

  # we now join the two lists, this way the exact matches are displayed
  # first in case of multiple matches
  # Note: before GAP 4.5 this was only done in case of substring search.
  match := Concatenation(exact, match);
  exact := [];

  # check if all matches point to the same subsection of the same book,
  # in that case we only keep the first match which then will be displayed
  # immediately

  # this function makes sure that nothing breaks if the help book handler
  # has no support for SubsectionNumber
  getsecnum := function(m)
    if IsBound(HELP_BOOK_HANDLER.(m[1].handler).SubsectionNumber) then
      return HELP_BOOK_HANDLER.(m[1].handler).SubsectionNumber(m[1], m[2]);
    else
      return m[2];
    fi;
  end;
  if Length(match) > 1 and Length(Set(match,
                            m-> [m[1].bookname,getsecnum(m)])) = 1 then
    match := [match[1]];
  fi;

  return [exact, match];
od; # end atomic
end);


#############################################################################
##
#F  InitialSubstringUTF8Text( <str>, <cols> )
##
##  This is a utility that extends the GAPDoc function
##  <C>InitialSubstringUTF8String</C>, which deals with strings containing
##  unicode characters but does not deal with escape sequences, i.e.,
##  sequences starting with ESC and stopping with the first letter
##  afterwards).
##  Note that the text version of GAPDoc manuals contains both
##  unicode characters and escape sequences.
##
##  <Ref Func="InitialSubstringUTF8Text"/> returns a string that is the
##  longest prefix of the string <A>str</A> that has visible/printed length
##  at most <A>cols</A> and contains all escape sequences from <C>str</C>.
##

# The following global variables will be defined via the GAPDoc package.
# We assign them here (and unbind them later on) in order to avoid syntax
# warnings.
if not IsBound( InitialSubstringUTF8String ) then
  InitialSubstringUTF8String:= "dummy";
fi;
if not IsBound( LETTERS ) then
  LETTERS:= "dummy";
fi;
if not IsBound( WidthUTF8String ) then
  WidthUTF8String:= "dummy";
fi;

BindGlobal( "InitialSubstringUTF8Text", function( str, cols )
    local esc, len, res, j, pos, word, w;

    esc:= CHAR_INT(27);
    len:= Length( str );
    res:= "";
    j:= 0;
    while true do
      pos:= Position( str, esc, j );
      if pos = fail then
        pos:= len+1;
      fi;
      word:= str{ [ j+1 .. pos-1 ] };
      w:= WidthUTF8String( word );
      if w <= cols then
        Append( res, word );
        cols:= cols - w;
      elif cols > 0 then
        Append( res, InitialSubstringUTF8String( word, cols ) );
        cols:= 0;
      fi;
      if len < pos then
        break;
      fi;
      # Now pos points at an ESC character; all escape sequences we
      # support are terminated by a letter, so search for one.
      j:= PositionProperty( str, c -> c in LETTERS, pos );
      if j = fail then
        Error( "string end inside escape sequence" );
      fi;
      Append( res, str{ [ pos .. j ] } );
    od;
    return res;
end );

if not IsReadOnlyGlobal( "InitialSubstringUTF8String" ) then
  Unbind( InitialSubstringUTF8String );
fi;
if not IsReadOnlyGlobal( "LETTERS" ) then
  Unbind( LETTERS );
fi;
if not IsReadOnlyGlobal( "WidthUTF8String" ) then
  Unbind( WidthUTF8String );
fi;

#############################################################################
##
#F  HELP_SHOW_MATCHES( <book>, <topic>, <frombegin> )  . . .  show list of
#F  matches or single match directly
##
InstallGlobalFunction(HELP_SHOW_MATCHES, function( books, topic, frombegin )
  local   exact,  match,  x,  lines,  cnt,  i,  str,  n, width, line;
atomic readwrite HELP_REGION do

  # first get lists of exact and other matches
  x := HELP_GET_MATCHES( books, topic, frombegin );
  exact := x[1];
  match := x[2];

  # no topic found
  if 0 = Length(match) and 0 = Length(exact)  then
    Print( "Help: no matching entry found\n" );
    return false;

  # one exact or together one topic found
  elif 1 = Length(exact) or (0 = Length(exact) and 1 = Length(match)) then
    if Length(exact) = 0 then exact := match; fi;
    i := exact[1];
    str := Concatenation("Help: Showing `", i[1].bookname,": ",
                                               i[1].entries[i[2]][1], "'\n");
    # to avoid line breaking when str contains escape sequences:
    n := 0;
    while n < Length(str) do
      Print(str{[n+1..Minimum(Length(str),
                                    n + QuoInt(SizeScreen()[1] ,2))]}, "\c");
      n := n + QuoInt(SizeScreen()[1] ,2);
    od;
    HELP_PRINT_MATCH(i);
    return true;

  # more than one topic found, show overview in pager
  else
    lines :=
        ["Help: several entries match this topic - type ?2 to get match [2]"];
    HELP_LAST.TOPICS:=[];
    cnt := 0;
    # show exact matches first
    match := Concatenation(exact, match);
    width:= SizeScreen()[1];
    for i  in match  do
      cnt := cnt+1;
      topic := Concatenation(i[1].bookname,": ",i[1].entries[i[2]][1]);
      Add(HELP_LAST.TOPICS, i);
      line:= Concatenation("[",String(cnt),"] ",topic);
      Add(lines, InitialSubstringUTF8Text(line, width));
    od;
    Pager(rec(lines := lines, formatted := true));
    return true;
  fi;
od; # end atomic
end);

# choosing one of last shown  list of matches
InstallGlobalFunction(HELP_SHOW_FROM_LAST_TOPICS, function(nr)
  if nr = 0 or Length(HELP_LAST.TOPICS) < nr then
    Print("Help:  No such topic.\n");
    return false;
  fi;
  HELP_PRINT_MATCH(HELP_LAST.TOPICS[nr]);
  return true;
end);

##  A generic function for HELP_BOOK_HANDLER.(handler).HelpData(b, e, "ref")
##  This can be used to resolve cross references between books. The function
##  returns a list r with six entries:
##
##    - r[1]    search string including book name       "ref: Xyz"
##    - r[2]    (sub)section number as string           "5.14.2" or "3.1"
##    - r[3]    name of dvi-file (or fail)              "/doc/path/manual.dvi"
##    - r[4]    name of pdf-file (or fail)              "/doc/path/manual.pdf"
##    - r[5]    page number for r[3], r[4] (or fail)    37
##    - r[6]    URL (or fail)                           "/doc/htm/ch3.html#s4"
##    - r[7]    [chnr, secnr, subsecnr]                 [5,14,2] or [3,1,0]
##
atomic HELP_REGION do

HELP_BOOK_HANDLER.HelpDataRef := function(book, entrynr)
  local    info,  handler,  entry,  secnr,  res,  r;

  info := HELP_BOOK_INFO(book);
  handler := info.handler;
  entry := info.entries[entrynr];

  # the search and reference string
  res := [ Concatenation(info.bookname, ": ", entry[1]) ];
  # the section number string
  secnr := HELP_BOOK_HANDLER.(handler).HelpData(info, entrynr, "secnr");
  Add(res, secnr[2]);
  # dvi-file and page number
  r := HELP_BOOK_HANDLER.(handler).HelpData(info, entrynr, "dvi");
  if r = fail then
    Add(res, fail);
  else
    Add(res, r.file);
    res[5] := r.page;
  fi;
  # pdf-file and page number
  r := HELP_BOOK_HANDLER.(handler).HelpData(info, entrynr, "pdf");
  if r = fail then
    res[4] := fail;
  else
    res[4] := r.file;
    if not IsBound(res[5]) then
      res[5] := r.page;
    fi;
  fi;
  if not IsBound(res[5]) then
    res[5] := fail;
  fi;
  # URL
  r := HELP_BOOK_HANDLER.(handler).HelpData(info, entrynr, "url");
  if r = fail then
    Add(res, fail);
  else
    Add(res, r);
  fi;
  # [chnr, secnr, subsecnr] as list
  Add(res, secnr[1]);

  return res;
end;

od; # end atomic

##  From this info we generate a manual.lab file for a given book.
##  Note that the gapmacro format has subsection information in manual.lab
##  which is not available in manual.six! So, one cannot properly regenerate
##  a manual.lab file for those books.
InstallGlobalFunction(HELP_LAB_FILE, function(file, book)
  local fun, str, i;
  book := HELP_BOOK_INFO(book);
  fun := function(i)
    local r;
    r := HELP_BOOK_HANDLER.HelpDataRef(book, i);
    return Concatenation("\\makelabel {",
            SIMPLE_STRING(r[1]), "}{", r[2], "}\n");
  end;
  str := "";
  for i in [1..Length(book.entries)] do
    Append(str, fun(i));
  od;
  PrintTo(file, str);
end);


#############################################################################
##
#F  HELP( <string> )  . . . . . . . . . . . . . . .  deal with a help request
##
# here we store the last 16 requests
HELP_RING_IDX :=  0;
HELP_RING_SIZE := 16;
BindGlobal("HELP_BOOK_RING", ListWithIdenticalEntries( HELP_RING_SIZE,
                                             ["tutorial"] ));
if IsHPCGAP then
  LockAndMigrateObj(HELP_BOOK_RING,HELP_REGION);
fi;
BindGlobal("HELP_TOPIC_RING", ListWithIdenticalEntries( HELP_RING_SIZE,
                                             "welcome to gap" ));
if IsHPCGAP then
  LockAndMigrateObj(HELP_TOPIC_RING,HELP_REGION);
fi;
BindGlobal("HELP_ORIG_TOPIC_RING", ListWithIdenticalEntries( HELP_RING_SIZE,
                                             "welcome to gap" ));
if IsHPCGAP then
  LockAndMigrateObj(HELP_ORIG_TOPIC_RING,HELP_REGION);
fi;
# here we store the last shown topic, initialized with 0 (leading to
# show "Tutorial: Help", see below)
BindGlobal("HELP_LAST", AtomicRecord( rec(MATCH := 0, BOOK := 0,
             NEXT_VIEWER := false, TOPICS := [])));
NAMES_SYSTEM_GVARS:= "to be defined in init.g";

InstallGlobalFunction(HELP, function( str )
  local origstr, nwostr, p, book, books, move, add;

  origstr := ShallowCopy(str);
  while Last( origstr ) = ';' do
    Remove( origstr );
  od;
  nwostr := NormalizedWhitespace(origstr);

  # extract the book
  p := Position( str, ':' );
  if p <> fail  then
      book := str{[1..p-1]};
      str  := str{[p+1..Length(str)]};
  else
      book := "";
  fi;

  # normalizing for search
  book := SIMPLE_STRING(book);
  str := SIMPLE_STRING(str);

atomic readwrite HELP_REGION do

  # we check if `book' MATCH_BEGINs some of the available books
  books := Filtered(HELP_KNOWN_BOOKS[1], bn-> MATCH_BEGIN(bn, book));
  if Length(book) > 0 and Length(books) = 0 then
    Print("Help: None of the available books matches (try: '?books').\n");
    return;
  fi;

  # function to add a topic to the ring
  move := false;
  add  := function( books, topic, orig_topic )
      if not move  then
          HELP_RING_IDX := (HELP_RING_IDX+1) mod HELP_RING_SIZE;
          HELP_BOOK_RING[HELP_RING_IDX+1]  := books;
          HELP_TOPIC_RING[HELP_RING_IDX+1] := topic;
          HELP_ORIG_TOPIC_RING[HELP_RING_IDX+1] := orig_topic;
      fi;
  end;

  # if the topic is empty show the last shown one again
  if  book = "" and str = ""  then
       if HELP_LAST.BOOK = 0 then
         HELP("Tutorial: Help");
       else
         HELP_PRINT_MATCH( [HELP_LAST.BOOK, HELP_LAST.MATCH] );
       fi;
       return;

  # if topic is "&" show last topic again, but with next viewer in viewer
  # list, or with last viewer again if there is no next one
  elif book = "" and str = "&" and Length(nwostr) = 1 then
       if HELP_LAST.BOOK = 0 then
         HELP("Tutorial: Help");
       else
         HELP_LAST.NEXT_VIEWER := true;
         HELP_PRINT_MATCH( [HELP_LAST.BOOK, HELP_LAST.MATCH] );
       fi;
       return;

  # if the topic is '-' we are interested in the previous search again
  elif book = "" and str = "-" and Length(nwostr) = 1  then
      HELP_RING_IDX := (HELP_RING_IDX-1) mod HELP_RING_SIZE;
      books := HELP_BOOK_RING[HELP_RING_IDX+1];
      str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
      origstr := HELP_ORIG_TOPIC_RING[HELP_RING_IDX+1];
      move := true;

  # if the topic is '+' we are interested in the last section again
  elif book = "" and str = "+" and Length(nwostr) = 1  then
      HELP_RING_IDX := (HELP_RING_IDX+1) mod HELP_RING_SIZE;
      books := HELP_BOOK_RING[HELP_RING_IDX+1];
      str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
      origstr := HELP_ORIG_TOPIC_RING[HELP_RING_IDX+1];
      move := true;
  fi;

  # number means topic from HELP_LAST.TOPICS list
  if book = "" and ForAll(str, a-> a in "0123456789") then
      HELP_SHOW_FROM_LAST_TOPICS(Int(str));

  # if the topic is '<' we are interested in the one before 'LastTopic'
  elif book = "" and str = "<" and Length(nwostr) = 1  then
      HELP_SHOW_PREV();

  # if the topic is '>' we are interested in the one after 'LastTopic'
  elif book = "" and str = ">" and Length(nwostr) = 1  then
      HELP_SHOW_NEXT();

  # if the topic is '<<' we are interested in the previous chapter intro
  elif book = "" and str = "<<"  then
      HELP_SHOW_PREV_CHAPTER();

  # if the topic is '>>' we are interested in the next chapter intro
  elif book = "" and str = ">>"  then
      HELP_SHOW_NEXT_CHAPTER();

  # if the subject is 'Welcome to GAP' display a welcome message
  elif book = "" and str = "welcome to gap"  then
      if HELP_SHOW_WELCOME(book)  then
          add( books, "Welcome to GAP", "Welcome to GAP" );
      fi;

  # if the topic is 'books' display the table of books
  elif book = "" and str = "books"  then
      if HELP_SHOW_BOOKS()  then
          add( books, "books", "books" );
      fi;

  # if the topic is 'chapters' display the table of chapters
  elif str = "chapters"  or str = "contents" or book <> "" and str = "" then
      if ForAll(books, HELP_SHOW_CHAPTERS) then
        add( books, "chapters", "chapters" );
      fi;

  # if the topic is 'sections' display the table of sections
  elif str = "sections"  then
      if ForAll(books, HELP_SHOW_SECTIONS) then
        add(books, "sections", "sections");
      fi;

  # if the topic is '?<string>' search the index for any entries for
  # which <string> is a substring (as opposed to an abbreviation)
  elif Length(str) > 0 and str[1] = '?'  then
      str := str{[2..Length(str)]};
      NormalizeWhitespace(str);
      origstr := origstr{[2..Length(origstr)]};
      if HELP_SHOW_MATCHES( books, str, false : HELP_TOPIC:= origstr ) then
          add( books, str, origstr );
      fi;

  # search for this topic
  elif HELP_SHOW_MATCHES( books, str, true : HELP_TOPIC:= origstr ) then
      add( books, str, origstr );
  elif origstr in NAMES_SYSTEM_GVARS then
      Print( "Help: '", origstr, "' is currently undocumented.\n",
             "      For details, try ?Undocumented Variables\n" );
  elif book = "" and
                 ForAny(HELP_KNOWN_BOOKS[1], bk -> MATCH_BEGIN(bk, str)) then
      Print( "Help: Are you looking for a certain book? (Trying '?", origstr,
             ":' ...\n");
      HELP( Concatenation(origstr, ":") );
  else
     # seems unnecessary, since some message is already printed in all
     # cases above (?):
     # Print( "Help: Sorry, could not find a match for '", origstr, "'.\n");
  fi;
od; # end atomic
end);
