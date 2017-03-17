#############################################################################
##
#W  XMLParser.gi                 GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files  XMLParser.g{d,i} contain a non-validating XML  parser and some
##  utilities.
##

BindGlobal("EMPTYCONTENT", 0);
BindGlobal("XMLPARSERFLAGS", rec());
BindGlobal("NAMECHARS",   
              ## here ':' is missing since it will probably  become reserved 
              ## for name space syntax in future XML
              Set(List(Concatenation([45,46], [48..57], [58], [65..90], 
              [95], [97..122]), CHAR_INT))
           );

##   two helper functions for parsing
# next successive characters not in delim (resp. enddelim) - default WHITESPACE
# arg: str, pos[, delim[, enddelim]]
BindGlobal("GetWord", function(arg)
  local   str,  pos,  delim,  enddelim,  len,  pos2;
  str := arg[1];
  pos := arg[2];
  if Length(arg)>2 then
    delim := arg[3];
    if Length(arg)>3 then
      enddelim := arg[4];
    else
      enddelim := delim;
    fi;
  else
    delim := WHITESPACE;
    enddelim := WHITESPACE;
  fi;
  
  len := Length(str);
  
  while pos <= len and str[pos] in delim do
    pos := pos + 1;
  od;
  pos2 := pos;
  while pos2 <= len and not str[pos2] in enddelim do
    pos2 := pos2 + 1;
  od;
  if pos2>len then
    return fail;
  else
    return [pos, pos2-1];
  fi;
end);

# first position after pos with character outside chars 
BindGlobal("GetChars", function(str, pos, chars)
  local   len;
  len := Length(str);
  while pos <= len and str[pos] in chars do
    pos := pos + 1;
  od;
  if pos > len then
    return fail;
  else
    return pos;
  fi;
end);

# returns for string, position:  [line number, [begin..end position of
# line]] (range without the '\n') 
BindGlobal("LineNumberStringPosition", function(str, pos)
  local p, nl, l;
  p := 0;
  l := 0;
  nl := 0;
  while p<>fail and p < pos do
    l := p;
    p := Position(str, '\n', p);
    nl := nl+1;
  od;
  if p=fail then
    p := Length(str)+1;
  fi;

  if pos = p then
    nl := nl - 1;
  fi;
  return [nl, [l+1..p-1]];
end);

# printing of error message for non-well formed XML document,
# also shows some text around position of error.
XMLPARSEORIGINS := false;
BindGlobal("ParseError", function(str, pos, comment)
  local Show, nl, ShowOrigin, r, badline, i, off;
  
  # for examination of error
  Show := function()
    Pager(rec(lines := str, start := nl[1]));
  end;
  ShowOrigin := function()
    if XMLPARSEORIGINS <> false then
      Pager(rec(lines := StringFile(r[1]), start := r[2]));
    else
      Show();
    fi;
  end;
  if InfoLevel(InfoXMLParser) > 0 then
    if XMLPARSERFLAGS.Encoding <> "UTF-8" then
      # we have an 8 bit encoding and must compute offset for original
      # position
      off := Number([1..pos], function(i) local c; c := INT_CHAR(str[i]);
        return c > 127 and c < 192; end);
    else
      off := 0;
    fi;
    # this is in UTF-8 document
    nl := LineNumberStringPosition(str, pos);
    if XMLPARSEORIGINS <> false then
      # need offset since in original encoding
      r := OriginalPositionDocument(XMLPARSEORIGINS, pos-off);
    fi;
    Print("XML Parse Error: Line ", nl[1]);
    Print(" Character ", pos-nl[2][1]+1, "\n");
    if XMLPARSEORIGINS <> false then
      Print("Original file: ", r[1], ", line number ", r[2],".\n");
    fi;
    badline := str{nl[2]}; 
    # to be perfect, consider current TERM encoding, ignore for now
    Print("-----------\n", badline, "\n");
    # this uses the same non-' ' whitespace to get the '^' at the right position
    for i in [1..pos-nl[2][1]] do
      if not badline[i] in WHITESPACE then
        badline[i] := ' ';
      fi;
    od;
    Print(badline{[1..pos-nl[2][1]]});
    Print("^", "\n-----------\n", comment, "\n!!! Type 'Show();' to watch the",
    " input string in pager - starting with\n    line containing error !!!\n");
    if XMLPARSEORIGINS <> false then
      Print("Or 'ShowOrigin();' to look it up in its source file.\n");
    fi;
  fi;
  Error();
end);

##  a container to collect named entities for the parser
BindGlobal("ENTITYDICT", rec());
##  the default XML entities
BindGlobal("ENTITYDICT_default", rec(
 lt := "&#38;#60;",
 gt := "&#62;",
 amp := "&#38;#38;",
 apos := "&#39;",
 quot := "&#34;") );
