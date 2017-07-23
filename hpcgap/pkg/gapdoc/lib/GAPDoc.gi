#############################################################################
##
#W  GAPDoc.gi                    GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files GAPDoc.g{d,i} contain some utilities for trees returned by
##  ParseTreeXMLString applied to a GAPDoc document.
##  

##  <#GAPDoc Label="CheckAndCleanGapDocTree">
##  <ManSection >
##  <Func Arg="tree" Name="CheckAndCleanGapDocTree" />
##  <Returns>nothing</Returns>
##  <Description>
##  The argument  <A>tree</A> of this  function is a parse  tree from
##  <Ref Func="ParseTreeXMLString" /> of some &GAPDoc; document. This
##  function  does an  (incomplete)  validity check  of the  document
##  according to the document  type declaration in <F>gapdoc.dtd</F>.
##  It also does some additional  checks which cannot be described in
##  the DTD (like checking whether chapters and sections have a heading).
##  For elements  with element  content the whitespace  between these
##  elements is removed.<P/>
##  
##  In case  of an error the  break loop is entered  and the position
##  of  the error  in  the  original XML  document  is printed.  With
##  <C>Show();</C>  one can  browse the  original input  in the  <Ref
##  BookName="Ref" Func="Pager" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# GAPDOCDTDINFO contains essentially the declaration information from
# gapdoc.dtd
Add(GAPDOCDTDINFO, rec(name := "WHOLEDOCUMENT", attr := [  ], 
            reqattr := [  ], type := "elements", content := ["Book"]));
