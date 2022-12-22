#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler / Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The  files  helpdef.g{d,i}  contain  the  `default'  help  book  handler
##  functions, which implement access of GAP's online help to help documents
##  produced  from `gapmacro.tex'-  .tex and  .msk files  using buildman.pe,
##  tex, pdftex and convert.pl.
##
##  The function  which converts the  TeX sources  to text for  the "screen"
##  viewer is outsourced into `helpt2t.g{d,i}'.
##

################ ???????????????????????????? ###############################


#############################################################################
##
#F  GapLibToc2Gap( <tocfile> )  . . . . . . . . . . . . . reading .toc file
##
##  reads a manual.toc file of GAP library book and returns list of entries
##  of form [[chapnr, secnr], pagenr]. Used in `default' ReadSix.
##
##  This allows  to  use     xdvi  and  acroread/xpdf conveniently  as help
##  browser.
##
InstallGlobalFunction(GapLibToc2Gap, function(file)
  local   stream,  str,  getarg,  p,  l,  res,  a,  s,  pos,  r;

  stream := StringStreamInputTextFile(file);
  if stream=fail then
    return fail;
  fi;
  str := ReadAll(stream);
  CloseStream(stream);

  # get next argument in {...} after pos (need to handle nested {}'s)
  getarg := function(str, pos)
    local   l,  level,  p;
    l := Length(str);
    while l >= pos and str[pos] <> '{' do
      pos := pos + 1;
    od;
    level := 0;
    p := pos+1;
    while true do
      if p > l then
        break;
      elif str[p] = '{' then
        level := level+1;
      elif str[p] = '}' then
        if level = 0 then
          break;
        else
          level := level-1;
        fi;
      fi;
      p := p+1;
    od;
    return [pos, p];
  end;

  p := Position(str, '\\');
  l := Length(str);
  res := [];

  while p <> fail do
    # read one .toc entry
    if p+12 < l and (str{[p..p+12]} = "\\chapcontents" or
               str{[p..p+11]} = "\\seccontents") then
      a := [getarg(str, p+12)];
      Add(a, getarg(str, a[1][2]+1));
      Add(a, getarg(str, a[2][2]+1));
      p := Position(str, '\\', a[3][2]);
      s := str{[a[1][1]+1..a[1][2]-1]};
      # bibliography, index,.. are numberless chapters and seem not available
      # in help index for library books
      if Length(s)>0 and ForAll(s, x-> x in "0123456789" or
                 x='.') then
        pos := Position(s, '.');
        if pos=fail then
          # chapter entry
          r := [[Int(s), 0]];
        else
          # chapter and section number
          r := [[Int(s{[1..pos-1]}), Int(s{[pos+1..Length(s)]})]];
        fi;
        # don't need the header again
        ##  Add(r, str{[a[2][1]+1..a[2][2]-1]});
        # page number
        Add(r, Int(str{[a[3][1]+1..a[3][2]-1]}));
        Add(res, r);
      fi;
    else
      p := Position(str, '\\', p);
    fi;
  od;

  return res;
end);

##  here are more functions which are used by the `default' handler
##  functions (see their use below).
#############################################################################
##
#F  HELP_CHAPTER_INFO( <book>, <chapter> )  . . . .  get info about a chapter
##
##  this is a helper function for `HELP_SHOW_SECTIONS'
BindGlobal("HELP_CHAPTER_BEGIN", Immutable("\\Chapter"));
BindGlobal("HELP_SECTION_BEGIN", Immutable("\\Section"));
BindGlobal("HELP_FAKECHAP_BEGIN", Immutable("%\\FakeChapter"));
BindGlobal("HELP_PRELCHAPTER_BEGIN", Immutable("\\PreliminaryChapter"));