##  the predefined entities of the GAPDoc package
##  in LaTeX we use some saved boxes defined in our preamble for
##  \, ~, ^, {, } because we think that the \texttt versions of these
##  characters look better (than mathmode chars or accents without letter)
# (although this is a general XML parser, we make it convenient for 
# GAPDoc documents)
BindGlobal("ENTITYDICT_GAPDoc", rec(
 # compatibility entities, no longer needed by GAPDoc >= 1.0
 tamp := "&amp;",
 tlt := "&lt;",
 tgt := "&gt;",
 hash := "#",
 dollar := "$",
 percent := "%",
 tilde := "~",
 bslash := "\\",
 obrace := "{",
 cbrace := "}",
 uscore := "_",
 circum := "^",
 
 nbsp := "&#160;",
 copyright := "&#169;",
 ndash := "&#x2013;",
 GAP := "<Package>GAP</Package>",
 GAPDoc := "<Package>GAPDoc</Package>",
 TeX    := "<Alt Only='LaTeX'>{\\TeX}</Alt><Alt Not='LaTeX'>TeX</Alt>",
 LaTeX  := "<Alt Only='LaTeX'>{\\LaTeX}</Alt><Alt Not='LaTeX'>LaTeX</Alt>",
 BibTeX := "<Alt Only='LaTeX'>Bib{\\TeX}</Alt><Alt Not='LaTeX'>BibTeX</Alt>",
 MeatAxe := "<Package>MeatAxe</Package>",
 XGAP   := "<Package>XGAP</Package>",
 CC := "&#x2102;",
 ZZ := "&#x2124;",
 NN := "&#x2115;",
 PP := "&#x2119;",
 QQ := "&#x211a;",
 HH := "&#x210D;",
 RR := "&#x211D;",
                  )
);

##  Parsing and resolving an entity, the needed substitution text for
##  non-character entities must be bound in ENTITYDICT.
##  -- assuming str[pos-1] = '&'
##  -- returns pseudo-element (Char)EntityValue with content the result string
##  -- character entities are just substituted and returned as string
##  -- the replacement for other entities is reparsed for recursive
##     substitution
InstallGlobalFunction(GetEnt, function(str, pos)
  local   d,  i,  ch,  pos1,  nam,  doc,  res,  ent;
  # character entity
  if str[pos] = '\#' then
     d := "";
    if str[pos+1] = 'x' then
      i := pos + 2;
      while str[i] <> ';' do
        Add(d, str[i]);
        i := i+1;
      od;
      d := NumberDigits(d, 16);
    else
      i := pos+1;
      while str[i] <> ';' do
        Add(d, str[i]);
        i := i+1;
      od;
      d := NumberDigits(d, 10);
    fi;
    # must consider this as unicode, translate it to UTF-8
    res := rec(name := "CharEntityValue", next := i+1,
               content := Encode(Unicode([d]), "UTF-8"));
    return res;
  fi;
  # else replace and reparse for recursive entity replacements
  pos1 := Position(str, ';', pos-1);
  if pos1=pos then
    ParseError(str, pos, "empty entity name not allowed");
  elif pos1 = fail then
    ParseError(str, pos, "no semicolon in entity reference");
  fi;
  nam := str{[pos..pos1-1]};
  if not IsBound(ENTITYDICT.(nam)) then
    # XXX error or better going on here?
##      ParseError(str, pos, "don't know entity name");
    Info(InfoXMLParser, 1, "#W WARNING: Entity with name `", nam, 
             "' not known!\n#W", "        (Specify in <!DOCTYPE ...> tag or ",
             "in argument to parser!)\n");
    doc := Concatenation("UNKNOWNEntity(", nam, ")");
  else
    doc := ENTITYDICT.(nam);
  fi;
  i := 1;
  res := "";
  while i <= Length(doc) do
    if doc[i] <> '&' or (i<Length(doc) and doc[i+1] <> '\#') then
      Add(res, doc[i]);
      i := i+1;
    else
      ent := GetEnt(doc, i+1);
      Append(res, ent.content);
      i := ent.next;
    fi;
  od;
  return rec(name := "EntityValue", content := res, next := pos1+1);
end);
  
