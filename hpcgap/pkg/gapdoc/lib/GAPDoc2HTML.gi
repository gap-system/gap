#############################################################################
##
#W  GAPDoc2HTML.gi                 GAPDoc                        Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2HTML.g{d,i}  contain  a  conversion program  which
##  produces from a  GAPDoc XML-document an HTML version for reading the
##  document with a Web-browser.
##  

##  REMARKS:
##  
##  We add to all  nodes of the parse tree an entry  .root which points to
##  the document root.  The toc-, index- and  bib-information is collected
##  in the root.
##  
##  The set  of elements  is partitioned  into two  subsets -  those which
##  contain whole paragraphs and those which don't.
##  
##  The     handler    of   a   paragraph     containing    element   (see
##  GAPDoc2HTMLProcs.ParEls below)  gets a  list as  argument to  which it
##  adds entries pairwise:   the first of such a   pair is  the  paragraph
##  counter (like [3,2,1,5] meaning Chap.3,   Sec.2, Subsec.1, Par.5)  and
##  the second is the formatted text of this paragraph.
##  
##  Some   handlers  of paragraph   containing  elements do the formatting
##  themselves (e.g., .List), the others are handled in the main recursion
##  function `GAPDoc2HTMLContent'.
##  
##  We produce  a full version of  the document in HTML  format, including
##  title  page,  abstract and  other  front  matter, table  of  contents,
##  bibliography (via  BibTeX-data files) and  index. For this we  have to
##  process a document twice (similar to LaTeX).
##  

##  Small utility to throw away SGML markup
BindGlobal("FilterSGMLMarkup", function(str)
  local p2, p1, res;
  p2 := Position(str, '<');
  if p2 = fail then
    return str;
  fi;
  p1 := 0;
  res := "";
  while p2 <> fail do
    Append(res, str{[p1+1..p2-1]});
    p1 := Position(str, '>', p2);
    if p1 = fail then
      return res;
    fi;
    p2 := Position(str, '<', p1);
    if p2 = fail then
      Append(res, str{[p1+1..Length(str)]});
      return res;
    fi;
  od;
end);

    

InstallValue(GAPDoc2HTMLProcs, rec());

##  Some text attributes ([begin, end] pairs)
GAPDoc2HTMLProcs.TextAttr := rec();
GAPDoc2HTMLProcs.TextAttr.Heading := ["<span class=\"Heading\">", "</span>"];

GAPDoc2HTMLProcs.TextAttr.Func := ["<code class=\"func\">", "</code>"];
GAPDoc2HTMLProcs.TextAttr.Arg := ["<var class=\"Arg\">", "</var>"];
GAPDoc2HTMLProcs.TextAttr.Example := ["<div class=\"Example\">", "</div>"];
GAPDoc2HTMLProcs.TextAttr.Package := ["<strong class=\"pkg\">", "</strong>"];
GAPDoc2HTMLProcs.TextAttr.URL := ["<span class=\"URL\">", "</span>"];
GAPDoc2HTMLProcs.TextAttr.Mark := ["<strong class=\"Mark\">", "</strong>"];

GAPDoc2HTMLProcs.TextAttr.K := ["<code class=\"keyw\">", "</code>"];
GAPDoc2HTMLProcs.TextAttr.C := ["<code class=\"code\">", "</code>"];
GAPDoc2HTMLProcs.TextAttr.F := ["<code class=\"file\">", "</code>"];
GAPDoc2HTMLProcs.TextAttr.I := ["<code class=\"i\">", "</code>"];
GAPDoc2HTMLProcs.TextAttr.B := ["<strong class=\"button\">", "</strong>"];
GAPDoc2HTMLProcs.TextAttr.Emph := ["<em>", "</em>"];
GAPDoc2HTMLProcs.TextAttr.Ref := ["<span class=\"RefLink\">", "</span>"];
GAPDoc2HTMLProcs.TextAttr.M := ["<span class=\"SimpleMath\">", "</span>"];
GAPDoc2HTMLProcs.TextAttr.Math := ["<span class=\"Math\">", "</span>"];
GAPDoc2HTMLProcs.TextAttr.GAPprompt := 
                                ["<span class=\"GAPprompt\">", "</span>"];
GAPDoc2HTMLProcs.TextAttr.GAPbrkprompt := 
                                ["<span class=\"GAPbrkprompt\">", "</span>"];
GAPDoc2HTMLProcs.TextAttr.GAPinput := 
                                ["<span class=\"GAPinput\">", "</span>"];

# like in Text converter, but a heading and an address are not a paragraph here
GAPDoc2HTMLProcs.ParEls := 
[ "Display", "Example", "Log", "Listing", "List", "Enum", "Item", "Table", 
  "TitlePage", "Abstract", "Copyright", "Acknowledgements",
  "Colophon", "TableOfContents", "Bibliography", "TheIndex",
  "Subsection", "ManSection", "Description", "Returns", "Section",
  "Chapter", "Appendix", "Body", "Book", "WHOLEDOCUMENT", "Attr", "Fam",
  "Filt", "Func", "InfoClass", "Meth", "Oper", "Prop", "Var", "Verb" ];

##  arg: a list of strings
##  for now only ??????
SetGapDocHTMLOptions := function(arg)    
  local   gdp;
  gdp := GAPDoc2HTMLProcs;
  return;  
end;

GAPDoc2HTMLProcs.Head1 := "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
\n\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\
         \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\