BindGlobal("GAPDOCDTDINFOELS", List(GAPDOCDTDINFO, a-> a.name));
InstallGlobalFunction(CheckAndCleanGapDocTree, function(arg)
  local r, str, name, pos, type, namc, l, i, namattr, typ, c;
  # we save orignal XML input string if available (as r.input on top
  # level and as second argument in recursive calls of this function)
  # This allows to browse the input if an error occurs.
  r := arg[1];
  if Length(arg) > 1 then
    str := arg[2];
  elif IsBound(r.input) then
    str := r.input;
  else
    str := "input string not available";
  fi;
  
  name := r.name;
  if name = "PCDATA" then
    return true;
  fi;
  if Length(name)>2 and name{[1..3]} = "XML" then
    return true;
  fi;
  pos := Position(GAPDOCDTDINFOELS, name);
  if pos=fail then
    ParseError(str, r.start, Concatenation("element ", name, " not known"));
  fi;
  type := GAPDOCDTDINFO[pos].type;
  # checking content
  if type = "empty" then
    # case that empty element is not input as such 
    if IsList(r.content) and Length(r.content) = 0 then
      r.content := EMPTYCONTENT;
    fi;
    if not r.content = EMPTYCONTENT then
      ParseError(str, r.start, Concatenation("element ", name, 
                      " must be empty"));
    fi;
  elif type = "elements" then
    # white space between elements is ignored
    r.content := Filtered(r.content, c-> c.name <> "PCDATA" or not
                          ForAll(c.content, x-> x in WHITESPACE));
    for c in r.content do 
      namc := c.name;
      if not ((Length(namc)>2 and namc{[1..3]}="XML") or
              (namc = "PCDATA" and ForAll(c.content, x-> x in
                      WHITESPACE)) or
              namc in GAPDOCDTDINFO[pos].content) then
        ParseError(str, r.start, Concatenation("Wrong element in ", 
                        name, ": ", namc));
      else
        
      fi;
    od;
    r.content := Filtered(r.content, a-> a.name <> "PCDATA");
  elif type = "mixed" then
    l := List(r.content, c-> (Length(c.name)>2 and c.name{[1..3]}
                 = "XML") or c.name in 
              GAPDOCDTDINFO[pos].content);
    if false in l then
      ParseError(str, r.start, Concatenation("Wrong element in ", 
                      name, ": ", r.content[Position(l, false)].name));
    fi;
    # compactifying sequences of PCDATA entries
    i := 1;
    while i < Length(r.content) do
      if r.content[i].name = "PCDATA" and r.content[i+1].name = "PCDATA" then
        Append(r.content[i].content, r.content[i+1].content);
        r.content := r.content{Concatenation([1..i], [i+2..Length(r.content)])};
      else
        i := i + 1;
      fi;
    od;
  fi;
  
  # checking existing attributes:
  namattr := NamesOfComponents(r.attributes);
  for c in namattr do
    if not c in GAPDOCDTDINFO[pos].attr then
      ParseError(str, r.start, Concatenation("Attribute ", c, 
                      " not declared for ", name));
    fi;
  od;
  # checking required attributes
  for c in GAPDOCDTDINFO[pos].reqattr do
    if not c in namattr then
      ParseError(str, r.start, Concatenation("Attribute ", c, 
                      " must be given in element ", name));
    fi;
  od;
  # some extra checks
  if name = "Ref" then
    if IsBound(r.attributes.BookName) and not
       IsBound(r.attributes.Label) then
      typ := Difference(NamesOfComponents(r.attributes), ["BookName",
             "Style", "Text"]);
      if Length(typ) <> 1 then
        ParseError(str, r.start, Concatenation(
                        "Ref with strange attribute set: ", typ));
      fi;
    fi;
  elif name in [ "Chapter", "Section", "Subsection" ] and not "Heading"
    in List(r.content, a-> a.name) then
    ParseError(str, r.start, 
                    "Chapter, Section or Subsection must have a heading");
  fi;
  
  if r.content = EMPTYCONTENT then
    return true;
  else
    return ForAll(r.content, x-> CheckAndCleanGapDocTree(x, str));
  fi;
end);

    
##  <#GAPDoc Label="AddParagraphNumbersGapDocTree">
##  <ManSection >
##  <Func Arg="tree" Name="AddParagraphNumbersGapDocTree" />
##  <Returns>nothing</Returns>
##  <Description>
##  The argument  <A>tree</A> must  be an XML  tree returned  by <Ref
##  Func="ParseTreeXMLString" /> applied to a &GAPDoc; document. This
##  function adds to each node  of the tree a component <C>.count</C>
##  which is of form <C>[Chapter[, Section[, Subsection, Paragraph] ]
##  ]</C>.  Here  the first  three  numbers  should  be the  same  as
##  produced  by the &LaTeX; version of the document. Text before the
##  first chapter  is counted as  chapter <C>0</C> and  similarly for
##  sections and subsections. Some  elements are always considered to
##  start a new paragraph.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(AddParagraphNumbersGapDocTree, function(r)
  local   parels,  cssp,  setcount;
  if IsBound(r.count) then
    return;
  fi;
  
  # these elements are paragraphs  
  parels := [ "List", "Enum", "Table", "Item", "Heading", "Attr", "Fam", 
              "Filt", "Func", "InfoClass", "Meth", "Oper", "Prop", "Var",
              "Display", "Example", "Listing", "Log", "Verb", "Address", 
              "TitleComment"];
  # reset counter
  cssp := [0, 0, 0, 1];
  # the counter setting recursive function
  setcount := function(rr)
    local   a;
    if  rr.name <> "Ignore" and IsList(rr.content) and 
                                                not IsString(rr.content) then
      for a in rr.content do
        # new chapter, text before first section is counted as section 0
        if a.name = "Chapter" then
          cssp := [cssp[1]+1, 0, 0, 1];
          a.count := cssp;
        elif a.name = "Section" then
          cssp := [cssp[1], cssp[2]+1, 0, 1];
        elif a.name in ["Subsection", "ManSection", "Abstract", "Copyright",
                "TableOfContents", "Acknowledgements", "Colophon"] then
          cssp := [cssp[1], cssp[2], cssp[3]+1, 1];
        elif a.name in ["P", "Par"] or a.name in parels then
          cssp := [cssp[1], cssp[2], cssp[3], cssp[4]+1];
        elif a.name = "Appendix" then
          # here we number with capital letters
          if IsInt(cssp[1]) then
            cssp := ["A", 0, 0, 1];
          else
            cssp := [[CHAR_INT(INT_CHAR(cssp[1][1])+1)], 0, 0, 1];
            ConvertToStringRep(cssp[1]);
          fi;
        # bib and index are counted as new chapters  
        elif  a.name = "Bibliography" then
          cssp := ["Bib", 0, 0, 1];
        elif a.name = "TheIndex" then
          cssp := ["Ind", 0, 0, 1];
        fi;
        a.count := cssp;
        # recursion
        setcount(a);
        if a.name in parels then
          cssp := [cssp[1], cssp[2], cssp[3], cssp[4]+1];
        fi;
      od;
    fi;
  end;
  r.count := cssp;
  setcount(r);