##  reading a start tag including attribute values
# returns rec(name := elementname, 
#             attributes := rec( attributename1 := attributevalue1, ...)
#             content := EMPTYCONTENT or [] (to be filled recursively)
#             next := positon in string after start tag )
# Special handling of case pos=1: the element name is not parsed but assumed 
# to be WHOLEDOCUMENT; this way a complete document can be put in one pseudo
# element of this name.
# assuming str[pos-1] = '<' and str[pos]<>'/'
InstallGlobalFunction(GetSTag, function(str, pos)
  local   res,  pos2,  start, attr, atval, delim, a, ent;
  res := rec(attributes := rec());
  # a small hack that allows to call GetElement with a whole document
  # after appending "</WHOLEDOCUMENT>"
  if pos=1 then
    res.name := "WHOLEDOCUMENT";
    res.next := 1;
    res.content := [];
    res.input := ShallowCopy(str);
    return res;
  fi;
  # name of element
  pos2 := GetChars(str, pos, NAMECHARS);
  if pos2=fail then
    ParseError(str, pos, "documents ends in element name");
  fi;
  if pos2=pos then
    ParseError(str, pos, "tag must start with name \'<name ...\'");
  fi;
  res.name := str{[pos..pos2-1]};
  # look for attributes or end of tag
  pos := GetChars(str, pos2, WHITESPACE);
  if pos=fail then
    ParseError(str, pos2, "document ends in tag");
  fi;
  while not str[pos] in "/>" do
    if not str[pos-1] in WHITESPACE then
      ParseError(str, pos-1, Concatenation("there must be white space ",
              "before attribute name"));
    fi;
    pos2 := GetChars(str, pos, NAMECHARS);
    if pos2=fail then
      ParseError(str, pos, "document ends in attribute name");
    fi;
    if pos2=pos then
      ParseError(str, pos, "attribute must have non-empty name");
    fi;
    # reading attribute value
    attr := str{[pos..pos2-1]};
##      if not (str[pos2] = '=' and str[pos2+1] in "\"'") then
##        ParseError(str, pos2, Concatenation("attribute must be specified ",
##                "in form \'attr=\"text\"\'"));
##      fi;
##      delim := str[pos2+1];
    # can be white space around =
    pos2 := GetChars(str, pos2, WHITESPACE);
    if pos2 = fail or str[pos2] <> '=' then
      ParseError(str, pos2, "expecting '=' for attribute value");
    fi;
    pos2 := GetChars(str, pos2+1, WHITESPACE);
    if pos2 = fail or not str[pos2] in "\"'" then
      ParseError(str, pos2, "expecting quotes for attribute value");
    fi;
    delim := str[pos2];
    atval := "";
    pos2 := pos2 + 1;
    while str[pos2] <> delim do
      # we allow     attr='fkjf"fafds'   as well, see AnnStd 2.3  
      pos2 := GetWord(str, pos2, "", "<&\"'");
      if pos2=fail then
        ParseError(str, pos, "document ends in attribute value");
      fi;
      # must allow    &xyz;  for entity resolution as well
      if not str[pos2[2]+1] = delim  then
        if str[pos2[2]+1] = '&' then
          ent := GetEnt(str, pos2[2]+2);
          Append(atval, str{[pos2[1]..pos2[2]]});
          start := pos2[2]+2;
          pos2 := ent.next;
          if ent.name = "CharEntityValue" then
            Append(atval, ent.content);
          else
            # now ent.content may still contain some character entities, but 
            # no '<' and so no markup 
            if '<' in ent.content then
              ParseError(str, start,
                "entity replacement in attribute value cannot contain '<'");
            fi;
            ent := GetElement(Concatenation(ent.content,"</WHOLEDOCUMENT>"),1);
            if IsString(ent.content) then
              Append(atval, ent.content);
            else
              for a in ent.content do
                Append(atval, a.content);
              od;
            fi;
          fi;
        elif str[pos2[2]+1] in "\"'" then
          Append(atval, str{[pos2[1]..pos2[2]+1]});
          pos2 := pos2[2]+2;
        else
          ParseError(str, pos2[2]+1, "non valid character in attribute value");
        fi;
      else
        Append(atval, str{[pos2[1]..pos2[2]]});
        pos2 := pos2[2]+1;   
      fi;
    od;
    res.attributes.(attr) := atval;
    pos2 := pos2+1;
    pos := GetChars(str, pos2, WHITESPACE);
    if pos=fail then
      ParseError(str, pos2, "document ends in tag");
    fi;
  od;
  if str[pos] = '/' then
    res.content := EMPTYCONTENT;
    pos := pos+1;
  else
    res.content := [];
  fi;
  if not str[pos] = '>' then
    ParseError(str, pos, "expecting end of tag \'>\' here");
  fi;
  res.next := pos+1;
  return res;
end);

##  reading an end tag, 
##  returns rec( name := elementname, 
##               next := first position after this end tag)
# assuming str{[pos-2,pos-1]} = "</"
InstallGlobalFunction(GetETag, function(str, pos)
  local   res,  pos2;
  res := rec();
  # name of element
  pos2 := GetChars(str, pos, NAMECHARS);
  if pos2=fail then
    ParseError(str, pos, "documents ends in element name");
  fi;
  if pos2=pos then
    ParseError(str, pos, "end tag must start with name \'</name ...\'");
  fi;
  res.name := str{[pos..pos2-1]};
  pos := pos2;
  pos2 := GetChars(str, pos, WHITESPACE);
  if pos2=fail then
    ParseError(str, pos, "documents ends inside end tag");
  fi;
  if str[pos2] <> '>' then
    ParseError(str, pos2, "expecting end of tag \'>\' here");
  fi;
  res.next := pos2+1;
  return res;
end);