InstallGlobalFunction(HELP_CHAPTER_INFO, function( book, chapter )
    local   info,  filename,  stream,  poss,  secnum,  pos,  line;

    # get the book info
    info := HELP_BOOK_INFO(book);

    # read in a chapter
    if not IsBound(info.secposs[chapter])  then

        filename := Filename( info.directories, info.filenames[chapter] );
        if filename = fail  then
            Error("help file ", info.filenames[chapter], " for help book '", book.bookname, "' not found");
            return fail;
        fi;
        stream := StringStreamInputTextFile(filename);
        if stream = fail then
            Error("help file ", filename, " does not exist or is not readable");
            return fail;
        fi;
        poss   := [];
        secnum := 0;
        repeat
            pos  := PositionStream(stream);
            line := ReadLine(stream);
            if line <> fail  then
                if MATCH_BEGIN( line, HELP_SECTION_BEGIN )  then
                    secnum := secnum + 1;
                    poss[secnum] := pos;
                elif MATCH_BEGIN( line, HELP_CHAPTER_BEGIN ) or
                     MATCH_BEGIN( line, HELP_PRELCHAPTER_BEGIN )  then
                    info.chappos[chapter] := pos;
                elif MATCH_BEGIN( line, HELP_FAKECHAP_BEGIN )  then
                    info.chappos[chapter] := pos;
                fi;
            fi;
        until IsEndOfStream(stream);
        CloseStream(stream);
        info.secposs[chapter] := Immutable(poss);
    fi;

    # return the info
    return [ info.chappos[chapter], info.secposs[chapter] ];

end);

InstallGlobalFunction(HELP_PRINT_SECTION_URL, function(arg)
    local book, hnb, d, pos, chapter, section, fn, path;

    book := HELP_BOOK_INFO(arg[1]);
    if book=fail then
      Error("this book does not exist");
    fi;
    hnb := HELP_KNOWN_BOOKS;
    # the path as string
    book := hnb[2][Position(hnb[1], SIMPLE_STRING(book.bookname))][3];
    if IsDirectory(book) then
      d := book![1];
    else
      d := book;
    fi;
    if d[Length(d)] = '/' then
      d := d{[1..Length(d)-1]};
    fi;

    # find `doc'
    pos:=Length(d)-2;
    while pos>0 and (d[pos]<>'d' or d[pos+1]<>'o' or d[pos+2]<>'c') do
      pos:=pos-1;
    od;
    #see if it is only `doc', if yes skip
    if pos+2=Length(d) then
      # it ends in doc, replace `doc' by `htm'
      d:=Concatenation(d{[1..pos-1]},"htm");
    else
      # insert htm after doc
      d:=Concatenation(d{[1..pos+2]},"/htm",d{[pos+3..Length(d)]});
    fi;

    chapter:=String(arg[2]);
    while Length(chapter)<3 do
      chapter:=Concatenation("0",chapter);
    od;
    section:=arg[3];

    # first try to find a file-per-chapter .htm file
    fn := Concatenation("CHAP", chapter, ".htm");
    if IsDirectory(book) then
      path := Filename([Directory(d)], fn);
    else
      path := Filename(List(GAPInfo.RootPaths, Directory),
                     Concatenation(d, "/", fn));
    fi;
    if path = fail then
      # now try to find a file-per-section .htm file
      section:=String(section);
      while Length(section)<3 do
        section:=Concatenation("0",section);
      od;
      fn := Concatenation("C", chapter, "S", section, ".htm");
      if IsDirectory(book) then
        path := Filename([Directory(d)], fn);
      else
        path := Filename(List(GAPInfo.RootPaths, Directory),
                       Concatenation(d, "/", fn));
      fi;
    fi;
    if path <> fail and not IsString(section) and section>0 then
      # we must have found a file-per-chapter .htm file above
      section:=String(section);
      while Length(section)<3 do
        section:=Concatenation("0",section);
      od;
      path:=Concatenation(path,"#SECT",section);
    fi;
    return path;
end);

# now the handlers

atomic HELP_REGION do # acquire lock for HELP_BOOK_HANDLER

