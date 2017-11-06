#############################################################################
##
#W  GAPDoc2LaTeX.gi                GAPDoc                        Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2LaTeX.g{d,i}  contain a  conversion program  which
##  produces from a GAPDoc XML-document a version which can be processed
##  by LaTeX and pdfLaTeX.
##  

##  All  the work  is  done by  handler functions  for  each GAPDoc  XML
##  element.  These functions  are  bound as  components  to the  record
##  `GAPDoc2LaTeXProcs'. Most  element markup is easily  translated to a
##  corresponding LaTeX markup. It should  be easy to modify details for
##  some elements  by small local  changes of the  corresponding handler
##  function. The only slight complications  are in places where the XML
##  elements imply some labeling or  indexing. Also for all (sub)section
##  commands  we  add some  commands  which  cause  LaTeX to  produce  a
##  GAP  readable .pnr  file which  contains  the page  numbers for  all
##  subsections.
InstallValue(GAPDoc2LaTeXProcs, rec());

##  <#GAPDoc Label="GAPDoc2LaTeX">
##  <ManSection >
##  <Func Arg="tree" Name="GAPDoc2LaTeX" />
##  <Returns>&LaTeX; document as string</Returns>
##  <Func Name="SetGapDocLaTeXOptions" Arg="[...]" />
##  <Returns>Nothing</Returns>
##  <Description>
##  The   argument  <A>tree</A>   for   this  function   is  a   tree
##  describing  a   &GAPDoc;  XML   document  as  returned   by  <Ref
##  Func="ParseTreeXMLString"  /> (probably  also  checked with  <Ref
##  Func="CheckAndCleanGapDocTree"  />).  The   output  is  a  string
##  containing a  version of the document  which can be written  to a
##  file  and processed  with  &LaTeX; or  pdf&LaTeX;  (and  probably
##  &BibTeX; and <C>makeindex</C>). <P/>
##  
##  The   output   uses   the  <C>report</C>   document   class   and
##  needs    the   following    &LaTeX;   packages:    <C>a4wide</C>,
##  <C>amssymb</C>,  <C>inputenc</C>, <C>makeidx</C>,  <C>color</C>,
##  <C>fancyvrb</C>,  <C>psnfss</C>, <C>pslatex</C>, <C>enumitem</C>  
##  and  <C>hyperref</C>.   These
##  are  for  example  provided by  the  <Package>teTeX-1.0</Package>
##  or <Package>texlive</Package> 
##  distributions  of   &TeX;   (which    in   turn  are   used   for
##  most  &TeX;   packages  of  current  Linux   distributions);  see
##  <URL>http://www.tug.org/tetex/</URL>. <P/>
##  
##  In  particular, the  resulting  <C>pdf</C>-output (and 
##  <C>dvi</C>-output)  
##  contains  (internal and  external) hyperlinks  which can  be very
##  useful for onscreen browsing of the document.<P/>
##  
##  The  &LaTeX;  processing  also  produces a  file  with  extension
##  <C>.pnr</C> which is &GAP; readable and contains the page numbers
##  for  all (sub)sections  of  the  document. This  can  be used  by
##  &GAP;'s online help; see <Ref Func="AddPageNumbersToSix" />.
##  
##  Non-ASCII characters in the &GAPDoc; document are translated to 
##  &LaTeX; input in ASCII-encoding with the help of <Ref Oper="Encode"/>
##  and the option <C>"LaTeX"</C>. See the documentation of 
##  <Ref Oper="Encode"/> for how to proceed if you have a character which 
##  is not handled (yet).<P/>
##  
##  This  function works  by  running recursively  through the  document
##  tree   and   calling   a   handler  function   for   each   &GAPDoc;
##  XML   element.  Many   of  these   handler  functions   (usually  in
##  <C>GAPDoc2LaTeXProcs.&lt;ElementName&gt;</C>)  are not  difficult to
##  understand (the  greatest complications are some  commands for index
##  entries, labels  or the  output of page  number information).  So it
##  should be easy to adjust layout  details to your own taste by slight
##  modifications of the program. <P/>
##  
##  Former   versions  of   &GAPDoc;  supported   some  XML   processing
##  instructions to add some extra lines  to the preamble of the &LaTeX;
##  document. Its use is now deprecated, use the much more flexible <Ref
##  Func="SetGapDocLaTeXOptions" /> instead:
##  
##  The    default   layout    of    the    resulting   documents    can
##  be   changed   with    <Ref   Func="SetGapDocLaTeXOptions"/>.   This
##  changes    parts   of    the    header   of    the   &LaTeX;    file
##  produced   by    &GAPDoc;.   You    can   see   the    header   with
##  some   placeholders  by   <C>Page(GAPDoc2LaTeXProcs.Head);</C>.  The
##  placeholders   are   filled   with  components   from   the   record
##  <C>GAPDoc2LaTeXProcs.DefaultOptions</C>.   The  arguments   of  <Ref
##  Func="SetGapDocLaTeXOptions"/>   can  be   records  with   the  same
##  structure (or parts  of it) with different  values. As abbreviations
##  there  are   also  three  strings  supported   as  arguments.  These
##  are  <C>"nocolor"</C>  for  switching  all  colors  to  black;  then
##  <C>"nopslatex"</C>  to   use  standard  &LaTeX;  fonts   instead  of
##  postscript fonts; and finally <C>"utf8"</C> to choose UTF-8 as input
##  encoding for the &LaTeX; document.
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
##  <!--  seems to be no longer needed
##  A hint for  large documents: In many &TeX;  installations one can
##  easily reach some memory limitations with documents which contain
##  many (cross-)references. In <Package>teTeX</Package> you can look
##  for  a  file <F>texmf.cnf</F>  which  allows  to enlarge  certain
##  memory sizes.<P/>
##  -->


# the basic call, used recursivly with a result r from GetElement 
# and a string str to which the output should be appended
# arg: r       (then a string is returned)
# or:  r, str  (then the output is appended to string str)
InstallGlobalFunction(GAPDoc2LaTeX, function(arg)
  local  r,  str,  name;
  r := arg[1];
  if Length(arg)>1 then
    str := arg[2];
  else
    AddRootParseTree(r);
    # reset to defaults in case of interrupted previous call
    GAPDoc2LaTeXProcs.verbatimPCDATA := false;
    GAPDoc2LaTeXProcs.recode := true;
    str := "";
  fi;
  name := r.name;
  if not IsBound(GAPDoc2LaTeXProcs.(name)) then
    Info(InfoGAPDoc, 1, "#W WARNING: Don't know how to process element ", name, 
          " ---- ignored\n");
  else
    GAPDoc2LaTeXProcs.(r.name)(r, str);
  fi;
  if Length(arg)=1 then
    return str;
  fi;
end);

##  a common recursion loop
BindGlobal("GAPDoc2LaTeXContent", function(r, str)
  local   a;
  for a in r.content do
    GAPDoc2LaTeX(a, str);
  od;
end);

# width of index entries, we use a trick to split longer command names
GAPDoc2LaTeXProcs.MaxIndexEntryWidth := 35;

# a flag for recoding to LaTeX
GAPDoc2LaTeXProcs.recode := true;