##  reading an element: start tag, content (with recursive calls of
##  GetElement) and end tag
# returns record explained before GetSTag, but with .content component
# filled
# assuming str[pos-1] = '<' and str[pos] in NAMECHARS
# (in this function we read entity definitions inside a <!DOCTYPE declaration)
InstallGlobalFunction(GetElement, function(str, pos)
  local   res,  r,  s,  pos2,  lev,  dt,  p,  nam,  val,  el, tmp;
  res := GetSTag(str,pos);
  res.start := pos - 1;
  # case of empty element
  if res.content = EMPTYCONTENT then
    res.stop := res.next - 1;
    return res;
  fi;
  pos := res.next;
  while true do
    if str[pos] = '&' then
      # resolve entity
      r := GetEnt(str, pos+1);
      pos := r.next;
      if r.name = "CharEntityValue" then
        # consider as PCDATA
        r.name := "PCDATA";
        Add(res.content, r);
      else
        # we have to parse the result
        s := Concatenation(r.content, "</WHOLEDOCUMENT>");
        r := GetElement(s, 1);
        Append(res.content, r.content);
      fi;
    elif str[pos] = '<' then
      if str[pos+1] = '?' then
        # processing instruction (PI), we repeat it literally
        pos2 := PositionSublist(str, "?>", pos+2);
        if pos2=fail then
          ParseError(str, pos+2, "document ends within processing instruction");
        fi;
        tmp := str{[pos+2..pos2-1]};
        Add(res.content, rec(name := "XMLPI", content := tmp));
        # check for encoding information
        if Length(tmp) > 3 and tmp{[1..4]} = "xml " then
          tmp := Concatenation(tmp, "/>");
          tmp := GetElement(tmp, 3);
          if IsBound(tmp.attributes.encoding) then
            tmp := tmp.attributes.encoding;
            if not IsBound(UNICODE_RECODE.NormalizedEncodings.(tmp)) then
              Error("Cannot parse document in encoding ", tmp, "\n");
            fi;
            XMLPARSERFLAGS.Encoding := UNICODE_RECODE.NormalizedEncodings.(tmp);
            # if not in UTF-8 encoding we recode rest of the document now
            if XMLPARSERFLAGS.Encoding <> "UTF-8" then
              Info(InfoGAPDoc, 1, "#I recoding input from ",
                                XMLPARSERFLAGS.Encoding, " to UTF-8 . . .\n");
              tmp := Encode(Unicode(str{[pos..Length(str)]},
                                           XMLPARSERFLAGS.Encoding), "UTF-8");
              str{[pos..pos-1+Length(tmp)]} := tmp;
            fi;
          fi;
        fi;
        pos := pos2+2;
      elif str[pos+1] = '!' then
        if str[pos+2] = '-' and str[pos+3] = '-' then
          ## comment 
          #  here we ignore the restriction that inside comment 
          #  no "--" is allowed.
          pos2 := PositionSublist(str, "-->", pos+4);
          if pos2=fail then
            ParseError(str,pos+4, "document ends within comment");
          fi;
          Add(res.content, rec(name := "XMLCOMMENT", 
                  content := str{[pos+4..pos2-1]}));
          pos := pos2+3;
        elif str[pos+2] = 'D' and str{[pos+3..pos+8]} = "OCTYPE" and
          str[pos+9] in WHITESPACE then
          ## <!DOCTYPE ....
          ## end of this tag is matching ">"
          ## we have to read ENTITY declarations
          pos2 := pos+10;
          lev := 0;
          while str[pos2] <> '>' or lev > 0 do
            if str[pos2] = '<' then
              lev := lev+1;
            elif str[pos2] = '>' then
              lev := lev-1;
            fi;
            pos2 := pos2+1;
            if pos2>Length(str) then
              ParseError(str,pos+10, "document ends within DOCTYPE tag"); 
            fi;
          od;
          dt := rec(name := "XMLDOCTYPE", 
                  content := str{[pos+10..pos2-1]});
          ##  convenience for parsing GAPDoc document, here we add the
          ##  GAPDoc defined entities automatically
          pos := PositionSublist(dt.content, "gapdoc.dtd");
          if pos <> fail and dt.content[pos-1] in "'\"/" then
            for p in RecFields(ENTITYDICT_GAPDoc) do
              ENTITYDICT.(p) := ENTITYDICT_GAPDoc.(p);
            od;
          fi;
          Add(res.content, dt);
          ##  parse entity declarations in here (no good error checking)
          pos := PositionSublist(dt.content, "<!ENTITY");
          while pos <> fail do
            p := GetWord(dt.content, pos+8);
            nam := dt.content{[p[1]..p[2]]};
            # value enclosed in ".." or '..'
            p := p[2]+1;
            while dt.content[p] in WHITESPACE do
              p := p + 1;
            od;
            p := [p+1];
            Add(p, Position(dt.content, dt.content[p[1]-1], p[1])-1);
            val := dt.content{[p[1]..p[2]]};
            ENTITYDICT.(nam) := val;
            pos := PositionSublist(dt.content, "<!ENTITY", p[2]);
          od;
          pos := pos2+1;
        elif  str[pos+2] = '[' and str{[pos+3..pos+8]} = "CDATA[" then
          ## <![CDATA[   everything is verbose text until "]]>"
          pos2 := PositionSublist(str, "]]>", pos+9);
          if pos2=fail then
            ParseError(str,pos+10, "document ends within CDATA text");
          fi;
          if pos2>pos+9 then
            Add(res.content, rec(name := "PCDATA", 
                    content := str{[pos+9..pos2-1]}));
          fi;
          pos := pos2+3;
        else 
          ParseError(str, pos, "unknown \"<!\"-tag");
        fi;
      elif str[pos+1] = '/' then
        ##  end tag, must be the right one corresponding to the
        ##  current element 
        el := GetETag(str, pos+2);
        if res.name <> el.name then
          ParseError(str, pos, Concatenation("wrong end tag, expecting \"</",
                  res.name, ">\" (starts line ",
                  String(LineNumberStringPosition(str, res.start)[1]), ")"));
        else
          res.stop := el.next - 1;
          res.next := el.next;
          break;
        fi;
      elif not str[pos+1] in NAMECHARS then  
        ParseError(str, pos+1, "not allowed character after '<'");
      else
        ## a new element starts, call GetElement recursively
        el := GetElement(str, pos+1);
        Add(res.content, el);
        pos := el.next;
      fi;
    else
      pos2 := GetWord(str, pos, "", "<&");
      if pos2 = fail then
        ParseError(str, pos, "document ends before end of current element");
      fi;
      if pos2[2] >= pos then
        Add(res.content, rec(name := "PCDATA", 
                content := str{[pos..pos2[2]]}));
      fi;
      pos := pos2[2]+1;
    fi;
  od;
  return res;
end);