end);

##  <#GAPDoc Label="AddPageNumbersToSix">
##  <ManSection >
##  <Func Arg="tree, pnrfile" Name="AddPageNumbersToSix" />
##  <Returns>nothing</Returns>
##  <Description>
##  Here   <A>tree</A>  must   be  the   XML  tree   of  a   &GAPDoc;
##  document,   returned   by  <Ref   Func="ParseTreeXMLString"   />.
##  Running <C>latex</C>  on the  result of  <C>GAPDoc2LaTeX(<A>tree</A>)</C>  
##  produces  a   file  <A>pnrfile</A>  (with
##  extension  <C>.pnr</C>).  The   command  <C>GAPDoc2Text(<A>tree</A>)</C>
##  creates a component <C><A>tree</A>.six</C>
##  which contains all  information about the document  for the &GAP;
##  online  help,  except  the  page numbers  in  the  <C>.dvi,  .ps,
##  .pdf</C> versions of the document.  This command adds the missing
##  page number information to <C><A>tree</A>.six</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
PAGENRS := 0;
InstallGlobalFunction(AddPageNumbersToSix, function(r, pnrfile)
  local   six,  a,  pos;
  if not IsExistingFile(pnrfile) and
    IsBound(GAPInfo.SIXFILEIGNOREMISSINGPNR) and
    GAPInfo.SIXFILEIGNOREMISSINGPNR = true then
    for a in r.six do a[5] := -1; od;
    return;
  fi;
  Read(pnrfile);
  six := r.six;
  for a in six do
    pos := Position(PAGENRS, a[3]);
    # can fail, e.g. because LaTeX/makeindex do not produce an empty index
    if pos = fail then
      a[5] := PAGENRS[Length(PAGENRS)];
    else
      a[5] := PAGENRS[pos+1];
    fi;
  od;
  Unbind(PAGENRS);
end);

##  <#GAPDoc Label="PrintSixFile">
##  <ManSection >
##  <Func Arg="tree, bookname, fname" Name="PrintSixFile" />
##  <Returns>nothing</Returns>
##  <Description>
##  This  function  prints  the  <C>.six</C>  file  <A>fname</A>  for
##  a   &GAPDoc;   document   stored   in   <A>tree</A>   with   name
##  <A>bookname</A>. Such  a file contains all  information about the
##  book which is  needed by the &GAP; online  help. This information
##  must first be created by  calls of <Ref Func="GAPDoc2Text" /> and
##  <Ref Func="AddPageNumbersToSix" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(PrintSixFile, function(file, r, bookname)
  local   f;
  f := function(a)
    local   res;
    res := ShallowCopy(a);
    res[2] := STRING_LOWER(res[2]);
    return res;
  end;
  PrintTo(file, "#SIXFORMAT  GapDocGAP\nHELPBOOKINFOSIXTMP := rec(\n",
          "encoding := \"UTF-8\",\n",
          "bookname := \"", bookname, "\",\n",
          "entries :=\n", List(r.six, f), "\n);\n");
end);