# two utilities for attribute values like labels or text with special
# XML or LaTeX characters which gets printed (always as \texttt text)
GAPDoc2LaTeXProcs.EscapeAttrValOld := function(str)
  local res, c;
  res := "";
  for c in str do
    if c = '\\' then
##        Append(res, "{\\gdttbs}");
      Append(res, "\\texttt{\\symbol{92}}");
    elif c = '_' then
      Append(res, "\\_");
    elif c = '{' then
##        Append(res, "{\\gdttob}");
      Append(res, "\\texttt{\\symbol{123}}");
    elif c = '}' then
##        Append(res, "{\\gdttcb}");
      Append(res, "\\texttt{\\symbol{125}}");
    elif c = '^' then
##        Append(res, "{\\gdttht}");
      Append(res, "\\texttt{\\symbol{94}}");
    elif c = '~' then
##        Append(res, "{\\gdttti}");
      Append(res, "\\texttt{\\symbol{126}}");
    elif c = '<' then
      Append(res, "{\\textless}");
    elif c = '>' then
      Append(res, "{\\textgreater}");
    elif c = '&' then
      Append(res, "\\&");
    elif c = '%' then
      Append(res, "\\%");
    elif c = '$' then
      Append(res, "\\$");
    elif c = '#' then
      Append(res, "\\#");
    else
      Add(res, c);
    fi;
  od;
  return res;
end;
# now via Unicode, handle many more characters as well
GAPDoc2LaTeXProcs.EscapeAttrVal := function(str)
  return Encode(Unicode(str), GAPDoc2LaTeXProcs.Encoder);
end;

GAPDoc2LaTeXProcs.DeleteUsBs := function(str)
  return Filtered(str, x-> not (x in "\\_"));
end;

##  this is for getting a string "[ \"A\", 1, 1 ]" from [ "A", 1, 1 ]
GAPDoc2LaTeXProcs.StringNrs := function(ssnr)
  if IsInt(ssnr[1]) then
    return String(ssnr);
  else
    return Concatenation("[ \"", ssnr[1], "\", ", String(ssnr[2]), ", ",
                   String(ssnr[3]), " ]");
  fi;
end;

GAPDoc2LaTeXProcs.Head := StringFile(
            Filename(DirectoriesPackageLibrary("gapdoc"),"latexhead.tex"));
                                   
GAPDoc2LaTeXProcs.Tail := Concatenation( 
"\\newpage\n",
"\\immediate\\write\\pagenrlog{[\"End\"], \\arabic{page}];}\n",
"\\immediate\\closeout\\pagenrlog\n",
"\\end{document}\n");

GAPDoc2LaTeXProcs.Options := rec();
GAPDoc2LaTeXProcs.DefaultOptions := rec(
  EarlyExtraPreamble := "",
  LateExtraPreamble := "",
  InputEncoding := "latin1",
  ColorDefinitions := rec(
             link := "0.0,0.0,0.554",
             cite := "0.0,0.0,0.554",
             file := "0.0,0.0,0.554",
             url := "0.0,0.0,0.554",
             prompt := "0.0,0.0,0.589",
             brkprompt := "0.589,0.0,0.0",
             gapinput := "0.589,0.0,0.0",
             gapoutput := "0.0,0.0,0.0",
             funcdefs := "0.0,0.0,0.0",
             chapter := "0.0,0.0,0.0"
             ),
  MoreColors := "\\definecolor{DarkOlive}{rgb}{0.1047,0.2412,0.0064}\n",
  FontPackages := "\\usepackage{mathptmx,helvet}\n\\usepackage[T1]{fontenc}\n\
\\usepackage{textcomp}\n",
  HyperrefOptions := rec(
             pdftex := "true",
             bookmarks := "true",
             a4paper := "true",
             pdftitle := "{Written with GAPDoc}",
             pdfcreator := "{LaTeX with hyperref package / GAPDoc}",
             colorlinks := "true",
             backref := "page",
             breaklinks := "true",
             pdfpagemode := "{UseNone}",
             MoreHyperrefOptions := "" 
             ),
  TocDepth := "\\setcounter{tocdepth}{1}",
  Maintitlesize := "\\fontsize{50}{55}\\selectfont",
);

# helper function to apply the options to the generic LaTeX head
GAPDoc2LaTeXProcs.HeadWithOptions := function(extra)
  local head, opt, f, ff;
  head := GAPDoc2LaTeXProcs.Head;
  opt := GAPDoc2LaTeXProcs.Options;
  for f in RecNames(opt) do
    if f = "ColorDefinitions" then
      for ff in RecNames(opt.(f)) do
        head := SubstitutionSublist(head, 
                               Concatenation("CONFIGCOLOR",ff), opt.(f).(ff));
      od;
    elif f = "HyperrefOptions" then
      for ff in RecNames(opt.(f)) do
        head := SubstitutionSublist(head, 
                               Concatenation("CONFIGHR",ff), opt.(f).(ff));
      od;
    else
      head := SubstitutionSublist(head, 
                               Concatenation("CONFIG", f), opt.(f));
    fi;
  od;
  head := SubstitutionSublist(head, "PIExtraPreamble", extra);
  return head;
end;

##  arg: a list of strings
##  for now only the output type (one of "dvi", "pdf" or "ps") is used
# to be enhanced
SetGapDocLaTeXOptions := function(arg)    
  local new, recs, r, f, ff;
  GAPDoc2LaTeXProcs.Options := StructuralCopy(GAPDoc2LaTeXProcs.DefaultOptions);
  new := GAPDoc2LaTeXProcs.Options;
  recs := Filtered(arg, IsRecord);
  # handle some abbreviations
  if "nocolor" in arg then
    Add(recs, rec(
           ColorDefinitions := rec(
             link := "0.0,0.0,0.0",
             cite := "0.0,0.0,0.0",
             file := "0.0,0.0,0.0",
             url := "0.0,0.0,0.0",
             prompt := "0.0,0.0,0.0",
             brkprompt := "0.0,0.0,0.0",
             gapinput := "0.0,0.0,0.0",
             gapoutput := "0.0,0.0,0.0",
             funcdefs := "0.0,0.0,0.0",
             chapter := "0.0,0.0,0.0"
                        ) ) );
  fi;
  if "utf8" in arg then
    Add(recs, rec(InputEncoding := "utf8"));
  fi;
  if "nopslatex" in arg then
    Add(recs, rec(FontPackages := "\n"));
  fi;

  # now overwrite the defaults
  for r in recs do
    for f in RecNames(r) do
      if IsRecord(r.(f)) then
        if IsBound(new.(f)) then
          for ff in RecNames(r.(f)) do
            if IsBound(new.(f).(ff)) then
              new.(f).(ff) := r.(f).(ff);
            fi;
          od;
        fi;
      else
        if IsBound(new.(f)) then
          new.(f) := r.(f);
        fi;
      fi;
    od;
  od;
  # set encoder accordingly
  if new.InputEncoding = "utf8" then
    GAPDoc2LaTeXProcs.Encoder := "LaTeXUTF8";
  else
    GAPDoc2LaTeXProcs.Encoder := "LaTeX";
  fi;
end;
# set defaults
SetGapDocLaTeXOptions();