\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n\
<head>\n\
<title>GAP (";

GAPDoc2HTMLProcs.MathJaxURL := "http://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML";

GAPDoc2HTMLProcs.Head1MathJax := "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
\n\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\
         \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\
\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n\
<head>\n\
<script type=\"text/javascript\"\n\
  src=\"MATHJAXURL\">\n\
</script>\n\
<title>GAP (";

GAPDoc2HTMLProcs.Head1Trans := "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
\n\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n\
         \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n\
\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n\
<head>\n\
<title>GAP (";

GAPDoc2HTMLProcs.Head1MML := "\
<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<?xml-stylesheet type=\"text/xsl\" href=\"mathml.xsl\"?>\n\
\n\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN\"\n\
       \"http://www.w3.org/TR/MathML2/dtd/xhtml-math11-f.dtd\" [\n\
       <!ENTITY mathml \"http://www.w3.org/1998/Math/MathML\">\n\
       ] >\n\
\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n\
<head>\n\
<link rel=\"stylesheet\" type=\"text/css\" href=\"mathml.css\" />\n\
<title>GAP (";

GAPDoc2HTMLProcs.Head2 := "\
</title>\n\
<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\" />\n\
<meta name=\"generator\" content=\"GAPDoc2HTML\" />\n\
<link rel=\"stylesheet\" type=\"text/css\" href=\"manual.css\" />\n\
<script src=\"manual.js\" type=\"text/javascript\"></script>\n\
<script type=\"text/javascript\">overwriteStyle();</script>\n\
</head>\n<body onload=\"jscontent()\">\n";

GAPDoc2HTMLProcs.Tail := "\n\
<hr />\n\
<p class=\"foot\">generated by <a \
href=\"http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc\">GAPDoc2HTML\
</a></p>\
\n</body>\n</html>\n";  

GAPDoc2HTMLProcs.PutFilesTogether := function(l, r)
  local   files,  n,  tt,  i, chnrs, chlink, prev, next, toplink;
  
  chnrs := Set(List([2,4..Length(l)], i-> l[i-1][1]));
  chnrs := Concatenation(Filtered(chnrs, a-> not a in ["Bib", "Ind"]),
                         Filtered(chnrs, a-> a in ["Bib", "Ind"]));
  chlink := Concatenation("\n<div class=\"chlinktop\"><span class=\"chlink1\">",
            GAPDocTexts.d.GotoChapter, ": </span>");
  for n in chnrs do
    Append(chlink, Concatenation("<a href=\"chap", String(n), 
           GAPDoc2HTMLProcs.ext, "\">"));
    if n = 0 then
      Append(chlink, GAPDocTexts.d.Top);
    else
      Append(chlink, String(n));
    fi;
    Append(chlink,"</a>  ");
  od;
  Append(chlink, "</div>\n");
  
  toplink := Concatenation( "&nbsp;<a href=\"chap0", GAPDoc2HTMLProcs.ext, 
             "\">[", GAPDocTexts.d.TopofBook, "]</a>&nbsp;  ",
             "<a href=\"chap0", GAPDoc2HTMLProcs.ext, "#contents",
             "\">[", GAPDocTexts.d.Contents, "]</a>&nbsp;  " );
  prev := [];
  next := [];
  for i in [1..Length(chnrs)] do
    if i > 1 then
      Add(prev, Concatenation("&nbsp;<a href=\"chap", String(chnrs[i-1]),
                  GAPDoc2HTMLProcs.ext, "\">[", GAPDocTexts.d.PreviousChapter,
                  "]</a>&nbsp;  "));
    else
      Add(prev, "");
    fi;
    if i < Length(chnrs) then
      Add(next, Concatenation("&nbsp;<a href=\"chap", String(chnrs[i+1]),
                        GAPDoc2HTMLProcs.ext, "\">[", GAPDocTexts.d.NextChapter,
                        "]</a>&nbsp;  "));
    else
      Add(next, "");
    fi;
  od;
  # putting the paragraphs together (one string (file) for each chapter)
  files := rec();
  for i in [1..Length(chnrs)] do
    n := chnrs[i];
    if r.root.mathmode = "MathML" then
      # this MathML is no longer documented
      files.(n) := rec(text := 
                   ShallowCopy(GAPDoc2HTMLProcs.Head1MML), ssnr := []);
    elif r.root.mathmode = "Tth" then
      files.(n) := rec(text :=
                   ShallowCopy(GAPDoc2HTMLProcs.Head1Trans), ssnr := []);
    elif r.root.mathmode = "MathJax" then
      files.(n) := rec(text := SubstitutionSublist(
                               GAPDoc2HTMLProcs.Head1MathJax, "MATHJAXURL", 
                               GAPDoc2HTMLProcs.MathJaxURL), ssnr := []);
    else
      files.(n) := rec(text := ShallowCopy(GAPDoc2HTMLProcs.Head1), ssnr := []);
    fi;
    tt := Concatenation(r.bookname, ") - ");
    if n=0 then
      Append(tt, GAPDocTexts.d.Contents);
    elif IsInt(n) then
      Append(tt, Concatenation(GAPDocTexts.d.Chapter, " ", String(n), ": ", 
             FilterSGMLMarkup(r.chaptitle.(n))));
    elif n="Bib" then
      Append(tt, GAPDocTexts.d.References);
    elif n="Ind" then
      Append(tt, GAPDocTexts.d.Index);
    else
      Append(tt, Concatenation(GAPDocTexts.d.Appendix, " ", n, ": ", 
             FilterSGMLMarkup(r.chaptitle.(n))));
    fi;
    Append(files.(n).text, tt);
    Append(files.(n).text, GAPDoc2HTMLProcs.Head2);
    # allow for chapter-wise CSS config
    files.(n).text := SubstitutionSublist(files.(n).text, "<body", 
                        Concatenation("<body class=\"chap", String(n), "\" "));
    Append(files.(n).text, Concatenation("\n", chlink));
    Append(files.(n).text, Concatenation(
           "\n<div class=\"chlinkprevnexttop\">",
           toplink, prev[i], next[i], "</div>\n\n"));
    if IsBound(r.root.LinkToMathJax) then
      # cross link to same chapter with MathJax enabled
      Append(files.(n).text,
                Concatenation("<p id=\"mathjaxlink\" ",
                "class=\"pcenter\"><a href=\"chap",
                String(n), "_mj.html\">[MathJax on]</a></p>\n"));
    elif r.root.mathmode = "MathJax" then
      # cross link to non-MathJax version
      Append(files.(n).text,
                Concatenation("<p id=\"mathjaxlink\" ",
                "class=\"pcenter\"><a href=\"chap",
                String(n), ".html\">[MathJax off]</a></p>\n"));
    else
      # we still want the hook for the [Style] link
      Append(files.(n).text, 
                Concatenation("<p id=\"mathjaxlink\" ",
                "class=\"pcenter\"></p>\n"));
    fi;
  od;
  for i in [2,4..Length(l)] do
    n := files.(l[i-1][1]);
    if Length(n.ssnr)=0 or l[i-1]{[1..3]} <> n.ssnr[Length(n.ssnr)] then
      Add(n.ssnr, l[i-1]{[1..3]});
      tt := GAPDoc2HTMLProcs.SectionLabel(r, l[i-1], "Subsection")[2];
      Append(n.text, Concatenation("<p><a id=\"", tt, "\" name=\"", tt, 
                                   "\"></a></p>\n"));
    fi;

    Append(n.text, l[i]);
  od;
  
  for i in [1..Length(chnrs)] do
    n := chnrs[i];
    Append(files.(n).text, Concatenation(
           "\n<div class=\"chlinkprevnextbot\">",
           toplink, prev[i], next[i], "</div>\n\n"));
    Append(files.(n).text,  SubstitutionSublist(chlink, "chlinktop",
                                                      "chlinkbot", false));
    Append(files.(n).text, GAPDoc2HTMLProcs.Tail);
  od;
  # finally tell result the file extensions
  files.ext := GAPDoc2HTMLProcs.ext;
  return files;
end;

##  
##  <#GAPDoc Label="GAPDoc2HTML">
##  <ManSection >
##  <Func Arg="tree[, bibpath[, gaproot]][, mtrans]" Name="GAPDoc2HTML" />
##  <Returns>record  containing  HTML  files  as  strings  and  other
##  information</Returns>
##  <Description>
##  <Index Key="MathJax"><Package>MathJax</Package></Index>
##  The   argument  <A>tree</A>   for   this  function   is  a   tree
##  describing  a   &GAPDoc;  XML   document  as  returned   by  <Ref
##  Func="ParseTreeXMLString"  /> (probably  also  checked with  <Ref
##  Func="CheckAndCleanGapDocTree"  />).   Without  an  <A>mtrans</A>
##  argument this function  produces an HTML version  of the document
##  which can  be read  with any  Web-browser and  also be  used with
##  &GAP;'s online help (see <Ref BookName="Ref" Func="SetHelpViewer"
##  />).  It  includes  title  page,  bibliography,  and  index.  The
##  bibliography is made from &BibTeX; databases. Their location must
##  be given with the argument <A>bibpath</A> (as string or directory
##  object, if not given the current directory is used). If the third
##  argument <A>gaproot</A> is given and is a string then this string
##  is  interpreted as relative  path to &GAP;'s main root directory.
##  Reference-URLs to external HTML-books  which begin with the &GAP;
##  root path  are then  rewritten to start  with the  given relative
##  path.  This  makes  the HTML-documentation  portable  provided  a
##  package is  installed in some  standard location below  the &GAP;
##  root.<P/>
##  
##  The  output is  a  record  with one  component  for each  chapter
##  (with  names   <C>"0"</C>,  <C>"1"</C>,  ...,   <C>"Bib"</C>, and
##  <C>"Ind"</C>).  Each  such  component   is again  a  record  with
##  the following components: 
##  
##  <List >
##  <Mark><C>text</C></Mark>
##  <Item>the text of an HTML file containing the whole chapter (as a
##  string)</Item>
##  <Mark><C>ssnr</C></Mark>
##  <Item>list of subsection numbers in  this chapter (like <C>[3, 2,
##  1]</C>  for  chapter&nbsp;3,  section&nbsp;2,  subsection&nbsp;1)
##  </Item>
##  </List>
##  
##  <Emph>Standard output format without</Emph> <A>mtrans</A> 
##  <Emph>argument</Emph><P/>
##  
##  The   HTML   code   produced   with   this   converter   conforms
##  to   the  W3C   specification   <Q>XHTML   1.0  strict</Q>,   see
##  <URL>http://www.w3.org/TR/xhtml1</URL>.  First, this  means  that
##  the   HTML   files   are   valid   XML   files.   Secondly,   the
##  extension  <Q>strict</Q>   says  in  particular  that   the  code
##  doesn't  contain  any explicit  font  or  color information.<P/>
##  
##  Mathematical  formulae  are  handled  as in  the  text  converter
##  <Ref  Func="GAPDoc2Text"/>.  We don't  want  to  assume that  the
##  browser can  use symbol  fonts. Some &GAP;  users like  to browse
##  the  online  help  with   <C>lynx</C>,  see  <Ref  BookName="Ref"
##  Func="SetHelpViewer"  />, which  runs  inside  the same  terminal
##  windows as &GAP;.<P/>
##  
##  To view the generated files in graphical browsers, stylesheet files
##  with layout configuration should be copied into the directory
##  with the generated HTML files, see <Ref Subsect="StyleSheets"/>.
##  <P/>
##  
##  <Label Name="mtransarg"/>
##  <Emph>Output format with</Emph> <A>mtrans</A> argument <P/>
##  
##  Currently, there  are three variants of  this converter available
##  which handle mathematical formulae differently. They are accessed
##  via the optional last <A>mtrans</A> argument.<P/>
##  
##  If  <A>mtrans</A>   is  set  to  <C>"MathJax"</C>   the  formulae
##  are  essentially  translated  as  for  &LaTeX;  documents  (there
##  is  no  processing  of   <C>&lt;M&gt;</C>  elements  as  decribed
##  in  <Ref   Subsect="M"/>).  Inline  formulae  are   delimited  by
##  <C>\(</C>  and  <C>\)</C>  and displayed  formulae  by  <C>\[</C>
##  and    <C>\]</C>.   With    <Package>MathJax</Package>   webpages
##  can   contain   nicely    formatted   scalable   and   searchable
##  formulae.   The  resulting   files  link   by  default   to  <URL
##  Text="http://cdn.mathjax.org">http://cdn.mathjax.org</URL> to get
##  the  <Package>MathJax</Package>  script  and  fonts.  This  means
##  that  they   can  only  be   used  on  computers   with  internet
##  access.   An  alternative   URL   can  be   set  by   overwriting
##  <C>GAPDoc2HTMLProcs.MathJaxURL</C>   before   building  the  HTML
##  version   of   a   manual.   This  way   a   local   installation
##  of   <Package>MathJax</Package>   could   be   used.   See   <URL
##  Text="http://www.mathjax.org/">http://www.mathjax.org/</URL>  for
##  more details.<P/>
##  
##  The following  possibilities for <A>mtrans</A> are  still supported,
##  but since the <Package>MathJax</Package> approach seems much better,
##  their use is deprecated.<P/>
##  
##  If  the  argument <A>mtrans</A>  is  set  to <C>"Tth"</C>  it  is
##  assumed that you  have installed the &LaTeX;  to HTML translation
##  program <C>tth</C>. This is used to translate the contents of the
##  <C>M</C>,  <C>Math</C>  and  <C>Display</C>  elements  into  HTML
##  code.  Note that  the resulting  code is  not compliant  with any
##  standard.  Formally  it  is  <Q>XHTML  1.0  Transitional</Q>,  it
##  contains  explicit  font  specifications and  the  characters  of
##  mathematical  symbols  are  included  via  their  position  in  a
##  <Q>Symbol</Q>  font. Some  graphical browsers  can be  configured
##  to  display  this  in  a  useful  manner,  check  <URL  Text="the
##  Tth homepage">http://hutchinson.belmont.ma.us/tth/</URL> for more
##  details.<P/>
##  
##  This  function works  by  running recursively  through the  document
##  tree   and   calling   a   handler  function   for   each   &GAPDoc;
##  XML   element.  Many   of  these   handler  functions   (usually  in
##  <C>GAPDoc2TextProcs.&lt;ElementName&gt;</C>)  are  not  difficult to
##  understand (the  greatest complications are some  commands for index
##  entries, labels  or the  output of page  number information).  So it
##  should be easy to adjust certain details to your own taste by slight
##  modifications of the program. <P/>
##  
##  The result  of this converter  can be  written to files  with the
##  command <Ref Func="GAPDoc2HTMLPrintHTMLFiles" />.<P/>
##  
##  There are two user preferences for reading the HTML manuals produced by
##  &GAPDoc;. A user can choose among several style files which determine the
##  appearance of the manual pages with 
##  <C>SetUserPreference("GAPDoc", "HTMLStyle", [...]);</C> where the list in 
##  the third argument are arguments for <Ref Func="SetGAPDocHTMLStyle"/>.
##  The second preference is set by 
##  <C>SetUserPreference("GAPDoc", "UseMathJax", ...);</C> where the third
##  argument is <K>true</K> or <K>false</K> (default). If this is set to
##  <K>true</K>, the &GAP; help system displays the <Package>MathJax</Package>
##  version of the HTML manuals.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
##  <#GAPDoc Label="HTMLStyleSheets">
##  <Subsection Label="StyleSheets">
##  <Heading>Stylesheet files</Heading>
##  <Index>CSS stylesheets</Index>
##  
##  For graphical  browsers the layout  of the generated HTML manuals  can be
##  highly  configured  by  cascading stylesheet  (CSS)  and  javascript
##  files. Such files are provided in the <F>styles</F> directory of the
##  &GAPDoc; package.<P/>
##  
##  We recommend that these files  are copied into each manual directory
##  (such  that each  of  them  is selfcontained).  There  is a  utility
##  function  <Ref  Func="CopyHTMLStyleFiles"  /> which  does  this.  Of
##  course, these files  may be changed or new styles  may be added. New
##  styles  may  also be  sent  to  the  &GAPDoc; authors  for  possible
##  inclusion in future versions.<P/>
##  
##  The  generated   HTML  files refer to  the   file  <F>manual.css</F>
##  which   conforms   to   the   W3C   specification   CSS   2.0,   see
##  <URL>http://www.w3.org/TR/REC-CSS2</URL>,  and  the javascript  file
##  <F>manual.js</F> (only in browsers  which support CSS or javascript,
##  respectively;  but   the  HTML  files  are   also  readable  without
##  any  of  them).  To  add  a style  <C>mystyle</C>  one  or  both  of
##  <F>mystyle.css</F> and <F>mystyle.js</F> must be provided; these can
##  overwrite  default settings  and add  new javascript  functions. For
##  more details see the comments in <F>manual.js</F>.<P/>
##  </Subsection>
##  <ManSection >
##  <Func Arg="dir" Name="CopyHTMLStyleFiles" />
##  <Returns>nothing</Returns>
##  <Description>
##  This utility function copies  the <F>*.css</F> and <F>*.js</F> files
##  from the  <F>styles</F> directory of  the &GAPDoc; package  into the
##  directory
##  <A>dir</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
##  the basic call, used recursively with a result r from GetElement 
##  and a string str or list l to which the output should be appended
# arg: r[, bibpath]    (then a list is returned, only for whole document)
# or:  r, str          (then the output is appended to string or list str)
InstallGlobalFunction(GAPDoc2HTML, function(arg)
  local   r,  str,  linelength,  name;
  r := arg[1];
  # first check for the mode
  if arg[Length(arg)] in ["MathML", "Tth", "MathJax"] then
    r.mathmode := arg[Length(arg)];
    arg := arg{[1..Length(arg)-1]};
  else
    r.mathmode := "Text";
  fi;
  
  if Length(arg) > 1 then
    str := arg[2];
  else 
    str := [];
  fi;
  if r.name = "WHOLEDOCUMENT" then
    # choose different file name conventions such that these
    # conversions can coexist
    if r.mathmode = "MathML" then
      GAPDoc2HTMLProcs.ext := "_mml.xml";
    elif r.mathmode = "Tth" then
      GAPDoc2HTMLProcs.ext := "_sym.html";
    elif r.mathmode = "MathJax" then
      GAPDoc2HTMLProcs.ext := "_mj.html";
    else
      GAPDoc2HTMLProcs.ext := ".html";
    fi;
    if IsDirectory(str) then
      r.bibpath := str;
    else
      if Length(str) = 0 then
        str := ".";
      fi;
      r.bibpath := Directory(str);
    fi;
    str := [];
    if Length(arg) > 2 and IsString(arg[3]) then
      GAPDoc2HTMLProcs.RelPath := arg[3];
      GAPInfo.MainRootPath := Filtered(GAPInfo.RootPaths, a->
                            Filename([Directory(a)], "lib/init.g")<>fail)[1];
    else
      Unbind(GAPDoc2HTMLProcs.RelPath);
    fi;
  fi;

  name := r.name;
  if not IsBound(GAPDoc2HTMLProcs.(name)) then
    Info(InfoGAPDoc, 1, "#W WARNING: Don't know how to process element ", name, 
          " ---- ignored\n");
  else
    GAPDoc2HTMLProcs.(r.name)(r, str);
  fi;
  
  if r.name ="WHOLEDOCUMENT" then
    # put final record together and return it
    return GAPDoc2HTMLProcs.PutFilesTogether(str, r);
  fi;

  return str;
end);

##  recursion through the tree and collecting paragraphs
BindGlobal("GAPDoc2HTMLContent", function(r, l)
  local par, cont, i, count, s, a;
  
  # utility: append counter and formatted paragraph to l
  par := function(s)
    if Length(s)>0 then
      s := NormalizedWhitespace(s);
      if Length(s)>0 then
        Add(l, count);
        Add(l, Concatenation("<p>", s, "</p>\n\n"));
      fi;
    fi;
  end;
  
  # if not containing paragraphs, then l is string to append to
  if not r.name in GAPDoc2HTMLProcs.ParEls then
    for a in r.content do
      GAPDoc2HTML(a, l);
    od;
    return;
  fi;
  
  # otherwise we have to collect text and paragraphs
  cont := r.content;
  # checking for alternatives
  i := 1;
  while i < Length(cont) do
    if cont[i].name = "Alt" and GAPDoc2HTMLProcs.AltYes(cont[i]) then
      cont := Concatenation(cont{[1..i-1]}, cont[i].content,
              cont{[i+1..Length(cont)]});
    else
      i := i + 1;
    fi;
  od;
  count := r.count;
  s := "";
  for a in cont do
    if a.count <> count  then
      par(s);
      count := a.count;
      s := "";
    fi;
    if a.name in GAPDoc2HTMLProcs.ParEls then
      # recursively collect paragraphs
      GAPDoc2HTML(a, l);
    else 
      # collect text for current paragraph
      GAPDoc2HTML(a, s);
    fi;
  od;
  if Length(s)>0 then
    par(s);
  fi;
end);

  
##  write head and foot of HTML file.
GAPDoc2HTMLProcs.WHOLEDOCUMENT := function(r, par)
  local i, pi, t, el, remdiv, math, pos, pos1, str, dat, datbt, bib, b, 
        keys, need, labels, tmp, j, diff, text, a, k, l, ind, opts;
  
  ##  add paragraph numbers to all nodes of the document
  AddParagraphNumbersGapDocTree(r);
  
  if not IsBound(r.six) then
    Info(InfoGAPDoc, 1, "#W WARNING: Using labels from section numbers, \n",
      "#W consider running the converter for the text version first!\n");
  fi;
  
  ##  add a link .root to the root of the document to all nodes
  ##  (then we can collect information about indexing and so on 
  ##  there)
  AddRootParseTree(r);
  r.index := [];
  r.toc := "";
  r.labels := rec();
  r.labeltexts := rec();
  if not IsBound(r.bibkeys) then
    r.bibkeys := [];
  fi;
  r.chaptitle := rec();
  r.chapsectlinks := rec();
  
  ##  checking for processing instructions before the book starts
  ##  example:  <?HTML option1="value1" ?>
  i := 1;
  pi := rec();
  while not r.content[i].name = "Book" do
    if r.content[i].name = "XMLPI" then
      t := r.content[i].content;
      if Length(t) > 4 and t{[1..5]} = "HTML " then
        el := GetSTag(Concatenation("<", t, ">"), 2);
        for a in NamesOfComponents(el.attributes) do
          pi.(a) := el.attributes.(a);
        od;
      fi;
    fi;
    i := i+1;
  od;
  
  # setup for external conversion of maths (MathML with ttm, tth, ...)
  if r.mathmode in ["MathML", "Tth"] then
    r.ConvInput := "";
    r.MathCount := 0;
  fi;
  
  ##  Now the actual work starts, we give the processing instructions found
  ##  so far to the Book handler.
  ##  We call the Book handler twice and produce index, bibliography, toc
  ##  in between.
  Info(InfoGAPDoc, 1, "#I First run, collecting cross references, ",
        "index, toc, bib and so on . . .\n");
  # with this flag we avoid unresolved references warnings in first run
  GAPDoc2HTMLProcs.FirstRun := true;
  GAPDoc2HTMLProcs.Book(r.content[i], [], pi);
  GAPDoc2HTMLProcs.FirstRun := false;
  
  # now the toc is ready
  Info(InfoGAPDoc, 1, "#I Table of contents complete.\n");
  r.toctext := r.toc;
  r.chapsectlinkstext := r.chapsectlinks;
  
  # utility to remove <div> tags
  remdiv := function(s)
    local pos, pos1;
    pos := PositionSublist(s, "<div");
    while pos <> fail do
      pos1 := Position(s, '>', pos);
      s := Concatenation(s{[1..pos-1]}, s{[pos1+1..Length(s)]});
      pos := PositionSublist(s, "<div");
    od;
    pos := PositionSublist(s, "</div");
    while pos <> fail do
      pos1 := Position(s, '>', pos);
      s := Concatenation(s{[1..pos-1]}, s{[pos1+1..Length(s)]});
      pos := PositionSublist(s, "</div");
    od;
    return s;
  end;

  # MathML or Tth translation
  if r.mathmode in ["MathML", "Tth"] then
    Info(InfoGAPDoc, 1, "#I   translating formulae with \c");
    FileString("tempCONV.tex", r.ConvInput);
    if r.mathmode = "MathML" then
      Info(InfoGAPDoc, 1, "ttm.\n");
      Exec("rm -f tempCONV.html; ttm -L -r tempCONV.tex > tempCONV.html");
    elif r.mathmode = "Tth" then
      Info(InfoGAPDoc, 1, "tth.\n");
      Exec("rm -f tempCONV.html; tth -w2 -r -u tempCONV.tex > tempCONV.html");
    fi; 
    math := StringFile("tempCONV.html");
    # correct the <var> tags
    math := SubstitutionSublist(math, "&lt; var &gt;", "<var>");
    math := SubstitutionSublist(math, "&lt; /var &gt;", "</var>");
    math := SubstitutionSublist(math, 
                  "<mo>&lt;</mo><mi>var</mi><mo>&gt;</mo>", "<var>");
    math := SubstitutionSublist(math, 
                  "<mo>&lt;</mo><mo>/</mo><mi>var</mi><mo>&gt;</mo>", "</var>");
    r.MathList := [];
    pos := PositionSublist(math, "TeXFormulaeDelim");
    while pos <> fail do
      pos1 := PositionSublist(math, "TeXFormulaeDelim", pos);
      if pos1 <> fail then
        Add(r.MathList, remdiv(math{[pos+16..pos1-1]}));
      else
        Add(r.MathList, remdiv(math{[pos+16..Length(math)]}));
      fi;
      pos := pos1;
    od;
  fi;
  
  # .index has entries of form [sorttext, subsorttext, numbertext, 
  # entrytext, url[, subtext]]
  Info(InfoGAPDoc, 1, "#I Producing the index . . .\n");
  SortBy(r.index, a-> [a[1],STRING_LOWER(a[2]),
                       List(SplitString(a[3],".-",""), Int)]);
  str := "";
  ind := r.index;
  k := 1;
  while k <= Length(ind) do
    if k > 1 and ind[k][4] = ind[k-1][4] then
      Append(str, "&nbsp;&nbsp;&nbsp;&nbsp;");
    else
      Append(str, ind[k][4]);
    fi;
    if IsBound(ind[k][6]) then
      if k = 1 or ind[k][4] <> ind[k-1][4] then
        Append(str, ", ");
      fi;
      Append(str, ind[k][6]);
    elif Length(ind[k][2]) > 0 then
      if k = 1 or ind[k][4] <> ind[k-1][4] then
        Append(str, ", ");
      fi;
      Append(str, ind[k][2]);
    fi;
    l := k;
    while l <= Length(ind) and ind[l][4] = ind[k][4] and
          ((IsBound(ind[k][6]) and IsBound(ind[l][6])
            and ind[k][6] = ind[l][6]) or
           (not IsBound(ind[k][6]) and not IsBound(ind[l][6])
           and ind[k][2] = ind[l][2]))  do
      Append(str, Concatenation("  <a href=\"", ind[l][5], "\">",
                              ind[l][3], "</a>  "));
      l := l+1;
    od;
    Append(str, "<br />\n");
    k := l;
  od;
  r.indextext := str;
  
  if Length(r.bibkeys) > 0 then
    GAPDocAddBibData(r);
    Info(InfoGAPDoc, 1, "#I Writing bibliography . . .\n");
    if r.root.mathmode = "MathJax" then
      opts := rec(MathJax := true);
    else
      opts := rec();
    fi;
    need := List(r.bibentries, a-> RecBibXMLEntry(a, "HTML", r.bibstrings,
            opts));
    # copy the unique labels
    for a in [1..Length(need)] do
      need[a].key := r.biblabels[a];
    od;
    text := "";
    for a in need do
      # an anchor for links from the citations
      Append(text, Concatenation("\n<p><a id=\"biB", a.Label, 
                        "\" name=\"biB", a.Label, "\"></a></p>\n")); 
      Append(text, StringBibAsHTML(a, false)); 
    od;
    r.bibtext := text;
  fi;
  
  # second run
  r.index := [];
  Info(InfoGAPDoc, 1, "#I Second run through document . . .\n");
  GAPDoc2HTMLProcs.Book(r.content[i], par, pi);
  
  for a in ["MathList", "MathCount", "index", "toc"] do
    Unbind(r.(a));
  od;
  ##  remove the links to the root  ???
##    RemoveRootParseTree(r);
end;

##  comments and processing instructions are in general ignored
GAPDoc2HTMLProcs.XMLPI := function(r, str)
  return;
end;
GAPDoc2HTMLProcs.XMLCOMMENT := function(r, str)
  return;
end;

# two utilities for attribute values like labels or text with special
# XML (or LaTeX) characters which gets printed
GAPDoc2HTMLProcs.EscapeAttrVal := function(str)
  str := SubstitutionSublist(str, "&", "&amp;");
  str := SubstitutionSublist(str, "<", "&lt;");
  str := SubstitutionSublist(str, ">", "&gt;");
  return str;
end;

# do nothing with Ignore
GAPDoc2HTMLProcs.Ignore := function(arg)
end;

# just process content 
GAPDoc2HTMLProcs.Book := function(r, par, pi)
  # copy the name of the book to the root
  r.root.bookname := r.attributes.Name;
  GAPDoc2HTMLContent(r, par);
end;

##  Body is sectioning element
GAPDoc2HTMLProcs.Body := GAPDoc2HTMLContent;

##  the title page,  the most complicated looking function
GAPDoc2HTMLProcs.TitlePage := function(r, par)
  local   strn,  l,  s,  a,  aa,  cont,  ss;
    
  strn := "<div class=\"pcenter\">\n";
  # title
  l := Filtered(r.content, a-> a.name = "Title");
  s := "";
  GAPDoc2HTMLContent(l[1], s);
  s := Concatenation("\n<h1>", NormalizedWhitespace(s), "</h1>\n\n"); 
  Append(strn, s);
  
  # subtitle
  l := Filtered(r.content, a-> a.name = "Subtitle");
  if Length(l)>0 then
    s := "";
    GAPDoc2HTMLContent(l[1], s);
    s := Concatenation("\n<h2>", NormalizedWhitespace(s), "</h2>\n\n"); 
    Append(strn, s);
  fi;
  
  # version
  l := Filtered(r.content, a-> a.name = "Version");
  if Length(l)>0 then
    s := "<p>";
    GAPDoc2HTMLContent(l[1], s);
    while Length(s)>0 and s[Length(s)] in  WHITESPACE do
      Unbind(s[Length(s)]);
    od;
    Append(s, "</p>\n\n");
    Append(strn, s);
  fi;

  # date
  l := Filtered(r.content, a-> a.name = "Date");
  if Length(l)>0 then
    s := "<p>";
    GAPDoc2HTMLContent(l[1], s);
    Append(strn, s);
    Append(strn, "</p>\n\n");
  fi;
  Append(strn, "</div>\n");

  # an extra comment
  l := Filtered(r.content, a-> a.name = "TitleComment");
  if Length(l) > 0 then
    s := "<p>";
    GAPDoc2HTMLContent(l[1], s);
    Append(s, "</p>\n");
    Append(strn, s);
  fi;

  # author name(s)
  l := Filtered(r.content, a-> a.name = "Author");
  for a in l do
    s := "<p><b>";
    aa := ShallowCopy(a);
    aa.content := Filtered(a.content, 
                  b-> not b.name in ["Email", "Homepage", "Address"]);
    GAPDoc2HTMLContent(aa, s);
    Append(strn, s);
    Append(strn, "</b>\n");
    cont := List(a.content, b-> b.name);
    if "Email" in cont then
      s := "";
      GAPDoc2HTML(a.content[Position(cont, "Email")], s);
      s := NormalizedWhitespace(s);
      Append(strn, Concatenation("<br />", GAPDocTexts.d.Email, ": ", s, "\n"));
    fi;
    if "Homepage" in cont then
      s := "";
      GAPDoc2HTML(a.content[Position(cont, "Homepage")], s);
      s := NormalizedWhitespace(s);
      Append(strn, Concatenation("<br />", GAPDocTexts.d.Homepage, 
                                 ": ", s, "\n"));
    fi;
    if "Address" in cont then
      s := "";
      GAPDoc2HTMLContent(a.content[Position(cont, "Address")], s);
      s := NormalizedWhitespace(s);
      Append(strn, Concatenation("<br />", GAPDocTexts.d.Address, 
                                 ": <br />", s, "\n"));
    fi;
    Append(strn, "</p>");
  od;
  Append(strn, "\n\n");
  
  Add(par, r.count);
  Add(par, strn);
  
  # an Address element in title page
  l := Filtered(r.content, a-> a.name = "Address");
  if Length(l) > 0 then
    s := "";
    GAPDoc2HTMLContent(l[1], s);
    s := NormalizedWhitespace(s);
    Append(strn, Concatenation("<p><b>", GAPDocTexts.d.Address, 
                               ":</b><br />\n", s, "</p>\n"));
  fi;
  
  # abstract, copyright page, acknowledgements, colophon
  for ss in ["Abstract", "Copyright", "Acknowledgements", "Colophon" ] do
    l := Filtered(r.content, a-> a.name = ss);
    if Length(l)>0 then
      Add(par, l[1].count);
      Add(par, Concatenation("<h3>", GAPDocTexts.d.(ss), "</h3>\n"));
      GAPDoc2HTMLContent(l[1], par);
    fi;
  od;
end;

##  these produce text for an URL
##  arg:  r, str[, pre]
GAPDoc2HTMLProcs.Link := GAPDoc2HTMLContent;
GAPDoc2HTMLProcs.LinkText := GAPDoc2HTMLContent;
GAPDoc2HTMLProcs.URL := function(arg)
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
    GAPDoc2HTML(rr, txt);
    rr := First(r.content, a-> a.name = "Link");
    if rr = fail then
      Info(InfoGAPDoc, 1, "#W missing <Link> element for text ", txt, "\n");
      s := "MISSINGLINK";
    else
      s := "";
      GAPDoc2HTMLContent(rr, s);
    fi;
  else
    s := "";
    GAPDoc2HTMLContent(r, s);
    if IsBound(r.attributes.Text) then
      txt := r.attributes.Text;
    else
      txt := s;
    fi;
  fi;
  Append(str, Concatenation(GAPDoc2HTMLProcs.TextAttr.URL[1], 
                    "<a href=\"", pre, s, "\">", txt, "</a>"));
  Append(str, GAPDoc2HTMLProcs.TextAttr.URL[2]);
end;

GAPDoc2HTMLProcs.Homepage := GAPDoc2HTMLProcs.URL;

GAPDoc2HTMLProcs.Email := function(r, str)
  # we add the `mailto:' phrase
  GAPDoc2HTMLProcs.URL(r, str, "mailto:");
end;

##  utility: generate a chapter or (sub)section-number string 
GAPDoc2HTMLProcs.SectionNumber := function(count, sect)
  local   res;
  res := "";
  if IsString(count[1]) or count[1]>0 then
    Append(res, String(count[1]));
  fi;
  if sect="Chapter" or sect="Appendix" then
    return res;
  fi;
  Add(res, '.');
  if count[2]>0 then
    Append(res, String(count[2]));
  fi;
  if sect="Section" then
    return res;
  fi;
  if count[3]>0 then
    Append(res, Concatenation("-", String(count[3])));
  fi;
  return res;
end;

##  utility: generate a chapter or (sub)section-number string 
GAPDoc2HTMLProcs.SectionLabel := function(r, count, sect)
  local   res, a;
  if IsString(count[1]) or count[1]>0 then
    res := Concatenation("chap", String(count[1]), GAPDoc2HTMLProcs.ext);
  else
    res := Concatenation("chap0", GAPDoc2HTMLProcs.ext);
  fi;
  res := [res, ""];
  if not IsBound(r.root.six) then
    if sect="Chapter" then
      return res;
    fi;
    Append(res[2], Concatenation("s", String(count[2])));
    Append(res[2], Concatenation("ss", String(count[3])));
    return res;
  else
##      a := First(r.root.six, a-> a[3] = count{[1..3]});
    a := PositionSet(r.root.sixcount, count{[1..3]});
    if a <> fail then
      a := r.root.six[r.root.sixindex[a]];
    fi;
    if a = fail or not IsBound(a[7]) then
      return GAPDoc2HTMLProcs.SectionLabel(rec(root:=rec()), count, sect);
    else
      Append(res[2], a[7]);
      return res;
    fi;
  fi;
end;

##  the sectioning commands are just translated and labels are
##  generated, if given as attribute  
GAPDoc2HTMLProcs.ChapSect := function(r, par, sect)
  local   num, posh, s, ind, strn, lab, types, nrs, hord, a, pos, l, i;
  
  types := ["Chapter", "Appendix", "Section", "Subsection"];
  nrs := ["3", "3", "4", "5"];
  hord := nrs[Position(types, sect)];
    
  Add(par, r.count);
  # if available, start with links to sections in chapter/appendix
  if sect in ["Chapter", "Appendix"] then
    if IsBound(r.root.chapsectlinkstext) and 
       IsBound(r.root.chapsectlinkstext.(r.count[1])) then
      Add(par, r.root.chapsectlinkstext.(r.count[1]));
    fi;
  fi;
  if par[Length(par)] = r.count then
    Add(par, "");
  fi;

  # section number as string
  num := GAPDoc2HTMLProcs.SectionNumber(r.count, sect);
  # and as anchor
  lab := GAPDoc2HTMLProcs.SectionLabel(r, r.count, "Subsection");
  lab := Concatenation(lab[1], "#", lab[2]);
  
  # the heading
  posh := Position(List(r.content, a-> a.name), "Heading");
  if posh <> fail then      
    s := "";
    # first the .six entry
    GAPDoc2HTMLProcs.Heading1(r.content[posh], s);
    if hord = "3" then
      r.root.chaptitle.(r.count[1]) := s;
    fi;
    
    # label entry, if present
    if IsBound(r.attributes.Label) then
      r.root.labels.(r.attributes.Label) := [num, lab];
      r.root.labeltexts.(r.attributes.Label) := s;
    fi;
  
    # the heading text
    Append(par[Length(par)], 
       Concatenation("\n<h", hord, ">", num, " ", s, "</h", hord, ">\n\n"));
    
    # table of contents entry
    s := Concatenation( num, " ", s);
    if sect in ["Chapter", "Appendix"] then
      if r.count[1] >= 1 then
        ind := "<div class=\"ContChap\">";
      fi;
    elif sect="Section" then 
      ind := "";
      if r.count[2] >= 1 then
        Append(ind, "<div class=\"ContSect\">");
      fi;
      Append(ind, "<span class=\"tocline\"><span class=\"nocss\">&nbsp;</span>");
    elif sect="Subsection" then
      ind := "<span class=\"ContSS\"><br /><span class=\"nocss\">&nbsp;&nbsp;</span>";
    else
      ind := "";
    fi;
    Append(r.root.toc, Concatenation(ind, "<a href=\"", 
                                        lab, "\">", s, "</a>\n"));
    if sect="Section" then
      Append(r.root.toc, "</span>\n<div class=\"ContSSBlock\">\n");
    fi;
  fi;
  
  # the actual content
  GAPDoc2HTMLContent(r, par);

  # possibly close <div> or <span> in content
  if posh <> fail then      
    if sect in ["Chapter", "Appendix" ] then
      Append(r.root.toc, "</div>\n");
    elif sect="Section" then
      # remove last line if no subsections
      l := Length(r.root.toc);
      if r.root.toc{[l-25..l]} = "<div class=\"ContSSBlock\">\n" then
        for i in [0..25] do Unbind(r.root.toc[l-i]); od;
        Append(r.root.toc, "</div>\n");
      else
        Append(r.root.toc, "</div></div>\n");
      fi;
    elif sect="Subsection" then
      Append(r.root.toc, "</span>\n");
    fi;
  fi;
  # if in chapter, also use the section links in top of page
  if sect in ["Chapter", "Appendix"] then
    a := Reversed(r.root.toc);
    pos := PositionSublist(a, Reversed("<div class=\"ContChap\">"));
    a := Reversed(a{[1..pos-1]});
    r.root.chapsectlinks.(r.count[1]) := Concatenation(
                                         "<div class=\"ChapSects\">", a);
  fi;
end;


##  this really produces the content of the heading
GAPDoc2HTMLProcs.Heading1 := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "Heading");
end;
##  and this ignores the heading (for simpler recursion)
GAPDoc2HTMLProcs.Heading := function(r, str)
end;

GAPDoc2HTMLProcs.Chapter := function(r, par)
  GAPDoc2HTMLProcs.ChapSect(r, par, "Chapter");
end;

GAPDoc2HTMLProcs.Appendix := function(r, par)
  GAPDoc2HTMLProcs.ChapSect(r, par, "Appendix");
end;

GAPDoc2HTMLProcs.Section := function(r, par)
  GAPDoc2HTMLProcs.ChapSect(r, par, "Section");
end;

GAPDoc2HTMLProcs.Subsection := function(r, par)
  GAPDoc2HTMLProcs.ChapSect(r, par, "Subsection");
end;

##  table of contents, just puts "TOC" in first run
GAPDoc2HTMLProcs.TableOfContents := function(r, par)
  Add(par, r.count);
  if IsBound(r.root.toctext) then
    Add(par, Concatenation("\n<div class=\"contents\">\n<h3>",
          GAPDocTexts.d.Contents, 
          "<a id=\"contents\" name=\"contents\"></a></h3>\n\n",
          r.root.toctext, "<br />\n</div>\n"));
  else
    Add(par,"<p>TOC\n-----------</p>\n\n");
  fi;
end;

##  bibliography, just "BIB" in first run, store databases in root
GAPDoc2HTMLProcs.Bibliography := function(r, par)
  local   s;
  # add references to TOC
  Append(r.root.toc, Concatenation("<div class=\"ContChap\"><a href=\"chapBib",
                        GAPDoc2HTMLProcs.ext, "\"><span class=\"Heading\">", 
                        GAPDocTexts.d.References, "</span></a></div>\n")); 
  r.root.bibdata := r.attributes.Databases;
  if IsBound(r.attributes.Style) then
    r.root.bibstyle := r.attributes.Style;
  fi;
  Add(par, r.count);
  if IsBound(r.root.bibtext) then
    Add(par, Concatenation("\n<h3>", GAPDocTexts.d.References, "</h3>\n\n", 
            r.root.bibtext, "<p> </p>\n\n"));
  else
    Add(par,"<p>BIB\n-----------</p>\n");
  fi;
end;

GAPDoc2HTMLProcs.PCDATAFILTER := function(r, str)
  local s, a;
  s := r.content;
  if not IsBound(r.HTML) and (Position(s, '<') <> fail or 
       Position(s, '&') <> fail or Position(s, '>') <> fail) then
    for a in s do 
      if a='<' then
        Append(str, "&lt;");
      elif a='&' then
        Append(str, "&amp;");
      elif a='>' then
        Append(str, "&gt;");
      else
        Add(str, a);
      fi;
    od;
  else
    Append(str, s);
  fi;
end;
# and without filter (e.g., for collecting formulae  
GAPDoc2HTMLProcs.PCDATANOFILTER := function(r, str)
  Append(str, r.content);
end;

GAPDoc2HTMLProcs.PCDATAFILTER;
## default is with filter
GAPDoc2HTMLProcs.PCDATA := GAPDoc2HTMLProcs.PCDATAFILTER;

##  end of paragraph (end with double newline)
GAPDoc2HTMLProcs.P := function(r, str)
# nothing to do, the "<p>" are added in main loop (GAPDoc2HTML)
end;

GAPDoc2HTMLProcs.Br := function(r, str)
  Append(str, "<br />\n");
end;

##  wrapping text attributes
GAPDoc2HTMLProcs.WrapAttr := function(r, str, a)
  local   s,  tt;
  s := "";
  GAPDoc2HTMLContent(r, s);
  tt := GAPDoc2HTMLProcs.TextAttr.(a);
  Append(str, Concatenation(tt[1], s, tt[2]));
end;

##  GAP keywords 
GAPDoc2HTMLProcs.K := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "K");
end;

