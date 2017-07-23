#############################################################################
##
#W  BibTeX.gi                    GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibTeX.g{d,i} contain a parser for BibTeX files and some
##  functions for printing BibTeX entries in different formats.
##  

##  normalize author/editor name lists: last-name, initial(s) of first
##  name(s) and ...
##  see Lamport: LaTeX App.B 1.2
InstallGlobalFunction(NormalizedNameAndKey, function(str)
  local   isutf8, nbsp, ini, new,  pp,  p,  a,  i,  names,  norm,  keyshort,  
          keylong,  res, utf8initial;
  utf8initial := function(s)
    local i, n;
    i := 1;
    while Length(s) <= i and s[i] in "-.{}\\\"\'`\003" do
      i := i+1;
    od;
    if i > Length(s) then
      return fail;
    fi;
    n := UNICODE_RECODE.UnicodeUTF8Char(s, i);
    return Encode(Unicode([n]),"UTF-8");
  end;
  # do almost nothing if already list of strings (e.g., from BibXMLext tools
  if IsString(str) then
    isutf8 := (Unicode(str) <> fail);
    # first normalize white space inside braces { ... } and change
    # spaces to non-spaces (removed below)
    nbsp := '\003';
    new := "";
    pp := 0;
    p := Position(str, '{');
    while p <> fail do
      Append(new, str{[pp+1..p-1]});
      pp := PositionMatchingDelimiter(str, "{}", p);
      a := NormalizedWhitespace(str{[p..pp]});
      for i in [1..Length(a)] do
        if a[i] = ' ' then
          a[i] := nbsp;
        fi;
      od;
      Append(new, a);
      p := Position(str, '{', pp);
    od;
    if Length(new)>0 then
      str := Concatenation(new, str{[pp+1..Length(str)]});
    fi;
    
    # split into names:
    names := [];
    pp := 0;
    p := PositionSublist(str, "and");
    while p <> fail do
      # "and" is only delimiter if surrounded by white space
      if not (str[p-1] in WHITESPACE and Length(str)>p+2 and str[p+3] in
                 WHITESPACE) then
        p := PositionSublist(str, "and", p);
      else
        Add(names, str{[pp+1..p-2]});
        pp := p+3;
        p := PositionSublist(str, "and", pp);
      fi;
    od;
    Add(names, str{[pp+1..Length(str)]});
    
    # normalize a single name
    norm := function(str)
      local   n,  i,  lnam,  j,  fnam, fnamfull;
      # special case "et. al."
      if str="others" then
        return ["others", "", ""];
      fi;
     
      # first some normalization on the string
      RemoveCharacters(str,"[]");
      str := SubstitutionSublist(str, "\\~", "BSLTILDE");
      str := SubstitutionSublist(str, "~", " ");
      str := SubstitutionSublist(str, "BSLTILDE", "\\~");
      str := SubstitutionSublist(str, ".", ". ");
      StripBeginEnd(str, WHITESPACE);
      n := SplitString(str, "", WHITESPACE);
      # check if in "lastname, firstname" notation
      # find last ","
      i := Length(n);
      while i>0 and n[i]<>"," and n[i][Length(n[i])] <> ',' do
        i := i-1;
      od;
      if i>0 then
        # last name
        lnam := "";
        for j in [1..i] do
          Append(lnam, n[j]);
          if j < i then
            Add(lnam, ' ');
          fi;
          lnam := Filtered(lnam, x-> x<>',');
        od;
        # first name initials
        fnam := "";
        for j in [i+1..Length(n)] do
          if isutf8 then
            ini := utf8initial(n[j]);
          else
            ini := First(n[j], x-> not x in WHITESPACE 
                              and not x in "-.{}\\\"\'`\003");
            if ini <> fail then
              ini := [ini];
            fi;
          fi;
          if ini <> fail then
            Append(fnam, ini);
            Append(fnam, ". ");
          fi;
        od;
        fnamfull := JoinStringsWithSeparator(n{[i+1..Length(n)]}, " ");
      else
        # last name is last including words not starting with
        # capital letters
        i := Length(n);
        while i>1 and First(n[i-1], a-> a in LETTERS) in SMALLLETTERS do
          i := i-1;
        od;
        # last name 
        lnam := "";
        for j in [i..Length(n)] do
          Append(lnam, n[j]);
          if j < Length(n) then
            Add(lnam, ' ');
          fi;
        od;
        # first name initials
        fnam := "";
        for j in [1..i-1] do
          if isutf8 then
            ini := utf8initial(n[j]);
          else
            ini := First(n[j], x-> not x in WHITESPACE 
                              and not x in "-.{}\\\"\'`\003");
            if ini <> fail then
              ini := [ini];
            fi;
          fi;
          if ini <> fail then
            Append(fnam, ini);
            Append(fnam, ". ");
          fi;
        od;
        fnamfull := JoinStringsWithSeparator(n{[1..i-1]}, " ");
      fi;
      for j in [1..Length(lnam)] do
        if lnam[j] = '\003' then
          lnam[j] := ' ';
        fi;
      od;
      for j in [1..Length(fnamfull)] do
        if fnamfull[j] = '\003' then
          fnamfull[j] := ' ';
        fi;
      od;
      while Length(fnam) > 0 and fnam[Length(fnam)] in WHITESPACE do
        fnam := fnam{[1..Length(fnam)-1]};
      od;
      return [lnam, fnam, fnamfull];
    end;
    
    names := List(names, norm);
  else
    names := str;
  fi;
  keyshort := "";
  keylong := "";
  res := "";
  for a in names do
    if Length(res)>0 then
      Append(res, " and ");
    fi;
    Append(res, a[1]);
    Append(res, ", ");
    Append(res, a[2]);
    if a[1] = "others" then
      Add(keyshort, '+');
    else
      p := 1;
      while p <= Length(a[1]) and not a[1][p] in CAPITALLETTERS do
        p := p+1;
      od;
      if p > Length(a[1]) then
        p := 1;
      fi;
      if a[1][p] in LETTERS then
        Add(keyshort, a[1][p]);
      else
        Add(keyshort, 'X');
      fi;
      Append(keylong, STRING_LOWER(Filtered(a[1]{[p..Length(a[1])]},
              x-> x in LETTERS)));
    fi;
  od;
  if Length(keyshort)>3 then
    keyshort := keyshort{[1,2]};
    Add(keyshort, '+');
  fi;
  return [res, keyshort, keylong, names];
end);