# non-documented utility
##  This prints templates for all elements (e.g., for editor helper functions)
InstallGlobalFunction(PrintGAPDocElementTemplates, function ( file )
  local a, x;
  PrintTo(file, "<--  Templates for GAPDoc XML Elements  -->\n");
  Sort(GAPDOCDTDINFO, function(a,b) return a.name<b.name;end);
  for a  in GAPDOCDTDINFO  do
    AppendTo(file, "name:",a.name,"\n<", a.name );
    for x  in a.reqattr  do
      AppendTo(file, " ", x, "=\"\"" );
    od;
    for x in Difference (a.attr, a.reqattr)  do
      AppendTo(file, " ??", x, "=\"\"" );
    od;
    if a.type = "empty" then
      AppendTo(file, "/>#\n\n");
    else
      AppendTo(file, ">XXX</", a.name, ">#\n\n" );
    fi;
  od;
  return;
end);

# these are simple translations from former GAPDoc version, below we add
# more using unicode characters
BindGlobal("TEXTMTRANSLATIONS",
  rec(
     ldots := "...",
     mid := "|",
     vert := "|",
     left := "",
     right := "",
     mathbb := "",
     mathop := "",
     limits := "",
     cdot := "*",
     ast := "*",
     geq := ">=",
     leq := "<=",
     neq := "<>",
     pmod := "mod ",
     bmod := "mod ",
     equiv := "=",
     sim := "~",
     rightarrow := "->",
     hookrightarrow := "->",
     to := "->",
     longrightarrow := "-->",
     Rightarrow := "=>",
     Longrightarrow := "==>",
     Leftarrow := "<=",
     iff := "<=>",
     mapsto := "->",            #  "|->"  looks ugly!
     leftarrow := "<-",
     langle := "<",
     prime := "'",
     rangle := ">",
     vee := "v",
     setminus := "\\",
     times := "x",
     colon := ":",
     bf := "",
     rm := "",
     textrm := "",
     sf := "",
     germ := "",
     text := "",
     thinspace := " ",
     \, := "",
     \! := "",
     \; := " ",
     \{ := "{",
     \} := "}",
     )
);

# add more text M translations using unicode characters, for those of these
# unicode characters which do not yet have a simplification, we add their
# LaTeX code as simplification to SimplifiedUnicodeTable (sometimes without
# the leading backslash)
CallFuncList( function()
  local hash, s, str, pos, a;
  hash := List(SimplifiedUnicodeTable, a-> a[1]);
  # the candidates to add are found in the LaTeXUnicodeTable
  for a in LaTeXUnicodeTable do
    if a[1] < 100000 and PositionSublist(a[2], "\\ensuremath") <> fail then
      s := ShallowCopy(a[2]);
      s := SubstitutionSublist(s, "\\ensuremath", "");
      RemoveCharacters(s, "{}");
      if not (s[1] <> '\\' or (Length(Positions(s, '\\')) > 1 and
                                        s{[1..5]}<>"\\not\\") or ' ' in s)  then
        str := Encode(Unicode([a[1]]), "UTF-8");
        pos := Position(hash, a[1]);
        TEXTMTRANSLATIONS.(s{[2..Length(s)]}) := str;
        if pos = fail then
          # for greek letters and a few more we simplify without backslash
          if (913 <= a[1] and 1014 >= a[1]) or a[1] in [8465,8476,8501,8502,
              8503,8504,8707,8710,8711,8712] then
            s := s{[2..Length(s)]};
          fi;
          Add(SimplifiedUnicodeTable, [a[1], IntListUnicodeString(Unicode(s))]);

        fi;
      fi;
    fi;
  od;
  Sort(SimplifiedUnicodeTable);
end, []);