##  the user function for parsing an XML document stored in a string, 
##  adds end tag for pseudo element WHOLEDOCUMENT (see before GetSTag)
##  and calls GetElement

##  <#GAPDoc Label="ParseTreeXMLString">
##  <ManSection >
##  <Func Arg="str[, srcinfo][, entitydict]" Name="ParseTreeXMLString" />
##  <Func Arg="fname[, entitydict]" Name="ParseTreeXMLFile" />
##  <Returns>a record which is root of a tree structure</Returns>
##  <Description>
##  The first function parses an  XML-document stored in string <A>str</A>
##  and returns the document in form of a tree.<P/>
## 
##  The  optional argument  <A>srcinfo</A> must  have the  same format
##  as  in <Ref  Func="OriginalPositionDocument"  />.  If it is given  then
##  error messages  refer  to the  original  source  of  the text  with  the
##  problem.<P/>
##  
##  With the optional argument <A>entitydict</A> named entities can be 
##  given to the parser, for example entities which are defined in the 
##  <C>.dtd</C>-file (which is not read by this parser). The standard
##  XML-entities do not need to be provided, and for &GAPDoc; documents
##  the entity definitions from  <C>gapdoc.dtd</C> are automatically
##  provided. Entities in the document's <C>&lt;!DOCTYPE</C> declaration
##  are parsed and also need not to be provided here. The argument
##  <A>entitydict</A> must be a record where each component name is an entity
##  name (without the surrounding &amp; and ;) to which  is assigned its
##  substitution string.<P/>
##  
##  The second function is just a shortcut for <C>ParseTreeXMLString( 
##  StringFile(</C><A>fname</A><C>), ... )</C>, see <Ref Func="StringFile"/>.
##  <P/>
##  
##  After these functions return the list of named entities which were known
##  during the parsing can be found in the record <C>ENTITYDICT</C>. <P/>
##  
##  A node  in the result tree  corresponds to an  XML element, or  to some
##  parsed character data. In the first case it looks as follows:
##  
##  <Listing Type="Example Node">
##  rec( name := "Book",
##       attributes := rec( Name := "EDIM" ),
##       content := [ ... list of nodes for content ...],
##       start := 312,
##       stop := 15610,
##       next := 15611     )
##  </Listing>
##  
##  This  means   that  <C><A>str</A>{[312..15610]}</C>   looks  like
##  <C>&lt;Book Name="EDIM"> ... content ... &lt;/Book></C>.<P/>
##  
##  The leaves  of the tree  encode parsed  character data as  in the
##  following example:
##  
##  <Listing Type="Example Node">
##  rec( name := "PCDATA", 
##       content := "text without markup "     )
##  </Listing>
##  
##  This function checks whether  the  XML  document   is  <Emph>well
##  formed</Emph>, see  <Ref Chap="XMLvalid"  /> for  an explanation.
##  If   an  error in  the XML  structure is found,  a break  loop is
##  entered and the text around the position where the problem starts
##  is shown. With  <C>Show();</C> one can browse  the original input
##  in  the <Ref  BookName="Ref" Func="Pager"  />, starting  with the
##  line where the error occurred.
##  
##  All entities are  resolved when they are  either entities defined
##  in the &GAPDoc; package (in particular the standard XML entities)
##  or if their definition is included in the <C>&lt;!DOCTYPE ..></C>
##  tag of the document.<P/>
##  
##  Note  that  <Ref  Func="ParseTreeXMLString"  />  does  not  parse
##  and  interpret the  corresponding document  type definition  (the
##  <C>.dtd</C>-file given in the <C>&lt;!DOCTYPE ..></C> tag). Hence
##  it also does not check  the <Emph>validity</Emph> of the document
##  (i.e., it is no <Emph>validating XML parser</Emph>).<P/>
##  
##  If  you are  using this  function  to parse  a &GAPDoc;  document
##  you  can  use  <Ref Func="CheckAndCleanGapDocTree"  />  for  some
##  validation and additional checking of the document structure.
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ParseTreeXMLString, function(arg)
  local str, ents, res, a;
  # artificial end tag to wrap document in one element
  str := Concatenation(arg[1], "</WHOLEDOCUMENT>");
  # default encoding is UTF-8, may be changed if we find a <?xml ... 
  # processing instruction
  XMLPARSERFLAGS.Encoding := "UTF-8";
  if Length(arg) > 1 and IsList(arg[2]) then
    XMLPARSEORIGINS := arg[2];
  else
    XMLPARSEORIGINS := false;
  fi;
  # reset ENTITYDICT
  for a in RecFields(ENTITYDICT) do
    Unbind(ENTITYDICT.(a));
  od;
  for a in RecFields(ENTITYDICT_default) do
    ENTITYDICT.(a) := ENTITYDICT_default.(a);
  od;
  # maybe load more entities from last argument
  if Length(arg) > 1 and IsRecord(arg[Length(arg)]) then
    ents := arg[Length(arg)];
    for a in RecFields(ents) do
      ENTITYDICT.(a) := ents.(a);
    od;
  fi;
  res := GetElement(str, 1);
  res.input := ShallowCopy(arg[1]);
  if XMLPARSEORIGINS <> false then
    res.inputorigins := XMLPARSEORIGINS;
  fi;
  return res;