##  buttons 
GAPDoc2HTMLProcs.B := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "B");
end;

##  verbatim GAP code
GAPDoc2HTMLProcs.C := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "C");
end;

##  file names
GAPDoc2HTMLProcs.F := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "F");
end;

##  argument names (same as Arg)
GAPDoc2HTMLProcs.A := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "Arg");
end;

GAPDoc2HTMLProcs.MathConvHelper := function(r, str, db, de)
  local s, x;
  if IsBound(r.root.MathList) then
    # conversion already available
    r.root.MathCount := r.root.MathCount + 1;
    Append(str, r.root.MathList[r.root.MathCount]);
  else 
    # add to input for converter
    if IsString(r.content) then
      s := r.content;
    else
      s := "";
      GAPDoc2HTMLProcs.PCDATA := GAPDoc2HTMLProcs.PCDATANOFILTER;
      for x in r.content do 
        GAPDoc2HTML(x, s);
      od;
      GAPDoc2HTMLProcs.PCDATA := GAPDoc2HTMLProcs.PCDATAFILTER;
    fi;
    s := Concatenation("TeXFormulaeDelim", db, s, de);
    Append(r.root.ConvInput, s);
    Append(str, "FORMULA");
  fi;
end;
  

##  simple maths, here we try to substitute TeX command to something which
##  looks ok in text mode
GAPDoc2HTMLProcs.M := function(r, str)
  local s, ss, save;
  if r.root.mathmode in ["MathML", "Tth"] then
    GAPDoc2HTMLProcs.MathConvHelper(r, str, "$", "$");
    return;
  fi;
  s := "";
  GAPDoc2HTMLProcs.PCDATA := GAPDoc2HTMLProcs.PCDATANOFILTER;
  # a hack, since we want to allow <A> in formulae
  save := GAPDoc2HTMLProcs.TextAttr.Arg;
  GAPDoc2HTMLProcs.TextAttr.Arg := ["TEXTaTTRvARBEGIN", "TEXTaTTRvAREND"];
  GAPDoc2HTMLContent(r, s);
  GAPDoc2HTMLProcs.TextAttr.Arg := save;
  GAPDoc2HTMLProcs.PCDATA := GAPDoc2HTMLProcs.PCDATAFILTER;
  ss := "";
  if r.root.mathmode = "MathJax" then
    s := Concatenation("\\(",s,"\\)");
    GAPDoc2HTMLProcs.PCDATAFILTER(rec(content := s), ss);
    ss := SubstitutionSublist(ss, "TEXTaTTRvARBEGIN", "\\textit{");
    ss := SubstitutionSublist(ss, "TEXTaTTRvAREND", "}");
  else
    s := TextM(s);
    GAPDoc2HTMLProcs.PCDATAFILTER(rec(content := s), ss);
    ss := SubstitutionSublist(ss, "TEXTaTTRvARBEGIN", save[1]);
    ss := SubstitutionSublist(ss, "TEXTaTTRvAREND", save[2]);
  fi;
  Append(str, WrapTextAttribute(ss, GAPDoc2HTMLProcs.TextAttr.M));