GAPDoc2LaTeXProcs.firstsix := function(r, count)
  local a;
  a := PositionSet(r.root.sixcount, count{[1..3]});
  if a <> fail then
    a := r.root.six[r.root.sixindex[a]];
  fi;
  return a;
end;
##  write head and foot of LaTeX file.
GAPDoc2LaTeXProcs.WHOLEDOCUMENT := function(r, str)
  local   i,  pi,  t,  el,  a;
  
  ##  add internal paragraph numbering
  AddParagraphNumbersGapDocTree(r);
  
  ##  checking for processing instructions
  i := 1;
  pi := rec();
  while not r.content[i].name = "Book" do
    if r.content[i].name = "XMLPI" then
      t := r.content[i].content;
      if Length(t) > 5 and t{[1..6]} = "LaTeX " then
        el := GetSTag(Concatenation("<", t, ">"), 2);
        for a in NamesOfComponents(el.attributes) do
          pi.(a) := el.attributes.(a);
        od;
      fi;
    fi;
    i := i+1;
  od;
  ##  collect headings of labeled sections, here we must run through the
  ##  whole parse tree first to know the headings of text style forward
  ##  references
  GAPDoc2LaTeXProcs._labeledSections := rec();
  ApplyToNodesParseTree(r, function(rr) 
    if IsRecord(rr) and IsBound(rr.name)
       and rr.name in ["Chapter", "Section", "Subsection", "Appendix"] then
      # save heading for "Text" style references to section
      GAPDoc2LaTeXProcs.(rr.name)(rr,"");
    fi;
  end);

  ##  warn if no labels via .six available
  if not IsBound(r.six) then
    Info(InfoGAPDoc, 1, "#W WARNING: No labels for section number independent ",
      "anchors available.\n", 
      "#W Consider running the converter for the text version first!\n");
  fi;

  ##  now the actual work starts, we give the found processing instructions
  ##  to the Book handler
  GAPDoc2LaTeXProcs.Book(r.content[i], str, pi);
  Unbind(GAPDoc2LaTeXProcs._labeledSections);
end;

##  comments and processing instructions are generally ignored
GAPDoc2LaTeXProcs.XMLPI := function(r, str);
end;
GAPDoc2LaTeXProcs.XMLCOMMENT := function(r, str);
end;

# do nothing with Ignore
GAPDoc2LaTeXProcs.Ignore := function(arg)
end;

##  this makes head and foot of the LaTeX output
##  - the only processing instructions handled currently are
##    - options for the report class (german, papersize, ...) and 
##    - extra entries in the preamble (\usepackage, macro definitions, ...)
GAPDoc2LaTeXProcs.Book := function(r, str, pi)
  local   a;
 
  if not IsBound(pi.ExtraPreamble) then
    pi.ExtraPreamble := "";
  fi;

  Append(str, GAPDoc2LaTeXProcs.HeadWithOptions(pi.ExtraPreamble));
  
  # and now the text of the document
  GAPDoc2LaTeXContent(r, str);
  
  # that's it
  Append(str, GAPDoc2LaTeXProcs.Tail);
end;

##  the Body  just prints its content
GAPDoc2LaTeXProcs.Body := GAPDoc2LaTeXContent;

##  the title page,  the most complicated looking function
GAPDoc2LaTeXProcs.TitlePage := function(r, str)
  local   l,  ll, a,  s,  cont;
  
  # page number info for online help
  Append(str, Concatenation("\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\n"));
  Append(str, "\\begin{titlepage}\n\\mbox{}\\vfill\n\n\\begin{center}");
  
  # title
  l := Filtered(r.content, a-> a.name = "Title");
  Append(str, "{\\maintitlesize \\textbf{");
  s := "";
  GAPDoc2LaTeXContent(l[1], s);
  Append(str, s);
  Append(str, "\\mbox{}}}\\\\\n\\vfill\n\n");
  # set title in info part of PDF document
  Append(str, "\\hypersetup{pdftitle=");
  Append(str, s);
  Append(str, "}\n");
  
  # the title is also used for the page headings
  Append(str, "\\markright{\\scriptsize \\mbox{}\\hfill ");
  Append(str, s);
  Append(str, " \\hfill\\mbox{}}\n");

  # subtitle
  l := Filtered(r.content, a-> a.name = "Subtitle");
  if Length(l)>0 then
    Append(str, "{\\Huge \\textbf{");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}}\\\\\n\\vfill\n\n");
  fi;
  
  # version
  l := Filtered(r.content, a-> a.name = "Version");
  if Length(l)>0 then
    Append(str, "{\\Huge ");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}\\\\[1cm]\n");
  fi;

  # date
  l := Filtered(r.content, a-> a.name = "Date");
  if Length(l)>0 then
    Append(str, "{");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}\\\\[1cm]\n");
  fi;
  Append(str, "\\mbox{}\\\\[2cm]\n");

  # author name(s)
  l := Filtered(r.content, a-> a.name = "Author");
  # collect author list for PDF info
  ll := [];
  for a in l do
    Append(str, "{\\Large \\textbf{");
    s := "";
    GAPDoc2LaTeXContent(rec(content := Filtered(a.content, b->
                   not b.name in ["Email", "Homepage", "Address"])), s);
    Append(str, s);
    Add(ll, s);
    Append(str, "\\mbox{}}}\\\\\n");
  od;
  Append(str, "\\hypersetup{pdfauthor=");
  Append(str, JoinStringsWithSeparator(ll, "; "));
  Append(str, "}\n");

  # extra comment for front page
  l := Filtered(r.content, a-> a.name = "TitleComment");
  if Length(l) > 0 then
    Append(str, "\\mbox{}\\\\[2cm]\n\\begin{minipage}{12cm}\\noindent\n");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\end{minipage}\n\n");
  fi;
  Append(str, "\\end{center}\\vfill\n\n\\mbox{}\\\\\n");
  
  # email, WWW-homepage and address of author(s), if given
  l := Filtered(r.content, a-> a.name = "Author");
  for a in l do
    cont := List(a.content, b-> b.name);
    if "Email" in cont or "Homepage" in cont or "Address" in cont then
      Append(str, "{\\mbox{}\\\\\n\\small \\noindent \\textbf{");
      GAPDoc2LaTeXContent(rec(content := Filtered(a.content, b->
                   not b.name in ["Email", "Homepage", "Address"])), str);
      Append(str, "}");
      if "Email" in cont then
        Append(str, Concatenation("  ", GAPDocTexts.d.Email, ": "));
        GAPDoc2LaTeX(a.content[Position(cont, "Email")], str);
      fi;
      if "Homepage" in cont then
        Append(str, "\\\\\n");
        Append(str, Concatenation("  ", GAPDocTexts.d.Homepage, ": "));
        GAPDoc2LaTeX(a.content[Position(cont, "Homepage")], str);
      fi;
      if "Address" in cont then
        Append(str, "\\\\\n");
        Append(str, Concatenation("  ", GAPDocTexts.d.Address, 
                                  ": \\begin{minipage}[t]{8cm}\\noindent\n"));
        GAPDoc2LaTeX(a.content[Position(cont, "Address")], str);
        Append(str, "\\end{minipage}\n");
      fi;
      Append(str, "}\\\\\n");
    fi;
  od;

  # Address outside the Author elements
  l := Filtered(r.content, a-> a.name = "Address");
  if Length(l)>0 then
    Append(str, "\n\\noindent ");
    Append(str, Concatenation("\\textbf{", GAPDocTexts.d.Address, 
                              ": }\\begin{minipage}[t]{8cm}\\noindent\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\end{minipage}\n");
  fi;
  
  Append(str, "\\end{titlepage}\n\n\\newpage");
  
  #  to make physical page numbers same as document page numbers
  Append(str, "\\setcounter{page}{2}\n");

  # abstract
  l := Filtered(r.content, a-> a.name = "Abstract");
  if Length(l)>0 then
    Append(str, Concatenation("{\\small \n\\section*{", GAPDocTexts.d.Abstract,
                              "}\n"));
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}\\\\[1cm]\n");
  fi;
  
  # copyright page
  l := Filtered(r.content, a-> a.name = "Copyright");
  if Length(l)>0 then
    Append(str, Concatenation("{\\small \n\\section*{", GAPDocTexts.d.Copyright,
                              "}\n"));
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}\\\\[1cm]\n");
  fi;

  # acknowledgement page
  l := Filtered(r.content, a-> a.name = "Acknowledgements");
  if Length(l)>0 then
    Append(str, Concatenation("{\\small \n\\section*{", 
                              GAPDocTexts.d.Acknowledgements, "}\n"));
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}\\\\[1cm]\n");
  fi;

  # colophon page
  l := Filtered(r.content, a-> a.name = "Colophon");
  if Length(l)>0 then
    Append(str, Concatenation("{\\small \n\\section*{", GAPDocTexts.d.Colophon,
                              "}\n"));
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\mbox{}}\\\\[1cm]\n");
  fi;  
  Append(str,"\\newpage\n\n");