end);
InstallGlobalFunction(ParseTreeXMLFile, function(arg)
  arg := ShallowCopy(arg);
  arg[1] := StringFile(arg[1]);
  return CallFuncList(ParseTreeXMLString, arg);
end);

##  Print document tree structure (without the PCDATA entries)

##  <#GAPDoc Label="DisplayXMLStructure">
##  <ManSection >
##  <Func Arg="tree" Name="DisplayXMLStructure" />
##  <Description>
##  This utility displays the tree structure of an XML document as it
##  is  returned by  <Ref Func="ParseTreeXMLString"  /> (without  the
##  <C>PCDATA</C> leaves).<P/>
##  
##  Since this  is usually quite long  the result is shown  using the
##  <Ref BookName="ref" Func="Pager" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(DisplayXMLStructure, function(doc)
  local   NL, prs, app, str;
  str := "";
  NL := "\n";
  app := function(arg)
    local i;
    for i in [2..Length(arg)] do
      Append(arg[1], arg[i]);
    od;
  end;  
  prs := function(doc, indent)
    local   a,  c,  indentnext;
    if doc.name = "PCDATA" then
      return;
    fi;
    if IsBound(doc.count) then
      c := String(doc.count);
    else
      c := "";
    fi;
    app(str, indent, c, "  ", doc.name, NL);
    if IsBound(doc.attributes) then
      for a in NamesOfComponents(doc.attributes) do
        app(str, indent,"  #",a,":",doc.attributes.(a), NL);
      od;
    fi;
    if doc.content = EMPTYCONTENT then
      app(str, indent, "  # empty element\n");
    elif IsString(doc.content) then
## ??? too much output
##        Print(indent, "  # data\n");
    else
      for a in doc.content do
        indentnext := Concatenation(indent, "  ");
        prs(a, indentnext);
      od;
    fi;
  end;
  prs(doc, "");
  Page(str);
end);

##  apply a function to all nodes of a parse tree

##  <#GAPDoc Label="ApplyToNodesParseTree">
##  <ManSection >
##  <Func Arg="tree, fun" Name="ApplyToNodesParseTree" />
##  <Func Arg="tree" Name="AddRootParseTree" />
##  <Func Arg="tree" Name="RemoveRootParseTree" />
##  <Description>
##  The  function  <Ref  Func="ApplyToNodesParseTree"  />  applies  a
##  function <A>fun</A>  to all nodes  of the parse  tree <A>tree</A>
##  of  an XML  document returned  by <Ref  Func="ParseTreeXMLString"
##  />.<P/>
##  
##  The function <Ref Func="AddRootParseTree" /> is an application of
##  this.  It adds  to all  nodes a  component <C>.root</C>  to which 
##  the top node tree <A>tree</A> is assigned. These components can be
##  removed afterwards with <Ref Func="RemoveRootParseTree" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ApplyToNodesParseTree, function(r, f)
  local   ff;
  ff := function(rr)
    local   a;
    if IsList(rr.content) and not IsString(rr.content) then
      for a in rr.content do 
        f(a);
        ff(a);
      od;
    fi;
  end;
  f(r);
  ff(r);
end);

##  This is useful for things like indexing where one should have
##  access to the root of the document tree during the whole processing 
InstallGlobalFunction(AddRootParseTree, function(r)
  ApplyToNodesParseTree(r, function(a) a.root := r; end);  
end);