InstallGlobalFunction(TextM, function(str)
  local subs, res, i, j;
  subs := Immutable(Set(NamesOfComponents(TEXTMTRANSLATIONS)));
  res := "";
  i := 1;
  while i <= Length(str) do
    # handle macros
    if str[i] = '\\' then
      j := i+1;
      while j <= Length(str) and str[j] in LETTERS do
        j := j+1;
      od;
      # we go on if we have a \not so far
      if j = i+4 and j <= Length(str) and str[j] = '\\' and 
                                     str{[i+1..i+3]} = "not" then
        j := j+1;
        while j <= Length(str) and str[j] in LETTERS do
          j := j+1;
        od;
      fi;
      # some spacing macros and braces
      if j = i+1 and str[j] in ";,!{}" then
        j := j+1;
      fi;
      if str{[i+1..j-1]} in subs then
        Append(res, TEXTMTRANSLATIONS.(str{[i+1..j-1]}));
      else
        Append(res, str{[i+1..j-1]});
      fi;
      i := j;
    elif str[i] = '{' then
      if i < Length(str) and str[i+1] = '{' then
        Add(res, '{');
        i := i + 2;
      else
        i := i + 1;
      fi;
    elif str[i] = '}' then
      if i < Length(str) and str[i+1] = '}' then
        Add(res, '}');
        i := i + 2;
      else
        i := i + 1;
      fi;
    else 
      Add(res, str[i]);
      i := i + 1;
    fi;
  od;
  NormalizeWhitespace(res);
  return res;
end);

# non-documented utility
##  normalizes the Args attribute in function like elements
InstallGlobalFunction(NormalizedArgList, function(argl)
  local pos, opt, f, tr, g;
  # first optional arguments
  pos := Position(argl, ':');
  if pos <> fail then
    opt := argl{[pos+1..Length(argl)]};
    argl := argl{[1..pos-1]};
    opt := SubstitutionSublist(opt, ":=", " := ");
    NormalizeWhitespace(opt);
    opt := SubstitutionSublist(opt, " := ", "OPTIONASSxpty");
    opt := NormalizedArgList(opt);
    opt := SubstitutionSublist(opt, "OPTIONASSxpty", " := ");
  else
    opt := "";
  fi;

  # remove ',' and split into tree
  argl := NormalizedWhitespace(SubstitutionSublist(argl, ",", " "));
  argl := SubstitutionSublist(argl, "[]", "");
  argl := SubstitutionSublist(argl, "[ ]", "");
  f := function(argl) 
    local tr, pos, pos2;
    tr := [];
    pos := 0;
    while true do
      pos2 := Position(argl, '[', pos);
      if pos2 <> fail then
        Append(tr, SplitString(argl{[pos+1..pos2-1]}, "", " "));
        pos := pos2;
        pos2 := PositionMatchingDelimiter(argl, "[]", pos);
        Add(tr, f(argl{[pos+1..pos2-1]}));
        pos := pos2;
      else
        Append(tr, SplitString(argl{[pos+1..Length(argl)]}, "", " "));
        return tr;
      fi;
    od;
  end;
  tr := f(argl);
  # put it back in a string with ','s and '[]'s in the right places
  g := function(tr, ne)
    local res, r, a, pos;
    res := "";
    for a in tr do
      if IsString(a) then
        if ne then
          Append(res, ", ");
        elif Length(res) > 0 then
##            Append(res, "[,]");
          pos := Length(res);
          while pos > 0 and res[pos] in " []," do
            pos := pos - 1;
          od;
          Add(res, ',', pos+1);
          Add(res, ' ', pos+2);
        fi;
        ne := true;
        Append(res, a);
      else
        r := Concatenation("[", g(a, ne), "]");
        if not ne and Length(res) > 0  then
##            Append(res, "[,]");
          pos := Length(res);
          while pos > 0 and res[pos] in " []," do
            pos := pos - 1;
          od;
          Add(res, ',', pos+1);
          Add(res, ' ', pos+2);
        fi;
        Append(res, r);
      fi;
    od;
    return res;
  end;
  tr := g(tr, false);
  if Length(opt) > 0 then
    Append(tr, ": ");
    Append(tr, opt);
  fi;
  return tr;
end);