##  <#GAPDoc Label="ParseBibFiles">
##  <ManSection >
##  <Func Arg="bibfile1[, bibfile2[, ...]]" Name="ParseBibFiles" />
##  <Func Arg="str1[, str2[, ...]]" Name="ParseBibStrings" />
##  <Returns>list <C>[list of bib-records, list of abbrevs, list  of 
##  expansions]</C></Returns>
##  <Description>
##  The first function parses the files <A>bibfile1</A> and so on (if a file 
##  does not
##  exist the  extension <C>.bib</C> is appended)  in &BibTeX; format
##  and returns a list  as follows: <C>[entries, strings, texts]</C>.
##  Here <C>entries</C>  is a  list of records,  one record  for each
##  reference  contained in  <A>bibfile</A>.  Then <C>strings</C>  is
##  a  list of  abbreviations  defined  by <C>@string</C>-entries  in
##  <A>bibfile</A> and <C>texts</C>  is a list which  contains in the
##  corresponding position  the full  text for such  an abbreviation.
##  <P/>
##  The second function does the same, but the input is given as &GAP; strings
##  <A>str1</A> and so on.<P/>
##  
##  The records in <C>entries</C> store key-value pairs of a &BibTeX;
##  reference in the  form <C>rec(key1 = value1,  ...)</C>. The names
##  of  the  keys are  converted  to  lower  case.  The type  of  the
##  reference (i.e.,  book, article,  ...) and  the citation  key are
##  stored as  components <C>.Type</C> and <C>.Label</C>. The records
##  also have a   <C>.From</C> field that says that the data are read 
##  from a &BibTeX; source.<P/>
##  
##  As an example consider the following &BibTeX; file.
##  
##  <Listing Type="doc/test.bib">
##  @string{ j  = "Important Journal" }
##  @article{ AB2000, Author=  "Fritz A. First and Sec, X. Y.", 
##  TITLE="Short", journal = j, year = 2000 }
##  </Listing> 
##  
##  <Example>
##  gap> bib := ParseBibFiles("doc/test.bib");
##  [ [ rec( From := rec( BibTeX := true ), Label := "AB2000", 
##            Type := "article", author := "Fritz A. First and Sec, X. Y."
##              , journal := "Important Journal", title := "Short", 
##            year := "2000" ) ], [ "j" ], [ "Important Journal" ] ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ParseBibFiles, function(arg)
  local s, entries, stringlabels, strings, str, file;
  s := Filtered(arg, x-> IsList(x) and not IsString(x));
  if Length(s) > 0 then
    entries := s[1][1];
    stringlabels := s[1][2]; 
    strings := s[1][3];
    arg := Filtered(arg, IsString);
  else
    entries := [];
    stringlabels := []; 
    strings := [];
  fi;
  
  for file in arg do
    str := StringFile(file);
    if str=fail then
      str := StringFile(Concatenation(file, ".bib"));
    fi;
    if str=fail then 
      Info(InfoBibTools, 1, "#W WARNING: Cannot find bib-file ", 
                                                      file, "[.bib]\n");
      return fail;
    fi;
    ParseBibStrings(str, [entries, stringlabels, strings]);
  od;
  return [entries, stringlabels, strings];
end);

InstallGlobalFunction(ParseBibStrings, function(arg)
  local s, entries, stringlabels, strings, p, r, pb, Type, ende, comp, pos, str;
  s := Filtered(arg, x-> IsList(x) and not IsString(x));
  if Length(s) > 0 then
    entries := s[1][1];
    stringlabels := s[1][2]; 
    strings := s[1][3];
    arg := Filtered(arg, IsString);
  else
    entries := [];
    stringlabels := []; 
    strings := [];
  fi;
  
  for str in arg do
    # find entries
    p := Position(str, '@');
    while p<>fail do
      r := rec();
      # type 
      pb := Position(str, '{', p);
      s := LowercaseString(StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE));
      p := pb;
      if s = "string" then
        # a string is normalized and stored for later substitutions 
        pb := Position(str, '=', p);
        Add(stringlabels, 
            LowercaseString(StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE)));
        p := pb;
        pb := PositionMatchingDelimiter(str, "{}", p);
        s := StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE);
        if (s[1]='\"' and s[Length(s)]='\"') or
           (s[1]='{' and s[Length(s)]='}') then
          s := s{[2..Length(s)-1]};
        fi;
        Add(strings, s);
        p := pb;
      else
        # type and label of entry
        r := rec(From := rec(BibTeX := true), Type := s);
        # end of bibtex entry, for better recovery from errors
        ende := PositionMatchingDelimiter(str, "{}", p);
        pb := Position(str, ',', p);
        if not IsInt(pb) or pb > ende then 
          # doesn't seem to be a correct entry, ignore
          p := Position(str, '@', ende);
          continue;
        fi;
        r.Label := StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE);
        p := pb;
        # get the components
        pb := Position(str, '=', p);
        while pb<>fail and pb < ende do
          comp := LowercaseString(StripBeginEnd(str{[p+1..pb-1]}, 
                          Concatenation(",", WHITESPACE)));
          pb := pb+1;
          while str[pb] in WHITESPACE do
            pb := pb+1;
          od;
          p := pb;
          if str[p] = '\"' then
            pb := Position(str, '\"', p);
            # if double quote is escaped, then go to next one
            while str[pb-1]='\\' do
              pb := Position(str, '\"', pb);
            od;
            r.(comp) := str{[p+1..pb-1]};
          elif str[p] = '{' then
            pb := PositionMatchingDelimiter(str, "{}", p);
            r.(comp) := str{[p+1..pb-1]};
          else 
            pb := p+1;
            while (not str[pb] in WHITESPACE) and str[pb] <> ',' and 
                       str[pb] <> '}' do
              pb := pb+1;
            od;
            s := str{[p..pb-1]};
            # number 
            if Int(s)<>fail then
              r.(comp) := s;
            else
              # abbrev string, look up and substitute
              s := LowercaseString(s);
              pos := Position(stringlabels, s);
              if pos=fail then
                r.(comp) := Concatenation("STRING-NOT-KNOWN: ", s);
              else
                r.(comp) := strings[pos];
              fi;  
            fi;
          fi;
          p := pb+1;
          pb := Position(str, '=', p);
        od;
        Add(entries, r);
      fi;
      p := Position(str, '@', p);
    od;
  od;
  return [entries, stringlabels, strings];
end);