##  And this throws away the links 
InstallGlobalFunction(RemoveRootParseTree, function(r)
  ApplyToNodesParseTree(r, function(a) Unbind(a.root); end);  
end);

##  <#GAPDoc Label="StringXMLElement">
##  <ManSection >
##  <Func Arg="tree" Name="StringXMLElement" />
##  <Returns>a list <C>[string, positions]</C></Returns>
##  <Description>
##  
##  The argument <A>tree</A> must have a format  of a node in the parse tree
##  of  an  XML  document  as  returned  by <Ref Func="ParseTreeXMLString"/>
##  (including the root node representing  the full document). This function
##  computes a pair <C>[string,  positions]</C> where <C>string</C> contains
##  XML  code which  is  equivalent to  the  code which  was  parsed to  get
##  <A>tree</A>. And  <C>positions</C> is  a list of  lists of  four numbers
##  <C>[eltb, elte, contb,  conte]</C>. There is one such list  for each XML
##  element occuring in <C>string</C>, where <C>eltb</C> and <C>elte</C> are
##  the begin  and end position of  this element in <C>string</C>  and where
##  <C>contb</C> and <C>conte</C> are begin  and end position of the content
##  of this element, or both are <C>0</C> if there is no content.<P/>
##  
##  Note that parsing XML code is an irreversible task, we can only expect
##  to get equivalent XML code from this function. But parsing the resulting
##  <C>string</C> again and applying <Ref Func="StringXMLElement"/> again
##  gives the same result. See the function <Ref Func="EntitySubstitution"/>
##  for back-substitutions of entities in the result.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
# args: r[, count, pos, str]    count, pos, str is for use within recursion
StringXMLElement := function(arg)
  local r, str, pos, p, tmp, att, a;
  if Length(arg) = 1 then
    r := arg[1];
    str := StringXMLElement(r, [], "");
    # revert the WHOLEDOCUMENT trick of the parser
    if IsRecord(r) and r.name = "WHOLEDOCUMENT" then
      str[1] := str[1]{[16..Length(str[1])-16]};
      str[2] := str[2] - 15;
      str[2][Length(str[2])] := [1, Length(str[1]), 1, Length(str[1])];
      for a in str[2] do
        if a[3] = -15 then
          a[3] := 0;
          a[4] := 0;
        fi;
      od;
    fi;
    return str;
  fi;
  # now we are in the recursion
  r := arg[1];
  pos := arg[2];
  str := arg[3];
  
  if IsRecord(r) then
    if r.name = "PCDATA" then
      return StringXMLElement(r.content, pos, str);
    elif r.name = "XMLPI" then
      p := Length(str)+1;
      Append(str, Concatenation("<?", r.content, "?>"));
      Add(pos, [p, Length(str), 0, 0]);
      return [str, pos];
    elif r.name = "XMLDOCTYPE" then
      p := Length(str)+1;
      Append(str, Concatenation("<!DOCTYPE ", r.content, ">"));
      Add(pos, [p, Length(str), 0, 0]);
      return [str, pos];
    elif r.name = "XMLCOMMENT" then
      p := Length(str)+1;
      Append(str, Concatenation("<!--", r.content, "-->"));
      Add(pos, [p, Length(str), 0, 0]);
      return [str, pos];
    fi;
  fi;
  if IsString(r) then 
    r := SubstitutionSublist(r, "&", "&amp;");
    r := SubstitutionSublist(r, "<", "&lt;");
    if Length(r) > 0 then
      Append(str, r);
    fi;
    return [str, pos];
  fi;
  p := [Length(str)+1];
  Append(str, "<");
  Append(str, r.name);
  for att in RecFields(r.attributes) do
    Add(str, ' ');
    Append(str, att);
    Append(str, "=\"");
    tmp := SubstitutionSublist(r.attributes.(att), "\"", "&#34;");
    tmp := SubstitutionSublist(tmp, "&", "&amp;");
    tmp := SubstitutionSublist(tmp, "<", "&lt;");
    if Length(tmp)>0 then
    fi;
    Append(str, tmp);
    Append(str, "\"");
  od;
  if r.content = 0 then
    Append(str, "/>");
    Add(pos, [p[1], Length(str), 0, 0]);
    return [str, pos];
  fi;
  Add(str, '>');
  p[3] := Length(str)+1;
  if IsString(r.content) then
    StringXMLElement(r.content, pos, str);
  else
    for a in r.content do 
      StringXMLElement(a, pos, str);
    od;
  fi;
  p[4] := Length(str);
  Append(str, "</");
  Append(str, r.name);
  Add(str, '>');
  p[2] := Length(str);
  Add(pos, p);
  return [str, pos];
end;