# shared utility for the converters to read data for bibliography 
BindGlobal("GAPDocAddBibData", function(r) 
  local dat, datbt, bib, bibbt, b, keys, need, labels, tmp, pos, diff, a,
        j, p, lab, st;
  if not IsBound(r.bibdata) then
    return;
  fi;
  if IsBound(r.bibentries) and IsBound(r.biblabels) then
    return;
  fi;
  Info(InfoGAPDoc, 1, "#I Reading bibliography data files . . . \n");
  dat := SplitString(r.bibdata, "", ", \t\b\n");
  datbt := Filtered(dat, a-> Length(a) < 4 or 
                             a{[Length(a)-3..Length(a)]} <> ".xml");
  bib := rec(entries := [], strings := [], entities := []);
  # first BibTeX files, then BibXMLext files
  if Length(datbt) > 0 then
    Info(InfoGAPDoc, 1, "#I   BibTeX format: ",
                                    JoinStringsWithSeparator(datbt), "\n");
    bibbt := 
        CallFuncList(ParseBibFiles, List(datbt, f-> Filename(r.bibpath, f)));
    Info(InfoGAPDoc, 1, "#I   checking and translating to BibXMLext . . .\n");
    for a in bibbt[1] do
      b := StringBibAsXMLext(a, bibbt[2], bibbt[3]);
      if b <> fail then
        b := ParseBibXMLextString(b, bib);
      fi;
    od;
  fi;
  dat := Difference(dat, datbt);
  if Length(dat) > 0 then
    Info(InfoGAPDoc, 1, "#I   BibXMLext format: ",
                                          JoinStringsWithSeparator(dat), "\n");
    dat := List(dat, f-> Filename(r.bibpath, f));
    CallFuncList(ParseBibXMLextFiles, Concatenation(dat, [bib]));
  fi;

  keys := Immutable(Set(r.bibkeys));
  need := [];
  for a in bib.entries do
    if a.attributes.id in keys then
      Add(need, a);
    fi;
  od;
  need := List(need, a-> [a, RecBibXMLEntry(a, "Text")]);
  SortParallel(List(need, a-> SortKeyRecBib(a[2])), need);
  keys := List(need, a-> a[2].Label);

  # here we check if 'bibtex' is available, if yes we adjust the labels and
  # ordering of the references to those produced by 'bibtex'
  if Filename(DirectoriesSystemPrograms(), "bibtex") <> fail then
    tmp := Filename(DirectoryTemporary(), "tmp.bib");
    WriteBibFile(tmp, bib);
    if not IsBound(r.bibstyle) then
      st := "alpha";
    else
      st := r.bibstyle;
    fi;
    #ids := List(need, a->a[1].attributes.id);
    lab := LabelsFromBibTeX(".", keys, [tmp], st);
    RemoveFile(tmp);
    tmp := [];
    for p in lab do
      a := Position(keys, p[1]);
      if a <> fail then
        a := need[Position(keys, p[1])];
        a[2].key := HeuristicTranslationsLaTeX2XML.Apply(p[2]);
        Add(tmp, a);
      fi;
    od;
    need := tmp;
    keys := List(need, a-> a[2].Label);
  fi;

  # now we get the labels
  labels := List(need, function(a) if IsBound(a[2].key) then return
                          a[2].key; else return a[2].printedkey; fi; end);

  # make labels unique
  tmp := Filtered(Collected(labels), a-> a[2] > 1);
  for a in tmp do
    pos := Positions(labels, a[1]);
    for j in [1..Length(pos)] do
      Add(labels[pos[j]], SMALLLETTERS[j]);
    od;
  od;
  diff := Difference(r.bibkeys, keys);
  if Length(diff) > 0 then
    Info(InfoGAPDoc, 1, "#W WARNING: could not find these references: \n", 
                                                         diff, "\n");
  fi;
  r.bibkeys := keys;
  r.biblabels := labels;
  r.bibentries := List(need, a-> a[1]);
  r.bibstrings := bib.strings;
  if Length(r.bibstrings) = 0 then
    # to avoid that this is an empty string
    r.bibstrings := [[0,0]];
  fi;
end);