end;

##  in HTML this is shown in TeX format
GAPDoc2HTMLProcs.Math := function(r, str)
  local s;
  if r.root.mathmode in ["MathML", "Tth"] then
    GAPDoc2HTMLProcs.MathConvHelper(r, str, "$", "$");
    return;
  fi;
  if r.root.mathmode = "MathJax" then
    s := "";
    GAPDoc2HTMLProcs.M(r, s);
    Append(str, s);
    return;
  fi;
  s := "";
  GAPDoc2HTMLContent(r, s);
  Append(str, WrapTextAttribute(s, GAPDoc2HTMLProcs.TextAttr.Math));
end;

##  displayed maths (also in TeX format, but centered paragraph in itself)
GAPDoc2HTMLProcs.Display := function(r, par)
  local   s, a, str;
  if r.root.mathmode in ["MathML", "Tth"] then
    str := "";
    GAPDoc2HTMLProcs.MathConvHelper(r, str, "\n\\[", "\\]\n\n");
    Add(par, r.count);
    Add(par, Concatenation("<table class=\"display\"><tr>",
             "<td class=\"display\">",
             str, "</td></tr></table>\n"));
    return;
  fi;
  s := "";
  for a in r.content do
    GAPDoc2HTML(a, s);
  od;
  if r.root.mathmode = "MathJax" then
    Add(par, r.count);
    Add(par, Concatenation("<p class=\"center\">\\[", 
                            s, "\\]</p>\n\n"));
    return;
  fi;
  if IsBound(r.attributes.Mode) and r.attributes.Mode = "M" then
    s := TextM(s);
  fi;
  s := Concatenation("<p class=\"pcenter\">", s, "</p>\n\n");
  Add(par, r.count);
  Add(par, s);