##  <#GAPDoc Label="NormalizeNameAndKey">
##  <ManSection >
##  <Func Arg="namestr" Name="NormalizedNameAndKey" />
##  <Returns>list of strings and names as lists</Returns>
##  <Func Arg="r" Name="NormalizeNameAndKey" />
##  <Returns>nothing</Returns>
##  <Description>
##  The argument <A>namestr</A> must be a string describing an author or a list
##  of authors as described in the &BibTeX; documentation in <Cite  Key="La85"
##  Where="Appendix  B 1.2"/>. The function <Ref Func="NormalizedNameAndKey"
##  /> returns a list of the form [ normalized name string, short key, long
##  key, names as lists]. The first entry is a normalized form
##  of the input where names are written as <Q>lastname, first name
##  initials</Q>. The second and third entry are the name parts of a short and
##  long key for the bibliography entry, formed from the (initials of) last
##  names. The fourth entry is a list of lists, one for each name, where a 
##  name is described by three strings for the last name, the first name
##  initials and the first name(s) as given in the input. <P/>
##  
##  The function <Ref Func="NormalizeNameAndKey"/> gets as argument <A>r</A> 
##  a record for a bibliography entry as returned by <Ref  Func="ParseBibFiles"
##  />. It substitutes  <C>.author</C> and <C>.editor</C> fields of <A>r</A> by
##  their normalized form, the original versions are stored in  fields
##  <C>.authororig</C> and <C>.editororig</C>.<P/> 
##  
##  Furthermore a short and a long citation key is generated and stored
##  in components <C>.printedkey</C> (only if no <C>.key</C> is already
##  bound) and <C>.keylong</C>.<P/> 
##  
##  We continue the example from <Ref  Func="ParseBibFiles"  />.
##  
##  <Example>
##  gap> bib := ParseBibFiles("doc/test.bib");;
##  gap> NormalizedNameAndKey(bib[1][1].author);
##  [ "First, F. A. and Sec, X. Y.", "FS", "firstsec", 
##    [ [ "First", "F. A.", "Fritz A." ], [ "Sec", "X. Y.", "X. Y." ] ] ]
##  gap> NormalizeNameAndKey(bib[1][1]);
##  gap> bib[1][1];
##  rec( From := rec( BibTeX := true ), Label := "AB2000", 
##    Type := "article", author := "First, F. A. and Sec, X. Y.", 
##    authororig := "Fritz A. First and Sec, X. Y.", 
##    journal := "Important Journal", keylong := "firstsec2000", 
##    printedkey := "FS00", title := "Short", year := "2000" )
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(NormalizeNameAndKey, function(b)
  local   yy,  y,  names,  nn;
  if IsBound(b.year) then
    if IsInt(b.year) then
      yy := String(b.year);
      y := String(b.year mod 100);
    else
      yy := b.year;
      y := b.year{[Length(b.year)-1, Length(b.year)]};
    fi;
  else
    yy := "";
    y := "";
  fi;
  for names in ["author", "editor"] do
    if IsBound(b.(names)) then
      nn := NormalizedNameAndKey(b.(names));
      if nn[1] <> b.(names) then
        b.(Concatenation(names, "orig")) := b.(names);
        b.(names) := nn[1];
      fi;
      if not IsBound(b.key) then
        b.printedkey := Concatenation(nn[2], y);
      fi;
      if not IsBound(b.keylong) then
        b.keylong := Concatenation(nn[3], yy);
      fi;
    fi;
  od;
  if not IsBound(b.keylong) then
    b.keylong := "xxx";
  fi;
  if not (IsBound(b.key) or IsBound(b.printedkey)) then
    b.printedkey := "xxx";
  fi;
end);

# small utility
BindGlobal("AndToCommaNames", function(str)
  local n, p, i;
  str := NormalizedWhitespace(str);
  n := 0;
  p := PositionSublist(str, " and ");
  while p <> fail do
    n := n+1;
    p := PositionSublist(str, " and ", p);
  od;
  for i in [1..n-1] do
    str := SubstitutionSublist(str, " and ", ", ", false);
  od;
  if n > 1 then
    str := SubstitutionSublist(str, " and ", ", and ", false);
  fi;
  return str;
end);
  

# print out a bibtex entry, the ordering of fields is normalized and
# type and field names are in lowercase, also some formatting is done
# arg: entry[, abbrevs, texts]    where abbrevs and texts are lists
#      of same length abbrevs[i] is string macro for texts[i]
InstallGlobalFunction(StringBibAsBib, function(arg)
  local r, abbrevs, texts, res, ind, fieldlist, pos, lines, comp;
  
  # scan arguments
  r := arg[1];
  if Length(arg)>2 then
    abbrevs := arg[2];
    texts := arg[3];
  else
    abbrevs := [];
    texts := [];
  fi;

  res := "";
  
  if not IsBound(r.Label) then
    Info(InfoBibTools, 1, "#W WARNING: no .Label in Bib-record");
    Info(InfoBibTools, 2, ":\n", r);
    Info(InfoBibTools, 1, "\n");
    
    return fail;
  fi;
  ind := RepeatedString(' ', 22);
  fieldlist := [
                "author",
                "editor",
                "booktitle",
                "title",
                "journal",
                "month",
                "organization",
                "institution",
                "publisher",
                "school",
                "edition",
                "series",
                "volume",
                "number",
                "address",
                "year",
                "pages",
                "chapter",
                "crossref",
                "note",
                "notes",
                "howpublished", 
                "key",
                "coden", 
                "fjournal", 
                "isbn", 
                "issn", 
                "location", 
                "mrclass", 
                "mrnumber", 
                "mrreviewer", 
                "organisation", 
                "reviews", 
                "source", 
                "url",
                "keywords" ];

  Append(res, Concatenation("@", r.Type, "{ ", r.Label));
  for comp in Concatenation(fieldlist,
          Difference(NamesOfComponents(r), Concatenation(fieldlist,
                ["From", "Type", "Label","authorAsList", "editorAsList"]) )) do
    if IsBound(r.(comp)) then
      Append(res, Concatenation(",\n  ", comp, " = ", 
                              ListWithIdenticalEntries(16-Length(comp), ' ')));
      pos := Position(texts, r.(comp));
      if pos <> fail then
        Append(res, abbrevs[pos]);
      else
        Append(res, "{");
        lines := FormatParagraph(r.(comp), SizeScreen()[1]-26, 
                                 "both", [ind, ""]);
        Append(res, lines{[Length(ind)+1..Length(lines)-1]});
        Append(res, "}");
      fi;
    fi;
  od;
  Append(res, "\n}\n");
  return res;
end);
InstallGlobalFunction(PrintBibAsBib, function(arg)
  PrintFormattedString(CallFuncList(StringBibAsBib, arg));
end);