##  <#GAPDoc Label="SetGapDocLanguage">
##  <ManSection >
##  <Func Arg="[lang]" Name="SetGapDocLanguage" />
##  <Returns>nothing</Returns>
##  <Description>
##  <Index>Using &GAPDoc; with other languages</Index>
##  The  &GAPDoc;  converter  programs   sometimes  produce  text  which  is
##  not  explicit  in  the  document, e.g.,  headers  like  <Q>Abstract</Q>,
##  <Q>Appendix</Q>,   links   to   <Q>Next  Chapter</Q>,   variable   types
##  <Q>function</Q> and so on. <P/>
##  With <Ref Func="SetGapDocLanguage"/> the language for these texts can be
##  changed.  The argument  <A>lang</A> must  be a  string. Calling  without
##  argument or with a language name for which no translations are available
##  is the same as using the default <C>"english"</C>. <P/>
##  If your  language <A>lang</A> is not  yet available, look at  the record
##  <C>GAPDocTexts.english</C> and translate all the strings to <A>lang</A>.
##  Then  assign this  record to  <C>GAPDocTexts.(<A>lang</A>)</C> and  send
##  it  to  the  &GAPDoc;  authors  for  inclusion  in  future  versions  of
##  &GAPDoc;. (Currently, there are translations for <C>english</C>, 
##  <C>german</C>, <C>russian</C> and <C>ukrainian</C>.)<P/>
##  
##  <Emph>Further  hints:</Emph>   To  get   strings  produced   by  &LaTeX;
##  right  you  will  probably  use the  <C>babel</C>  package  with  option
##  <A>lang</A>,  see  <Ref Func="SetGapDocLaTeXOptions"/>. 
##  If <A>lang</A> cannot be encoded in <C>latin1</C>
##  encoding  you   can  consider  the   use  of  <C>"utf8"</C>   with  <Ref
##  Func="SetGapDocLaTeXOptions"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

# language dependent string used in converted documents
InstallValue(GAPDocTexts, rec());
# default is english
GAPDocTexts.english := rec(
  # for title page
  Titlepage := "Title page",
  Abstract := "Abstract",
  Copyright := "Copyright",
  Contents := "Contents",
  Email := "Email",
  Homepage := "Homepage",
  Address := "Address",
  Acknowledgements := "Acknowledgements",
  Colophon := "Colophon",
  # HTML navigation
  GotoChapter := "Goto Chapter",
  TopofBook := "Top of Book",
  PreviousChapter := "Previous Chapter",
  NextChapter := "Next Chapter",
  Top := "Top",
  # sectioning
  Chapter := "Chapter",
  Appendix := "Appendix",
  Index := "Index",
  References := "References",
  Bibliography := "Bibliography",
  TableofContents := "Table of Contents",
  # Other
  Returns := "Returns",
  Example := "Example",
  Log := "Example",
  Table := "Table",
  # variable types, should these be translated?
  Func := "function",
  Oper := "operation",
  Meth := "method",
  Filt := "filter",
  Prop := "property",
  Attr := "attribute",
  Var := "global variable",
  Fam := "family",
  InfoClass := "info class",
             );
InstallGlobalFunction(SetGapDocLanguage, function(arg)
  local lang;
  if Length(arg) > 0 then
    lang := arg[1];
  else
    lang := "english";
  fi;
  lang := LowercaseString(lang);
  if not IsBound(GAPDocTexts.(lang)) then
    Info(InfoGAPDoc, 1, "#W No texts in language ", lang, " available - ",
                         "using English.\n");
    Info(InfoGAPDoc, 1, "#W Please, provide translation of GAPDocTexts.",
                          "english in GAPDocTexts.", lang, ".\n");
    lang := "english";
  fi;
  GAPDocTexts.d := GAPDocTexts.(lang);
end);
# default
SetGapDocLanguage();