end;

##  emphazised text
GAPDoc2HTMLProcs.Emph := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "Emph");
end;

##  quoted text
GAPDoc2HTMLProcs.Q := function(r, str)
  Append(str, "\"");
  GAPDoc2HTMLContent(r, str);
  Append(str, "\"");
end;

##  Package names
GAPDoc2HTMLProcs.Package := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "Package");
end;

##  menu items
GAPDoc2HTMLProcs.I := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "I");
end;

GAPDoc2HTMLProcs.AddColorPromptMarkup := function(cont)
  local patt, batt, iatt, res, pos, s, rows;
  patt := GAPDoc2HTMLProcs.TextAttr.GAPprompt;
  batt := GAPDoc2HTMLProcs.TextAttr.GAPbrkprompt;
  iatt := GAPDoc2HTMLProcs.TextAttr.GAPinput;
  res := "";
  rows := SplitString(cont, "\n", "");
  for s in rows do
    if Length(s) > 7 and s{[1..8]} = "gap&gt; " then
      Append(res, Concatenation(WrapTextAttribute("gap&gt;", patt),
                       " ", WrapTextAttribute(s{[9..Length(s)]}, iatt)));
    elif Length(s) > 4 and s{[1..5]} = "&gt; " then
      Append(res, Concatenation(WrapTextAttribute("&gt;", patt),
                       " ", WrapTextAttribute(s{[6..Length(s)]}, iatt)));
    elif Length(s) > 2 and s{[1..3]} = "brk" then
      pos := Position(s, ' ');
      if pos <> fail then
        Append(res, Concatenation(WrapTextAttribute(s{[1..pos-1]}, batt),
                        " ", WrapTextAttribute(s{[pos+1..Length(s)]}, iatt)));
      else
        Append(res, WrapTextAttribute(s, batt));
      fi;
    else
      Append(res, WrapTextAttribute(s, ["",""]));
    fi;
    Add(res, '\n');
  od;
  if Length(cont) > 0 and cont[Length(cont)] <> '\n' then
    Unbind(res[Length(res)]);
  fi;
  return res;