##  <#GAPDoc Label="WriteBibFile">
##  <ManSection >
##  <Func Arg="bibfile, bib" Name="WriteBibFile" />
##  <Returns>nothing</Returns>
##  <Description>
##  This  is   the  converse  of  <Ref  Func="ParseBibFiles"/>.  Here
##  <A>bib</A>  either must  have  a  format as list of three lists  
##  as  it  is  returned  by  <Ref
##  Func="ParseBibFiles"/>. Or <A>bib</A> can be a record as returned
##  by <Ref Func="ParseBibXMLextFiles"/>. 
##  A &BibTeX; file <A>bibfile</A> is written
##  and  the  entries are  formatted  in  a  uniform way.  All  given
##  abbreviations are used while writing this file.<P/>
##  
##  We continue the example from <Ref   Func="NormalizeNameAndKey"/>.
##  The command
##  
##  <Example>
##  gap> WriteBibFile("nicer.bib", bib);
##  </Example>
##  
##  produces a file <F>nicer.bib</F> as follows:
##  
##  <Listing Type="nicer.bib">
##  @string{j = "Important Journal" }
##  
##  @article{ AB2000,
##    author =           {First, F. A. and Sec, X. Y.},
##    title =            {Short},
##    journal =          j,
##    year =             {2000},
##    authororig =       {Fritz A. First and Sec, X. Y.},
##    keylong =          {firstsec2000},
##    printedkey =       {FS00}
##  }
##  </Listing>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(WriteBibFile, function(file, bib)
  local   p,  b3,  a,  b,  pos,  f;
  
  if IsRecord(bib) and IsBound(bib.entries) and IsBound(bib.strings) then
    b := bib;
    bib := [];
    bib[1] := List(b.entries, a-> RecBibXMLEntry(a, "BibTeX", b.strings));
    bib[2] := List(b.strings, a-> a[1]);
    bib[3] := List(b.strings, a-> a[2]);
  fi;

  # collect abbrevs 
  p := [];
  SortParallel(bib[3], bib[2]);
  b3 := Immutable(bib[3]);
  IsSet(b3);
  for a in bib[1] do
    for b in NamesOfComponents(a) do
      pos := Position(b3, a.(b));
      if pos <> fail then
        Add(p, pos);
      fi;
    od;
  od;
  p := Set(p);
  
  f := function()
    local   i,  a;
    Print("\n\n");
    # the `string's
    for i in p do
      Print("@string{", bib[2][i], " = \"", b3[i], "\" }\n");
    od;        
    Print("\n\n");  
    for a in bib[1] do
      PrintBibAsBib(a, bib[2], b3);
    od;
  end;
  
  PrintTo1(file, f);
end);

# a utility for translating LaTeX macros for non ascii characters into
# HTML entities; also removing {}'s, and "\-" hyphenation hints.
BindGlobal("LaTeXToHTMLString", function(str)
  local trans_bs, trans_qq, i, pos;
  # macros for accents starting with '\', add new entries - somehow more
  # frequent ones first - as they become necessary
  trans_bs := [ ["\\\"a","&auml;"], ["\\\"o","&ouml;"], ["\\\"u","&uuml;"],
                ["\\\"{a}","&auml;"], ["\\\"{o}","&ouml;"], 
                ["\\\"{u}","&uuml;"], ["\\\"{s}","&szlig;"], 
                ["\\\"s","&szlig;"], ["\\3","&szlig;"], ["\\ss","&szlig;"],
                ["\\\"A","&Auml;"], ["\\\"O","&Ouml;"], ["\\\"U","&Uuml;"],
                ["\\'e","&eacute;"], ["\\`e","&egrave;"], 
                ["\\'E","&Eacute;"], ["\\`E","&Egrave;"],
                ["\\'a","&aacute;"], ["\\`a","&agrave;"],
                ["\\c{c}", "&ccedil;"], ["\\c c", "&ccedil;"], 
                # long Hungarian umlaut, substituted by unicode entity
                #    (see http://www.unicode.org/charts/)
                ["\\H{o}", "&#x0151;"], ["\\H o", "&#x0151;"],
                ["\\'A","&Aacute;"], ["\\'I","&Iacute;"], ["\\'O","&Oacute;"],
                ["\\'U","&Uacute;"], ["\\'i","&iacute;"],
                ["\\'o","&oacute;"], ["\\'u","&uacute;"],
                ["\\`A","&Agrave;"], ["\\`I","&Igrave;"], ["\\`O","&Ograve;"],
                ["\\`U","&Ugrave;"], ["\\`i","&igrave;"],
                ["\\`o","&ograve;"], ["\\`u","&ugrave;"] 
                ];
  # and some starting with '"' from 'german' styles
  trans_qq := [ ["\"a","&auml;"], ["\"o","&ouml;"], ["\"u","&uuml;"],
                ["\"s","&szlig;"],  ["\"A","&Auml;"], ["\"O","&Ouml;"], 
                ["\"U","&Uuml;"] ];
                
  i := 0; pos := Position(str, '\\');
  while pos <> fail and i < Length(trans_bs) do
    i := i + 1;
    str := ReplacedString(str, trans_bs[i][1], trans_bs[i][2]);
    pos := Position(str, '\\');
  od;
  i := 0; pos := Position(str, '\"');
  while pos <> fail and i < Length(trans_qq) do
    i := i + 1;
    str := ReplacedString(str, trans_qq[i][1], trans_qq[i][2]);
    pos := Position(str, '\"');
  od;
  # throw away {}'s and "\-"'s
  if Position(str, '{') <> fail then
    str := Filtered(str, c-> c <> '{' and c <> '}');
  fi;
  str := ReplacedString(str, "\\-", "");

  return str;
end);
                