# translation to Russian and Ukrainian, provided by Alexander Konovalov
GAPDocTexts.russian := rec(
  # for title page
  Titlepage := "Титульная страница",
  Abstract := "Реферат",
  Copyright := "Copyright", # internationally recognized
  Contents := "Содержание",  
  Email := "Email",         # internationally recognized
  Homepage := "WWW",        # internationally recognized
  Address := "Адрес",
  Acknowledgements := "Благодарности",
  Colophon := "Выходные данные",
  # HTML navigation
  GotoChapter := "Перейти к главе",
  TopofBook := "Начало книги",
  PreviousChapter := "Предыдущая глава",
  NextChapter := "Следующая глава",
  Top := "Начало",
  # sectioning
  Chapter := "Глава",
  Appendix := "Приложение",
  Index := "Индекс",
  References := "Ссылки",
  Bibliography := "Библиография",
  TableofContents := "Содержание",
  # Other
  Returns := "Результат", 
  # The Russian word for "Returns" is actually the translation of "Result",
  # hope this does not make any harm in the context.
  Example := "Пример",
  Log := "Пример",
  Table := "Таблица",
  # variable types, should these be translated?
  Func := "функция",
  Oper := "операция",
  Meth := "метод",
  Filt := "фильтр",
  Prop := "свойство",
  Attr := "атрибут",
  Var := "глобальная переменная",
  Fam := "семейство",
  InfoClass := "инфокласс",
             );


GAPDocTexts.ukrainian := rec(
  # for title page
  Titlepage := "Титульна сторінка",
  Abstract := "Реферат",
  Copyright := "Copyright", # internationally recognized
  Contents := "Зміст",
  Email := "Email",         # internationally recognized
  Homepage := "WWW",        # internationally recognized
  Address := "Адреса",
  Acknowledgements := "Подяки",
  Colophon := "Вихідні дані",
  # HTML navigation
  GotoChapter := "Перейти до розділу",
  TopofBook := "Початок книги",
  PreviousChapter := "Попередній розділ",
  NextChapter := "Наступний розділ",
  Top := "Початок",
  # sectioning
  Chapter := "Розділ",
  Appendix := "Додаток",
  Index := "Індекс",
  References := "Посилання",
  Bibliography := "Бібліографія",
  TableofContents := "Зміст",
  # Other
  Returns := "Результат", 
  # The Ukrainian word for "Returns" is actually the translation of "Result",
  # hope this does not make any harm in the context.
  Example := "Приклад",
  Log := "Приклад",
  Table := "Таблиця",
  # variable types, should these be translated?
  Func := "функція",
  Oper := "операція",
  Meth := "метод",
  Filt := "фільтр",
  Prop := "властивість",
  Attr := "атрибут",
  Var := "глобальна змінна",
  Fam := "родина",
  InfoClass := "інфоклас",
             );
# ok, I can do this one
GAPDocTexts.german := rec(
  # for title page
  Titlepage := "Titelseite",
  Abstract := "Zusammenfassung",
  Copyright := "Copyright",
  Contents := "Inhalt",
  Email := "Email",
  Homepage := "WWW",
  Address := "Adresse",
  Acknowledgements := "Danksagungen",
  Colophon := "Kolofon",
  # HTML navigation
  GotoChapter := "Zum Kapitel",
  TopofBook := "Buchanfang",
  PreviousChapter := "Voriges Kapitel",
  NextChapter := "Nächstes Kapitel",
  Top := "Nach oben",
  # sectioning
  Chapter := "Kapitel",
  Appendix := "Anhang",
  Index := "Stichwortverzeichnis",
  References := "Literatur",
  Bibliography := "Literatur",
  TableofContents := "Inhaltsverzeichnis",
  # Other
  Returns := "Gibt zurück",
  Example := "Beispiel",
  Log := "Beispiel",
  Table := "Tabelle",
  # variable types, should these be translated?
  Func := "Funktion",
  Oper := "Operation",
  Meth := "Methode",
  Filt := "Filter",
  Prop := "Eigenschaft",
  Attr := "Attribut",
  Var := "globale Variable",
  Fam := "Familie",
  InfoClass := "Info-Klasse",
             );