end;

## this allows line breaks in URL strings s for use with \texttt{s} by
## inserting some "}\discretionary{}{}{}\texttt{" 
GAPDoc2LaTeXProcs.URLBreaks := function(s)
  local pos, ss, old;
  # not after ://
  pos := PositionSublist(s, "://");
  if pos = fail then
    pos := Minimum(3, Length(s));
  else
    pos := pos + 2;
  fi;
  ss := s{[1..pos]};
  old := pos;
  pos := Position(s, '/', old);
  while pos <> fail and pos+3 < Length(s) do
    Append(ss, s{[old+1..pos]});
    Append(ss, "}\\discretionary {}{}{}\\texttt{");
    old := pos;
    pos := Position(s, '/', old);
  od;
  Append(ss, s{[old+1..Length(s)]});
  return ss;
end;

##  ~ and # characters are correctly escaped
##  arg:  r, str[, pre]
GAPDoc2LaTeXProcs.Link := GAPDoc2LaTeXContent;
GAPDoc2LaTeXProcs.LinkText := GAPDoc2LaTeXContent;
GAPDoc2LaTeXProcs.URL := function(arg)
  local r, str, pre, rr, txt, s;
  r := arg[1];
  str := arg[2];
  if Length(arg)>2 then
    pre := arg[3];
  else
    pre := "";
  fi;
  rr := First(r.content, a-> a.name = "LinkText");
  if rr <> fail then
    txt := "";
    GAPDoc2LaTeXContent(rr, txt);
    rr := First(r.content, a-> a.name = "Link");
    if rr = fail then
      Info(InfoGAPDoc, 1, "#W missing <Link> element for text ", txt, "\n");
      s := "MISSINGLINK";
    else
      s := "";
      # must avoid recoding for first argument of \href
      GAPDoc2LaTeXProcs.recode := false;
      GAPDoc2LaTeXContent(rr, s);
      GAPDoc2LaTeXProcs.recode := true;
    fi;
  else
    s := "";
    GAPDoc2LaTeXProcs.recode := false;
    GAPDoc2LaTeXContent(r, s);
    GAPDoc2LaTeXProcs.recode := true;
    if IsBound(r.attributes.Text) then
      txt := r.attributes.Text;
    else
      # need recode in second argument of \href
      txt := Encode(Unicode(s, "UTF-8"), GAPDoc2LaTeXProcs.Encoder);
      txt := Concatenation("\\texttt{", txt, "}");
    fi;
  fi;
  Append(str, Concatenation("\\href{", pre, s, "} {", txt, "}"));
end;

GAPDoc2LaTeXProcs.Homepage := GAPDoc2LaTeXProcs.URL;

GAPDoc2LaTeXProcs.Email := function(r, str)
  # we add the `mailto://' phrase
  GAPDoc2LaTeXProcs.URL(r, str, "mailto://");
end;

##  the sectioning commands are just translated and labels are
##  generated, if given as attribute
GAPDoc2LaTeXProcs.ChapSect := function(r, str, sect)
  local   posh,  a,  s;
  posh := Position(List(r.content, a-> a.name), "Heading");
  # heading
  Append(str, Concatenation("\n\\", sect, "{"));
  s := "";
  if posh <> fail then      
    GAPDoc2LaTeXProcs.Heading1(r.content[posh], s);
  fi;
  Append(str, "\\textcolor{Chapter }{");
  Append(str, s);
  Append(str, "}}");
  # label for references
  if IsBound(r.attributes.Label) then
    Append(str, "\\label{");
    Append(str, r.attributes.Label);
    Append(str, "}\n");
    # save heading for "Text" style references to section
    GAPDoc2LaTeXProcs._labeledSections.(r.attributes.Label) := s;
  fi;
  # page number info for online help (no r.count below Ignore),
  # we also add a section number and page number independent label,
  # if available
  if IsBound(r.count) then
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\n"));
    if IsBound(r.root.six) then
##        a := First(r.root.six, x-> x[3] = r.count{[1..3]});
      a := GAPDoc2LaTeXProcs.firstsix(r, r.count);
      if a <> fail and IsBound(a[7]) then
        Append(str, Concatenation("\\hyperdef{L}{", a[7], "}{}\n"));
      fi;
    fi;
    # the actual content
    Append(str, "{\n");
    GAPDoc2LaTeXContent(r, str);
    Append(str, "}\n\n");
  fi;
end;

##  this really produces the content of the heading
GAPDoc2LaTeXProcs.Heading1 := function(r, str)
  GAPDoc2LaTeXContent(r, str);
end;
##  and this ignores the heading (for simpler recursion)
GAPDoc2LaTeXProcs.Heading := function(r, str)
end;

GAPDoc2LaTeXProcs.Chapter := function(r, str)
  GAPDoc2LaTeXProcs.ChapSect(r, str, "chapter");
end;

GAPDoc2LaTeXProcs.Appendix := function(r, str)
  if r.count[1] = "A" then
    Append(str, "\n\n\\appendix\n\n");
  fi;
  GAPDoc2LaTeXProcs.ChapSect(r, str, "chapter");
end;

GAPDoc2LaTeXProcs.Section := function(r, str)
  GAPDoc2LaTeXProcs.ChapSect(r, str, "section");
end;

GAPDoc2LaTeXProcs.Subsection := function(r, str)
  GAPDoc2LaTeXProcs.ChapSect(r, str, "subsection");
end;