##  arg: r[, escape]  (with escape = false it is assumed that entries are
##                     already HTML)
InstallGlobalFunction(StringBibAsHTML, function(arg)
  local   r,  i, str, res, esc, key, mrnumber, booklike;
  r := arg[1];
  if Length(arg)=2 then
    esc := arg[2];
  else
    if IsBound(r.From) and IsBound(r.From.BibXML) and r.From.BibXML = true then
      esc := false;
    else
      esc := true;
    fi;
  fi;
  
  if not IsBound(r.Label) then
    Info(InfoBibTools, 1, "#W WARNING: no .Label in Bib-record");
    Info(InfoBibTools, 2, ":\n", r);
    Info(InfoBibTools, 1, "\n");
    return fail;
  fi;

  # some details are set differently for book-like references
  if r.Type in [ "book", "booklet", "manual", "techreport", "mastersthesis", 
                 "phdthesis", "proceedings" ] then
    booklike := true;
  else
    booklike := false;
  fi;

  res := "";

  # remove SGML markup characters in entries and translate
  # LaTeX macros for accented characters to HTML, remove {}'s
  if esc = true then
    r := ShallowCopy(r);
    for i in NamesOfComponents(r) do
      if IsString(r.(i)) then
        str := "";
        GAPDoc2HTMLProcs.PCDATAFILTER(rec(content := r.(i)), str);
        if str <> r.(i) then
          r.(i) := str;
        fi;
        r.(i) := LaTeXToHTMLString(r.(i));
        if i in ["title", "subtitle", "booktitle"] then
          r.(i) := Filtered(r.(i), x -> not x in "{}");
        fi;
      fi;
    od;
  fi;
  
  if IsBound(r.key) then
    key := r.key;
  elif IsBound(r.printedkey) then
    key := r.printedkey;
  else
    key := r.Label;
  fi;
  if IsBound(r.mrnumber) then
    mrnumber:= r.mrnumber;
    if ' ' in mrnumber then
      mrnumber:= mrnumber{ [ 1 .. Position( mrnumber, ' ' ) - 1 ] };
    fi;
    Append(res, Concatenation(
      "<p class='BibEntry'>\n[<span class='BibKeyLink'><a href=\"http://www.ams.org/mathscinet-getitem?mr=",
      mrnumber, "\">", key, "</a></span>]   "));
  else
    Append(res, Concatenation("<p class='BibEntry'>\n[<span class='BibKey'>", 
                    key, "</span>]   "));
  fi;
  # standard BibTeX-styles typeset a type if not given
  if r.Type = "phdthesis" and not IsBound(r.type) then
    r := ShallowCopy(r);
    r.type := "Ph.D. thesis";
  elif r.Type = "mastersthesis" and not IsBound(r.type) then
    r := ShallowCopy(r);
    r.type := "Master's thesis";
  fi;
  # we assume with the "," delimiters that at least one of .author,
  # .editor or .title exist
  if IsBound(r.author) then
    Append(res, Concatenation("<b class='BibAuthor'>", 
                AndToCommaNames(r.author),"</b>"));
  fi;
  if IsBound(r.editor) then
  if PositionSublist( r.editor, " and " ) = fail then
      Append(res, Concatenation(" (<span class='BibEditor'>", 
                  AndToCommaNames(r.editor), "</span>, Ed.)"));
  else
      Append(res, Concatenation(" (<span class='BibEditor'>", 
                  AndToCommaNames(r.editor), "</span>, Eds.)"));
  fi;
  fi;
  if IsBound(r.title) then
    if ForAny(["author", "editor"], a-> IsBound(r.(a))) then
      Add(res, ',');
    fi;
    Append(res, Concatenation("\n <i class='BibTitle'>", r.title, "</i>"));
  fi;
  if IsBound(r.booktitle) then
    Append( res, ",\n " );
    if r.Type in ["inproceedings", "incollection"] then
      Append(res, " in ");
    fi;
    Append(res, Concatenation(" <i class='BibBooktitle'>", 
                r.booktitle, "</i>"));
  fi;
  if IsBound(r.subtitle) then
    Append(res, Concatenation("\n <i class='BibSubtitle'>&ndash;", 
                r.subtitle, "</i>"));
  fi;
  if IsBound(r.journal) then
    Append(res, Concatenation(",\n <span class='BibJournal'>", 
                r.journal, "</span>"));
  fi;
  if IsBound(r.type) then
    Append(res, Concatenation(",\n <span class='BibType'>", 
                r.type, "</span>"));
  fi;
  if IsBound(r.organization) then
    Append(res, Concatenation(",\n <span class='BibOrganization'>", 
                r.organization, "</span>"));
  fi;
  if IsBound(r.institution) then
    Append(res, Concatenation(",\n <span class='BibOrganization'>", 
                r.institution, "</span>"));
  fi;
  if IsBound(r.publisher) then
    Append(res, Concatenation(",\n <span class='BibPublisher'>", 
                r.publisher, "</span>"));
  fi;
  if IsBound(r.school) then
    Append(res, Concatenation(",\n <span class='BibSchool'>", r.school, "</span>"));
  fi;
  if IsBound(r.edition) then
    Append(res, Concatenation(",\n <span class='BibEdition'>", 
                r.edition, " edition", "</span>"));
  fi;
  if IsBound(r.series) then
    Append(res, Concatenation(",\n <span class='BibSeries'>", 
                r.series, "</span>"));
  fi;
  if IsBound(r.volume) then
    Append(res, Concatenation(",\n <em class='BibVolume'>", 
                r.volume, "</em>"));
  fi;
  if IsBound(r.number) then
    Append(res, Concatenation(" (<span class='BibNumber'>", 
                r.number, "</span>)"));
  fi;
  if IsBound(r.address) then
    Append(res, Concatenation(",\n <span class='BibAddress'>", 
                r.address, "</span>"));
  fi;
  if IsBound(r.year) then
    Append(res, Concatenation("\n (<span class='BibYear'>", 
                r.year, "</span>)"));
  fi;
  if IsBound(r.pages) then
    if booklike then
      Append(res, Concatenation(",\n <span class='BibPages'>", 
                  r.pages, " pages</span>"));
    else
      Append(res, Concatenation(",\n <span class='BibPages'>", 
                  r.pages, "</span>"));
    fi;
  fi;
  if IsBound(r.chapter) then
    Append(res, Concatenation(",\n <span class='BibChapter'>Chapter ", 
                r.chapter, "</span>"));
  fi;
  if IsBound(r.note) then
    Append(res, Concatenation("<br />\n(<span class='BibNote'>", 
                r.note, "</span>", ")"));
  fi;
  if IsBound(r.notes) then
    Append(res, Concatenation("<br />\n(<span class='BibNotes'>", 
                r.notes, "</span>", ")"));
  fi;
  if IsBound(r.howpublished) then
    Append(res, Concatenation(",\n<span class='BibHowpublished'>", 
                r.howpublished, "</span>"));
  fi;
 
  if IsBound(r.BUCHSTABE) then
    Append(res, Concatenation("<br />\nEinsortiert unter ", 
                r.BUCHSTABE, ".<br />\n"));
  fi;
  if IsBound(r.LDFM) then
    Append(res, Concatenation("Signatur ", r.LDFM, ".<br />\n"));
  fi;
  if IsBound(r.BUCHSTABE) and i>=0 then
    Append(res, Concatenation("<a href=\"HTMLldfm", r.BUCHSTABE, ".html#", i, 
          "\"><span style=\"color: red;\">BibTeX Eintrag</span></a>\n<br />"));
  elif not ( IsBound( r.BUCHSTABE ) or IsBound( r.LDFM ) ) then
    Append( res, ".\n" );
  fi;
  Append(res, "</p>\n\n");
  return res;
end);