##  the default ReadSix function for books in gapmacro format
##  (need to parse a text file in this case, this function still
##  looks pretty long winded)
HELP_BOOK_HANDLER.default.ReadSix := function(stream)
  local   fname,  readNumber, pos,  n,  c,  s,  x,  f,  line,  subline,
          c1,  c2,  i,  name,  num,  s1,  sec,  s2,  j,  x1,
          w,  f1,  res,  toc;

  # name of file
  fname := ShallowCopy(stream![2]);

  # numbers
  readNumber := function( str )
    local   n;

    while pos<=Length(str) and str[pos] = ' '  do
      pos := pos+1;
    od;
    n := 0;
    while pos<=Length(str) and str[pos] <> '.'  do
      n := n * 10 + (Position("0123456789", str[pos])-1);
      pos := pos+1;
    od;
    pos := pos+1;
    return n;
  end;

  c := []; s := []; x := []; f := [];
  repeat
    line := ReadLine(stream);
    if line <> fail  then
      RemoveCharacters(line, "\r");
      subline:=line{[3..Length(line)-1]} ;
      if line[1] = 'C'  then
        Add( c, subline);
      elif line[1] = 'S'  then
        Add( s, subline);
      elif line[1] = 'I'  then
        Add( x, subline);
      elif line[1] = 'F'  then
        if ForAll([Maximum(Length(f)-10, 1)..Length(f)],
                  i-> f[i] <> subline) then
          Add( f, subline);
        fi;
      else
        Print( "#W  corrupted 'manual.six': ", line );
        Print( "#W (in stream: ", stream, ")\n");
        break;
      fi;
    fi;
  until IsEndOfStream(stream);
  CloseStream(stream);

  # parse the chapters information
  c1 := [];
  c2 := [];
  for line  in c  do

    # first the filename
    pos  := Position( line, ' ' );
    name := line{[1..pos-1]};

    # then the chapter number
    num := readNumber(line);

    # then the chapter name
    while pos <= Length(line) and line[pos] = ' '  do pos := pos+1;  od;

    # store that information in <c1> and <c2>
    c1[num] := name;
    c2[num] := line{[pos..Length(line)]};
  od;

  # parse the sections information
  s1 := List( c1, x -> [] );
  for line  in s  do

    # chapter and section number
    pos := 1;
    num := readNumber(line);
    sec := readNumber(line);

    # then the section name
    while pos < Length(line) and line[pos] = ' '  do pos := pos+1;  od;

    # store the information in <s1>
    s1[num][sec] := line{[pos..Length(line)]};
    if pos = Length(line) then
      Print("#W  Empty section name ", num, ".", sec,"\n");
    fi;
  od;

  # convert sections and chapters to lower case
  s2 := [];
  for i  in [ 1 .. Length(s1) ]  do
    for j  in [ 1 .. Length(s1[i]) ]  do
      Add( s2, [ s1[i][j], SIMPLE_STRING(s1[i][j]), "S", i, j ] );
    od;
  od;
  for i  in [ 1 .. Length(c2) ]  do
    Add( s2, [ c2[i], SIMPLE_STRING(c2[i]), "C", i, 0 ] );
  od;

  # parse the index information
  x1 := [];
  for line  in x  do

    # chapter and section number
    pos := 1;
    num := readNumber(line);
    sec := readNumber(line);

    # then the index entry
    while pos <= Length(line) and line[pos] = ' '  do pos := pos+1;  od;

    # store the information in <x1>
    w := line{[pos..Length(line)]};
    Add( x1, [ w, SIMPLE_STRING(w), "I", num, sec ] );
  od;

  # parse the function information
  f1 := [];
  for line  in f  do

    # chapter and section number
    pos := 1;
    num := readNumber(line);
    sec := readNumber(line);

    # then the index entry
    while pos <= Length(line) and line[pos] = ' '  do pos := pos+1;  od;

    # store the information in <x1>
    w := line{[pos..Length(line)]};
    Add( f1, [ w, SIMPLE_STRING(w), "F", num, sec ] );
  od;

  res := rec(
          formats       := ["text", "url"],
          filenames   := Immutable(c1),
# the following three are not made immutable to allow change of names (if it
# is found out that several sections have the same name).
          chapters    := c2,
          sections    := s1,
          secposs     := [],
          chappos     := [],
          entries := Concatenation(s2, x1, f1)
        );

  # trying to read page numbers from manual.toc file
  fname{[Length(fname)-2..Length(fname)]} := "toc";
  toc := GapLibToc2Gap(fname);
  if toc <> fail then
    res.pagenumbers := toc;
    fname{[Length(fname)-2..Length(fname)]} := "dvi";
    if IsExistingFile( fname ) = true then
      res.dvifile := ShallowCopy(fname);
      Add(res.formats, "dvi");
    fi;
    fname{[Length(fname)-2..Length(fname)]} := "pdf";
    if IsExistingFile( fname ) = true then
      res.pdffile := ShallowCopy(fname);
      Add(res.formats, "pdf");
    fi;
  fi;
  res.directories := [ Directory(fname{[1..Length(fname)-10]}) ];
  return res;