##  table of contents, the job is completely delegated to LaTeX
GAPDoc2LaTeXProcs.TableOfContents := function(r, str)
  # page number info for online help
  Append(str, Concatenation("\\def\\contentsname{", GAPDocTexts.d.Contents, 
          "\\logpage{", GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}}\n"));
  Append(str, "\n\\tableofcontents\n\\newpage\n\n");
end;

##  bibliography, the job is completely delegated to LaTeX and BibTeX
GAPDoc2LaTeXProcs.Bibliography := function(r, str)
  local dat, fname, t, b, st, a;
  # check if bib data are in BibXMLext format, in that case produce a 
  # BibTeX file
  dat := r.attributes.Databases;
  dat := SplitString(dat, "", ", \n\t\b");
  dat := Filtered(dat, a-> Length(a) > 3 and 
                                     a{[Length(a)-3..Length(a)]} = ".xml");
  dat := List(dat, a-> Filename(r.root.bibpath, a));
  for fname in dat do
    b := ParseBibXMLextFiles(fname);
    b := List(b.entries, a-> RecBibXMLEntry(a, b.strings, "BibTeX"));
    WriteBibFile(Concatenation(fname, ".bib"), [b, [], []]);
  od;
  if IsBound(r.attributes.Style) then
    st := r.attributes.Style;
  else
    st := "alpha";
  fi;

  # page number info for online help
  Append(str, Concatenation("\\def\\bibname{", GAPDocTexts.d.References,
          "\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\n"));
  if IsBound(r.root.six) then
##      a := First(r.root.six, x-> x[3] = r.count{[1..3]});
    a := GAPDoc2LaTeXProcs.firstsix(r, r.count);
    if a <> fail and IsBound(a[7]) then
      Append(str, Concatenation("\\hyperdef{L}{", a[7], "}{}\n"));
    fi;
  fi;
  Append(str, "}\n");
  Append(str, "\n\\bibliographystyle{");
  Append(str, st);
  Append(str,"}\n\\bibliography{");
  Append(str, r.attributes.Databases);
  Append(str, "}\n\n");
  # toc entry
  Append(str, "\\addcontentsline{toc}{chapter}{");
  Append(str, GAPDocTexts.d.References);
  Append(str, "}\n\n");
end;

##  as default we normalize white space in text and split the result 
##  into lines (leading and trailing white space is also substituted 
##  by one space).
GAPDoc2LaTeXProcs.PCDATA := function(r, str)
  local   lines,  i;
  if GAPDoc2LaTeXProcs.verbatimPCDATA then
    # no reformatting at all, used for <Alt Only="LaTeX"> content
    Append(str, r.content);
    return;
  fi;
  if Length(r.content)>0 and r.content[1] in WHITESPACE then
    Add(str, ' ');
  fi;
  lines := r.content;
  if GAPDoc2LaTeXProcs.recode = true then
    lines := Encode(Unicode(lines), GAPDoc2LaTeXProcs.Encoder);
  fi;
  lines := FormatParagraph(lines, "left");
  if Length(lines)>0 then
    if r.content[Length(r.content)] in WHITESPACE then
      lines[Length(lines)] := ' ';
    else
      Unbind(lines[Length(lines)]);
    fi;
  fi;
  Append(str, lines);
end;

##  end of paragraph 
GAPDoc2LaTeXProcs.P := function(r, str)
  Append(str, "\n\n");
end;

##  forced line break
GAPDoc2LaTeXProcs.Br := function(r, str)
  Append(str, "\\\\\n");
end;

##  generic function to get content and wrap by some markup
GAPDoc2LaTeXProcs.WrapMarkup := function(r, str, pre, post)
  local s;
  s := "";
  GAPDoc2LaTeXContent(r, s);
  Append(str, Concatenation(pre, s, post));
end;

##  setting in typewriter
GAPDoc2LaTeXProcs.WrapTT := function(r, str)
  GAPDoc2LaTeXProcs.WrapMarkup(r, str, "\\texttt{", "}");
end;

##  GAP keywords 
GAPDoc2LaTeXProcs.K := function(r, str)
  GAPDoc2LaTeXProcs.WrapTT(r, str);
end;

##  verbatim GAP code
GAPDoc2LaTeXProcs.C := function(r, str)
  GAPDoc2LaTeXProcs.WrapTT(r, str);
end;

##  file names
GAPDoc2LaTeXProcs.F := function(r, str)
  GAPDoc2LaTeXProcs.WrapTT(r, str);
end;

##  argument names
GAPDoc2LaTeXProcs.A := function(r, str)
  Append(str, "\\mbox{");
##    GAPDoc2LaTeXProcs.WrapTT(r, str);
  ## the \mdseries is necessary because there is no bold-sl which
  ## LaTeX substitutes by bold-normal, but we want medium-sl
  GAPDoc2LaTeXProcs.WrapMarkup(r, str, "\\texttt{\\mdseries\\slshape ", "}");
  Append(str, "}");
end;

##  simple maths
GAPDoc2LaTeXProcs.M := function(r, str)
  local saveenc;
  Append(str, "$");
  # here the input is already coded in LaTeX
  saveenc := GAPDoc2LaTeXProcs.Encoder;
  GAPDoc2LaTeXProcs.Encoder := "LaTeXleavemarkup";
  GAPDoc2LaTeXContent(r, str);
  GAPDoc2LaTeXProcs.Encoder := saveenc;
  Append(str, "$");
end;

##  in LaTeX same as <M>
GAPDoc2LaTeXProcs.Math := GAPDoc2LaTeXProcs.M;

##  displayed maths
GAPDoc2LaTeXProcs.Display := function(r, str)
  local saveenc;
  if Length(str)>0 and str[Length(str)] <> '\n' then
    Add(str, '\n');
  fi;
  Append(str, "\\[");
  saveenc := GAPDoc2LaTeXProcs.Encoder;
  GAPDoc2LaTeXProcs.Encoder := "LaTeXleavemarkup";
  GAPDoc2LaTeXContent(r, str);
  GAPDoc2LaTeXProcs.Encoder := saveenc;
  Append(str, "\\]\n");
end;

##  emphazised text
GAPDoc2LaTeXProcs.Emph := function(r, str)
  local   a;
  Append(str, "\\emph{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}");
end;

##  quoted text
GAPDoc2LaTeXProcs.Q := function(r, str)
  local   a;
  Append(str, "``");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "''");
end;

##  Package names
GAPDoc2LaTeXProcs.Package := function(r, str)
  local   a;
  Append(str, "\\textsf{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}");
end;

##  menu items
GAPDoc2LaTeXProcs.B := function(r, str)
  local   a;
  Append(str, "\\textsc{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}");
end;

GAPDoc2LaTeXProcs.verbcontent := function(r, delfirst)
  local cont;
  # here we cannot use recoding, fall back to SimplifiedUnicodeString (latin1)
  # first collect content without recoding or reformatting
  cont := GetTextXMLTree(r);
  if GAPDoc2LaTeXProcs.Options.InputEncoding = "latin1" then
    cont := Encode(SimplifiedUnicodeString(Unicode(cont), "latin1"), "latin1");
  fi;
  cont := SplitString(cont, "\n", "");
  # if first line has white space only, we remove it
  if delfirst and Length(cont) > 0 and ForAll(cont[1], x-> x in WHITESPACE) then
    cont := cont{[2..Length(cont)]};
  fi;
  cont := Concatenation(List(cont, a-> Concatenation("  ", a, "\n")));
  return cont;