InstallGlobalFunction(PrintBibAsHTML, function(arg)
  PrintFormattedString(CallFuncList(StringBibAsHTML, arg));
end);

##  arg: r[, ansi]  (for link to BibTeX)
InstallGlobalFunction(StringBibAsText, function(arg)
  local r, ansi, str, txt, s, f, field, booklike;
  r := arg[1];
  ansi := rec(
    Bib_reset := TextAttr.reset,
    Bib_author := Concatenation(TextAttr.bold, TextAttr.1),
##      Bib_editor := ~.Bib_author,
    Bib_title := TextAttr.4,
##      Bib_subtitle := ~.Bib_title,
    Bib_journal := "",
    Bib_volume := TextAttr.4,
    Bib_Label := TextAttr.3,
    Bib_edition := ["", ""],
    Bib_year := ["", ""],
    Bib_note := ["(", ")"],
    Bib_chapter := ["Chapter ", ""],
  );
  ansi.Bib_editor := ansi.Bib_author;
  ansi.Bib_subtitle := ansi.Bib_title;
  if Length(arg) = 2  and arg[2] <> true then
    for f in RecNames(arg[2]) do
      ansi.(f) := arg[2].(f);
    od;
  elif IsBound(r.From) and IsBound(r.From.options) and
            IsBound(r.From.options.ansi) then
    for f in RecNames(r.From.options.ansi) do
      ansi.(f) := r.From.options.ansi.(f);
    od;
  else
    for f in RecNames(ansi) do
      ansi.(f) := "";
    od;
  fi;
  # some details are set differently for book-like references
  if r.Type in [ "book", "booklet", "manual", "techreport", "mastersthesis",
                 "phdthesis", "proceedings" ] then
    booklike := true;
  else
    booklike := false;
  fi;
  
  if not IsBound(r.Label) then
    Info(InfoBibTools, 1, "#W WARNING: no .Label in Bib-record");
    Info(InfoBibTools, 2, ":\n", r);
    Info(InfoBibTools, 1, "\n");
    return;
  fi;
  str := "";
  # helper adds markup
  txt := function(arg)
    local field, s, pp, pre, post;
    field := arg[1];
    if Length(arg) > 1 then
      s := arg[2];
    elif IsBound(r.(field)) then
      s := r.(field);
    else
      return;
    fi;
    if not IsBound(ansi.(Concatenation("Bib_", field))) then
      Append(str, s);
    else
      pp := ansi.(Concatenation("Bib_", field));
      if not IsString(pp) then
        pre := pp[1];
        post := pp[2];
      else
        pre := pp;
        post := ansi.Bib_reset;
      fi;
      Append(str, pre);
      Append(str, s);
      Append(str, post);
    fi;
  end;
  if IsBound(r.key) then
    s := r.key;
  elif IsBound(r.printedkey) then
    s := r.printedkey;
  else
    s := r.Label;
  fi;
  Add(str, '['); txt("Label", s); Append(str, "] ");

  # we assume with the "," delimiters that at least one of .author,
  # .editor or .title exist
  txt("author");
  if IsBound(r.editor) then
    Append(str, " ("); txt("editor"); 
    if PositionSublist( r.editor, " and " ) = fail then
      Append(str, ", Ed.)");
    else
      Append(str, ", Eds.)");
    fi;
  fi;
  if IsBound(r.title) then
    if IsBound(r.author) or IsBound(r.editor) then
      Append(str, ", ");
    fi;
    txt("title");
  fi;
  if IsBound(r.booktitle) then
    Append(str, ", ");
    if r.Type in ["inproceedings", "incollection"] then
      Append(str, " in ");
    fi;
    txt("booktitle");
  fi;
  if IsBound(r.subtitle) then
    Append(str, "–"); txt("subtitle");
  fi;

  # standard BibTeX-styles typeset a type if not given
  if r.Type = "phdthesis" and not IsBound(r.type) then
    r := ShallowCopy(r);
    r.type := "Ph.D. thesis";
  elif r.Type = "mastersthesis" and not IsBound(r.type) then
    r := ShallowCopy(r);
    r.type := "Master's thesis";
  fi;
  for field in [ "journal", "type", "organization", "institution", 
                 "publisher", "school",
                 "edition", "series", "volume", "number", "address",
                 "year", "pages", "chapter", "note", "notes", 
                 "howpublished" ] do
    if IsBound(r.(field)) then
      if field = "year" then
        Append(str, " (");
        txt(field);
        Append(str, ")");
        continue;
      elif field = "pages" then
        if booklike then
          Append(str, ", ");
          txt(field);
          Append(str, " pages");
        else
##            Append(str, ", p. ");
          Append(str, ", ");
          txt(field);
        fi;
        continue;
      elif field = "edition" then
        Append(str, ", ");
        txt(field);
        Append(str, " edition");
        continue;
      elif field in ["note", "notes"] then
        Append(str, ",\n (");
        txt(field);
        Append(str, ")");
        continue;
      elif field = "chapter" then
        Append(str, ", Chapter ");
        txt(field);
        continue;
      else
        Append(str, ", "); 
      fi;
      txt(field);
    fi;
  od;
  
  # some LDFM specific
  if IsBound(r.BUCHSTABE) then
    Append(str, Concatenation(", Einsortiert unter ", r.BUCHSTABE));
  fi;
  if IsBound(r.LDFM) then
    Append(str, Concatenation(", Signatur ", r.LDFM));
  fi;

##    str := FormatParagraph(Filtered(str, x-> not x in "{}"), 72);
  Add(str, '.');
  if Unicode(str, "UTF-8") <> fail then
    str := FormatParagraph(str, SizeScreen()[1]-4, WidthUTF8String);
  else
    str := FormatParagraph(str, SizeScreen()[1]-4);
  fi;
  Add(str, '\n');
  return str;
end);

InstallGlobalFunction(PrintBibAsText, function(arg)
  PrintFormattedString(CallFuncList(StringBibAsText, arg));
end);