end;

GAPDoc2HTMLProcs.ExampleLike := function(r, par, label, colorpr)
  local   str,  cont,  a,  s;
  str := "\n<div class=\"example\"><pre>";
  cont := "";
  for a in r.content do 
    # here we try to avoid reformatting
    if IsString(a.content) then
      GAPDoc2HTMLProcs.PCDATA(a, cont); 
    else
      s := "";
      GAPDoc2HTML(a, s);
      Append(cont, s);
    fi;
  od;
  if colorpr then
    cont := GAPDoc2HTMLProcs.AddColorPromptMarkup(cont);
  fi;
  Append(str, cont);
  Append(str, "</pre></div>\n\n");
  Add(par, r.count);
  Add(par, str);
end;

##  log of session and GAP code is typeset the same way as <Example>
GAPDoc2HTMLProcs.Example := function(r, par)
  GAPDoc2HTMLProcs.ExampleLike(r, par, "Example", true);
end;
GAPDoc2HTMLProcs.Log := function(r, par)
  GAPDoc2HTMLProcs.ExampleLike(r, par, "Log", true);
end;
GAPDoc2HTMLProcs.Listing := function(r, par)
  GAPDoc2HTMLProcs.ExampleLike(r, par, "Code", false);
end;

GAPDoc2HTMLProcs.Verb := function(r, par)
  local   str,  cont,  a,  s;
  str := "\n<pre class=\"normal\">\n";
  cont := "";
  for a in r.content do 
    # here we try to avoid reformatting
    if IsString(a.content) then
      GAPDoc2HTMLProcs.PCDATA(a, cont); 
    else
      s := "";
      GAPDoc2HTML(a, s);
      Append(cont, s);
    fi;
  od;
  Append(str, cont);
  Append(str, "\n</pre>\n\n");
  Add(par, r.count);
  Add(par, str);
end;

##  explicit labels
GAPDoc2HTMLProcs.Label := function(r, str)
  local num,  lab;
  num := GAPDoc2HTMLProcs.SectionNumber(r.count, "Subsection");
  lab := GAPDoc2HTMLProcs.SectionLabel(r, r.count, "Subsection"); 
  r.root.labels.(r.attributes.Name) := [num, Concatenation(lab[1],"#",lab[2])];
end;

##  citations
GAPDoc2HTMLProcs.Cite := function(r, str)
  local   key,  pos;
  key := r.attributes.Key;
  pos := Position(r.root.bibkeys, key);
  if pos = fail then
    Add(r.root.bibkeys, key);
    Append(str, Concatenation("[?", key, "?]"));
  elif  not IsBound(r.root.biblabels) then
    Append(str, Concatenation("[?", key, "?]"));
  else
    # here we include a link to the corresponding entry in bibliography 
    Append(str, Concatenation("<a href=\"chapBib", GAPDoc2HTMLProcs.ext,
                              "#biB", key, "\">[", r.root.biblabels[pos]));
    if IsBound(r.attributes.Where) then
      Append(str, ", ");
      Append(str, r.attributes.Where);
    fi;
    Append(str, "]</a>");
  fi;
end;

##  explicit index entries
GAPDoc2HTMLProcs.Subkey := GAPDoc2HTMLContent;
GAPDoc2HTMLProcs.Index := function(r, str)
  local s, sub, entry, url, a;
  
  s := "";
  sub := "";
  for a in r.content do
    if a.name = "Subkey" then
      GAPDoc2HTML(a, sub);
    else
      GAPDoc2HTML(a, s);
    fi;
  od;
  NormalizeWhitespace(s);
  NormalizeWhitespace(sub);
  if IsBound(r.attributes.Key) then
    entry := [STRING_LOWER(r.attributes.Key)];
  else
    entry := [STRING_LOWER(s)];
  fi;
  if IsBound(r.attributes.Subkey) then
    Add(entry, r.attributes.Subkey);
  else
    Add(entry, sub);
  fi;
  Add(entry, GAPDoc2HTMLProcs.SectionNumber(r.count, "Subsection"));
  Add(entry, s);
  url := GAPDoc2HTMLProcs.SectionLabel(r, r.count, "Subsection");
  Add(entry, Concatenation(url[1],"#",url[2]));
  if Length(sub) > 0 then
    Add(entry, sub);
  fi;
  Add(r.root.index, entry);
end;

##  helper to add markup to the args
GAPDoc2HTMLProcs.WrapArgs := function(argstr)
  local res, noletter, c;
  res := "";
  noletter := true;
  for c in argstr do
    if noletter then
      if not c in ", []" then
        noletter := false;
        Append(res, GAPDoc2HTMLProcs.TextAttr.Arg[1]);
      fi;
    elif c in ", []" then
      noletter := true;
      Append(res, GAPDoc2HTMLProcs.TextAttr.Arg[2]);
    fi;
    Add(res, c);
  od;
  if not noletter then
    Append(res, GAPDoc2HTMLProcs.TextAttr.Arg[2]);
  fi;
  return res;
end;

##  this produces an implicit index entry and a label entry
GAPDoc2HTMLProcs.LikeFunc := function(r, par, typ)
  local   attr,  s,  name,  lab, url;
  attr := GAPDoc2HTMLProcs.TextAttr.Func;
  name := GAPDoc2HTMLProcs.EscapeAttrVal(r.attributes.Name);
  s := Concatenation(attr[1], "&#8227; ", name, attr[2]);
  if IsBound(r.attributes.Arg) then
    Append(s, Concatenation("( ", GAPDoc2HTMLProcs.WrapArgs(
              GAPDoc2HTMLProcs.EscapeAttrVal(
              NormalizedArgList(r.attributes.Arg))), " )"));
  fi;
  # index entry
  attr := GAPDoc2HTMLProcs.TextAttr.Func;
  url := GAPDoc2HTMLProcs.SectionLabel(r, r.count, "Subsection");
  url := Concatenation(url[1],"#",url[2]);
  if IsBound(r.attributes.Label) then
    lab := r.attributes.Label;
  else
    lab := "";
  fi;
  Add(r.root.index, [STRING_LOWER(name), lab, 
          GAPDoc2HTMLProcs.SectionNumber(r.count, "Subsection"), 
          Concatenation(attr[1], name, attr[2]),
          url]);
  # label (if not given, the default is the Name)
  if IsBound(r.attributes.Label) then
    if IsBound(r.attributes.Name) then
      lab := Concatenation(r.attributes.Name, " (", r.attributes.Label, ")");
    else
      lab := r.attributes.Label;
    fi;
  else
    lab := r.attributes.Name;  
  fi;
  GAPDoc2HTMLProcs.Label(rec(count := r.count, attributes := rec(Name
                                             := lab), root := r.root), par); 
  # adding  hint about the type of the variable  
  s := Concatenation("<div class=\"func\"><table class=\"func\" ", 
               "width=\"100%\">", 
               "<tr><td class=\"tdleft\">", s,
               "</td><td class=\"tdright\">( ", typ, 
               " )</td></tr></table></div>\n");
  Add(par, r.count);
  Add(par, s);