end;

##  verbatim GAP session
GAPDoc2LaTeXProcs.Verb := function(r, str)
  local   cont,  a,  s;
  Append(str, "\n\\begin{verbatim}");
  Append(str, GAPDoc2LaTeXProcs.verbcontent(r, false));
  Append(str, "\\end{verbatim}\n");
end;

GAPDoc2LaTeXProcs.ExampleLike := function(r, str, label, findprompts)
  local cont, comopt, comchars, sp, pos, c;
  cont := GAPDoc2LaTeXProcs.verbcontent(r, true);
  comopt := "";
  if findprompts then
    comchars := "";
    for c in Concatenation("!@|", LETTERS) do
      if not c in cont then
        Add(comchars, c);
        if Length(comchars) = 3 then
          break;
        fi;
      fi;
    od;
    if Length(comchars) = 3 then
      comopt := Concatenation("commandchars=",comchars,",");
      sp := SplitString(cont, "\n", "");
      cont := "";
      for r in sp do
        if Length(r) > 6 and r{[1..7]} = "  gap> " then
          Append(cont, Concatenation("  ",comchars{[1]},
                 "gapprompt",comchars{[2]},
                 "gap>",comchars{[3]}," ",comchars{[1]},"gapinput",
                 comchars{[2]},r{[8..Length(r)]},comchars{[3]},"\n"));
        elif Length(r) > 3 and r{[1..4]} = "  > " then
          Append(cont, Concatenation("  ",comchars{[1]},
                 "gapprompt",comchars{[2]},
                 ">",comchars{[3]}," ",comchars{[1]},"gapinput",
                 comchars{[2]},r{[5..Length(r)]},comchars{[3]},"\n"));
        elif Length(r) > 5 and r{[1..5]} = "  brk" then
          pos := Position(r, '>');
          Append(cont, Concatenation("  ",comchars{[1]},
                 "gapbrkprompt",comchars{[2]},
                 r{[3..pos]},comchars{[3]}," ",comchars{[1]},"gapinput",
                 comchars{[2]},r{[pos+2..Length(r)]},comchars{[3]},"\n"));
        else
          Append(cont, r);
          Add(cont, '\n');
        fi;
      od;
    fi;
  fi;
  Append(str, Concatenation("\n\\begin{Verbatim}[",comopt,
          "fontsize=\\small,",
          "frame=single,label=", label, "]\n"));
  Append(str, cont);
  Append(str, "\\end{Verbatim}\n");
end;

##  log of session and GAP code is typeset the same way as <Example>
GAPDoc2LaTeXProcs.Example := function(r, str)
  GAPDoc2LaTeXProcs.ExampleLike(r, str, GAPDocTexts.d.Example, true);
end;
GAPDoc2LaTeXProcs.Log := function(r, str)
  GAPDoc2LaTeXProcs.ExampleLike(r, str, GAPDocTexts.d.Log, true);
end;
GAPDoc2LaTeXProcs.Listing := function(r, str)
  if IsBound(r.attributes.Type) then
    GAPDoc2LaTeXProcs.ExampleLike(r, str, r.attributes.Type, false);
  else
    GAPDoc2LaTeXProcs.ExampleLike(r, str, "", false);
  fi;
end;

##  explicit labels
GAPDoc2LaTeXProcs.Label := function(r, str)
  Append(str, "\\label{");
  Append(str, r.attributes.Name);
  Append(str, "}");
end;

##  citations
GAPDoc2LaTeXProcs.Cite := function(r, str)
  Append(str, "\\cite");
  if IsBound(r.attributes.Where) then
    Add(str, '[');
    Append(str, Encode(Unicode(r.attributes.Where), GAPDoc2LaTeXProcs.Encoder));
    Add(str, ']');
  fi;
  Add(str, '{');
  Append(str, r.attributes.Key);
  Add(str, '}');
end;

##  explicit index entries
GAPDoc2LaTeXProcs.Subkey := GAPDoc2LaTeXContent;
GAPDoc2LaTeXProcs.Index := function(r, str)
  local s, sub, a;
  s := "";
  sub := "";
  for a in r.content do
    if a.name = "Subkey" then
      GAPDoc2LaTeX(a, sub);
    else
      GAPDoc2LaTeX(a, s);
    fi;
  od;
  NormalizeWhitespace(s);
  NormalizeWhitespace(sub);
  if IsBound(r.attributes.Key) then
    s := Concatenation(r.attributes.Key, "@", s);
  fi;
  if Length(sub) > 0 then
    s := Concatenation(s, "!", sub);
  elif IsBound(r.attributes.Subkey) then
    s := Concatenation(s, "!", r.attributes.Subkey);
  fi;
  Append(str, "\\index{");
  Append(str, s);
  Append(str, "}");
end;

##  this produces an implicit index entry and a label entry
GAPDoc2LaTeXProcs.LikeFunc := function(r, str, typ)
  local nam, namclean, lab, inam, i;
  Append(str, "\\noindent\\textcolor{FuncColor}{$\\triangleright$\\enspace\\texttt{");
  nam := r.attributes.Name;
  namclean := GAPDoc2LaTeXProcs.DeleteUsBs(nam);
  # we allow _,  \ and so on here
  nam := GAPDoc2LaTeXProcs.EscapeAttrVal(nam);
  Append(str, nam);
  if IsBound(r.attributes.Arg) then
    Append(str, "({\\mdseries\\slshape ");
    Append(str, GAPDoc2LaTeXProcs.EscapeAttrVal(
                NormalizedArgList(r.attributes.Arg)));
    Append(str, "})");
  fi;
  # possible label
  if IsBound(r.attributes.Label) then
    lab := Concatenation("!", r.attributes.Label);
  else
    lab := "";
  fi;
  # index entry
  # handle extremely long names
  if Length(nam) > GAPDoc2LaTeXProcs.MaxIndexEntryWidth then
    inam := nam{[1..3]};
    for i in [4..Length(nam)-3] do
      if nam[i] in CAPITALLETTERS then
        Append(inam, "}\\-\\texttt{");
      fi;
      Add(inam, nam[i]);
    od;
    Add(inam, nam[Length(nam)-2]); Add(inam, nam[Length(nam)-1]);
    Add(inam, nam[Length(nam)]);
  else
    inam := nam;
  fi;
  Append(str, Concatenation("\\index{", namclean, "@\\texttt{",
          inam, "}", lab, "}\n"));
  # label (if not given, the default is the Name)
  if IsBound(r.attributes.Label) then
    namclean := Concatenation(namclean, ":", r.attributes.Label);
  fi;
  Add(GAPDoc2LaTeXProcs._currentSubsection, namclean);
  Append(str, Concatenation("\\label{", namclean, "}\n"));
  # some hint about the type of the variable
  Append(str, "}\\hfill{\\scriptsize (");
  Append(str, typ);
  Append(str, ")}}\\\\\n");
end;

GAPDoc2LaTeXProcs.Func := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Func);
end;

GAPDoc2LaTeXProcs.Oper := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Oper);
end;