##  <#GAPDoc Label="SearchMRSection">
##  <Section Label="MathSciNet">
##  <Heading>Getting &BibTeX; entries from 
##           <Package>MathSciNet</Package></Heading>
##  We provide utilities to access the <URL
##  ><Link>http://www.ams.org/mathscinet/</Link><LinkText><Package>
##  MathSciNet</Package></LinkText></URL> 
##  data base from within GAP. One condition for this to work is that the 
##  <Package>IO</Package>-package <Cite Key="IO"/> is available. The other is,
##  of course, that you use these functions from a computer which has access to
##  <Package>MathSciNet</Package>.<P/>
##  
##  Please note, that the usual license for <Package>MathSciNet</Package> 
##  access does not allow for automated searches in the database. Therefore,
##  only use the <Ref Func="SearchMR" /> function for single queries, as you 
##  would do using your webbrowser.<P/>
##  
##  <ManSection >
##  <Func Arg="qurec" Name="SearchMR" />
##  <Func Arg="bib" Name="SearchMRBib" />
##  <Returns>a list of strings, a string or <K>fail</K></Returns>
##  <Description>
##  The first function <Ref Func="SearchMR"/> provides the same functionality 
##  as the Web interface <URL
##  ><Link>http://www.ams.org/mathscinet/</Link><LinkText><Package>
##  MathSciNet</Package></LinkText></URL>. The query strings must be given as
##  a record, and the following components of this record are recognized:
##  <C>Author</C>, <C>AuthorRelated</C>, <C>Title</C>, <C>ReviewText</C>, 
##  <C>Journal</C>, <C>InstitutionCode</C>, <C>Series</C>, <C>MSCPrimSec</C>, 
##  <C>MSCPrimary</C>, <C>MRNumber</C>, <C>Anywhere</C>, <C>References</C>
##  and <C>Year</C>.
##  <P/>
##  Furthermore, the component <C>type</C> can be specified. It can be one of 
##  <C>"bibtex"</C> (the default if not given), <C>"pdf"</C>, <C>"html"</C> and
##  probably others. In the last  cases the function returns a string with
##  the correspondig PDF-file or web page from <Package>MathSciNet</Package>.
##  In the first case the <Package>MathSciNet</Package> interface returns a web
##  page with  &BibTeX; entries, for convenience this function returns a list
##  of strings,  each containing the &BibTeX; text for a single result entry.
##  <P/>
##  The format of a <C>.Year</C> component can be either a four digit number,
##  optionally preceded by  one of the characters <C>'&lt;'</C>,
##  <C>'&gt;'</C> or <C>'='</C>, or it can be two four digit numbers 
##  separated by a <C>-</C> to specify a year range.<P/>
##  
##  The function <Ref Func="SearchMRBib"/> gets a record of a parsed &BibTeX;
##  entry as input as returned by <Ref Func="ParseBibFiles"/> or <Ref
##  Func="ParseBibStrings"/>. It tries to generate some sensible input from this
##  information for <Ref Func="SearchMR"/> and calls that function. <P/>
##  
##  <Example>
##  gap> ll := SearchMR(rec(Author:="Gauss", Title:="Disquisitiones"));;
##  gap> ll2 := List(ll, HeuristicTranslationsLaTeX2XML.Apply);;
##  gap> bib := ParseBibStrings(Concatenation(ll2));;
##  gap> bibxml := List(bib[1], StringBibAsXMLext);;
##  gap> bib2 := ParseBibXMLextString(Concatenation(bibxml));;
##  gap> for b in bib2.entries do 
##  >          PrintFormattedString(StringBibXMLEntry(b, "Text")); od;     
##  [Gau95]   Gauss,   C.   F.,  Disquisitiones  arithmeticae,  Academia
##  Colombiana   de  Ciencias  Exactas,  Físicas  y  Naturales,  Bogotá,
##  Colección   Enrique   Pérez   Arbeláez   [Enrique   Pérez   Arbeláez
##  Collection],  10  (1995), xliv+495 pages, (Translated from the Latin
##  by  Hugo  Barrantes  Campos,  Michael Josephy and Ángel Ruiz Zúñiga,
##  With a preface by Ruiz Zúñiga).
##  
##  [Gau86]  Gauss, C. F., Disquisitiones arithmeticae, Springer-Verlag,
##  New  York  (1986),  xx+472  pages, (Translated and with a preface by
##  Arthur  A.  Clarke,  Revised  by  William  C.  Waterhouse, Cornelius
##  Greither and A. W. Grootendorst and with a preface by Waterhouse).
##  
##  [Gau66]  Gauss,  C. F., Disquisitiones arithmeticae, Yale University
##  Press, New Haven, Conn.-London, Translated into English by Arthur A.
##  Clarke, S. J (1966), xx+472 pages.
##  
##  </Example>
##  </Description>
##  
##  
##  </ManSection>
##  
##  
##  </Section>
##  <#/GAPDoc>


SEARCHMRHOST := "www.ams.org";
##  SEARCHMRHOST := "ams.math.uni-bielefeld.de";
if not IsBound(SingleHTTPRequest) then
  SingleHTTPRequest := 0;