end;

HELP_BOOK_HANDLER.default.ShowChapters := function( book )
  local   info,  chap;

  info := HELP_BOOK_INFO(book);
  if info = fail  then
    Print( "Help: unknown book \"", book, "\"\n" );
           return false;
  fi;

  # print the chapters
  chap := ShallowCopy(info.chapters);
  Sort(chap);
  return Concatenation(
            [ FILLED_LINE( "Table of Chapters", info.bookname, '_' ) ],
            chap,
            [ "" ]
        );
end;

HELP_BOOK_HANDLER.default.ShowSections := function( book )
  local   info,  lines,  chap,  sec;

  info := HELP_BOOK_INFO(book);
  if info = fail  then
    Print( "Help: unknown book \"", book, "\"\n" );
           return false;
  fi;

  # print the sections
  lines := [ FILLED_LINE( "Table of Sections", info.bookname, '_' ) ];
  for chap  in [ 1 .. Length(info.chapters) ]  do
    Add( lines, info.chapters[chap] );
    for sec  in [ 1 .. Length(info.sections[chap]) ]  do
      Add(lines,Concatenation("    ",info.sections[chap][sec]));
    od;
  od;
  Add( lines, "" );
  return lines;
end;

HELP_BOOK_HANDLER.default.MatchPrevChap := function(book, entrynr)
  local   info,  chnr,  nr;
  info := HELP_BOOK_INFO(book);
  chnr := info.entries[entrynr][4];
  if info.entries[entrynr][3] <> "C" or chnr = 1 then
    nr :=  First([1..Length(info.entries)], i-> info.entries[i]{[3,4]} =
               ["C", chnr]);
  else
    nr :=  First([1..Length(info.entries)], i-> info.entries[i]{[3,4]} =
               ["C", chnr-1]);
  fi;
  return [info, nr];
end;

HELP_BOOK_HANDLER.default.MatchNextChap := function(book, entrynr)
  local   info,  chnr,  nr;
  info := HELP_BOOK_INFO(book);
  chnr := info.entries[entrynr][4] + 1;
  nr :=  First([1..Length(info.entries)], i-> info.entries[i]{[3,4]} =
               ["C", chnr]);
  return [info, nr];
end;

HELP_BOOK_HANDLER.default.MatchPrev := function(book, entrynr)
  local   info,  entry,  chnr,  secnr,  nr;

  info := HELP_BOOK_INFO(book);
  entry := info.entries[entrynr];
  chnr := entry[4];
  secnr := entry[5];
  if secnr > 1 then
    nr := First([1..Length(info.entries)], i-> info.entries[i]{[3,4,5]}
              = ["S", chnr, secnr-1]);
  elif secnr = 1 then
    nr := First([1..Length(info.entries)], i-> info.entries[i]{[3,4]}
                = ["C", chnr]);
  elif secnr = 0 then
    nr := First(Reversed([1..Length(info.entries)]), i->
                info.entries[i][3] = "S" and
                info.entries[i][4] = chnr-1);
  fi;
  return [info, nr];