GAPDoc2LaTeXProcs.Constr := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Constr);
end;

GAPDoc2LaTeXProcs.Meth := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Meth);
end;

GAPDoc2LaTeXProcs.Filt := function(r, str)
  # r.attributes.Type could be "representation", "category", ...
  if IsBound(r.attributes.Type) then
    GAPDoc2LaTeXProcs.LikeFunc(r, str, r.attributes.Type);
  else
    GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Filt);
  fi;
end;

GAPDoc2LaTeXProcs.Prop := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Prop);
end;

GAPDoc2LaTeXProcs.Attr := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Attr);
end;

GAPDoc2LaTeXProcs.Var := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Var);
end;

GAPDoc2LaTeXProcs.Fam := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.Fam);
end;

GAPDoc2LaTeXProcs.InfoClass := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, GAPDocTexts.d.InfoClass);
end;

##  using the HelpData(.., .., "ref") interface
GAPDoc2LaTeXProcs.ResolveExternalRef := function(bookname,  label, nr)
  local info, match, res;
  info := HELP_BOOK_INFO(bookname);
  if info = fail then
    return fail;
  fi;
  match := Concatenation(HELP_GET_MATCHES(info, SIMPLE_STRING(label), true));
  #   maybe change, and check if there are matches to several subsections?
  #ssecs := List(match, i-> HELP_BOOK_HANDLER.(info.handler).HelpData(info,
  #         match[i][2], "ref")[7]);
  if Length(match) < nr then
    return fail;
  fi;
  res := GetHelpDataRef(info, match[nr][2]);
  res[1] := SubstitutionSublist(res[1], " (not loaded): ", ": ", "one");
  return res;
end;

GAPDoc2LaTeXProcs.Ref := function(r, str)
  local   funclike,  int,  txt,  ref,  lab,  sectlike, slab;
  
  # function like cases
  funclike := [ "Func", "Oper", "Constr", "Meth", "Filt", "Prop", "Attr", 
                "Var", "Fam", "InfoClass" ];
  int := Intersection(funclike, NamesOfComponents(r.attributes));
  if Length(int)>0 then
    txt := r.attributes.(int[1]);
    if IsBound(r.attributes.Label) then
      lab := Concatenation(txt, ":", r.attributes.Label);
    else
      lab := txt;
    fi;
    if IsBound(r.attributes.BookName) then
      slab := txt;
      if IsBound(r.attributes.Label) then
        slab := Concatenation(slab, " (", r.attributes.Label, ")");
      fi;
      ref := GAPDoc2LaTeXProcs.ResolveExternalRef(
                                             r.attributes.BookName, slab, 1);
      if ref = fail then
        Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
        ref := Concatenation(" (", Encode(Unicode(lab),
               GAPDoc2LaTeXProcs.Encoder)
               , "???)");
      else
        # the search text for online help including book name
        ref := Concatenation(" (\\textbf{", 
                              GAPDoc2LaTeXProcs.EscapeAttrVal(ref[1]), "})");
      fi;
    else
      ref := Concatenation(" (\\ref{", GAPDoc2LaTeXProcs.DeleteUsBs(lab), "})");
    fi;
    # delete ref, if pointing to current subsection
    if not IsBound(r.attributes.BookName) and 
                 IsBound(GAPDoc2LaTeXProcs._currentSubsection) and 
                 lab in GAPDoc2LaTeXProcs._currentSubsection then
      ref := "";
    fi;
    Append(str, Concatenation("\\texttt{", GAPDoc2LaTeXProcs.EscapeAttrVal(txt), 
            "}", ref));
    return;
  fi;
  
  # section like cases
  sectlike := ["Chap", "Sect", "Subsect", "Appendix"];
  int := Intersection(sectlike, NamesOfComponents(r.attributes));
  if Length(int)>0 then
    txt := r.attributes.(int[1]);
    if IsBound(r.attributes.Label) then
      lab := r.attributes.Label;
    else
      lab := txt;
    fi;
    if IsBound(r.attributes.BookName) then
      ref := GAPDoc2LaTeXProcs.ResolveExternalRef(
                                          r.attributes.BookName, lab, 1);
      if ref = fail then
        Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
        ref := Concatenation(" (", lab, "???)");
      else
        # the search text for online help including book name
        ref := Concatenation(" (\\textbf{", GAPDoc2LaTeXProcs.EscapeAttrVal(ref[1]), "})");
      fi;
    elif IsBound(r.attributes.Style) and r.attributes.Style = "Text" then
      if IsBound(GAPDoc2LaTeXProcs._labeledSections.(lab)) then
        ref := Concatenation("\\hyperref[",lab,"]{`", StripBeginEnd(
                GAPDoc2LaTeXProcs._labeledSections.(lab), WHITESPACE), "'}"); 
      else
        Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
        ref := "`???'";
      fi;
    else
      # with sectioning references Label must be given
      lab := r.attributes.(int[1]);
      #ref := Concatenation("\\ref{", GAPDoc2LaTeXProcs.EscapeAttrVal(lab), "}");
      ref := Concatenation("\\ref{", lab, "}");
    fi;
    Append(str, ref);
    return;
  fi;
  
  # neutral reference to a label
  if IsBound(r.attributes.BookName) then
    if IsBound(r.attributes.Label) then
      lab := r.attributes.Label;
    else
      lab := "_X_X_X";
    fi;
    ref := GAPDoc2LaTeXProcs.ResolveExternalRef(
                                        r.attributes.BookName, lab, 1);
    if ref = fail then
      Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
      ref := Concatenation(" ", GAPDoc2LaTeXProcs.EscapeAttrVal(lab), "??? ");
    else
      # the search text for online help including book name
      ref := Concatenation(" \\textbf{", GAPDoc2LaTeXProcs.EscapeAttrVal(ref[1]), "}");
    fi;
  else
    lab := r.attributes.Label;
    ref := Concatenation("\\ref{", GAPDoc2LaTeXProcs.EscapeAttrVal(lab), "}");
  fi;
  Append(str, ref);
  return;
end;

# just process
GAPDoc2LaTeXProcs.Address := function(r, str)
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.Description := function(r, str)
  Append(str, "\n\n");
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.Returns := function(r, str)
  Append(str, Concatenation("\\textbf{\\indent ", GAPDocTexts.d.Returns, 
                            ":\\ }\n"));
  GAPDoc2LaTeXContent(r, str); 
  Append(str,"\n\n");
end;