end;

GAPDoc2HTMLProcs.Func := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Func);
end;

GAPDoc2HTMLProcs.Oper := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Oper);
end;

GAPDoc2HTMLProcs.Meth := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Meth);
end;

GAPDoc2HTMLProcs.Filt := function(r, str)
  # r.attributes.Type could be "representation", "category", ...
  if IsBound(r.attributes.Type) then
    GAPDoc2HTMLProcs.LikeFunc(r, str, LowercaseString(r.attributes.Type));
  else
    GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Filt);
  fi;
end;

GAPDoc2HTMLProcs.Prop := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Prop);
end;

GAPDoc2HTMLProcs.Attr := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Attr);
end;

GAPDoc2HTMLProcs.Var := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Var);
end;

GAPDoc2HTMLProcs.Fam := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.Fam);
end;

GAPDoc2HTMLProcs.InfoClass := function(r, str)
  GAPDoc2HTMLProcs.LikeFunc(r, str, GAPDocTexts.d.InfoClass);
end;

##  using the HelpData(.., .., "ref") interface
GAPDoc2HTMLProcs.ResolveExternalRef := function(bookname,  label, nr)
  local info, match, res;
  info := HELP_BOOK_INFO(bookname);
  if info = fail then
    return fail;
  fi;
  match := Concatenation(HELP_GET_MATCHES(info, SIMPLE_STRING(label), true));
  if Length(match) < nr then
    return fail;
  fi;

  atomic readwrite HELP_REGION do
  res := HELP_BOOK_HANDLER.(info.handler).HelpData(info, match[nr][2], "ref");
  res[1] := SubstitutionSublist(res[1], " (not loaded): ", ": ", "one");
  return res;
  od;
end;

##  helper for external URLs, remove GAPDocStyle part and maybe add "_mj"
GAPDoc2HTMLProcs.AdjustExtURL := function(r, url)
  local pos, pos2, res, fnam, mjnam;
  pos := PositionSublist(url, "?GAPDocStyle=");
  if pos <> fail then
    pos2 := Position(url, '#', pos);
    if pos2 = fail then
      pos2 := Length(url)+1;
    fi;
    res := url{[1..pos-1]};
    Append(res, url{[pos2..Length(url)]});
  else
    res :=url;
  fi;
  if r.root.mathmode = "MathJax" then
    pos := Position(res, '#');
    if pos <> fail then
      fnam := res{[1..pos-1]};
    else
      pos := Length(res)+1;
      fnam := res;
    fi;
    if Length(fnam) >= 5 and fnam{[Length(fnam)-4..Length(fnam)]} = ".html" then
      mjnam := Concatenation(fnam{[1..Length(fnam)-5]}, "_mj.html");
      if IsExistingFile(mjnam) then
        res := Concatenation(mjnam, res{[pos..Length(res)]});
      fi;
    fi;
  fi;
  return res;
end;

##  a try to make it somewhat shorter than for the Text and LaTeX conversions
GAPDoc2HTMLProcs.Ref := function(r, str)
  local int,  txt,  ref,  lab,  attr,  sectlike, rattr;
  
  rattr := GAPDoc2HTMLProcs.TextAttr.Ref;
  int := Difference(NamesOfComponents(r.attributes), ["BookName", "Label",
         "Style"]);
  if Length(int)>0 and int[1] <> "Text" then
    lab := r.attributes.(int[1]);
  else
    lab := "";
  fi;
  if IsBound(r.attributes.Label) then
    if Length(lab) > 0 then
      lab := Concatenation(lab, " (", r.attributes.Label, ")");
    else
      lab := r.attributes.Label;
    fi;
  fi;
  if IsBound(r.attributes.BookName) then
    ref := GAPDoc2HTMLProcs.ResolveExternalRef(r.attributes.BookName, lab, 1);
    if ref <> fail and ref[6] <> fail then
      ref[6] := GAPDoc2HTMLProcs.AdjustExtURL(r, ref[6]);
      if IsBound(GAPDoc2HTMLProcs.RelPath) and 
         PositionSublist(ref[6], GAPInfo.MainRootPath) = 1 then
         ref[6] := Concatenation(GAPDoc2HTMLProcs.RelPath, "/", 
                   ref[6]{[Length(GAPInfo.MainRootPath)+1..Length(ref[6])]});
      fi;
      if IsBound(r.attributes.Style) and r.attributes.Style = "Number" then
        ref := Concatenation("<a href=\"", ref[6], "\">",rattr[1],
               r.attributes.BookName, " ", ref[2], rattr[2],"</a>");
      elif IsBound(r.attributes.Text) then
        ref := Concatenation("<a href=\"", ref[6], "\">", rattr[1], 
               r.attributes.Text, rattr[2], "</a>");
      else
        ref := Concatenation("<a href=\"", ref[6], "\">", rattr[1], ref[1],
               rattr[2], "</a>");
      fi;
    elif ref <> fail then
      ref := Concatenation(rattr[1], ref[1], rattr[2]);
    else
      if GAPDoc2HTMLProcs.FirstRun <> true then
        Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
      fi;
      ref := Concatenation(rattr[1], "???", rattr[2]);
    fi;
  else
    if IsBound(r.root.labels.(lab)) then
      if not IsBound(r.attributes.Text) then
        ref := Concatenation("<a href=\"", r.root.labels.(lab)[2], "\">",
                             rattr[1], r.root.labels.(lab)[1], rattr[2],
                             "</a>");
      else
        ref := Concatenation("<a href=\"", r.root.labels.(lab)[2], "\">",
                             rattr[1], r.attributes.Text, rattr[2], "</a>");
      fi;
    else
      if GAPDoc2HTMLProcs.FirstRun <> true then
        Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
      fi;
      ref := Concatenation(rattr[1], "???", rattr[2]);
    fi;
  fi;
  if Length(int)>0 and int[1] in [ "Func", "Oper", "Meth", "Filt", "Prop", 
                                   "Attr", "Var", "Fam", "InfoClass" ] then
    attr := GAPDoc2HTMLProcs.TextAttr.Func;
    txt := Concatenation(attr[1], 
             GAPDoc2HTMLProcs.EscapeAttrVal(r.attributes.(int[1])), attr[2]);
    # avoid reference to current subsection
    if IsBound(r.attributes.BookName) or not IsBound(r.root.labels.(lab)) 
      or GAPDoc2HTMLProcs.SectionNumber(r.count, "Subsection") <> 
                                                r.root.labels.(lab)[1] then
      Append(txt, Concatenation(" (", ref, ")"));
    fi;
  elif Length(int)>0 and 
       int[1] in [ "Sect", "Subsect", "Chap", "Appendix"] and 
       IsBound(r.attributes.Style) and
       r.attributes.Style = "Text" then
    if IsBound(r.root.labeltexts.(lab)) then
      txt := Concatenation("<a href=\"",r.root.labels.(lab)[2],
             "\">",rattr[1],r.root.labeltexts.(lab),rattr[2],"</a>");
    else
      if GAPDoc2HTMLProcs.FirstRun <> true then
        Info(InfoGAPDoc, 1, "#W WARNING: non resolved reference: ",
                            r.attributes, "\n");
      fi;
      txt := Concatenation(rattr[1], "???", rattr[2]);
    fi;
  else
    txt := ref;
  fi;
  Append(str, txt);
end;

GAPDoc2HTMLProcs.Description := GAPDoc2HTMLContent;

GAPDoc2HTMLProcs.Returns := function(r, par)
  local l;
  l := [];
  GAPDoc2HTMLContent(r, l);
  if Length(l) > 0 then
    l[2] := Concatenation("<p>", GAPDocTexts.d.Returns, 
                          ": ", l[2]{[4..Length(l[2])]});
  fi;
  Append(par, l);
end;

GAPDoc2HTMLProcs.ManSection := function(r, par)
  local   strn,  funclike,  i,  num,  s,  lab, ind;
  
  # if there is a Heading then handle as subsection
  if ForAny(r.content, a-> IsRecord(a) and a.name = "Heading") then
    GAPDoc2HTMLProcs.ChapSect(r, par, "Subsection");
    return;
  fi;
  strn := "";
  # function like elements
  funclike := [ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", 
                "Fam", "InfoClass" ];
  
  # heading comes from name of first function like element
  i := 1;
  while not r.content[i].name in funclike do
    i := i+1;
  od;
  
  num := GAPDoc2HTMLProcs.SectionNumber(r.count, "Subsection");
  s := Concatenation(num, " ", 
         GAPDoc2HTMLProcs.EscapeAttrVal(r.content[i].attributes.Name));
  Add(par, r.count);
  # avoid MathJax interpretation in \(, \[ outside <code>
  if '\\' in s then
    s := Concatenation("<code>",s,"</code>");
  fi;
  Add(par, Concatenation("\n<h5>", s, "</h5>\n\n"));
  
  # append to TOC as subsection
  lab := GAPDoc2HTMLProcs.SectionLabel(r, r.count, "Subsection");
  lab := Concatenation(lab[1], "#", lab[2]);
  ind := "<span class=\"ContSS\"><br /><span class=\"nocss\">&nbsp;&nbsp;</span>";
  Append(r.root.toc, Concatenation(ind, "<a href=\"", lab, "\">", s, 
          "</a></span>\n"));

  # label entry, if present
  if IsBound(r.attributes.Label) then
    r.root.labels.(r.attributes.Label) := [num, lab];
    r.root.labeltexts.(r.attributes.Label) := s;
  fi;

  GAPDoc2HTMLContent(r, par);
end;

GAPDoc2HTMLProcs.Mark := function(r, str)
  GAPDoc2HTMLProcs.WrapAttr(r, str, "Mark");
end;

GAPDoc2HTMLProcs.Item := function(r, str)
  GAPDoc2HTMLContent(r, str);
end;