end;

HELP_BOOK_HANDLER.default.MatchNext := function(book, entrynr)
  local   info,  entry,  chnr,  secnr,  nr;

  info := HELP_BOOK_INFO(book);
  entry := info.entries[entrynr];
  chnr := entry[4];
  secnr := entry[5];
  nr := First([1..Length(info.entries)], i-> info.entries[i]{[3,4,5]}
              = ["S", chnr, secnr+1]);
  if nr = fail then
    nr := First([1..Length(info.entries)], i-> info.entries[i]{[3,4,5]}
                = ["C", chnr+1, 0]);
  fi;

  return [info, nr];
end;

##
##  The default search for matches is easy, just MATCH_BEGIN (if frombegin
##  = true), resp.  IS_SUBSTRING is used for content of second position in
##  .entries. The topic is assumed to be normalized already.
##
HELP_BOOK_HANDLER.default.SearchMatches := function (book, topic, frombegin)
  local info, exact, match, rank, m, i;
  info := HELP_BOOK_INFO(book);
  exact := [];
  match := [];
  rank := [];
  for i in [1..Length(info.entries)] do
    if topic=info.entries[i][2] then
      Add(exact, i);
    elif frombegin = true then
      m := MATCH_BEGIN_COUNT(info.entries[i][2], topic);
      if m >= 0 then
        Add(match, i);
        Add(rank, -m);
      fi;
    else
      if IS_SUBSTRING(info.entries[i][2], topic) then
        Add(match, i);
      fi;
    fi;
  od;

  # sort by rank if applicable
  if frombegin = true then
    SortParallel(rank, match);
  fi;

  return [exact, match];
end;

##  the `default' handler for HelpData delegates to functions from above
HELP_BOOK_HANDLER.default.HelpData := function(book, entrynr, type)
  local   info,  entry,  chnr,  secnr,  pos,  r;

  info := HELP_BOOK_INFO(book);
  entry := info.entries[entrynr];
  chnr := entry[4];
  secnr := entry[5];

  # we handle the special type "ref" for cross references first
  if type = "ref" then
    return HELP_BOOK_HANDLER.HelpDataRef(info, entrynr);
  fi;

  if type = "secnr" then
    r := "";
    Append(r, String(chnr));
    if secnr <> 0 then
      Add(r, '.');
      Append(r, String(secnr));
    fi;
    return [[chnr, secnr, 0], r];
  fi;

  if not type in info.formats then
    return fail;
  fi;

  if type = "text" then
    if entry[3] = "F" then
      return HELP_PRINT_SECTION_TEXT(info, chnr, secnr, entry[1]);
    else
      return HELP_PRINT_SECTION_TEXT(info, chnr, secnr);
    fi;
  fi;

  if type = "url" then
    return HELP_PRINT_SECTION_URL(info, chnr, secnr);
  fi;

  if type = "dvi" then
    pos := PositionSorted(info.pagenumbers, [[chnr, secnr],-1]);
    if IsBound(info.pagenumbers[pos]) and info.pagenumbers[pos][1] =
       [chnr, secnr] then
      return rec(file := info.dvifile, page := info.pagenumbers[pos][2]);
    fi;
  fi;

  if type = "pdf" then
    pos := PositionSorted(info.pagenumbers, [[chnr, secnr],-1]);
    if IsBound(info.pagenumbers[pos]) and info.pagenumbers[pos][1] =
       [chnr, secnr] then
      return rec(file := info.pdffile, page := info.pagenumbers[pos][2]);
    fi;
  fi;

  return fail;
end;

HELP_BOOK_HANDLER.default.SubsectionNumber := function(info, entrynr)
  return info.entries[entrynr]{[4,5]};
end;

od; # end of atomic HELP_REGION
