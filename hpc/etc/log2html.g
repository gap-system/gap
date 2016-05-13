#############################################################################
##
#W  log2html.g             GAP *.log - File --> HTML              Stefan Kohl
##
#H  @(#)$Id: log2html.g,v 1.1 2004/04/19 15:48:56 stefan Exp $
##
##  Utility to convert GAP log files to XHTML 1.0 Strict.
##
##  Usage:
##
##  - Load this file into GAP.
##
##  - Issue Log2HTML( <logfilename> ), where the path must be relative to
##    your home directory. The extension of the input file must be .log.
##    The name of the output file is the same as the one of the input file
##    except that the extension .log is replaced by .html.
##
##  - Adjust the style file gaplog.css to your taste.
##
WKDir := Directory("~/");

Log2HTML := function ( logfilename )

  local  input, output, s1, s2, header, footer, pos, lastlf, nextlf, prompt;

  header := Concatenation(
              "<?xml version = \"1.0\" encoding = \"ISO-8859-1\"?>\n\n",
              "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n",
              "                      \"http://www.w3.org/TR/xhtml1/DTD/",
              "xhtml1-strict.dtd\">\n<html>\n\n<head>\n  <title> ",
              logfilename, " </title>\n  <link rel = \"stylesheet\" ",
              "type = \"text/css\" href = \"gaplog.css\" />\n",
              "</head>\n\n<body>\n\n<pre class = \"logfile\">\n");
  footer := "</pre> </body> </html>";
  input := InputTextFile(Filename(WKDir,logfilename));
  s1 := ReadAll(input); CloseStream(input);
  pos := PositionSublist(s1,"gap>"); prompt := "gap> ";
  s2 := ReplacedString(s1{[1..pos-1]},"<","&lt;");
  while pos <> fail do
    s2 := Concatenation(s2,"<em class = \"prompt\">",prompt,"</em>");
    s2 := Concatenation(s2,"<em class = \"input\">");
    nextlf := Position(s1,'\n',pos); prompt := "gap>";
    if nextlf = fail then nextlf := Length(s1); fi;
    s2 := Concatenation(s2,ReplacedString(s1{[pos+5..nextlf-1]},"<","&lt;"),
                        "</em>");
    while nextlf < Length(s1) and s1[nextlf+1] = '>' do
      s2 := Concatenation(s2,"\n<em class = \"prompt\">></em>",
                          "<em class = \"input\">");
      lastlf := nextlf;
      nextlf := Position(s1,'\n',lastlf);
      if nextlf = fail then nextlf := Length(s1); fi;
      s2 := Concatenation(s2,ReplacedString(s1{[lastlf+2..nextlf-1]},
                                            "<","&lt;"),"</em>");
    od;
    s2 := Concatenation(s2,"\n");
    pos := PositionSublist(s1,"\ngap>",nextlf-1);
    if pos = fail then pos := Length(s1); fi;
    if pos > nextlf then
      s2 := Concatenation(s2,"<em class = \"output\">",
                          ReplacedString(s1{[nextlf+1..pos-1]},"<","&lt;"),
                          "</em>\n");
    fi;
    if pos > Length(s1) - 3 then break; fi;
  od;
  s2 := Concatenation(header,s2,footer);
  output := OutputTextFile(Filename(WKDir,ReplacedString(logfilename,
                           ".log",".html")),false);
  WriteAll(output,s2); CloseStream(output);
end;

#############################################################################
##
#E  log2html.g . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