# must do the complete formatting 
GAPDoc2HTMLProcs.List := function(r, par)
  local   s,  a,  ss, i;
  s := "\n";
  if "Mark" in List(r.content, a-> a.name) then
    # a <dl> list
    Append(s, "<dl>\n");
    for a in r.content do
      if a.name = "Mark" then
        ss := "";
        GAPDoc2HTMLProcs.Mark(a, ss);
        Append(s, Concatenation("<dt>", ss, "</dt>\n"));
      elif a.name = "Item" then
        ss := "";
        GAPDoc2HTMLProcs.Item(a, ss);
        ss := Concatenation(Filtered(ss, IsString));
        ss := Concatenation("<dd>", ss, "</dd>\n");
        Append(s, ss);
      fi;
    od;
    Append(s, "</dl>\n");
  else
    # a <ul> list
    Append(s, "<ul>\n");
    for a in r.content do
      if a.name = "Item" then
        ss := "";
        GAPDoc2HTMLProcs.Item(a, ss);
        ss := Concatenation(Filtered(ss, IsString));
        Append(s, Concatenation("<li>", ss, "</li>\n"));
      fi;
    od;
    Append(s, "</ul>\n");
  fi;
  Add(par, r.count);
  Add(par, s);
end;

##  and this is an <ol> list
GAPDoc2HTMLProcs.Enum := function(r, par)
  local   s,  i,  a,  ss,  num;
  s := "";
  # a <ul> list
  Append(s, "<ol>\n");
  for a in r.content do
    if a.name = "Item" then
      ss := "";
      GAPDoc2HTMLProcs.Item(a, ss);
      if not IsString(ss) then
        ss := Concatenation(Filtered(ss, IsString));
      fi;
      Append(s, Concatenation("<li>", ss, "</li>\n"));
    fi;
  od;
  Append(s, "</ol>\n");
  Add(par, r.count);
  Add(par, s);
end;

GAPDoc2HTMLProcs.TheIndex := function(r, par)
  local   s;
  
  # add index to TOC
  Append(r.root.toc, Concatenation("<div class=\"ContChap\"><a href=\"chapInd",
                        GAPDoc2HTMLProcs.ext, "\"><span class=\"Heading\">", 
                        GAPDocTexts.d.Index, "</span></a></div>\n")); 
  # the text, if available
  Add(par, r.count);
  if IsBound(r.root.indextext) then
    Add(par, Concatenation("\n<div class=\"index\">\n<h3>",
                           GAPDocTexts.d.Index, "</h3>\n\n",
          r.root.indextext, "<p> </p>\n</div>\n"));
  else
    Add(par,"<p>INDEX\n-----------</p>\n\n");
  fi;
end;

GAPDoc2HTMLProcs.AltYes := function(r)
  local mark, mj, l;
  # recursively mark text as HTML code (no escaping of HTML markup)
  mark := function(r)
    local a;
    if IsString(r.content) then
      r.HTML := true;
    elif IsList(r.content) then
      for a in r.content do
        mark(a);
      od;
    fi;
  end;
  mj := r.root.mathmode="MathJax";
  if IsBound(r.attributes.Only) then
    l := SplitString(r.attributes.Only, "", "\n\r\t ,");
    if "HTML" in l then
      if "MathJax" in l then
        if mj then
          mark(r);
          return true;
        else
          return false;
        fi;
      elif "noMathJax" in l then
        if not mj then
          mark(r);
          return true;
        else
          return false;
        fi;
      else
        mark(r);
        return true;
      fi;
    else
      return false;
    fi;
  elif IsBound(r.attributes.Not) then
    # here, even if it is used, it is not HTML specific, so we not 'mark'
    l := SplitString(r.attributes.Not, "", "\n\r\t ,");
    if "HTML" in l then
      if "MathJax" in l then
        if mj then
          return false;
        else
          return true;
        fi;
      elif "noMathJax" in l then
        if not mj then
          return false;
        else
          return true;
        fi;
      else
        return false;
      fi;
    else
      return true;
    fi;
  fi;
  return true;
end;

GAPDoc2HTMLProcs.Alt := function(r, str)
  if GAPDoc2HTMLProcs.AltYes(r) then
    GAPDoc2HTMLContent(r, str);
  fi;
end;

# nothing special to do
GAPDoc2HTMLProcs.Address := function(r, str)
  GAPDoc2HTMLContent(r, str);
end;

# copy a few entries with two element names
GAPDoc2HTMLProcs.E := GAPDoc2HTMLProcs.Emph;
GAPDoc2HTMLProcs.Keyword := GAPDoc2HTMLProcs.K;
GAPDoc2HTMLProcs.Code := GAPDoc2HTMLProcs.C;
GAPDoc2HTMLProcs.File := GAPDoc2HTMLProcs.F;
GAPDoc2HTMLProcs.Button := GAPDoc2HTMLProcs.B;
GAPDoc2HTMLProcs.Arg := GAPDoc2HTMLProcs.A;
GAPDoc2HTMLProcs.Quoted := GAPDoc2HTMLProcs.Q;
GAPDoc2HTMLProcs.Par := GAPDoc2HTMLProcs.P;

# tables and utilities, not so nice since | and <Horline/> cannot be handled
GAPDoc2HTMLProcs.Table := function(r, s)
  local str, cap, al,  a, i;
  str := "";
  if not GAPDoc2HTMLProcs.AltYes(r) then
    return;
  fi;
  # label
  if IsBound(r.attributes.Label) then
    GAPDoc2HTMLProcs.Label(rec(count := r.count, root := r.root, 
              attributes := rec(Name := r.attributes.Label)), str);
  fi;
  # alignments, table has borders and lines everywhere if any | or HorLine
  # is specified
  Append(str, "<div class=\"pcenter\"><table class=\"GAPDocTable");
  if not '|' in r.attributes.Align and 
                                  Length(XMLElements(r, "HorLine")) = 0 then
    Append(str, "noborder");
  fi;
  Append(str, "\">\n");
  # the caption, if given
  cap := Filtered(r.content, a-> a.name = "Caption");
  if Length(cap) > 0 then
    GAPDoc2HTMLProcs.Caption1(cap[1], str);
  fi;

  al := Filtered(r.attributes.Align, x-> x <> '|');
  for i in [1..Length(al)] do
    if al[i] = 'c' then
      al[i] := "\"tdcenter\"";
    elif al[i] = 'l' then
      al[i] := "\"tdleft\"";
    else
      al[i] := "\"tdright\"";
    fi;
  od;
  # the rows of the table
  for a in r.content do 
    if a.name = "Row" then
      GAPDoc2HTMLProcs.Row(a, str, al);
    fi;
  od;
  Append(str, "</table><br /><p>&nbsp;</p><br />\n");
  Append(str, "</div>\n\n");
  Add(s, r.count);
  Add(s, str);
end;

# do nothing, we call .Caption1 directly in .Table
GAPDoc2HTMLProcs.Caption := function(r, str)
  return;
end;

# here the caption text is produced
GAPDoc2HTMLProcs.Caption1 := function(r, str)
  Append(str, Concatenation("<caption class=\"GAPDocTable\"><b>", 
                                  GAPDocTexts.d.Table, ": </b>"));
  GAPDoc2HTMLContent(r, str);
  Append(str, "</caption>\n");
end;

# cannot be chosen in HTML
GAPDoc2HTMLProcs.HorLine := function(r, str)
end;

GAPDoc2HTMLProcs.Row := function(r, str, al)
  local s, i, l;
  Append(str, "<tr>\n");
  l := Filtered(r.content, a-> a.name = "Item");
  for i in [1..Length(l)] do
    s := "";
    GAPDoc2HTMLContent(l[i], s);
    if not IsString(s) then
      s := Concatenation(Filtered(s, IsString));
    fi;
    # throw away <p> tags in table entries
    if Length(s) > 5 and s{[1..3]} = "<p>" and 
                         s{[Length(s)-5..Length(s)]} = "</p>\n\n" then
      s := s{[4..Length(s)-6]};
    fi;
    Append(str, Concatenation("<td class=", al[i], ">", s, "</td>\n"));
  od;
  while i < Length(al) do
    Append(str, "<td>&#160;</td>\n");
    i := i+1;
  od;
  Append(str, "</tr>\n");
end;


##  
##  <#GAPDoc Label="GAPDoc2HTMLPrintHTMLFiles">
##  <ManSection >
##  <Func Arg="t[, path]" Name="GAPDoc2HTMLPrintHTMLFiles" />
##  <Returns>nothing</Returns>
##  <Description>
##  The  first   argument  must   be  a   result  returned   by  <Ref
##  Func="GAPDoc2HTML"/>. The second argument is a path for the files
##  to write, it can be given as string or directory object. The text
##  of  each  chapter is  written  into  a  separate file  with  name
##  <F>chap0.html</F>,  <F>chap1.html</F>,  ...,  <F>chapBib.html</F>,
##  and <F>chapInd.html</F>.<P/>
## 
##  The <Package>MathJax</Package> versions are written to files
##  <F>chap0_mj.html</F>, ..., <F>chapInd_mj.html</F>. <P/>
##  
##  The  experimental version  which  is  produced with  <C>tth</C>
##  uses  different  names  for   the  files,  namely
##  <F>chap0_sym.html</F>,  and so  on  for  files which  need
##  symbol  fonts.
##  <P/>
##  
##  You should also add stylesheet files to the directory with the HTML
##  files, see <Ref Subsect="StyleSheets"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
##  Finally a function to print the text files:
InstallGlobalFunction(GAPDoc2HTMLPrintHTMLFiles, function(t, path)
  local   a;
  if IsString(path) then
    path := Directory(path);
  fi;
  for a in NamesOfComponents(t) do
    if IsRecord(t.(a)) and IsBound(t.(a).text) then
      FileString(Filename(path, Concatenation("chap", a, t.ext)), t.(a).text);
    fi;
  od;
end);

InstallGlobalFunction(CopyHTMLStyleFiles, function(dir)
  local d, todo, l, s, e, f;
  if not IsDirectory(dir) then
    dir := Directory(dir);
  fi;
  d := DirectoriesPackageLibrary("GAPDoc","styles")[1];
  todo := [];
  for f in DirectoryContents(d) do
    if f = "chooser.html" then
      Add(todo, f);
    else
      l := Length(f);
      if l > 3 and f{[l-2..l]} = ".js" then
        Add(todo, f);
      elif l > 4 and f{[l-3..l]} = ".css" then
        Add(todo, f);
      fi;
    fi;
  od;
  for f in todo do
    s := StringFile(Filename(d,f));
    if s = fail then
      Info(InfoGAPDoc, 1, "Cannot read file ", Filename(d,f), "\n");
    else
      e := FileString(Filename(dir,f), s);
      if e = fail then
        Info(InfoGAPDoc, 1, "Cannot write file ", Filename(dir,f), "\n");
      fi;
    fi;
  od;
end);