##  <#GAPDoc Label="EntitySubstitution">
##  <ManSection >
##  <Func Arg="xmlstring, entities" Name="EntitySubstitution" />
##  <Returns>a string</Returns>
##  <Description>
##  The  argument   <A>xmlstring</A>  must   be  a  string   containing  XML
##  code  or  a   pair  <C>[string,  positions]</C>  as   returned  by  <Ref
##  Func="StringXMLElement"/>. The argument <A>entities</A> specifies entity
##  names  (without the  surrounding <A>&amp;</A>  and <C>;</C>)  and their
##  substitution strings, either  a list of pairs of strings  or as a record
##  with the names as components and the substitutions as values.<P/>
##  
##  This   function   tries   to  substitute   non-intersecting   parts   of
##  <C>string</C> by the given entities. If the <C>positions</C> information
##  is  given  then  only  parts  of   the  document  which  allow  a  valid
##  substitution  by  an entity  are  considered.  Otherwise a  simple  text
##  substitution without further check is done. <P/>
##  
##  Note that in general the entity resolution in XML documents is a
##  complicated and non-reversible task. But nevertheless this utility may
##  be useful in not too complicated situations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
EntitySubstitution := function(xmlstr, entities)
  local posinfo, entities2, check, subs, pos, npos, new, res, off, a;
  if not IsString(xmlstr) then
    posinfo := xmlstr[2];
    xmlstr := xmlstr[1];
  else
    posinfo := fail;
  fi;
  if IsRecord(entities) then
    entities := List(RecFields(entities), f-> [f, entities.(f)]);
  fi;
  # parse and rewrite entities
  entities2 := List(entities, a-> [a[1], StringXMLElement(
                                           ParseTreeXMLString(a[2]))[1]]);
  # checks if beginning and end of a substring are in the content of the
  # same element (if this information is available)
  check := function(b, e)
    local pb, a;
    if posinfo = fail then
      return true;
    fi;
    pb := [-1];
    for a in posinfo do
      if a[1] <= b and a[1] > pb[1] and a[2] >= e then
        pb := a;
      fi;
    od;
    if b = pb[1] and e = pb[2] then
      return true;
    fi;
    for a in posinfo do
      if a <> pb and a[1] > pb[1] and a[2] < pb[2] then
        if not Intersection([b..e],[a[1]..a[2]]) in [[], [a[1]..a[2]]] then
          return false;
        fi;
      fi;
    od;
    return true;
  end;

  subs := [];
  for a in entities2 do
    if not a[1] in ["lt", "gt", "amp", "apos", "quot"] then
      pos := 0;
      while pos <> fail do
        npos := PositionSublist(xmlstr, a[2], pos);
        if npos <> fail and check(npos, npos-1+Length(a[2])) then
          new := [npos, npos-1+Length(a[2]), a];
          if ForAll(subs, b-> b[1] > new[2] or b[2] < new[1]) then
            Add(subs, new);
          fi;
          pos := new[2];
        else
          pos := npos;
        fi;
      od;
    fi;
  od;
  Sort(subs);
  if Length(subs) > 0 then
    res := xmlstr{[1..subs[1][1]-1]};
    off := 0;
    res := "";
    for a in subs do
      Append(res, xmlstr{[off+1..a[1]-1]});
      Append(res, Concatenation("&", a[3][1], ";"));
      off := a[2];
    od;
    Append(res, xmlstr{[off+1..Length(xmlstr)]});
    xmlstr := res;
  fi;
  return xmlstr;
end;

##  <#GAPDoc Label="GetTextXMLTree">
##  <ManSection >
##  <Func Arg="tree" Name="GetTextXMLTree" />
##  <Returns>a string</Returns>
##  <Description>
##  The  argument   <A>tree</A>  must   be  a  node of a parse tree of some
##  XML document, see <Ref Func="ParseTreeXMLFile"/>. 
##  This function collects the content of this and all included elements 
##  recursively into a string.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
# extract and collect text in elements recursively
InstallGlobalFunction(GetTextXMLTree, function(r)
  local res, fun;
  res := "";
  fun := function(r)
    if IsString(r.content) then
      Append(res, r.content);
    fi;
  end;
  ApplyToNodesParseTree(r, fun);
  return res;
end);


##  <#GAPDoc Label="XMLElements">
##  <ManSection >
##  <Func Arg="tree, eltnames" Name="XMLElements" />
##  <Returns>a list of nodes</Returns>
##  <Description>
##  The  argument   <A>tree</A>  must   be  a  node of a parse tree of some
##  XML document, see <Ref Func="ParseTreeXMLFile"/>. 
##  This function returns a list of all subnodes of <A>tree</A> (possibly 
##  including <A>tree</A>) of elements with name given in the list of strings
##  <A>eltnames</A>. Use <C>"PCDATA"</C> as name for leave nodes which contain 
##  the actual text of the document. As an abbreviation <A>eltnames</A> can also
##  be a string which is then put in a one element list.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
# return list of nodes of elements with name in 'eltnames' from XML tree r
InstallGlobalFunction(XMLElements, function(r, eltnames)
  local res, fun;
  if IsString(eltnames) then
    eltnames := [eltnames];
  fi;
  res := [];
  fun := function(r)
    if r.name in eltnames then
      Add(res, r);
    fi;
  end;
  ApplyToNodesParseTree(r, fun);
  return res;
end);