fi;
InstallGlobalFunction(SearchMR, function(r)
  local trans, uri, i, l, res, extr, a, b;
  trans := [["Author", "AUCN"], ["AuthorRelated","ICN"], ["Title","TI"],
            ["ReviewText","RT"],["Journal","JOUR"],["InstitutionCode","IC"],
            ["Series","SE"],["MSCPrimSec","CC"],["MSCPrimary","PC"],
            ["MRNumber","MR"],["Anywhere","ALLF"],["References","REFF"]];
  if LoadPackage("IO") <> true then
    Print("SearchMR not available because IO package not available.\n");
    return fail;
  fi;
  if not IsBound(r.type) then
    r.type := "bibtex";
  fi;
  uri := Concatenation("/mathscinet/search/publications.html?fmt=", 
                       r.type);
  if IsBound(r.Year) then
    if '-' in r.Year then
      extr := SplitString(r.Year,"","- ");
      Append(uri, "&dr=yearrange&yearRangeFirst=");
      Append(uri, extr[1]);
      Append(uri, "&yearRangeSecond=");
      Append(uri, extr[2]);
    else 
      Append(uri, "&dr=pubyear&arg3=");
      Append(uri, Filtered(r.Year, c-> not c in "<>="));
      if r.Year[1] = '<' then
        Append(uri, "&yrop=lt");
      elif r.Year[1] = '>' then
        Append(uri, "&yrop=gt");
      else
        Append(uri, "&yrop=eq");
      fi;
    fi;
  fi;
  i := 4;
  for a in trans do
    if IsBound(r.(a[1])) then
      if IsString(r.(a[1])) then
        l := [r.(a[1])];
      else
        l := r.(a[1]);
      fi;
      for b in l do 
        Append(uri, Concatenation("&pg", String(i), "=", a[2], "&s",
                      String(i), "=", Encode(Unicode(b),"URL")));
        if i = 9 then
          break;
        else
          i := i+1;
        fi;
      od;
    fi;
    if i = 9 then
      break;
    fi;
  od;
  # get all entries
  Append(uri, "&extend=1");
  res := SingleHTTPRequest(SEARCHMRHOST, 80, "GET", uri, rec(), false, false);
  while res.statuscode = 302 do
    res := SingleHTTPRequest(SEARCHMRHOST, 80, "GET", res.header.location, 
           rec(), false, false);
  od;
  if not IsBound(res.body) then
    Info(InfoBibTools, 1, "Cannot reach MathSciNet service.");
    return fail;
  fi;
  if r.type = "bibtex" then
    i := PositionSublist(res.body, "<pre>\n@", i);
    extr := [];
    while i <> fail do
      Add(extr, res.body{[i+5..PositionSublist(res.body, "</pre>", i)-1]});
      i := PositionSublist(res.body, "<pre>\n@", i);
    od;
    return extr;
  else
    return res.body;
  fi;
end);
# args: record[, type]
# records like entry from ParseBibStrings/Files, default for type is "bibtex"
InstallGlobalFunction(SearchMRBib, function(arg)
  local nn, tt, r, a, f;
  a := arg[1];
  if IsBound(a.mrnumber) then
    r := rec(MRNumber := a.mrnumber);
    if ' ' in r.MRNumber then
      r.MRNumber := r.MRNumber{[1..Position(r.MRNumber, ' ')-1]};
    fi;
  else
    a := ShallowCopy(a);
    for f in RecNames(a) do
      if IsString(a.(f)) then
        a.(f) := HeuristicTranslationsLaTeX2XML.Apply(a.(f));
      fi;
    od;
    if IsBound(a.author) then
      a.author := SubstitutionSublist(a.author, "~", " ");
      nn := NormalizedNameAndKey(a.author)[4];
    elif IsBound(a.editor) then
      a.editor := SubstitutionSublist(a.editor, "~", " ");
      nn := NormalizedNameAndKey(a.editor)[4];
    else
      nn := [[""]];
    fi;
    # up to three longest words from title
    tt := SubstitutionSublist(a.title, "{", "");
    tt := SubstitutionSublist(tt, "}", "");
    tt := NormalizedWhitespace(tt);
    tt := WordsString(tt);
    SortParallel(List(tt, w-> 1000-Length(w)), tt);
    tt := tt{[1..Minimum(3, Length(tt))]};
    r := rec( Author := List(nn, a->a[1]),
                                  Title := tt);
  fi;
  if Length(arg) > 1 then
    r.type := arg[2];
  fi;
  return SearchMR(r);
end);
if SingleHTTPRequest = 0 then
  Unbind(SingleHTTPRequest);
fi;

##  <#GAPDoc Label="LabelsFromBibTeX">
##  <ManSection >
##  <Func Arg="path, keys, bibfiles, style" Name="LabelsFromBibTeX" />
##  <Returns>a list of pairs of strings <C>[key, label]</C></Returns>
##  <Description>
##  This function uses  <C>bibtex</C> to determine the ordering  of a list
##  of  references and  a label  for each  entry which  is typeset  in   a
##  document citing these references.
##  <P/>
##  The  argument  <A>path</A>  is  a directory  specified  as  string  or
##  directory object. The argument <A>bibfiles</A> must be a list of files
##  in  &BibTeX;  format,  each  specified  by  a  path  relative  to  the
##  first  argument, or  an absolute  path (starting  with <C>'/'</C>)  or
##  relative to the &GAP; roots  (starting with <C>"gap://"</C>). The list
##  <A>keys</A>  must contain  strings which  occur as  keys in  the given
##  &BibTeX; files. Finally the string <A>style</A>  must be the name of a
##  bibliography style (like <C>"alpha"</C>). <P/>
##  
##  The list returned by this  function contains pairs <C>[key, label]</C>
##  where <C>key</C> is one of the entries of <A>keys</A> and <C>label</C>
##  is  a string  used  for  citations  of the   bibliography  entry  in a
##  document. These  pairs are ordered  as the reference list  produced by
##  &BibTeX;.
##  <Example>
##  gap> f := Filename(DirectoriesPackageLibrary("gapdoc","doc"), "test.bib");;
##  gap> LabelsFromBibTeX(".", ["AB2000"], [f], "alpha");
##  [ [ "AB2000", "FS00" ] ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(LabelsFromBibTeX, function(path, keys, bibfiles, style)
  local aux, flist, poss, d, dstr, auxfile, out, res, lab, pos, k, n, i;
  aux := "";
  # keys of citations
  for k in keys do
    Append(aux, "\\citation{");
    Append(aux, k);
    Append(aux, "}\n");
  od;
  if IsString(path) then
    path := Directory(path);
  fi;

  # file names of bib-files
  flist := [];
  for n in bibfiles do
    if Length(n) > 0 and n[1] = '/' then
      Add(flist, n);
    elif Length(n) > 5 and n{[1..6]} = "gap://" then
      Add(flist, FilenameGAP(n));
    else
      Add(flist, n);
    fi;
  od;
  poss := Positions(flist, fail);
  if Length(poss) > 0 then
    Error("Cannot generate path for bibfiles ",bibfiles{poss},".\n");
    return fail;
  fi;
  Append(aux, "\\bibdata{");
  Append(aux, JoinStringsWithSeparator(flist, ","));
  Append(aux, "}\n");

  # bibstyle of result
  Append(aux, "\\bibstyle{");
  Append(aux, style);
  Append(aux, "}\n");

  # write out, call bibtex, filter \bibitem lines from result
  d := DirectoryTemporary();
  dstr := Filename(d, "");
  auxfile := Filename(d, "temp.aux");
  FileString(auxfile, aux);
  Exec(Concatenation("(export TEXMFOUTPUT=", dstr, "; cd ", Filename(path, ""), 
                 "; bibtex ", dstr, "/temp > /dev/null 2>&1 ; ",
                 "grep '^\\\\bibitem' ", dstr, "/temp.bbl > ", dstr, "/out )"));
  out := StringFile(Filename(d, "out"));
  if out = fail then
    Error("Call of 'bibtex' was not successful.\n");
    return fail;
  fi;
  
  # clean temporary directory
  for n in DirectoryContents(d) do 
    if not n in [".", ".."] then
      RemoveFile(Filename(d, n)); 
    fi; 
  od;
  # ???  RemoveDir(Filename(d,""));

  # parse result
  out := SplitString(out, "", "\n");
  res := [];
  for i in [1..Length(out)] do
    n := out[i];
    if n[9] = '[' then
      pos := Position(n, ']', 9);
      lab := n{[10..pos-1]};
      pos := Position(n, '{', pos);
    else
      lab := String(i);
      pos := Position(n, '{', 8);
    fi;
    Add(res, [n{[pos+1..PositionMatchingDelimiter(n, "{}", pos)-1]}, lab]);
  od;
  return res;
end);