GAPDoc2LaTeXProcs.ManSection := function(r, str)
  local   funclike,  f,  lab,  i, a;
  
  # if there is a Heading then handle as subsection
  if ForAny(r.content, a-> IsRecord(a) and a.name = "Heading") then
    GAPDoc2LaTeXProcs._currentSubsection := r.count{[1..3]};
    GAPDoc2LaTeXProcs.ChapSect(r, str, "subsection");
    Unbind(GAPDoc2LaTeXProcs._currentSubsection);
    return;
  fi;
  # function like elements
  funclike := [ "Func", "Oper", "Constr", "Meth", "Filt", "Prop", "Attr",
                "Var", "Fam", "InfoClass" ];
  
  # heading comes from name of first function like element
  i := 1;
  while not r.content[i].name in funclike do
    i := i+1;
  od;
  f := r.content[i];
  if IsBound(f.attributes.Label) then
    lab := Concatenation(" (", f.attributes.Label, ")");
  else
    lab := "";
  fi;
  Append(str, Concatenation("\n\n\\subsection{\\textcolor{Chapter }{", 
          GAPDoc2LaTeXProcs.EscapeAttrVal(f.attributes.Name), lab, "}}\n"));
  # page number info for online help
  Append(str, Concatenation("\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\\nobreak\n"));
  # label for references
  if IsBound(r.attributes.Label) then
    Append(str, "\\label{");
    Append(str, r.attributes.Label);
    Append(str, "}\n");
    # save heading for "Text" style references to section
    GAPDoc2LaTeXProcs._labeledSections.(r.attributes.Label) := Concatenation(
                       GAPDoc2LaTeXProcs.EscapeAttrVal(f.attributes.Name), lab);
  fi;
  if IsBound(r.root.six) then
##      a := First(r.root.six, x-> x[3] = r.count{[1..3]});
    a := GAPDoc2LaTeXProcs.firstsix(r, r.count);
    if a <> fail and IsBound(a[7]) then
      Append(str, Concatenation("\\hyperdef{L}{", a[7], "}{}\n"));
    fi;
  fi;
  # to avoid references to local subsection in description:
  GAPDoc2LaTeXProcs._currentSubsection := r.count{[1..3]};
  Append(str, "{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}\n\n");
  Unbind(GAPDoc2LaTeXProcs._currentSubsection);
end;

GAPDoc2LaTeXProcs.Mark := function(r, str)
  Append(str, "\n\\item[{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}] ");
end;

GAPDoc2LaTeXProcs.Item := function(r, str)
  Append(str, "\n\\item ");
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.List := function(r, str)
  local   item,  type,  a;
  if "Mark" in List(r.content, a-> a.name) then
    item := "";
    type := "description";
  else
    item := "\n\\item ";
    type := "itemize";
  fi;
  Append(str, Concatenation("\n\\begin{", type, "}"));
  for a in r.content do
    if a.name = "Mark" then
      GAPDoc2LaTeXProcs.Mark(a, str);
    elif a.name = "Item" then
      Append(str, item);
      GAPDoc2LaTeXContent(a, str);
    fi;
  od;
  Append(str, Concatenation("\n\\end{", type, "}\n"));
end;

GAPDoc2LaTeXProcs.Enum := function(r, str)
  Append(str, "\n\\begin{enumerate}");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "\n\\end{enumerate}\n");
end;

GAPDoc2LaTeXProcs.TheIndex := function(r, str)
  local a;
  # page number info for online help
  Append(str, Concatenation("\\def\\indexname{", GAPDocTexts.d.Index, 
            "\\logpage{", GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\n"));
  if IsBound(r.root.six) then
##      a := First(r.root.six, x-> x[3] = r.count{[1..3]});
    a := GAPDoc2LaTeXProcs.firstsix(r, r.count);
    if a <> fail and IsBound(a[7]) then
      Append(str, Concatenation("\\hyperdef{L}{", a[7], "}{}\n"));
    fi;
  fi;
  Append(str, "}\n\n");
  # toc entry
  Append(str, "\\cleardoublepage\n\\phantomsection\n");
  Append(str, "\\addcontentsline{toc}{chapter}{");
  Append(str, GAPDocTexts.d.Index);
  Append(str, "}\n");
  Append(str, "\n\n\\printindex\n\n");
end;

# like PCDATA
GAPDoc2LaTeXProcs.EntityValue := GAPDoc2LaTeXProcs.PCDATA;

GAPDoc2LaTeXProcs.Table := function(r, str)
  local cap;
  if (IsBound(r.attributes.Only) and r.attributes.Only <> "LaTeX") or
     (IsBound(r.attributes.Not) and r.attributes.Not = "LaTeX") then
    return;
  fi;
  # head part of table and tabular
  if IsBound(r.attributes.Label) then
    Append(str, "\\mbox{}\\label{");
    Append(str, r.attributes.Label);
    Add(str, '}');
  fi;
  Append(str, "\\begin{center}\n\\begin{tabular}{");
  Append(str, r.attributes.Align);
  Add(str, '}');
  # the rows of the table
  GAPDoc2LaTeXContent(r, str);
  # the trailing part with caption, if given
  Append(str, "\\end{tabular}\\\\[2mm]\n");
  cap := Filtered(r.content, a-> a.name = "Caption");
  if Length(cap) > 0 then
    GAPDoc2LaTeXProcs.Caption1(cap[1], str);
  fi;
  Append(str, "\\end{center}\n\n");
end;

# do nothing, we call .Caption1 directly in .Table
GAPDoc2LaTeXProcs.Caption := function(r, str)
  return;
end;

# here the caption text is produced
GAPDoc2LaTeXProcs.Caption1 := function(r, str)
  Append(str, Concatenation("\\textbf{", GAPDocTexts.d.Table, ": }"));
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.HorLine := function(r, str)
  Append(str, "\\hline\n");
end;

GAPDoc2LaTeXProcs.Row := function(r, str)
  local i, l;
  l := Filtered(r.content, a-> a.name = "Item");
  for i in [1..Length(l)-1] do
    GAPDoc2LaTeXContent(l[i], str);
    Append(str, "&\n");
  od;
  GAPDoc2LaTeXContent(l[Length(l)], str);
  Append(str, "\\\\\n");
end;

GAPDoc2LaTeXProcs.Alt := function(r, str)
  local take, types;
  take := false;
  if IsBound(r.attributes.Only) then
    NormalizeWhitespace(r.attributes.Only);
    types := SplitString(r.attributes.Only, "", " ,");
    if "LaTeX" in types or "BibTeX" in types then
      take := true;
      GAPDoc2LaTeXProcs.recode := false;
      GAPDoc2LaTeXProcs.verbatimPCDATA := true;
    fi;
  fi;
  if IsBound(r.attributes.Not) then
    NormalizeWhitespace(r.attributes.Not);
    types := SplitString(r.attributes.Not, "", " ,");
    if not "LaTeX" in types then
      take := true;
    fi;
  fi;
  if take then
    GAPDoc2LaTeXContent(r, str);
  fi;
  GAPDoc2LaTeXProcs.recode := true;
  GAPDoc2LaTeXProcs.verbatimPCDATA := false;
end;

# copy a few entries with two element names
GAPDoc2LaTeXProcs.E := GAPDoc2LaTeXProcs.Emph;
GAPDoc2LaTeXProcs.Keyword := GAPDoc2LaTeXProcs.K;
GAPDoc2LaTeXProcs.Code := GAPDoc2LaTeXProcs.C;
GAPDoc2LaTeXProcs.File := GAPDoc2LaTeXProcs.F;
GAPDoc2LaTeXProcs.Button := GAPDoc2LaTeXProcs.B;
GAPDoc2LaTeXProcs.Arg := GAPDoc2LaTeXProcs.A;
GAPDoc2LaTeXProcs.Quoted := GAPDoc2LaTeXProcs.Q;
GAPDoc2LaTeXProcs.Par := GAPDoc2LaTeXProcs.P;

